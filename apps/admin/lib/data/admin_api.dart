import 'dart:async';
import 'dart:convert';

import 'package:doaya_core/doaya_core.dart' show SyncApiException, SyncNetworkException;
import 'package:http/http.dart' as http;

import 'models.dart';

export 'package:doaya_core/doaya_core.dart' show SyncApiException, SyncNetworkException;

/// A signed-in admin: the long-lived session secret (kept in the browser)
/// and the admin's name.
class AdminSession {
  const AdminSession({required this.sessionToken, required this.name});

  final String sessionToken;
  final String name;

  String toJsonString() => jsonEncode({'session_token': sessionToken, 'name': name});

  static AdminSession? fromJsonString(String? s) {
    if (s == null) return null;
    try {
      final j = jsonDecode(s) as Json;
      return AdminSession(sessionToken: j['session_token']! as String, name: j['name']! as String);
    } on Object {
      return null;
    }
  }
}

/// Doaya online for its owner. Errors: [SyncApiException] with the server's
/// short code (`bad_credentials`, `reason_required`…) or
/// [SyncNetworkException].
class AdminApi {
  AdminApi(this.baseUrl, {http.Client? client, this.timeout = const Duration(seconds: 30)})
    : _client = client ?? http.Client();

  final Uri baseUrl;
  final Duration timeout;
  final http.Client _client;

  String? _sessionToken;
  String? _accessToken;

  void resume(String sessionToken) {
    _sessionToken = sessionToken;
    _accessToken = null;
  }

  void forget() => _sessionToken = _accessToken = null;

  void close() => _client.close();

  // ─── Sign-in ─────────────────────────────────────────────────────────────

  Future<AdminSession> login(String phone, String password) async {
    final j =
        (await _send('POST', 'admin/login', body: {'phone': phone, 'password': password}))! as Json;
    _sessionToken = j['session_token']! as String;
    _accessToken = j['access_token']! as String;
    return AdminSession(
      sessionToken: _sessionToken!,
      name: (j['admin']! as Json)['name']! as String,
    );
  }

  Future<void> logout() async {
    try {
      await _authorized('POST', 'admin/logout');
    } finally {
      forget();
    }
  }

  // ─── Overview, pharmacies, performance ───────────────────────────────────

  Future<Overview> overview({int days = 30}) async =>
      Overview((await _authorized('GET', 'admin/overview?days=$days'))! as Json);

  Future<List<Pharmacy>> pharmacies({String? query, String? status}) async {
    final q = {if (query != null && query.trim().isNotEmpty) 'q': query.trim(), 'status': ?status};
    final path = q.isEmpty
        ? 'admin/pharmacies'
        : 'admin/pharmacies?${Uri(queryParameters: q).query}';
    return [for (final p in (await _authorized('GET', path))! as List) Pharmacy(p as Json)];
  }

  Future<Pharmacy> pharmacy(String id) async =>
      Pharmacy((await _authorized('GET', 'admin/pharmacies/$id'))! as Json);

  Future<Pharmacy> addPharmacy({
    required String name,
    required String city,
    required String code,
    String? address,
    String? phone,
    String? hours,
    int licenceDays = 30,
  }) async => Pharmacy(
    (await _authorized('POST', 'admin/pharmacies', {
          'name': name,
          'city': city,
          'code': code,
          'address': address,
          'phone': phone,
          'hours': hours,
          'licence_days': licenceDays,
        }))!
        as Json,
  );

  /// approve · suspend · resume · stop · remove · list · unlist · new_key ·
  /// licence · health_check.
  Future<Pharmacy> act(String id, String action, {String? reason, int? licenceDays}) async =>
      Pharmacy(
        (await _authorized('POST', 'admin/pharmacies/$id/actions', {
              'action': action,
              'reason': ?reason,
              'licence_days': ?licenceDays,
            }))!
            as Json,
      );

  Future<Performance> performance({String? month}) async => Performance(
    (await _authorized(
          'GET',
          month == null ? 'admin/performance' : 'admin/performance?month=$month',
        ))!
        as Json,
  );

  // ─── Review and knowledge ────────────────────────────────────────────────

