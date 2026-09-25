import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../router.dart';
import '../sync/sync_controller.dart';
import 'format.dart';
import 'screens/sync_screen.dart' show syncStatusChip;
import 'widgets.dart' show isPhoneLayout;

/// Desktop shell: sidebar + top bar (who's working, offline status).
/// F2 anywhere jumps to the POS search.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const _compactBreakpoint = 1100.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isPhoneLayout(context)) return PhoneShell(location: location, child: child);
    final l = AppLocalizations.of(context);
    final session = ref.watch(requireSessionProvider);
    final pharmacyName = ref.watch(settingsProvider).value?['pharmacy_name'];
    final width = MediaQuery.sizeOf(context).width;

    // Owner-only destinations are hidden from employees.
    final mainItems = [
      (Routes.dashboard, DoayaNavItem(icon: DoayaIcons.dashboard, label: l.navDashboard)),
      (Routes.pos, DoayaNavItem(icon: DoayaIcons.pos, label: l.navPos)),
      (Routes.inventory, DoayaNavItem(icon: DoayaIcons.inventory, label: l.navInventory)),
      (Routes.purchases, DoayaNavItem(icon: DoayaIcons.receive, label: l.navPurchases)),
      (Routes.debts, DoayaNavItem(icon: DoayaIcons.debts, label: l.navDebts)),
      (Routes.till, DoayaNavItem(icon: DoayaIcons.till, label: l.navTill)),
    ];
    final adminItems = [
      if (session.isOwner)
        (Routes.reports, DoayaNavItem(icon: DoayaIcons.reports, label: l.navReports)),
      if (session.isOwner) (Routes.staff, DoayaNavItem(icon: DoayaIcons.staff, label: l.navStaff)),
      if (session.isOwner) (Routes.sync, DoayaNavItem(icon: DoayaIcons.sync, label: l.syncTitle)),
      if (session.isOwner)
        (Routes.settings, DoayaNavItem(icon: DoayaIcons.settings, label: l.navSettings)),
    ];
    final routes = [...mainItems, ...adminItems].map((e) => e.$1).toList();
    final selected = routes.indexWhere((r) => location.startsWith(r));

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f2): () {
          if (!location.startsWith(Routes.pos)) context.go(Routes.pos);
        },
      },
      child: Scaffold(
        body: DesktopShell(
          brandName: l.appName,
          compact: width < _compactBreakpoint,
          selectedIndex: selected < 0 ? 0 : selected,
          onSelect: (i) => context.go(routes[i]),
          sections: [
            DoayaNavSection(title: l.navSectionMain, items: mainItems.map((e) => e.$2).toList()),
            if (adminItems.isNotEmpty)
              DoayaNavSection(
                title: l.navSectionAdmin,
                items: adminItems.map((e) => e.$2).toList(),
              ),
          ],
          topBar: Row(
            children: [
              if (pharmacyName != null) Text(pharmacyName, style: DoayaTypography.lead),
              const Spacer(),
              Tooltip(
                message: l.syncTitle,
                child: GestureDetector(
                  onTap: () => context.go(Routes.sync),
                  child: syncStatusChip(
                    l,
                    ref.watch(syncProvider),
                    ref.watch(pendingChangesProvider).value ?? 0,
                  ),
                ),
              ),
              const SizedBox(width: DoayaSpacing.ml),
              _WhoIsWorking(
                name: session.employee.name,
                role: session.isOwner ? l.owner : l.employee,
                device: session.device.name,
              ),
              const SizedBox(width: DoayaSpacing.sm),
              RoundIconButton(
                icon: DoayaIcons.switchUser,
                tooltip: l.signOut,
                onPressed: () => ref.read(sessionProvider.notifier).signOut(),
              ),
            ],
          ),
          body: child,
        ),
      ),
    );
  }
}

class _WhoIsWorking extends StatelessWidget {
  const _WhoIsWorking({required this.name, required this.role, required this.device});

