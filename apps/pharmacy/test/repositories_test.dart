import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_pharmacy/data/catalog_repository.dart';
import 'package:doaya_pharmacy/data/database.dart';
import 'package:doaya_pharmacy/data/ledger_repository.dart';
import 'package:doaya_pharmacy/data/people_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CatalogRepository catalog;
  late LedgerRepository ledger;
  late PeopleRepository people;
  var now = DateTime.utc(2026, 9, 25, 10);
  const counter = Session(deviceId: 'laptop', employeeId: 'emp-1');
  const syp = Currency.syp;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    final ids = UuidV7();
    catalog = CatalogRepository(db, ids: ids, clock: () => now);
    ledger = LedgerRepository(db, ids: ids, clock: () => now);
    people = PeopleRepository(db, ids: ids, clock: () => now);
  });
  tearDown(() => db.close());

  Future<ProductRow> product(String name, String ingredient, {List<String> codes = const []}) =>
      catalog.create(
        ProductDraft(
          tradeName: name,
          activeIngredient: ingredient,
          priceMinor: 4500,
          barcodes: codes,
        ),
        deviceId: 'laptop',
      );

  group('ledger tables are append-only', () {
    test('DELETE is refused', () async {
      final p = await product('Amoxil 500', 'Amoxicillin');
      await ledger.receive(counter, productId: p.id, quantity: 10);
      expect(() => db.delete(db.stockEvents).go(), throwsA(isA<SqliteException>()));
    });

    test('UPDATE of data columns is refused, stamping syncedAt is allowed', () async {
      final p = await product('Amoxil 500', 'Amoxicillin');
      final e = await ledger.receive(counter, productId: p.id, quantity: 10);
      expect(
        () => (db.update(
          db.stockEvents,
        )..where((t) => t.id.equals(e.id))).write(const StockEventsCompanion(quantity: Value(99))),
        throwsA(isA<SqliteException>()),
      );
      await (db.update(
        db.stockEvents,
      )..where((t) => t.id.equals(e.id))).write(StockEventsCompanion(syncedAt: Value(now)));
      expect((await ledger.loadStock()).onHand(p.id), 10);
    });
  });

  group('stock', () {
    test('re-inserting the same events is idempotent', () async {
      final p = await product('Panadol', 'Paracetamol');
      final e = await ledger.receive(counter, productId: p.id, quantity: 7);
      expect(await ledger.insertStockEvents([e, e]), 0);
      expect((await ledger.loadStock()).onHand(p.id), 7);
    });

    test('events round-trip through SQLite with ms precision and expiry', () async {
      final p = await product('Panadol', 'Paracetamol');
      now = DateTime.utc(2026, 9, 25, 10, 0, 0, 123);
      final e = await ledger.receive(
        counter,
        productId: p.id,
        quantity: 3,
        expiry: DateTime.utc(2027, 1, 31),
        unitCostMinor: 3000,
      );
      final back = (await ledger.loadStock()).batch(e.batchId)!;
      expect(back.expiry, DateTime.utc(2027, 1, 31));
      expect(back.receivedAt!.isAtSameMomentAs(now), isTrue);
    });

    test('adjust down takes FEFO; adjust up goes to newest batch', () async {
      final p = await product('Brufen', 'Ibuprofen');
      final soon = await ledger.receive(
        counter,
        productId: p.id,
        quantity: 2,
        expiry: DateTime.utc(2026, 11),
      );
      now = now.add(const Duration(days: 1));
      final late = await ledger.receive(
        counter,
        productId: p.id,
        quantity: 5,
        expiry: DateTime.utc(2027, 5),
      );
      final down = await ledger.adjust(counter, productId: p.id, delta: -3);
      expect(down.map((e) => (e.batchId, e.quantity)), [(soon.batchId, -2), (late.batchId, -1)]);
      final up = await ledger.adjust(counter, productId: p.id, delta: 4);
      expect(up.single.batchId, late.batchId);
      expect((await ledger.loadStock()).onHand(p.id), 8);
    });

    test('remove expired empties the batch', () async {
      final p = await product('Brufen', 'Ibuprofen');
      final b = await ledger.receive(
        counter,
        productId: p.id,
        quantity: 4,
        expiry: DateTime.utc(2026, 9),
      );
      final e = await ledger.removeExpired(counter, batchId: b.batchId);
      expect(e!.type, StockEventType.expiredRemoved);
      expect(e.quantity, -4);
      expect(await ledger.removeExpired(counter, batchId: b.batchId), isNull);
    });
  });

  group('sales', () {
    test('cash sale writes header, lines and FEFO sold events atomically', () async {
      final p = await product('Amoxil 500', 'Amoxicillin');
      await ledger.receive(counter, productId: p.id, quantity: 5);
      final sale = await ledger.sell(
        counter,
        cart: [CartLine(productId: p.id, quantity: 2, unitPrice: Money(p.priceMinor, syp))],
        currency: syp,
        payment: PaymentType.cash,
      );
      final header = await (db.select(db.sales)..where((t) => t.id.equals(sale.id))).getSingle();
      expect(header.totalMinor, 9000);
      expect(header.deviceId, 'laptop');
      expect(header.employeeId, 'emp-1');
      expect(await ledger.linesOf(sale.id), hasLength(1));
      expect((await ledger.loadStock()).onHand(p.id), 3);
    });

    test('a failing sale leaves nothing behind', () async {
      final p = await product('Amoxil 500', 'Amoxicillin');
      await ledger.receive(counter, productId: p.id, quantity: 1);
      await expectLater(
        ledger.sell(
          counter,
          cart: [CartLine(productId: p.id, quantity: 2, unitPrice: const Money(100, syp))],
          currency: syp,
          payment: PaymentType.cash,
        ),
        throwsA(isA<SaleException>()),
      );
      expect(await db.select(db.sales).get(), isEmpty);
      expect((await ledger.loadStock()).onHand(p.id), 1);
    });

    test('debt sale + payment update the customer balance', () async {
      final p = await product('Amoxil 500', 'Amoxicillin');
      await ledger.receive(counter, productId: p.id, quantity: 5);
      final c = await people.addCustomer(name: 'أبو أحمد', phone: '0999');
      await ledger.sell(
        counter,
        cart: [CartLine(productId: p.id, quantity: 2, unitPrice: const Money(4500, syp))],
        currency: syp,
        payment: PaymentType.debt,
        customerId: c.id,
      );
      await ledger.recordPayment(counter, customerId: c.id, amount: const Money(3000, syp));
      final debts = await ledger.loadDebts();
      expect(debts.balance(c.id), 6000);
    });
  });

  group('catalog', () {
    test('search by name, ingredient, Arabic name and barcode', () async {
      final a = await product('Amoxil 500', 'Amoxicillin', codes: ['6221234567890']);
      await product('Panadol', 'Paracetamol');
      expect((await catalog.search('amox')).map((r) => r.id), [a.id]);
      expect((await catalog.search('AMOXICILLIN')).map((r) => r.id), [a.id]);
      expect((await catalog.search('6221234567890')).first.id, a.id);
      expect(await catalog.search('   '), isEmpty);
      expect((await catalog.byBarcode('6221234567890'))!.id, a.id);
    });

    test('alternatives share the normalised active ingredient', () async {
      final a = await product('Amoxil 500', 'Amoxicillin');
      final b = await product('Ospamox 500', '  amoxicillin ');
      await product('Panadol', 'Paracetamol');
      expect((await catalog.alternatives(a)).map((r) => r.id), [b.id]);
    });

    test('a barcode can belong to one product only', () async {
      await product('Amoxil 500', 'Amoxicillin', codes: ['111']);
      expect(() => product('Other', 'x', codes: ['111']), throwsA(isA<DuplicateBarcode>()));
    });
  });

  group('people', () {
    test('first-run setup creates device and owner; PIN verifies', () async {
      final (device, owner) = await people.setUp(
        deviceName: 'لابتوب الكاونتر',
        ownerName: 'د. سامر',
        ownerPin: '1234',
        pharmacyName: 'الشفاء',
      );
      expect(device.isThisDevice, isTrue);
      expect(owner.role, 'owner');
      expect(owner.pinHash, isNot(contains('1234')));
      expect(await people.verifyPin(owner.id, '1234'), isNotNull);
      expect(await people.verifyPin(owner.id, '0000'), isNull);
      expect(await people.setting(SettingKeys.pharmacyName), 'الشفاء');
      expect(
        () => people.setUp(deviceName: 'x', ownerName: 'y', ownerPin: '1111'),
        throwsStateError,
      );
    });

    test('inactive employees cannot log in; PIN must be 4 digits', () async {
      final e = await people.addEmployee(name: 'رنا', pin: '4321');
      await people.setActive(e.id, active: false);
      expect(await people.verifyPin(e.id, '4321'), isNull);
      expect(() => people.addEmployee(name: 'x', pin: '12'), throwsArgumentError);
    });

    test('currency defaults to the new Syrian pound and is editable', () async {
      expect(await people.currency(), Currency.syp);
      await people.setSetting(SettingKeys.currencyCode, 'USD');
      await people.setSetting(SettingKeys.currencySymbol, r'$');
      final c = await people.currency();
      expect((c.code, c.symbol, c.decimals), ('USD', r'$', 2));
    });
  });
}
