import 'dart:convert';
import 'dart:io';

import 'package:doaya_pharmacy/sync/discovery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('finds a server that answers DOAYA?', () async {
    final responder = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    responder.listen((e) {
      final d = responder.receive();
      if (d == null || utf8.decode(d.data) != 'DOAYA?') return;
      responder.send(
        utf8.encode(
          jsonEncode({'service': 'doaya', 'http_port': 8000, 'pharmacy': 'صيدلية الشفاء'}),
        ),
        d.address,
        d.port,
      );
    });
    final found = await discoverServers(
      port: responder.port,
      target: InternetAddress.loopbackIPv4,
      timeout: const Duration(milliseconds: 300),
    );
    responder.close();
    expect(found.single.url.toString(), 'http://127.0.0.1:8000/');
    expect(found.single.pharmacyName, 'صيدلية الشفاء');
  });

  test('an https server announces its certificate, and the address pins it', () async {
    final responder = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    final fp = 'ab' * 32;
    responder.listen((e) {
      final d = responder.receive();
      if (d == null) return;
      responder.send(
        utf8.encode(
          jsonEncode({
            'service': 'doaya',
            'http_port': 8000,
            'pharmacy': null,
            'scheme': 'https',
            'fingerprint': fp,
          }),
        ),
        d.address,
        d.port,
      );
    });
    final found = await discoverServers(
      port: responder.port,
      target: InternetAddress.loopbackIPv4,
      timeout: const Duration(milliseconds: 300),
    );
    responder.close();
    expect(found.single.url.toString(), 'https://127.0.0.1:8000/#sha256=$fp');
  });

  test('typed addresses', () {
    expect(parseServerAddress('192.168.1.10').toString(), 'https://192.168.1.10:8000/');
    expect(parseServerAddress(' 192.168.1.10:9000 ').toString(), 'https://192.168.1.10:9000/');
    expect(parseServerAddress('http://192.168.1.10').toString(), 'http://192.168.1.10:8000/');
    expect(parseServerAddress('https://doaya.example').toString(), 'https://doaya.example:8000/');
    expect(parseServerAddress(''), isNull);
  });
}
