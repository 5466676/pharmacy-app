import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/doses.dart';
import 'data/live_updates.dart';
import 'data/providers.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';

class PatientApp extends ConsumerWidget {
  const PatientApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(authProvider.select((a) => a.signedIn))) {
      ref.watch(liveUpdatesProvider);
      // Tops up the phone's dose schedule on every start.
      ref.watch(remindersProvider);
    }
    ref.listen(notificationRouteProvider, (_, route) {
      if (route == null) return;
      ref.read(notificationRouteProvider.notifier).done();
      ref.read(routerProvider).push(route);
    });
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: DoayaTheme.glass(),
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => DoayaBackground(child: child),
    );
  }
}
