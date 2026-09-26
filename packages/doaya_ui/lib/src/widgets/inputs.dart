import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/doaya_tokens.dart';

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
      padding: EdgeInsetsDirectional.only(start: DoayaSpacing.xl, end: DoayaSpacing.sm),
      child: Row(
        children: [
          Icon(DoayaIcons.search, size: DoayaSizes.iconS, color: DoayaColors.textPrimary),
          SizedBox(width: DoayaSpacing.m),
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

/// Labelled form field on a glass surface (radius 18). Validation errors show
/// under it in the danger tone.
class GlassTextField extends StatelessWidget {
  const GlassTextField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.hint,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textDirection,
    this.obscureText = false,
    this.autofocus = false,
    this.maxLength,
    this.maxLines = 1,
    this.inputFormatters,
    this.textInputAction,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final bool obscureText;
  final bool autofocus;
  final int? maxLength;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final tokens = DoayaTokens.of(context);
    // A field always shows its edge: in the flat style surfaces have none,
    // and a field would vanish into the card it sits on.
    final edge = tokens.surfaceBorder.a == 0 ? DoayaColors.border : tokens.surfaceBorder;
    OutlineInputBorder border(Color c, [double w = DoayaSizes.borderWidth]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(DoayaRadii.tile),
      borderSide: BorderSide(color: c, width: w),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: DoayaSpacing.xs, bottom: DoayaSpacing.s),
          child: Text(
            label,
            style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
          ),
        ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          keyboardType: keyboardType,
          textDirection: textDirection,
          obscureText: obscureText,
          autofocus: autofocus,
          maxLength: maxLength,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          style: DoayaTypography.bodyMedium.copyWith(height: 1.3),
          cursorColor: DoayaColors.accent,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: DoayaTypography.bodyMedium.copyWith(
              height: 1.3,
              color: DoayaColors.textSecondary,
            ),
            counterText: '',
            filled: true,
            fillColor: tokens.surfaceFill,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: DoayaSpacing.xl,
              vertical: DoayaSpacing.l,
            ),
            border: border(edge),
            enabledBorder: border(edge),
            focusedBorder: border(DoayaColors.accent, DoayaSizes.focusWidth),
            errorBorder: border(DoayaColors.dangerBorder),
            focusedErrorBorder: border(DoayaColors.dangerText, DoayaSizes.focusWidth),
            errorStyle: DoayaTypography.caption.copyWith(color: DoayaColors.dangerText),
          ),
        ),
      ],
    );
  }
}
