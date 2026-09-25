import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'data/database.dart';
import 'data/device_backup.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // A restore chosen in Settings takes place before the database opens.
  await DeviceBackup.applyPendingRestore(
    (await getApplicationSupportDirectory()).path,
    AppDatabase.fileName,
  );
  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(AppDatabase.open())],
      child: const PharmacyApp(),
    ),
  );
}
