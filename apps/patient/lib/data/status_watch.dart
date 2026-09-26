import 'dart:convert';

import '../l10n/app_localizations.dart';

/// A notification to show about a change the patient should know of.
class Notice {
  const Notice({required this.id, required this.title, required this.body, required this.route});

  final int id;
  final String title;
  final String body;

  /// Where tapping it goes.
  final String route;
}

/// What the patient last knew about each consultation and order, so a
/// background check tells only what's new. Kept on the device.
class StatusWatch {
  StatusWatch({Map<String, String>? known, this.since}) : known = known ?? {};

  factory StatusWatch.decode(String? s) {
    if (s == null) return StatusWatch();
    try {
      final j = jsonDecode(s) as Map<String, Object?>;
      return StatusWatch(
        known: (j['known']! as Map).cast<String, String>(),
        since: j['since'] == null ? null : DateTime.parse(j['since']! as String),
      );
    } on Object {
      return StatusWatch();
    }
  }

  final Map<String, String> known;
  DateTime? since;

  String encode() => jsonEncode({'known': known, 'since': since?.toIso8601String()});

  static const _consultation = {'preparing', 'ready', 'needs_doctor'};
  static const _order = {'ready', 'rejected'};

  /// Folds one `/updates` answer in; returns what to tell the patient.
  /// The very first check only learns (no flood after installing).
  List<Notice> apply(Map<String, Object?> updates, AppLocalizations l) {
    final first = since == null;
    final out = <Notice>[];
    for (final c in (updates['consultations'] as List? ?? const [])) {
      if (c case {'id': final String id, 'status': final String status}) {
        final key = 'c:$id';
        if (!first && known[key] != status && _consultation.contains(status)) {
          out.add(switch (status) {
            'ready' => Notice(
              id: _id(key),
              title: l.noticeConsultationReady,
              body: l.noticeConsultationReadyBody,
              route: '/chat/$id',
            ),
            'needs_doctor' => Notice(
              id: _id(key),
              title: l.noticeNeedsDoctor,
              body: l.noticeNeedsDoctorBody,
              route: '/chat/$id',
            ),
            _ => Notice(
              id: _id(key),
              title: l.noticePreparing,
              body: l.noticeNeedsDoctorBody,
              route: '/chat/$id',
            ),
          });
        }
        known[key] = status;
      }
    }
    for (final o in (updates['orders'] as List? ?? const [])) {
      if (o case {'id': final String id, 'status': final String status}) {
        final key = 'o:$id';
        if (!first && known[key] != status && _order.contains(status)) {
          out.add(
            Notice(
              id: _id(key),
              title: status == 'ready' ? l.noticeOrderReady : l.noticeOrderRejected,
              body: l.noticeOrderBody,
              route: '/order/$id',
            ),
          );
        }
        known[key] = status;
      }
    }
    if (updates['now'] case final String now) since = DateTime.parse(now);
    return out;
  }

  /// Update notices use ids 1..999 (reminders use 1000 and up).
  static int _id(String key) => 1 + key.codeUnits.fold(7, (h, c) => (h * 31 + c) % 999);
}
