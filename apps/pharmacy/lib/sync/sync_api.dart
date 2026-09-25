import 'package:doaya_core/doaya_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Everything the app asks of a Doaya server, so tests can swap in a fake
/// (widget tests can't make real HTTP calls).
abstract interface class SyncApi {
  Future<bool> ping(Uri url);
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

  @override
  Future<bool> ping(Uri url) => HttpSyncClient.ping(url);

  @override
  Future<bool> needsSetup(Uri url) => HttpSyncClient.needsSetup(url);

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
  }) => HttpSyncClient.setup(
    url,
    pharmacyName: pharmacyName,
    ownerName: ownerName,
    ownerPhone: ownerPhone,
    password: password,
    ownerEmployeeId: ownerEmployeeId,
    deviceId: deviceId,
    deviceName: deviceName,
  );

  @override
  Future<LinkResult> link(
    Uri url, {
    required String phone,
    required String password,
    required String deviceId,
    required String deviceName,
  }) => HttpSyncClient.link(
    url,
    phone: phone,
    password: password,
    deviceId: deviceId,
    deviceName: deviceName,
  );

  @override
  SyncRemote remote(Uri url, {required String deviceId, required String deviceToken}) =>
      HttpSyncClient(baseUrl: url, deviceId: deviceId, deviceToken: deviceToken);
}

final syncApiProvider = Provider<SyncApi>((ref) => const HttpSyncApi());
