import 'package:doaya_core/doaya_core.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('StockEvent validation', () {
    test('received must open its own batch with positive qty', () {
      final m = meta();
      expect(
        () => StockEvent(
          meta: m,
          type: StockEventType.received,
          productId: 'p',
          batchId: 'other',
          quantity: 5,
        ),
        throwsArgumentError,
      );
      expect(
        () => StockEvent(
          meta: m,
          type: StockEventType.received,
          productId: 'p',
          batchId: m.id,
          quantity: 0,
        ),
        throwsArgumentError,
      );
    });

    test('signs are enforced per type', () {
      expect(() => move(StockEventType.sold, 'p', 'b', 2), throwsArgumentError);
      expect(() => move(StockEventType.expiredRemoved, 'p', 'b', 1), throwsArgumentError);
      expect(() => move(StockEventType.returned, 'p', 'b', -1), throwsArgumentError);
      expect(() => move(StockEventType.adjusted, 'p', 'b', 0), throwsArgumentError);
      expect(move(StockEventType.adjusted, 'p', 'b', -3).quantity, -3);
    });

    test('expiry only on received', () {
      expect(
        () => StockEvent(
          meta: meta(),
          type: StockEventType.sold,
          productId: 'p',
          batchId: 'b',
          quantity: -1,
          expiry: t0,
        ),
        throwsArgumentError,
      );
    });

    test('wire names match the spec', () {
      expect(StockEventType.values.map((t) => t.wire), [
        'received',
        'sold',
        'returned',
        'adjusted',
        'expired_removed',
        'returned_to_supplier',
      ]);
      expect(StockEventType.fromWire('expired_removed'), StockEventType.expiredRemoved);
      expect(DebtEventType.fromWire('payment_received'), DebtEventType.paymentReceived);
    });
  });

  group('StockLedger', () {
    test('stock = sum of all event types', () {
      final r = receive('amox', 20);
      final l = StockLedger([
        r,
        move(StockEventType.sold, 'amox', r.batchId, -3),
        move(StockEventType.returned, 'amox', r.batchId, 1),
        move(StockEventType.adjusted, 'amox', r.batchId, -2),
        move(StockEventType.expiredRemoved, 'amox', r.batchId, -4),
      ]);
      expect(l.onHand('amox'), 12);
      expect(l.onHand('unknown'), 0);
    });

    test('re-applying the same event is a no-op (idempotent sync)', () {
      final r = receive('amox', 10);
      final s = move(StockEventType.sold, 'amox', r.batchId, -2);
      final l = StockLedger([r, s]);
      expect(l.apply(s), isFalse);
      expect(l.apply(r), isFalse);
      expect(l.onHand('amox'), 8);
      expect(l.eventCount, 2);
    });

    test('order-independent merge from two devices', () {
      final r1 = receive('para', 10, dev: 'laptop');
      final r2 = receive('para', 5, dev: 'phone');
      final events = [
        r1,
        r2,
        move(StockEventType.sold, 'para', r1.batchId, -4, dev: 'laptop'),
        move(StockEventType.sold, 'para', r2.batchId, -1, dev: 'phone'),
      ];
      final forward = StockLedger(events);
      final backward = StockLedger(events.reversed);
      final doubled = StockLedger([...events, ...events]);
      expect(forward.onHand('para'), 10);
      expect(backward.onHand('para'), 10);
      expect(doubled.onHand('para'), 10);
      // A sale arriving before its batch's `received` still keeps batch metadata.
      expect(backward.batchesOf('para').every((b) => b.receivedAt != null), isTrue);
    });

    test('FEFO: earliest expiry first, no-expiry last', () {
      final noExp = receive('ibu', 5, at: t0);
      final late = receive(
        'ibu',
        5,
        expiry: DateTime.utc(2027, 6),
        at: t0.add(const Duration(days: 1)),
      );
      final soon = receive(
        'ibu',
        5,
        expiry: DateTime.utc(2026, 11),
        at: t0.add(const Duration(days: 2)),
      );
      final l = StockLedger([noExp, late, soon]);
      expect(l.fefo('ibu').map((b) => b.batchId), [soon.batchId, late.batchId, noExp.batchId]);
    });

    test('FEFO ties break by receive time', () {
      final exp = DateTime.utc(2027);
      final a = receive('x', 1, expiry: exp, at: t0.add(const Duration(hours: 2)));
      final b = receive('x', 1, expiry: exp, at: t0);
      expect(StockLedger([a, b]).fefo('x').first.batchId, b.batchId);
    });

    test('allocate splits across batches FEFO and skips empty ones', () {
      final soon = receive('amox', 3, expiry: DateTime.utc(2026, 10));
      final empty = receive('amox', 2, expiry: DateTime.utc(2026, 9, 15));
      final late = receive('amox', 10, expiry: DateTime.utc(2027, 1));
      final l = StockLedger([
        soon,
        empty,
        late,
        move(StockEventType.sold, 'amox', empty.batchId, -2),
      ]);
      expect(l.allocate('amox', 5), [Allocation(soon.batchId, 3), Allocation(late.batchId, 2)]);
      expect(l.allocate('amox', 1), [Allocation(soon.batchId, 1)]);
    });

    test('allocate throws when stock is short', () {
      final l = StockLedger([receive('amox', 2)]);
      expect(
        () => l.allocate('amox', 3),
        throwsA(isA<InsufficientStock>().having((e) => e.available, 'available', 2)),
      );
      expect(() => l.allocate('none', 1), throwsA(isA<InsufficientStock>()));
    });

    test('near-expiry and expired queries', () {
      final now = DateTime.utc(2026, 9, 25);
      final past = receive('a', 2, expiry: DateTime.utc(2026, 9, 1));
      final soon = receive('a', 4, expiry: DateTime.utc(2026, 11, 1));
      final far = receive('a', 6, expiry: DateTime.utc(2027, 9, 1));
      final soldOut = receive('b', 1, expiry: DateTime.utc(2026, 10, 1));
      final l = StockLedger([
        past,
        soon,
        far,
        soldOut,
        move(StockEventType.sold, 'b', soldOut.batchId, -1),
      ]);
      final near = l.nearExpiry(now, const Duration(days: 90));
      expect(near.map((b) => b.batchId), [past.batchId, soon.batchId]);
      expect(l.expired(now).map((b) => b.batchId), [past.batchId]);
      expect(l.nearExpiry(now, const Duration(days: 90), productId: 'b'), isEmpty);
    });

    test('low stock uses per-product thresholds', () {
      final l = StockLedger([receive('a', 2), receive('b', 50)]);
      expect(l.lowStock({'a': 5, 'b': 5, 'c': 0}), {'a': 2, 'c': 0});
    });
  });

  group('DebtLedger', () {
    DebtEvent debt(String c, DebtEventType t, int amount) =>
        DebtEvent(meta: meta(), type: t, customerId: c, amountMinor: amount, currencyCode: 'SYP');

    test('balance = debts - payments, idempotent', () {
      final d1 = debt('abu-ahmad', DebtEventType.debtAdded, 50000);
      final p1 = debt('abu-ahmad', DebtEventType.paymentReceived, 20000);
      final l = DebtLedger([d1, p1, d1]);
      expect(l.balance('abu-ahmad'), 30000);
      expect(l.apply(p1), isFalse);
      expect(l.balance('nobody'), 0);
    });

    test('open debts sorted, credits excluded', () {
      final l = DebtLedger([
        debt('a', DebtEventType.debtAdded, 100),
        debt('b', DebtEventType.debtAdded, 500),
        debt('c', DebtEventType.paymentReceived, 50),
      ]);
      expect(l.openDebts().map((e) => e.key), ['b', 'a']);
      expect(l.totalOpen, 600);
      expect(l.balance('c'), -50);
    });

    test('amount must be positive', () {
      expect(() => debt('a', DebtEventType.debtAdded, 0), throwsArgumentError);
    });
  });
}
