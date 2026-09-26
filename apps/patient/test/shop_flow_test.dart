import 'dart:async';
import 'dart:convert';

import 'package:doaya_patient/data/patient_api.dart';
import 'package:doaya_patient/data/session_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_flow_test.dart' show FakeServer, l, pumpApp, tap;
import 'auth_test.dart' show pharmacy;
import 'patient_api_test.dart' show patientJson;

void main() {
  testWidgets('from the shelf to a pickup order; the pharmacist\'s quantities show live', (
    tester,
  ) async {
    final server = FakeServer()..me = {...patientJson, 'pharmacy': pharmacy};
    final store = MemorySessionStore();
    await store.write(
      jsonEncode(
        PatientSession.fromJsonString(jsonEncode({'session_token': 's.x', 'patient': server.me}))!
            .toJson(),
      ),
    );
    final live = StreamController<Object?>();
    addTearDown(live.close);
    await pumpApp(tester, server, store, live: live.stream);

    // Home: what's available (Augmentin isn't).
    expect(find.text(l.availableAtPharmacy), findsOneWidget);
    expect(find.text('Omega 3'), findsOneWidget);
    expect(find.text('Augmentin 1g'), findsNothing);
    await tap(tester, 'Panadol 500mg');

    // The product page.
    expect(find.text(l.noPrescription), findsOneWidget);
    expect(find.text('2,500 ل.س'), findsOneWidget);
    await tester.tap(find.byTooltip(l.more));
    await tester.pump();
    await tap(tester, l.orderFromPharmacy);
    expect(find.text('2'), findsWidgets); // the cart badge
    await tap(tester, '${l.viewCart} (${l.inCart('2')})');

    // The cart: total, pay at pickup, send.
    expect(find.text(l.orderTotal('5,000 ل.س')), findsOneWidget);
    expect(find.text(l.payAtPickup), findsOneWidget);
    await tap(tester, l.sendOrder);
    expect(server.seen, contains('POST /orders'));
    expect(find.text(l.orderStatus('sent')), findsOneWidget);
    expect(find.text(l.cancelOrder), findsOneWidget);

    // The pharmacist has only one: the page follows over the socket.
    server.orders['o1']!
      ..['status'] = 'ready'
      ..['pharmacist_note'] = 'في علبة وحدة بس'
      ..['handled_by'] = 'سامر'
      ..['lines'] = [
        {...(server.orders['o1']!['lines']! as List).single as Map, 'quantity': 1},
      ]
      ..['total_minor'] = 250000;
    live.add(jsonEncode({'type': 'order', 'order_id': 'o1', 'status': 'ready'}));
    await tester.pumpAndSettle();
    expect(find.text(l.orderStatus('ready')), findsOneWidget);
    expect(find.text(l.lineChanged('2', '1')), findsOneWidget);
    expect(find.textContaining('في علبة وحدة بس'), findsOneWidget);
    expect(find.text(l.cancelOrder), findsNothing);

    // Back lands on «طلباتي», not on the empty cart.
    await tester.tap(find.byTooltip(l.cancel).first);
    await tester.pumpAndSettle();
    expect(find.text(l.ordersTitle), findsWidgets); // title + the active tab
    expect(find.text(l.orderStatus('ready')), findsOneWidget);
    expect(find.text(l.cartEmpty), findsNothing);
  });

  testWidgets('search, an unavailable prescription medicine can\'t be ordered', (tester) async {
    final server = FakeServer()..me = {...patientJson, 'pharmacy': pharmacy};
    final store = MemorySessionStore();
    await store.write(jsonEncode({'session_token': 's.x', 'patient': server.me}));
    await pumpApp(tester, server, store);

    await tap(tester, l.seeAll);
    expect(find.text(l.shelfTitle), findsOneWidget);
    expect(find.text('Augmentin 1g'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'اوغ');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Panadol 500mg'), findsNothing);
    await tap(tester, 'Augmentin 1g');
    expect(find.text(l.rxHint), findsOneWidget);
    expect(find.text(l.orderFromPharmacy), findsNothing);
  });
}
