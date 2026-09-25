import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/doaya_tokens.dart';
import '../tokens/colors.dart';
import '../tokens/dimensions.dart';
import 'painters.dart';

/// Visual tone of a [GlassSurface].
enum SurfaceTone {
  /// Standard glass (`glassFill`) / `surface` in solid mode.
  normal,

  /// Hero cards, sheets, nav (`glassFillStrong`) / `surfaceRaised` in solid mode.
  strong,

  /// Active category tile / selected row.
  selected,

  /// Soft accent panel (e.g. the case summary inside a chat bubble).
  accentSoft,

  /// Low stock, near expiry, safety notes.
  warning,

  /// Out of stock, red-flag cases.
  danger,
}

/// The single building block for every glass or solid surface in Doaya:
/// translucent fill + 1px border + 1px inner top highlight + soft outer shadow,
/// and optionally a `BackdropFilter` blur.
///
/// Blur is only applied when [blur] is true **and** the theme allows it
/// (`DoayaTokens.surfaceStyle == SurfaceStyle.glass`). Use blur only for large
/// surfaces (hero, sheet, bottom nav, input bar, dialog) — max ~3 per screen.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    this.child,
    this.tone = SurfaceTone.normal,
    this.blur = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(DoayaRadii.card)),
    this.padding,
    this.width,
    this.height,
    this.shadow = true,
    this.fill,
  });

  final Widget? child;
  final SurfaceTone tone;
  final bool blur;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool shadow;

  /// Overrides the tone's fill (rare; e.g. a button's pressed state).
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    final tokens = DoayaTokens.of(context);
    final style = _resolve(tokens);
    final useBlur = blur && tokens.blurAllowed;
    final sigma = tone == SurfaceTone.strong ? DoayaBlur.glassStrong : DoayaBlur.glass;

    Widget content = CustomPaint(
      foregroundPainter: TopHighlightPainter(borderRadius: borderRadius, color: style.highlight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill ?? style.fill,
          borderRadius: borderRadius,
          border: Border.all(color: style.border, width: DoayaSizes.borderWidth),
        ),
        child: padding == null ? child : Padding(padding: padding!, child: child),
      ),
    );

    if (useBlur) {
      content = BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: content,
      );
    }

    content = ClipRRect(borderRadius: borderRadius, child: content);

    if (shadow && style.shadow.isNotEmpty) {
      content = CustomPaint(
        painter: OuterShadowPainter(borderRadius: borderRadius, shadows: style.shadow),
        child: content,
      );
    }

    if (width != null || height != null) {
      content = SizedBox(width: width, height: height, child: content);
    }
    return content;
  }

  _SurfaceStyle _resolve(DoayaTokens t) {
    return switch (tone) {
      SurfaceTone.normal => _SurfaceStyle(t.surfaceFill, t.surfaceBorder, t.highlight, t.shadow),
      SurfaceTone.strong => _SurfaceStyle(
        t.surfaceFillStrong,
        t.surfaceBorderStrong,
        t.highlightStrong,
        t.shadowStrong,
      ),
      SurfaceTone.selected => _SurfaceStyle(
        DoayaColors.selectedTileFill,
        DoayaColors.selectedTileBorder,
        t.highlightStrong,
        t.shadow,
      ),
      SurfaceTone.accentSoft => const _SurfaceStyle(
        DoayaColors.accentSoftFill,
        DoayaColors.accentSoftBorder,
        DoayaColors.transparent,
        [],
      ),
      SurfaceTone.warning => const _SurfaceStyle(
        DoayaColors.warningFill,
        DoayaColors.warningBorder,
        DoayaColors.transparent,
        [],
      ),
      SurfaceTone.danger => const _SurfaceStyle(
        DoayaColors.dangerFill,
        DoayaColors.dangerBorder,
        DoayaColors.transparent,
        [],
      ),
    };
  }
}

class _SurfaceStyle {
  const _SurfaceStyle(this.fill, this.border, this.highlight, this.shadow);
  final Color fill;
  final Color border;
  final Color highlight;
  final List<BoxShadow> shadow;
}
