import 'dart:io';

import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_core/sync_testing.dart';
import 'package:doaya_pharmacy/data/catalog_repository.dart';
import 'package:doaya_pharmacy/data/database.dart';
import 'package:doaya_pharmacy/data/ledger_repository.dart';
import 'package:doaya_pharmacy/data/people_repository.dart';
import 'package:doaya_pharmacy/data/sync_store.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// One device: its own database, its sync store, and handy repositories.
class Device {
  Device(this.id) : db = AppDatabase(NativeDatabase.memory());

  final String id;
  final AppDatabase db;
  late final store = DriftSyncStore(db, deviceId: id);
  late final ledger = LedgerRepository(db);
  late final catalog = CatalogRepository(db);
  late final people = PeopleRepository(db);

  SyncEngine engine(InMemorySyncServer server, {int limit = 500}) =>
      SyncEngine(store, server.transportFor(id), pullLimit: limit);

  /// A phone joining an existing pharmacy: only its own device row.
  Future<void> registerOnly(String name) => db
      .into(db.devices)
      .insert(
        DevicesCompanion.insert(
          id: id,
          name: name,
          isThisDevice: const Value(true),
          createdAt: DateTime.now(),
        ),
      );
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  const syp = Currency.syp;
  late InMemorySyncServer server;
  final open = <AppDatabase>[];

  setUp(() => server = InMemorySyncServer());
  tearDown(() async {
    for (final db in open) {
      await db.close();
    }
    open.clear();
  });

  Device device(String id) {
    final d = Device(id);
    open.add(d.db);
    return d;
  }

  Future<int> outbox(Device d) => d.store.outboxCount();

