import 'dart:io';

import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_pharmacy/data/accounting_repository.dart';
import 'package:doaya_pharmacy/data/catalog_repository.dart';
import 'package:doaya_pharmacy/data/database.dart';
import 'package:doaya_pharmacy/data/ledger_repository.dart';
import 'package:doaya_pharmacy/data/till_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const syp = Currency.syp;
  const s = Session(deviceId: 'laptop', employeeId: 'rana');

  test('v4 database upgrades to v5: ref_id + append-only accounting tables', () async {
    final v4 = File('test/fixtures/schema_v4.sql').readAsStringSync();
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute(v4);
          raw.execute(
            "INSERT INTO stock_events (id, type, product_id, batch_id, quantity, device_id, "
            "employee_id, occurred_at) VALUES ('e1', 'received', 'p', 'e1', 5, 'd', 'e', "
            "'2026-09-01T00:00:00.000Z')",
          );
          raw.execute('PRAGMA user_version = 4');
        },
      ),
    );
    addTearDown(db.close);
    expect((await LedgerRepository(db).loadStock()).onHand('p'), 5);
    expect(
      () => db.customStatement("UPDATE stock_events SET ref_id = 'x' WHERE id = 'e1'"),
      throwsA(isA<SqliteException>()),
    );
    final acc = AccountingRepository(db, LedgerRepository(db));
    await acc.addExpense(
      s,
      category: 'rent',
      amount: const Money(100, syp),
      paidFrom: PaidFrom.outside,
    );
    expect(() => db.delete(db.expenseEvents).go(), throwsA(isA<SqliteException>()));
  });

  group('accounting on SQLite', () {
    late AppDatabase db;
    late LedgerRepository ledger;
    late AccountingRepository acc;
    late ProductRow amox;
    late SupplierRow ibnSina;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      ledger = LedgerRepository(db);
      acc = AccountingRepository(db, ledger);
      amox = await CatalogRepository(db).create(
        const ProductDraft(tradeName: 'Amoxil', activeIngredient: 'amoxicillin', priceMinor: 4500),
        deviceId: 'laptop',
      );
      ibnSina = await acc.addSupplier(name: 'مستودع ابن سينا', phone: '011٢٢٢');
    });
    tearDown(() => db.close());

    Future<CompletedPurchase> buy({
      int qty = 10,
      int bonus = 2,
      PurchasePayment payment = PurchasePayment.credit,
      PaidFrom? from,
      Map<String, int> newPrices = const {},
    }) => acc.recordPurchase(
      s,
      supplierId: ibnSina.id,
      items: [
        PurchaseItem(
          productId: amox.id,
          quantity: qty,
          bonus: bonus,
          unitPriceMinor: 3000,
          expiry: DateTime.utc(2027, 6, 1),
        ),
      ],
      currency: syp,
      payment: payment,
      paidFrom: from,
      supplierInvoiceNo: 'F-٧٧',
      newSalePrices: newPrices,
    );

    test('purchase on credit: stock with bonus, supplier debt, cost book, new price', () async {
      final p = await buy(newPrices: {amox.id: 4800});
      expect(ibnSina.phone, '011222');
      expect((await ledger.loadStock()).onHand(amox.id), 12);
      expect((await acc.loadSupplierLedger()).balance(ibnSina.id), 30000);
      final book = await acc.costBook();
      expect(book.costOf(p.lines.single.batchId, 3), 7500);
      final row = await (db.select(db.purchases)..where((t) => t.id.equals(p.id))).getSingle();
      expect((row.supplierInvoiceNo, row.employeeId), ('F-77', 'rana'));
      expect((await CatalogRepository(db).byId(amox.id))!.priceMinor, 4800);
      expect((await acc.priceHistory(amox.id)).single.unitPriceMinor, 3000);
    });

    test('profit of a sale uses the batch cost', () async {
      await buy();
      final sale = await ledger.sell(
        s,
        cart: [CartLine(productId: amox.id, quantity: 3, unitPrice: const Money(4500, syp))],
        currency: syp,
        payment: PaymentType.cash,
      );
      final p = profitOf(
        revenueMinor: sale.totalMinor,
        stockEvents: sale.stockEvents,
        costs: await acc.costBook(),
      );
      expect((p.costMinor, p.profitMinor, p.complete), (7500, 13500 - 7500, true));
    });

    test('profit report: discount spread over lines, a customer return subtracts both', () async {
      await buy(); // 30000 for 12 pieces: 25.00 each
      final sale = await ledger.sell(
        s,
        cart: [CartLine(productId: amox.id, quantity: 3, unitPrice: const Money(4500, syp))],
        currency: syp,
        payment: PaymentType.cash,
        discountMinor: 1500,
      );
      await ledger.processReturn(
        const Session(deviceId: 'laptop', employeeId: 'sam'),
        items: [
          ReturnItem(
            productId: amox.id,
            quantity: 1,
            unitPrice: const Money(4500, syp),
            saleLineId: sale.lines.single.id,
          ),
        ],
        currency: syp,
        refund: RefundMethod.cash,
        saleId: sale.id,
      );
      final now = DateTime.now();
      final r = await acc.profitReport(
        now.subtract(const Duration(hours: 1)),
        now.add(const Duration(hours: 1)),
      );
      expect((r.total.revenueMinor, r.total.costMinor), (12000 - 4500, 7500 - 2500));
      expect(r.total.profitMinor, 2500);
      expect(r.byEmployee['rana']!.profitMinor, 12000 - 7500);
      expect(r.byEmployee['sam']!.profitMinor, -4500 + 2500);
      expect(r.byProduct[amox.id]!.complete, isTrue);
      // A period with nothing in it.
      final empty = await acc.profitReport(DateTime(2020), DateTime(2020, 2));
      expect(empty.byProduct, isEmpty);
      // Stock value at cost: 12 − 3 + 1 = 10 pieces at 25.00.
      expect(stockValue(await ledger.loadStock(), await acc.costBook()).costMinor, 25000);
    });

    test('shortages and purchase orders: create per supplier, edit, receive, delete', () async {
      // Amoxil: none in stock, minimum 5 boxes → out of stock, 6 boxes suggested.
      var list = await acc.shortages();
      expect(list.single.productId, amox.id);
      expect((list.single.reason, list.single.suggestedPacks), (ShortageReason.outOfStock, 6));
      expect(await acc.lastPurchases(), isEmpty);

      await buy(); // 12 pieces from Ibn Sina at 30.00
      list = await acc.shortages();
      expect(list, isEmpty); // 12 > minimum 5
      expect((await acc.lastPurchases())[amox.id]!.supplierId, ibnSina.id);

      final ids = await acc.createOrders({
        ibnSina.id: [(amox.id, 6)],
        'empty-supplier': [(amox.id, 0)], // nothing wanted → no order
      });
      expect(ids, hasLength(1));
      final line = (await acc.orderLines(ids.single)).single;
      expect(line.quantity, 6);
      await acc.setOrderLineQuantity(line.id, 8);
      expect((await acc.orderLines(ids.single)).single.quantity, 8);
      await acc.setOrderStatus(ids.single, 'sent');
      expect((await acc.order(ids.single))!.status, 'sent');
      await acc.setOrderLineQuantity(line.id, 0);
      expect(await acc.orderLines(ids.single), isEmpty);
      await acc.deleteOrder(ids.single);
      expect(await acc.order(ids.single), isNull);
    });

    test('payment and return to supplier update the statement', () async {
      final p = await buy();
      await acc.paySupplier(
        s,
        supplierId: ibnSina.id,
        amount: const Money(10000, syp),
        paidFrom: PaidFrom.outside,
      );
      await acc.returnToSupplier(
        s,
        supplierId: ibnSina.id,
        currency: syp,
        refundInCash: false,
        items: [
          SupplierReturnItem(
            productId: amox.id,
            pieces: 2,
            creditMinor: 5000,
            batchId: p.lines.single.batchId,
          ),
        ],
      );
      final l = await acc.loadSupplierLedger();
      expect(l.balance(ibnSina.id), 30000 - 10000 - 5000);
      expect(l.statement(ibnSina.id).map((x) => x.$2), [30000, 20000, 15000]);
      expect((await ledger.loadStock()).onHand(amox.id), 10);
    });

    test('drawer: cash purchase, supplier payment and expense lower the expected cash', () async {
      final till = TillRepository(db);
      final shift = await till.openShift(s, floatMinor: 100000);
      await buy(payment: PurchasePayment.cash, from: PaidFrom.drawer); // 30000
      await acc.paySupplier(
        s,
        supplierId: ibnSina.id,
        amount: const Money(2000, syp),
        paidFrom: PaidFrom.drawer,
      );
      await acc.addExpense(
        s,
        category: 'electricity',
        amount: const Money(5000, syp),
        paidFrom: PaidFrom.drawer,
      );
      await acc.addExpense(
        s,
        category: 'rent',
        amount: const Money(90000, syp),
        paidFrom: PaidFrom.outside,
      );
      final sum = (await till.summary(shift))!;
      expect(sum.expected, 100000 - 30000 - 2000 - 5000);
    });

    test('stocktake: counts at count time, applying writes adjustments', () async {
      await buy(); // 12
      final st = await acc.startStocktake(s, scope: 'B3');
      await acc.count(s, stocktakeId: st, productId: amox.id, countedPieces: 11);
      // A sale after the count doesn't change the difference.
      await ledger.sell(
        s,
        cart: [CartLine(productId: amox.id, quantity: 2, unitPrice: const Money(4500, syp))],
        currency: syp,
        payment: PaymentType.cash,
      );
      expect((await acc.openStocktake())!.id, st);
      final adj = await acc.applyStocktake(s, st);
      expect(adj, {amox.id: -1});
      expect((await ledger.loadStock()).onHand(amox.id), 12 - 2 - 1);
      expect(await acc.openStocktake(), isNull);
      final adjusted = (await db.select(db.stockEvents).get()).where((e) => e.type == 'adjusted');
      expect(adjusted.single.refId, st);
    });
  });
}
