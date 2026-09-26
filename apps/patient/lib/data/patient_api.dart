import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:doaya_core/doaya_core.dart' show SyncApiException, SyncNetworkException;
import 'package:http/http.dart' as http;

import 'models.dart';

export 'package:doaya_core/doaya_core.dart' show SyncApiException, SyncNetworkException;

/// A signed-in patient: the long-lived session secret (kept on the device)
/// and the short access token traded for it.
class PatientSession {
  const PatientSession({required this.sessionToken, required this.patient});

  final String sessionToken;
  final Patient patient;

  Map<String, Object?> toJson() => {'session_token': sessionToken, 'patient': patient.toJson()};

  static PatientSession? fromJsonString(String? s) {
    if (s == null) return null;
    try {
      final j = jsonDecode(s) as Map<String, Object?>;
      return PatientSession(
        sessionToken: j['session_token']! as String,
        patient: Patient.fromJson(j['patient']! as Map<String, Object?>),
      );
    } on Object {
      return null;
    }
  }
}

/// Doaya online for the patient. Errors: [SyncApiException] with the
/// server's short code (`phone_taken`, `bad_credentials`…) or
/// [SyncNetworkException] (no internet).
class PatientApi {
  PatientApi(this.baseUrl, {http.Client? client, this.timeout = const Duration(seconds: 60)})
    : _client = client ?? http.Client();

  final Uri baseUrl;
  final Duration timeout;
  final http.Client _client;

  String? _sessionToken;
  String? _accessToken;

  /// Resumes a saved session (the access token is fetched when needed).
  void resume(String sessionToken) {
    _sessionToken = sessionToken;
    _accessToken = null;
  }

  void forget() => _sessionToken = _accessToken = null;

  String? get accessToken => _accessToken;

  // ─── Account ─────────────────────────────────────────────────────────────

  Future<PatientSession> register({
    required String name,
    required String phone,
    required String password,
    int? birthYear,
    String? sex,
    String? city,
  }) async => _signedIn(
    await _post('patients/register', {
      'name': name,
      'phone': phone,
      'password': password,
      'birth_year': birthYear,
      'sex': sex,
      'city': city,
    }),
  );

  Future<PatientSession> login(String phone, String password) async =>
      _signedIn(await _post('patients/login', {'phone': phone, 'password': password}));

  PatientSession _signedIn(Object? j) {
    final m = j! as Map<String, Object?>;
    _sessionToken = m['session_token']! as String;
    _accessToken = m['access_token']! as String;
    return PatientSession(
      sessionToken: _sessionToken!,
      patient: Patient.fromJson(m['patient']! as Map<String, Object?>),
    );
  }

  Future<Patient> me() async =>
      Patient.fromJson((await _authorized('GET', 'patients/me'))! as Map<String, Object?>);

  Future<Patient> updateMe(Map<String, Object?> fields) async => Patient.fromJson(
    (await _authorized('PATCH', 'patients/me', fields))! as Map<String, Object?>,
  );

  Future<void> logout() async {
    try {
      await _authorized('POST', 'patients/logout');
    } finally {
      forget();
    }
  }

  // ─── Pharmacies ──────────────────────────────────────────────────────────

  Future<List<PharmacyBrief>> directory({String? city, String? query}) async {
    final uri = baseUrl
        .resolve('directory')
        .replace(
          queryParameters: {
            if (city != null && city.isNotEmpty) 'city': city,
            if (query != null && query.isNotEmpty) 'q': query,
          },
        );
    return [
      for (final p in (await _send('GET', uri))! as List)
        PharmacyBrief.fromJson(p as Map<String, Object?>),
    ];
  }

  Future<PharmacyBrief> byCode(String code) async => PharmacyBrief.fromJson(
    (await _send('GET', baseUrl.resolve('directory/code/${Uri.encodeComponent(code.trim())}')))!
        as Map<String, Object?>,
  );