  test('v5 database upgrades to v6: outbox and state tables, triggers catch writes', () async {
    final v5 = File('test/fixtures/schema_v5.sql').readAsStringSync();
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute(v5);
          raw.execute('PRAGMA user_version = 5');
        },
      ),
    );
    open.add(db);
    final store = DriftSyncStore(db, deviceId: 'pc');
    expect(await store.outboxCount(), 0);
    await PeopleRepository(db).addCustomer(name: 'أبو أحمد');
    final pending = await store.pending(10);
    expect(pending.single.change.table, 'customers');
    expect(pending.single.change.data!['name'], 'أبو أحمد');
  });

  test('every write is queued: sales, edits and deletions', () async {
    final pc = device('pc');
    final (dev, owner) = await pc.people.setUp(deviceName: 'PC', ownerName: 'سامر', ownerPin: '1234');
    final amox = await pc.catalog.create(
      const ProductDraft(
        tradeName: 'Amoxil',
        activeIngredient: 'amoxicillin',
        priceMinor: 4500,
        barcodes: ['111'],
      ),
      deviceId: dev.id,
    );
    await pc.ledger.receive(
      Session(deviceId: dev.id, employeeId: owner.id),
      productId: amox.id,
      quantity: 5,
    );
    await pc.ledger.sell(
      Session(deviceId: dev.id, employeeId: owner.id),
      cart: [CartLine(productId: amox.id, quantity: 1, unitPrice: const Money(4500, syp))],
      currency: syp,
      payment: PaymentType.cash,
    );
    // Editing the product replaces its barcodes (delete + insert).
    await pc.catalog.update(
      amox.id,
      const ProductDraft(
        tradeName: 'Amoxil',
        activeIngredient: 'amoxicillin',
        priceMinor: 5000,
        barcodes: ['222'],
      ),
      deviceId: dev.id,
    );
    final changes = {for (final p in await pc.store.pending(100)) p.change.key: p.change};
    expect(changes.keys, containsAll(['products:${amox.id}', 'product_barcodes:111']));
    expect(changes['product_barcodes:111']!.deleted, isTrue);
    expect(changes['product_barcodes:222']!.deleted, isFalse);
    expect(changes['products:${amox.id}']!.data!['price_minor'], 5000);
    expect(changes.keys.where((k) => k.startsWith('sales:')), hasLength(1));
    expect(changes.keys.where((k) => k.startsWith('sale_lines:')), hasLength(1));
    expect(changes.keys.where((k) => k.startsWith('stock_events:')), hasLength(2));
    // Local-only columns never leave the device.
    final deviceRow = changes['devices:${dev.id}']!.data!;
    expect(deviceRow.containsKey('is_this_device'), isFalse);
    expect(changes.values.any((c) => c.data?.containsKey('synced_at') ?? false), isFalse);
  });

  test('the counter PC uploads its history; a new phone gets the same pharmacy', () async {
    final pc = device('pc'), phone = device('phone');
    final (dev, owner) = await pc.people.setUp(deviceName: 'PC', ownerName: 'سامر', ownerPin: '1234');
    final s = Session(deviceId: dev.id, employeeId: owner.id);
    final amox = await pc.catalog.create(
      const ProductDraft(tradeName: 'Amoxil', activeIngredient: 'amoxicillin', priceMinor: 4500),
      deviceId: dev.id,
    );
    await pc.ledger.receive(s, productId: amox.id, quantity: 10);
    final c = await pc.people.addCustomer(name: 'أبو أحمد');
    await pc.ledger.sell(
      s,
      cart: [CartLine(productId: amox.id, quantity: 2, unitPrice: const Money(4500, syp))],
      currency: syp,
      payment: PaymentType.debt,
      customerId: c.id,
    );

    await pc.store.seedOutbox();
    await pc.engine(server).sync();
    expect(await outbox(pc), 0);

    await phone.registerOnly('موبايل رنا');
    await phone.engine(server, limit: 3).sync(); // small pages on purpose
    expect(await outbox(phone), 0, reason: 'pulled rows must not be queued back');
    expect((await phone.ledger.loadStock()).onHand(amox.id), 8);
    expect((await phone.ledger.loadDebts()).balance(c.id), 9000);
    expect((await phone.people.watchEmployees().first).single.name, 'سامر');
    expect((await phone.people.thisDevice())!.id, 'phone');
    final devices = await phone.db.select(phone.db.devices).get();
    expect(devices.where((d) => d.isThisDevice).map((d) => d.id), ['phone']);
  });

  test('both devices sell offline, sync, and end up identical', () async {
    final pc = device('pc'), phone = device('phone');
    final (dev, owner) = await pc.people.setUp(deviceName: 'PC', ownerName: 'سامر', ownerPin: '1234');
    final amox = await pc.catalog.create(
      const ProductDraft(tradeName: 'Amoxil', activeIngredient: 'amoxicillin', priceMinor: 4500),
      deviceId: dev.id,
    );
    await pc.ledger.receive(Session(deviceId: dev.id, employeeId: owner.id), productId: amox.id, quantity: 3);
    await pc.store.seedOutbox();
    await pc.engine(server).sync();
    await phone.registerOnly('موبايل');
    await phone.engine(server).sync();

    // Offline: the PC sells 2, the phone sells 1.
    Future<void> sell(Device d, String deviceId, int q) => d.ledger.sell(
      Session(deviceId: deviceId, employeeId: owner.id),
      cart: [CartLine(productId: amox.id, quantity: q, unitPrice: const Money(4500, syp))],
      currency: syp,
      payment: PaymentType.cash,
    );
    await sell(pc, dev.id, 2);
    await sell(phone, 'phone', 1);

    await pc.engine(server).sync();
    await phone.engine(server).sync();
    await pc.engine(server).sync();

    for (final d in [pc, phone]) {
      expect((await d.ledger.loadStock()).onHand(amox.id), 0);
      expect(await d.db.select(d.db.sales).get(), hasLength(2));
      expect(await outbox(d), 0);
    }
  });

  test('a child that arrives before its edited parent is still applied', () async {
    final pc = device('pc'), phone = device('phone');
    final (dev, _) = await pc.people.setUp(deviceName: 'PC', ownerName: 'سامر', ownerPin: '1234');
    final p = await pc.catalog.create(
      const ProductDraft(
        tradeName: 'Amoxil',
        activeIngredient: 'amoxicillin',
        priceMinor: 4500,
        barcodes: ['111'],
      ),
      deviceId: dev.id,
    );
    await pc.store.seedOutbox();
    await pc.engine(server).sync();
    // Editing only the price later gives the product a newer sequence number
    // than its barcode, so a new device receives the barcode first.
    await (pc.db.update(pc.db.products)..where((t) => t.id.equals(p.id))).write(
      ProductsCompanion(priceMinor: const Value(5000), updatedAt: Value(DateTime.now())),
    );
    await pc.engine(server).sync();

    await phone.registerOnly('موبايل');
    await phone.engine(server, limit: 1).sync();
    expect((await phone.catalog.byBarcode('111'))!.priceMinor, 5000);
  });
}
