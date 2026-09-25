import 'package:doaya_core/doaya_core.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  const syp = Currency.syp;

  TillEvent opened(int float) {
    final m = meta();
    return TillEvent(meta: m, type: TillEventType.opened, shiftId: m.id, amountMinor: float);
  }

  TillEvent ev(TillEventType t, String shift, int amount, {String? note}) =>
      TillEvent(meta: meta(), type: t, shiftId: shift, amountMinor: amount, note: note);

  group('TillEvent rules', () {
    test('opened starts its own shift', () {
      expect(
        () => TillEvent(meta: meta(), type: TillEventType.opened, shiftId: 'x', amountMinor: 0),
        throwsArgumentError,
      );
    });
    test('amounts are non-negative; cash in/out must be > 0', () {
      final o = opened(0);
      expect(() => ev(TillEventType.cashOut, o.shiftId, 0), throwsArgumentError);
      expect(() => ev(TillEventType.closed, o.shiftId, -1), throwsArgumentError);
      expect(ev(TillEventType.closed, o.shiftId, 0).amountMinor, 0);
    });
    test('wire names', () {
      expect(TillEventType.values.map((t) => t.wire), ['opened', 'cash_in', 'cash_out', 'closed']);
      expect(PaymentType.fromWire('transfer'), PaymentType.transfer);
    });
  });

  group('shift reconciliation', () {
    test('expected = float + cash sales + debt payments − refunds + in − out', () {
      final o = opened(20000);
      final events = [
        o,
        ev(TillEventType.cashIn, o.shiftId, 5000),
        ev(TillEventType.cashOut, o.shiftId, 3000, note: 'مصروف'),
      ];
      final s = summarizeShift(
        events,
        const ShiftMovements(
          cashSales: 100000,
          debtPayments: 10000,
          cashRefunds: 4000,
          transferSales: 50000,
        ),
      );
      expect(s.isOpen, isTrue);
      expect(s.expected, 20000 + 100000 + 10000 - 4000 + 5000 - 3000);
      expect(s.difference, isNull);
    });

    test('closing records counted cash and the shortage / surplus', () {
      final o = opened(0);
      const m = ShiftMovements(cashSales: 45000);
      final short = summarizeShift([o, ev(TillEventType.closed, o.shiftId, 44000)], m);
      expect((short.isOpen, short.counted, short.difference), (false, 44000, -1000));
      final exact = summarizeShift([o, ev(TillEventType.closed, o.shiftId, 45000)], m);
      expect(exact.difference, 0);
    });

    test('transfers are not expected in the drawer', () {
      final o = opened(0);
      final s = summarizeShift([o], const ShiftMovements(transferSales: 99999));
      expect(s.expected, 0);
    });
  });

  group('amount received and change', () {
    test('changeDue', () {
      expect(changeDue(totalMinor: 8100, tenderedMinor: 10000), 1900);
      expect(changeDue(totalMinor: 8100), isNull);
      expect(() => changeDue(totalMinor: 8100, tenderedMinor: 8000), throwsArgumentError);
    });

    CompletedSale sell({PaymentType payment = PaymentType.cash, int? tendered, int discount = 0}) =>
        buildSale(
          cart: [const CartLine(productId: 'p', quantity: 2, unitPrice: Money(4500, syp))],
          stock: StockLedger([receive('p', 10)]),
          currency: syp,
          payment: payment,
          customerId: payment == PaymentType.debt ? 'c' : null,
          discountMinor: discount,
          tenderedMinor: tendered,
          deviceId: 'd',
          employeeId: 'e',
          now: t0,
          ids: UuidV7(),
        );

    test('cash sale keeps tendered and computes change after discount', () {
      final s = sell(tendered: 10000, discount: 500);
      expect((s.totalMinor, s.tenderedMinor, s.changeMinor), (8500, 10000, 1500));
    });

    test('tendered below total is refused', () {
      expect(
        () => sell(tendered: 8000),
        throwsA(isA<SaleException>().having((e) => e.code, 'code', SaleError.tenderedTooLow)),
      );
    });

    test('tendered is ignored for debt and transfer sales', () {
      expect(sell(payment: PaymentType.transfer, tendered: 1).tenderedMinor, isNull);
      expect(sell(payment: PaymentType.debt, tendered: 1).tenderedMinor, isNull);
    });
  });
}
