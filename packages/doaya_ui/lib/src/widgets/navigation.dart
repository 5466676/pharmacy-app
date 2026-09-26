import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/dimensions.dart';
import '../tokens/typography.dart';
import 'doaya_logo.dart';
import 'glass_surface.dart';

/// One destination in [FloatingBottomNav] or [DesktopShell].
class DoayaNavItem {
  const DoayaNavItem({required this.icon, required this.label, this.activeIcon, this.badge});

  final IconData icon;
  final IconData? activeIcon;
  final String label;

  /// Pre-formatted badge text (Arabic digits), e.g. pending AI cases.
  final String? badge;
}

/// Phone bottom navigation: a strong glass bar floating 14px from the screen
/// sides, radius 26, blurred. The active item gets a tinted circle.
class FloatingBottomNav extends StatelessWidget {
  const FloatingBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<DoayaNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: EdgeInsets.only(bottom: DoayaSpacing.floatingBottom),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: DoayaSpacing.floatingInset),
        child: GlassSurface(
          tone: SurfaceTone.strong,
          blur: true,
          height: DoayaSizes.bottomNav,
          borderRadius: BorderRadius.circular(DoayaRadii.bottomNav),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _BottomNavButton(
                    item: items[i],
                    active: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({required this.item, required this.active, required this.onTap});

  final DoayaNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? DoayaColors.accent : DoayaColors.textSecondary;
    final Widget icon = active
        ? Container(
            width: DoayaSizes.bottomNavActive,
            height: DoayaSizes.bottomNavActive,
            decoration: BoxDecoration(color: DoayaColors.navActiveFill, shape: BoxShape.circle),
            child: Icon(item.activeIcon ?? item.icon, size: DoayaSizes.iconS, color: color),
          )
        : Icon(item.icon, size: DoayaSizes.iconM, color: color);

    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: DoayaSizes.bottomNav / 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Badged(badge: item.badge, child: icon),
            SizedBox(height: DoayaSpacing.xs),
            Text(
              item.label,
              style: DoayaTypography.micro.copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// A group of sidebar destinations under an optional header.
class DoayaNavSection {
  const DoayaNavSection({this.title, required this.items});

  final String? title;
  final List<DoayaNavItem> items;
}

/// Desktop/web shell: sidebar (full 230px, or an 84px icon rail when
/// [compact]) on the start side, an optional top bar, and the content.
///
/// Always solid (no blur), for the pharmacy counter laptops and admin web.
class DesktopShell extends StatelessWidget {
  const DesktopShell({
    super.key,
    required this.brandName,
    required this.sections,
    required this.selectedIndex,
    required this.onSelect,
    required this.body,
    this.topBar,
    this.compact = false,
    this.sidePanel,
  });

  /// Wordmark text ("دوايا", from ARB).
  final String brandName;
  final List<DoayaNavSection> sections;

  /// Index across all sections' items, in order.
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Widget body;
  final Widget? topBar;
  final bool compact;

  /// Optional end-side panel (e.g. the POS invoice).
  final Widget? sidePanel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Sidebar(
          brandName: brandName,
          sections: sections,
          selectedIndex: selectedIndex,
          onSelect: onSelect,
          compact: compact,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(DoayaSpacing.huge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (topBar != null) ...[topBar!, SizedBox(height: DoayaSpacing.xl)],
                Expanded(child: body),
              ],
            ),
          ),
        ),
        ?sidePanel,
      ],
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.brandName,
    required this.sections,
    required this.selectedIndex,
    required this.onSelect,
    required this.compact,
  });

  final String brandName;
  final List<DoayaNavSection> sections;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Padding(
        padding: EdgeInsets.only(
          bottom: DoayaSpacing.xxl,
          right: compact ? 0 : DoayaSpacing.sm,
          left: compact ? 0 : DoayaSpacing.sm,
        ),
        child: compact
            ? const DoayaLogo(size: DoayaSizes.logoMedium, strokeWidth: 5)
            : DoayaWordmark(name: brandName),
      ),
    ];

    var index = 0;
    for (final section in sections) {
      if (!compact && section.title != null) {
        children.add(
          Padding(
            padding: EdgeInsets.fromLTRB(
              DoayaSpacing.ml,
              DoayaSpacing.l,
              DoayaSpacing.ml,
              DoayaSpacing.xs,
            ),
            child: Text(section.title!, style: DoayaTypography.sectionLabel),
          ),
        );
      } else if (compact && index > 0) {
        children.add(SizedBox(height: DoayaSpacing.sm));
      }
      for (final item in section.items) {
        final i = index++;
        children.add(
          Padding(
            padding: EdgeInsets.only(bottom: DoayaSpacing.xs),
            child: compact
                ? _RailButton(item: item, selected: i == selectedIndex, onTap: () => onSelect(i))
                : _SidebarButton(
                    item: item,
                    selected: i == selectedIndex,
                    onTap: () => onSelect(i),
                  ),
          ),
        );
      }
    }

    return Container(
      width: compact ? DoayaSizes.railWidth : DoayaSizes.sidebarWidth,
      decoration: BoxDecoration(
        color: DoayaColors.surface,
        border: BorderDirectional(
          end: BorderSide(color: DoayaColors.border, width: DoayaSizes.borderWidth),
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: DoayaSpacing.giant,
        horizontal: compact ? 0 : DoayaSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: compact ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  const _SidebarButton({required this.item, required this.selected, required this.onTap});

  final DoayaNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? DoayaColors.accent : DoayaColors.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Ink(
            height: DoayaSizes.sidebarItem,
            decoration: BoxDecoration(
              color: selected ? DoayaColors.selectedTileFill : DoayaColors.transparent,
              borderRadius: BorderRadius.circular(DoayaRadii.pill),
              border: Border.all(
                color: selected ? DoayaColors.selectedTileBorder : DoayaColors.transparent,
                width: DoayaSizes.borderWidth,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: DoayaSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: DoayaSizes.sidebarIcon,
                  height: DoayaSizes.sidebarIcon,
                  decoration: BoxDecoration(
                    color: selected ? DoayaColors.accent : DoayaColors.surfaceRaised,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.activeIcon != null && selected ? item.activeIcon : item.icon,
                    size: DoayaSizes.iconSidebar,
                    color: selected ? DoayaColors.onSage : DoayaColors.textSecondary,
                  ),
                ),
                SizedBox(width: DoayaSpacing.m),
                Expanded(
                  child: Text(
                    item.label,
                    style: DoayaTypography.bodyMedium.copyWith(color: fg, height: 1.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.badge != null) _BadgePill(text: item.badge!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({required this.item, required this.selected, required this.onTap});

  final DoayaNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: item.label,
      child: Semantics(
        button: true,
        selected: selected,
        label: item.label,
        excludeSemantics: true,
        child: _Badged(
          badge: item.badge,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Ink(
                width: DoayaSizes.railButton,
                height: DoayaSizes.railButton,
                decoration: BoxDecoration(
                  color: selected ? DoayaColors.accent : DoayaColors.surfaceRaised,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  size: DoayaSizes.iconM,
                  color: selected ? DoayaColors.onSage : DoayaColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Puts a small accent badge on the top-end corner (top-left in RTL, as in
/// the mockups).
class _Badged extends StatelessWidget {
  const _Badged({required this.badge, required this.child});

  final String? badge;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (badge == null) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        PositionedDirectional(
          top: -DoayaSpacing.xs,
          end: -DoayaSpacing.xs,
          child: Container(
            constraints: const BoxConstraints(minWidth: DoayaSizes.badge),
            height: DoayaSizes.badge,
            padding: EdgeInsets.symmetric(horizontal: DoayaSpacing.xs),
            decoration: BoxDecoration(
              color: DoayaColors.accent,
              borderRadius: BorderRadius.circular(DoayaRadii.pill),
            ),
            alignment: Alignment.center,
            child: Text(badge!, style: DoayaTypography.badge),
          ),
        ),
      ],
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: DoayaSpacing.sm, vertical: DoayaSpacing.xxs),
      decoration: BoxDecoration(
        color: DoayaColors.accent,
        borderRadius: BorderRadius.circular(DoayaRadii.pill),
      ),
      child: Text(text, style: DoayaTypography.micro.copyWith(color: DoayaColors.onSage)),
    );
  }
}
