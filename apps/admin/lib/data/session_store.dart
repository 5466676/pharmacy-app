import 'session_store_io.dart' if (dart.library.js_interop) 'session_store_web.dart';

/// What the panel keeps between visits, in the browser's `localStorage`:
/// the admin's session and the chosen design. One string per [name].
abstract class SessionStore {
  Future<String?> read();
  Future<void> write(String? value);

  factory SessionStore([String name = 'session']) => platformSessionStore(name);
}

/// For tests.
class MemorySessionStore implements SessionStore {
  MemorySessionStore([this.value]);
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String? value) async => this.value = value;
}
