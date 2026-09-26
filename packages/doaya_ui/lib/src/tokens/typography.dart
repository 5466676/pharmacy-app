import 'package:flutter/painting.dart';

import '../theme/doaya_appearance.dart';
import '../theme/doaya_look.dart';
import 'colors.dart';

/// Font families bundled in this package.
abstract final class DoayaFonts {
  static const package = 'doaya_ui';
  static const display = 'Amiri';
  static const body = 'ReadexPro';

  /// Fully-qualified family, for places that don't accept `package:`
  /// (e.g. `ThemeData.fontFamily`).
  static const bodyQualified = 'packages/$package/$body';
}

/// Text styles. Amiri Bold for display/titles/prices/big numbers,
/// Readex Pro (300–600) for everything else.
abstract final class DoayaTypography {
  /// Titles: Amiri Bold, or Readex Pro Bold when the user picked «بسيط».
  static TextStyle get _amiri => TextStyle(
    fontFamily: DoayaAppearance.look.headingFont == DoayaHeadingFont.amiri
        ? DoayaFonts.display
        : DoayaFonts.body,
    package: DoayaFonts.package,
    fontWeight: FontWeight.w700,
    color: DoayaColors.textPrimary,
    height: 1.2,
  );

  static TextStyle get _readex => TextStyle(
    fontFamily: DoayaFonts.body,
    package: DoayaFonts.package,
    fontWeight: FontWeight.w400,
    color: DoayaColors.textPrimary,
  );

  // Display (Amiri Bold).
  static TextStyle get wordmark => _amiri.copyWith(fontSize: 64, height: 1.1);
  static TextStyle get displayLarge => _amiri.copyWith(fontSize: 30);
  static TextStyle get title => _amiri.copyWith(fontSize: 28);
  static TextStyle get titleMedium => _amiri.copyWith(fontSize: 26);
  static TextStyle get titleSmall => _amiri.copyWith(fontSize: 22, height: 1.1);
  static TextStyle get price => _amiri.copyWith(fontSize: 26, color: DoayaColors.price);
  static TextStyle get bigNumber => _amiri.copyWith(fontSize: 26);

  // Body (Readex Pro).
  static TextStyle get lead => _readex.copyWith(fontSize: 18, fontWeight: FontWeight.w500);
  static TextStyle get bodyLarge => _readex.copyWith(fontSize: 16, height: 1.9);
  static TextStyle get body => _readex.copyWith(fontSize: 15, height: 1.6);
  static TextStyle get bodyMedium => _readex.copyWith(fontSize: 14, height: 1.7);
  static TextStyle get bodySmall => _readex.copyWith(fontSize: 13, height: 1.7);
  static TextStyle get label => _readex.copyWith(fontSize: 14, fontWeight: FontWeight.w500);
  static TextStyle get button => _readex.copyWith(fontSize: 16, fontWeight: FontWeight.w500);
  static TextStyle get buttonSmall => _readex.copyWith(fontSize: 13, fontWeight: FontWeight.w500);
  static TextStyle get caption => _readex.copyWith(fontSize: 12);
  static TextStyle get micro => _readex.copyWith(fontSize: 11);
  static TextStyle get sectionLabel =>
      _readex.copyWith(fontSize: 11, fontWeight: FontWeight.w300, color: DoayaColors.textSecondary);
  static TextStyle get badge =>
      _readex.copyWith(fontSize: 10, height: 1, color: DoayaColors.onSage);
  static TextStyle get priceSmall => _readex.copyWith(fontSize: 12, color: DoayaColors.price);
}
