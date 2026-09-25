import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_pharmacy/app.dart';
import 'package:doaya_pharmacy/data/catalog_repository.dart';
import 'package:doaya_pharmacy/data/database.dart';
import 'package:doaya_pharmacy/data/ledger_repository.dart';
import 'package:doaya_pharmacy/data/people_repository.dart';
import 'package:doaya_pharmacy/data/till_repository.dart';
import 'package:doaya_pharmacy/providers.dart';
import 'package:doaya_pharmacy/router.dart';
import 'package:doaya_pharmacy/sync/sync_controller.dart';
import 'package:doaya_ui/doaya_ui.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<(DeviceRow, EmployeeRow, EmployeeRow)> seed(WidgetTester tester) async {
    late DeviceRow dev;
    late EmployeeRow owner, rana;
    await tester.runAsync(() async {
      final people = PeopleRepository(db);
      (dev, owner) = await people.setUp(deviceName: 'موبايل', ownerName: 'سامر', ownerPin: '1234');
      rana = await people.addEmployee(name: 'رنا', pin: '1111');
      final p = await CatalogRepository(db).create(
        const ProductDraft(
          tradeName: 'Amoxil 500 mg',
          activeIngredient: 'amoxicillin',
          priceMinor: 4500,
          barcodes: ['6221000000011'],
        ),
        deviceId: dev.id,
      );
      final s = Session(deviceId: dev.id, employeeId: owner.id);
      await LedgerRepository(db).receive(s, productId: p.id, quantity: 5);
      await TillRepository(db).openShift(s, floatMinor: 0);
    });
    return (dev, owner, rana);
  }

  Future<void> pumpPhone(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 820);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        syncIntervalProvider.overrideWithValue(null),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const PharmacyApp()),
    );
    await settle(tester);
  }

  testWidgets('phone: bottom navigation, and a sale from the one-column POS', (tester) async {
    final (dev, owner, _) = await seed(tester);
    await pumpPhone(tester);
    container.read(sessionProvider.notifier).signIn(dev, owner);
    await settle(tester);
    expect(find.byType(FloatingBottomNav), findsOneWidget);
    expect(find.byType(DesktopShell), findsNothing);

    await tester.tap(find.byIcon(DoayaIcons.pos));
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, '6221000000011');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await settle(tester);
    expect(find.text('Amoxil 500 mg'), findsOneWidget); // now in the invoice
    await tester.ensureVisible(find.text('إتمام البيع'));
    await tester.tap(find.text('إتمام البيع'));
    await settle(tester);
    final sales = await tester.runAsync(() => db.select(db.sales).get());
    expect(sales, hasLength(1));
    expect(tester.takeException(), isNull); // no overflow on a phone
  });

  testWidgets('phone: «المزيد» lists the rest; employees don\'t see owner pages', (tester) async {
    final (dev, _, rana) = await seed(tester);
    await pumpPhone(tester);
    container.read(sessionProvider.notifier).signIn(dev, rana);
    await settle(tester);
    container.read(routerProvider).go(Routes.more);
    await settle(tester);
    expect(find.text('الصندوق'), findsOneWidget);
    expect(find.text('السيرفر والمزامنة'), findsOneWidget);
    expect(find.text('الأرباح'), findsNothing);
    expect(find.text('الإعدادات'), findsNothing);
    for (final route in [Routes.dashboard, Routes.inventory, Routes.debts, Routes.till]) {
      container.read(routerProvider).go(route);
      await settle(tester);
      expect(tester.takeException(), isNull, reason: route);
    }
  });
}
