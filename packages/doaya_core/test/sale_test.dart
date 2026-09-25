import 'package:doaya_core/doaya_core.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  const syp = Currency.syp;
  late StockEvent soon, late_;
  late StockLedger stock;

  setUp(() {
    soon = receive('amox', 2, expiry: DateTime.utc(2026, 10));
    late_ = receive('amox', 10, expiry: DateTime.utc(2027, 3));
    stock = StockLedger([soon, late_, receive('para', 5)]);
  });

  CompletedSale sell(
    List<CartLine> cart, {
    PaymentType payment = PaymentType.cash,
    String? customer,
    int discount = 0,
  }) => buildSale(
    cart: cart,
    stock: stock,
    currency: syp,
    payment: payment,
    customerId: customer,
    discountMinor: discount,
    deviceId: 'laptop',
    employeeId: 'emp-7',
    now: t0,
    ids: UuidV7(),
  );

  CartLine line(String p, int q, int price) =>
      CartLine(productId: p, quantity: q, unitPrice: Money(price, syp));

  test('cash sale: totals, FEFO sold events, who and which device', () {
    final s = sell([line('amox', 3, 4500), line('para', 1, 1200)]);
    expect(s.subtotalMinor, 3 * 4500 + 1200);
    expect(s.totalMinor, s.subtotalMinor);
    expect(s.debtEvent, isNull);
    final amox = s.stockEvents.where((e) => e.productId == 'amox').toList();
    expect(amox.map((e) => (e.batchId, e.quantity)), [(soon.batchId, -2), (late_.batchId, -1)]);
    for (final e in s.stockEvents) {
      expect(e.type, StockEventType.sold);
      expect(e.saleId, s.id);
      expect(e.meta.deviceId, 'laptop');
      expect(e.meta.employeeId, 'emp-7');
      expect(UuidV7.isValid(e.id), isTrue);
    }
    // Applying the events gives the expected stock.
    s.stockEvents.forEach(stock.apply);
    expect(stock.onHand('amox'), 9);
    expect(stock.onHand('para'), 4);
  });

  test('duplicate cart lines are merged before allocation', () {
    final s = sell([line('amox', 1, 4500), line('amox', 2, 4500)]);
    expect(s.lines.single.quantity, 3);
    expect(s.stockEvents.fold<int>(0, (a, e) => a + e.quantity), -3);
  });

  test('debt sale creates debt_added for the total after discount', () {
    final s = sell(
      [line('amox', 2, 4500)],
      payment: PaymentType.debt,
      customer: 'abu-ahmad',
      discount: 1000,
    );
    expect(s.totalMinor, 8000);
    expect(s.debtEvent!.type, DebtEventType.debtAdded);
    expect(s.debtEvent!.amountMinor, 8000);
    expect(s.debtEvent!.saleId, s.id);
    expect(DebtLedger([s.debtEvent!]).balance('abu-ahmad'), 8000);
  });

  test('rules', () {
    expect(
      () => sell([]),
      throwsA(isA<SaleException>().having((e) => e.code, 'code', SaleError.emptyCart)),
    );
    expect(
      () => sell([line('amox', 1, 100)], payment: PaymentType.debt),
      throwsA(isA<SaleException>().having((e) => e.code, 'code', SaleError.debtNeedsCustomer)),
    );
    expect(
      () => sell([line('amox', 0, 100)]),
      throwsA(isA<SaleException>().having((e) => e.code, 'code', SaleError.badQuantity)),
    );
    expect(
      () => sell([line('amox', 1, 100)], discount: 101),
      throwsA(isA<SaleException>().having((e) => e.code, 'code', SaleError.discountTooLarge)),
    );
    expect(
      () => sell([line('amox', 13, 100)]),
      throwsA(isA<SaleException>().having((e) => e.code, 'code', SaleError.insufficientStock)),
    );
  });

  test('building a sale does not mutate the ledger', () {
    sell([line('amox', 3, 4500)]);
    expect(stock.onHand('amox'), 12);
  });
}
