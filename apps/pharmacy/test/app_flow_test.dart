import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_pharmacy/app.dart';
import 'package:doaya_pharmacy/data/accounting_repository.dart';
import 'package:doaya_pharmacy/data/catalog_repository.dart';
import 'package:doaya_pharmacy/data/database.dart';
import 'package:doaya_pharmacy/data/ledger_repository.dart';
import 'package:doaya_pharmacy/data/people_repository.dart';
import 'package:doaya_pharmacy/data/till_repository.dart';
import 'package:doaya_pharmacy/providers.dart';
import 'package:doaya_pharmacy/router.dart';
import 'package:doaya_pharmacy/ui/whatsapp.dart';
import 'package:doaya_ui/doaya_ui.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
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

  Future<void> pumpApp(WidgetTester tester, {List<Override> overrides = const []}) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db), ...overrides],
    );
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

    Future<void> seed(WidgetTester tester, {bool openTill = true}) async {
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
        if (openTill) {
          await TillRepository(db)
              .openShift(Session(deviceId: device.id, employeeId: o.id), floatMinor: 10000);
        }
      });
    }

    testWidgets('login: wrong PIN is refused, right PIN signs in', (tester) async {
      await seed(tester);
      await pumpApp(tester);
      expect(find.text('مين عم يشتغل هلق؟'), findsOneWidget);
      await tester.tap(find.text('سامر'));
      await settle(tester);

      for (final d in ['0', '0', '0', '0']) {
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
      expect(find.text('2'), findsOneWidget);

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
      expect(find.text('5'), findsOneWidget);
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

    testWidgets('owner sees employee accounts; employees do not see admin pages', (tester) async {
      await seed(tester);
      late EmployeeRow rana;
      late DeviceRow device;
      // All writes happen before the app is pumped (see settle()).
      await tester.runAsync(() async {
        final people = PeopleRepository(db);
        rana = await people.addEmployee(name: 'رنا', pin: '1111');
        device = (await people.thisDevice())!;
        await LedgerRepository(db).sell(
          Session(deviceId: device.id, employeeId: rana.id),
          cart: [
            CartLine(productId: amox.id, quantity: 1, unitPrice: const Money(4500, Currency.syp)),
          ],
          currency: Currency.syp,
          payment: PaymentType.cash,
        );
      });
      await pumpApp(tester);

      // As Rana: no admin section.
      container.read(sessionProvider.notifier).signIn(device, rana);
      await settle(tester);
      expect(find.text('حسابات الموظفين'), findsNothing);
      expect(find.text('الإعدادات'), findsNothing);

      // As owner: the staff page lists Rana and her sale.
      container.read(sessionProvider.notifier).signIn(device, owner);
      await settle(tester);
      await tester.tap(find.text('حسابات الموظفين'));
      await settle(tester);
      expect(find.text('رنا'), findsWidgets);
      expect(find.text('المفروض يسلّم نقدي'), findsOneWidget);
      expect(find.text('45 ل.س'), findsWidgets);
      await unmount(tester);
    });

    testWidgets('POS: sells strips of a split box; stock counted in strips', (tester) async {
      late ProductRow pan;
      await seed(tester);
      await tester.runAsync(() async {
        final device = (await PeopleRepository(db).thisDevice())!;
        pan = await CatalogRepository(db).create(
          const ProductDraft(
            tradeName: 'Panadol 500 mg',
            activeIngredient: 'paracetamol',
            priceMinor: 1800,
            unitsPerPack: 3,
            stripPriceMinor: 650,
          ),
          deviceId: device.id,
        );
        await LedgerRepository(db).receive(
          Session(deviceId: device.id, employeeId: owner.id),
          productId: pan.id,
          quantity: 2 * 3,
        );
      });
      await pumpApp(tester);
      final device = await tester.runAsync(() => PeopleRepository(db).thisDevice());
      container.read(sessionProvider.notifier).signIn(device!, owner);
      await settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await settle(tester);

      await tester.enterText(find.byType(TextField).first, 'panadol');
      await tester.pump(const Duration(milliseconds: 300));
      await settle(tester);
      // 6 strips = 2 boxes, under the default threshold of 5 boxes.
      expect(find.text('باقي 2 علبة'), findsOneWidget);
      await tester.tap(find.text('ظرف'));
      await settle(tester);
      expect(find.text('6.50 ل.س للظرف'), findsOneWidget);

      await tester.testTextInput.receiveAction(TextInputAction.search); // Enter = complete
      await settle(tester);
      final stock = await tester.runAsync(() => LedgerRepository(db).loadStock());
      expect(stock!.onHand(pan.id), 5);
      await unmount(tester);
    });

    testWidgets('returns screen: from an invoice, back into stock with cash refund', (
      tester,
    ) async {
      await seed(tester);
      await tester.runAsync(() async {
        final device = (await PeopleRepository(db).thisDevice())!;
        await LedgerRepository(db).sell(
          Session(deviceId: device.id, employeeId: owner.id),
          cart: [
            CartLine(productId: amox.id, quantity: 2, unitPrice: const Money(4500, Currency.syp)),
          ],
          currency: Currency.syp,
          payment: PaymentType.cash,
        );
      });
      await pumpApp(tester);
      final device = await tester.runAsync(() => PeopleRepository(db).thisDevice());
      container.read(sessionProvider.notifier).signIn(device!, owner);
      await settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await settle(tester);
      await tester.tap(find.text('مرتجع'));
      await settle(tester);

      await tester.tap(find.text('زبون عابر'));
      await settle(tester);
      expect(find.text('Amoxil 500 mg'), findsOneWidget);
      await tester.tap(find.byTooltip('+'));
      await settle(tester);
      await tester.tap(find.byTooltip('+'));
      await settle(tester);
      await tester.tap(find.byTooltip('+')); // capped at 2
      await settle(tester);
      expect(find.text('90 ل.س'), findsWidgets);
      await tester.tap(find.text('تأكيد المرتجع'));
      await settle(tester);

      final stock = await tester.runAsync(() => LedgerRepository(db).loadStock());
      expect(stock!.onHand(amox.id), 5);
      final returns = await tester.runAsync(() => db.select(db.returns).get());
      expect((returns!.single.totalMinor, returns.single.refund), (9000, 'cash'));
      expect(find.textContaining('انسجّل المرتجع'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('receive-stock dialog saves and closes without leaving the product page', (
      tester,
    ) async {
      await seed(tester);
      await pumpApp(tester);
      final device = await tester.runAsync(() => PeopleRepository(db).thisDevice());
      container.read(sessionProvider.notifier).signIn(device!, owner);
      await settle(tester);
      container.read(routerProvider).go(Routes.product(amox.id));
      await settle(tester);
      expect(find.text('تفاصيل الصنف'), findsOneWidget);

      await tester.tap(find.text('استلام بضاعة'));
      await settle(tester);
      await tester.enterText(find.byType(TextFormField).first, '3');
      await tester.tap(find.text('حفظ'));
      await settle(tester);

      expect(find.text('الكمية (علب)'), findsNothing); // dialog closed
      expect(find.text('الكمية'), findsNothing);
      expect(find.text('تفاصيل الصنف'), findsOneWidget); // still on the product page
      final stock = await tester.runAsync(() => LedgerRepository(db).loadStock());
      expect(stock!.onHand(amox.id), 8);
      await unmount(tester);
    });

    testWidgets('POS: discount + amount received shows change; till summary adds up', (
      tester,
    ) async {
      await signInAndOpenPos(tester);
      await tester.enterText(find.byType(TextField).first, '6221000000011');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await settle(tester);
      await tester.enterText(find.byType(TextField).first, '6221000000011');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await settle(tester); // 2 × 45 = 90

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '5'); // discount
      await tester.enterText(fields.at(1), '100'); // received
      await settle(tester);
      expect(find.text('85 ل.س'), findsWidgets); // total
      expect(find.text('الباقي للزبون'), findsOneWidget);
      expect(find.text('15 ل.س'), findsOneWidget); // change

      // Enter in the amount-received field completes the sale.
      await tester.showKeyboard(fields.at(1));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await settle(tester);
      final sale = (await tester.runAsync(() => db.select(db.sales).get()))!.single;
      expect((sale.totalMinor, sale.discountMinor, sale.tenderedMinor), (8500, 500, 10000));

      // Till: float 100 + cash sale 85 = 185 expected.
      await tester.tap(find.text('الصندوق'));
      await settle(tester);
      expect(find.text('185 ل.س'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('POS: amount received below total blocks the sale', (tester) async {
      await signInAndOpenPos(tester);
      await tester.enterText(find.byType(TextField).first, '6221000000011');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await settle(tester);
      await tester.enterText(find.byType(TextFormField).at(1), '40');
      await settle(tester);
      expect(find.text('المبلغ المقبوض أقل من الإجمالي'), findsOneWidget);
      final button = tester.widget<SagePillButton>(
        find.widgetWithText(SagePillButton, 'إتمام البيع'),
      );
      expect(button.onPressed, isNull);
      await unmount(tester);
    });

    testWidgets('closed till: POS asks to open it; closing shows the shortage', (tester) async {
      await seed(tester, openTill: false);
      await pumpApp(tester);
      final device = await tester.runAsync(() => PeopleRepository(db).thisDevice());
      container.read(sessionProvider.notifier).signIn(device!, owner);
      await settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await settle(tester);
      expect(find.text('الصندوق مسكّر. افتحه لتبدأ البيع.'), findsOneWidget);

      await tester.tap(find.text('افتح الصندوق').last);
      await settle(tester);
      await tester.enterText(find.byType(TextFormField).last, '50');
      await tester.tap(find.text('تأكيد'));
      await settle(tester);
      expect(find.text('إتمام البيع'), findsOneWidget);

      await tester.tap(find.text('الصندوق'));
      await settle(tester);
      await tester.tap(find.widgetWithText(SagePillButton, 'إغلاق الصندوق'));
      await settle(tester);
      await tester.enterText(find.byType(TextFormField).last, '45');
      await tester.tap(find.text('تأكيد'));
      await settle(tester);
      expect(find.text('عجز 5 ل.س'), findsOneWidget);
      await unmount(tester);
    });

    Future<(DeviceRow, SupplierRow)> seedSupplier(
      WidgetTester tester, {
      bool openTill = true,
    }) async {
      await seed(tester, openTill: openTill);
      late SupplierRow supplier;
      late DeviceRow device;
      await tester.runAsync(() async {
        device = (await PeopleRepository(db).thisDevice())!;
        supplier = await AccountingRepository(
          db,
          LedgerRepository(db),
        ).addSupplier(name: 'مستودع النور', repName: 'أبو خالد');
      });
      return (device, supplier);
    }

    testWidgets('purchase invoice: scan, bonus, discount, transport, credit, new sale price', (
      tester,
    ) async {
      final (device, supplier) = await seedSupplier(tester);
      await pumpApp(tester);
      container.read(sessionProvider.notifier).signIn(device, owner);
      await settle(tester);
      container.read(routerProvider).go(Routes.newPurchaseFrom(supplier.id));
      await settle(tester);
      expect(find.text('مستودع النور'), findsOneWidget); // supplier preselected

      await tester.enterText(find.byType(TextField).first, '6221000000011');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await settle(tester);
      expect(find.text('Amoxil 500 mg'), findsOneWidget);

      Finder field(String label) => find.descendant(
        of: find.widgetWithText(GlassTextField, label),
        matching: find.byType(TextField),
      );
      await tester.enterText(field('الكمية'), '10');
      await tester.enterText(field('بونص'), '2');
      await tester.enterText(field('سعر الشراء'), '30');
      await tester.enterText(field('حسم %'), '10');
      await tester.enterText(field('الانتهاء'), '1/6/2028');
      await tester.enterText(field('سعر المبيع'), '50');
      await tester.enterText(field('مصاريف نقل'), '10');
      await settle(tester);
      expect(find.text('280 ل.س'), findsOneWidget); // 300 − 10% + 10

      await tester.sendKeyEvent(LogicalKeyboardKey.f9);
      await settle(tester);
      expect(find.text('انحفظت فاتورة الشراء'), findsOneWidget);

      final stock = await tester.runAsync(() => LedgerRepository(db).loadStock());
      expect(stock!.onHand(amox.id), 5 + 12);
      final ledger = await tester.runAsync(
        () => AccountingRepository(db, LedgerRepository(db)).loadSupplierLedger(),
      );
      expect(ledger!.balance(supplier.id), 28000);
      final product = await tester.runAsync(() => CatalogRepository(db).byId(amox.id));
      expect(product!.priceMinor, 5000);
      await unmount(tester);
    });

    testWidgets(
      'supplier page: owner sees statement and pays from the drawer; employee sees no amounts',
      (tester) async {
        final (device, supplier) = await seedSupplier(tester);
        late EmployeeRow rana;
        await tester.runAsync(() async {
          rana = await PeopleRepository(db).addEmployee(name: 'رنا', pin: '1111');
          await AccountingRepository(db, LedgerRepository(db)).recordPurchase(
            Session(deviceId: device.id, employeeId: rana.id),
            supplierId: supplier.id,
            items: [PurchaseItem(productId: amox.id, quantity: 4, unitPriceMinor: 2500)],
            currency: Currency.syp,
            payment: PurchasePayment.credit,
          );
        });
        await pumpApp(tester);

        // Employee: the invoice is listed, but no totals or balances.
        container.read(sessionProvider.notifier).signIn(device, rana);
        await settle(tester);
        container.read(routerProvider).go(Routes.purchases);
        await settle(tester);
        expect(find.text('مستودع النور'), findsOneWidget);
        expect(find.textContaining('دخّلها رنا'), findsOneWidget);
        expect(find.text('100 ل.س'), findsNothing);
        container.read(routerProvider).go(Routes.supplier(supplier.id));
        await settle(tester);
        expect(find.text('كشف الحساب'), findsNothing);

        // Owner: balance + statement; pays 40 from the drawer.
        container.read(sessionProvider.notifier).signIn(device, owner);
        await settle(tester);
        container.read(routerProvider).go(Routes.supplier(supplier.id));
        await settle(tester);
        expect(find.text('كشف الحساب'), findsOneWidget);
        expect(find.text('100 ل.س'), findsWidgets);

        await tester.tap(find.text('دفعة للمورد'));
        await settle(tester);
        await tester.enterText(find.byType(TextFormField).first, '40');
        await tester.tap(find.text('تأكيد'));
        await settle(tester);
        expect(find.text('60 ل.س'), findsWidgets);
        final shift = await tester.runAsync(() async {
          final till = TillRepository(db);
          final stamp = Session(deviceId: device.id, employeeId: owner.id);
          return till.summary((await till.openShiftId(stamp))!);
        });
        expect(shift!.movements.drawerPurchases, 4000);
        expect(shift.expected, 10000 - 4000);
        await unmount(tester);
      },
    );

    testWidgets('closed till: paying a supplier from the drawer is refused', (tester) async {
      final (device, supplier) = await seedSupplier(tester, openTill: false);
      await pumpApp(tester);
      container.read(sessionProvider.notifier).signIn(device, owner);
      await settle(tester);
      container.read(routerProvider).go(Routes.supplier(supplier.id));
      await settle(tester);
      await tester.tap(find.text('دفعة للمورد'));
      await settle(tester);
      await tester.enterText(find.byType(TextFormField).first, '40');
      await tester.tap(find.text('تأكيد'));
      await settle(tester);
      expect(find.textContaining('الصندوق مسكّر'), findsOneWidget);
      final events = await tester.runAsync(() => db.select(db.supplierDebtEvents).get());
      expect(events, isEmpty);
      await unmount(tester);
    });

    testWidgets('profit report: owner only; unknown cost is flagged, not guessed', (tester) async {
      final (device, supplier) = await seedSupplier(tester);
      late EmployeeRow rana;
      await tester.runAsync(() async {
        rana = await PeopleRepository(db).addEmployee(name: 'رنا', pin: '1111');
        final stamp = Session(deviceId: device.id, employeeId: owner.id);
        await AccountingRepository(db, LedgerRepository(db)).recordPurchase(
          stamp,
          supplierId: supplier.id,
          items: [PurchaseItem(productId: amox.id, quantity: 4, unitPriceMinor: 2500)],
          currency: Currency.syp,
          payment: PurchasePayment.credit,
        );
        // FEFO sells the seeded batch first: it has no purchase cost.
        await LedgerRepository(db).sell(
          stamp,
          cart: [
            CartLine(productId: amox.id, quantity: 1, unitPrice: const Money(4500, Currency.syp)),
          ],
          currency: Currency.syp,
          payment: PaymentType.cash,
        );
      });
      await pumpApp(tester);

      container.read(sessionProvider.notifier).signIn(device, rana);
      await settle(tester);
      expect(find.text('ربح اليوم'), findsNothing);
      expect(find.text('الأرباح'), findsNothing);

      container.read(sessionProvider.notifier).signIn(device, owner);
      await settle(tester);
      expect(find.text('ربح اليوم'), findsOneWidget);
      expect(find.text('علينا للموردين'), findsOneWidget);
      await tester.tap(find.text('الأرباح'));
      await settle(tester);
      expect(find.text('الأرباح والتكلفة'), findsOneWidget);
      expect(find.text('Amoxil 500 mg'), findsOneWidget);
      expect(find.textContaining('تكلفتها مو معروفة'), findsOneWidget);
      expect(find.text('100 ل.س'), findsOneWidget); // stock value: 4 boxes at 25
      await unmount(tester);
    });

    testWidgets('shortage → order per supplier → copied for WhatsApp → received as an invoice', (
      tester,
    ) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (
        call,
      ) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      final (device, supplier) = await seedSupplier(tester);
      await pumpApp(tester);
      container.read(sessionProvider.notifier).signIn(device, owner);
      await settle(tester);
      container.read(routerProvider).go(Routes.shortages);
      await settle(tester);
      // 5 boxes on hand, minimum 5 → under the minimum; 1 box suggested.
      expect(find.text('تحت الحد الأدنى'), findsOneWidget);

      await tester.tap(find.text('اعمل الطلبيات (1)'));
      await settle(tester);
      expect(find.textContaining('في أصناف بدون مورد'), findsOneWidget);

      await tester.tap(find.text('اختار المورد'));
      await settle(tester);
      await tester.tap(find.text('مستودع النور'));
      await settle(tester);
      await tester.tap(find.text('اعمل الطلبيات (1)'));
      await settle(tester);
      expect(find.text('مسودة'), findsOneWidget); // switched to the orders tab

      await tester.tap(find.text('مستودع النور'));
      await settle(tester);
      await tester.tap(find.text('انسخ الطلبية'));
      await settle(tester);
      expect(copied, contains('1. Amoxil 500 mg: 1 علبة'));
      expect(copied, contains('طلبية من'));
      expect(find.text('انبعتت'), findsWidgets);

      await tester.tap(find.text('وصلت: فاتورة شراء'));
      await settle(tester);
      expect(find.text('Amoxil 500 mg'), findsOneWidget); // line filled in
      await tester.enterText(
        find.descendant(
          of: find.widgetWithText(GlassTextField, 'سعر الشراء'),
          matching: find.byType(TextField),
        ),
        '30',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.f9);
      await settle(tester);
      expect(find.text('انحفظت فاتورة الشراء'), findsOneWidget);
      final stock = await tester.runAsync(() => LedgerRepository(db).loadStock());
      expect(stock!.onHand(amox.id), 6);
      final order = await tester.runAsync(() => db.select(db.purchaseOrders).getSingle());
      expect(order!.status, 'received');
      await unmount(tester);
    });

    testWidgets('order by WhatsApp: asks for the supplier number, then opens the chat', (
      tester,
    ) async {
      final (device, supplier) = await seedSupplier(tester);
      await tester.runAsync(
        () => AccountingRepository(db, LedgerRepository(db)).createOrders({
          supplier.id: [(amox.id, 4)],
        }),
      );
      final opened = <(String, String?)>[];
      await pumpApp(
        tester,
        overrides: [
          whatsappProvider.overrideWithValue((number, {text}) async {
            opened.add((number, text));
            return true;
          }),
        ],
      );
      container.read(sessionProvider.notifier).signIn(device, owner);
      await settle(tester);
      container.read(routerProvider).go('${Routes.purchases}?tab=orders');
      await settle(tester);
      await tester.tap(find.text('مستودع النور'));
      await settle(tester);
      await tester.tap(find.text('ابعتها واتساب'));
      await settle(tester);
      expect(find.text('تعديل المورد'), findsOneWidget); // no number yet
      await tester.enterText(
        find.descendant(
          of: find.widgetWithText(GlassTextField, 'رقم الواتساب (اختياري)'),
          matching: find.byType(TextField),
        ),
        '٠٩٤٤ ١٢٣ ٤٥٦',
      );
      await tester.tap(find.text('حفظ'));
      await settle(tester);
      expect(opened.single.$1, '963944123456');
      expect(opened.single.$2, contains('1. Amoxil 500 mg: 4 علبة'));
      expect(find.text('انبعتت'), findsWidgets);
      final saved = await tester.runAsync(
        () => AccountingRepository(db, LedgerRepository(db)).supplier(supplier.id),
      );
      expect(saved!.phone, '0944 123 456');
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
