import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Notifications on this device: shown now (a case is ready) or scheduled
/// (dose reminders). Android only for now; elsewhere nothing is shown and
/// [canSchedule] is false. No Google push: everything is local.
abstract class DeviceNotifications {
  bool get canSchedule;

  Future<void> init({void Function(String route)? onOpen});
  Future<bool> requestPermission();
  Future<void> show(int id, String title, String body, {String? route});
  Future<void> schedule(int id, DateTime at, String title, String body, {String? route});
  Future<void> cancel(Iterable<int> ids);

  /// The platform's own, or [NoDeviceNotifications] where unsupported.
  factory DeviceNotifications() => !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? AndroidDeviceNotifications()
      : NoDeviceNotifications();
}

class NoDeviceNotifications implements DeviceNotifications {
  @override
  bool get canSchedule => false;
  @override
  Future<void> init({void Function(String route)? onOpen}) async {}
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<void> show(int id, String title, String body, {String? route}) async {}
  @override
  Future<void> schedule(int id, DateTime at, String title, String body, {String? route}) async {}
  @override
  Future<void> cancel(Iterable<int> ids) async {}
}

class AndroidDeviceNotifications implements DeviceNotifications {
  final _plugin = FlutterLocalNotificationsPlugin();

  static const _updates = NotificationDetails(
    android: AndroidNotificationDetails(
      'updates',
      'حالاتك وطلباتك',
      channelDescription: 'لما الصيدلي يحضّرلك دوا أو طلب',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  static const _doses = NotificationDetails(
    android: AndroidNotificationDetails(
      'doses',
      'مواعيد الدوا',
      channelDescription: 'تذكير بمواعيد الدوا يلي حدّدها الصيدلي',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
    ),
  );

  @override
  bool get canSchedule => true;

  @override
  Future<void> init({void Function(String route)? onOpen}) async {
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (r) {
        if (r.payload case final route? when onOpen != null) onOpen(route);
      },
    );
    if (onOpen != null) {
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.notificationResponse?.payload case final route?
          when launch!.didNotificationLaunchApp) {
        onOpen(route);
      }
    }
  }

  @override
  Future<bool> requestPermission() async =>
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission() ??
      false;

  @override
  Future<void> show(int id, String title, String body, {String? route}) =>
      _plugin.show(id: id, title: title, body: body, notificationDetails: _updates, payload: route);

  @override
  Future<void> schedule(int id, DateTime at, String title, String body, {String? route}) =>
      _plugin.zonedSchedule(
        id: id,
        // UTC instants: the phone's clock decides the local time it shows.
        scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
        notificationDetails: _doses,
        // A few minutes' leeway, no exact-alarm permission needed.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: title,
        body: body,
        payload: route,
      );

  @override
  Future<void> cancel(Iterable<int> ids) async {
    for (final id in ids) {
      await _plugin.cancel(id: id);
    }
  }
}
