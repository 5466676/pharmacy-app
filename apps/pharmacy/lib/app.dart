import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/backup_controller.dart';
import 'data/look_store.dart';
import 'l10n/app_localizations.dart';
import 'providers.dart';
import 'router.dart';

/// Desktop counters get the solid theme (no blur, fast on old laptops);
/// phones get glass.
bool get isDesktopPlatform => switch (defaultTargetPlatform) {
  TargetPlatform.windows || TargetPlatform.linux || TargetPlatform.macOS => true,
  _ => false,
};

class PharmacyApp extends ConsumerWidget {
  const PharmacyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Daily backups once the pharmacy is set up on this device.
    if (ref.watch(thisDeviceProvider).value != null) ref.watch(backupProvider);
    // Built under the scope, after the look is applied, so the theme is
    // always the current one.
    return DoayaLookScope(
      look: ref.watch(lookProvider),
      child: Builder(
        builder: (context) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appName,
          theme: isDesktopPlatform ? DoayaTheme.solid() : DoayaTheme.glass(),
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: ref.watch(routerProvider),
          builder: (context, child) =>
              DoayaLookScope.textScaled(context, DoayaBackground(child: child)),
        ),
      ),
    );
  }
}
