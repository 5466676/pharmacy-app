import 'dart:async';

import 'package:doaya_core/doaya_core.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/people_repository.dart';
import '../data/sync_store.dart';
import '../providers.dart';
import 'sync_api.dart';

/// What the top bar shows about sync.
enum SyncPhase {
  /// This device isn't linked to a server: it works on its own.
  notLinked,

  /// Linked and up to date (or waiting for the next run).
  idle,
  syncing,

  /// The server couldn't be reached (PC off, not on the Wi-Fi…). Selling
  /// goes on; changes wait in the outbox.
  serverUnreachable,

  /// The owner unlinked this device.
  unlinked,

  /// Another certificate answers at the server's address (the server was
  /// reinstalled, or another machine poses as it). Nothing is sent until
  /// the device is linked again.
  wrongServer,

  /// Something else went wrong; retried on the next run.
  failed,
}

/// This device's link to its server, kept in `sync_state`.
class SyncLink {
  const SyncLink({
    required this.url,
    required this.deviceToken,
    required this.pharmacyName,
    required this.userName,
    required this.role,
    this.employeeId,
  });

  final Uri url;
  final String deviceToken;
  final String pharmacyName;
  final String userName;
  final String role;
  final String? employeeId;

  bool get isOwner => role == 'pharmacist_owner';
}

class SyncStatus {
  const SyncStatus({
    this.phase = SyncPhase.notLinked,
    this.link,
    this.lastSyncAt,
    this.cursor = 0,
    this.latest = 0,
    this.error,
  });

  final SyncPhase phase;
  final SyncLink? link;
  final DateTime? lastSyncAt;

  /// Download progress while syncing (cursor of latest).
  final int cursor;
  final int latest;
  final String? error;

  bool get linked => link != null;

  SyncStatus copyWith({
    SyncPhase? phase,
    SyncLink? link,
    DateTime? lastSyncAt,
    int? cursor,
    int? latest,
    String? error,
  }) => SyncStatus(
    phase: phase ?? this.phase,
    link: link ?? this.link,
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    cursor: cursor ?? this.cursor,
    latest: latest ?? this.latest,
    error: error,
  );
}

/// How often a linked device syncs by itself (null: never; tests).
final syncIntervalProvider = Provider<Duration?>((ref) => const Duration(seconds: 30));

/// This device's sync store (null before first-run setup).
final syncStoreProvider = Provider<DriftSyncStore?>((ref) {
  final device = ref.watch(thisDeviceProvider).value;
  if (device == null) return null;
  return DriftSyncStore(ref.watch(databaseProvider), deviceId: device.id);
});

/// Changes waiting to be pushed, live.
final pendingChangesProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  final c = db.syncOutbox.id.count();
  return (db.selectOnly(db.syncOutbox)..addColumns([c])).watchSingle().map((r) => r.read(c) ?? 0);
});

/// Linking, the sync loop and its status.
class SyncController extends Notifier<SyncStatus> {
  Timer? _timer;
  SyncRemote? _client;
  Future<void>? _running;

  DriftSyncStore? get _store => ref.read(syncStoreProvider);

  @override
  SyncStatus build() {
    ref.watch(syncStoreProvider);
    ref.onDispose(() {
      _timer?.cancel();
      _client?.close();
    });
    scheduleMicrotask(_load);
    return const SyncStatus();
  }

  Future<void> _load() async {
    final store = _store;
    if (store == null) return;
    final url = await store.getState('server_url');
    final token = await store.getState('device_token');
    if (url == null || token == null) return;
    final last = await store.getState('last_sync_at');
    state = state.copyWith(
      phase: SyncPhase.idle,
      link: SyncLink(
        url: Uri.parse(url),
        deviceToken: token,
        pharmacyName: await store.getState('pharmacy_name') ?? '',
        userName: await store.getState('user_name') ?? '',
        role: await store.getState('role') ?? '',
        employeeId: await store.getState('employee_id'),
      ),
      lastSyncAt: last == null ? null : DateTime.tryParse(last),
    );
    _startTimer();
    unawaited(syncNow());
  }

  void _startTimer() {
    _timer?.cancel();
    final every = ref.read(syncIntervalProvider);
    if (every != null) _timer = Timer.periodic(every, (_) => syncNow());
  }

  /// The client for the linked server (devices, accounts…).
  SyncRemote? get client {
    final link = state.link;
    final device = ref.read(thisDeviceProvider).value;
    if (link == null || device == null) return null;
    return _client ??= ref
        .read(syncApiProvider)
        .remote(link.url, deviceId: device.id, deviceToken: link.deviceToken);
  }

  /// One run now (joins a run already going).
  Future<void> syncNow() => _running ??= _run().whenComplete(() => _running = null);

