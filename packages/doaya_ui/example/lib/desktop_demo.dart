import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';

import 'gallery_page.dart';
import 'l10n/app_localizations.dart';

/// Pharmacy desktop layout (from `design/pharmacy_dashboard_layout.html`),
/// rebuilt with dark tokens and the solid theme: no blur anywhere.
class DesktopDemo extends StatefulWidget {
  const DesktopDemo({super.key});

  @override
  State<DesktopDemo> createState() => _DesktopDemoState();
}

class _DesktopDemoState extends State<DesktopDemo> {
  var _selected = 0;
  var _compact = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Theme(
      data: DoayaTheme.solid(),
      child: Scaffold(
        body: DesktopShell(
          brandName: l.appName,
          compact: _compact,
          selectedIndex: _selected,
          onSelect: (i) => setState(() => _selected = i),
          sections: [
            DoayaNavSection(
              title: l.sideMain,
              items: [
                DoayaNavItem(icon: DoayaIcons.dashboard, label: l.sideDashboard),
                DoayaNavItem(icon: DoayaIcons.inventory, label: l.sideInventory),
                DoayaNavItem(icon: DoayaIcons.category, label: l.sideCategories),
              ],
            ),
            DoayaNavSection(
              title: l.sideOps,
              items: [
                DoayaNavItem(icon: DoayaIcons.pos, label: l.sideSale),
                DoayaNavItem(icon: DoayaIcons.debts, label: l.sideDebts),
                DoayaNavItem(icon: DoayaIcons.cases, label: l.sideCases, badge: formatNumber(3)),
              ],
            ),
            DoayaNavSection(
              title: l.sideAdmin,
              items: [
                DoayaNavItem(icon: DoayaIcons.reports, label: l.sideReports),
                DoayaNavItem(icon: DoayaIcons.settings, label: l.sideSettings),
              ],
            ),
          ],
          topBar: Row(
            children: [
              RoundIconButton(
                icon: DoayaIcons.back,
                tooltip: l.back,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: DoayaSpacing.ml),
              SizedBox(
                width: DoayaSizes.desktopSearchWidth,
                child: GlassSearchField(hint: l.posSearchHint),
              ),
              const Spacer(),
              GlassPillButton(
                label: _compact ? l.fullSidebar : l.compactSidebar,
                onPressed: () => setState(() => _compact = !_compact),
              ),
              const SizedBox(width: DoayaSpacing.ml),
              StatusChip(label: l.chipSynced, dot: true),
              const SizedBox(width: DoayaSpacing.ml),
              CircleAvatar(
                radius: DoayaSizes.avatar / 2,
                backgroundColor: DoayaColors.selectedTileFill,
                child: Text(
                  l.sampleDoctor.characters.first,
                  style: DoayaTypography.label.copyWith(color: DoayaColors.accent),
                ),
              ),
              const SizedBox(width: DoayaSpacing.m),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.pharmacistName(l.sampleDoctor), style: DoayaTypography.label),
                  Text(
                    l.pharmacyName(l.samplePharmacy),
                    style: DoayaTypography.micro.copyWith(color: DoayaColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            children: [
              Row(
                children: [
                  Expanded(child: Text(l.greeting(l.sampleDoctor), style: DoayaTypography.title)),
                  SagePillButton(
                    label: l.newSale,
                    size: PillSize.medium,
                    icon: DoayaIcons.add,
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: DoayaSpacing.xl),
              GlassSurface(
                borderRadius: BorderRadius.circular(DoayaRadii.hero),
                padding: const EdgeInsets.all(DoayaSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.pharmacyResults, style: DoayaTypography.lead),
                    const SizedBox(height: DoayaSpacing.l),
                    GalleryStats(l: l, columns: 4),
                  ],
                ),
              ),
              const SizedBox(height: DoayaSpacing.xl),
              GlassSurface(
                borderRadius: BorderRadius.circular(DoayaRadii.hero),
                padding: const EdgeInsets.all(DoayaSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionHeader(title: l.latestCases, actionLabel: l.seeAll, onAction: () {}),
                    const SizedBox(height: DoayaSpacing.l),
                    GalleryCases(l: l),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