  // ─── Shelf and orders ────────────────────────────────────────────────────

  /// The pharmacy's shelf, available first; [query] matches trade, Arabic
  /// and ingredient names.
  Future<List<ShelfItem>> shelf(
    String pharmacyId, {
    String? query,
    bool availableOnly = false,
    int limit = 50,
    int offset = 0,
  }) async {
    final uri = baseUrl
        .resolve('directory/${Uri.encodeComponent(pharmacyId)}/shelf')
        .replace(
          queryParameters: {
            if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
            if (availableOnly) 'available_only': 'true',
            'limit': '$limit',
            'offset': '$offset',
          },
        );
    return [
      for (final i in (await _send('GET', uri))! as List)
        ShelfItem.fromJson(i as Map<String, Object?>),
    ];
  }

  Future<ShelfItem> shelfItem(String pharmacyId, String productId) async => ShelfItem.fromJson(
    (await _send(
          'GET',
          baseUrl.resolve(
            'directory/${Uri.encodeComponent(pharmacyId)}/shelf/${Uri.encodeComponent(productId)}',
          ),
        ))!
        as Map<String, Object?>,
  );

  PatientOrder _o(Object? j) => PatientOrder.fromJson(j! as Map<String, Object?>);

  /// Product id → quantity asked for; the pharmacist settles the final ones.
  Future<PatientOrder> placeOrder(Map<String, int> lines, {String? note, String? photoId}) async =>
      _o(
        await _authorized('POST', 'orders', {
          'photo_id': ?photoId,
          'lines': [
            for (final MapEntry(:key, :value) in lines.entries)
              {'product_id': key, 'quantity': value},
          ],
          'note': ?note,
        }),
      );

  Future<List<PatientOrder>> orders() async => [
    for (final o in (await _authorized('GET', 'orders'))! as List) _o(o),
  ];

  Future<PatientOrder> order(String id) async => _o(await _authorized('GET', 'orders/$id'));

  Future<PatientOrder> cancelOrder(String id) async =>
      _o(await _authorized('POST', 'orders/$id/cancel'));

  // ─── Photos ──────────────────────────────────────────────────────────────

  /// A prescription photo in the chat: it goes to the pharmacist with the
  /// case.
  Future<Consultation> sendPhoto(String consultationId, Uint8List bytes, String filename) async =>
      _c(await _upload('consultations/$consultationId/photos', bytes, filename));

  /// A photo to attach to an order ([placeOrder]'s `photoId`).
  Future<String> uploadPhoto(Uint8List bytes, String filename) async =>
      ((await _upload('photos', bytes, filename))! as Map<String, Object?>)['id']! as String;

  /// A photo the patient sent (the app shows it from memory).
  Future<Uint8List> photo(String id) async {
    Future<http.Response> get() => _client
        .get(baseUrl.resolve('photos/$id'), headers: {'authorization': 'Bearer $_accessToken'})
        .timeout(timeout);
    if (_accessToken == null) await _refresh();
    try {
      var r = await get();
      if (r.statusCode == 401) {
        await _refresh();
        r = await get();
      }
      if (r.statusCode != 200) throw SyncApiException(r.statusCode, 'photo_not_found');
      return r.bodyBytes;
    } on TimeoutException {
      throw const SyncNetworkException('timeout');
    } on http.ClientException catch (e) {
      throw SyncNetworkException(e.message);
    }
  }

  Future<Object?> _upload(String path, Uint8List bytes, String filename) async {
    Future<http.Response> send() async {
      final req = http.MultipartRequest('POST', baseUrl.resolve(path))
        ..headers['authorization'] = 'Bearer $_accessToken'
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
      return http.Response.fromStream(await _client.send(req).timeout(timeout));
    }

    if (_accessToken == null) await _refresh();
    try {
      var r = await send();
      if (r.statusCode == 401) {
        await _refresh();
        r = await send();
      }
      return _decode(r);
    } on TimeoutException {
      throw const SyncNetworkException('timeout');
    } on http.ClientException catch (e) {
      throw SyncNetworkException(e.message);
    }
  }

