import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('SagePillButton fires and is inert when disabled', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      harness(
        Column(
          children: [
            SagePillButton(label: 'يلا نبلش', icon: DoayaIcons.forward, onPressed: () => taps++),
            const SagePillButton(label: 'غير متاح', onPressed: null),
          ],
        ),
      ),
    );
    await tester.tap(find.text('يلا نبلش'));
    await tester.tap(find.text('غير متاح'));
    expect(taps, 1);
  });

  testWidgets('GlassPillButton and RoundIconButton respond to taps', (tester) async {
    var pill = 0;
    var round = 0;
    await tester.pumpWidget(
      harness(
        Column(
          children: [
            GlassPillButton(label: 'لا، ولا شي', selected: true, onPressed: () => pill++),
            RoundIconButton(icon: DoayaIcons.back, tooltip: 'رجوع', onPressed: () => round++),
          ],
        ),
      ),
    );
    await tester.tap(find.text('لا، ولا شي'));
    await tester.tap(find.byTooltip('رجوع'));
    expect((pill, round), (1, 1));
  });

  testWidgets('GlassSearchField forwards scanner input on submit', (tester) async {
    String? submitted;
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: 300,
          child: GlassSearchField(hint: 'ابحث', onSubmitted: (v) => submitted = v),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), '6221234567890');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    expect(submitted, '6221234567890');
  });

  testWidgets('IconTile, ProductCard, StatCard, StatusChip, CaseRow, NoticeBanner render', (
    tester,
  ) async {
    var fav = 0;
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: 360,
          child: Column(
            children: [
              IconTile(icon: DoayaIcons.medicine, label: 'الأدوية', selected: true, onTap: () {}),
              SizedBox(
                width: 120,
                child: ProductCard(
                  image: const Icon(DoayaIcons.medicine),
                  name: 'Omega 3',
                  price: '${formatNumber(45000)} ل.س',
                  onFavorite: () => fav++,
                  favoriteTooltip: 'المفضلة',
                ),
              ),
              StatCard(icon: DoayaIcons.sales, label: 'مبيعات اليوم', value: formatNumber(3)),
              const StatusChip(label: 'نفد', tone: StatusTone.danger),
              const StatusChip(label: 'جاهز', tone: StatusTone.success),
              const StatusChip(label: 'متزامن', dot: true),
              const CaseRow(initials: 'س.ح', title: 'ألم صدر', subtitle: 'مستعجلة', urgent: true),
              const NoticeBanner(message: 'روح عالطوارئ', icon: DoayaIcons.warning),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Omega 3'), findsOneWidget);
    expect(find.text('45,000 ل.س'), findsOneWidget);
    await tester.tap(find.byIcon(DoayaIcons.heart));
    expect(fav, 1);
  });

  testWidgets('LatinText renders LTR and aligns to the RTL start', (tester) async {
    await tester.pumpWidget(harness(const LatinText('Paracetamol 500')));
    final text = tester.widget<Text>(find.text('Paracetamol 500'));
    expect(text.textDirection, TextDirection.ltr);
    expect(text.textAlign, TextAlign.right);
    expect(ltrIsolate('Ibuprofen'), '\u2066Ibuprofen\u2069');
  });

  testWidgets('FloatingBottomNav reports taps and blurs once', (tester) async {
    var index = 0;
    await tester.pumpWidget(
      harness(
        StatefulBuilder(
          builder: (context, setState) => FloatingBottomNav(
            currentIndex: index,
            onTap: (i) => setState(() => index = i),
            items: const [
              DoayaNavItem(icon: DoayaIcons.home, label: 'الرئيسية'),
              DoayaNavItem(icon: DoayaIcons.chat, label: 'استشارة'),
              DoayaNavItem(icon: DoayaIcons.bag, label: 'طلباتي', badge: '2'),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(BackdropFilter), findsOneWidget);
    await tester.tap(find.text('طلباتي'));
    expect(index, 2);
  });

  for (final compact in [false, true]) {
    testWidgets('DesktopShell selects across sections (compact: $compact), no blur', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 880);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: DoayaTheme.solid(),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => DesktopShell(
                  brandName: 'دوايا',
                  compact: compact,
                  selectedIndex: selected,
                  onSelect: (i) => setState(() => selected = i),
                  sections: const [
                    DoayaNavSection(
                      title: 'الرئيسية',
                      items: [DoayaNavItem(icon: DoayaIcons.dashboard, label: 'لوحة التحكم')],
                    ),
                    DoayaNavSection(
                      title: 'العمليات',
                      items: [
                        DoayaNavItem(icon: DoayaIcons.pos, label: 'البيع'),
                        DoayaNavItem(icon: DoayaIcons.cases, label: 'حالات المساعد', badge: '3'),
                      ],
                    ),
                  ],
                  body: const GlassSurface(blur: true, child: SizedBox.expand()),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(BackdropFilter), findsNothing);
      if (compact) {
        await tester.tap(find.byTooltip('حالات المساعد'));
      } else {
        await tester.tap(find.text('حالات المساعد'));
      }
      expect(selected, 2);
    });
  }

  testWidgets('DoayaLogo paints at any size', (tester) async {
    await tester.pumpWidget(
      harness(
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DoayaLogo(),
            DoayaLogo(size: DoayaSizes.logoSmall, strokeWidth: 5, showPlus: false),
            DoayaWordmark(name: 'دوايا'),
          ],
        ),
      ),
    );
    expect(find.byType(DoayaLogo), findsNWidgets(3));
    const a = DoayaLogoPainter();
    expect(a.shouldRepaint(const DoayaLogoPainter()), isFalse);
    expect(a.shouldRepaint(const DoayaLogoPainter(strokeWidth: 5)), isTrue);
  });

  testWidgets('DoayaBackground falls back to the gradient when the photo is missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DoayaBackground(photo: AssetImage('assets/bg/leaves.jpg'), child: Text('x')),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('x'), findsOneWidget);
  });
}
