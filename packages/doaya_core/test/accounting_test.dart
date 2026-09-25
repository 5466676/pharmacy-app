import 'package:doaya_core/doaya_core.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  const syp = Currency.syp;

  CompletedPurchase buy(
    List<PurchaseItem> items, {
    PurchasePayment payment = PurchasePayment.credit,
    PaidFrom? from,
    int invoiceDiscount = 0,
    int transport = 0,
  }) => buildPurchase(
    items: items,
    supplierId: 'ibn-sina',
    currency: syp,
    payment: payment,
    paidFrom: from,
    invoiceDiscountMinor: invoiceDiscount,
    transportMinor: transport,
    supplierInvoiceNo: 'F-77',
    deviceId: 'd',
    employeeId: 'e',
    now: t0,
    ids: UuidV7(),
  );

  group('allocateProportionally', () {
    test('parts always sum to the amount', () {
      expect(allocateProportionally(100, [1, 1, 1]).fold<int>(0, (a, b) => a + b), 100);
      expect(allocateProportionally(1000, [3000, 7000]), [300, 700]);
      expect(allocateProportionally(10, [0, 0]), [5, 5]);
      expect(allocateProportionally(0, [5, 5]), [0, 0]);
    });
  });

  group('purchase invoice', () {
    test('bonus lowers the true cost per piece', () {
      // 10 boxes at 30.00 + 2 free boxes → 12 boxes cost 300.00.
      final p = buy([
        const PurchaseItem(productId: 'amox', quantity: 10, bonus: 2, unitPriceMinor: 3000),
      ]);
      expect(p.totalMinor, 30000);
      final r = p.stockEvents.single;
      expect(
        (r.type, r.quantity, r.unitCostMinor, r.refId),
        (StockEventType.received, 12, 2500, p.id),
      );
      expect(p.lines.single.costMinor, 30000);
      expect(p.lines.single.batchId, r.batchId);
    });

    test('line discount, invoice discount and transport are spread exactly', () {
      final p = buy(
        [
          const PurchaseItem(
            productId: 'a',
            quantity: 10,
            unitPriceMinor: 1000,
            discountBasisPoints: 1000,
          ),
          const PurchaseItem(productId: 'b', quantity: 1, unitPriceMinor: 1000),
        ],
        invoiceDiscount: 1000,
        transport: 501,
      );
      // gross 11000, line discount 1000 → net 9000 + 1000 (weights 9:1)
      expect((p.grossMinor, p.lineDiscountsMinor), (11000, 1000));
      expect(p.lines.map((l) => l.costMinor), [9000 - 900 + 451, 1000 - 100 + 50]);
      expect(p.lines.fold<int>(0, (s, l) => s + l.costMinor), p.totalMinor);
      expect(p.totalMinor, 11000 - 1000 - 1000 + 501);
    });

    test('strips: pieces = (quantity + bonus) × strips per box', () {
      final p = buy([
        const PurchaseItem(
          productId: 'pan',
          quantity: 5,
          bonus: 1,
          unitPriceMinor: 1500,
          piecesPerUnit: 3,
        ),
      ]);
      expect(p.stockEvents.single.quantity, 18);
    });

    test('credit adds supplier debt; cash needs a source and adds none', () {
      final credit = buy([const PurchaseItem(productId: 'a', quantity: 1, unitPriceMinor: 500)]);
      expect(credit.supplierDebtEvent!.amountMinor, 500);
      expect(credit.supplierDebtEvent!.refId, credit.id);
      expect(
        () => buy([
          const PurchaseItem(productId: 'a', quantity: 1, unitPriceMinor: 500),
        ], payment: PurchasePayment.cash),
        throwsA(
          isA<PurchaseException>().having((e) => e.code, 'code', PurchaseError.cashNeedsSource),
        ),
      );
      final cash = buy(
        [const PurchaseItem(productId: 'a', quantity: 1, unitPriceMinor: 500)],
        payment: PurchasePayment.cash,
        from: PaidFrom.drawer,
      );
      expect((cash.supplierDebtEvent, cash.paidFrom), (null, PaidFrom.drawer));
    });

    test('bad lines and discounts are refused', () {
      expect(() => buy([]), throwsA(isA<PurchaseException>()));
      expect(
        () => buy([const PurchaseItem(productId: 'a', quantity: 0, unitPriceMinor: 1)]),
        throwsA(isA<PurchaseException>().having((e) => e.code, 'code', PurchaseError.badLine)),
      );
      expect(
        () => buy([
          const PurchaseItem(productId: 'a', quantity: 1, unitPriceMinor: 100),
        ], invoiceDiscount: 101),
        throwsA(
          isA<PurchaseException>().having((e) => e.code, 'code', PurchaseError.discountTooLarge),
        ),
      );
      // A pure-bonus line (free goods only) is allowed.
      expect(
        buy([const PurchaseItem(productId: 'a', quantity: 0, bonus: 2, unitPriceMinor: 0)])
            .totalMinor,
        0,
      );
    });
  });

  group('supplier ledger', () {
    SupplierDebtEvent ev(SupplierDebtEventType t, int amount, DateTime at) => SupplierDebtEvent(
      meta: meta(at: at),
      type: t,
      supplierId: 's',
      amountMinor: amount,
      currencyCode: 'SYP',
    );

    test('balance, statement with running balance, idempotent', () {
      final a = ev(SupplierDebtEventType.purchaseOnCredit, 10000, DateTime.utc(2026, 8, 1));
      final b = ev(SupplierDebtEventType.paymentMade, 4000, DateTime.utc(2026, 8, 10));
      final c = ev(SupplierDebtEventType.returnCredited, 1000, DateTime.utc(2026, 8, 12));
      final l = SupplierLedger([c, a, b, a]);
      expect(l.balance('s'), 5000);
      expect(l.statement('s').map((x) => x.$2), [10000, 6000, 5000]);
      expect(l.totalOwed, 5000);
    });

    test('debt age: payments settle the oldest purchase first', () {
      final l = SupplierLedger([
        ev(SupplierDebtEventType.purchaseOnCredit, 10000, DateTime.utc(2026, 7, 1)),
        ev(SupplierDebtEventType.purchaseOnCredit, 5000, DateTime.utc(2026, 9, 1)),
        ev(SupplierDebtEventType.paymentMade, 12000, DateTime.utc(2026, 9, 10)),
      ]);
      final open = l.openDebts('s');
      expect(open.single.remainingMinor, 3000);
      expect(open.single.ageInDays(DateTime.utc(2026, 9, 25)), 24);
    });
  });

  group('supplier return', () {
    test('takes the chosen (expired) batch and credits the supplier', () {
      final expired = receive('a', 5, expiry: DateTime.utc(2026, 8, 1));
      final good = receive('a', 5, expiry: DateTime.utc(2027, 1, 1));
      final r = buildSupplierReturn(
        items: [
          SupplierReturnItem(
            productId: 'a',
            pieces: 5,
            creditMinor: 7500,
            batchId: expired.batchId,
          ),
        ],
        supplierId: 's',
        stock: StockLedger([expired, good]),
        currency: syp,
        refundInCash: false,
        deviceId: 'd',
        employeeId: 'e',
        now: t0,
        ids: UuidV7(),
      );
      final e = r.stockEvents.single;
      expect(
        (e.type, e.batchId, e.quantity, e.refId),
        (StockEventType.returnedToSupplier, expired.batchId, -5, r.id),
      );
      expect(r.supplierDebtEvent!.type, SupplierDebtEventType.returnCredited);
      expect(r.supplierDebtEvent!.amountMinor, 7500);
      expect(StockEventType.fromWire('returned_to_supplier'), StockEventType.returnedToSupplier);
    });

    test('cash refund creates no supplier credit; too many pieces is refused', () {
      final b = receive('a', 2);
      CompletedSupplierReturn ret(int pieces, bool cash) => buildSupplierReturn(
        items: [
          SupplierReturnItem(productId: 'a', pieces: pieces, creditMinor: 100, batchId: b.batchId),
        ],
        supplierId: 's',
        stock: StockLedger([b]),
        currency: syp,
        refundInCash: cash,
        deviceId: 'd',
        employeeId: 'e',
        now: t0,
        ids: UuidV7(),
      );
      expect(ret(1, true).supplierDebtEvent, isNull);
      expect(() => ret(3, false), throwsA(isA<InsufficientStock>()));
    });
  });

  group('cost & profit', () {
    test('sold events are valued at their batch cost; unknown batches are flagged', () {
      final costs = CostBook({'b1': const BatchCost(totalMinor: 30000, pieces: 12)}); // 25.00/piece
      StockEvent sold(String batch, int q) => move(StockEventType.sold, 'a', batch, -q);
      final p = profitOf(
        revenueMinor: 4 * 4500,
        stockEvents: [sold('b1', 3), sold('old', 1)],
        costs: costs,
      );
      expect((p.costMinor, p.unknownCostPieces, p.complete), (7500, 1, false));
      expect(p.profitMinor, 18000 - 7500);
    });

    test('a return gives its cost back', () {
      final costs = CostBook({'b1': const BatchCost(totalMinor: 1000, pieces: 10)});
      final p = profitOf(
        revenueMinor: 0,
        stockEvents: [
          move(StockEventType.sold, 'a', 'b1', -4),
          move(StockEventType.returned, 'a', 'b1', 1),
        ],
        costs: costs,
      );
      expect(p.costMinor, 300);
    });

    test('margin', () {
      const p = ProfitSummary(revenueMinor: 10000, costMinor: 7500, unknownCostPieces: 0);
      expect(p.marginBasisPoints, 2500);
      expect((p + p).profitMinor, 5000);
    });
  });

  group('profit report', () {
    final day1 = DateTime.utc(2026, 9, 1, 9), day2 = DateTime.utc(2026, 9, 2, 17);
    DateTime dayOf(DateTime t) => DateTime.utc(t.year, t.month, t.day);
    StockEvent ev(
      StockEventType type,
      String product,
      String batch,
      int q,
      String emp,
      DateTime at,
    ) => StockEvent(
      meta: EventMeta(
        id: type == StockEventType.received ? batch : ids.generate(),
        deviceId: 'd',
        employeeId: emp,
        occurredAt: at,
      ),
      type: type,
      productId: product,
      batchId: batch,
      quantity: q,
    );
    final costs = CostBook({
      'a1': const BatchCost(totalMinor: 1000, pieces: 10), // 1.00 each
      'b1': const BatchCost(totalMinor: 6000, pieces: 20), // 3.00 each
    });

    test('groups revenue and cost by product, employee and day; returns subtract', () {
      final r = buildProfitReport(
        revenue: [
          RevenueItem(productId: 'a', employeeId: 'rana', at: day1, amountMinor: 500),
          RevenueItem(productId: 'b', employeeId: 'rana', at: day1, amountMinor: 1000),
          RevenueItem(productId: 'b', employeeId: 'sam', at: day2, amountMinor: 800),
          RevenueItem(productId: 'b', employeeId: 'sam', at: day2, amountMinor: -400), // refund
        ],
        stockEvents: [
          ev(StockEventType.sold, 'a', 'a1', -2, 'rana', day1),
          ev(StockEventType.sold, 'b', 'b1', -2, 'rana', day1),
          ev(StockEventType.sold, 'b', 'b1', -2, 'sam', day2),
          ev(StockEventType.returned, 'b', 'b1', 1, 'sam', day2),
          ev(StockEventType.received, 'b', 'b2', 5, 'sam', day2), // ignored
        ],
        costs: costs,
        dayOf: dayOf,
      );
      expect((r.total.revenueMinor, r.total.costMinor), (1900, 200 + 600 + 600 - 300));
      expect(r.byProduct['a']!.profitMinor, 300);
      expect(r.byProduct['b']!.profitMinor, 1400 - 900);
      expect(r.byEmployee['rana']!.profitMinor, 1500 - 800);
      expect(r.byEmployee['sam']!.profitMinor, 400 - 300);
      expect(r.byDay[dayOf(day2)]!.revenueMinor, 400);
      expect(ProfitReport.ranked(r.byProduct).first.key, 'b');
      expect(r.total.complete, isTrue);
    });

    test('pieces from batches without a cost are counted, never guessed', () {
      final r = buildProfitReport(
        revenue: [RevenueItem(productId: 'a', employeeId: 'e', at: day1, amountMinor: 900)],
        stockEvents: [ev(StockEventType.sold, 'a', 'old', -3, 'e', day1)],
        costs: costs,
        dayOf: dayOf,
      );
      expect((r.total.costMinor, r.total.unknownCostPieces, r.total.complete), (0, 3, false));
    });

    test('stock value at cost: known batches valued, unknown pieces counted', () {
      final stock = StockLedger([
        ev(StockEventType.received, 'b', 'b1', 20, 'e', day1),
        ev(StockEventType.sold, 'b', 'b1', -5, 'e', day1),
        ev(StockEventType.received, 'a', 'old', 4, 'e', day1),
      ]);
      final v = stockValue(stock, costs);
      expect((v.costMinor, v.unknownCostPieces), (15 * 300, 4));
    });
  });

  group('stocktake', () {
    test('difference is taken at count time; last count wins; zero ignored', () {
      final adj = stocktakeAdjustments(const [
        StocktakeCount(productId: 'a', countedPieces: 8, systemPiecesAtCount: 10),
        StocktakeCount(productId: 'b', countedPieces: 5, systemPiecesAtCount: 5),
        StocktakeCount(productId: 'c', countedPieces: 3, systemPiecesAtCount: 1),
        StocktakeCount(productId: 'a', countedPieces: 9, systemPiecesAtCount: 10),
      ]);
      expect(adj, {'a': -1, 'c': 2});
    });
  });

  group('expenses & P&L', () {
    ExpenseEvent exp(String cat, int amount, {PaidFrom from = PaidFrom.outside}) => ExpenseEvent(
      meta: meta(),
      category: cat,
      amountMinor: amount,
      currencyCode: 'SYP',
      paidFrom: from,
    );

    test('net profit = sales − refunds − cost − expenses', () {
      final pl = profitAndLoss(
        salesMinor: 1000000,
        refundsMinor: 20000,
        goods: const ProfitSummary(revenueMinor: 980000, costMinor: 700000, unknownCostPieces: 0),
        expenses: [exp('rent', 100000), exp('electricity', 30000), exp('rent', 5000)],
      );
      expect(pl.expensesByCategory, {'rent': 105000, 'electricity': 30000});
      expect(pl.grossProfitMinor, 980000 - 700000);
      expect(pl.netProfitMinor, 280000 - 135000);
    });

    test('expense rules', () {
      expect(() => exp('rent', 0), throwsArgumentError);
      expect(() => exp(' ', 5), throwsArgumentError);
    });

    test('till subtracts drawer purchases and expenses, adds supplier cash refunds', () {
      final m = meta();
      final s = summarizeShift(
        [TillEvent(meta: m, type: TillEventType.opened, shiftId: m.id, amountMinor: 10000)],
        const ShiftMovements(
          cashSales: 50000,
          drawerPurchases: 20000,
          drawerExpenses: 3000,
          supplierCashRefunds: 1000,
        ),
      );
      expect(s.expected, 10000 + 50000 - 20000 - 3000 + 1000);
    });
  });
}
