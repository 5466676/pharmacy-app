import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'sync.dart';

/// An error answer from the server, with its short code (`bad_credentials`,
/// `device_unlinked`, `owner_only`…); the app shows its own Arabic message.
class SyncApiException implements Exception {
  const SyncApiException(this.status, this.code);
  final int status;
  final String code;

  bool get deviceUnlinked => code == 'device_unlinked' || code == 'account_disabled';

  @override
  String toString() => 'SyncApiException($status, $code)';
}

/// The server's certificate isn't the one this device pinned when it was
/// linked: another machine answers at that address, or the server was
/// reinstalled. Nothing is sent; the device must be linked again.
class SyncCertificateException implements Exception {
  const SyncCertificateException();

  @override
  String toString() => 'SyncCertificateException';
}

/// A server address carries the SHA-256 of the server's own certificate in
/// its fragment (`https://192.168.1.10:8000/#sha256=…`). There is no
/// certificate authority on a pharmacy's Wi-Fi, so each device pins the
/// certificate it met when it was linked (discovery announces it) and
/// refuses any other one. Fragments never go over the wire.
Uri pinServer(Uri url, String fingerprint) => url.replace(fragment: 'sha256=$fingerprint');

/// The fingerprint pinned in [url], if any.
String? serverPin(Uri url) =>
    url.fragment.startsWith('sha256=') ? url.fragment.substring('sha256='.length) : null;

/// The short form people compare by eye (the server prints the same):
/// `AB12-CD34`.
String serverCode(String fingerprint) {
  final f = fingerprint.substring(0, 8).toUpperCase();
  return '${f.substring(0, 4)}-${f.substring(4)}';
}

/// What linking a device returns; the app keeps it to stay signed in.
class LinkResult {
  const LinkResult({
    required this.pharmacyId,
    required this.pharmacyName,
    required this.userId,
    required this.userName,
    required this.role,
    required this.deviceToken,
    required this.accessToken,
    this.employeeId,
  });

  factory LinkResult.fromJson(Map<String, Object?> j) {
    final u = j['user']! as Map<String, Object?>;
    return LinkResult(
      pharmacyId: j['pharmacy_id']! as String,
      pharmacyName: j['pharmacy_name']! as String,
      userId: u['id']! as String,
      userName: u['name']! as String,
      role: u['role']! as String,
      employeeId: u['employee_id'] as String?,
      deviceToken: j['device_token']! as String,
      accessToken: j['access_token']! as String,
    );
  }

  final String pharmacyId;
  final String pharmacyName;
  final String userId;
  final String userName;
  final String role;

  /// The app's employee row this account signs in as.
  final String? employeeId;
  final String deviceToken;
  final String accessToken;

  bool get isOwner => role == 'pharmacist_owner';
}

/// A linked device's connection to its server: sync plus the few JSON
/// calls the app makes (devices, accounts). HTTP in the app; fakes in tests.
abstract interface class SyncRemote implements SyncTransport {
  Future<Object?> getJson(String path);
  Future<Object?> postJson(String path, [Object? body]);
  Future<Object?> putJson(String path, Object body);
  Future<Object?> deleteJson(String path);

  /// Raw bytes (a patient's prescription photo).
  Future<Uint8List> getBytes(String path);
  void close();
}

/// Talks to a Doaya server over HTTP. Sign-in calls are static; a linked
/// device makes an instance with its secret, and access tokens are fetched
/// and refreshed by themselves.
class HttpSyncClient implements SyncRemote {
  HttpSyncClient({
    required this.baseUrl,
    required this.deviceId,
    required this.deviceToken,
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  }) : _client = client ?? http.Client();

  final Uri baseUrl;
  final String deviceId;
  final String deviceToken;
  final Duration timeout;
  final http.Client _client;
  String? _accessToken;

  @override
  void close() => _client.close();

  // ─── Without a device (first run, linking) ─────────────────────────────

  /// Whether a server answers at [baseUrl] (used to confirm discovery).
  static Future<bool> ping(Uri baseUrl, {http.Client? client}) async {
    try {
      final r = await _send(
        client,
        (c) => c.get(baseUrl.resolve('health')),
        const Duration(seconds: 3),
      );
      return r.statusCode == 200 && (jsonDecode(r.body) as Map)['service'] == 'doaya';
    } on SyncNetworkException {
      return false;
    } on SyncCertificateException {
      return false;
    }
  }

  /// Whether the server still waits for its first pharmacy.
  static Future<bool> needsSetup(Uri baseUrl, {http.Client? client}) async {
    final r = await _send(client, (c) => c.get(baseUrl.resolve('setup')), _defaultTimeout);
    return (_decode(r) as Map<String, Object?>)['needs_setup']! as bool;
  }

  /// First run of a pharmacy's server: creates the pharmacy and its owner
  /// and links this device.
  static Future<LinkResult> setup(
    Uri baseUrl, {
    required String pharmacyName,
    required String ownerName,
    required String ownerPhone,
    required String password,
    required String ownerEmployeeId,
    required String deviceId,
    required String deviceName,
    http.Client? client,
  }) async {
    final r = await _send(
      client,
      (c) => c.post(
        baseUrl.resolve('setup'),
        headers: _json,
        body: jsonEncode({
          'pharmacy_name': pharmacyName,
          'owner_name': ownerName,
          'owner_phone': ownerPhone,
          'password': password,
          'owner_employee_id': ownerEmployeeId,
          'device': {'id': deviceId, 'name': deviceName},
        }),
      ),
      _defaultTimeout,
    );
    return LinkResult.fromJson(_decode(r) as Map<String, Object?>);
  }

