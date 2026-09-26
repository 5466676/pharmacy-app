import 'package:flutter/material.dart';

import 'dart:ui' show lerpDouble;

import 'doaya_appearance.dart';
import 'doaya_look.dart';

/// How surfaces are rendered.
enum SurfaceStyle {
  /// Translucent glass; large surfaces may use `BackdropFilter`.
  glass,

  /// Opaque solid variants, never any blur (pharmacy desktop).
  solid,
}

/// Mode-dependent design tokens, exposed as a [ThemeExtension].
///
/// Read with `DoayaTokens.of(context)`.
@immutable
class DoayaTokens extends ThemeExtension<DoayaTokens> {
  const DoayaTokens({
    required this.surfaceStyle,
    required this.surfaceFill,
    required this.surfaceFillStrong,
    required this.surfaceBorder,
    required this.surfaceBorderStrong,
    required this.highlight,
    required this.highlightStrong,
    required this.shadow,
    required this.shadowStrong,
    this.borderWidth = 1,
  });

  /// Surfaces for the current look; blur only where [allowBlur] (never on
  /// the pharmacy desktop) and only in the glass style.
  static DoayaTokens forLook({required bool allowBlur}) {
    final look = DoayaAppearance.look;
    final p = DoayaAppearance.palette;
    final light = p.brightness == Brightness.light;
    List<BoxShadow> drop(double blur, double y, Color c) => [
      BoxShadow(color: c, offset: Offset(0, y), blurRadius: blur),
    ];
    return switch (look.style) {
      DoayaStyle.glass when allowBlur => DoayaTokens(
        surfaceStyle: SurfaceStyle.glass,
        surfaceFill: p.glassFill,
        surfaceFillStrong: p.glassFillStrong,
        surfaceBorder: p.glassBorder,
        surfaceBorderStrong: p.glassBorderStrong,
        highlight: p.glassHighlight,
        highlightStrong: p.glassHighlightStrong,
        shadow: drop(30, 10, p.shadow),
        shadowStrong: drop(40, 16, p.shadowStrong),
      ),
      DoayaStyle.glass => DoayaTokens(
        surfaceStyle: SurfaceStyle.solid,
        surfaceFill: p.surface,
        surfaceFillStrong: p.surfaceRaised,
        surfaceBorder: p.border,
        surfaceBorderStrong: p.border,
        highlight: p.glassHighlight,
        highlightStrong: p.glassHighlight,
        shadow: drop(6, 2, p.shadowSolid),
        shadowStrong: drop(12, 4, p.shadowSolid),
      ),
      DoayaStyle.flat => DoayaTokens(
        surfaceStyle: SurfaceStyle.solid,
        surfaceFill: p.surface,
        surfaceFillStrong: p.surfaceRaised,
        surfaceBorder: DoayaPalette.transparent,
        surfaceBorderStrong: DoayaPalette.transparent,
        highlight: DoayaPalette.transparent,
        highlightStrong: DoayaPalette.transparent,
        shadow: const [],
        shadowStrong: const [],
      ),
      DoayaStyle.soft => DoayaTokens(
        surfaceStyle: SurfaceStyle.solid,
        surfaceFill: p.surfaceRaised,
        surfaceFillStrong: light ? p.surface : Color.lerp(p.surfaceRaised, p.textPrimary, .05)!,
        surfaceBorder: DoayaPalette.transparent,
        surfaceBorderStrong: DoayaPalette.transparent,
        highlight: DoayaPalette.transparent,
        highlightStrong: DoayaPalette.transparent,
        shadow: drop(18, 6, p.shadowStrong),
        shadowStrong: drop(30, 12, p.shadowStrong),
      ),
      DoayaStyle.outline => DoayaTokens(
        surfaceStyle: SurfaceStyle.solid,
        surfaceFill: DoayaPalette.transparent,
        surfaceFillStrong: p.subtleFill,
        surfaceBorder: p.textPrimary.withValues(alpha: .35),
        surfaceBorderStrong: p.textPrimary.withValues(alpha: .5),
        highlight: DoayaPalette.transparent,
        highlightStrong: DoayaPalette.transparent,
        shadow: const [],
        shadowStrong: const [],
        borderWidth: 1.5,
      ),
      DoayaStyle.contrast => DoayaTokens(
        surfaceStyle: SurfaceStyle.solid,
        surfaceFill: p.surface,
        surfaceFillStrong: p.surfaceRaised,
        surfaceBorder: p.textSecondary,
        surfaceBorderStrong: p.textPrimary,
        highlight: DoayaPalette.transparent,
        highlightStrong: DoayaPalette.transparent,
        shadow: const [],
        shadowStrong: const [],
        borderWidth: 2,
      ),
    };
  }

  /// Phones and web: the look's surfaces, glass allowed.
  static DoayaTokens get glass => forLook(allowBlur: true);

  /// The pharmacy desktop: the look's surfaces, never any blur.
  static DoayaTokens get solid => forLook(allowBlur: false);

  final SurfaceStyle surfaceStyle;
  final Color surfaceFill;
  final Color surfaceFillStrong;
  final Color surfaceBorder;
  final Color surfaceBorderStrong;
  final Color highlight;
  final Color highlightStrong;
  final List<BoxShadow> shadow;
  final List<BoxShadow> shadowStrong;

  /// 1 normally; thicker in the outline and high-contrast styles.
  final double borderWidth;

  /// Whether any `BackdropFilter` may be built.
  bool get blurAllowed => surfaceStyle == SurfaceStyle.glass;

  static DoayaTokens of(BuildContext context) =>
      Theme.of(context).extension<DoayaTokens>() ?? glass;

  @override
  DoayaTokens copyWith({
    SurfaceStyle? surfaceStyle,
    Color? surfaceFill,
    Color? surfaceFillStrong,
    Color? surfaceBorder,
    Color? surfaceBorderStrong,
    Color? highlight,
    Color? highlightStrong,
    List<BoxShadow>? shadow,
    List<BoxShadow>? shadowStrong,
    double? borderWidth,
  }) {
    return DoayaTokens(
      surfaceStyle: surfaceStyle ?? this.surfaceStyle,
      surfaceFill: surfaceFill ?? this.surfaceFill,
      surfaceFillStrong: surfaceFillStrong ?? this.surfaceFillStrong,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      surfaceBorderStrong: surfaceBorderStrong ?? this.surfaceBorderStrong,
      highlight: highlight ?? this.highlight,
      highlightStrong: highlightStrong ?? this.highlightStrong,
      shadow: shadow ?? this.shadow,
      shadowStrong: shadowStrong ?? this.shadowStrong,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  @override
  DoayaTokens lerp(DoayaTokens? other, double t) {
    if (other == null) return this;
    return DoayaTokens(
      surfaceStyle: t < 0.5 ? surfaceStyle : other.surfaceStyle,
      surfaceFill: Color.lerp(surfaceFill, other.surfaceFill, t)!,
      surfaceFillStrong: Color.lerp(surfaceFillStrong, other.surfaceFillStrong, t)!,
      surfaceBorder: Color.lerp(surfaceBorder, other.surfaceBorder, t)!,
      surfaceBorderStrong: Color.lerp(surfaceBorderStrong, other.surfaceBorderStrong, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      highlightStrong: Color.lerp(highlightStrong, other.highlightStrong, t)!,
      shadow: BoxShadow.lerpList(shadow, other.shadow, t)!,
      shadowStrong: BoxShadow.lerpList(shadowStrong, other.shadowStrong, t)!,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
    );
  }
}
