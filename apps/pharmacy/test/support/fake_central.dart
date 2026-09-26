import 'dart:typed_data';

import 'package:doaya_core/doaya_core.dart';

/// Doaya online as the pharmacy's server forwards it (`/central/…`), in
/// memory, with the same JSON shapes as backend/app/consultations.py and
/// orders.py.
class FakeCentral {
  var connected = true;
  var online = true;
  final cases = <String, Map<String, Object?>>{};
  final orders = <String, Map<String, Object?>>{};
  final corrections = <Map<String, Object?>>[];
  var _messageId = 100;
  String actor = 'سامر';

  static Map<String, Object?> patient({
    String name = 'مازن',
    String phone = '0933111222',
    int? age = 34,
    String? sex = 'm',
  }) => {'name': name, 'phone': phone, 'age': age, 'sex': sex};

  Map<String, Object?> addCase(
    String id, {
    bool urgent = false,
    String status = 'sent',
    String? redFlag,
    Map<String, Object?>? summary,
    List<(String, String)> messages = const [],
    Map<String, Object?>? patient,
    DateTime? sentAt,
  }) {
    final at = (sentAt ?? DateTime.utc(2026, 9, 26, 10)).toIso8601String();
    return cases[id] = {
      'id': id,
      'pharmacy_id': 'ph',
      'status': status,
      'urgent': urgent,
      'red_flag': redFlag,
      'summary': summary,
      'decision': null,
      'handled_by': null,
      'created_at': at,
      'sent_at': at,
      'updated_at': at,
      'messages': [for (final (role, text) in messages) _message(role, text)],
      'patient': patient ?? FakeCentral.patient(),
    };
  }

  Map<String, Object?> addOrder(
    String id, {
    required List<(String productId, String name, int qty, int price)> lines,
    String? note,
    Map<String, Object?>? patient,
  }) => orders[id] = {
    'id': id,
    'pharmacy_id': 'ph',
    'status': 'sent',
    'lines': [
      for (final (p, n, q, price) in lines)
        {'product_id': p, 'name': n, 'requested': q, 'quantity': q, 'price_minor': price},
    ],
    'currency': 'SYP',
    'note': note,
    'pharmacist_note': null,
    'handled_by': null,
    'created_at': '2026-09-26T09:00:00Z',
    'updated_at': '2026-09-26T09:00:00Z',
    'patient': patient ?? FakeCentral.patient(),
  };

  Map<String, Object?> _message(String role, String text, {String? author}) => {
    'id': _messageId++,
    'role': role,
    'text': text,
    'quick_replies': null,
    'author': author,
    'created_at': '2026-09-26T10:00:00Z',
  };

  /// Patients' photos by id (PNG bytes).
  final photos = <String, Uint8List>{};

  Object? handle(String method, String path, Object? body) {
    final b = (body as Map<String, Object?>?) ?? const {};
    if (path == 'central-link') {
      switch (method) {
        case 'GET':
          return {'linked': connected, 'url': connected ? 'https://doaya.example' : null};
        case 'PUT':
          if (b['key'] != 'dk_good') throw const SyncApiException(400, 'bad_pharmacy_key');
          connected = true;
          return {'linked': true};
        default:
          connected = false;
          return {'linked': false};
      }
    }
    if (!connected) throw const SyncApiException(503, 'central_not_configured');
    if (!online) throw const SyncApiException(503, 'central_unreachable');
    final parts = path.split('/').skip(1).toList(); // after "central"
    switch ((method, parts)) {
      case ('GET', ['photos', final id]):
        return photos[id] ?? (throw const SyncApiException(404, 'photo_not_found'));
      case ('GET', ['cases']):
        final list = cases.values.toList()
          ..sort((a, b) {
            final u = (b['urgent']! as bool ? 1 : 0) - (a['urgent']! as bool ? 1 : 0);
            return u != 0 ? u : (b['sent_at']! as String).compareTo(a['sent_at']! as String);
          });
        return [
          for (final c in list)
            {
              ...c,
              'title': (c['summary'] as Map?)?['symptoms'] is List
                  ? ((c['summary']! as Map)['symptoms'] as List).join('، ')
                  : (c['messages']! as List).isEmpty
                  ? ''
                  : ((c['messages']! as List).first as Map)['text'],
            },
        ];
      case ('GET', ['cases', final id]):
        return cases[id] ?? (throw const SyncApiException(404, 'case_not_found'));
      case ('POST', ['cases', final id, final action]):
        final c = cases[id] ?? (throw const SyncApiException(404, 'case_not_found'));
        final messages = c['messages']! as List;
        switch (action) {
          case 'messages':
            messages.add(_message('pharmacist', b['text']! as String, author: actor));
            if (c['status'] == 'sent') c['status'] = 'preparing';
          case 'preparing':
            c['status'] = 'preparing';
          case 'decision':
            c['status'] = 'ready';
            c['decision'] = {...b, 'by': actor};
            messages.add(_message('pharmacist', 'جاهز', author: actor));
          case 'needs-doctor':
            c['status'] = 'needs_doctor';
          case 'picked-up':
            if (c['status'] != 'ready') throw const SyncApiException(409, 'bad_status');
            c['status'] = 'picked_up';
          case 'close':
            c['status'] = 'closed';
          case 'corrections':
            corrections.add({...b, 'case': id});
            return {'ok': true};
        }
        c['handled_by'] = actor;
        return c;
      case ('GET', ['orders']):
        return orders.values.toList();
      case ('POST', ['orders', final id, 'status']):
        final o = orders[id] ?? (throw const SyncApiException(404, 'order_not_found'));
        final q = (b['quantities'] as Map?)?.cast<String, int>();
        if (q != null) {
          o['lines'] = [
            for (final l in (o['lines']! as List).cast<Map<String, Object?>>())
              if ((q[l['product_id']] ?? l['quantity']! as int) > 0)
                {...l, 'quantity': q[l['product_id']] ?? l['quantity']},
          ];
        }
        o['status'] = b['status'];
        if (b['note'] != null) o['pharmacist_note'] = b['note'];
        o['handled_by'] = actor;
        return o;
    }
    throw SyncApiException(404, 'not_found: $path');
  }
}

extension OrderTotals on Map<String, Object?> {
  /// Adds `total_minor` the way the server does.
  Map<String, Object?> withTotal() => {
    ...this,
    'total_minor': (this['lines']! as List).cast<Map<String, Object?>>().fold<int>(
      0,
      (s, l) => s + (l['quantity']! as int) * (l['price_minor']! as int),
    ),
  };
}