  // ─── Consultations ───────────────────────────────────────────────────────

  Consultation _c(Object? j) => Consultation.fromJson(j! as Map<String, Object?>);

  Future<List<Consultation>> consultations() async => [
    for (final c in (await _authorized('GET', 'consultations'))! as List) _c(c),
  ];

  Future<Consultation> startConsultation() async => _c(await _authorized('POST', 'consultations'));

  Future<Consultation> consultation(String id) async =>
      _c(await _authorized('GET', 'consultations/$id'));

  /// The patient's message: the assistant's answer (or the pharmacist's,
  /// once sent) comes back in the consultation.
  Future<Consultation> say(String id, String text) async =>
      _c(await _authorized('POST', 'consultations/$id/messages', {'text': text}));

  Future<Consultation> correctSummary(String id, Map<String, Object?> summary) async =>
      _c(await _authorized('PUT', 'consultations/$id/summary', summary));

  Future<Consultation> send(String id) async =>
      _c(await _authorized('POST', 'consultations/$id/send'));

  /// What changed since [since] (background checks).
  Future<Map<String, Object?>> updates({DateTime? since}) async =>
      (await _authorized(
            'GET',
            since == null
                ? 'updates'
                : 'updates?since=${Uri.encodeQueryComponent(since.toUtc().toIso8601String())}',
          ))!
          as Map<String, Object?>;

  /// The live-updates socket address, with a fresh access token (the
  /// server closes a socket opened with an expired one).
  Future<Uri> liveUri() async {
    await _refresh();
    return baseUrl
        .resolve('ws')
        .replace(
          scheme: baseUrl.scheme == 'https' ? 'wss' : 'ws',
          queryParameters: {'token': _accessToken!},
        );
  }

  // ─── Plumbing ────────────────────────────────────────────────────────────

  static const _json = {'content-type': 'application/json'};

  Future<Object?> _post(String path, Object? body) =>
      _send('POST', baseUrl.resolve(path), body: body);

  Future<void> _refresh() async {
    if (_sessionToken == null) throw const SyncApiException(401, 'signed_out');
    final j = await _post('patients/token', {'session_token': _sessionToken});
    _accessToken = (j! as Map<String, Object?>)['access_token']! as String;
  }

  Future<Object?> _authorized(String method, String path, [Object? body]) async {
    if (_accessToken == null) await _refresh();
    try {
      return await _send(method, baseUrl.resolve(path), body: body, token: _accessToken);
    } on SyncApiException catch (e) {
      if (e.status != 401 || e.code != 'token_expired') rethrow;
      await _refresh();
      return _send(method, baseUrl.resolve(path), body: body, token: _accessToken);
    }
  }

  Future<Object?> _send(String method, Uri uri, {Object? body, String? token}) async {
    final req = http.Request(method, uri)
      ..headers.addAll({..._json, 'authorization': ?(token == null ? null : 'Bearer $token')});
    if (body != null) req.body = jsonEncode(body);
    final http.Response r;
    try {
      r = await http.Response.fromStream(await _client.send(req).timeout(timeout));
    } on TimeoutException {
      throw const SyncNetworkException('timeout');
    } on http.ClientException catch (e) {
      throw SyncNetworkException(e.message);
    }
    return _decode(r);
  }

  Object? _decode(http.Response r) {
    final text = utf8.decode(r.bodyBytes);
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return text.isEmpty ? null : jsonDecode(text);
    }
    String code = 'http_${r.statusCode}';
    try {
      final d = (jsonDecode(text) as Map)['detail'];
      if (d is String) code = d;
    } on Object {
      // Not JSON: keep the status code.
    }
    throw SyncApiException(r.statusCode, code);
  }

  void close() => _client.close();
}
