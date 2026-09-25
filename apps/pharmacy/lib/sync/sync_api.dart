import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_core/pinned_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Everything the app asks of a Doaya server, so tests can swap in a fake
/// (widget tests can't make real HTTP calls). Every address carries the
/// server's pinned certificate (see `pinServer`).
abstract interface class SyncApi {
  /// Whether a Doaya server answers at [url]. Returns the address to use:
  /// a typed https address comes back with the server's certificate
  /// pinned (first contact). Null when nothing answers.
  Future<Uri?> probe(Uri url);
  Future<bool> needsSetup(Uri url);

  Future<LinkResult> setup(
    Uri url, {
    required String pharmacyName,
    required String ownerName,
    required String ownerPhone,
    required String password,
    required String ownerEmployeeId,
    required String deviceId,
    required String deviceName,
  });

  Future<LinkResult> link(
    Uri url, {
    required String phone,
    required String password,
    required String deviceId,
    required String deviceName,
  });

  SyncRemote remote(Uri url, {required String deviceId, required String deviceToken});
}

class HttpSyncApi implements SyncApi {
  const HttpSyncApi();

  /// Runs [call] with a client that trusts only [url]'s pinned certificate.
  static Future<T> _with<T>(Uri url, Future<T> Function(http.Client client) call) async {
    final client = clientFor(url);
    try {
      return await call(client);
    } finally {
      client.close();
    }
  }

  @override
  Future<Uri?> probe(Uri url) async {
    if (url.scheme == 'https' && serverPin(url) == null) {
      final fingerprint = await probeServerCertificate(url);
      if (fingerprint == null) return null;
      url = pinServer(url, fingerprint);
    }
    final target = url;
    return await _with(target, (c) => HttpSyncClient.ping(target, client: c)) ? target : null;
  }

  @override
  Future<bool> needsSetup(Uri url) => _with(url, (c) => HttpSyncClient.needsSetup(url, client: c));

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
  }) => _with(
    url,
    (c) => HttpSyncClient.setup(
      url,
      client: c,
      pharmacyName: pharmacyName,
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      password: password,
      ownerEmployeeId: ownerEmployeeId,
      deviceId: deviceId,
      deviceName: deviceName,
    ),
  );

  @override
  Future<LinkResult> link(
    Uri url, {
    required String phone,
    required String password,
    required String deviceId,
    required String deviceName,
  }) => _with(
    url,
    (c) => HttpSyncClient.link(
      url,
      client: c,
      phone: phone,
      password: password,
      deviceId: deviceId,
      deviceName: deviceName,
    ),
  );

  @override
  SyncRemote remote(Uri url, {required String deviceId, required String deviceToken}) =>
      HttpSyncClient(
        baseUrl: url,
        deviceId: deviceId,
        deviceToken: deviceToken,
        client: clientFor(url),
      );
}

final syncApiProvider = Provider<SyncApi>((ref) => const HttpSyncApi());
