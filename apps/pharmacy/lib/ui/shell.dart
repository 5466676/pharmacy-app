import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../router.dart';
import 'format.dart';

/// Desktop shell: sidebar + top bar (who's working, offline status).
/// F2 anywhere jumps to the POS search.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const _compactBreakpoint = 1100.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(requireSessionProvider);
    final pharmacyName = ref.watch(settingsProvider).value?['pharmacy_name'];
    final width = MediaQuery.sizeOf(context).width;

    // Owner-only destinations are hidden from employees.
    final mainItems = [
      (Routes.dashboard, DoayaNavItem(icon: DoayaIcons.dashboard, label: l.navDashboard)),
      (Routes.pos, DoayaNavItem(icon: DoayaIcons.pos, label: l.navPos)),
      (Routes.inventory, DoayaNavItem(icon: DoayaIcons.inventory, label: l.navInventory)),
      (Routes.debts, DoayaNavItem(icon: DoayaIcons.debts, label: l.navDebts)),
    ];
    final adminItems = [
      if (session.isOwner) (Routes.staff, DoayaNavItem(icon: DoayaIcons.staff, label: l.navStaff)),
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
              StatusChip(label: l.offline, dot: true),
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