  Future<List<ReviewItem>> review({bool reviewed = false, String? kind}) async => [
    for (final r
        in (await _authorized(
              'GET',
              'admin/review?reviewed=$reviewed${kind == null ? '' : '&kind=$kind'}',
            ))!
            as List)
      ReviewItem(r as Json),
  ];

  Future<ReviewItem> reviewItem(int id) async =>
      ReviewItem((await _authorized('GET', 'admin/review/$id'))! as Json);

  Future<ReviewItem> markReviewed(int id, {String? note}) async =>
      ReviewItem((await _authorized('POST', 'admin/review/$id', {'note': note}))! as Json);

  Future<List<KnowledgeNote>> notes() async => [
    for (final n in (await _authorized('GET', 'admin/knowledge'))! as List)
      KnowledgeNote(n as Json),
  ];

  Future<KnowledgeNote> addNote({
    required String title,
    required String text,
    required List<String> tags,
    int? sourceLogId,
  }) async => KnowledgeNote(
    (await _authorized('POST', 'admin/knowledge', {
          'title': title,
          'text': text,
          'tags': tags,
          'source_log_id': ?sourceLogId,
        }))!
        as Json,
  );

  Future<KnowledgeNote> updateNote(
    String id, {
    String? title,
    String? text,
    List<String>? tags,
    bool? enabled,
  }) async => KnowledgeNote(
    (await _authorized('PATCH', 'admin/knowledge/$id', {
          'title': ?title,
          'text': ?text,
          'tags': ?tags,
          'enabled': ?enabled,
        }))!
        as Json,
  );

  /// Which notes the assistant would get for [text].
  Future<List<KnowledgeNote>> matchNotes(String text) async => [
    for (final n
        in (await _authorized(
              'GET',
              'admin/knowledge/match?${Uri(queryParameters: {'text': text}).query}',
            ))!
            as List)
      KnowledgeNote(n as Json),
  ];

  Future<AdminSettings> settings() async =>
      AdminSettings((await _authorized('GET', 'admin/settings'))! as Json);

  /// (answers, milliseconds, error).
  Future<({bool ok, int? ms, String? error})> modelCheck() async {
    final j = (await _authorized('POST', 'admin/settings/model-check'))! as Json;
    return (ok: j['ok'] == true, ms: j['ms'] as int?, error: j['error'] as String?);
  }

  // ─── The assistant ───────────────────────────────────────────────────────

  Future<AssistantModel> assistant() async =>
      AssistantModel((await _authorized('GET', 'admin/assistant'))! as Json);

  /// «اختر النموذج»: what the server at [baseUrl] offers. [apiKey] null
  /// uses the saved key (same address).
  Future<List<String>> listModels(String provider, String baseUrl, {String? apiKey}) async {
    final j =
        (await _authorized('POST', 'admin/assistant/models', {
              'provider': provider,
              'base_url': baseUrl,
              'api_key': ?apiKey,
            }))!
            as Json;
    return [for (final m in j['models']! as List) m as String];
  }

  /// Switches only after the model answers. [apiKey]: null keeps the saved
  /// one, "" removes it.
  Future<AssistantModel> setModel({
    required String provider,
    required String baseUrl,
    required String model,
    String? apiKey,
    int timeoutSeconds = 60,
  }) async => AssistantModel(
    (await _authorized('PUT', 'admin/assistant/model', {
          'provider': provider,
          'base_url': baseUrl,
          'model': model,
          'api_key': ?apiKey,
          'timeout_seconds': timeoutSeconds,
        }))!
        as Json,
  );

  Future<AssistantStats> assistantStats({int hours = 24}) async =>
      AssistantStats((await _authorized('GET', 'admin/assistant/stats?hours=$hours'))! as Json);

  Future<Map<String, PromptSet>> prompts() async {
    final j = (await _authorized('GET', 'admin/assistant/prompts'))! as Json;
    return {for (final e in j.entries) e.key: PromptSet(e.key, e.value! as Json)};
  }

  Future<PromptVersionView> newDraft(String kind, String text, {String? note}) async =>
      PromptVersionView(
        (await _authorized('POST', 'admin/assistant/prompts', {
              'kind': kind,
              'text': text,
              'note': ?note,
            }))!
            as Json,
      );

