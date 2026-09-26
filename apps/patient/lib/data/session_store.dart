import 'session_store_io.dart' if (dart.library.js_interop) 'session_store_web.dart';

/// Where the patient's session is kept between launches: a private file
/// on a phone, `localStorage` in a browser. One JSON string.
abstract class SessionStore {
  Future<String?> read();
  Future<void> write(String? value);

  factory SessionStore() => platformSessionStore();
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
