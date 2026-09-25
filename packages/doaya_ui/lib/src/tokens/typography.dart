import 'package:flutter/painting.dart';

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
  static const _amiri = TextStyle(
    fontFamily: DoayaFonts.display,
    package: DoayaFonts.package,
    fontWeight: FontWeight.w700,
    color: DoayaColors.textPrimary,
    height: 1.2,
  );

  static const _readex = TextStyle(
    fontFamily: DoayaFonts.body,
    package: DoayaFonts.package,
    fontWeight: FontWeight.w400,
    color: DoayaColors.textPrimary,
  );

  // Display (Amiri Bold).
  static final wordmark = _amiri.copyWith(fontSize: 64, height: 1.1);
  static final displayLarge = _amiri.copyWith(fontSize: 30);
  static final title = _amiri.copyWith(fontSize: 28);
  static final titleMedium = _amiri.copyWith(fontSize: 26);
  static final titleSmall = _amiri.copyWith(fontSize: 22, height: 1.1);
  static final price = _amiri.copyWith(fontSize: 26, color: DoayaColors.price);
  static final bigNumber = _amiri.copyWith(fontSize: 26);

  // Body (Readex Pro).
  static final lead = _readex.copyWith(fontSize: 18, fontWeight: FontWeight.w500);
  static final bodyLarge = _readex.copyWith(fontSize: 16, height: 1.9);
  static final body = _readex.copyWith(fontSize: 15, height: 1.6);
  static final bodyMedium = _readex.copyWith(fontSize: 14, height: 1.7);
  static final bodySmall = _readex.copyWith(fontSize: 13, height: 1.7);
  static final label = _readex.copyWith(fontSize: 14, fontWeight: FontWeight.w500);
  static final button = _readex.copyWith(fontSize: 16, fontWeight: FontWeight.w500);
  static final buttonSmall = _readex.copyWith(fontSize: 13, fontWeight: FontWeight.w500);
  static final caption = _readex.copyWith(fontSize: 12);
  static final micro = _readex.copyWith(fontSize: 11);
  static final sectionLabel = _readex.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w300,
    color: DoayaColors.textSecondary,
  );
  static final badge = _readex.copyWith(fontSize: 10, height: 1, color: DoayaColors.onSage);
  static final priceSmall = _readex.copyWith(fontSize: 12, color: DoayaColors.price);
}
