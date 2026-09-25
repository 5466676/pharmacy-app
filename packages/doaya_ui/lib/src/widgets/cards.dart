import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/dimensions.dart';
import '../tokens/icons.dart';
import '../tokens/typography.dart';
import 'glass_surface.dart';
import 'latin_text.dart';
import 'status.dart';

/// 54×54 category tile (radius 18) with a label underneath.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? DoayaColors.accent : DoayaColors.textPrimary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DoayaRadii.tile),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassSurface(
              tone: selected ? SurfaceTone.selected : SurfaceTone.normal,
              width: DoayaSizes.iconTile,
              height: DoayaSizes.iconTile,
              shadow: false,
              borderRadius: BorderRadius.circular(DoayaRadii.tile),
              child: Center(
                child: Icon(icon, size: DoayaSizes.iconL, color: color),
              ),
            ),
            const SizedBox(height: DoayaSpacing.s),
            Text(
              label,
              style: DoayaTypography.micro.copyWith(
                color: selected ? DoayaColors.accent : DoayaColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Product card for grids: image well, name + favourite, price.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    this.latinName = true,
    this.favorite = false,
    this.onFavorite,
    this.favoriteTooltip,
    this.onTap,
    this.status,
  });

  final Widget image;
  final String name;

  /// Pre-formatted price (Arabic digits + currency from ARB).
  final String price;

  /// Drug/brand names are Latin and render LTR.
  final bool latinName;
  final bool favorite;
  final VoidCallback? onFavorite;
  final String? favoriteTooltip;
  final VoidCallback? onTap;

  /// Optional stock chip over the image (e.g. "نفد").
  final StatusChip? status;

  @override
  Widget build(BuildContext context) {
    final nameStyle = DoayaTypography.caption.copyWith(color: DoayaColors.textPrimary);
    return GlassSurface(
      borderRadius: BorderRadius.circular(DoayaRadii.card),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(DoayaSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: DoayaSizes.productImage,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: DoayaColors.imageWell,
                          borderRadius: BorderRadius.circular(DoayaRadii.imageWell),
                        ),
                        child: Center(child: image),
                      ),
                      if (status != null)
                        PositionedDirectional(
                          top: DoayaSpacing.xs,
                          start: DoayaSpacing.xs,
                          child: status!,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: DoayaSpacing.s),
                Row(
                  children: [
                    Expanded(
                      child: latinName
                          ? LatinText(name, style: nameStyle, maxLines: 1)
                          : Text(
                              name,
                              style: nameStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    if (onFavorite != null)
                      _FavoriteButton(
                        favorite: favorite,
                        onPressed: onFavorite!,
                        tooltip: favoriteTooltip,
                      ),
                  ],
                ),
                const SizedBox(height: DoayaSpacing.xs),
                Text(price, style: DoayaTypography.priceSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.favorite, required this.onPressed, this.tooltip});

  final bool favorite;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      favorite ? DoayaIcons.heartFilled : DoayaIcons.heart,
      size: DoayaSizes.iconXs,
      color: favorite ? DoayaColors.accent : DoayaColors.textSecondary,
    );
    return Semantics(
      button: true,
      toggled: favorite,
      label: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: DoayaSizes.iconM,
        child: Padding(padding: const EdgeInsets.all(DoayaSpacing.xxs), child: icon),
      ),
    );
  }
}

/// KPI card for dashboards: icon badge, label, big number, optional caption.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.caption,
    this.tone = StatusTone.accent,
    this.onTap,
  });

  final IconData icon;
  final String label;

  /// Pre-formatted value (Arabic digits).
  final String value;
  final String? caption;
  final StatusTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconFg = tone == StatusTone.success ? DoayaColors.accent : tone.iconColor;
    return GlassSurface(
      borderRadius: BorderRadius.circular(DoayaRadii.cardLarge),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(DoayaSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassSurface(
                  tone: tone == StatusTone.success ? SurfaceTone.selected : tone.surfaceTone,
                  shadow: false,
                  width: DoayaSizes.statIcon,
                  height: DoayaSizes.statIcon,
                  borderRadius: BorderRadius.circular(DoayaSizes.statIcon / 2),
                  child: Center(
                    child: Icon(icon, size: DoayaSizes.iconS, color: iconFg),
                  ),
                ),
                const SizedBox(height: DoayaSpacing.m),
                Text(
                  label,
                  style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
                ),
                const SizedBox(height: DoayaSpacing.xs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(value, style: DoayaTypography.bigNumber, maxLines: 1),
                ),
                if (caption != null) ...[
                  const SizedBox(height: DoayaSpacing.xxs),
                  Text(caption!, style: DoayaTypography.micro.copyWith(color: iconFg)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A row in the pharmacy's AI-case inbox: initials avatar, title, subtitle,
/// optional trailing chip. [urgent] rows (red flags) use the danger tone.
class CaseRow extends StatelessWidget {
  const CaseRow({
    super.key,
    required this.initials,
    required this.title,
    required this.subtitle,
    this.urgent = false,
    this.selected = false,
    this.trailing,
    this.onTap,
  });

  final String initials;
  final String title;
  final String subtitle;
  final bool urgent;
  final bool selected;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tone = urgent
        ? SurfaceTone.danger
        : (selected ? SurfaceTone.selected : SurfaceTone.normal);
    final avatarTone = urgent ? StatusTone.danger : StatusTone.accent;
    return Semantics(
      button: onTap != null,
      selected: selected,
      child: GlassSurface(
        tone: tone,
        shadow: false,
        borderRadius: BorderRadius.circular(DoayaRadii.card),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(DoayaSpacing.ml),
              child: Row(
                children: [
                  GlassSurface(
                    tone: avatarTone.surfaceTone,
                    shadow: false,
                    width: DoayaSizes.avatar,
                    height: DoayaSizes.avatar,
                    borderRadius: BorderRadius.circular(DoayaSizes.avatar / 2),
                    child: Center(
                      child: Text(
                        initials,
                        style: DoayaTypography.caption.copyWith(
                          color: avatarTone.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DoayaSpacing.ml),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: DoayaTypography.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: DoayaSpacing.xxs),
                        Text(
                          subtitle,
                          style: DoayaTypography.caption.copyWith(
                            color: urgent ? DoayaColors.dangerText : DoayaColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[const SizedBox(width: DoayaSpacing.sm), trailing!],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
