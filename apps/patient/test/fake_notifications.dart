import 'package:doaya_patient/data/device_notifications.dart';

/// Records what would show on the phone.
class FakeNotifications implements DeviceNotifications {
  final shown = <(int, String, String, String?)>[];
  final scheduled = <int, (DateTime, String, String)>{};
  var permissionAsked = 0;

  @override
  bool get canSchedule => true;
  @override
  Future<void> init({void Function(String route)? onOpen}) async {}
  @override
  Future<bool> requestPermission() async {
    permissionAsked++;
    return true;
  }

  @override
  Future<void> show(int id, String title, String body, {String? route}) async =>
      shown.add((id, title, body, route));

  @override
  Future<void> schedule(int id, DateTime at, String title, String body, {String? route}) async =>
      scheduled[id] = (at, title, body);

  @override
  Future<void> cancel(Iterable<int> ids) async => ids.forEach(scheduled.remove);
}
