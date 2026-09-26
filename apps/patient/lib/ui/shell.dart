import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../router.dart';

const _tabs = [Routes.home, Routes.consultations, Routes.doses, Routes.orders, Routes.account];

/// The three tabs with the floating glass nav (design/patient_home.html).
class PatientShell extends StatelessWidget {
  const PatientShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tab = _tabs.indexOf(location).clamp(0, _tabs.length - 1);
    return Scaffold(
      backgroundColor: DoayaColors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: DoayaSizes.bottomNav + DoayaSpacing.floatingBottom),
              child: SafeArea(bottom: false, child: child),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: DoayaSizes.phoneMaxWidth),
                child: FloatingBottomNav(
                  currentIndex: tab,
                  onTap: (i) => context.go(_tabs[i]),
                  items: [
                    DoayaNavItem(
                      icon: DoayaIcons.homeOutlined,
                      activeIcon: DoayaIcons.home,
                      label: l.navHome,
                    ),
                    DoayaNavItem(
                      icon: DoayaIcons.chat,
                      activeIcon: DoayaIcons.chatFilled,
                      label: l.navConsultations,
                    ),
                    DoayaNavItem(icon: DoayaIcons.clock, label: l.navDoses),
                    DoayaNavItem(icon: DoayaIcons.bag, label: l.navOrders),
                    DoayaNavItem(
                      icon: DoayaIcons.person,
                      activeIcon: DoayaIcons.personFilled,
                      label: l.navAccount,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