  Future<PromptVersionView> editDraft(int id, String text) async => PromptVersionView(
    (await _authorized('PATCH', 'admin/assistant/prompts/$id', {'text': text}))! as Json,
  );

  Future<PromptVersionView> testDraft(int id) async =>
      PromptVersionView((await _authorized('POST', 'admin/assistant/prompts/$id/test'))! as Json);

  Future<PromptVersionView> activate(int id) async => PromptVersionView(
    (await _authorized('POST', 'admin/assistant/prompts/$id/activate'))! as Json,
  );

  Future<void> rollback(String kind) =>
      _authorized('POST', 'admin/assistant/prompts/$kind/rollback');

  Future<List<SafetyExample>> safetyExamples() async => [
    for (final e in (await _authorized('GET', 'admin/assistant/examples'))! as List)
      SafetyExample(e as Json),
  ];

  Future<SafetyExample> addExample(String text, String label, {String? note}) async =>
      SafetyExample(
        (await _authorized('POST', 'admin/assistant/examples', {
              'text': text,
              'label': label,
              'note': ?note,
            }))!
            as Json,
      );

  Future<SafetyExample> editExample(int id, {String? text, String? label, bool? enabled}) async =>
      SafetyExample(
        (await _authorized('PATCH', 'admin/assistant/examples/$id', {
              'text': ?text,
              'label': ?label,
              'enabled': ?enabled,
            }))!
            as Json,
      );

  /// The prompts in use against the built-in cases and the examples.
  Future<TestResult> testCurrent() async =>
      TestResult((await _authorized('POST', 'admin/assistant/test'))! as Json);

  Future<SandboxTurn> sandbox(
    List<({String role, String text})> history,
    String text, {
    List<int> drafts = const [],
  }) async => SandboxTurn(
    (await _authorized('POST', 'admin/assistant/sandbox', {
          'history': [
            for (final m in history) {'role': m.role, 'text': m.text},
          ],
          'text': text,
          'drafts': drafts,
        }))!
        as Json,
  );

  // ─── Patients (Phase 5) ──────────────────────────────────────────────────

  Future<List<PatientRow>> patients({String? query}) async {
    final path = query == null || query.trim().isEmpty
        ? 'admin/patients'
        : 'admin/patients?${Uri(queryParameters: {'q': query.trim()}).query}';
    return [for (final p in (await _authorized('GET', path))! as List) PatientRow(p as Json)];
  }

  /// Every opening is logged on the server.
  Future<PatientFileView> patientFile(String id) async =>
      PatientFileView((await _authorized('GET', 'admin/patients/$id/file'))! as Json);

  // ─── Plumbing ────────────────────────────────────────────────────────────

  Future<void> _refresh() async {
    if (_sessionToken == null) throw const SyncApiException(401, 'signed_out');
    final j = await _send('POST', 'admin/token', body: {'session_token': _sessionToken});
    _accessToken = (j! as Json)['access_token']! as String;
  }

  Future<Object?> _authorized(String method, String path, [Object? body]) async {
    if (_accessToken == null) await _refresh();
    try {
      return await _send(method, path, body: body, token: _accessToken);
    } on SyncApiException catch (e) {
      if (e.status != 401 || e.code != 'token_expired') rethrow;
      await _refresh();
      return _send(method, path, body: body, token: _accessToken);
    }
  }

  Future<Object?> _send(String method, String path, {Object? body, String? token}) async {
    final req = http.Request(method, baseUrl.resolve(path))
      ..headers.addAll({
        'content-type': 'application/json',
        'authorization': ?(token == null ? null : 'Bearer $token'),
      });
    if (body != null) req.body = jsonEncode(body);
    final http.Response r;
    try {
      r = await http.Response.fromStream(await _client.send(req).timeout(timeout));
    } on TimeoutException {
      throw const SyncNetworkException('timeout');
    } on http.ClientException catch (e) {
      throw SyncNetworkException(e.message);
    }
    final text = utf8.decode(r.bodyBytes);
    final Object? j = text.isEmpty ? null : jsonDecode(text);
    if (r.statusCode >= 400) {
      final detail = j is Map ? j['detail'] : null;
      throw SyncApiException(r.statusCode, detail is String ? detail : 'http_${r.statusCode}');
    }
    return j;
  }
}