  Future<void> _run() async {
    final store = _store, c = client;
    if (store == null ||
        c == null ||
        state.phase == SyncPhase.unlinked ||
        state.phase == SyncPhase.wrongServer) {
      return;
    }
    state = state.copyWith(phase: SyncPhase.syncing);
    try {
      await SyncEngine(store, c).sync(
        onProgress: (p) => state = state.copyWith(cursor: p.cursor, latest: p.latest),
      );
      final now = DateTime.now();
      await store.setState('last_sync_at', now.toUtc().toIso8601String());
      state = state.copyWith(phase: SyncPhase.idle, lastSyncAt: now);
    } on SyncCertificateException {
      state = state.copyWith(phase: SyncPhase.wrongServer);
    } on SyncNetworkException {
      state = state.copyWith(phase: SyncPhase.serverUnreachable);
    } on SyncApiException catch (e) {
      state = state.copyWith(
        phase: e.deviceUnlinked ? SyncPhase.unlinked : SyncPhase.failed,
        error: e.code,
      );
    } on Object catch (e) {
      state = state.copyWith(phase: SyncPhase.failed, error: '$e');
    }
  }

  /// The counter PC creates the pharmacy on an empty server and uploads its
  /// whole history.
  Future<LinkResult> setUpServer(
    Uri url, {
    required String ownerPhone,
    required String password,
    required EmployeeRow owner,
  }) async {
    final device = ref.read(thisDeviceProvider).value!;
    final people = ref.read(peopleProvider);
    final result = await ref
        .read(syncApiProvider)
        .setup(
          url,
          pharmacyName: await people.setting(SettingKeys.pharmacyName) ?? device.name,
          ownerName: owner.name,
          ownerPhone: ownerPhone,
          password: password,
          ownerEmployeeId: owner.id,
          deviceId: device.id,
          deviceName: device.name,
        );
    await _saveLink(url, result);
    return result;
  }

  /// Links this device to an existing pharmacy with a phone + password.
  Future<LinkResult> link(Uri url, {required String phone, required String password}) async {
    final device = ref.read(thisDeviceProvider).value!;
    final result = await ref
        .read(syncApiProvider)
        .link(url, phone: phone, password: password, deviceId: device.id, deviceName: device.name);
    await _saveLink(url, result);
    return result;
  }

  /// A new device (phone, second laptop) joins an existing pharmacy from the
  /// first-run screen: links with a phone + password, registers only its
  /// own device row, then downloads everything. The account's employee is
  /// signed in by itself on this device from then on.
  Future<LinkResult> joinPharmacy(
    Uri url, {
    required String phone,
    required String password,
    required String deviceName,
  }) async {
    final id = ref.read(idsProvider).generate();
    final result = await ref
        .read(syncApiProvider)
        .link(url, phone: phone, password: password, deviceId: id, deviceName: deviceName);
    await ref.read(peopleProvider).registerDevice(id: id, name: deviceName);
    ref.invalidate(thisDeviceProvider);
    await ref.read(thisDeviceProvider.future);
    await _saveLink(url, result, autoSignIn: true);
    return result;
  }

  /// Drops the link to the server (after it was unlinked or reinstalled)
  /// so the device can be linked again. Local data stays; it all goes up
  /// again on the next link, and the download starts over.
  Future<void> forgetServer() async {
    final store = _store;
    if (store == null) return;
    await _running;
    for (final key in [
      'server_url',
      'device_token',
      'pharmacy_id',
      'pharmacy_name',
      'user_name',
      'role',
      'employee_id',
      'cursor',
      'last_sync_at',
    ]) {
      await store.setState(key, null);
    }
    _timer?.cancel();
    _client?.close();
    _client = null;
    state = const SyncStatus();
  }

  Future<void> _saveLink(Uri url, LinkResult r, {bool autoSignIn = false}) async {
    final store = _store!;
    if (autoSignIn && r.employeeId != null) await store.setState('auto_employee_id', r.employeeId);
    for (final MapEntry(:key, :value) in {
      'server_url': url.toString(),
      'device_token': r.deviceToken,
      'pharmacy_id': r.pharmacyId,
      'pharmacy_name': r.pharmacyName,
      'user_name': r.userName,
      'role': r.role,
      'employee_id': r.employeeId,
    }.entries) {
      await store.setState(key, value);
    }
    // Whatever this device already has goes up (a fresh phone: just its
    // own device row).
    await store.seedOutbox();
    _client?.close();
    _client = null;
    state = const SyncStatus();
    await _load();
    await _running;
  }
}

final syncProvider = NotifierProvider<SyncController, SyncStatus>(SyncController.new);
