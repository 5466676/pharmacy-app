import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/doaya_appearance.dart';
import '../theme/doaya_look.dart';
import '../tokens/colors.dart';
import '../tokens/dimensions.dart';

/// The Doaya screen background: vertical sage-green gradient, two large soft
/// blobs and faint blurred leaves. Optionally a blurred photo on top (e.g.
/// `AssetImage('assets/bg/leaves.jpg')`); if the photo is null or fails to
/// load, the gradient shows through.
///
/// Painted once into a [RepaintBoundary]; cheap enough for old laptops.
class DoayaBackground extends StatelessWidget {
  const DoayaBackground({super.key, this.child, this.photo, this.leaves = true});

  final Widget? child;
  final ImageProvider? photo;

  /// Draw the blurred leaf shapes (on by default).
  final bool leaves;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: _BackgroundPainter(
              leaves: leaves,
              palette: DoayaAppearance.palette,
              // Only the glass style has the blobs and leaves; the others are plain.
              plain: DoayaAppearance.look.style != DoayaStyle.glass,
            ),
          ),
        ),
        if (photo != null)
          RepaintBoundary(
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(
                sigmaX: DoayaBlur.photo,
                sigmaY: DoayaBlur.photo,
                tileMode: TileMode.decal,
              ),
              child: Image(
                image: photo!,
                fit: BoxFit.cover,
                color: DoayaColors.photoScrim,
                colorBlendMode: BlendMode.srcATop,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
        ?child,
      ],
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  _BackgroundPainter({required this.leaves, required this.palette, required this.plain});

  final bool leaves;
  final DoayaPalette palette;
  final bool plain;

  // Leaf outline in a 100×200 box (from the mockups).
  static final _leafPath = Path()
    ..moveTo(50, 0)
    ..cubicTo(95, 50, 95, 150, 50, 200)
    ..cubicTo(5, 150, 5, 50, 50, 0)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (plain) {
      canvas.drawRect(rect, Paint()..color = DoayaColors.bgMid);
      return;
    }

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [DoayaColors.bgTop, DoayaColors.bgMid, DoayaColors.bgBottom],
          stops: [0, 0.55, 1],
        ).createShader(rect),
    );

    // Blobs: CSS 420px circle at (-160, -140) with blur(80px), and
    // 380px circle at (right -140, bottom -120). A radial gradient that
    // reaches 50% at the original radius and 0 at radius + 2σ matches it.
    _blob(
      canvas,
      center: const Offset(-160 + 210, -140 + 210),
      radius: 210,
      color: DoayaColors.blobLight.withValues(alpha: DoayaOpacity.blobLight),
    );
    _blob(
      canvas,
      center: Offset(size.width + 140 - 190, size.height + 120 - 190),
      radius: 190,
      color: DoayaColors.blobDark.withValues(alpha: DoayaOpacity.blobDark),
    );

    if (!leaves) return;
    // Near leaf: right -70, top 90, 280×520, rotate 18°, blur 4, opacity .5.
    _leaf(
      canvas,
      box: Rect.fromLTWH(size.width + 70 - 280, 90, 280, 520),
      degrees: 18,
      sigma: DoayaBlur.leafNear,
      opacity: DoayaOpacity.leafNear,
      fill: DoayaColors.leafFillA,
      vein: DoayaColors.leafVeinA,
    );
    // Far leaf: left -90, bottom 60, 260×480, rotate −30°, blur 6, opacity .45.
    _leaf(
      canvas,
      box: Rect.fromLTWH(-90, size.height - 60 - 480, 260, 480),
      degrees: -30,
      sigma: DoayaBlur.leafFar,
      opacity: DoayaOpacity.leafFar,
      fill: DoayaColors.leafFillB,
      vein: DoayaColors.leafVeinB,
    );
  }

  void _blob(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    const sigma = 80.0;
    final outer = radius + 2 * sigma;
    final half = color.withValues(alpha: color.a * 0.5);
    canvas.drawCircle(
      center,
      outer,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color, half, color.withValues(alpha: 0)],
          stops: [0, (radius - sigma) / outer, radius / outer, 1],
        ).createShader(Rect.fromCircle(center: center, radius: outer)),
    );
  }

  void _leaf(
    Canvas canvas, {
    required Rect box,
    required double degrees,
    required double sigma,
    required double opacity,
    required Color fill,
    required Color vein,
  }) {
    final sx = box.width / 100;
    final sy = box.height / 200;
    final blur = MaskFilter.blur(BlurStyle.normal, sigma / sx);
    canvas
      ..save()
      ..translate(box.center.dx, box.center.dy)
      ..rotate(degrees * 3.1415926535 / 180)
      ..translate(-box.width / 2, -box.height / 2)
      ..scale(sx, sy);
    canvas.drawPath(
      _leafPath,
      Paint()
        ..color = fill.withValues(alpha: opacity)
        ..maskFilter = blur,
    );
    canvas.drawLine(
      const Offset(50, 12),
      const Offset(50, 188),
      Paint()
        ..color = vein.withValues(alpha: opacity)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke
        ..maskFilter = blur,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) =>
      old.leaves != leaves || !identical(old.palette, palette) || old.plain != plain;
}
