import 'dart:convert';

import 'package:doaya_core/doaya_core.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  final base = Uri.parse('http://192.168.1.10:8000/');

  http.Response json(Object body, [int status = 200]) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );

  test('fetches an access token, then refreshes it once when it expires', () async {
    var tokens = 0, pulls = 0;
    final mock = MockClient((req) async {
      if (req.url.path == '/auth/token') {
        final b = jsonDecode(req.body) as Map;
        expect(b, {'device_id': 'dev', 'device_token': 'secret'});
        return json({'access_token': 'a${++tokens}', 'expires_in': 900});
      }
      expect(req.url.path, '/sync/pull');
      expect(req.url.queryParameters, {'after': '5', 'limit': '100'});
      pulls++;
      if (req.headers['authorization'] == 'Bearer a1') {
        return json({'detail': 'token_expired'}, 401);
      }
      return json({'changes': [], 'cursor': 5, 'more': false, 'latest': 9});
    });
    final c = HttpSyncClient(baseUrl: base, deviceId: 'dev', deviceToken: 'secret', client: mock);
    final page = await c.pull(after: 5, limit: 100);
    expect((page.cursor, page.latest, tokens, pulls), (5, 9, 2, 2));
  });

  test('an unlinked device gets a clear error, not a retry loop', () async {
    final mock = MockClient((req) async => json({'detail': 'device_unlinked'}, 401));
    final c = HttpSyncClient(baseUrl: base, deviceId: 'dev', deviceToken: 'x', client: mock);
    await expectLater(
      c.push(const []),
      throwsA(isA<SyncApiException>().having((e) => e.deviceUnlinked, 'unlinked', isTrue)),
    );
  });

  test('network trouble becomes SyncNetworkException', () async {
    final mock = MockClient((req) async => throw http.ClientException('no route to host'));
    final c = HttpSyncClient(baseUrl: base, deviceId: 'dev', deviceToken: 'x', client: mock);
    await expectLater(c.pull(after: 0, limit: 1), throwsA(isA<SyncNetworkException>()));
    expect(await HttpSyncClient.ping(base, client: mock), isFalse);
  });

  test('link sends phone, password and this device; returns who signed in', () async {
    final mock = MockClient((req) async {
      expect(req.url.path, '/auth/link');
      expect((jsonDecode(req.body) as Map)['device'], {'id': 'dev', 'name': 'موبايل رنا'});
      return json({
        'pharmacy_id': 'ph',
        'pharmacy_name': 'صيدلية الشفاء',
        'user': {'id': 'u', 'name': 'رنا', 'role': 'pharmacist_employee', 'employee_id': 'e2'},
        'device_token': 'secret',
        'access_token': 'a',
        'expires_in': 900,
      });
    });
    final r = await HttpSyncClient.link(
      base,
      phone: '0933000111',
      password: 'pw',
      deviceId: 'dev',
      deviceName: 'موبايل رنا',
      client: mock,
    );
    expect((r.pharmacyName, r.employeeId, r.isOwner), ('صيدلية الشفاء', 'e2', false));
  });

  test('wrong password surfaces the server code', () async {
    final mock = MockClient((req) async => json({'detail': 'bad_credentials'}, 401));
    await expectLater(
      HttpSyncClient.link(
        base,
        phone: 'p',
        password: 'x',
        deviceId: 'd',
        deviceName: 'n',
        client: mock,
      ),
      throwsA(isA<SyncApiException>().having((e) => e.code, 'code', 'bad_credentials')),
    );
  });
}
