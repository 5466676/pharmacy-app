import 'dart:convert';

import 'package:doaya_patient/app.dart';
import 'package:doaya_patient/data/patient_api.dart';
import 'package:doaya_patient/data/providers.dart';
import 'package:doaya_patient/data/session_store.dart';
import 'package:doaya_patient/l10n/app_localizations.dart';
import 'package:doaya_patient/ui/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'auth_test.dart' show pharmacy;
import 'patient_api_test.dart' show json, patientJson;

final l = lookupAppLocalizations(const Locale('ar'));

/// Doaya online in memory: one patient, one pharmacy, a scripted assistant.
class FakeServer {
  Map<String, Object?> me = Map.of(patientJson);
  final consultations = <String, Map<String, Object?>>{};
  final seen = <String>[];
  var _msg = 0;

  Map<String, Object?> _message(String role, String text, [List<String> quick = const []]) => {
    'id': ++_msg,
    'role': role,
    'text': text,
    'quick_replies': quick,
    'author': null,
    'created_at': '2026-09-26T10:00:00Z',
  };

  Map<String, Object?> consultation(String id, {String status = 'chatting'}) =>
      consultations[id] = {
        'id': id,
        'pharmacy_id': 'ph1',
        'status': status,
        'urgent': status == 'emergency',
        'red_flag': status == 'emergency' ? 'chest_pain' : null,
        'summary': null,
        'decision': null,
        'handled_by': null,
        'created_at': '2026-09-26T10:00:00Z',
        'updated_at': '2026-09-26T10:00:00Z',
        'messages': <Map<String, Object?>>[],
      };

  late final client = MockClient((req) async {
    final path = req.url.path;
    seen.add('${req.method} $path');
    final body = req.body.isEmpty ? null : jsonDecode(req.body);
    final parts = path.split('/');
    switch ((req.method, path)) {
      case ('POST', '/patients/register'):
        me = {...me, 'name': body['name']};
        return json({'patient': me, 'session_token': 's.x', 'access_token': 'a'});
      case ('POST', '/patients/token'):
        return json({'access_token': 'a'});
      case ('GET', '/directory'):
        return json([pharmacy]);
      case ('PATCH', '/patients/me'):
        me = {...me, 'pharmacy': pharmacy};
        return json(me);
      case ('GET', '/patients/me'):
        return json(me);
      case ('GET', '/consultations'):
        return json(consultations.values.toList().reversed.toList());
      case ('POST', '/consultations'):
        return json(consultation('c${consultations.length + 1}'));
      case ('GET', _) when parts.length == 3:
        return json(consultations[parts[2]]!);
      case ('POST', _) when path.endsWith('/messages'):
        final c = consultations[parts[2]]!;
        final messages = c['messages']! as List;
        messages.add(_message('patient', body['text'] as String));
        if (messages.length == 1) {
          messages.add(_message('assistant', 'سلامتك. في حرارة؟', ['لا، ولا شي', 'في حرارة']));
        } else {
          messages.add(_message('assistant', 'هاد ملخص حالتك، راجعه.'));
          c['status'] = 'summary';
          c['summary'] = {
            'symptoms': ['صداع'],
            'duration': 'يومين',
            'denied_red_flags': ['حرارة'],
          };
        }
        return json(c);
      case ('POST', _) when path.endsWith('/send'):
        final c = consultations[parts[2]]!;
        c['status'] = 'sent';
        (c['messages']! as List).add(_message('system', 'بعتنا حالتك للصيدلية.'));
        return json(c);
      default:
        return json({'detail': 'not_found'}, 404);
    }
  });
}

Future<void> pumpApp(WidgetTester tester, FakeServer server, MemorySessionStore store) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiProvider.overrideWithValue(PatientApi(Uri.parse('https://x/'), client: server.client)),
        sessionStoreProvider.overrideWithValue(store),
      ],
      child: const PatientApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).last);
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sign up, choose a pharmacy, consult, check the summary, send it', (tester) async {
    final server = FakeServer();
    await pumpApp(tester, server, MemorySessionStore());

    await tap(tester, l.createAccount);
    expect(find.text(l.nameLabel), findsOneWidget);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'مازن');
    await tester.enterText(fields.at(1), '٠٩٣٣١١١٢٢٢'); // Arabic keyboard digits
    await tester.enterText(fields.at(2), 'secret-1');
    await tap(tester, l.createAccount);

    // No pharmacy yet: the list of the patient's city.
    expect(find.text(l.choosePharmacyTitle), findsOneWidget);
    expect(find.text('صيدلية الشفاء'), findsOneWidget);
    await tap(tester, l.chooseThis);

    // Home.
    expect(find.text(l.startConsultation), findsOneWidget);
    expect(find.text(l.noConsultations), findsOneWidget);
    expect(find.text(l.safetyLine), findsOneWidget);
    await tap(tester, l.startConsultation);

    // Chat: the assistant asks, with quick replies.
    expect(find.text(l.assistantTitle), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'عندي صداع');
    await tester.tap(find.byTooltip(l.send));
    await tester.pumpAndSettle();
    expect(find.text('سلامتك. في حرارة؟'), findsOneWidget);
    expect(find.text(l.sendToPharmacyNow), findsOneWidget);
    await tap(tester, 'لا، ولا شي');

    // The summary to check.
    expect(find.text(l.summaryTitle), findsOneWidget);
    expect(find.textContaining('صداع'), findsWidgets);
    expect(find.text(l.sendToPharmacyNow), findsNothing);
    await tap(tester, l.sendToPharmacy);

    expect(find.text(l.stepSent), findsOneWidget);
    expect(find.text(l.status('sent')), findsOneWidget);
    expect(find.text(l.summaryTitle), findsNothing);
    expect(server.seen, contains('POST /consultations/c1/send'));
    expect(server.me['name'], 'مازن');
  });

  testWidgets('a signed-in patient lands home; an emergency shows who to call', (tester) async {
    final server = FakeServer()..me = {...patientJson, 'pharmacy': pharmacy};
    server.consultation('c1', status: 'emergency');
    final store = MemorySessionStore();
    await store.write(
      jsonEncode(
        PatientSession.fromJsonString(jsonEncode({'session_token': 's.x', 'patient': server.me}))!
            .toJson(),
      ),
    );
    await pumpApp(tester, server, store);

    expect(find.text(l.recentConsultations), findsOneWidget);
    expect(find.text(l.status('emergency')), findsOneWidget);
    await tester.tap(find.text(l.status('emergency')));
    await tester.pumpAndSettle();

    expect(find.byType(EmergencyPanel), findsOneWidget);
    expect(find.text(l.callAmbulance('110')), findsOneWidget);
    expect(find.text(l.callEmergency('112')), findsOneWidget);
    // Still able to write to the pharmacy.
    expect(find.byTooltip(l.send), findsOneWidget);
  });
}
