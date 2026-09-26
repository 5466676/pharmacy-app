import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/providers.dart';
import 'ui/account_screen.dart';
import 'ui/chat_screen.dart';
import 'ui/common.dart';
import 'ui/consultations_screen.dart';
import 'ui/home_screen.dart';
import 'ui/pharmacy_screen.dart';
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
  static const account = '/account';
  static String chat(String id) => '/chat/$id';
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
      ShellRoute(
        builder: (_, state, child) => PatientShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
          GoRoute(path: Routes.consultations, builder: (_, _) => const ConsultationsScreen()),
          GoRoute(path: Routes.account, builder: (_, _) => const AccountScreen()),
        ],
      ),
    ],
  );
});
