import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/dimensions.dart';
import '../tokens/typography.dart';
import 'glass_surface.dart';
import 'painters.dart';

/// Button sizes shared by the pill buttons.
enum PillSize {
  /// 38px — inline actions (hero CTA, chat quick replies, chips).
  small(DoayaSizes.buttonSmall, DoayaSpacing.xxl),

  /// 48px — POS actions, compact forms.
  medium(DoayaSizes.buttonMedium, DoayaSpacing.xxxl),

  /// 56px — primary screen action.
  large(DoayaSizes.buttonLarge, DoayaSpacing.huge);

  const PillSize(this.height, this.horizontalPadding);
  final double height;
  final double horizontalPadding;

  TextStyle get textStyle =>
      this == PillSize.small ? DoayaTypography.buttonSmall : DoayaTypography.button;
}

/// Where the icon of a pill button goes relative to the label.
enum PillIconLayout {
  /// Icon right after the label, both centred.
  inline,

  /// Label at the start edge, icon pushed to the end edge (splash / order CTA).
  spread,
}

/// Primary action: full pill with the sage gradient, `onSage` text and a soft
/// shadow.
class SagePillButton extends StatelessWidget {
  const SagePillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.size = PillSize.large,
    this.expand = false,
    this.iconLayout = PillIconLayout.inline,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final PillSize size;
  final bool expand;
  final PillIconLayout iconLayout;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final style = size.textStyle.copyWith(color: DoayaColors.onSage);
    final radius = BorderRadius.circular(DoayaRadii.pill);

    final text = Text(label, style: style, overflow: TextOverflow.ellipsis);
    final iconWidget = icon == null
        ? null
        : Icon(icon, size: DoayaSizes.iconM, color: DoayaColors.onSage);
    final spread = iconWidget != null && iconLayout == PillIconLayout.spread;
    final children = <Widget>[
      if (spread) Expanded(child: text) else Flexible(child: text),
      if (iconWidget != null) ...[if (!spread) const SizedBox(width: DoayaSpacing.m), iconWidget],
    ];

    final button = Container(
      height: size.height,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: enabled
            ? const [
                BoxShadow(color: DoayaColors.shadowStrong, offset: Offset(0, 8), blurRadius: 20),
              ]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [DoayaColors.sageTop, DoayaColors.sageBottom],
            ),
          ),
          child: CustomPaint(
            foregroundPainter: TopHighlightPainter(
              borderRadius: radius,
              color: DoayaColors.sageHighlight,
              inset: 0,
            ),
            child: InkWell(
              onTap: onPressed,
              customBorder: const StadiumBorder(),
              splashColor: DoayaColors.sagePressed,
              highlightColor: DoayaColors.sageHover,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.horizontalPadding),
                child: Row(
                  mainAxisSize: expand || spread ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      child: Opacity(opacity: enabled ? 1 : DoayaOpacity.disabled, child: button),
    );
  }
}

/// Secondary action: full-pill glass (no blur). Set [selected] for toggle
/// groups and segmented controls.
class GlassPillButton extends StatelessWidget {
  const GlassPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.size = PillSize.small,
    this.selected = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final PillSize size;
  final bool selected;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = selected ? DoayaColors.accent : DoayaColors.textPrimary;
    const radius = BorderRadius.all(Radius.circular(DoayaRadii.pill));

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : DoayaOpacity.disabled,
        child: GlassSurface(
          tone: selected ? SurfaceTone.selected : SurfaceTone.normal,
          borderRadius: radius,
          shadow: false,
          height: size.height,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPressed,
              customBorder: const StadiumBorder(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.horizontalPadding),
                child: Row(
                  mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: DoayaSizes.iconS, color: color),
                      const SizedBox(width: DoayaSpacing.sm),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        style: size.textStyle.copyWith(color: color, fontWeight: FontWeight.w400),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 44px round glass icon button (back, favourite, share…).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = DoayaSizes.roundButton,
    this.iconColor = DoayaColors.textPrimary,
    this.tone = SurfaceTone.normal,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  /// Accessibility label (from ARB).
  final String tooltip;
  final double size;
  final Color iconColor;
  final SurfaceTone tone;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GlassSurface(
        tone: tone,
        width: size,
        height: size,
        shadow: false,
        borderRadius: BorderRadius.circular(size / 2),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Center(
              child: Icon(icon, size: DoayaSizes.iconS, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
