import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('DoayaTheme', () {
    test('glass and solid expose matching token extensions', () {
      final glass = DoayaTheme.glass().extension<DoayaTokens>()!;
      final solid = DoayaTheme.solid().extension<DoayaTokens>()!;
      expect(glass.surfaceStyle, SurfaceStyle.glass);
      expect(glass.blurAllowed, isTrue);
      expect(glass.surfaceFill, DoayaColors.glassFill);
      expect(solid.surfaceStyle, SurfaceStyle.solid);
      expect(solid.blurAllowed, isFalse);
      expect(solid.surfaceFill, DoayaColors.surface);
      expect(solid.surfaceFillStrong, DoayaColors.surfaceRaised);
      expect(solid.surfaceBorder, DoayaColors.border);
    });

    test('is dark, uses Readex Pro and a transparent scaffold', () {
      final theme = DoayaTheme.glass();
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor.a, 0);
      expect(theme.textTheme.bodyLarge!.fontFamily, contains(DoayaFonts.body));
      expect(theme.textTheme.displayLarge!.fontFamily, contains(DoayaFonts.display));
    });

    test('tokens lerp between modes', () {
      final glass = DoayaTokens.glass;
      final mid = glass.lerp(DoayaTokens.solid, 0.5);
      expect(mid.surfaceStyle, SurfaceStyle.solid);
      expect(glass.lerp(DoayaTokens.solid, 0).surfaceFill, DoayaColors.glassFill);
      expect(glass.lerp(null, 0.7), same(glass));
    });

    test('spec colors are exact', () {
      expect(DoayaColors.bgTop, const Color(0xFF285439));
      expect(DoayaColors.glassFill, const Color.fromRGBO(236, 242, 234, 0.09));
      expect(DoayaColors.onSage, const Color(0xFF1B3024));
      expect(DoayaColors.accent, const Color(0xFFC9DEAE));
      expect(DoayaColors.dangerFill, const Color.fromRGBO(240, 120, 110, 0.16));
    });
  });

  group('GlassSurface blur rules', () {
    testWidgets('glass theme + blur builds a BackdropFilter', (tester) async {
      await tester.pumpWidget(
        harness(const GlassSurface(blur: true, child: SizedBox(width: 100, height: 100))),
      );
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('no blur by default', (tester) async {
      await tester.pumpWidget(
        harness(const GlassSurface(child: SizedBox(width: 100, height: 100))),
      );
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('solid theme never blurs, even when asked', (tester) async {
      await tester.pumpWidget(
        harness(
          const Column(
            children: [
              GlassSurface(
                blur: true,
                tone: SurfaceTone.strong,
                child: SizedBox(width: 100, height: 100),
              ),
              GlassSurface(blur: true, child: SizedBox(width: 100, height: 100)),
            ],
          ),
          theme: DoayaTheme.solid(),
        ),
      );
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('solid theme paints the solid surface color', (tester) async {
      await tester.pumpWidget(
        harness(
          const GlassSurface(child: SizedBox(width: 50, height: 50)),
          theme: DoayaTheme.solid(),
        ),
      );
      final box = tester.widget<DecoratedBox>(
        find.descendant(of: find.byType(GlassSurface), matching: find.byType(DecoratedBox)).first,
      );
      expect((box.decoration as BoxDecoration).color, DoayaColors.surface);
    });
  });
}
