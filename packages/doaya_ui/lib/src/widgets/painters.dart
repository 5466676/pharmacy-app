import 'package:flutter/widgets.dart';

import '../tokens/dimensions.dart';

/// CSS `inset 0 1px 0 <color>`: a 1px band along the inner top edge that
/// follows the corner curve.
class TopHighlightPainter extends CustomPainter {
  TopHighlightPainter({
    required this.borderRadius,
    required this.color,
    this.inset = DoayaSizes.borderWidth,
  });

  final BorderRadius borderRadius;
  final Color color;

  /// Distance from the outer edge (the border width, or 0 for borderless).
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    if (color.a == 0) return;
    final outer = borderRadius.toRRect(Offset.zero & size).deflate(inset);
    final shifted = outer.shift(const Offset(0, DoayaSizes.borderWidth));
    final band = Path.combine(
      PathOperation.difference,
      Path()..addRRect(outer),
      Path()..addRRect(shifted),
    );
    canvas.drawPath(band, Paint()..color = color);
  }

  @override
  bool shouldRepaint(TopHighlightPainter old) =>
      old.color != color || old.borderRadius != borderRadius || old.inset != inset;
}

/// Box shadow painted only *outside* the shape, like CSS `box-shadow`.
/// A normal [BoxShadow] would darken the area behind a translucent fill.
class OuterShadowPainter extends CustomPainter {
  OuterShadowPainter({required this.borderRadius, required this.shadows});

  final BorderRadius borderRadius;
  final List<BoxShadow> shadows;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = borderRadius.toRRect(Offset.zero & size);
    final bounds = (Offset.zero & size).inflate(200);
    canvas
      ..save()
      ..clipPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(bounds)
          ..addRRect(rrect),
      );
    for (final s in shadows) {
      final paint = s.toPaint();
      canvas.drawRRect(rrect.shift(s.offset).inflate(s.spreadRadius), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(OuterShadowPainter old) =>
      old.borderRadius != borderRadius || old.shadows != shadows;
}
