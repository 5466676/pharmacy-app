import 'dart:io';

import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_pharmacy/data/database.dart';
import 'package:doaya_pharmacy/data/ledger_repository.dart';
import 'package:doaya_pharmacy/data/till_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v2 database upgrades to v3: tendered column + append-only till_events', () async {
    final v2 = File('test/fixtures/schema_v2.sql').readAsStringSync();
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute(v2);
          raw.execute(
            "INSERT INTO sales (id, payment, currency_code, subtotal_minor, discount_minor, "
            "total_minor, device_id, employee_id, occurred_at) VALUES "
            "('s1', 'cash', 'SYP', 100, 0, 100, 'd', 'e', '2026-09-01T00:00:00.000Z')",
          );
          raw.execute('PRAGMA user_version = 2');
        },
      ),
    );
    addTearDown(db.close);
    final sale = await db.select(db.sales).getSingle();
    expect(sale.tenderedMinor, isNull);
    // The re-created guard freezes old and new columns alike.
    expect(
      () => db.customStatement("UPDATE sales SET tendered_minor = 5 WHERE id = 's1'"),
      throwsA(isA<SqliteException>()),
    );
    final shift = await TillRepository(db)
        .openShift(const Session(deviceId: 'd', employeeId: 'e'), floatMinor: 0);
    expect(() => db.delete(db.tillEvents).go(), throwsA(isA<SqliteException>()));
    expect(shift, isNotEmpty);
  });

  group('till on SQLite', () {
    late AppDatabase db;
    late TillRepository till;
    late LedgerRepository ledger;
    const me = Session(deviceId: 'laptop', employeeId: 'rana');
    const other = Session(deviceId: 'laptop', employeeId: 'samer');

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      till = TillRepository(db);
      ledger = LedgerRepository(db);
    });
    tearDown(() => db.close());

    test('one open shift per employee per device', () async {
      final id = await till.openShift(me, floatMinor: 1000);
      expect(await till.openShiftId(me), id);
      expect(() => till.openShift(me, floatMinor: 0), throwsA(isA<ShiftAlreadyOpen>()));
      expect(await till.openShiftId(other), isNull);
      await till.closeShift(me, id, countedMinor: 1000);
      expect(await till.openShiftId(me), isNull);
    });

    test('expected counts only this employee\'s cash on this device during the shift', () async {
      final p = await (db
          .into(db.products)
          .insertReturning(
            ProductsCompanion.insert(
              id: 'p',
              tradeName: 'X',
              activeIngredient: 'x',
              priceMinor: 1000,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              updatedByDevice: 'laptop',
            ),
          ));
      await ledger.receive(me, productId: p.id, quantity: 20);
      final shift = await till.openShift(me, floatMinor: 5000);
      CartLine line(int q) =>
          CartLine(productId: p.id, quantity: q, unitPrice: const Money(1000, Currency.syp));
      await ledger.sell(
        me,
        cart: [line(2)],
        currency: Currency.syp,
        payment: PaymentType.cash,
        tenderedMinor: 5000,
      );
      await ledger.sell(me, cart: [line(1)], currency: Currency.syp, payment: PaymentType.transfer);
      await ledger.sell(other, cart: [line(4)], currency: Currency.syp, payment: PaymentType.cash);
      await till.cashOut(me, shift, 500, note: 'مصروف');

      final s = await till.closeShift(me, shift, countedMinor: 6400);
      expect(s.movements.cashSales, 2000);
      expect(s.movements.transferSales, 1000);
      expect(s.expected, 5000 + 2000 - 500);
      expect(s.difference, -100);
      expect((await till.shiftsBetween(DateTime(2000), DateTime(2100))).single.shiftId, shift);
    });
  });
}
