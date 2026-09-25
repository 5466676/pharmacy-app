import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/dimensions.dart';
import '../tokens/typography.dart';
import 'glass_surface.dart';

/// Shows a Doaya dialog: strong glass sheet (blurred on glass themes, solid on
/// the desktop theme) with a title, content and actions.
Future<T?> showDoayaDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  List<Widget> actions = const [],
  double maxWidth = DoayaSizes.dialogWidth,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: DoayaColors.scrim,
    builder: (context) => Dialog(
      backgroundColor: DoayaColors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(DoayaSpacing.huge),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: GlassSurface(
          tone: SurfaceTone.strong,
          blur: true,
          borderRadius: BorderRadius.circular(DoayaRadii.hero),
          padding: const EdgeInsets.all(DoayaSpacing.huge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: DoayaTypography.titleSmall),
              const SizedBox(height: DoayaSpacing.xl),
              Flexible(child: SingleChildScrollView(child: content)),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: DoayaSpacing.xxl),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: DoayaSpacing.m,
                  runSpacing: DoayaSpacing.m,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
