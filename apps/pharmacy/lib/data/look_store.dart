import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// «المظهر» of this device, in `look.json` next to its database. Not in
/// the settings table: that one syncs to every device of the pharmacy.
abstract class LookStore {
  Future<String?> read();
  Future<void> write(String value);
}

class FileLookStore implements LookStore {
  Future<File> _file() async =>
      File('${(await getApplicationSupportDirectory()).path}${Platform.pathSeparator}look.json');

  @override
  Future<String?> read() async {
    final f = await _file();
    return f.existsSync() ? f.readAsString() : null;
  }

  @override
  Future<void> write(String value) async {
    final f = await _file();
    await f.parent.create(recursive: true);
    await f.writeAsString(value);
  }
}

/// For tests.
class MemoryLookStore implements LookStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async => this.value = value;
}

final lookStoreProvider = Provider<LookStore>((ref) => FileLookStore());

class LookController extends Notifier<DoayaLook> {
  @override
  DoayaLook build() {
    scheduleMicrotask(_load);
    return const DoayaLook();
  }

  Future<void> _load() async {
    try {
      final s = await ref.read(lookStoreProvider).read();
      if (s != null) state = DoayaLook.fromJson(jsonDecode(s) as Map<String, Object?>);
    } on Object {
      // No file or unreadable: the default look.
    }
  }

  Future<void> set(DoayaLook look) async {
    state = look;
    try {
      await ref.read(lookStoreProvider).write(jsonEncode(look.toJson()));
    } on Object {
      // Not saved; it still applies until the app closes.
    }
  }
}

final lookProvider = NotifierProvider<LookController, DoayaLook>(LookController.new);
