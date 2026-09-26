import 'package:doaya_pharmacy/app.dart';
import 'package:doaya_pharmacy/central/inbox_controller.dart';
import 'package:doaya_pharmacy/data/catalog_repository.dart';
import 'package:doaya_pharmacy/data/database.dart';
import 'package:doaya_pharmacy/data/ledger_repository.dart';
import 'package:doaya_pharmacy/data/people_repository.dart';
import 'package:doaya_pharmacy/data/till_repository.dart';
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

const summary = {
  'symptoms': ['صداع', 'حرارة خفيفة'],
  'duration': 'يومين',
  'age': '34',
  'sex': 'ذكر',
  'pregnancy': null,
  'allergies': 'ما في',
  'medications': 'ولا شي',
  'conditions': null,
  'denied_red_flags': ['غثيان', 'تيبس بالرقبة'],
  'notes': null,
};

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late FakeSyncApi api;
  late ProviderContainer container;
  late AppDatabase db;
  late DeviceRow dev;
  late EmployeeRow owner, rana;
  late ProductRow amox;

  setUp(() {
    api = FakeSyncApi();
    db = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// The counter PC, linked to its pharmacy server, with an open till, a
  /// product in stock and a customer whose phone matches a patient's.
  Future<void> pumpLinked(WidgetTester tester) async {
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
      final s = Session(deviceId: dev.id, employeeId: owner.id);
      await LedgerRepository(db).receive(s, productId: amox.id, quantity: 7);
      await people.addCustomer(name: 'مازن الخطيب', phone: '0933 111 222');
      await TillRepository(db).openShift(s, floatMinor: 10000);
    });
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        syncApiProvider.overrideWithValue(api),
        syncIntervalProvider.overrideWithValue(null),
        inboxIntervalProvider.overrideWithValue(null),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const PharmacyApp()),
    );
    await settle(tester);
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
  }

  Future<void> refreshInbox(WidgetTester tester) async {
    container.read(inboxProvider.notifier).refresh();
    await settle(tester);
  }

  testWidgets('the owner links Doaya online from the sync screen', (tester) async {
    api.central.connected = false;
    await pumpLinked(tester);
    expect(find.text('دوايا أونلاين'), findsOneWidget);
    expect(find.text('مو مربوطة'), findsOneWidget);
    await tester.enterText(field('عنوان دوايا أونلاين'), 'https://doaya.example');
    await tester.enterText(field('مفتاح الصيدلية'), 'dk_wrong');
    await tester.tap(find.text('اربط'));
    await settle(tester);
    expect(find.text('المفتاح غلط'), findsOneWidget);
    await tester.enterText(field('مفتاح الصيدلية'), 'dk_good');
    // Wait for the error toast at the bottom to go.
    await tester.pump(const Duration(seconds: 6));
    await settle(tester);
    await tester.tap(find.text('اربط'));
    await settle(tester);
    expect(api.central.connected, isTrue);
    expect(find.textContaining('مربوطة بـ'), findsOneWidget);
    expect(container.read(inboxProvider).phase, InboxPhase.ready);
  });

  testWidgets('a case: urgent first, summary, customer history, decision, pickup at the POS', (
    tester,
  ) async {
    await pumpLinked(tester);
    api.central
      ..addCase(
        'c1',
        summary: summary,
        messages: [('assistant', 'أهلين'), ('patient', 'عندي صداع'), ('assistant', 'من إيمتى؟')],
        sentAt: DateTime.utc(2026, 9, 26, 11),
      )
      ..addCase(
        'c2',
        urgent: true,
        status: 'emergency',
        redFlag: 'chest_pain',
        messages: [('patient', 'بابا عنده وجع بصدره')],
        patient: {'name': 'ليلى', 'phone': '0944777888', 'age': 61, 'sex': 'f'},
        sentAt: DateTime.utc(2026, 9, 26, 9),
      );
    await refreshInbox(tester);
    expect(find.text('وصلت حالة مستعجلة: ليلى'), findsOneWidget);

    container.read(routerProvider).go(Routes.cases);
    await settle(tester);
    final rows = tester.widgetList<CaseRow>(find.byType(CaseRow)).toList();
    expect(rows.first.urgent, isTrue); // urgent on top
    expect(rows.last.title, 'صداع، حرارة خفيفة');

    await tester.tap(find.text('صداع، حرارة خفيفة'));
    await settle(tester);
    expect(find.text('ملخص المساعد'), findsOneWidget);
    expect(find.text('يومين'), findsOneWidget);
    expect(find.text('نفى: غثيان، تيبس بالرقبة'), findsOneWidget);
    expect(find.text('مازن الخطيب'), findsOneWidget); // matched by phone
    expect(find.text('القرار والجرعات دايماً عند الصيدلي'), findsOneWidget);

    // Correct the assistant's question.
    await tester.tap(find.text('صحّح').last);
    await settle(tester);
    await tester.enterText(field('شو كان الصح؟'), 'كان لازم يسأل عن الحرارة كم');
    await tester.tap(find.text('تأكيد'));
    await settle(tester);
    expect(api.central.corrections.single['message_id'], isNotNull);

    // Decide: Amoxil from stock, with the pharmacist's instructions.
    await tester.enterText(field('أضف دوا'), 'Amox');
    await settle(tester);
    await tester.tap(find.text('Amoxil 500 mg').last);
    await settle(tester);
    await tester.tap(find.text('جاهز، بلّغ المريض'));
    await settle(tester);
    expect(find.text('اكتب طريقة الاستعمال لكل دوا'), findsOneWidget);
    await tester.enterText(field('طريقة الاستعمال'), 'كبسولة كل 8 ساعات لمدة 5 أيام');
    await tester.enterText(field('مرات باليوم'), '3');
    await tester.tap(find.text('جاهز، بلّغ المريض'));
    await settle(tester);
    final decision = api.central.cases['c1']!['decision']! as Map;
    final item = (decision['items']! as List).single as Map;
    expect((item['product_id'], item['times_per_day']), (amox.id, 3));
    expect(api.central.cases['c1']!['status'], 'ready');

    // Pickup: the POS opens with the cart filled; the sale marks it picked up.
    await tester.tap(find.text('استلم وبيع'));
    await settle(tester);
    expect(find.text('Amoxil 500 mg'), findsWidgets);
    await tester.tap(find.text('إتمام البيع'));
    await settle(tester, 10);
    expect(api.central.cases['c1']!['status'], 'picked_up');
    final stock = await tester.runAsync(() => LedgerRepository(db).loadStock());
    expect(stock!.onHand(amox.id), 6);
  });

  testWidgets('ask the patient, then send them to a doctor', (tester) async {
    await pumpLinked(tester);
    api.central.addCase('c1', messages: [('patient', 'عندي دوخة من اسبوع')]);
    await refreshInbox(tester);
    container.read(routerProvider).go(Routes.cases);
    await settle(tester);
    await tester.tap(find.text('عندي دوخة من اسبوع'));
    await settle(tester);
    expect(find.textContaining('المساعد ما كان متاح'), findsOneWidget); // no summary
    await tester.tap(find.text('اسأل المريض سؤال'));
    await settle(tester);
    await tester.enterText(field('اسأل المريض سؤال'), 'في عندك ضغط؟');
    await tester.tap(find.text('تأكيد'));
    await settle(tester);
    final messages = api.central.cases['c1']!['messages']! as List;
    expect((messages.last as Map)['text'], 'في عندك ضغط؟');
    expect(api.central.cases['c1']!['status'], 'preparing');

    await tester.tap(find.text('بحاجة طبيب'));
    await settle(tester);
    await tester.tap(find.text('تأكيد'));
    await settle(tester);
    expect(api.central.cases['c1']!['status'], 'needs_doctor');
  });

  testWidgets('an order: the pharmacist sets the final quantities, then sells it', (tester) async {
    await pumpLinked(tester);
    api.central.addOrder(
      'o1',
      lines: [(amox.id, 'Amoxil 500 mg', 3, 4500), ('gone', 'Zyrtec', 1, 3000)],
      note: 'بدي فاتورة',
    );
    await refreshInbox(tester);
    container.read(routerProvider).go(Routes.casesTab('orders'));
    await settle(tester);
    await tester.tap(find.text('مازن'));
    await settle(tester);
    expect(find.text('ملاحظة المريض: بدي فاتورة'), findsOneWidget);
    // Two Amoxil instead of three, no Zyrtec.
    await tester.tap(find.byTooltip('−').first);
    await tester.pump();
    await tester.tap(find.byTooltip('−').last);
    await tester.pump();
    await tester.tap(find.text('جاهز للاستلام'));
    await settle(tester);
    final lines = (api.central.orders['o1']!['lines']! as List).cast<Map<String, Object?>>();
    expect(lines.map((l) => (l['product_id'], l['requested'], l['quantity'])), [(amox.id, 3, 2)]);
    expect(api.central.orders['o1']!['status'], 'ready');
    await tester.tap(find.text('استلم وبيع'));
    await settle(tester);
    await tester.tap(find.text('إتمام البيع'));
    await settle(tester, 10);
    expect(api.central.orders['o1']!['status'], 'picked_up');
  });

  testWidgets('no internet at the pharmacy: the inbox says so, selling is untouched', (
    tester,
  ) async {
    await pumpLinked(tester);
    api.central.online = false;
    await refreshInbox(tester);
    container.read(routerProvider).go(Routes.cases);
    await settle(tester);
    expect(find.textContaining('ما في إنترنت هلق'), findsOneWidget);
    // An employee doesn't see the menu entry until the pharmacy is on Doaya
    // online; here it is, so she does.
    container.read(sessionProvider.notifier).signIn(dev, rana);
    await settle(tester);
    expect(find.text('الحالات'), findsWidgets);
  });

  testWidgets('on a phone: the list, then the case and the order on their own pages', (
    tester,
  ) async {
    await pumpLinked(tester);
    api.central
      ..addCase('c1', summary: summary, messages: [('patient', 'عندي صداع')])
      ..addOrder('o1', lines: [(amox.id, 'Amoxil 500 mg', 2, 4500)]);
    await refreshInbox(tester);
    tester.view.physicalSize = const Size(360, 740);
    await settle(tester);
    container.read(routerProvider).go(Routes.cases);
    await settle(tester);
    await tester.tap(find.text('صداع، حرارة خفيفة'));
    await settle(tester);
    expect(find.text('ملخص المساعد'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('جاهز، بلّغ المريض'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    container.read(routerProvider).go(Routes.caseItem('orders', 'o1'));
    await settle(tester);
    expect(find.text('جاهز للاستلام'), findsOneWidget);
  });
}
