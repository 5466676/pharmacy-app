import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models.dart';
import 'patient_api.dart';
import 'session_store.dart';

/// Doaya online's address, set at build time:
/// `--dart-define=DOAYA_API=https://…`.
final apiBaseProvider = Provider<Uri>((ref) {
  const raw = String.fromEnvironment('DOAYA_API', defaultValue: 'http://127.0.0.1:8100');
  return Uri.parse(raw.endsWith('/') ? raw : '$raw/');
});

final sessionStoreProvider = Provider<SessionStore>((ref) => SessionStore());

final apiProvider = Provider<PatientApi>((ref) {
  final api = PatientApi(ref.watch(apiBaseProvider));
  ref.onDispose(api.close);
  return api;
});

class AuthState {
  const AuthState({this.loading = false, this.patient});
  const AuthState.loading() : this(loading: true);

  final bool loading;
  final Patient? patient;

  bool get signedIn => patient != null;
  bool get hasPharmacy => patient?.pharmacy != null;
}

/// Signing up / in once, then staying signed in (the session secret is kept
/// on the device). With no internet the last known profile is used.
class AuthController extends Notifier<AuthState> {
  PatientApi get _api => ref.read(apiProvider);
  SessionStore get _store => ref.read(sessionStoreProvider);
  String? _sessionToken;

  @override
  AuthState build() {
    scheduleMicrotask(_load);
    return const AuthState.loading();
  }

  Future<void> _load() async {
    final saved = PatientSession.fromJsonString(await _store.read());
    if (saved == null) {
      state = const AuthState();
      return;
    }
    _sessionToken = saved.sessionToken;
    _api.resume(saved.sessionToken);
    state = AuthState(patient: saved.patient);
    try {
      await _save(await _api.me());
    } on SyncApiException catch (e) {
      if (e.status == 401 || e.status == 403) await _clear();
    } on SyncNetworkException {
      // Offline: keep the saved profile.
    }
  }

  Future<void> _save(Patient p) async {
    await _store.write(
      jsonEncode(PatientSession(sessionToken: _sessionToken!, patient: p).toJson()),
    );
    state = AuthState(patient: p);
  }

  Future<void> _clear() async {
    _api.forget();
    _sessionToken = null;
    await _store.write(null);
    state = const AuthState();
  }

  Future<void> _signedIn(PatientSession s) async {
    _sessionToken = s.sessionToken;
    await _save(s.patient);
  }

  Future<void> register({
    required String name,
    required String phone,
    required String password,
    int? birthYear,
    String? sex,
    String? city,
  }) async => _signedIn(
    await _api.register(
      name: name,
      phone: phone,
      password: password,
      birthYear: birthYear,
      sex: sex,
      city: city,
    ),
  );

  Future<void> login(String phone, String password) async =>
      _signedIn(await _api.login(phone, password));

  Future<void> choosePharmacy(PharmacyBrief pharmacy) async =>
      _save(await _api.updateMe({'pharmacy_id': pharmacy.id}));

  Future<void> updateProfile(Map<String, Object?> fields) async =>
      _save(await _api.updateMe(fields));

  Future<void> logout() async {
    try {
      await _api.logout();
    } on Object {
      // Offline: forget locally anyway.
    }
    await _clear();
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

/// The patient's consultations, newest first.
final consultationsProvider = FutureProvider<List<Consultation>>((ref) {
  ref.watch(authProvider.select((a) => a.patient?.id));
  return ref.read(apiProvider).consultations();
});

/// One consultation while it's open on screen.
class ConsultationController extends AsyncNotifier<Consultation> {
  ConsultationController(this.id);
  final String id;

  PatientApi get _api => ref.read(apiProvider);

  @override
  Future<Consultation> build() => _api.consultation(id);

  Future<void> _run(Future<Consultation> Function() call) async {
    state = AsyncData(await call());
    ref.invalidate(consultationsProvider);
  }

  Future<void> say(String text) => _run(() => _api.say(id, text));
  Future<void> correctSummary(Map<String, Object?> summary) =>
      _run(() => _api.correctSummary(id, summary));
  Future<void> send() => _run(() => _api.send(id));
  Future<void> reload() => _run(() => _api.consultation(id));
}

final consultationProvider =
    AsyncNotifierProvider.family<ConsultationController, Consultation, String>(
      ConsultationController.new,
    );
