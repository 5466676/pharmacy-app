import 'package:doaya_patient/data/status_watch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doaya_patient/l10n/app_localizations.dart';

final l = lookupAppLocalizations(const Locale('ar'));

Map<String, Object?> updates(
  String now, {
  List<(String, String)> c = const [],
  List<(String, String)> o = const [],
}) => {
  'now': now,
  'consultations': [
    for (final (id, s) in c) {'id': id, 'status': s},
  ],
  'orders': [
    for (final (id, s) in o) {'id': id, 'status': s},
  ],
};

void main() {
  test('the first check learns; later ones tell only what changed and matters', () {
    final w = StatusWatch();
    expect(
      w.apply(updates('2026-09-26T10:00:00Z', c: [('c1', 'sent')], o: [('o1', 'ready')]), l),
      isEmpty,
    );
    expect(w.since, DateTime.parse('2026-09-26T10:00:00Z'));

    final n = w.apply(
      updates(
        '2026-09-26T10:15:00Z',
        c: [('c1', 'ready'), ('c2', 'chatting')],
        o: [('o1', 'ready'), ('o2', 'rejected')],
      ),
      l,
    );
    expect(n.map((x) => (x.title, x.route)), [
      (l.noticeConsultationReady, '/chat/c1'),
      (l.noticeOrderRejected, '/order/o2'),
    ]);
    // The same answer again (the app and the background both asked): nothing new.
    expect(w.apply(updates('2026-09-26T10:16:00Z', c: [('c1', 'ready')]), l), isEmpty);
    expect(
      w.apply(updates('2026-09-26T10:20:00Z', c: [('c1', 'needs_doctor')]), l).single.title,
      l.noticeNeedsDoctor,
    );
  });

  test('kept across restarts; ids stay under the reminders range', () {
    final w = StatusWatch()..apply(updates('2026-09-26T10:00:00Z', c: [('c1', 'sent')]), l);
    final back = StatusWatch.decode(w.encode());
    expect(back.known, {'c:c1': 'sent'});
    final n = back.apply(updates('2026-09-26T11:00:00Z', c: [('c1', 'preparing')]), l).single;
    expect(n.id, inInclusiveRange(1, 999));
    expect(StatusWatch.decode('junk').since, isNull);
  });
}
