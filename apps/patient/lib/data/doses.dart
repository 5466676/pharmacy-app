import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'device_notifications.dart';
import 'patient_api.dart';
import 'providers.dart';
import 'reminders.dart';
import 'session_store.dart';
import 'status_watch.dart';

/// Reminder notifications use ids from here up.
const reminderIdBase = 1000;

/// How many doses are scheduled ahead at once (topped up at every start
/// and background check).
const scheduledAhead = 60;

final _ar = lookupAppLocalizations(const Locale('ar'));

/// Schedules the next doses of every reminder, earliest first; the doses
/// scheduled before are cancelled first. Shared by the app and the
/// background check.
Future<void> scheduleDoses(
  DeviceNotifications notifications,
  List<Reminder> reminders,
  DateTime now,
) async {
  if (!notifications.canSchedule) return;
  await notifications.cancel([for (var i = 0; i < scheduledAhead; i++) reminderIdBase + i]);
  final doses = [
    for (final r in reminders)
      for (final at in r.upcoming(now, limit: scheduledAhead)) (at, r),
  ]..sort((a, b) => a.$1.compareTo(b.$1));
  for (final (i, (at, r)) in doses.take(scheduledAhead).indexed) {
    await notifications.schedule(
      reminderIdBase + i,
      at,
      _ar.doseTitle(r.name),
      r.instructions,
      route: '/doses',
    );
  }
}

/// Asks `/updates` and notifies what's new (a case or order ready…).
/// Shared by the open app and the background check.
Future<void> checkUpdates(
  PatientApi api,
  SessionStore watchStore,
  DeviceNotifications notifications,
) async {
  final watch = StatusWatch.decode(await watchStore.read());
  final notices = watch.apply(await api.updates(since: watch.since), _ar);
  await watchStore.write(watch.encode());
  for (final n in notices) {
    await notifications.show(n.id, n.title, n.body, route: n.route);
  }
}

final deviceNotificationsProvider = Provider<DeviceNotifications>((ref) => DeviceNotifications());
final remindersStoreProvider = Provider<SessionStore>((ref) => SessionStore('reminders'));
final watchStoreProvider = Provider<SessionStore>((ref) => SessionStore('watch'));

/// Where tapping a notification should go (the app listens).
final notificationRouteProvider = NotifierProvider<_Route, String?>(_Route.new);

class _Route extends Notifier<String?> {
  @override
  String? build() => null;
  void open(String route) => state = route;
  void done() => state = null;
}

/// «جرعاتي»: the patient's dose reminders, kept on the device.
class RemindersController extends AsyncNotifier<List<Reminder>> {
  SessionStore get _store => ref.read(remindersStoreProvider);
  DeviceNotifications get _notifications => ref.read(deviceNotificationsProvider);

  /// Tests set the clock.
  DateTime Function() now = DateTime.now;

  @override
  Future<List<Reminder>> build() async {
    final all = decodeReminders(await _store.read());
    // Keep the phone's schedule topped up on every start.
    await scheduleDoses(_notifications, all, now());
    return all;
  }

  Future<void> _save(List<Reminder> all) async {
    await _store.write(encodeReminders(all));
    state = AsyncData(all);
    await scheduleDoses(_notifications, all, now());
  }

  List<Reminder> get _all => state.value ?? const [];

  /// Adds (or replaces, same medicine of the same consultation).
  Future<void> put(List<Reminder> rs) async {
    if (_notifications.canSchedule) await _notifications.requestPermission();
    final ids = {for (final r in rs) r.id};
    await _save([..._all.where((r) => !ids.contains(r.id)), ...rs]);
  }

  Future<void> setTimes(String id, List<int> times) =>
      _save([for (final r in _all) r.id == id ? r.copyWith(times: times) : r]);

  Future<void> setEnabled(String id, bool on) =>
      _save([for (final r in _all) r.id == id ? r.copyWith(enabled: on) : r]);

  Future<void> remove(String id) => _save([..._all.where((r) => r.id != id)]);
}

final remindersProvider = AsyncNotifierProvider<RemindersController, List<Reminder>>(
  RemindersController.new,
);

/// The open app checks after each live event (the background task covers
/// the app closed).
Future<void> checkUpdatesNow(Ref ref) async {
  try {
    await checkUpdates(
      ref.read(apiProvider),
      ref.read(watchStoreProvider),
      ref.read(deviceNotificationsProvider),
    );
  } on Object {
    // Offline: the next check catches up.
  }
}
