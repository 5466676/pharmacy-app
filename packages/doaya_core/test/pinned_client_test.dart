@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_core/pinned_client.dart';
import 'package:test/test.dart';

/// A stand-in Doaya server over HTTPS. `test/tls` holds a throwaway
/// certificate and key made only for these tests.
Future<HttpServer> _server() async {
  final ctx = SecurityContext()
    ..useCertificateChain('test/tls/server.crt')
    ..usePrivateKey('test/tls/server.key');
  final s = await HttpServer.bindSecure(InternetAddress.loopbackIPv4, 0, ctx);
  s.listen((req) {
    req.response
      ..headers.contentType = ContentType.json
      ..write(jsonEncode({'status': 'ok', 'service': 'doaya'}))
      ..close();
  });
  return s;
}

void main() {
  late HttpServer server;
  late Uri url;
  setUp(() async {
    server = await _server();
    url = Uri.parse('https://127.0.0.1:${server.port}/');
  });
  tearDown(() => server.close(force: true));

  const pin = '6e9b8aa7f8a219b9060ab70fffb7b8b5b364ffbf3d422848d18e5910477e1b19';

  test('the pin rides in the address and never goes over the wire', () {
    final pinned = pinServer(url, pin);
    expect(serverPin(pinned), pin);
    expect(serverPin(url), isNull);
    expect(pinned.resolve('sync/pull').hasFragment, isFalse);
    expect(serverCode(pin), '6E9B-8AA7');
  });

  test('first contact learns the certificate', () async {
    expect(await probeServerCertificate(url), pin);
  });

  test('the pinned certificate is accepted', () async {
    final pinned = pinServer(url, pin);
    expect(await HttpSyncClient.ping(pinned, client: clientFor(pinned)), isTrue);
    final c = clientFor(pinned);
    expect((await c.get(pinned.resolve('health'))).statusCode, 200);
    c.close();
  });

  test('any other certificate is refused with a clear error', () async {
    final wrong = pinServer(url, 'ab' * 32);
    final c = HttpSyncClient(
      baseUrl: wrong,
      deviceId: 'dev',
      deviceToken: 'secret',
      client: clientFor(wrong),
    );
    await expectLater(c.pull(after: 0, limit: 10), throwsA(isA<SyncCertificateException>()));
    c.close();
    expect(await HttpSyncClient.ping(wrong, client: clientFor(wrong)), isFalse);
  });

  test('without a pin, a self-made certificate is not trusted', () async {
    expect(await HttpSyncClient.ping(url, client: clientFor(url)), isFalse);
  });
}
