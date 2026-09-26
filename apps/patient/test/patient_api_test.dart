import 'dart:convert';

import 'package:doaya_patient/data/models.dart';
import 'package:doaya_patient/data/patient_api.dart';
import 'package:doaya_patient/data/session_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const patientJson = {
  'id': 'p1',
  'name': 'مازن',
  'phone': '0933111222',
  'birth_year': 1992,
  'sex': 'm',
  'city': 'دمشق',
  'pharmacy': null,
};

http.Response json(Object body, [int status = 200]) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json'},
);

void main() {
  final base = Uri.parse('https://doaya.example/');

  test('register signs in; the session survives a restart', () async {
    final seen = <String>[];
    final api = PatientApi(
      base,
      client: MockClient((req) async {
        seen.add('${req.method} ${req.url.path}');
        if (req.url.path == '/patients/register') {
          expect(jsonDecode(req.body)['phone'], '0933111222');
          return json({
            'patient': patientJson,
            'session_token': 's1.secret',
            'access_token': 'a1',
            'expires_in': 900,
          });
        }
        expect(req.headers['authorization'], 'Bearer a1');
        return json(patientJson);
      }),
    );
    final s = await api.register(name: 'مازن', phone: '0933111222', password: 'secret-1');
    expect(s.patient.name, 'مازن');
    expect((await api.me()).birthYear, 1992);
    expect(seen, ['POST /patients/register', 'GET /patients/me']);

    final store = MemorySessionStore();
    await store.write(jsonEncode(s.toJson()));
    final back = PatientSession.fromJsonString(await store.read())!;
    expect((back.sessionToken, back.patient.city), ('s1.secret', 'دمشق'));
    expect(PatientSession.fromJsonString('garbage'), isNull);
  });

  test(
    'a resumed session fetches an access token, and refreshes it once when it expires',
    () async {
      var tokens = 0, calls = 0;
      final api = PatientApi(
        base,
        client: MockClient((req) async {
          if (req.url.path == '/patients/token') {
            expect(jsonDecode(req.body), {'session_token': 's1.secret'});
            return json({'access_token': 'a${++tokens}', 'expires_in': 900});
          }
          calls++;
          if (req.headers['authorization'] == 'Bearer a1') {
            return json({'detail': 'token_expired'}, 401);
          }
          return json([]);
        }),
      )..resume('s1.secret');
      expect(await api.consultations(), isEmpty);
      expect((tokens, calls), (2, 2));
    },
  );

  test('errors carry the server code; no internet is its own error', () async {
    final api = PatientApi(
      base,
      client: MockClient((req) async => json({'detail': 'phone_taken'}, 409)),
    );
    await expectLater(
      api.register(name: 'x', phone: '0933', password: 'secret-1'),
      throwsA(isA<SyncApiException>().having((e) => e.code, 'code', 'phone_taken')),
    );
    final offline = PatientApi(
      base,
      client: MockClient((req) async => throw http.ClientException('no route')),
    );
    await expectLater(offline.login('0933', 'x'), throwsA(isA<SyncNetworkException>()));
    await expectLater(PatientApi(base).me(), throwsA(isA<SyncApiException>()));
  });

  test('consultation JSON: messages, quick replies, title, live address', () async {
    final c = Consultation.fromJson({
      'id': 'c1',
      'pharmacy_id': 'ph',
      'status': 'chatting',
      'urgent': false,
      'red_flag': null,
      'summary': null,
      'decision': null,
      'handled_by': null,
      'created_at': '2026-09-26T10:00:00Z',
      'sent_at': null,
      'updated_at': '2026-09-26T10:01:00Z',
      'messages': [
        {
          'id': 1,
          'role': 'assistant',
          'text': 'أهلين',
          'quick_replies': null,
          'author': null,
          'created_at': '2026-09-26T10:00:00Z',
        },
        {
          'id': 2,
          'role': 'patient',
          'text': 'عندي صداع',
          'quick_replies': null,
          'author': null,
          'created_at': '2026-09-26T10:00:10Z',
        },
        {
          'id': 3,
          'role': 'assistant',
          'text': 'في غثيان؟',
          'quick_replies': ['لا', 'اي'],
          'author': null,
          'created_at': '2026-09-26T10:00:20Z',
        },
      ],
    });
    expect((c.title, c.withAssistant), ('عندي صداع', true));
    expect(c.quickReplies, ['لا', 'اي']);
    final api = PatientApi(
      base,
      client: MockClient((req) async => json({'access_token': 'a 1', 'expires_in': 900})),
    )..resume('s1.x');
    final live = await api.liveUri();
    expect(live.toString(), 'wss://doaya.example/ws?token=a+1');
  });
}