  final String name;
  final String role;
  final String device;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: DoayaSizes.avatar / 2,
          backgroundColor: DoayaColors.selectedTileFill,
          child: Text(
            initialsOf(name),
            style: DoayaTypography.caption.copyWith(
              color: DoayaColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: DoayaSpacing.m),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: DoayaTypography.label),
            Text(
              '$role · $device',
              style: DoayaTypography.micro.copyWith(color: DoayaColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

/// Phone layout: a slim top bar, the page, and a floating bottom bar with
/// the everyday destinations; the rest lives under «المزيد».
class PhoneShell extends ConsumerWidget {
  const PhoneShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const _tabs = [Routes.dashboard, Routes.pos, Routes.inventory, Routes.debts, Routes.more];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(requireSessionProvider);
    final pharmacyName = ref.watch(settingsProvider).value?['pharmacy_name'];
    var tab = _tabs.indexWhere((r) => r != Routes.dashboard && location.startsWith(r));
    if (location.startsWith(Routes.dashboard)) tab = 0;
    if (tab < 0) tab = _tabs.length - 1; // anything else lives under «المزيد»
    const navSpace = DoayaSizes.bottomNav + DoayaSpacing.floatingBottom + DoayaSpacing.l;

    return Scaffold(
      body: DoayaBackground(
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      DoayaSpacing.l,
                      DoayaSpacing.sm,
                      DoayaSpacing.l,
                      DoayaSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            pharmacyName ?? l.appName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: DoayaTypography.lead,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go(Routes.sync),
                          child: syncStatusChip(
                            l,
                            ref.watch(syncProvider),
                            ref.watch(pendingChangesProvider).value ?? 0,
                          ),
                        ),
                        const SizedBox(width: DoayaSpacing.s),
                        RoundIconButton(
                          icon: DoayaIcons.switchUser,
                          tooltip: '${l.signOut}: ${session.employee.name}',
                          onPressed: () => ref.read(sessionProvider.notifier).signOut(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        DoayaSpacing.l,
                        DoayaSpacing.sm,
                        DoayaSpacing.l,
                        navSpace,
                      ),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingBottomNav(
                currentIndex: tab,
                onTap: (i) => context.go(_tabs[i]),
                items: [
                  DoayaNavItem(icon: DoayaIcons.dashboard, label: l.navDashboard),
                  DoayaNavItem(icon: DoayaIcons.pos, label: l.navPos),
                  DoayaNavItem(icon: DoayaIcons.inventory, label: l.navInventoryShort),
                  DoayaNavItem(icon: DoayaIcons.debts, label: l.navDebtsShort),
                  DoayaNavItem(icon: DoayaIcons.menu, label: l.navMore),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// «المزيد» on the phone: every other destination, as a list.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final owner = ref.watch(requireSessionProvider).isOwner;
    final items = [
      (Routes.till, DoayaIcons.till, l.navTill),
      (Routes.purchases, DoayaIcons.receive, l.navPurchases),
      (Routes.stocktake, DoayaIcons.adjust, l.stocktakeTitle),
      if (owner) (Routes.reports, DoayaIcons.reports, l.navReports),
      if (owner) (Routes.staff, DoayaIcons.staff, l.navStaff),
      (Routes.sync, DoayaIcons.sync, l.syncTitle),
      if (owner) (Routes.settings, DoayaIcons.settings, l.navSettings),
    ];
    return ListView(
      children: [
        Text(l.navMore, style: DoayaTypography.title),
        const SizedBox(height: DoayaSpacing.l),
        for (final (route, icon, label) in items)
          Padding(
            padding: const EdgeInsets.only(bottom: DoayaSpacing.sm),
            child: GlassSurface(
              shadow: false,
              borderRadius: BorderRadius.circular(DoayaRadii.tile),
              child: Material(
                type: MaterialType.transparency,
                child: ListTile(
                  leading: Icon(icon, color: DoayaColors.accent),
                  title: Text(label, style: DoayaTypography.label),
                  onTap: () => context.go(route),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
