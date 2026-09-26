import 'dart:convert';

import 'package:doaya_pharmacy/app.dart';
import 'package:doaya_pharmacy/data/database.dart';
import 'package:doaya_pharmacy/data/look_store.dart';
import 'package:doaya_pharmacy/data/people_repository.dart';
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
  tearDown(() => DoayaAppearance.apply(const DoayaLook()));

  testWidgets('an employee (not the owner) picks the look of this device', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    late DeviceRow dev;
    late EmployeeRow rana;
    await tester.runAsync(() async {
      final people = PeopleRepository(db);
      (dev, _) = await people.setUp(deviceName: 'الكاونتر', ownerName: 'سامر', ownerPin: '1234');
      rana = await people.addEmployee(name: 'رنا', pin: '1111');
    });
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = MemoryLookStore();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        syncIntervalProvider.overrideWithValue(null),
        lookStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const PharmacyApp()),
    );
    await settle(tester);
    container.read(sessionProvider.notifier).signIn(dev, rana);
    await settle(tester);

    // In the menu for everyone; settings (owner only) is not.
    expect(find.text('المظهر'), findsOneWidget);
    expect(find.text('الإعدادات'), findsNothing);
    container.read(routerProvider).go(Routes.look);
    await settle(tester);

    await tester.tap(find.text('مسطّح'));
    await settle(tester);
    await tester.tap(find.text('نهاري'));
    await settle(tester);

    final look = DoayaLook.fromJson(jsonDecode(store.value!) as Map<String, Object?>);
    expect((look.style, look.mode), (DoayaStyle.flat, DoayaMode.light));
    expect(DoayaColors.bgMid, DoayaPalette.of(look).bgMid);
    // The counter PC never blurs: no blur slider here.
    expect(find.text('التغبيش'), findsNothing);
  });
}