  /// Phone number + password once; the device then stays signed in.
  static Future<LinkResult> link(
    Uri baseUrl, {
    required String phone,
    required String password,
    required String deviceId,
    required String deviceName,
    http.Client? client,
  }) async {
    final r = await _send(
      client,
      (c) => c.post(
        baseUrl.resolve('auth/link'),
        headers: _json,
        body: jsonEncode({
          'phone': phone,
          'password': password,
          'device': {'id': deviceId, 'name': deviceName},
        }),
      ),
      _defaultTimeout,
    );
    return LinkResult.fromJson(_decode(r) as Map<String, Object?>);
  }

  // ─── Linked device ─────────────────────────────────────────────────────

  @override
  Future<PushResult> push(List<OutgoingChange> changes) async {
    final body = jsonEncode({
      'changes': [for (final c in changes) c.toJson()],
    });
    final r = await _authorized(
      (c, h) => c.post(baseUrl.resolve('sync/push'), headers: h, body: body),
    );
    return PushResult.fromJson(_decode(r) as Map<String, Object?>);
  }

  @override
  Future<PullPage> pull({required int after, required int limit}) async {
    final uri = baseUrl
        .resolve('sync/pull')
        .replace(queryParameters: {'after': '$after', 'limit': '$limit'});
    final r = await _authorized((c, h) => c.get(uri, headers: h));
    return PullPage.fromJson(_decode(r) as Map<String, Object?>);
  }

  @override
  Future<Uint8List> getBytes(String path) async {
    final r = await _authorized((c, h) => c.get(baseUrl.resolve(path), headers: h));
    if (r.statusCode >= 200 && r.statusCode < 300) return r.bodyBytes;
    throw SyncApiException(r.statusCode, _code(r) ?? 'http_${r.statusCode}');
  }

  /// Any authorized GET/POST returning JSON (devices, users…).
  @override
  Future<Object?> getJson(String path) async =>
      _decode(await _authorized((c, h) => c.get(baseUrl.resolve(path), headers: h)));

  @override
  Future<Object?> postJson(String path, [Object? body]) async => _decode(
    await _authorized(
      (c, h) =>
          c.post(baseUrl.resolve(path), headers: h, body: body == null ? null : jsonEncode(body)),
    ),
  );

  @override
  Future<Object?> putJson(String path, Object body) async => _decode(
    await _authorized((c, h) => c.put(baseUrl.resolve(path), headers: h, body: jsonEncode(body))),
  );

  @override
  Future<Object?> deleteJson(String path) async =>
      _decode(await _authorized((c, h) => c.delete(baseUrl.resolve(path), headers: h)));

  Future<Object?> patchJson(String path, Object body) async => _decode(
    await _authorized((c, h) => c.patch(baseUrl.resolve(path), headers: h, body: jsonEncode(body))),
  );

  Future<void> _refresh() async {
    final r = await _send(
      _client,
      (c) => c.post(
        baseUrl.resolve('auth/token'),
        headers: _json,
        body: jsonEncode({'device_id': deviceId, 'device_token': deviceToken}),
      ),
      timeout,
    );
    _accessToken = (_decode(r) as Map<String, Object?>)['access_token']! as String;
  }

  /// Sends with a valid access token, fetching or refreshing it once.
  Future<http.Response> _authorized(
    Future<http.Response> Function(http.Client, Map<String, String>) call,
  ) async {
    if (_accessToken == null) await _refresh();
    Map<String, String> headers() => {..._json, 'authorization': 'Bearer $_accessToken'};
    var r = await _send(_client, (c) => call(c, headers()), timeout);
    if (r.statusCode == 401 && _code(r) == 'token_expired') {
      await _refresh();
      r = await _send(_client, (c) => call(c, headers()), timeout);
    }
    return r;
  }

  static const _json = {'content-type': 'application/json'};
  static const _defaultTimeout = Duration(seconds: 20);

  static Future<http.Response> _send(
    http.Client? client,
    Future<http.Response> Function(http.Client) call,
    Duration timeout,
  ) async {
    final c = client ?? http.Client();
    try {
      return await call(c).timeout(timeout);
    } on SyncCertificateException {
      rethrow;
    } on TimeoutException {
      throw const SyncNetworkException('timeout');
    } on http.ClientException catch (e) {
      throw SyncNetworkException(e.message);
    } on Exception catch (e) {
      // SocketException etc. (dart:io isn't imported: this stays web-safe).
      throw SyncNetworkException(e.toString());
    } finally {
      if (client == null) c.close();
    }
  }

  static String? _code(http.Response r) {
    try {
      final d = (jsonDecode(utf8.decode(r.bodyBytes)) as Map)['detail'];
      return d is String ? d : null;
    } on FormatException {
      return null;
    }
  }

  static Object? _decode(http.Response r) {
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return r.body.isEmpty ? null : jsonDecode(utf8.decode(r.bodyBytes));
    }
    throw SyncApiException(r.statusCode, _code(r) ?? 'http_${r.statusCode}');
  }
}
