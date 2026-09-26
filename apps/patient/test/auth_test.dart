import 'dart:convert';

import 'package:doaya_patient/data/patient_api.dart';
import 'package:doaya_patient/data/providers.dart';
import 'package:doaya_patient/data/session_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'patient_api_test.dart' show json, patientJson;

const pharmacy = {
  'id': 'ph1',
  'name': 'صيدلية الشفاء',
  'code': 'SH4F',
  'city': 'دمشق',
  'address': null,
  'phone': null,
  'hours': '9 - 23',
};

ProviderContainer container(MockClient client, MemorySessionStore store) {
  final c = ProviderContainer(
    overrides: [
      apiProvider.overrideWithValue(PatientApi(Uri.parse('https://x/'), client: client)),
      sessionStoreProvider.overrideWithValue(store),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  test('sign up, choose a pharmacy, stay signed in after a restart', () async {
    final store = MemorySessionStore();
    var me = Map<String, Object?>.of(patientJson);
    final client = MockClient((req) async {
      switch (req.url.path) {
        case '/patients/register':
          return json({'patient': me, 'session_token': 's1.x', 'access_token': 'a1'});
        case '/patients/token':
          return json({'access_token': 'a2'});
        case '/patients/me' when req.method == 'PATCH':
          expect(jsonDecode(req.body), {'pharmacy_id': 'ph1'});
          me = {...me, 'pharmacy': pharmacy};
          return json(me);
        default:
          return json(me);
      }
    });
    var c = container(client, store);
    c.read(authProvider);
    await settle();
    expect(c.read(authProvider).signedIn, isFalse);
    await c.read(authProvider.notifier).register(name: 'مازن', phone: '0933', password: 'secret-1');
    expect(c.read(authProvider).hasPharmacy, isFalse);
    await c
        .read(authProvider.notifier)
        .choosePharmacy(
          (await PatientApi(
            Uri.parse('https://x/'),
            client: MockClient((_) async => json(pharmacy)),
          ).byCode('SH4F')),
        );
    expect(c.read(authProvider).patient!.pharmacy!.code, 'SH4F');

    // Restart: the saved session signs in without the password.
    c = container(client, store);
    c.read(authProvider);
    await settle();
    expect(c.read(authProvider).patient!.pharmacy!.name, 'صيدلية الشفاء');
  });

  test('offline at start: the saved profile is used; signed out elsewhere: forgotten', () async {
    final saved = jsonEncode({'session_token': 's1.x', 'patient': patientJson});
    final offline = MockClient((req) async => throw http.ClientException('offline'));
    final store = MemorySessionStore(saved);
    var c = container(offline, store);
    c.read(authProvider);
    await settle();
    expect(c.read(authProvider).patient!.name, 'مازن');

    final revoked = MockClient((req) async => json({'detail': 'signed_out'}, 401));
    c = container(revoked, store);
    c.read(authProvider);
    await settle();
    expect(c.read(authProvider).signedIn, isFalse);
    expect(store.value, isNull);
  });
}
