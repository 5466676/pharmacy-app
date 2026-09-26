import 'dart:convert';

import 'package:doaya_patient/data/session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_flow_test.dart' show FakeServer, l, png, pumpApp, tap;
import 'auth_test.dart' show pharmacy;
import 'patient_api_test.dart' show patientJson;

MemorySessionStore signedIn(FakeServer server) {
  server.me = {...patientJson, 'pharmacy': pharmacy};
  return MemorySessionStore(jsonEncode({'session_token': 's.x', 'patient': server.me}));
}

void main() {
  testWidgets('a prescription photo in the chat', (tester) async {
    final server = FakeServer();
    server.consultation('c1', status: 'sent');
    await pumpApp(tester, server, signedIn(server));
    await tap(tester, l.status('sent'));

    await tester.tap(find.byTooltip(l.attachPhoto));
    await tester.pumpAndSettle();
    await tap(tester, l.takePhoto);

    expect(server.seen, contains('POST /consultations/c1/photos'));
    expect(server.photos.values.single, isNotEmpty);
    expect(find.byType(Image), findsOneWidget);
    expect(server.seen, contains('GET /photos/photo1'));
  });

  testWidgets('a prescription photo with a pickup order', (tester) async {
    final server = FakeServer();
    await pumpApp(tester, server, signedIn(server));
    await tap(tester, 'Panadol 500mg');
    await tap(tester, l.orderFromPharmacy);
    await tap(tester, '${l.viewCart} (${l.inCart('1')})');

    await tap(tester, l.attachPrescription);
    await tap(tester, l.fromGallery);
    expect(find.text(l.prescriptionPhotoHint), findsOneWidget);
    await tap(tester, l.sendOrder);

    expect(server.seen, containsAllInOrder(['POST /photos', 'POST /orders', 'photo_id photo1']));
    expect(png, isNotEmpty);
  });
}
