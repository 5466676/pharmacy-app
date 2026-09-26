import 'dart:async';
import 'dart:convert';

import 'package:doaya_patient/data/live_updates.dart';
import 'package:doaya_patient/data/patient_api.dart';
import 'package:doaya_patient/data/providers.dart';
import 'package:doaya_patient/data/session_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_flow_test.dart' show FakeServer;
import 'auth_test.dart' show pharmacy;
import 'patient_api_test.dart' show patientJson;

Future<void> until(bool Function() done) async {
  for (var i = 0; i < 200 && !done(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(done(), isTrue);
}

void main() {
  test(
    'a socket event reloads the consultation; with the socket down, /updates is polled',
    () async {
      final server = FakeServer()..me = {...patientJson, 'pharmacy': pharmacy};
      server.consultation('c1');
      final sockets = <StreamController<Object?>>[];
      final uris = <Uri>[];
      final store = MemorySessionStore();
      await store.write(jsonEncode({'session_token': 's.x', 'patient': server.me}));
      final c = ProviderContainer(
        overrides: [
          apiProvider.overrideWithValue(PatientApi(Uri.parse('https://x/'), client: server.client)),
          sessionStoreProvider.overrideWithValue(store),
          pollIntervalProvider.overrideWithValue(const Duration(milliseconds: 20)),
          liveConnectProvider.overrideWithValue((uri) {
            uris.add(uri);
            return (sockets..add(StreamController<Object?>())).last.stream;
          }),
        ],
      );
      addTearDown(c.dispose);
      int fetches() => server.seen.where((s) => s == 'GET /consultations/c1').length;

      c.listen(consultationProvider('c1'), (_, _) {});
      c.read(authProvider);
      await until(() => c.read(authProvider).signedIn);
      final live = c.read(liveUpdatesProvider);
      await until(() => sockets.isNotEmpty);
      expect(uris.single.toString(), 'wss://x/ws?token=a');
      await until(() => fetches() == 1);

      sockets.last.add(jsonEncode({'type': 'ping'}));
      sockets.last.add(jsonEncode({'type': 'case_status', 'consultation_id': 'c1'}));
      await until(() => fetches() == 2);
      expect(live.live, isTrue);

      // The server goes away: poll /updates until the socket is back.
      await sockets.last.close();
      await until(() => server.seen.contains('GET /updates'));
      await until(() => fetches() == 3);
      expect(live.live, isFalse);
    },
  );
}
