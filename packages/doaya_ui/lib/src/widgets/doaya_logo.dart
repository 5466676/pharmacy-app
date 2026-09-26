import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/dimensions.dart';
import '../tokens/typography.dart';

/// The Doaya mark: a line-art capsule rotated −45° with a divider across the
/// middle and a small plus beside it.
///
/// [strokeWidth] is in the logo's 100×100 design units, so the line weight
/// scales with [size] (3.5 = the splash logo; 5 = heavier, for small avatars).
class DoayaLogo extends StatelessWidget {
  const DoayaLogo({
    super.key,
    this.size = DoayaSizes.logoLarge,
    this.strokeWidth = 3.5,
    this.color,
    this.showPlus = true,
    this.semanticLabel,
  });

  final double size;
  final double strokeWidth;

  /// Defaults to the accent colour.
  final Color? color;
  final bool showPlus;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final logo = CustomPaint(
      size: Size.square(size),
      painter: DoayaLogoPainter(
        strokeWidth: strokeWidth,
        // Resolved here, so a new palette repaints the logo.
        color: color ?? DoayaColors.accent,
        showPlus: showPlus,
      ),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: logo);
    return Semantics(label: semanticLabel, image: true, child: logo);
  }
}

/// Paints the Doaya mark in a square canvas. Public so it can be reused
/// (e.g. app icons or splash generation).
class DoayaLogoPainter extends CustomPainter {
  const DoayaLogoPainter({this.strokeWidth = 3.5, this.color, this.showPlus = true});

  final double strokeWidth;
  final Color? color;
  final bool showPlus;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 100;
    final paint = Paint()
      ..color = color ?? DoayaColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas
      ..save()
      ..scale(scale);

    // Capsule rotated −45° around the centre (50, 50).
    canvas
      ..save()
      ..translate(50, 50)
      ..rotate(-45 * math.pi / 180)
      ..translate(-50, -50)
      ..drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(16, 33, 68, 34), const Radius.circular(17)),
        paint,
      )
      ..drawLine(const Offset(50, 33), const Offset(50, 67), paint)
      ..restore();

    if (showPlus) {
      canvas
        ..drawLine(const Offset(61.3, 32.7), const Offset(61.3, 44.7), paint)
        ..drawLine(const Offset(55.3, 38.7), const Offset(67.3, 38.7), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(DoayaLogoPainter old) =>
      old.strokeWidth != strokeWidth || old.color != color || old.showPlus != showPlus;
}

/// Logo mark + "دوايا" wordmark in Amiri Bold. The wordmark text is passed in
/// (from the app's ARB file).
class DoayaWordmark extends StatelessWidget {
  const DoayaWordmark({
    super.key,
    required this.name,
    this.logoSize = DoayaSizes.logoSmall,
    this.textStyle,
    this.gap,
  });

  final String name;
  final double logoSize;
  final TextStyle? textStyle;
  final double? gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DoayaLogo(size: logoSize, strokeWidth: 5),
        SizedBox(width: gap ?? DoayaSpacing.sm),
        Text(name, style: textStyle ?? DoayaTypography.titleSmall),
      ],
    );
  }
}
