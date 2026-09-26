import 'dart:ui' show Brightness;

import 'package:flutter/painting.dart';

import 'package:doaya_ui/src/theme/doaya_look.dart';
import 'package:flutter_test/flutter_test.dart';

const modes = [DoayaMode.dark, DoayaMode.light, DoayaMode.black];

Iterable<(String, DoayaLook)> everyLook() sync* {
  for (final p in [...DoayaPaletteSpec.all.map((p) => p.id), DoayaLook.custom]) {
    for (final m in modes) {
      for (final s in DoayaStyle.values) {
        yield ('$p/${m.name}/${s.name}', DoayaLook(palette: p, mode: m, style: s));
      }
    }
  }
}

void readable(String name, DoayaPalette p, {required bool hi}) {
  final t = hi ? 7.0 : 4.5;
  expect(contrastRatio(p.textPrimary, p.bgMid), greaterThanOrEqualTo(hi ? 12 : 7), reason: '$name text');
  expect(contrastRatio(p.textPrimary, p.surfaceRaised), greaterThanOrEqualTo(4.5), reason: '$name text on a card');
  expect(contrastRatio(p.textSecondary, p.bgMid), greaterThanOrEqualTo(t), reason: '$name secondary');
  expect(contrastRatio(p.accent, p.bgMid), greaterThanOrEqualTo(t), reason: '$name accent');
  expect(contrastRatio(p.onSage, p.accent), greaterThanOrEqualTo(4.5), reason: '$name text on accent');
  expect(contrastRatio(p.onSage, p.sageBottom), greaterThanOrEqualTo(4.5), reason: '$name button text');
  expect(contrastRatio(p.dangerText, p.bgMid), greaterThanOrEqualTo(4.5), reason: '$name danger');
  expect(contrastRatio(p.warningText, p.bgMid), greaterThanOrEqualTo(4.5), reason: '$name warning');
}

void main() {
  test('nobody who leaves «المظهر» alone sees any change', () {
    expect(identical(DoayaPalette.of(const DoayaLook()), DoayaPalette.classic), isTrue);
    for (final s in [DoayaStyle.glass, DoayaStyle.flat, DoayaStyle.soft, DoayaStyle.outline]) {
      expect(identical(DoayaPalette.of(DoayaLook(style: s)), DoayaPalette.classic), isTrue);
    }
  });

  test('every palette, mode and style stays readable', () {
    for (final (name, look) in everyLook()) {
      readable(name, DoayaPalette.of(look), hi: look.style == DoayaStyle.contrast);
    }
  });

  test('any colours a user picks stay readable', () {
    for (var h = 0; h < 360; h += 30) {
      for (final l in [0.15, 0.35, 0.55, 0.75, 0.9]) {
        final main = HSLColor.fromAHSL(1, h.toDouble(), 0.7, l).toColor();
        for (final bl in [0.05, 0.3, 0.5, 0.7, 0.95]) {
          final back = HSLColor.fromAHSL(1, (h + 150) % 360, 0.4, bl).toColor();
          for (final m in modes) {
            final look = DoayaLook(
              palette: DoayaLook.custom,
              customMain: main,
              customDark: back,
              customLight: back,
              mode: m,
            );
            readable('h$h l$l bl$bl ${m.name}', DoayaPalette.of(look), hi: false);
          }
        }
      }
    }
  });

  test('danger and warning keep their meaning in every look', () {
    for (final (name, look) in everyLook()) {
      final p = DoayaPalette.of(look);
      final light = p.brightness == Brightness.light;
      expect(p.dangerText, light ? const Color(0xFF8E1F14) : DoayaPalette.classic.dangerText, reason: name);
      expect(p.warningText, light ? const Color(0xFF6E4600) : DoayaPalette.classic.warningText, reason: name);
    }
  });

  test('a main colour that would be hard to read is adjusted, and says so', () {
    final p = DoayaPalette.of(
      const DoayaLook(palette: DoayaLook.custom, customMain: Color(0xFF203020), customDark: Color(0xFF101810)),
    );
    expect(p.accentAdjusted, isTrue);
    expect(DoayaPalette.of(const DoayaLook(palette: 'navy')).accentAdjusted, isFalse);
  });

  test('«تلقائي» follows the device; the choice survives a restart', () {
    const auto = DoayaLook(mode: DoayaMode.auto, palette: 'violet');
    expect(DoayaPalette.of(auto, platform: Brightness.light).brightness, Brightness.light);
    expect(DoayaPalette.of(auto, platform: Brightness.dark).brightness, Brightness.dark);

    const look = DoayaLook(
      style: DoayaStyle.soft,
      mode: DoayaMode.black,
      palette: DoayaLook.custom,
      customMain: Color(0xFF8CC8F5),
      radius: 1.5,
      blur: 10,
      textScale: 1.15,
      density: 0.72,
      headingFont: DoayaHeadingFont.readex,
    );
    expect(DoayaLook.fromJson(look.toJson()), look);
    expect(DoayaLook.fromJson({'style': 'weird', 'radius': 'x', 'text_scale': 9}), const DoayaLook(textScale: 1.4));
  });
}
