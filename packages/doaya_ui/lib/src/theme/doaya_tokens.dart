import 'package:flutter/material.dart';

import '../tokens/colors.dart';

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
  });

  static const glass = DoayaTokens(
    surfaceStyle: SurfaceStyle.glass,
    surfaceFill: DoayaColors.glassFill,
    surfaceFillStrong: DoayaColors.glassFillStrong,
    surfaceBorder: DoayaColors.glassBorder,
    surfaceBorderStrong: DoayaColors.glassBorderStrong,
    highlight: DoayaColors.glassHighlight,
    highlightStrong: DoayaColors.glassHighlightStrong,
    shadow: [BoxShadow(color: DoayaColors.shadow, offset: Offset(0, 10), blurRadius: 30)],
    shadowStrong: [
      BoxShadow(color: DoayaColors.shadowStrong, offset: Offset(0, 16), blurRadius: 40),
    ],
  );

  static const solid = DoayaTokens(
    surfaceStyle: SurfaceStyle.solid,
    surfaceFill: DoayaColors.surface,
    surfaceFillStrong: DoayaColors.surfaceRaised,
    surfaceBorder: DoayaColors.border,
    surfaceBorderStrong: DoayaColors.border,
    highlight: DoayaColors.glassHighlight,
    highlightStrong: DoayaColors.glassHighlight,
    shadow: [BoxShadow(color: DoayaColors.shadowSolid, offset: Offset(0, 2), blurRadius: 6)],
    shadowStrong: [BoxShadow(color: DoayaColors.shadowSolid, offset: Offset(0, 4), blurRadius: 12)],
  );

  final SurfaceStyle surfaceStyle;
  final Color surfaceFill;
  final Color surfaceFillStrong;
  final Color surfaceBorder;
  final Color surfaceBorderStrong;
  final Color highlight;
  final Color highlightStrong;
  final List<BoxShadow> shadow;
  final List<BoxShadow> shadowStrong;

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
    );
  }
}
