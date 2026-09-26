import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import 'data/device_notifications.dart';
import 'data/doses.dart';
import 'data/patient_api.dart';
import 'data/providers.dart' show apiBaseUrl;
import 'data/reminders.dart';
import 'data/session_store.dart';

const _task = 'doaya-updates';

/// With the app closed (Android): about every 15 minutes, when there's a
/// connection, ask Doaya online what changed and top up the dose
/// reminders. Android's own scheduler runs it: no Google push service.
Future<void> startBackgroundChecks() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  await Workmanager().initialize(backgroundDispatcher);
  await Workmanager().registerPeriodicTask(
    _task,
    _task,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}

@pragma('vm:entry-point')
void backgroundDispatcher() {
  Workmanager().executeTask((_, _) async {
    WidgetsFlutterBinding.ensureInitialized();
    await backgroundCheck(DeviceNotifications(), now: DateTime.now());
    return true;
  });
}

/// One background round. Signed out: nothing to do.
Future<void> backgroundCheck(
  DeviceNotifications notifications, {
  required DateTime now,
  SessionStore? session,
  SessionStore? reminders,
  SessionStore? watch,
  PatientApi? api,
}) async {
  await notifications.init();
  await scheduleDoses(
    notifications,
    decodeReminders(await (reminders ?? SessionStore('reminders')).read()),
    now,
  );
  final saved = PatientSession.fromJsonString(await (session ?? SessionStore()).read());
  if (saved == null) return;
  final client = api ?? PatientApi(apiBaseUrl);
  try {
    client.resume(saved.sessionToken);
    await checkUpdates(client, watch ?? SessionStore('watch'), notifications);
  } on Object {
    // Offline or signed out elsewhere: try again next round.
  } finally {
    if (api == null) client.close();
  }
}
