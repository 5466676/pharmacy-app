import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'session_store.dart';

SessionStore platformSessionStore(String name) => _LocalStorageSessionStore('doaya.$name');

/// `window.localStorage`, through the SDK's own JS interop (no package).
class _LocalStorageSessionStore implements SessionStore {
  _LocalStorageSessionStore(this._key);
  final String _key;

  JSObject get _storage => globalContext['localStorage']! as JSObject;

  @override
  Future<String?> read() async => _storage.callMethod<JSString?>('getItem'.toJS, _key.toJS)?.toDart;

  @override
  Future<void> write(String? value) async {
    if (value == null) {
      _storage.callMethod<JSAny?>('removeItem'.toJS, _key.toJS);
    } else {
      _storage.callMethod<JSAny?>('setItem'.toJS, _key.toJS, value.toJS);
    }
  }
}
