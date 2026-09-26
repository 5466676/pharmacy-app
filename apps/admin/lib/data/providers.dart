import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'admin_api.dart';
import 'session_store.dart';

/// Doaya online's address, set at build time:
/// `--dart-define=DOAYA_API=https://…`.
final Uri apiBaseUrl = () {
  const raw = String.fromEnvironment('DOAYA_API', defaultValue: 'http://127.0.0.1:8100');
  return Uri.parse(raw.endsWith('/') ? raw : '$raw/');
}();

final apiBaseProvider = Provider<Uri>((ref) => apiBaseUrl);

final sessionStoreProvider = Provider<SessionStore>((ref) => SessionStore());

final apiProvider = Provider<AdminApi>((ref) {
  final api = AdminApi(ref.watch(apiBaseProvider));
  ref.onDispose(api.close);
  return api;
});

class AuthState {
  const AuthState({this.loading = false, this.name});
  const AuthState.loading() : this(loading: true);

  final bool loading;

  /// The signed-in admin's name.
  final String? name;

  bool get signedIn => name != null;
}

/// Signing in once per browser, then staying signed in (the session secret
/// is kept in the browser). An expired or revoked session signs out.
class AuthController extends Notifier<AuthState> {
  AdminApi get _api => ref.read(apiProvider);
  SessionStore get _store => ref.read(sessionStoreProvider);

  @override
  AuthState build() {
    scheduleMicrotask(_load);
    return const AuthState.loading();
  }

  Future<void> _load() async {
    final saved = AdminSession.fromJsonString(await _store.read());
    if (saved == null) {
      state = const AuthState();
      return;
    }
    _api.resume(saved.sessionToken);
    state = AuthState(name: saved.name);
  }

  Future<void> login(String phone, String password) async {
    final s = await _api.login(phone, password);
    await _store.write(s.toJsonString());
    state = AuthState(name: s.name);
  }

  /// Also called when the server says the session is over.
  Future<void> signOut({bool tellServer = true}) async {
    if (tellServer) {
      try {
        await _api.logout();
      } on Object {
        // Offline: forget here anyway.
      }
    }
    _api.forget();
    await _store.write(null);
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Runs [call]; a session the server no longer knows signs the panel out.
Future<T> guarded<T>(Ref ref, Future<T> Function(AdminApi api) call) async {
  try {
    return await call(ref.read(apiProvider));
  } on SyncApiException catch (e) {
    if (e.status == 401) {
      unawaited(ref.read(authProvider.notifier).signOut(tellServer: false));
    }
    rethrow;
  }
}

// ─── Data the screens show (refreshed by invalidating) ──────────────────────

final overviewDaysProvider = NotifierProvider<_Value<int>, int>(() => _Value(30));

final overviewProvider = FutureProvider.autoDispose(
  (ref) => guarded(ref, (api) => api.overview(days: ref.watch(overviewDaysProvider))),
);

final pharmacyQueryProvider = NotifierProvider<_Value<String>, String>(() => _Value(''));

final pharmaciesProvider = FutureProvider.autoDispose(
  (ref) => guarded(ref, (api) => api.pharmacies(query: ref.watch(pharmacyQueryProvider))),
);

final pharmacyProvider = FutureProvider.autoDispose.family(
  (ref, String id) => guarded(ref, (api) => api.pharmacy(id)),
);

final performanceMonthProvider = NotifierProvider<_Value<String?>, String?>(() => _Value(null));

final performanceProvider = FutureProvider.autoDispose(
  (ref) => guarded(ref, (api) => api.performance(month: ref.watch(performanceMonthProvider))),
);

final reviewDoneProvider = NotifierProvider<_Value<bool>, bool>(() => _Value(false));

final reviewProvider = FutureProvider.autoDispose(
  (ref) => guarded(ref, (api) => api.review(reviewed: ref.watch(reviewDoneProvider))),
);

final reviewItemProvider = FutureProvider.autoDispose.family(
  (ref, int id) => guarded(ref, (api) => api.reviewItem(id)),
);

final notesProvider = FutureProvider.autoDispose((ref) => guarded(ref, (api) => api.notes()));

final settingsProvider = FutureProvider.autoDispose((ref) => guarded(ref, (api) => api.settings()));

final assistantProvider = FutureProvider.autoDispose(
  (ref) => guarded(ref, (api) => api.assistant()),
);

final assistantStatsProvider = FutureProvider.autoDispose.family(
  (ref, int hours) => guarded(ref, (api) => api.assistantStats(hours: hours)),
);

final promptsProvider = FutureProvider.autoDispose((ref) => guarded(ref, (api) => api.prompts()));

final safetyExamplesProvider = FutureProvider.autoDispose(
  (ref) => guarded(ref, (api) => api.safetyExamples()),
);

/// A plain settable value.
class _Value<T> extends Notifier<T> {
  _Value(this._initial);
  final T _initial;

  @override
  T build() => _initial;

  void set(T value) => state = value;
}
