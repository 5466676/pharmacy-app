import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sync/sync_controller.dart';
import 'sync_store.dart';

/// What Doaya online last said about this pharmacy, as its server passed it
/// on (`GET /control`), kept on the device in `sync_state`.
class SystemLock {
  const SystemLock({required this.state, this.reason, this.licenceUntil});

  factory SystemLock.fromJson(Map<String, Object?> j) => SystemLock(
    state: j['state'] as String? ?? 'standalone',
    reason: j['reason'] as String?,
    licenceUntil: j['licence_until'] == null
        ? null
        : DateTime.tryParse(j['licence_until']! as String)?.toUtc(),
  );

  /// standalone | active | pending | suspended | stopped | removed.
  final String state;
  final String? reason;

  /// Until when the system works without hearing from Doaya online.
  final DateTime? licenceUntil;

  static const lockedStates = {'stopped', 'removed'};

  Map<String, Object?> toJson() => {
    'state': state,
    'reason': reason,
    'licence_until': licenceUntil?.toIso8601String(),
  };

  bool get stoppedByOwner => lockedStates.contains(state);

  bool licenceExpiredAt(DateTime now) => licenceUntil != null && now.isAfter(licenceUntil!);

  bool lockedAt(DateTime now) => stoppedByOwner || licenceExpiredAt(now);

  /// Whole days left before the licence runs out (null: no licence).
  int? daysLeftAt(DateTime now) =>
      licenceUntil == null ? null : licenceUntil!.difference(now).inHours ~/ 24;
}

/// The lock as it was when the app started. Selling never locks in the
/// middle of a day: a new answer from the server only counts at the next
/// start.
class LockSnapshot {
  const LockSnapshot({this.lock, this.locked = false, this.daysLeft});

  factory LockSnapshot.at(SystemLock? lock, DateTime now) => LockSnapshot(
    lock: lock,
    locked: lock?.lockedAt(now) ?? false,
    daysLeft: lock?.daysLeftAt(now),
  );

  final SystemLock? lock;
  final bool locked;
  final int? daysLeft;

  /// Show a reminder to connect when the licence is close to running out.
  bool get endingSoon => !locked && daysLeft != null && daysLeft! <= warnDays;

  static const warnDays = 5;
}

const _key = 'control';

Future<SystemLock?> loadLock(DriftSyncStore store) async {
  final raw = await store.getState(_key);
  if (raw == null) return null;
  try {
    return SystemLock.fromJson(jsonDecode(raw) as Map<String, Object?>);
  } on FormatException {
    return null;
  }
}

/// Keeps the server's answer. A server never linked to Doaya online
/// ("standalone") doesn't replace an earlier answer: unlinking must not
/// lift a lock or a licence.
Future<void> saveLock(DriftSyncStore store, Map<String, Object?> json) async {
  final lock = SystemLock.fromJson(json);
  if (lock.state == 'standalone' && await store.getState(_key) != null) return;
  await store.setState(_key, jsonEncode(lock.toJson()));
}

/// The clock the lock is judged by (tests move it).
final lockClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Read once per start (see [LockSnapshot]).
final systemLockProvider = FutureProvider<LockSnapshot>((ref) async {
  final store = ref.watch(syncStoreProvider);
  if (store == null) return const LockSnapshot();
  return LockSnapshot.at(await loadLock(store), ref.read(lockClockProvider)().toUtc());
});
