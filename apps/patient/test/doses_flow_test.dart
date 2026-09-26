import 'dart:convert';

import 'package:doaya_patient/data/doses.dart';
import 'package:doaya_patient/data/reminders.dart';
import 'package:doaya_patient/data/session_store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_flow_test.dart' show FakeServer, l, pumpApp, tap;
import 'auth_test.dart' show pharmacy;
import 'fake_notifications.dart';
import 'patient_api_test.dart' show patientJson;

void main() {
  testWidgets('«ذكّرني بالجرعات» from the pharmacist\'s decision to «جرعاتي»', (tester) async {
    final server = FakeServer()..me = {...patientJson, 'pharmacy': pharmacy};
    server.consultation('c1', status: 'ready')['decision'] = {
      'items': [
        {
          'name': 'Amoxil 500mg',
          'quantity': 1,
          'instructions': 'كبسولة كل 8 ساعات بعد الأكل',
          'times_per_day': 3,
          'days': 7,
        },
        {'name': 'Panadol', 'quantity': 1, 'instructions': 'عند اللزوم'},
      ],
      'by': 'سامر',
    };
    final store = MemorySessionStore(jsonEncode({'session_token': 's.x', 'patient': server.me}));
    final notifications = FakeNotifications();
    final reminders = MemorySessionStore();
    await pumpApp(tester, server, store, notifications: notifications, reminders: reminders);

    await tap(tester, l.status('ready'));
    await tap(tester, l.remindMe);

    // Now on «جرعاتي», with only the medicine that has doses a day.
    expect(find.text(l.dosesTitle), findsWidgets);
    expect(find.text('Amoxil 500mg'), findsOneWidget);
    expect(find.text('Panadol'), findsNothing);
    expect(find.text('08:00'), findsOneWidget);
    expect(notifications.permissionAsked, 1);
    expect(notifications.scheduled, isNotEmpty);
    expect(notifications.scheduled[reminderIdBase]!.$2, l.doseTitle('Amoxil 500mg'));

    // Half an hour later for the first dose.
    await tester.tap(find.byTooltip(l.later).first);
    await tester.pumpAndSettle();
    expect(find.text('08:30'), findsOneWidget);
    expect(decodeReminders(reminders.value).single.times.first, 8 * 60 + 30);
  });
}
