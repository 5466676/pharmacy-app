import 'session_store.dart';

/// The admin panel runs in a browser; off the web (tests, `flutter run`
/// on a desktop while developing) it keeps nothing between launches.
SessionStore platformSessionStore(String name) => MemorySessionStore();
