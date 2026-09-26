import 'dart:async';

import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_store.dart';

/// The panel's three designs (owner's choice: all three, switchable). Each
/// is a [DoayaLook], so every colour still comes from the design system,
/// with its contrast guarantees. No blur anywhere: the panel is a desktop
/// tool.
enum AdminIdentity {
  /// «غرفة القيادة»: dark, dense, sharp, cyan.
  console(
    DoayaLook(
      style: DoayaStyle.outline,
      mode: DoayaMode.black,
      palette: DoayaLook.custom,
      customMain: Color(0xFF4FC3D3),
      customDark: Color(0xFF0A1214),
      customLight: Color(0xFFEFF5F6),
      radius: 0.35,
      density: 0.72,
      headingFont: DoayaHeadingFont.readex,
    ),
  ),

  /// «الدفتر»: light, navy and blue ink.
  ledger(
    DoayaLook(
      style: DoayaStyle.flat,
      mode: DoayaMode.light,
      palette: DoayaLook.custom,
      customMain: Color(0xFF2F4FD6),
      customDark: Color(0xFF141C2B),
      customLight: Color(0xFFF2F4F7),
      radius: 0.7,
      headingFont: DoayaHeadingFont.readex,
    ),
  ),

  /// «من عيلة دوايا»: Doaya green, Amiri headings, solid.
  family(DoayaLook(style: DoayaStyle.flat, radius: 1.2));

  const AdminIdentity(this.look);
  final DoayaLook look;
}

final identityStoreProvider = Provider<SessionStore>((ref) => SessionStore('identity'));

class IdentityController extends Notifier<AdminIdentity> {
  @override
  AdminIdentity build() {
    scheduleMicrotask(_load);
    return AdminIdentity.console;
  }

  Future<void> _load() async {
    try {
      final s = await ref.read(identityStoreProvider).read();
      state = AdminIdentity.values.firstWhere((i) => i.name == s, orElse: () => state);
    } on Object {
      // Keep the default.
    }
  }

  Future<void> set(AdminIdentity identity) async {
    state = identity;
    try {
      await ref.read(identityStoreProvider).write(identity.name);
    } on Object {
      // Not saved; applies until the tab closes.
    }
  }
}

final identityProvider = NotifierProvider<IdentityController, AdminIdentity>(
  IdentityController.new,
);
