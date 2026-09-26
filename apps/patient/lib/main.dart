import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'background.dart';
import 'data/doses.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  // A tapped notification opens its page.
  await container
      .read(deviceNotificationsProvider)
      .init(onOpen: container.read(notificationRouteProvider.notifier).open);
  unawaited(startBackgroundChecks());
  runApp(UncontrolledProviderScope(container: container, child: const PatientApp()));
}
