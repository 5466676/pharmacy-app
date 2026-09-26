import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/identity.dart';
import '../data/providers.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';

/// Below this width the sidebar becomes an icon rail (tablets).
const _compactBreakpoint = 1100.0;

String identityName(AppLocalizations l, AdminIdentity i) => switch (i) {
  AdminIdentity.console => l.designConsole,
  AdminIdentity.ledger => l.designLedger,
  AdminIdentity.family => l.designFamily,
};

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final waiting = ref.watch(overviewProvider).value?.reviewWaiting ?? 0;
    final items = [
      (Routes.overview, DoayaNavItem(icon: DoayaIcons.dashboard, label: l.navOverview)),
      (Routes.pharmacies, DoayaNavItem(icon: DoayaIcons.pharmacy, label: l.navPharmacies)),
      (Routes.performance, DoayaNavItem(icon: DoayaIcons.trophy, label: l.navPerformance)),
      (
        Routes.review,
        DoayaNavItem(
          icon: DoayaIcons.review,
          label: l.navReview,
          badge: waiting > 0 ? formatNumber(waiting) : null,
        ),
      ),
      (Routes.knowledge, DoayaNavItem(icon: DoayaIcons.knowledge, label: l.navKnowledge)),
    ];
    final settings = [
      (Routes.settings, DoayaNavItem(icon: DoayaIcons.settings, label: l.navSettings)),
    ];
    final routes = [...items, ...settings].map((e) => e.$1).toList();
    final selected = routes.indexWhere(location.startsWith);
    final identity = ref.watch(identityProvider);

    return Scaffold(
      body: DesktopShell(
        brandName: l.appName,
        compact: MediaQuery.sizeOf(context).width < _compactBreakpoint,
        selectedIndex: selected < 0 ? 0 : selected,
        onSelect: (i) => context.go(routes[i]),
        sections: [
          DoayaNavSection(title: l.panelName, items: items.map((e) => e.$2).toList()),
          DoayaNavSection(items: settings.map((e) => e.$2).toList()),
        ],
        topBar: Row(
          children: [
            Text(l.panelName, style: DoayaTypography.lead),
            const Spacer(),
            // The three designs, one click away (owner's wish).
            for (final i in AdminIdentity.values) ...[
              GlassPillButton(
                label: identityName(l, i),
                selected: i == identity,
                onPressed: () => ref.read(identityProvider.notifier).set(i),
              ),
              SizedBox(width: DoayaSpacing.xs),
            ],
            SizedBox(width: DoayaSpacing.m),
            Text(ref.watch(authProvider).name ?? '', style: DoayaTypography.label),
            SizedBox(width: DoayaSpacing.sm),
            RoundIconButton(
              icon: DoayaIcons.logout,
              tooltip: l.signOut,
              onPressed: () => ref.read(authProvider.notifier).signOut(),
            ),
          ],
        ),
        body: child,
      ),
    );
  }
}
