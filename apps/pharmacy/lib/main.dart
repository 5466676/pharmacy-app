import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/database.dart';
import 'providers.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(AppDatabase.open())],
      child: const PharmacyApp(),
    ),
  );
}
