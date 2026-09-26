import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/dimensions.dart';
import '../tokens/typography.dart';
import 'doaya_appearance.dart';
import 'doaya_tokens.dart';

/// Builds the app-wide [ThemeData].
///
/// * [DoayaTheme.glass] — patient app, admin web, pharmacy mobile.
/// * [DoayaTheme.solid] — pharmacy desktop: same look, no blur anywhere.
abstract final class DoayaTheme {
  static ThemeData glass() => _build(DoayaTokens.glass);
  static ThemeData solid() => _build(DoayaTokens.solid);

  static ThemeData _build(DoayaTokens tokens) {
    final brightness = DoayaAppearance.palette.brightness;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: DoayaColors.accent,
      onPrimary: DoayaColors.onSage,
      secondary: DoayaColors.sageBottom,
      onSecondary: DoayaColors.onSage,
      error: DoayaColors.dangerText,
      onError: DoayaColors.onSage,
      surface: DoayaColors.surface,
      onSurface: DoayaColors.textPrimary,
      onSurfaceVariant: DoayaColors.textSecondary,
      outline: DoayaColors.border,
      outlineVariant: DoayaColors.glassBorder,
    );

    final textTheme = TextTheme(
      displayLarge: DoayaTypography.wordmark,
      displayMedium: DoayaTypography.displayLarge,
      headlineLarge: DoayaTypography.title,
      headlineMedium: DoayaTypography.titleMedium,
      headlineSmall: DoayaTypography.titleSmall,
      titleLarge: DoayaTypography.lead,
      titleMedium: DoayaTypography.label,
      bodyLarge: DoayaTypography.body,
      bodyMedium: DoayaTypography.bodyMedium,
      bodySmall: DoayaTypography.bodySmall,
      labelLarge: DoayaTypography.button,
      labelMedium: DoayaTypography.caption,
      labelSmall: DoayaTypography.micro,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: DoayaFonts.bodyQualified,
      textTheme: textTheme,
      scaffoldBackgroundColor: DoayaColors.transparent,
      canvasColor: DoayaColors.bgMid,
      dividerColor: DoayaColors.divider,
      splashFactory: InkRipple.splashFactory,
      iconTheme: IconThemeData(color: DoayaColors.textPrimary, size: DoayaSizes.iconL),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: DoayaColors.accent,
        selectionColor: DoayaColors.selectedTileFill,
        selectionHandleColor: DoayaColors.accent,
      ),
      tooltipTheme: TooltipThemeData(
        textStyle: DoayaTypography.caption.copyWith(color: DoayaColors.onSage),
        decoration: BoxDecoration(
          color: DoayaColors.accent,
          borderRadius: BorderRadius.circular(DoayaRadii.key),
        ),
      ),
      extensions: [tokens],
    );
  }
}
