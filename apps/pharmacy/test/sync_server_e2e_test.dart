// End-to-end against the real server: run through tool/sync_e2e.sh, which
// starts it (HTTPS, its own certificate) on an empty database and sets
// DOAYA_SERVER_URL. Goes through the app's HttpSyncApi: pinned TLS.
import 'dart:io';

import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_pharmacy/data/catalog_repository.dart';
import 'package:doaya_pharmacy/data/database.dart';
import 'package:doaya_pharmacy/data/ledger_repository.dart';
import 'package:doaya_pharmacy/data/people_repository.dart';
import 'package:doaya_pharmacy/data/sync_store.dart';
import 'package:doaya_pharmacy/sync/sync_api.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final url = Platform.environment['DOAYA_SERVER_URL'];
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  const syp = Currency.syp;

  test('counter PC creates the pharmacy, an employee phone links, both sell, both agree', () async {
    const api = HttpSyncApi();
    // First contact pins the server's certificate.
    final base = (await api.probe(Uri.parse(url!)))!;
    expect(serverPin(base), hasLength(64));
    expect(await api.needsSetup(base), isTrue);

    // ── Counter PC: existing offline history, then first link (setup).
    final pcDb = AppDatabase(NativeDatabase.memory());
    addTearDown(pcDb.close);
    final people = PeopleRepository(pcDb);
    final (dev, owner) = await people.setUp(
      deviceName: 'لابتوب الكاونتر',
      ownerName: 'سامر',
      ownerPin: '1234',
      pharmacyName: 'صيدلية الشفاء',
    );
    final rana = await people.addEmployee(name: 'رنا', pin: '1111');
    final amox = await CatalogRepository(pcDb).create(
      const ProductDraft(tradeName: 'Amoxil', activeIngredient: 'amoxicillin', priceMinor: 4500),
      deviceId: dev.id,
    );
    await LedgerRepository(pcDb).receive(
      Session(deviceId: dev.id, employeeId: owner.id),
      productId: amox.id,
      quantity: 10,
    );
    final linked = await api.setup(
      base,
      pharmacyName: 'صيدلية الشفاء',
      ownerName: 'سامر',
      ownerPhone: '0944123456',
      password: 'secret-1',
      ownerEmployeeId: owner.id,
      deviceId: dev.id,
      deviceName: dev.name,
    );
    final pcClient = api.remote(base, deviceId: dev.id, deviceToken: linked.deviceToken);
    addTearDown(pcClient.close);
    final pcStore = DriftSyncStore(pcDb, deviceId: dev.id);
    await pcStore.seedOutbox();
    final first = await SyncEngine(pcStore, pcClient).sync();
    expect(first.pushed, greaterThan(5));
    expect(await pcStore.outboxCount(), 0);

    // The owner gives Rana an account for her phone.
    await pcClient.postJson('users', {
      'name': 'رنا',
      'phone': '0933000111',
      'password': 'rana-pass',
      'employee_id': rana.id,
    });

    // ── Rana's phone: fresh app, links with her phone + password.
    final phoneDb = AppDatabase(NativeDatabase.memory());
    addTearDown(phoneDb.close);
    const phoneId = '0190a000-0000-7000-8000-00000000beef';
    await phoneDb
        .into(phoneDb.devices)
        .insert(
          DevicesCompanion.insert(
            id: phoneId,
            name: 'موبايل رنا',
            isThisDevice: const Value(true),
            createdAt: DateTime.now(),
          ),
        );
    final ranaLink = await api.link(
      base,
      phone: '٠٩٣٣ ٠٠٠ ١١١',
      password: 'rana-pass',
      deviceId: phoneId,
      deviceName: 'موبايل رنا',
    );
    expect(ranaLink.employeeId, rana.id);
    final phoneClient = api.remote(base, deviceId: phoneId, deviceToken: ranaLink.deviceToken);
    addTearDown(phoneClient.close);
    final phoneStore = DriftSyncStore(phoneDb, deviceId: phoneId);
    await SyncEngine(phoneStore, phoneClient, pullLimit: 4).sync();
    expect((await LedgerRepository(phoneDb).loadStock()).onHand(amox.id), 10);
    expect(await PeopleRepository(phoneDb).setting('pharmacy_name'), 'صيدلية الشفاء');

    // ── Both sell offline, then sync.
    Future<void> sell(AppDatabase db, String deviceId, String employeeId, int q) =>
        LedgerRepository(db).sell(
          Session(deviceId: deviceId, employeeId: employeeId),
          cart: [CartLine(productId: amox.id, quantity: q, unitPrice: const Money(4500, syp))],
          currency: syp,
          payment: PaymentType.cash,
        );
    await sell(pcDb, dev.id, owner.id, 3);
    await sell(phoneDb, phoneId, rana.id, 2);
    await SyncEngine(pcStore, pcClient).sync();
    await SyncEngine(phoneStore, phoneClient).sync();
    await SyncEngine(pcStore, pcClient).sync();
    for (final db in [pcDb, phoneDb]) {
      expect((await LedgerRepository(db).loadStock()).onHand(amox.id), 5);
      expect(await db.select(db.sales).get(), hasLength(2));
    }

    // ── Another certificate at the same address (an impostor, or the
    // server reinstalled): refused before anything is sent.
    final impostor = api.remote(
      pinServer(base, 'ab' * 32),
      deviceId: dev.id,
      deviceToken: linked.deviceToken,
    );
    addTearDown(impostor.close);
    await expectLater(
      SyncEngine(pcStore, impostor).sync(),
      throwsA(isA<SyncCertificateException>()),
    );
    expect(await api.probe(Uri.parse(url.replaceFirst('https', 'http'))), isNull);

    // ── The owner unlinks the phone: its next sync is refused.
    await pcClient.postJson('devices/$phoneId/unlink');
    await expectLater(
      SyncEngine(phoneStore, phoneClient).sync(),
      throwsA(isA<SyncApiException>().having((e) => e.deviceUnlinked, 'unlinked', isTrue)),
    );
  }, skip: url == null ? 'set DOAYA_SERVER_URL (see tool/sync_e2e.sh)' : null);
}
