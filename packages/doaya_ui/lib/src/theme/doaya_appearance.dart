import 'dart:ui';

import 'doaya_look.dart';

/// The look in force right now. `DoayaColors`, `DoayaSpacing`,
/// `DoayaRadii` and `DoayaTypography` read it; `DoayaLookScope` sets it
/// and rebuilds the app when the user changes «المظهر».
abstract final class DoayaAppearance {
  static DoayaLook _look = const DoayaLook();
  static DoayaPalette _palette = DoayaPalette.classic;

  static DoayaLook get look => _look;
  static DoayaPalette get palette => _palette;

  /// Spacing factor (1 = comfortable, 0.72 = compact).
  static double get density => _look.density;

  /// Corner factor: the user's roundness × the style's own shape.
  static double get roundness =>
      _look.radius *
      switch (_look.style) {
        DoayaStyle.glass => 1.0,
        DoayaStyle.flat => 0.7,
        DoayaStyle.soft => 1.35,
        DoayaStyle.outline => 0.45,
        DoayaStyle.contrast => 0.7,
      };

  /// Sets the look (tests and `DoayaLookScope`); returns whether it changed.
  static bool apply(DoayaLook look, {Brightness platform = Brightness.dark}) {
    final palette = DoayaPalette.of(look, platform: platform);
    final changed =
        look != _look ||
        palette.brightness != _palette.brightness ||
        palette.bgMid != _palette.bgMid;
    _look = look;
    _palette = palette;
    return changed;
  }
}
