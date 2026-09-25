import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';

import 'desktop_demo.dart';
import 'l10n/app_localizations.dart';

/// Phone-style gallery of every `doaya_ui` component.
class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key, required this.style, required this.onStyleChanged});

  final SurfaceStyle style;
  final ValueChanged<SurfaceStyle> onStyleChanged;

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  var _navIndex = 0;
  var _category = 0;
  var _reply = 0;
  final _favorites = <int>{0};

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      extendBody: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DoayaSizes.phoneMaxWidth),
          child: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                DoayaSpacing.screenGutter,
                DoayaSpacing.sm,
                DoayaSpacing.screenGutter,
                DoayaSizes.bottomNav + DoayaSpacing.floatingBottom * 3,
              ),
              children: [
                _topBar(l),
                _gap,
                _hero(l),
                _gap,
                _Section(title: l.sectionColors, child: const _ColorSwatches()),
                _Section(title: l.sectionTypography, child: _typography(l)),
                _Section(title: l.sectionLogo, child: _logos()),
                _Section(title: l.sectionButtons, child: _buttons(l)),
                _Section(title: l.sectionInputs, child: _inputs(l)),
                _Section(title: l.sectionTiles, child: _tiles(l)),
                _Section(title: l.sectionProducts, action: l.seeAll, child: _products(l)),
                _Section(title: l.sectionStats, child: _stats(l)),
                _Section(title: l.sectionChips, child: _chips(l)),
                _Section(title: l.sectionNotices, child: _notices(l)),
                _Section(title: l.sectionCases, child: _cases(l)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: DoayaSizes.phoneMaxWidth),
          child: FloatingBottomNav(
            currentIndex: _navIndex,
            onTap: (i) => setState(() => _navIndex = i),
            items: [
              DoayaNavItem(
                icon: DoayaIcons.homeOutlined,
                activeIcon: DoayaIcons.home,
                label: l.navHome,
              ),
              DoayaNavItem(
                icon: DoayaIcons.chat,
                activeIcon: DoayaIcons.chatFilled,
                label: l.navConsult,
              ),
              DoayaNavItem(icon: DoayaIcons.clock, label: l.navDoses),
              DoayaNavItem(icon: DoayaIcons.bag, label: l.navOrders, badge: formatNumber(2)),
              DoayaNavItem(
                icon: DoayaIcons.person,
                activeIcon: DoayaIcons.personFilled,
                label: l.navAccount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _gap = SizedBox(height: DoayaSpacing.xl);

  Widget _topBar(AppLocalizations l) {
    return Row(
      children: [
        DoayaWordmark(name: l.appName, textStyle: DoayaTypography.title),
        const Spacer(),
        GlassPillButton(
          label: l.modeGlass,
          selected: widget.style == SurfaceStyle.glass,
          onPressed: () => widget.onStyleChanged(SurfaceStyle.glass),
        ),
        const SizedBox(width: DoayaSpacing.s),
        GlassPillButton(
          label: l.modeSolid,
          selected: widget.style == SurfaceStyle.solid,
          onPressed: () => widget.onStyleChanged(SurfaceStyle.solid),
        ),
      ],
    );
  }

  Widget _hero(AppLocalizations l) {
    return Column(
      children: [
        GlassSurface(
          tone: SurfaceTone.strong,
          blur: true,
          borderRadius: BorderRadius.circular(DoayaRadii.hero),
          padding: const EdgeInsets.symmetric(
            horizontal: DoayaSpacing.xxxl,
            vertical: DoayaSpacing.huge,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.heroTitle, style: DoayaTypography.displayLarge),
                    const SizedBox(height: DoayaSpacing.m),
                    Text(
                      l.heroBody,
                      style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
                    ),
                    const SizedBox(height: DoayaSpacing.m),
                    SagePillButton(
                      label: l.startConsultation,
                      size: PillSize.small,
                      onPressed: () => setState(() => _navIndex = 1),
                    ),
                  ],
                ),
              ),
              const DoayaLogo(size: DoayaSizes.logoHero, strokeWidth: 3),
            ],
          ),
        ),
        const SizedBox(height: DoayaSpacing.ml),
        OutlinedButton(
          onPressed: () =>
              Navigator.of(context)
                  .push(MaterialPageRoute<void>(builder: (_) => const DesktopDemo())),
          style: OutlinedButton.styleFrom(
            foregroundColor: DoayaColors.accent,
            side: const BorderSide(color: DoayaColors.accentSoftBorder),
            shape: const StadiumBorder(),
          ),
          child: Text(l.openDesktop),
        ),
      ],
    );
  }

  Widget _typography(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.appName, style: DoayaTypography.wordmark),
        Text(l.typeDisplay, style: DoayaTypography.title),
        Text(l.price(formatNumber(12500)), style: DoayaTypography.price),
        const SizedBox(height: DoayaSpacing.sm),
        Text(l.typeBody, style: DoayaTypography.body),
        for (final w in const [FontWeight.w300, FontWeight.w400, FontWeight.w500, FontWeight.w600])
          Text(
            l.typeWeight(formatNumber(w.value)),
            style: DoayaTypography.bodyMedium.copyWith(fontWeight: w),
          ),
        LatinText('Amoxicillin 500 mg · 16 caps', style: DoayaTypography.body),
      ],
    );
  }

  Widget _logos() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        DoayaLogo(size: DoayaSizes.logoLarge),
        DoayaLogo(size: DoayaSizes.logoLarge, strokeWidth: 6),
        DoayaLogo(size: DoayaSizes.logoMedium, strokeWidth: 5),
        DoayaLogo(size: DoayaSizes.logoSmall, strokeWidth: 5, showPlus: false),
      ],
    );
  }

  Widget _buttons(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SagePillButton(
          label: l.letsGo,
          icon: DoayaIcons.forward,
          expand: true,
          iconLayout: PillIconLayout.spread,
          onPressed: () {},
        ),
        _smallGap,
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SagePillButton(
            label: l.orderFromMyPharmacy,
            icon: DoayaIcons.bag,
            onPressed: () {},
          ),
        ),
        _smallGap,
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SagePillButton(label: l.disabled, size: PillSize.medium, onPressed: null),
        ),
        _smallGap,
        Wrap(
          spacing: DoayaSpacing.sm,
          runSpacing: DoayaSpacing.sm,
          children: [
            GlassPillButton(
              label: l.replyNothing,
              selected: _reply == 1,
              onPressed: () => setState(() => _reply = 1),
            ),
            GlassPillButton(
              label: l.replyAllergy,
              selected: _reply == 2,
              onPressed: () => setState(() => _reply = 2),
            ),
          ],
        ),
        _smallGap,
        Row(
          children: [
            RoundIconButton(icon: DoayaIcons.back, tooltip: l.back, onPressed: () {}),
            const Spacer(),
            RoundIconButton(icon: DoayaIcons.heart, tooltip: l.favorite, onPressed: () {}),
            const SizedBox(width: DoayaSpacing.sm),
            RoundIconButton(icon: DoayaIcons.share, tooltip: l.share, onPressed: () {}),
          ],
        ),
      ],
    );
  }

  Widget _inputs(AppLocalizations l) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: GlassSearchField(hint: l.searchHint)),
            const SizedBox(width: DoayaSpacing.m),
            RoundIconButton(
              icon: DoayaIcons.filter,
              tooltip: l.filter,
              size: DoayaSizes.searchField,
              onPressed: () {},
            ),
          ],
        ),
        _smallGap,
        GlassSearchField(
          hint: l.posSearchHint,
          emphasized: true,
          height: DoayaSizes.inputBar,
          textDirection: TextDirection.ltr,
          trailing: const Padding(
            padding: EdgeInsetsDirectional.only(end: DoayaSpacing.sm),
            child: Icon(DoayaIcons.barcode, color: DoayaColors.accent),
          ),
        ),
      ],
    );
  }

  Widget _tiles(AppLocalizations l) {
    final cats = [
      (DoayaIcons.medicine, l.catMedicine),
      (DoayaIcons.health, l.catHealth),
      (DoayaIcons.care, l.catCare),
      (DoayaIcons.baby, l.catKids),
      (DoayaIcons.device, l.catDevices),
    ];
    return Row(
      children: [
        for (var i = 0; i < cats.length; i++)
          Expanded(
            child: IconTile(
              icon: cats[i].$1,
              label: cats[i].$2,
              selected: i == _category,
              onTap: () => setState(() => _category = i),
            ),
          ),
      ],
    );
  }

  Widget _products(AppLocalizations l) {
    final items = [
      ('Omega 3', true, 45000, null),
      ('Vitamin D3', true, 28000, null),
      (l.skinWash, false, 36500, StatusChip(label: l.chipOut, tone: StatusTone.danger)),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: DoayaSpacing.m),
          Expanded(
            child: ProductCard(
              image: const Icon(
                DoayaIcons.medicine,
                size: DoayaSizes.productIcon,
                color: DoayaColors.sageBottom,
              ),
              name: items[i].$1,
              latinName: items[i].$2,
              price: l.price(formatNumber(items[i].$3)),
              status: items[i].$4,
              favorite: _favorites.contains(i),
              favoriteTooltip: l.favorite,
              onFavorite: () =>
                  setState(() => _favorites.contains(i) ? _favorites.remove(i) : _favorites.add(i)),
              onTap: () {},
            ),
          ),
        ],
      ],
    );
  }

  Widget _stats(AppLocalizations l) => GalleryStats(l: l, columns: 2);

  Widget _chips(AppLocalizations l) {
    return Wrap(
      spacing: DoayaSpacing.sm,
      runSpacing: DoayaSpacing.sm,
      children: [
        StatusChip(label: l.chipReady, tone: StatusTone.success),
        StatusChip(label: l.chipDelivered, tone: StatusTone.success, icon: DoayaIcons.check),
        StatusChip(label: l.chipInStock(formatNumber(24)), tone: StatusTone.accent),
        StatusChip(label: l.chipLeft(formatNumber(3)), tone: StatusTone.warning),
        StatusChip(label: l.chipOut, tone: StatusTone.danger),
        StatusChip(label: l.chipSynced, dot: true),
        StatusChip(label: l.chipCash),
        StatusChip(label: l.chipUrgent, tone: StatusTone.danger, icon: DoayaIcons.danger),
      ],
    );
  }

  Widget _notices(AppLocalizations l) {
    return Column(
      children: [
        NoticeBanner(message: l.noticeSafety, icon: DoayaIcons.warning),
        _smallGap,
        NoticeBanner(
          message: l.noticeEmergency,
          tone: StatusTone.danger,
          icon: DoayaIcons.danger,
          action: SagePillButton(label: l.callEmergency, size: PillSize.medium, onPressed: () {}),
        ),
      ],
    );
  }

  Widget _cases(AppLocalizations l) => GalleryCases(l: l);

  static const _smallGap = SizedBox(height: DoayaSpacing.ml);
}

