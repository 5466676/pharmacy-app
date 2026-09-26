import 'dart:convert';

import 'package:doaya_admin/data/admin_api.dart';
import 'package:doaya_admin/data/identity.dart';
import 'package:doaya_admin/data/providers.dart';
import 'package:doaya_admin/data/session_store.dart';
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  final base = Uri.parse('http://central/');

  test('sign-in keeps the session; an expired access token is renewed once', () async {
    final seen = <String>[];
    var tokens = 0;
    final api = AdminApi(
      base,
      client: MockClient((r) async {
        seen.add('${r.method} ${r.url.path} ${r.headers['authorization'] ?? ''}');
        switch (r.url.path) {
          case '/admin/login':
            return json({
              'admin': {'id': 'a', 'name': 'فايز'},
              'session_token': 's.secret',
              'access_token': 'old',
              'expires_in': 900,
            });
          case '/admin/token':
            expect(jsonDecode(r.body), {'session_token': 's.secret'});
            tokens++;
            return json({'access_token': 'new', 'expires_in': 900});
          case '/admin/me':
          case '/admin/settings':
            if (r.headers['authorization'] == 'Bearer old') {
              return json({'detail': 'token_expired'}, 401);
            }
            return json({
              'llm_base_url': 'http://localhost:1234/v1',
              'llm_model': 'm',
              'emergency_ambulance': '110',
              'emergency_general': '112',
              'cors_origins': <String>[],
              'server_version': '0.1.0',
            });
        }
        return json({'detail': 'not_found'}, 404);
      }),
    );
    final s = await api.login('0999', 'pass');
    expect((s.sessionToken, s.name), ('s.secret', 'فايز'));
    final settings = await api.settings();
    expect(settings.ambulance, '110');
    expect(tokens, 1);
    expect(seen.last, 'GET /admin/settings Bearer new');
  });

  test('errors carry the server\'s code; no network is its own error', () async {
    final api = AdminApi(
      base,
      client: MockClient((r) async => json({'detail': 'reason_required'}, 400)),
    )..resume('s.x');
    await expectLater(
      api.act('p1', 'suspend'),
      throwsA(isA<SyncApiException>().having((e) => e.code, 'code', 'reason_required')),
    );
    final offline = AdminApi(
      base,
      client: MockClient((r) async => throw http.ClientException('no route')),
    )..resume('s.x');
    await expectLater(offline.overview(), throwsA(isA<SyncNetworkException>()));
  });

  test('actions and searches send what the server expects', () async {
    final bodies = <Object?>[];
    final paths = <String>[];
    final api = AdminApi(
      base,
      client: MockClient((r) async {
        if (r.url.path == '/admin/token') return json({'access_token': 't'});
        paths.add(r.url.toString());
        bodies.add(r.body.isEmpty ? null : jsonDecode(r.body));
        if (r.url.path == '/admin/pharmacies') return json(<Object>[]);
        return json({
          'id': 'p1',
          'name': 'صيدلية',
          'status': 'stopped',
          'licence_days': 30,
          'actions': <Object>[],
        });
      }),
    )..resume('s.x');
    await api.pharmacies(query: ' حلب ');
    final p = await api.act('p1', 'stop', reason: 'انتهى العقد');
    await api.act('p1', 'licence', licenceDays: 45);
    expect(p.status, 'stopped');
    expect(Uri.decodeFull(paths[0]), 'http://central/admin/pharmacies?q=حلب');
    expect(bodies[1], {'action': 'stop', 'reason': 'انتهى العقد'});
    expect(bodies[2], {'action': 'licence', 'licence_days': 45});
  });

  group('sign-in state', () {
    test('a saved session is resumed; signing out forgets it', () async {
      final store = MemorySessionStore(
        const AdminSession(sessionToken: 's.x', name: 'فايز').toJsonString(),
      );
      final c = ProviderContainer(
        overrides: [
          sessionStoreProvider.overrideWithValue(store),
          apiProvider.overrideWithValue(
            AdminApi(base, client: MockClient((r) async => json({'ok': true}))),
          ),
        ],
      );
      addTearDown(c.dispose);
      expect(c.read(authProvider).loading, isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(authProvider).name, 'فايز');
      await c.read(authProvider.notifier).signOut();
      expect(c.read(authProvider).signedIn, isFalse);
      expect(store.value, isNull);
    });
  });

  group('the three designs', () {
    test('each is a different look, and every one keeps readable contrast', () {
      final looks = AdminIdentity.values.map((i) => i.look).toSet();
      expect(looks.length, 3);
      for (final i in AdminIdentity.values) {
        final p = DoayaPalette.of(i.look);
        expect(contrastRatio(p.textPrimary, p.bgMid), greaterThanOrEqualTo(4.5), reason: i.name);
        expect(i.look.style, isNot(DoayaStyle.glass), reason: 'no blur on the panel');
      }
      expect(DoayaPalette.of(AdminIdentity.ledger.look).brightness, Brightness.light);
    });

    test('the choice is kept in the browser', () async {
      final store = MemorySessionStore();
      final c = ProviderContainer(overrides: [identityStoreProvider.overrideWithValue(store)]);
      addTearDown(c.dispose);
      expect(c.read(identityProvider), AdminIdentity.console);
      await Future<void>.delayed(Duration.zero);
      await c.read(identityProvider.notifier).set(AdminIdentity.family);
      expect(store.value, 'family');
      final again = ProviderContainer(overrides: [identityStoreProvider.overrideWithValue(store)]);
      addTearDown(again.dispose);
      again.read(identityProvider);
      await Future<void>.delayed(Duration.zero);
      expect(again.read(identityProvider), AdminIdentity.family);
    });
  });
}
