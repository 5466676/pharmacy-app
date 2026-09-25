import 'dart:io';

import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_pharmacy/data/catalog_repository.dart';
import 'package:doaya_pharmacy/data/database.dart';
import 'package:doaya_pharmacy/data/ledger_repository.dart';
import 'package:doaya_pharmacy/data/people_repository.dart';
import 'package:doaya_pharmacy/data/reports.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const syp = Currency.syp;

  test('v1 database (Phase 1 schema) upgrades to v2 and keeps its data', () async {
    final v1 = File('test/fixtures/schema_v1.sql').readAsStringSync();
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute(v1);
          raw.execute(
            "INSERT INTO products (id, trade_name, active_ingredient, price_minor, prescription_only, "
            "low_stock_threshold, active, created_at, updated_at, updated_by_device) VALUES "
            "('p1', 'Panadol', 'paracetamol', 1800, 0, 5, 1, '2026-09-01T00:00:00.000Z', "
            "'2026-09-01T00:00:00.000Z', 'd')",
          );
          raw.execute('PRAGMA user_version = 1');
        },
      ),
    );
    addTearDown(db.close);

    final p = await CatalogRepository(db).byId('p1');
    expect(p!.unitsPerPack, 1);
    expect(p.stripPriceMinor, isNull);
    expect(await db.select(db.returns).get(), isEmpty);
    // New tables are append-only too.
    await db.customStatement(
      "INSERT INTO returns (id, refund, currency_code, total_minor, device_id, employee_id, occurred_at) "
      "VALUES ('r1', 'cash', 'SYP', 1, 'd', 'e', '2026-09-25T00:00:00.000Z')",
    );
    expect(() => db.delete(db.returns).go(), throwsA(isA<SqliteException>()));
  });

  group('strips and returns on SQLite', () {
    late AppDatabase db;
    late LedgerRepository ledger;
    late CatalogRepository catalog;
    late PeopleRepository people;
    late Session s;
    late ProductRow pan;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      ledger = LedgerRepository(db);
      catalog = CatalogRepository(db);
      people = PeopleRepository(db);
      s = const Session(deviceId: 'd', employeeId: 'e');
      pan = await catalog.create(
        const ProductDraft(
          tradeName: 'Panadol',
          activeIngredient: 'paracetamol',
          priceMinor: 1800,
          unitsPerPack: 3,
          stripPriceMinor: 650,
        ),
        deviceId: 'd',
      );
      await ledger.receive(s, productId: pan.id, quantity: 4 * 3); // 4 boxes
    });
    tearDown(() => db.close());

    CartLine box(int q) => CartLine(
      productId: pan.id,
      quantity: q,
      unitPrice: const Money(1800, syp),
      piecesPerUnit: 3,
    );
    CartLine strip(int q) =>
        CartLine(productId: pan.id, quantity: q, unitPrice: const Money(650, syp));

    test('selling boxes and strips counts stock in strips', () async {
      final sale = await ledger.sell(
        s,
        cart: [box(1), strip(2)],
        currency: syp,
        payment: PaymentType.cash,
      );
      expect(sale.totalMinor, 1800 + 1300);
      expect((await ledger.loadStock()).onHand(pan.id), 12 - 5);
      final lines = await ledger.linesOf(sale.id);
      expect(lines.map((l) => (l.quantity, l.piecesPerUnit)).toSet(), {(1, 3), (2, 1)});
    });

    test('strips-per-box is locked once stock has moved', () async {
      expect(
        () => catalog.update(
          pan.id,
          const ProductDraft(
            tradeName: 'Panadol',
            activeIngredient: 'paracetamol',
            priceMinor: 1800,
            unitsPerPack: 2,
          ),
          deviceId: 'd',
        ),
        throwsA(isA<UnitsPerPackLocked>()),
      );
    });

    test('return from a sale: limited to what is left, restores stock, cash refund', () async {
      final sale = await ledger.sell(s, cart: [box(2)], currency: syp, payment: PaymentType.cash);
      final line = (await ledger.linesOf(sale.id)).single;
      expect(await ledger.returnablePieces(sale.id), {line.id: 6});

      await ledger.processReturn(
        s,
        saleId: sale.id,
        refund: RefundMethod.cash,
        currency: syp,
        items: [
          ReturnItem(
            productId: pan.id,
            quantity: 1,
            unitPrice: const Money(1800, syp),
            piecesPerUnit: 3,
            saleLineId: line.id,
          ),
        ],
      );
      expect(await ledger.returnablePieces(sale.id), {line.id: 3});
      expect((await ledger.loadStock()).onHand(pan.id), 12 - 6 + 3);

      // Returning 2 more boxes than remain is refused and writes nothing.
      await expectLater(
        ledger.processReturn(
          s,
          saleId: sale.id,
          refund: RefundMethod.cash,
          currency: syp,
          items: [
            ReturnItem(
              productId: pan.id,
              quantity: 2,
              unitPrice: const Money(1800, syp),
              piecesPerUnit: 3,
              saleLineId: line.id,
            ),
          ],
        ),
        throwsA(isA<ReturnException>()),
      );
      expect(await db.select(db.returns).get(), hasLength(1));
    });

    test('free-form return credited to a customer debt', () async {
      final c = await people.addCustomer(name: 'أبو أحمد');
      await ledger.sell(
        s,
        cart: [box(2)],
        currency: syp,
        payment: PaymentType.debt,
        customerId: c.id,
      );
      await ledger.processReturn(
        s,
        refund: RefundMethod.debtCredit,
        customerId: c.id,
        currency: syp,
        items: [ReturnItem(productId: pan.id, quantity: 2, unitPrice: const Money(650, syp))],
      );
      expect((await ledger.loadDebts()).balance(c.id), 3600 - 1300);
      expect((await ledger.loadStock()).onHand(pan.id), 12 - 6 + 2);
    });

    test('employee account subtracts cash refunds from cash to hand in', () async {
      final sale = await ledger.sell(s, cart: [box(2)], currency: syp, payment: PaymentType.cash);
      final line = (await ledger.linesOf(sale.id)).single;
      await ledger.processReturn(
        s,
        saleId: sale.id,
        refund: RefundMethod.cash,
        currency: syp,
        items: [
          ReturnItem(
            productId: pan.id,
            quantity: 1,
            unitPrice: const Money(1800, syp),
            piecesPerUnit: 3,
            saleLineId: line.id,
          ),
        ],
      );
      final (from, to) = periodRange(ReportPeriod.today, DateTime.now());
      final e = summarizeByEmployee(
        sales: await ledger.watchSalesBetween(from, to).first,
        lines: await ledger.watchLinesBetween(from, to).first,
        payments: await ledger.watchPaymentsBetween(from, to).first,
        returns: await ledger.watchReturnsBetween(from, to).first,
      ).single;
      expect((e.returnsCount, e.cashRefundsMinor), (1, 1800));
      expect(e.cashToHandInMinor, 3600 - 1800);
    });
  });
}
