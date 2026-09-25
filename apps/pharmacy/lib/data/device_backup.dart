import 'dart:io';

import 'database.dart';

/// Daily copies of this device's database into a folder (a USB stick, a
/// synced folder…), the newest [keep] kept. Made with SQLite's
/// `VACUUM INTO`, which is consistent while the app keeps selling. The
/// folder and the last backup time are device-local (`sync_state`, never
/// synced).
class DeviceBackup {
  DeviceBackup(this._db, {required this.defaultFolder, DateTime Function()? clock, this.keep = 30})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;

  /// Used until the owner picks another folder.
  final String defaultFolder;
  final int keep;
  final DateTime Function() _clock;

  static const every = Duration(hours: 24);
  static const _folderKey = 'backup_folder';
  static const _lastKey = 'last_backup_at';
  static final _name = RegExp(r'^doaya-\d{8}-\d{6}(-\d+)?\.sqlite$');

  Future<String?> _get(String key) async =>
      (await (_db.select(_db.syncState)..where((t) => t.key.equals(key))).getSingleOrNull())?.value;

  Future<void> _set(String key, String value) => _db
      .into(_db.syncState)
      .insertOnConflictUpdate(SyncStateCompanion.insert(key: key, value: value));

  Future<String> folder() async => await _get(_folderKey) ?? defaultFolder;

  Future<void> setFolder(String path) => _set(_folderKey, path.trim());

  Future<DateTime?> lastBackupAt() async {
    final v = await _get(_lastKey);
    return v == null ? null : DateTime.tryParse(v);
  }

  /// Backups in the folder, newest first.
  Future<List<File>> list() async {
    final dir = Directory(await folder());
    if (!dir.existsSync()) return const [];
    final files = [
      for (final f in dir.listSync().whereType<File>())
        if (_name.hasMatch(f.uri.pathSegments.last)) f,
    ]..sort((a, b) => b.path.compareTo(a.path));
    return files;
  }

  /// A copy now; older ones beyond [keep] are deleted.
  Future<File> backupNow() async {
    final dir = Directory(await folder());
    await dir.create(recursive: true);
    final now = _clock();
    String two(int n) => n.toString().padLeft(2, '0');
    final stamp =
        '${now.year}${two(now.month)}${two(now.day)}-${two(now.hour)}${two(now.minute)}${two(now.second)}';
    var file = File('${dir.path}${Platform.pathSeparator}doaya-$stamp.sqlite');
    for (var i = 2; file.existsSync(); i++) {
      file = File('${dir.path}${Platform.pathSeparator}doaya-$stamp-$i.sqlite');
    }
    await _db.customStatement("VACUUM INTO '${file.path.replaceAll("'", "''")}'");
    await _set(_lastKey, now.toUtc().toIso8601String());
    final all = await list();
    for (final old in all.skip(keep)) {
      await old.delete();
    }
    return file;
  }

  /// Backs up when the last copy is a day old (or there's none). Returns
  /// the new file, or null when not due.
  Future<File?> backupIfDue() async {
    final last = await lastBackupAt();
    if (last != null && _clock().difference(last) < every) return null;
    return backupNow();
  }

  // ─── Restore (applied at the next start, before the database opens) ───

  static const _pending = 'restore_pending';

  /// Marks [backup] to replace the database in [dataFolder] at the next
  /// start. The app must be closed and opened again.
  static Future<void> scheduleRestore(String dataFolder, File backup) =>
      File('$dataFolder${Platform.pathSeparator}$_pending').writeAsString(backup.path);

  /// Called at start-up: puts a scheduled backup in place of
  /// `[dataFolder]/[dbName].sqlite`. The current database is kept next to it
  /// as `.before-restore` in case it's needed. Returns true if it restored.
  static Future<bool> applyPendingRestore(String dataFolder, String dbName) async {
    final sep = Platform.pathSeparator;
    final marker = File('$dataFolder$sep$_pending');
    if (!marker.existsSync()) return false;
    final source = File((await marker.readAsString()).trim());
    await marker.delete();
    if (!source.existsSync()) return false;
    final db = File('$dataFolder$sep$dbName.sqlite');
    if (db.existsSync()) await db.copy('${db.path}.before-restore');
    for (final extra in ['-wal', '-shm', '-journal']) {
      final f = File('${db.path}$extra');
      if (f.existsSync()) await f.delete();
    }
    await source.copy(db.path);
    return true;
  }
}
