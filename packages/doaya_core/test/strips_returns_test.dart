import 'package:doaya_core/doaya_core.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  const syp = Currency.syp;
  // Panadol: 1 box = 3 strips. Stock is counted in strips.
  late StockEvent soon, late_;
  late StockLedger stock;

  setUp(() {
    soon = receive('pan', 2 * 3, expiry: DateTime.utc(2026, 10)); // 2 boxes
    late_ = receive('pan', 10 * 3, expiry: DateTime.utc(2027, 5)); // 10 boxes
    stock = StockLedger([soon, late_]);
  });

  CompletedSale sell(
    List<CartLine> cart, {
    PaymentType payment = PaymentType.cash,
    String? customer,
  }) => buildSale(
    cart: cart,
    stock: stock,
    currency: syp,
    payment: payment,
    customerId: customer,
    deviceId: 'd',
    employeeId: 'e',
    now: t0,
    ids: UuidV7(),
  );

  CartLine box(int q) =>
      CartLine(productId: 'pan', quantity: q, unitPrice: const Money(1800, syp), piecesPerUnit: 3);
  CartLine strip(int q) =>
      CartLine(productId: 'pan', quantity: q, unitPrice: const Money(650, syp));

  group('strips', () {
    test('box + strips of one product share one FEFO allocation', () {
      final s = sell([box(2), strip(1)]); // 7 strips
      expect(s.subtotalMinor, 2 * 1800 + 650);
      expect(s.lines.map((l) => (l.quantity, l.piecesPerUnit)), [(2, 3), (1, 1)]);
      expect(s.stockEvents.map((e) => (e.batchId, e.quantity)), [
        (soon.batchId, -6),
        (late_.batchId, -1),
      ]);
    });

    test('stock limit is in pieces', () {
      expect(() => sell([box(12), strip(1)]), throwsA(isA<SaleException>()));
      expect(sell([box(12)]).stockEvents.fold<int>(0, (a, e) => a + e.quantity), -36);
    });

    test('splitPieces shows boxes + loose strips', () {
      expect(splitPieces(7, 3), (2, 1));
      expect(splitPieces(6, 3), (2, 0));
      expect(splitPieces(5, 1), (5, 0));
    });
  });

  group('returns', () {
    CompletedReturn ret(
      List<ReturnItem> items, {
      String? saleId,
      RefundMethod refund = RefundMethod.cash,
      String? customer,
      Map<String, int> returnable = const {},
      Map<String, Map<String, int>> soldFrom = const {},
      int balance = 0,
    }) => buildReturn(
      items: items,
      stock: stock,
      currency: syp,
      refund: refund,
      saleId: saleId,
      customerId: customer,
      returnablePieces: returnable,
      soldFromBatches: soldFrom,
      customerBalanceMinor: balance,
      deviceId: 'd',
      employeeId: 'e',
      now: t0,
      ids: UuidV7(),
    );

    test('from a sale: goes back into the batches it was sold from', () {
      final sale = sell([box(2), strip(1)]);
      sale.stockEvents.forEach(stock.apply);
      final boxLine = sale.lines.first;
      final r = ret(
        [
          ReturnItem(
            productId: 'pan',
            quantity: 1,
            unitPrice: const Money(1800, syp),
            piecesPerUnit: 3,
            saleLineId: boxLine.id,
          ),
        ],
        saleId: sale.id,
        returnable: {boxLine.id: boxLine.pieces},
        soldFrom: {
          'pan': {soon.batchId: 6, late_.batchId: 1},
        },
      );
      expect(r.totalMinor, 1800);
      expect(r.stockEvents.single.type, StockEventType.returned);
      expect((r.stockEvents.single.batchId, r.stockEvents.single.quantity), (soon.batchId, 3));
      expect(r.stockEvents.single.saleId, sale.id);
      expect(r.debtEvent, isNull);
      r.stockEvents.forEach(stock.apply);
      expect(stock.onHand('pan'), 36 - 7 + 3);
    });

    test('from a sale: cannot return more than was sold (minus earlier returns)', () {
      expect(
        () => ret(
          [
            const ReturnItem(
              productId: 'pan',
              quantity: 2,
              unitPrice: Money(1800, syp),
              piecesPerUnit: 3,
              saleLineId: 'L1',
            ),
          ],
          saleId: 's1',
          returnable: {'L1': 3},
          soldFrom: {
            'pan': {'b': 6},
          },
        ),
        throwsA(isA<ReturnException>().having((e) => e.code, 'code', ReturnError.moreThanSold)),
      );
    });

    test('free-form: goes into the latest-expiring batch', () {
      final r = ret([const ReturnItem(productId: 'pan', quantity: 4, unitPrice: Money(650, syp))]);
      expect((r.stockEvents.single.batchId, r.stockEvents.single.quantity), (late_.batchId, 4));
      expect(r.saleId, isNull);
    });

    test('free-form for a product never received is refused', () {
      expect(
        () => ret([const ReturnItem(productId: 'ghost', quantity: 1, unitPrice: Money(1, syp))]),
        throwsA(isA<ReturnException>().having((e) => e.code, 'code', ReturnError.unknownProduct)),
      );
    });

    test('debt credit needs a customer and cannot exceed the debt', () {
      const item = ReturnItem(
        productId: 'pan',
        quantity: 1,
        unitPrice: Money(1800, syp),
        piecesPerUnit: 3,
      );
      expect(
        () => ret([item], refund: RefundMethod.debtCredit),
        throwsA(
          isA<ReturnException>().having((e) => e.code, 'code', ReturnError.creditNeedsCustomer),
        ),
      );
      expect(
        () => ret([item], refund: RefundMethod.debtCredit, customer: 'c', balance: 1000),
        throwsA(
          isA<ReturnException>().having((e) => e.code, 'code', ReturnError.creditMoreThanDebt),
        ),
      );
      final r = ret([item], refund: RefundMethod.debtCredit, customer: 'c', balance: 5000);
      expect(r.debtEvent!.type, DebtEventType.debtCredited);
      expect(
        DebtLedger([
          DebtEvent(
            meta: meta(),
            type: DebtEventType.debtAdded,
            customerId: 'c',
            amountMinor: 5000,
            currencyCode: 'SYP',
          ),
          r.debtEvent!,
        ]).balance('c'),
        3200,
      );
    });
  });
}