/// Stat cards, shared with the desktop demo.
class GalleryStats extends StatelessWidget {
  const GalleryStats({super.key, required this.l, required this.columns});

  final AppLocalizations l;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final cards = [
      StatCard(
        icon: DoayaIcons.sales,
        label: l.statSalesToday,
        value: l.price(formatNumber(1250000)),
        caption: l.statVsYesterday(formatNumber(12)),
        tone: StatusTone.success,
      ),
      StatCard(
        icon: DoayaIcons.debts,
        label: l.statOpenDebts,
        value: l.price(formatNumber(340000)),
        caption: l.statCustomers(formatNumber(9)),
        tone: StatusTone.neutral,
      ),
      StatCard(
        icon: DoayaIcons.expiry,
        label: l.statNearExpiry,
        value: formatNumber(14),
        caption: l.statWithinDays(formatNumber(30)),
        tone: StatusTone.warning,
      ),
      StatCard(
        icon: DoayaIcons.cases,
        label: l.statAiCases,
        value: formatNumber(3),
        caption: l.statWaiting(formatNumber(1)),
        tone: StatusTone.accent,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = DoayaSpacing.ml;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final c in cards) SizedBox(width: width, child: c)],
        );
      },
    );
  }
}

/// Case rows, shared with the desktop demo.
class GalleryCases extends StatefulWidget {
  const GalleryCases({super.key, required this.l});

