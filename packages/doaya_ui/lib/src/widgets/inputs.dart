import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/dimensions.dart';
import '../tokens/icons.dart';
import '../tokens/typography.dart';
import 'glass_surface.dart';

/// Full-pill glass search field with a leading search icon.
///
/// Barcode scanners act as keyboards, so [onSubmitted] fires on the scanner's
/// trailing Enter — the POS uses that.
class GlassSearchField extends StatelessWidget {
  const GlassSearchField({
    super.key,
    required this.hint,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.blur = false,
    this.trailing,
    this.textDirection,
    this.height = DoayaSizes.searchField,
    this.emphasized = false,
  });

  final String hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final bool blur;
  final Widget? trailing;

  /// Force a direction, e.g. LTR for drug-name search at the POS.
  final TextDirection? textDirection;
  final double height;

  /// Stronger tone (e.g. the always-focused POS search bar).
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      tone: emphasized ? SurfaceTone.strong : SurfaceTone.normal,
      blur: blur,
      shadow: false,
      height: height,
      borderRadius: BorderRadius.circular(DoayaRadii.pill),
      padding: const EdgeInsetsDirectional.only(start: DoayaSpacing.xl, end: DoayaSpacing.sm),
      child: Row(
        children: [
          const Icon(DoayaIcons.search, size: DoayaSizes.iconS, color: DoayaColors.textPrimary),
          const SizedBox(width: DoayaSpacing.m),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textDirection: textDirection,
              textInputAction: TextInputAction.search,
              style: DoayaTypography.bodyMedium.copyWith(height: 1.2),
              cursorColor: DoayaColors.accent,
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: DoayaTypography.bodyMedium.copyWith(
                  height: 1.2,
                  color: DoayaColors.textSecondary,
                ),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
