import 'dart:convert';

import 'package:doaya_patient/data/patient_api.dart';
import 'package:doaya_patient/data/session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_flow_test.dart' show FakeServer, l, pumpApp, tap;
import 'auth_test.dart' show pharmacy;
import 'patient_api_test.dart' show patientJson;

Future<(FakeServer, MemorySessionStore)> signedIn(WidgetTester tester, {bool? consent}) async {
  final server = FakeServer()
    ..me = {...patientJson, 'pharmacy': pharmacy}
    ..consent = consent;
  final store = MemorySessionStore();
  await store.write(
    jsonEncode(
      PatientSession.fromJsonString(jsonEncode({'session_token': 's.x', 'patient': server.me}))!
          .toJson(),
    ),
  );
  await pumpApp(tester, server, store);
  return (server, store);
}

void main() {
  testWidgets('no file yet: the patient agrees from «حسابي»', (tester) async {
    final (server, _) = await signedIn(tester);
    await tap(tester, l.navAccount);
    await tap(tester, l.fileTitle);
    expect(find.text(l.fileNoConsent), findsOneWidget);
    await tap(tester, l.fileEnable);
    expect(server.consent, isTrue);
    expect(find.text(l.fileIntro), findsOneWidget);
    expect(find.text(l.fileEmpty), findsOneWidget);
    expect(find.text('صداع'), findsOneWidget); // a past consultation
    expect(find.text('Panadol 500mg'), findsOneWidget);
  });

  testWidgets('confirm what the chat revealed, add, end, export, delete', (tester) async {
    final (server, _) = await signedIn(tester, consent: true);
    server
      ..facts.add(server.fact('f0', 'medication', 'Concor 5', pharmacist: true))
      ..proposals.addAll([
        {
          'id': 'p1',
          'kind': 'pregnancy',
          'text': 'حامل بالشهر الرابع',
          'needs': 'patient',
          'status': 'pending',
        },
        {
          'id': 'p2',
          'kind': 'allergy',
          'text': 'البنسلين',
          'needs': 'pharmacist',
          'status': 'pending',
        },
      ]);
    await tap(tester, l.navAccount);
    await tap(tester, l.fileTitle);
    // The pharmacist's medicine, with their instructions.
    expect(find.text('Concor 5'), findsOneWidget);
    expect(find.text('حبة الصبح'), findsOneWidget);
    expect(find.text(l.factByPharmacist), findsOneWidget);
    // One proposal for the patient; one waits for the pharmacist.
    expect(find.text(l.fileConfirmMine), findsOneWidget);
    expect(find.text('${l.kindAllergy}: البنسلين'), findsOneWidget);
    await tap(tester, l.yes);
    expect(server.proposals.first['status'], 'accepted');
    expect(find.text('حامل بالشهر الرابع'), findsOneWidget);
    expect(find.text(l.fileConfirmMine), findsNothing);

    // Add an allergy.
    await tap(tester, l.addFact);
    await tester.enterText(find.byType(TextField).last, 'الأسبرين');
    await tap(tester, l.save);
    expect(server.facts.last['text'], 'الأسبرين');
    expect(find.text('الأسبرين'), findsOneWidget);

    // End it.
    await tester.tap(find.byTooltip(l.factEnd).last);
    await tester.pumpAndSettle();
    expect(find.text(l.filePast), findsOneWidget);

    // Export copies the file.
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (
      c,
    ) async {
      if (c.method == 'Clipboard.setData') copied = (c.arguments as Map)['text'] as String;
      return null;
    });
    await tap(tester, l.fileExport);
    expect(copied, contains('Concor 5'));
    expect(find.text(l.fileExported), findsOneWidget);

    // Delete, after confirming (once the toast is gone).
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tap(tester, l.fileDelete);
    await tap(tester, l.confirm);
    expect(server.consent, isNull);
    expect(find.text(l.fileNoConsent), findsOneWidget);
  });

  testWidgets('sign-up asks for the file consent, off by default', (tester) async {
    final server = FakeServer();
    await pumpApp(tester, server, MemorySessionStore());
    await tap(tester, l.createAccount);
    expect(find.text(l.fileConsent), findsOneWidget);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'سامر');
    await tester.enterText(fields.at(1), '0933111222');
    await tester.enterText(fields.at(2), 'secret-1');
    await tap(tester, l.fileConsent);
    await tap(tester, l.createAccount);
    expect(server.registered?['file_consent'], isTrue);
  });
}
