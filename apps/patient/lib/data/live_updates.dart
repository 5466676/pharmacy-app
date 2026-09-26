import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'providers.dart';

/// Opens the live socket; tests swap in a stream of their own.
typedef LiveConnect = Stream<Object?> Function(Uri uri);

final liveConnectProvider = Provider<LiveConnect>(
  (ref) =>
      (uri) => WebSocketChannel.connect(uri).stream,
);

/// How often to ask `/updates` while the socket is down.
final pollIntervalProvider = Provider<Duration>((ref) => const Duration(seconds: 30));

/// Keeps what's on screen current while the app is open: the server's
/// WebSocket, and `/updates` polling whenever the socket is down (no
/// Google push in Syria). Each change reloads that consultation and the list.
class LiveUpdates {
  LiveUpdates(this._ref);

  final Ref _ref;
  StreamSubscription<Object?>? _socket;
  Timer? _poll;
  Timer? _reconnect;
  DateTime? _since;
  var _backoff = const Duration(seconds: 2);
  var _closed = false;

  /// True while the socket is open.
  bool get live => _socket != null && _poll == null;

  void start() => unawaited(_connect());

  Future<void> _connect() async {
    if (_closed) return;
    try {
      final uri = await _ref.read(apiProvider).liveUri();
      if (_closed) return;
      _socket = _ref
          .read(liveConnectProvider)(uri)
          .listen(_onEvent, onError: (Object _) => _down(), onDone: _down, cancelOnError: true);
    } on Object {
      _down();
    }
  }

  void _onEvent(Object? raw) {
    // Connected: no need to poll; catch up once on what the gap missed.
    if (_poll != null) {
      _poll!.cancel();
      _poll = null;
      unawaited(_check());
    }
    _backoff = const Duration(seconds: 2);
    final Object? event;
    try {
      event = raw is String ? jsonDecode(raw) : raw;
    } on FormatException {
      return;
    }
    if (event case {'consultation_id': final String id}) _changed(id);
  }

  void _changed(String id) {
    _ref
      ..invalidate(consultationProvider(id))
      ..invalidate(consultationsProvider);
  }

  void _down() {
    unawaited(_socket?.cancel());
    _socket = null;
    if (_closed) return;
    _poll ??= Timer.periodic(_ref.read(pollIntervalProvider), (_) => _check());
    _reconnect?.cancel();
    _reconnect = Timer(_backoff, _connect);
    final next = _backoff * 2;
    _backoff = next > const Duration(minutes: 1) ? const Duration(minutes: 1) : next;
  }

  Future<void> _check() async {
    try {
      final u = await _ref.read(apiProvider).updates(since: _since);
      _since = DateTime.parse(u['now']! as String);
      for (final c in (u['consultations'] as List? ?? const [])) {
        if (c case {'id': final String id}) _changed(id);
      }
    } on Object {
      // Offline: try again at the next tick.
    }
  }

  void dispose() {
    _closed = true;
    _poll?.cancel();
    _reconnect?.cancel();
    unawaited(_socket?.cancel());
  }
}

/// Alive while a patient is signed in (watched by the app).
final liveUpdatesProvider = Provider<LiveUpdates>((ref) {
  ref.watch(authProvider.select((a) => a.patient?.id));
  final live = LiveUpdates(ref);
  ref.onDispose(live.dispose);
  if (ref.read(authProvider).signedIn) live.start();
  return live;
});
