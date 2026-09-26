import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'session_store.dart';

SessionStore platformSessionStore(String name) => _FileSessionStore(name);

class _FileSessionStore implements SessionStore {
  _FileSessionStore(this.name);
  final String name;

  Future<File> _file() async =>
      File('${(await getApplicationSupportDirectory()).path}${Platform.pathSeparator}$name.json');

  @override
  Future<String?> read() async {
    final f = await _file();
    return f.existsSync() ? f.readAsString() : null;
  }

  @override
  Future<void> write(String? value) async {
    final f = await _file();
    if (value == null) {
      if (f.existsSync()) await f.delete();
    } else {
      await f.parent.create(recursive: true);
      await f.writeAsString(value);
    }
  }
}
