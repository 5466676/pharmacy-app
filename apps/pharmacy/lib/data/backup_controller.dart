import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../providers.dart';
import 'device_backup.dart';

/// Where backups go until the owner picks a folder: "Doaya Backups" in the
/// user's Documents (visible, and often copied off the PC by OneDrive).
/// Never fails: Linux without `xdg-user-dir` has no "Documents" answer, so
/// it falls back to ~/Documents, then to the app's own folder.
final defaultBackupFolderProvider = FutureProvider<String>((ref) async {
  const name = 'Doaya Backups';
  final sep = Platform.pathSeparator;
  try {
    return '${(await getApplicationDocumentsDirectory()).path}$sep$name';
  } on Object {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home != null) return '$home${sep}Documents$sep$name';
    return '${(await getApplicationSupportDirectory()).path}$sep$name';
  }
});

final deviceBackupProvider = FutureProvider<DeviceBackup>(
  (ref) async => DeviceBackup(
    ref.watch(databaseProvider),
    defaultFolder: await ref.watch(defaultBackupFolderProvider.future),
    clock: ref.watch(clockProvider),
  ),
);

/// How often the app checks whether a daily backup is due (null: never,
/// e.g. widget tests, which have no real folders).
final backupCheckEveryProvider = Provider<Duration?>(
  (ref) => Platform.environment.containsKey('FLUTTER_TEST') ? null : const Duration(hours: 1),
);

class BackupState {
  const BackupState({this.folder, this.last, this.files = const [], this.error, this.busy = false});

  final String? folder;
  final DateTime? last;

  /// Newest first.
  final List<File> files;
  final String? error;
  final bool busy;
}

/// Runs the daily backup while the app is open and tells Settings about it.
class BackupController extends Notifier<BackupState> {
  Timer? _timer;

  @override
  BackupState build() {
    ref.onDispose(() => _timer?.cancel());
    final every = ref.watch(backupCheckEveryProvider);
    if (every != null) {
      scheduleMicrotask(() => _run(onlyIfDue: true));
      _timer = Timer.periodic(every, (_) => _run(onlyIfDue: true));
    }
    return const BackupState();
  }

  Future<void> refresh() async {
    final b = await ref.read(deviceBackupProvider.future);
    state = BackupState(
      folder: await b.folder(),
      last: await b.lastBackupAt(),
      files: await b.list(),
      error: state.error,
    );
  }

  Future<void> backupNow() => _run(onlyIfDue: false);

  Future<void> setFolder(String path) async {
    await (await ref.read(deviceBackupProvider.future)).setFolder(path);
    await _run(onlyIfDue: false);
  }

  Future<void> _run({required bool onlyIfDue}) async {
    if (state.busy) return;
    state = BackupState(folder: state.folder, last: state.last, files: state.files, busy: true);
    String? error;
    try {
      final b = await ref.read(deviceBackupProvider.future);
      onlyIfDue ? await b.backupIfDue() : await b.backupNow();
    } on Object catch (e) {
      // A missing USB stick, a full disk…: shown in Settings, tried again later.
      error = '$e';
    }
    state = BackupState(folder: state.folder, last: state.last, files: state.files, error: error);
    try {
      await refresh();
    } on Object {
      // Nothing more to show.
    }
  }
}

final backupProvider = NotifierProvider<BackupController, BackupState>(BackupController.new);
