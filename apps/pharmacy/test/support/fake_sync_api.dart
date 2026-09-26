import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_core/sync_testing.dart';
import 'package:doaya_pharmacy/sync/sync_api.dart';

import 'fake_central.dart';

/// A pharmacy server in memory for widget tests: the same sync rules as the
/// real one (InMemorySyncServer) plus accounts and linked devices.
class FakeSyncApi implements SyncApi {
  final server = InMemorySyncServer();

  /// Doaya online behind the pharmacy's server (cases, orders).
  final central = FakeCentral();
  final _accounts = <String, ({String password, String role, String name, String? employeeId})>{};
  final _devices = <String, ({String name, String token, bool revoked})>{};
  String? pharmacyName;

  /// The PC is off / not on the Wi-Fi.
  bool offline = false;

  /// The fingerprint of the server's certificate; changing it plays a
  /// reinstalled server (or an impostor) at the same address.
  String certificate = 'c0ffee' * 10 + 'beef';

  /// Fails like a pinned client does when [url] doesn't pin [certificate].
  void _reachable([Uri? url]) {
    if (offline) throw const SyncNetworkException('offline');
    final pin = url == null ? null : serverPin(url);
    if (pin != null && pin != certificate) throw const SyncCertificateException();
  }

  void addAccount(String phone, String password, {required String name, String? employeeId}) =>
      _accounts[phone] = (
        password: password,
        role: 'pharmacist_employee',
        name: name,
        employeeId: employeeId,
      );

  void unlink(String deviceId) {
    final d = _devices[deviceId]!;
    _devices[deviceId] = (name: d.name, token: d.token, revoked: true);
  }

  Iterable<String> get deviceNames => _devices.values.map((d) => d.name);

  LinkResult _linkDevice(String phone, String deviceId, String deviceName) {
    final a = _accounts[phone]!;
    final token = 'token-$deviceId';
    _devices[deviceId] = (name: deviceName, token: token, revoked: false);
    return LinkResult(
      pharmacyId: 'ph',
      pharmacyName: pharmacyName!,
      userId: phone,
      userName: a.name,
      role: a.role,
      employeeId: a.employeeId,
      deviceToken: token,
      accessToken: 'access',
    );
  }

  @override
  Future<Uri?> probe(Uri url) async =>
      offline ? null : (serverPin(url) == null ? pinServer(url, certificate) : url);

  @override
  Future<bool> needsSetup(Uri url) async {
    _reachable();
    return pharmacyName == null;
  }

  @override
  Future<LinkResult> setup(
    Uri url, {
    required String pharmacyName,
    required String ownerName,
    required String ownerPhone,
    required String password,
    required String ownerEmployeeId,
    required String deviceId,
    required String deviceName,
  }) async {
    _reachable();
    if (this.pharmacyName != null) throw const SyncApiException(409, 'already_set_up');
    this.pharmacyName = pharmacyName;
    _accounts[ownerPhone] = (
      password: password,
      role: 'pharmacist_owner',
      name: ownerName,
      employeeId: ownerEmployeeId,
    );
    return _linkDevice(ownerPhone, deviceId, deviceName);
  }

  @override
  Future<LinkResult> link(
    Uri url, {
    required String phone,
    required String password,
    required String deviceId,
    required String deviceName,
  }) async {
    _reachable();
    final a = _accounts[phone];
    if (a == null || a.password != password) {
      throw const SyncApiException(401, 'bad_credentials');
    }
    return _linkDevice(phone, deviceId, deviceName);
  }

  @override
  SyncRemote remote(Uri url, {required String deviceId, required String deviceToken}) =>
      _FakeRemote(this, url, deviceId, deviceToken);
}

class _FakeRemote implements SyncRemote {
  _FakeRemote(this.api, this.url, this.deviceId, this.token);
  final FakeSyncApi api;
  final Uri url;
  final String deviceId;
  final String token;

  void _check() {
    api._reachable(url);
    final d = api._devices[deviceId];
    if (d == null || d.revoked || d.token != token) {
      throw const SyncApiException(401, 'device_unlinked');
    }
  }

  @override
  Future<PushResult> push(List<OutgoingChange> changes) {
    _check();
    return api.server.transportFor(deviceId).push(changes);
  }

  @override
  Future<PullPage> pull({required int after, required int limit}) {
    _check();
    return api.server.transportFor(deviceId).pull(after: after, limit: limit);
  }

  Object? _central(String method, String path, [Object? body]) {
    final r = api.central.handle(method, path, body);
    // Orders carry their total like the server's.
    if (r is Map<String, Object?> && r.containsKey('lines')) return r.withTotal();
    if (r is List) {
      return [
        for (final x in r) x is Map<String, Object?> && x.containsKey('lines') ? x.withTotal() : x,
      ];
    }
    return r;
  }

  @override
  Future<Object?> putJson(String path, Object body) async {
    _check();
    return _central('PUT', path, body);
  }

  @override
  Future<Object?> deleteJson(String path) async {
    _check();
    return _central('DELETE', path);
  }

  @override
  Future<Object?> getJson(String path) async {
    _check();
    if (path.startsWith('central')) return _central('GET', path);
    return switch (path) {
      'devices' => [
        for (final e in api._devices.entries)
          {'id': e.key, 'name': e.value.name, 'revoked': e.value.revoked, 'last_seen_at': null},
      ],
      'backups' => {'latest': '2026-09-25T02:00:00Z', 'count': 1, 'error': null},
      'users' => [
        for (final e in api._accounts.entries)
          {'phone': e.key, 'name': e.value.name, 'employee_id': e.value.employeeId},
      ],
      _ => throw SyncApiException(404, 'not_found: $path'),
    };
  }

  @override
  Future<Object?> postJson(String path, [Object? body]) async {
    _check();
    if (path.startsWith('central')) return _central('POST', path, body);
    if (path == 'users') {
      final b = body! as Map<String, Object?>;
      final phone = b['phone']! as String;
      if (api._accounts.containsKey(phone)) throw const SyncApiException(409, 'phone_taken');
      api.addAccount(
        phone,
        b['password']! as String,
        name: b['name']! as String,
        employeeId: b['employee_id'] as String?,
      );
      return {'phone': phone};
    }
    final unlink = RegExp(r'^devices/(.+)/unlink$').firstMatch(path);
    if (unlink != null) {
      api.unlink(unlink[1]!);
      return null;
    }
    throw SyncApiException(404, 'not_found: $path');
  }

  @override
  void close() {}
}
