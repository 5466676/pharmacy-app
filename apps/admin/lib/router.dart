import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/providers.dart';
import 'ui/knowledge_screen.dart';
import 'ui/overview_screen.dart';
import 'ui/performance_screen.dart';
import 'ui/pharmacies_screen.dart';
import 'ui/review_screen.dart';
import 'ui/settings_screen.dart';
import 'ui/shell.dart';
import 'ui/sign_in_screen.dart';

abstract final class Routes {
  static const loading = '/loading';
  static const signIn = '/sign-in';
  static const overview = '/overview';
  static const pharmacies = '/pharmacies';
  static String pharmacy(String id) => '$pharmacies/$id';
  static const performance = '/performance';
  static const review = '/review';
  static String reviewItem(int id) => '$review/$id';
  static const knowledge = '/knowledge';
  static const settings = '/settings';
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref
    ..listen(authProvider, (_, _) => refresh.value++)
    ..onDispose(refresh.dispose);

  NoTransitionPage<void> page(Widget child, [LocalKey? key]) =>
      NoTransitionPage(key: key, child: child);

  return GoRouter(
    initialLocation: Routes.overview,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;
      if (auth.loading) return Routes.loading;
      if (!auth.signedIn) return loc == Routes.signIn ? null : Routes.signIn;
      if (loc == Routes.signIn || loc == Routes.loading) return Routes.overview;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.loading,
        builder: (_, _) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: Routes.signIn, builder: (_, _) => const SignInScreen()),
      ShellRoute(
        builder: (context, state, child) =>
            AdminShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: Routes.overview, pageBuilder: (_, _) => page(const OverviewScreen())),
          GoRoute(
            path: Routes.pharmacies,
            pageBuilder: (_, _) => page(const PharmaciesScreen()),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (_, s) => page(PharmaciesScreen(selected: s.pathParameters['id'])),
              ),
            ],
          ),
          GoRoute(path: Routes.performance, pageBuilder: (_, _) => page(const PerformanceScreen())),
          GoRoute(
            path: Routes.review,
            pageBuilder: (_, _) => page(const ReviewScreen()),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (_, s) =>
                    page(ReviewScreen(selected: int.tryParse(s.pathParameters['id']!))),
              ),
            ],
          ),
          GoRoute(path: Routes.knowledge, pageBuilder: (_, _) => page(const KnowledgeScreen())),
          GoRoute(path: Routes.settings, pageBuilder: (_, _) => page(const SettingsScreen())),
        ],
      ),
    ],
  );
});
