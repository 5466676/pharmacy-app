import 'package:doaya_pharmacy/app.dart';
import 'package:doaya_pharmacy/data/catalog_repository.dart';
import 'package:doaya_pharmacy/data/database.dart';
import 'package:doaya_pharmacy/data/ledger_repository.dart';
import 'package:doaya_pharmacy/data/people_repository.dart';
import 'package:doaya_pharmacy/providers.dart';
import 'package:doaya_ui/doaya_ui.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lets drift's real async work finish between frames.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

/// End-to-end flows through the real app on an in-memory database.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late ProviderContainer container;

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const PharmacyApp()),
    );
    await settle(tester);
  }

  setUp(() => db = AppDatabase(NativeDatabase.memory()));

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  testWidgets('first run: setup creates the owner and lands on the dashboard', (tester) async {
    await pumpApp(tester);
    expect(find.text('أهلين بدوايا'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'الشفاء');
    await tester.enterText(fields.at(1), 'لابتوب الكاونتر');
    await tester.enterText(fields.at(2), 'سامر');
    await tester.enterText(fields.at(3), '1234');
    await tester.enterText(fields.at(4), '1234');
    await tester.tap(find.text('ابدأ'));
    await settle(tester);

    expect(find.text('أهلين سامر'), findsOneWidget);
    expect(find.text('يعمل بدون إنترنت'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('setup validates the PIN', (tester) async {
    await pumpApp(tester);
    final fields = find.byType(TextFormField);
    for (var i = 0; i < 3; i++) {
      await tester.enterText(fields.at(i), 'x');
    }
    await tester.enterText(fields.at(3), '1234');
    await tester.enterText(fields.at(4), '9999');
    await tester.tap(find.text('ابدأ'));
    await settle(tester);
    expect(find.text('الرمزين مو متطابقين'), findsOneWidget);
    await unmount(tester);
  });

  group('with a set-up pharmacy', () {
    late EmployeeRow owner;
    late ProductRow amox;

    Future<void> seed(WidgetTester tester) async {
      await tester.runAsync(() async {
        final people = PeopleRepository(db);
        final (device, o) = await people.setUp(
          deviceName: 'لابتوب',
          ownerName: 'سامر',
          ownerPin: '1234',
        );
        owner = o;
        amox = await CatalogRepository(db).create(
          const ProductDraft(
            tradeName: 'Amoxil 500 mg',
            activeIngredient: 'amoxicillin',
            priceMinor: 4500,
            barcodes: ['6221000000011'],
          ),
          deviceId: device.id,
        );
        await LedgerRepository(db).receive(
          Session(deviceId: device.id, employeeId: o.id),
          productId: amox.id,
          quantity: 5,
          expiry: DateTime.now().add(const Duration(days: 30)),
        );
      });
    }

    testWidgets('login: wrong PIN is refused, right PIN signs in', (tester) async {
      await seed(tester);
      await pumpApp(tester);
      expect(find.text('مين عم يشتغل هلق؟'), findsOneWidget);
      await tester.tap(find.text('سامر'));
      await settle(tester);

      for (final d in ['٠', '٠', '٠', '٠']) {
        await tester.tap(find.text(d).last);
        await tester.pump();
      }
      await settle(tester);
      expect(find.text('الرمز غلط'), findsOneWidget);

      // Physical keyboard works too.
      for (final k in [
        LogicalKeyboardKey.digit1,
        LogicalKeyboardKey.digit2,
        LogicalKeyboardKey.digit3,
        LogicalKeyboardKey.digit4,
      ]) {
        await tester.sendKeyEvent(k);
      }
      await settle(tester);
      expect(container.read(sessionProvider)?.employee.id, owner.id);
      expect(find.text('أهلين سامر'), findsOneWidget);
      await unmount(tester);
    });

    Future<void> signInAndOpenPos(WidgetTester tester) async {
      await seed(tester);
      await pumpApp(tester);
      final device = await tester.runAsync(() => PeopleRepository(db).thisDevice());
      container.read(sessionProvider.notifier).signIn(device!, owner);
      await settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.f2); // F2 → POS
      await settle(tester);
      expect(find.text('بيع جديد'), findsWidgets);
    }

    testWidgets('POS: scan a barcode, Enter on empty field completes a cash sale', (tester) async {
      await signInAndOpenPos(tester);

      // Scanner = keyboard: types the code then Enter.
      await tester.enterText(find.byType(TextField).first, '6221000000011');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await settle(tester);
      expect(find.text('Amoxil 500 mg'), findsOneWidget); // in the invoice
      // Near-expiry nudge shows on the cart line.
      expect(find.textContaining('بيع منها أول'), findsOneWidget);

      // Scan again → quantity 2.
      await tester.enterText(find.byType(TextField).first, '6221000000011');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await settle(tester);
      expect(find.text('٢'), findsOneWidget);

      // Enter on the empty search completes the sale.
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await settle(tester);

      final stock = await tester.runAsync(() => LedgerRepository(db).loadStock());
      expect(stock!.onHand(amox.id), 3);
      final sales = await tester.runAsync(() => db.select(db.sales).get());
      expect(sales!.single.totalMinor, 9000);
      expect(sales.single.employeeId, owner.id);
      expect(find.textContaining('تمّ البيع'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('POS: cannot add more than in stock; unknown barcode is reported', (tester) async {
      await signInAndOpenPos(tester);
      for (var i = 0; i < 6; i++) {
        await tester.enterText(find.byType(TextField).first, '6221000000011');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await settle(tester);
      }
      expect(find.text('٥'), findsOneWidget);
      expect(find.text('الكمية مو متوفرة بالمخزون'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '000');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await settle(tester);
      expect(find.textContaining('ما لقينا صنف'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('POS: F8 switches to debt and asks for a customer', (tester) async {
      await signInAndOpenPos(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.f8);
      await settle(tester);
      expect(find.text('اختار زبون'), findsWidgets);
      expect(find.text('زبون جديد'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('solid theme on desktop: no BackdropFilter anywhere', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      await signInAndOpenPos(tester);
      expect(find.byType(BackdropFilter), findsNothing);
      expect(DoayaTokens.of(tester.element(find.byType(Scaffold).first)).blurAllowed, isFalse);
      debugDefaultTargetPlatformOverride = null;
      await unmount(tester);
    });
  });
}
