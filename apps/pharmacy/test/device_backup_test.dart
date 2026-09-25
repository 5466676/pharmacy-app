import 'dart:io';

import 'package:doaya_pharmacy/data/catalog_repository.dart';
import 'package:doaya_pharmacy/data/database.dart';
import 'package:doaya_pharmacy/data/device_backup.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late Directory tmp;
  late AppDatabase db;
  var now = DateTime(2026, 9, 25, 14, 30);

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('doaya-backup');
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2026, 9, 25, 14, 30);
    await CatalogRepository(db).create(
      const ProductDraft(tradeName: 'Amoxil', activeIngredient: 'amoxicillin', priceMinor: 4500),
      deviceId: 'pc',
    );
  });
  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  DeviceBackup backup({int keep = 30}) =>
      DeviceBackup(db, defaultFolder: '${tmp.path}/backups', clock: () => now, keep: keep);

  test('a backup is a complete, readable copy of the database', () async {
    final file = await backup().backupNow();
    expect(file.uri.pathSegments.last, 'doaya-20260925-143000.sqlite');
    final copy = AppDatabase(NativeDatabase(file));
    addTearDown(copy.close);
    expect((await copy.select(copy.products).get()).single.tradeName, 'Amoxil');
    expect(await backup().lastBackupAt(), now.toUtc());
  });

  test('daily: not again within 24 hours; only the newest are kept', () async {
    final b = backup(keep: 2);
    expect(await b.backupIfDue(), isNotNull);
    now = now.add(const Duration(hours: 5));
    expect(await b.backupIfDue(), isNull);
    for (var i = 0; i < 3; i++) {
      now = now.add(const Duration(days: 1));
      expect(await b.backupIfDue(), isNotNull);
    }
    final names = [for (final f in await b.list()) f.uri.pathSegments.last];
    expect(names, ['doaya-20260928-193000.sqlite', 'doaya-20260927-193000.sqlite']);
  });

  test('another folder can be chosen (a USB stick)', () async {
    final b = backup();
    await b.setFolder('${tmp.path}/usb/Doaya');
    final file = await b.backupNow();
    expect(file.parent.path, '${tmp.path}/usb/Doaya');
    // Two in the same second don't overwrite each other.
    expect((await b.backupNow()).path, isNot(file.path));
  });

  test('restore: applied at the next start, the old database kept aside', () async {
    final data = await Directory('${tmp.path}/data').create();
    final saved = await backup().backupNow();
    final current = File('${data.path}/doaya_pharmacy.sqlite')..writeAsStringSync('newer');
    File('${current.path}-wal').writeAsStringSync('wal');

    expect(await DeviceBackup.applyPendingRestore(data.path, 'doaya_pharmacy'), isFalse);
    await DeviceBackup.scheduleRestore(data.path, saved);
    expect(await DeviceBackup.applyPendingRestore(data.path, 'doaya_pharmacy'), isTrue);
    expect(current.readAsBytesSync(), saved.readAsBytesSync());
    expect(File('${current.path}.before-restore').readAsStringSync(), 'newer');
    expect(File('${current.path}-wal').existsSync(), isFalse);
    // Only once.
    expect(await DeviceBackup.applyPendingRestore(data.path, 'doaya_pharmacy'), isFalse);
  });
}
