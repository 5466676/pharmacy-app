import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_pharmacy/app.dart';
import 'package:doaya_pharmacy/data/catalog_repository.dart';
import 'package:doaya_pharmacy/data/database.dart';
import 'package:doaya_pharmacy/data/ledger_repository.dart';
import 'package:doaya_pharmacy/data/people_repository.dart';
import 'package:doaya_pharmacy/data/sync_store.dart';
import 'package:doaya_pharmacy/providers.dart';
import 'package:doaya_pharmacy/router.dart';
import 'package:doaya_pharmacy/sync/sync_api.dart';
import 'package:doaya_pharmacy/sync/sync_controller.dart';
import 'package:doaya_ui/doaya_ui.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_sync_api.dart';

Future<void> settle(WidgetTester tester, [int rounds = 6]) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Finder field(String label) => find.descendant(
  of: find.widgetWithText(GlassTextField, label),
  matching: find.byType(TextField),
);

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late FakeSyncApi api;
  late ProviderContainer container;
  final dbs = <AppDatabase>[];

  setUp(() => api = FakeSyncApi());
  tearDown(() async {
    container.dispose();
    for (final db in dbs) {
      await db.close();
    }
    dbs.clear();
  });

  AppDatabase newDb() {
    final db = AppDatabase(NativeDatabase.memory());
    dbs.add(db);
    return db;
  }

  Future<void> pumpApp(WidgetTester tester, AppDatabase db) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        syncApiProvider.overrideWithValue(api),
        syncIntervalProvider.overrideWithValue(null),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const PharmacyApp()),
    );
    await settle(tester);
  }

  /// The counter PC with some history: owner, an employee, a product in stock.
  Future<(DeviceRow, EmployeeRow, EmployeeRow, ProductRow)> seedPc(
    WidgetTester tester,
    AppDatabase db,
  ) async {
    late DeviceRow dev;
    late EmployeeRow owner, rana;
    late ProductRow amox;
    await tester.runAsync(() async {
      final people = PeopleRepository(db);
      (dev, owner) = await people.setUp(
        deviceName: 'لابتوب الكاونتر',
        ownerName: 'سامر',
        ownerPin: '1234',
        pharmacyName: 'صيدلية الشفاء',
      );
      rana = await people.addEmployee(name: 'رنا', pin: '1111');
      amox = await CatalogRepository(db).create(
        const ProductDraft(
          tradeName: 'Amoxil 500 mg',
          activeIngredient: 'amoxicillin',
          priceMinor: 4500,
        ),
        deviceId: dev.id,
      );
      await LedgerRepository(db).receive(
        Session(deviceId: dev.id, employeeId: owner.id),
        productId: amox.id,
        quantity: 7,
      );
    });
    return (dev, owner, rana, amox);
  }

  testWidgets('owner links the counter PC: creates the pharmacy, uploads, adds an account', (
    tester,
  ) async {
    final db = newDb();
    final (dev, owner, rana, _) = await seedPc(tester, db);
    await pumpApp(tester, db);
    container.read(sessionProvider.notifier).signIn(dev, owner);
    await settle(tester);
    expect(find.text('يعمل بدون إنترنت'), findsOneWidget); // not linked yet

    container.read(routerProvider).go(Routes.sync);
    await settle(tester);
    await tester.enterText(field('عنوان السيرفر'), '192.168.1.10');
    await tester.tap(find.text('اعتمد هالعنوان'));
    await settle(tester);
    expect(find.text('إنشاء الصيدلية على السيرفر'), findsOneWidget);

    await tester.enterText(field('رقم الموبايل'), '0944123456');
    await tester.enterText(field('كلمة السر'), 'secret-1');
    await tester.enterText(field('تأكيد كلمة السر'), 'secret-1');
    await tester.tap(find.text('أنشئ واربط'));
    await settle(tester, 10);

    expect(api.pharmacyName, 'صيدلية الشفاء');
    expect(api.server.latest, greaterThan(5)); // history uploaded
    expect(find.textContaining('متزامن'), findsWidgets);
    expect(find.text('مربوط بـ صيدلية الشفاء'), findsOneWidget);
    expect(find.textContaining('آخر نسخة احتياطية على السيرفر'), findsOneWidget);
    final outbox = await tester.runAsync(() => DriftSyncStore(db, deviceId: dev.id).outboxCount());
    expect(outbox, 0);

    // The owner gives Rana an account for her phone.
    expect(find.text('لابتوب الكاونتر'), findsWidgets); // devices panel
    await tester.tap(find.text('حساب لموظف').last);
    await settle(tester);
    await tester.enterText(field('رقم الموبايل').last, '0933000111');
    await tester.enterText(field('كلمة السر').last, 'rana-pass');
    await tester.enterText(field('تأكيد كلمة السر').last, 'rana-pass');
    await tester.tap(find.text('حفظ'));
    await settle(tester);
    final users = await api
        .remote(Uri(), deviceId: dev.id, deviceToken: 'token-${dev.id}')
        .getJson('users');
    expect((users! as List).map((u) => (u as Map)['employee_id']), contains(rana.id));
  });

  testWidgets('a new phone joins the pharmacy and opens straight into its employee', (
    tester,
  ) async {
    // The PC already created the pharmacy and uploaded (no UI needed here).
    final pc = newDb();
    final (dev, owner, rana, amox) = await seedPc(tester, pc);
    await tester.runAsync(() async {
      final r = await api.setup(
        Uri(),
        pharmacyName: 'صيدلية الشفاء',
        ownerName: 'سامر',
        ownerPhone: '0944123456',
        password: 'secret-1',
        ownerEmployeeId: owner.id,
        deviceId: dev.id,
        deviceName: dev.name,
      );
      final store = DriftSyncStore(pc, deviceId: dev.id);
      await store.seedOutbox();
      await SyncEngine(
        store,
        api.remote(Uri(), deviceId: dev.id, deviceToken: r.deviceToken),
      ).sync();
      api.addAccount('0933000111', 'rana-pass', name: 'رنا', employeeId: rana.id);
    });

    final phone = newDb();
    await pumpApp(tester, phone);
    expect(find.text('أهلين بدوايا'), findsOneWidget); // first-run screen
    await tester.tap(find.text('انضمام لصيدلية موجودة'));
    await settle(tester);
    await tester.enterText(field('اسم هالجهاز'), 'موبايل رنا');
    await tester.enterText(field('عنوان السيرفر'), '192.168.1.10');
    await tester.tap(find.text('اعتمد هالعنوان'));
    await settle(tester);
    await tester.enterText(field('رقم الموبايل'), '٠٩٣٣٠٠٠١١١');
    await tester.enterText(field('كلمة السر'), 'rana-pass');
    await tester.tap(find.text('اربط'));
    await settle(tester, 14);

    expect(container.read(sessionProvider)?.employee.id, rana.id); // no PIN screen
    expect(find.text('أهلين رنا'), findsOneWidget);
    final stock = await tester.runAsync(() => LedgerRepository(phone).loadStock());
    expect(stock!.onHand(amox.id), 7);
    expect(api.deviceNames, containsAll(['لابتوب الكاونتر', 'موبايل رنا']));
  });

  testWidgets('server off: selling goes on and the chip says so; unlinked device is told', (
    tester,
  ) async {
    final db = newDb();
    final (dev, owner, _, _) = await seedPc(tester, db);
    await pumpApp(tester, db);
    container.read(sessionProvider.notifier).signIn(dev, owner);
    await settle(tester);
    container.read(routerProvider).go(Routes.sync);
    await settle(tester);
    await tester.enterText(field('عنوان السيرفر'), '192.168.1.10');
    await tester.tap(find.text('اعتمد هالعنوان'));
    await settle(tester);
    await tester.enterText(field('رقم الموبايل'), '0944123456');
    await tester.enterText(field('كلمة السر'), 'secret-1');
    await tester.enterText(field('تأكيد كلمة السر'), 'secret-1');
    await tester.tap(find.text('أنشئ واربط'));
    await settle(tester, 10);
    expect(find.textContaining('متزامن'), findsWidgets);

    api.offline = true;
    await tester.tap(find.text('زامن هلق'));
    await settle(tester);
    expect(find.text('السيرفر مو موجود'), findsWidgets);
    expect(find.textContaining('البيع شغّال عادي'), findsOneWidget);

    api.offline = false;
    api.unlink(dev.id);
    await tester.tap(find.text('زامن هلق'));
    await settle(tester);
    expect(find.text('الجهاز مفصول'), findsWidgets);
    expect(find.textContaining('فصل هالجهاز عن السيرفر'), findsOneWidget);
  });

  testWidgets('another certificate at the server address: sync stops, relink starts over', (
    tester,
  ) async {
    final db = newDb();
    final (dev, owner, _, _) = await seedPc(tester, db);
    await pumpApp(tester, db);
    container.read(sessionProvider.notifier).signIn(dev, owner);
    await settle(tester);
    container.read(routerProvider).go(Routes.sync);
    await settle(tester);
    await tester.enterText(field('عنوان السيرفر'), '192.168.1.10');
    await tester.tap(find.text('اعتمد هالعنوان'));
    await settle(tester);
    // First contact pins the certificate; its code is shown to compare.
    expect(find.textContaining('C0FF-EEC0'), findsOneWidget);
    await tester.enterText(field('رقم الموبايل'), '0944123456');
    await tester.enterText(field('كلمة السر'), 'secret-1');
    await tester.enterText(field('تأكيد كلمة السر'), 'secret-1');
    await tester.tap(find.text('أنشئ واربط'));
    await settle(tester, 10);
    expect(find.textContaining('متزامن'), findsWidgets);
    expect(
      container.read(syncProvider).link!.url.toString(),
      endsWith('#sha256=${api.certificate}'),
    );

    api.certificate = 'ab' * 32;
    await tester.tap(find.text('زامن هلق'));
    await settle(tester);
    expect(find.text('السيرفر تغيّر'), findsWidgets);
    expect(find.textContaining('مو نفس السيرفر'), findsOneWidget);

    await tester.tap(find.text('اربط من جديد'));
    await settle(tester);
    await tester.tap(find.text('تأكيد'));
    await settle(tester);
    expect(container.read(syncProvider).linked, isFalse);
    expect(find.text('اعتمد هالعنوان'), findsOneWidget);
  });
}
