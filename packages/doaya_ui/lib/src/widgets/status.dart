import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/dimensions.dart';
import '../tokens/icons.dart';
import '../tokens/typography.dart';
import 'glass_surface.dart';

/// Semantic tone for chips, notices and stat cards.
enum StatusTone {
  /// Plain glass.
  neutral,

  /// Accent-tinted (info, AI cases).
  accent,

  /// Solid accent pill with `onSage` text: "ready", "delivered ✓".
  success,

  /// Low stock, near expiry, safety note.
  warning,

  /// Out of stock, red flag, urgent.
  danger,
}

extension StatusToneColors on StatusTone {
  Color get foreground => switch (this) {
    StatusTone.neutral => DoayaColors.textSecondary,
    StatusTone.accent => DoayaColors.accent,
    StatusTone.success => DoayaColors.onSage,
    StatusTone.warning => DoayaColors.warningText,
    StatusTone.danger => DoayaColors.dangerText,
  };

  Color get iconColor => switch (this) {
    StatusTone.warning => DoayaColors.warningIcon,
    _ => foreground,
  };

  SurfaceTone get surfaceTone => switch (this) {
    StatusTone.neutral => SurfaceTone.normal,
    StatusTone.accent => SurfaceTone.accentSoft,
    StatusTone.success => SurfaceTone.selected,
    StatusTone.warning => SurfaceTone.warning,
    StatusTone.danger => SurfaceTone.danger,
  };
}

/// Small pill label: stock state, case state, payment type, sync state.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
    this.dot = false,
    this.icon,
  });

  final String label;
  final StatusTone tone;

  /// Leading glowing dot (e.g. "online", "synced").
  final bool dot;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = tone.foreground;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dot) ...[const StatusDot(), const SizedBox(width: DoayaSpacing.s)],
        if (icon != null) ...[
          Icon(icon, size: DoayaSizes.iconXs, color: tone.iconColor),
          const SizedBox(width: DoayaSpacing.xs),
        ],
        Flexible(
          child: Text(
            label,
            style: DoayaTypography.caption.copyWith(color: fg, height: 1.3),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
    const padding = EdgeInsets.symmetric(horizontal: DoayaSpacing.ml, vertical: DoayaSpacing.xs);

    if (tone == StatusTone.success) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: DoayaColors.accent,
          borderRadius: BorderRadius.circular(DoayaRadii.pill),
        ),
        child: Padding(padding: padding, child: content),
      );
    }
    return GlassSurface(
      tone: tone.surfaceTone,
      shadow: false,
      borderRadius: BorderRadius.circular(DoayaRadii.pill),
      padding: padding,
      child: content,
    );
  }
}

/// 7px glowing status dot (online / synced / ready).
class StatusDot extends StatelessWidget {
  const StatusDot({super.key, this.color = DoayaColors.successDot});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DoayaSizes.statusDot,
      height: DoayaSizes.statusDot,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: DoayaSpacing.sm)],
      ),
    );
  }
}

/// Inline notice panel with an icon: safety notes, emergency messages.
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({
    super.key,
    required this.message,
    this.tone = StatusTone.warning,
    this.icon,
    this.action,
  });

  final String message;
  final StatusTone tone;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      tone: tone.surfaceTone,
      shadow: false,
      borderRadius: BorderRadius.circular(DoayaRadii.tile),
      padding: const EdgeInsets.symmetric(horizontal: DoayaSpacing.l, vertical: DoayaSpacing.ml),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: DoayaSpacing.xxs),
                  child: Icon(icon, size: DoayaSizes.iconS, color: tone.iconColor),
                ),
                const SizedBox(width: DoayaSpacing.m),
              ],
              Expanded(
                child: Text(
                  message,
                  style: DoayaTypography.bodySmall.copyWith(color: tone.foreground, height: 1.6),
                ),
              ),
            ],
          ),
          if (action != null) ...[const SizedBox(height: DoayaSpacing.m), action!],
        ],
      ),
    );
  }
}

/// Section title with an optional trailing link ("الكل" + arrow).
///
/// Arrows/checkmarks are drawn as icons, never as text glyphs: the bundled
/// fonts don't contain them, and Flutter web would try to fetch a fallback
/// font from Google's CDN.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final linkStyle = DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary);
    return Row(
      children: [
        Expanded(child: Text(title, style: DoayaTypography.lead)),
        if (actionLabel != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(DoayaRadii.key),
            child: Padding(
              padding: const EdgeInsets.all(DoayaSpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(actionLabel!, style: linkStyle),
                  const SizedBox(width: DoayaSpacing.xs),
                  const Icon(
                    DoayaIcons.forward,
                    size: DoayaSizes.iconXs,
                    color: DoayaColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
