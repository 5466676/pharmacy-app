import 'package:doaya_pharmacy/data/database.dart';
import 'package:doaya_pharmacy/data/sync_store.dart';
import 'package:doaya_pharmacy/data/system_lock.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

final now = DateTime.utc(2026, 9, 26, 12);

Map<String, Object?> answer(String state, {DateTime? until, String? reason}) => {
  'state': state,
  'reason': reason,
  'licence_until': until?.toIso8601String(),
  'locked': false, // the app judges by its own clock
};

void main() {
  group('SystemLock', () {
    test('stopped and removed lock at once, whatever the licence', () {
      for (final s in ['stopped', 'removed']) {
        final l = SystemLock.fromJson(answer(s, until: now.add(const Duration(days: 20))));
        expect(l.lockedAt(now), isTrue, reason: s);
      }
    });

    test('active and suspended work until the licence runs out', () {
      for (final s in ['active', 'suspended']) {
        final l = SystemLock.fromJson(answer(s, until: now.add(const Duration(days: 3))));
        expect(l.lockedAt(now), isFalse);
        expect(l.lockedAt(now.add(const Duration(days: 4))), isTrue);
        expect(l.daysLeftAt(now), 3);
      }
    });

    test('never linked to Doaya online: never locked', () {
      final l = SystemLock.fromJson(answer('standalone'));
      expect(l.lockedAt(now.add(const Duration(days: 999))), isFalse);
      expect(l.daysLeftAt(now), isNull);
    });

    test('the snapshot is taken once, at start', () {
      final l = SystemLock.fromJson(answer('active', until: now.add(const Duration(hours: 1))));
      final snap = LockSnapshot.at(l, now);
      expect(snap.locked, isFalse);
      // Hours later the licence has run out, but the snapshot still says
      // open: selling never stops in the middle of a day.
      expect(snap.locked, isFalse);
      expect(LockSnapshot.at(l, now.add(const Duration(hours: 2))).locked, isTrue);
    });

    test('a reminder when the licence is close to running out', () {
      LockSnapshot at(int days) => LockSnapshot.at(
        SystemLock.fromJson(answer('active', until: now.add(Duration(days: days, hours: 1)))),
        now,
      );
      expect(at(30).endingSoon, isFalse);
      expect(at(LockSnapshot.warnDays).endingSoon, isTrue);
      expect(LockSnapshot.at(null, now).endingSoon, isFalse);
    });
  });

  group('kept on the device', () {
    late AppDatabase db;
    late DriftSyncStore store;
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      store = DriftSyncStore(db, deviceId: 'd1');
    });
    tearDown(() => db.close());

    test('survives a restart and keeps the reason', () async {
      expect(await loadLock(store), isNull);
      await saveLock(store, answer('stopped', until: now, reason: 'انتهى العقد'));
      final again = await loadLock(DriftSyncStore(db, deviceId: 'd1'));
      expect(again!.state, 'stopped');
      expect(again.reason, 'انتهى العقد');
      expect(again.licenceUntil, now);
    });

    test('a server unlinked from Doaya online does not lift a lock', () async {
      await saveLock(store, answer('stopped', until: now));
      await saveLock(store, answer('standalone'));
      expect((await loadLock(store))!.state, 'stopped');
    });

    test('a newer answer replaces the old one', () async {
      await saveLock(store, answer('stopped', until: now));
      await saveLock(store, answer('active', until: now.add(const Duration(days: 30))));
      expect((await loadLock(store))!.lockedAt(now), isFalse);
    });
  });
}
