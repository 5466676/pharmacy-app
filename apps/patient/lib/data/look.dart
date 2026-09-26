import 'dart:async';
import 'dart:convert';

import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_store.dart';

/// «المظهر» is kept on this device only.
final lookStoreProvider = Provider<SessionStore>((ref) => SessionStore('look'));

class LookController extends Notifier<DoayaLook> {
  @override
  DoayaLook build() {
    scheduleMicrotask(_load);
    return const DoayaLook();
  }

  Future<void> _load() async {
    try {
      final s = await ref.read(lookStoreProvider).read();
      if (s != null) state = DoayaLook.fromJson(jsonDecode(s) as Map<String, Object?>);
    } on Object {
      // Unreadable: keep the default look.
    }
  }

  Future<void> set(DoayaLook look) async {
    state = look;
    try {
      await ref.read(lookStoreProvider).write(jsonEncode(look.toJson()));
    } on Object {
      // Not saved; it still applies until the app closes.
    }
  }
}

final lookProvider = NotifierProvider<LookController, DoayaLook>(LookController.new);
