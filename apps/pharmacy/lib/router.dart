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
import 'ui/screens/purchase_form_screen.dart';
import 'ui/screens/purchases_screen.dart';
import 'ui/screens/reports_screen.dart';
import 'ui/screens/return_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/setup_screen.dart';
import 'ui/screens/staff_screen.dart';
import 'ui/screens/supplier_screen.dart';
import 'ui/screens/till_screen.dart';
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
  static const till = '/till';
  static const returns = '/pos/return';
  static const settings = '/settings';
  static const reports = '/reports';
  static const purchases = '/purchases';
  static const newPurchase = '$purchases/new';
  static String newPurchaseFrom(String supplierId) => '$newPurchase?supplier=$supplierId';
  static String purchaseFromOrder(String orderId) => '$newPurchase?order=$orderId';
  static const shortages = '$purchases?tab=shortages';
  static String supplier(String id) => '$purchases/supplier/$id';

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
            routes: [GoRoute(path: 'return', builder: (_, _) => const ReturnScreen())],
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
            path: Routes.purchases,
            pageBuilder: (_, s) => NoTransitionPage(
              child: PurchasesScreen(
                initialTab: PurchasesTab.values.firstWhere(
                  (t) => t.name == s.uri.queryParameters['tab'],
                  orElse: () => PurchasesTab.invoices,
                ),
              ),
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, s) => PurchaseFormScreen(
                  supplierId: s.uri.queryParameters['supplier'],
                  orderId: s.uri.queryParameters['order'],
                ),
              ),
              GoRoute(
                path: 'supplier/:id',
                builder: (_, s) => SupplierScreen(supplierId: s.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: Routes.debts,
            pageBuilder: (_, _) => const NoTransitionPage(child: DebtsScreen()),
          ),
          GoRoute(
            path: Routes.till,
            pageBuilder: (_, _) => const NoTransitionPage(child: TillScreen()),
          ),
          GoRoute(
            path: Routes.reports,
            pageBuilder: (_, _) => const NoTransitionPage(child: ReportsScreen()),
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
