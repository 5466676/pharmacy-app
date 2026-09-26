import 'dart:convert';

import 'package:doaya_patient/background.dart';
import 'package:doaya_patient/data/doses.dart';
import 'package:doaya_patient/data/patient_api.dart';
import 'package:doaya_patient/data/reminders.dart';
import 'package:doaya_patient/data/session_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_flow_test.dart' show FakeServer, l;
import 'fake_notifications.dart';
import 'patient_api_test.dart' show patientJson;

Reminder amoxil(DateTime start) => Reminder(
  id: 'c1:0',
  consultationId: 'c1',
  name: 'Amoxil',
  instructions: 'كبسولة كل 8 ساعات بعد الأكل',
  times: defaultTimes(3),
  start: start,
  days: 7,
);

void main() {
  test('the next doses are scheduled, earliest first, with the pharmacist\'s words', () async {
    final n = FakeNotifications();
    final now = DateTime(2026, 9, 26, 15);
    final vitD = Reminder(
      id: 'c1:1',
      consultationId: 'c1',
      name: 'Vit D',
      instructions: 'بعد الغدا',
      times: const [13 * 60],
      start: DateTime(2026, 9, 26),
    );
    await scheduleDoses(n, [amoxil(DateTime(2026, 9, 26)), vitD], now);
    expect(n.scheduled, hasLength(scheduledAhead));
    final first = [for (var i = 0; i < 3; i++) n.scheduled[reminderIdBase + i]!];
    expect(first.map((d) => (d.$1, d.$2)), [
      (DateTime(2026, 9, 26, 20), l.doseTitle('Amoxil')),
      (DateTime(2026, 9, 27, 8), l.doseTitle('Amoxil')),
      (DateTime(2026, 9, 27, 13), l.doseTitle('Vit D')),
    ]);
    expect(first.first.$3, 'كبسولة كل 8 ساعات بعد الأكل');

    // Turned off: rescheduling leaves nothing behind.
    await scheduleDoses(n, [amoxil(DateTime(2026, 9, 26)).copyWith(enabled: false)], now);
    expect(n.scheduled, isEmpty);
  });

  test('the reminders controller saves, reschedules and asks permission once added', () async {
    final n = FakeNotifications();
    final store = MemorySessionStore();
    final c = ProviderContainer(
      overrides: [
        deviceNotificationsProvider.overrideWithValue(n),
        remindersStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(c.dispose);
    final ctl = c.read(remindersProvider.notifier);
    await c.read(remindersProvider.future);
    await ctl.put([amoxil(DateTime.now())]);
    expect(n.permissionAsked, 1);
    expect(decodeReminders(store.value).single.name, 'Amoxil');
    expect(n.scheduled, isNotEmpty);

    await ctl.setTimes('c1:0', [9 * 60, 21 * 60]);
    expect(c.read(remindersProvider).value!.single.times, [540, 1260]);
    await ctl.setEnabled('c1:0', false);
    expect(n.scheduled, isEmpty);
    await ctl.remove('c1:0');
    expect(decodeReminders(store.value), isEmpty);
  });

  test('the background round: learns first, then notifies a ready case once', () async {
    final server = FakeServer()..me = Map.of(patientJson);
    server.consultation('c1', status: 'sent');
    final session = MemorySessionStore(jsonEncode({'session_token': 's.x', 'patient': server.me}));
    final watch = MemorySessionStore();
    final n = FakeNotifications();
    Future<void> round() => backgroundCheck(
      n,
      now: DateTime(2026, 9, 26, 10),
      session: session,
      reminders: MemorySessionStore(encodeReminders([amoxil(DateTime(2026, 9, 26))])),
      watch: watch,
      api: PatientApi(Uri.parse('https://x/'), client: server.client),
    );

    await round();
    expect(n.shown, isEmpty);
    expect(n.scheduled, isNotEmpty); // doses topped up even with nothing new

    server.consultations['c1']!['status'] = 'ready';
    await round();
    expect(n.shown.single.$2, l.noticeConsultationReady);
    expect(n.shown.single.$4, '/chat/c1');
    await round();
    expect(n.shown, hasLength(1));

    // Signed out: the doses still come, nothing is asked of the server.
    await session.write(null);
    final before = server.seen.length;
    await round();
    expect(server.seen.length, before);
  });
}
