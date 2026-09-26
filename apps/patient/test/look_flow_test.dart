import 'dart:convert';

import 'package:doaya_patient/data/session_store.dart';
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_flow_test.dart' show FakeServer, l, pumpApp, tap;
import 'auth_test.dart' show pharmacy;
import 'patient_api_test.dart' show patientJson;

void main() {
  tearDown(() => DoayaAppearance.apply(const DoayaLook()));

  testWidgets('«المظهر»: day mode and navy apply at once, and after a restart', (tester) async {
    final server = FakeServer()..me = {...patientJson, 'pharmacy': pharmacy};
    String session() => jsonEncode({'session_token': 's.x', 'patient': server.me});
    final look = MemorySessionStore();
    await pumpApp(tester, server, MemorySessionStore(session()), look: look);
    expect(DoayaColors.bgMid, DoayaPalette.classic.bgMid);

    await tap(tester, l.navAccount);
    await tap(tester, l.lookTitle);
    await tap(tester, l.lookModeLight);
    await tester.ensureVisible(find.byTooltip(l.lookPaletteNavy));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(l.lookPaletteNavy));
    await tester.pumpAndSettle();

    final navyDay = DoayaPalette.of(const DoayaLook(palette: 'navy', mode: DoayaMode.light));
    expect(DoayaColors.bgMid, navyDay.bgMid);
    expect(DoayaColors.accent, navyDay.accent);
    final saved = DoayaLook.fromJson(jsonDecode(look.value!) as Map<String, Object?>);
    expect((saved.mode, saved.palette), (DoayaMode.light, 'navy'));

    // Back to the default before a "restart": the saved look comes back.
    await tester.pumpWidget(const SizedBox());
    DoayaAppearance.apply(const DoayaLook());
    await pumpApp(tester, server, MemorySessionStore(session()), look: look);
    await tester.pumpAndSettle();
    expect(DoayaColors.bgMid, navyDay.bgMid);
  });
}
