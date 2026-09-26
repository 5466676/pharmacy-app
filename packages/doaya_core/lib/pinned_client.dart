/// HTTPS to the pharmacy's own server, trusting only the pinned certificate
/// (see `pinServer`). Uses dart:io: devices only, not the web.
library;

import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'src/sync_http.dart';

/// The SHA-256 of a certificate (DER), as the server computes it.
String certificateFingerprint(X509Certificate cert) => sha256.convert(cert.der).toString();

/// A client for [url]: with a pinned fingerprint, only that exact
/// certificate is accepted (no certificate authority is trusted), and any
/// other one fails with [SyncCertificateException]. Without one, a plain
/// client (http:// addresses, tests).
http.Client clientFor(Uri url) {
  final pin = serverPin(url);
  return pin == null ? IOClient(HttpClient()..idleTimeout = idleTimeout) : _PinnedClient(pin);
}

/// Idle connections are dropped sooner than the server closes them (65 s,
/// app/serve.py; uvicorn's default is 5 s). Otherwise a request can go out
/// on a socket the server just closed and fail as "server unreachable".
const idleTimeout = Duration(seconds: 4);

class _PinnedClient extends http.BaseClient {
  _PinnedClient(String pin) {
    _io = IOClient(
      HttpClient(context: SecurityContext(withTrustedRoots: false))
        ..idleTimeout = idleTimeout
        ..badCertificateCallback = (cert, host, port) {
          final ok = certificateFingerprint(cert) == pin;
          if (!ok) _mismatch = true;
          return ok;
        },
    );
  }

  late final IOClient _io;
  var _mismatch = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      return await _io.send(request);
    } on Exception {
      if (_mismatch) {
        _mismatch = false;
        throw const SyncCertificateException();
      }
      rethrow;
    }
  }

  @override
  void close() => _io.close();
}

/// First contact with a typed https address: fetches the server's
/// certificate fingerprint to pin (only if a Doaya server answers there).
/// Nothing secret is sent on this call.
Future<String?> probeServerCertificate(
  Uri url, {
  Duration timeout = const Duration(seconds: 3),
}) async {
  String? seen;
  final client = HttpClient(context: SecurityContext(withTrustedRoots: false))
    ..connectionTimeout = timeout
    ..badCertificateCallback = (cert, host, port) {
      seen = certificateFingerprint(cert);
      return true;
    };
  try {
    final ok = await HttpSyncClient.ping(url, client: IOClient(client));
    return ok ? seen : null;
  } finally {
    client.close(force: true);
  }
}
