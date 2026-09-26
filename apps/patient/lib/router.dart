import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/providers.dart';
import 'ui/account_screen.dart';
import 'ui/cart_screen.dart';
import 'ui/chat_screen.dart';
import 'ui/common.dart';
import 'ui/consultations_screen.dart';
import 'ui/home_screen.dart';
import 'ui/orders_screens.dart';
import 'ui/pharmacy_screen.dart';
import 'ui/shelf_screens.dart';
import 'ui/shell.dart';
import 'ui/welcome_screens.dart';

abstract final class Routes {
  static const loading = '/loading';
  static const welcome = '/welcome';
  static const signUp = '$welcome/sign-up';
  static const signIn = '$welcome/sign-in';
  static const pharmacy = '/pharmacy';
  static const home = '/home';
  static const consultations = '/consultations';
  static const orders = '/orders';
  static const account = '/account';
  static String chat(String id) => '/chat/$id';
  static const shelf = '/shelf';
  static String shelfSearch(String q) => '$shelf?q=${Uri.encodeQueryComponent(q)}';
  static String product(String id) => '/product/$id';
  static const cart = '/cart';
  static String order(String id) => '/order/$id';
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref
    ..listen(authProvider, (_, _) => refresh.value++)
    ..onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;
      if (auth.loading) return Routes.loading;
      if (!auth.signedIn) return loc.startsWith(Routes.welcome) ? null : Routes.welcome;
      if (!auth.hasPharmacy) return loc == Routes.pharmacy ? null : Routes.pharmacy;
      if (loc == Routes.loading || loc.startsWith(Routes.welcome)) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.loading, builder: (_, _) => const LoadingScreen()),
      GoRoute(
        path: Routes.welcome,
        builder: (_, _) => const WelcomeScreen(),
        routes: [
          GoRoute(path: 'sign-up', builder: (_, _) => const SignUpScreen()),
          GoRoute(path: 'sign-in', builder: (_, _) => const SignInScreen()),
        ],
      ),
      GoRoute(path: Routes.pharmacy, builder: (_, _) => const ChoosePharmacyScreen()),
      GoRoute(
        path: '/chat/:id',
        builder: (_, state) => ChatScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.shelf,
        builder: (_, state) => ShelfScreen(query: state.uri.queryParameters['q'] ?? ''),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (_, state) => ProductScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(path: Routes.cart, builder: (_, _) => const CartScreen()),
      GoRoute(
        path: '/order/:id',
        builder: (_, state) => OrderScreen(id: state.pathParameters['id']!),
      ),
      ShellRoute(
        builder: (_, state, child) => PatientShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
          GoRoute(path: Routes.consultations, builder: (_, _) => const ConsultationsScreen()),
          GoRoute(path: Routes.orders, builder: (_, _) => const OrdersScreen()),
          GoRoute(path: Routes.account, builder: (_, _) => const AccountScreen()),
        ],
      ),
    ],
  );
});