  final AppLocalizations l;

  @override
  State<GalleryCases> createState() => _GalleryCasesState();
}

class _GalleryCasesState extends State<GalleryCases> {
  var _selected = 1;

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final rows = [
      (l.initials1, l.case1Title, l.case1Sub(formatNumber(2)), true),
      (l.initials2, l.case2Title, l.case2Sub(formatNumber(4)), false),
      (l.initials3, l.case3Title, l.case3Sub(formatNumber(11)), false),
    ];
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: DoayaSpacing.sm),
            child: CaseRow(
              initials: rows[i].$1,
              title: rows[i].$2,
              subtitle: rows[i].$3,
              urgent: rows[i].$4,
              selected: i == _selected,
              trailing: i == 0 ? StatusChip(label: l.chipUrgent, tone: StatusTone.danger) : null,
              onTap: () => setState(() => _selected = i),
            ),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.action});

  final String title;
  final String? action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DoayaSpacing.giant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: title, actionLabel: action, onAction: action == null ? null : () {}),
          const SizedBox(height: DoayaSpacing.ml),
          child,
        ],
      ),
    );
  }
}

class _ColorSwatches extends StatelessWidget {
  const _ColorSwatches();

  // Token names are developer identifiers, shown as-is.
  static const _swatches = <(String, Color)>[
    ('bgTop', DoayaColors.bgTop),
    ('bgMid', DoayaColors.bgMid),
    ('bgBottom', DoayaColors.bgBottom),
    ('surface', DoayaColors.surface),
    ('surfaceRaised', DoayaColors.surfaceRaised),
    ('border', DoayaColors.border),
    ('glassFill', DoayaColors.glassFill),
    ('glassFillStrong', DoayaColors.glassFillStrong),
    ('sageTop', DoayaColors.sageTop),
    ('sageBottom', DoayaColors.sageBottom),
    ('onSage', DoayaColors.onSage),
    ('accent', DoayaColors.accent),
    ('price', DoayaColors.price),
    ('textPrimary', DoayaColors.textPrimary),
    ('textSecondary', DoayaColors.textSecondary),
    ('successDot', DoayaColors.successDot),
    ('warningIcon', DoayaColors.warningIcon),
    ('warningText', DoayaColors.warningText),
    ('dangerText', DoayaColors.dangerText),
    ('selectedTile', DoayaColors.selectedTileFill),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DoayaSpacing.sm,
      runSpacing: DoayaSpacing.ml,
      children: [
        for (final (name, color) in _swatches)
          SizedBox(
            width: DoayaSizes.swatchWidth,
            child: Column(
              children: [
                Container(
                  height: DoayaSizes.swatchHeight,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(DoayaRadii.imageWell),
                    border: Border.all(color: DoayaColors.glassBorder),
                  ),
                ),
                const SizedBox(height: DoayaSpacing.xs),
                LatinText(
                  name,
                  textAlign: TextAlign.center,
                  style: DoayaTypography.micro.copyWith(color: DoayaColors.textSecondary),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
