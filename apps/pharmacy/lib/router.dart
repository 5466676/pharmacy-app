import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/debts_screen.dart';
import 'ui/screens/inventory_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/pos_screen.dart';
import 'ui/screens/product_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/setup_screen.dart';
import 'ui/screens/staff_screen.dart';
import 'ui/shell.dart';

abstract final class Routes {
  static const loading = '/loading';
  static const setup = '/setup';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const pos = '/pos';
  static const inventory = '/inventory';
  static const debts = '/debts';
  static const staff = '/staff';
  static const settings = '/settings';

  static String product(String id) => '$inventory/product/$id';
  static const newProduct = '$inventory/new';
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref
    ..listen(thisDeviceProvider, (_, _) => refresh.value++)
    ..listen(sessionProvider, (_, _) => refresh.value++)
    ..onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.dashboard,
    refreshListenable: refresh,
    redirect: (context, state) {
      final device = ref.read(thisDeviceProvider);
      final loc = state.matchedLocation;
      if (device.isLoading && !device.hasValue) return Routes.loading;
      if (device.value == null) return loc == Routes.setup ? null : Routes.setup;
      if (ref.read(sessionProvider) == null) return loc == Routes.login ? null : Routes.login;
      if (loc == Routes.setup || loc == Routes.login || loc == Routes.loading) {
        return Routes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.loading,
        builder: (_, _) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: Routes.setup, builder: (_, _) => const SetupScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: Routes.dashboard,
            pageBuilder: (_, _) => const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: Routes.pos,
            pageBuilder: (_, _) => const NoTransitionPage(child: PosScreen()),
          ),
          GoRoute(
            path: Routes.inventory,
            pageBuilder: (_, _) => const NoTransitionPage(child: InventoryScreen()),
            routes: [
              GoRoute(path: 'new', builder: (_, _) => const ProductFormScreen()),
              GoRoute(
                path: 'product/:id',
                builder: (_, s) => ProductScreen(productId: s.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: Routes.debts,
            pageBuilder: (_, _) => const NoTransitionPage(child: DebtsScreen()),
          ),
          GoRoute(
            path: Routes.staff,
            pageBuilder: (_, _) => const NoTransitionPage(child: StaffScreen()),
          ),
          GoRoute(
            path: Routes.settings,
            pageBuilder: (_, _) => const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
    ],
  );
});
