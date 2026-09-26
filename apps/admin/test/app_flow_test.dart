import 'dart:convert';

import 'package:doaya_admin/app.dart';
import 'package:doaya_admin/data/admin_api.dart';
import 'package:doaya_admin/data/identity.dart';
import 'package:doaya_admin/data/providers.dart';
import 'package:doaya_admin/data/session_store.dart';
import 'package:doaya_admin/router.dart';
import 'package:doaya_admin/ui/overview_screen.dart' show attentionFor;
import 'package:doaya_admin/data/models.dart';
import 'package:doaya_admin/l10n/app_localizations_ar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Doaya online as the panel sees it: one admin, two pharmacies, one item
/// to review, notes.
class FakeCentral {
  final calls = <String>[];
  final bodies = <String, Object?>{};
  String status = 'active';
  bool reviewed = false;
  final notes = <Map<String, Object?>>[];

  Map<String, Object?> pharmacy({bool detail = false}) => {
    'id': 'p1',
    'name': 'صيدلية الشفاء',
    'status': status,
    'status_reason': status == 'active' ? null : 'تأخير بالرد',
    'city': 'حلب',
    'code': 'SH4F',
    'listed': status == 'active',
    'patients': 318,
    'median_minutes': 2.8,
    'created_at': '2026-09-01T10:00:00Z',
    'last_heartbeat_at': DateTime.now().toUtc().toIso8601String(),
    'connected': true,
    'licence_days': 30,
    'health': 'warn',
    'health_requested': false,
    if (detail) ...{
      'active_keys': 1,
      'heartbeat': {
        'server_version': '0.1.0',
        'devices': [
          {'name': 'لابتوب الكاونتر', 'last_seen_at': null},
        ],
        'last_backup_at': DateTime.now().toUtc().toIso8601String(),
        'disk_free_mb': 50000,
      },
      'health_report': {
        'ran_at': '2026-09-20T10:00:00Z',
        'checks': [
          {'id': 'backup', 'level': 'ok', 'count': 0},
          {'id': 'open_shifts', 'level': 'warn', 'count': 2},
        ],
      },
      'health_at': '2026-09-20T10:00:00Z',
      'actions': [
        if (status != 'active')
          {
            'action': 'suspend',
            'reason': 'تأخير بالرد',
            'detail': {},
            'by': 'فايز',
            'at': '2026-09-26T10:00:00Z',
          },
      ],
    },
  };

  late final client = MockClient((r) async {
    final path = r.url.path;
    calls.add('${r.method} $path');
    if (r.body.isNotEmpty) bodies[path] = jsonDecode(r.body);
    Object? body;
    switch ((r.method, path)) {
      case ('POST', '/admin/login'):
        final b = jsonDecode(r.body) as Map;
        if (b['password'] != 'owner-pass-1') return _json({'detail': 'bad_credentials'}, 401);
        body = {
          'admin': {'id': 'a', 'name': 'فايز'},
          'session_token': 's.x',
          'access_token': 't',
          'expires_in': 900,
        };
      case ('POST', '/admin/token'):
        body = {'access_token': 't', 'expires_in': 900};
      case ('GET', '/admin/overview'):
        body = {
          'days': 30,
          'pharmacies': {
            'by_status': {'active': 1, 'pending': 0, 'suspended': 0, 'stopped': 0, 'removed': 0},
            'connected': 1,
            'new': 1,
          },
          'patients': {'registered': 1284, 'active': 612, 'new': 40},
          'today': {'consultations': 86, 'urgent': 3, 'urgent_unanswered': 0, 'orders': 41},
          'response': {
            'median_minutes': 4.2,
            'p90_minutes': 12.0,
            'answered': 500,
            'unanswered': 4,
            'target_minutes': 10,
            'by_day': [
              for (var d = 1; d <= 5; d++)
                {'day': '2026-09-0$d', 'median': 4.0 + d / 10, 'p90': 11.0, 'count': 20},
            ],
          },
          'review_waiting': reviewed ? 0 : 1,
        };
      case ('GET', '/admin/pharmacies'):
        body = [pharmacy()];
      case ('GET', '/admin/pharmacies/p1'):
        body = pharmacy(detail: true);
      case ('POST', '/admin/pharmacies/p1/actions'):
        final b = jsonDecode(r.body) as Map;
        if (b['action'] == 'suspend') status = 'suspended';
        body = pharmacy(detail: true);
      case ('GET', '/admin/review'):
        body = [if (r.url.queryParameters['reviewed'] == '$reviewed') _item()];
      case ('GET', '/admin/review/7'):
        body = {
          ..._item(),
          'status': 'emergency',
          'summary': null,
          'decision': null,
          'messages': [
            {
              'role': 'patient',
              'text': 'عندي ألم بالصدر',
              'author': null,
              'photo': false,
              'at': '2026-09-26T10:00:00Z',
            },
          ],
        };
      case ('POST', '/admin/review/7'):
        reviewed = true;
        body = _item();
      case ('GET', '/admin/knowledge'):
        body = notes;
      case ('POST', '/admin/knowledge'):
        final b = jsonDecode(r.body) as Map<String, Object?>;
        notes.add({
          'id': 'n${notes.length + 1}',
          ...b,
          'enabled': true,
          'created_at': '2026-09-26T10:00:00Z',
          'updated_at': '2026-09-26T10:00:00Z',
        });
        body = notes.last;
      default:
        return _json({'detail': 'not_found'}, 404);
    }
    return _json(body);
  });

  Map<String, Object?> _item() => {
    'id': 7,
    'kind': 'red_flag',
    'detail': {'source': 'rules', 'category': 'chest_pain'},
    'created_at': '2026-09-26T10:00:00Z',
    'reviewed': reviewed,
    'review_note': reviewed ? 'الإحالة صح' : null,
    'reviewed_at': null,
    'consultation_id': 'c1',
    'urgent': true,
    'red_flag': 'chest_pain',
    'age': 58,
    'sex': 'm',
    'pharmacy': 'صيدلية النور',
  };
}

http.Response _json(Object? body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late FakeCentral central;
  late ProviderContainer container;
  late MemorySessionStore session;
  late MemorySessionStore identity;

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container = ProviderContainer(
      overrides: [
        apiProvider.overrideWithValue(
          AdminApi(Uri.parse('http://central/'), client: central.client),
        ),
        sessionStoreProvider.overrideWithValue(session),
        identityStoreProvider.overrideWithValue(identity),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const AdminApp()),
    );
    await settle(tester);
  }

  Future<void> go(WidgetTester tester, String route) async {
    container.read(routerProvider).go(route);
    await settle(tester);
  }

  setUp(() {
    central = FakeCentral();
    session = MemorySessionStore();
    identity = MemorySessionStore();
  });

  testWidgets('sign in, see the overview; a wrong password is refused', (tester) async {
    await pumpApp(tester);
    expect(find.text('لوحة مالك دوايا'), findsOneWidget);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '٠٩٩٩٠٠٠١١١');
    await tester.enterText(fields.at(1), 'nope');
    await tester.tap(find.text('دخول'));
    await settle(tester);
    expect(find.text('الرقم أو كلمة السر غلط.'), findsOneWidget);

    await tester.enterText(fields.at(1), 'owner-pass-1');
    await tester.tap(find.text('دخول'));
    await settle(tester);
    expect((central.bodies['/admin/login']! as Map)['phone'], '0999000111');
    expect(find.text('1,284'), findsOneWidget);
    expect(find.text('4.2 د'), findsOneWidget);
    expect(find.text('1 محادثة ناطرة مراجعة'), findsOneWidget);
    expect(session.value, contains('s.x'));
  });

  testWidgets('suspend a pharmacy: the reason is required and sent', (tester) async {
    session.value = const AdminSession(sessionToken: 's.x', name: 'فايز').toJsonString();
    await pumpApp(tester);
    await go(tester, Routes.pharmacy('p1'));
    expect(find.text('صيدلية الشفاء'), findsWidgets);
    expect(find.text('ورديات مفتوحة أكتر من يوم'), findsOneWidget);
    expect(find.textContaining('ما بتوصلك أدويتهم'), findsOneWidget);

    await tester.tap(find.text('تعليق'));
    await settle(tester);
    await tester.tap(find.text('تأكيد'));
    await settle(tester);
    expect(find.text('اكتب السبب (3 أحرف عالأقل).'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).last, 'تأخير بالرد');
    await tester.tap(find.text('تأكيد'));
    await settle(tester);
    expect(central.bodies['/admin/pharmacies/p1/actions'], {
      'action': 'suspend',
      'reason': 'تأخير بالرد',
    });
    expect(find.text('معلّقة'), findsWidgets);
    expect(find.textContaining('فايز، '), findsOneWidget);
  });

  testWidgets('review: no patient name, mark reviewed, note to the knowledge base', (tester) async {
    session.value = const AdminSession(sessionToken: 's.x', name: 'فايز').toJsonString();
    await pumpApp(tester);
    await go(tester, Routes.reviewItem(7));
    expect(find.text('رجل، 58 سنة، صيدلية النور'), findsWidgets);
    expect(find.text('عندي ألم بالصدر'), findsOneWidget);

    await tester.tap(find.text('حوّلها لملاحظة بقاعدة المعرفة'));
    await settle(tester);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(fields.evaluate().length - 3), 'ألم صدر');
    await tester.enterText(fields.at(fields.evaluate().length - 2), 'اسأل إذا الألم بيمتد للإيد.');
    await tester.enterText(fields.last, 'صدر، قلب');
    await tester.tap(find.text('حفظ'));
    await settle(tester);
    expect(central.bodies['/admin/knowledge'], {
      'title': 'ألم صدر',
      'text': 'اسأل إذا الألم بيمتد للإيد.',
      'tags': ['صدر', 'قلب'],
      'source_log_id': 7,
    });

    await tester.enterText(find.byType(TextFormField).first, 'الإحالة صح');
    await tester.tap(find.text('تمت المراجعة'));
    await settle(tester);
    expect(central.bodies['/admin/review/7'], {'note': 'الإحالة صح'});
    expect(central.reviewed, isTrue);
  });

  testWidgets('the three designs switch at once and are remembered', (tester) async {
    session.value = const AdminSession(sessionToken: 's.x', name: 'فايز').toJsonString();
    await pumpApp(tester);
    expect(container.read(identityProvider), AdminIdentity.console);
    await tester.tap(find.text('الدفتر').first);
    await settle(tester);
    expect(container.read(identityProvider), AdminIdentity.ledger);
    expect(identity.value, 'ledger');
    expect(Theme.of(tester.element(find.byType(Scaffold).first)).brightness, Brightness.light);
    await tester.tap(find.text('من عيلة دوايا').first);
    await settle(tester);
    expect(Theme.of(tester.element(find.byType(Scaffold).first)).brightness, Brightness.dark);
  });

  test('pharmacies needing attention', () {
    final l = AppLocalizationsAr();
    final now = DateTime(2026, 9, 26, 12);
    Pharmacy p(
      String id, {
      DateTime? seen,
      String? health,
      double? median,
      String status = 'active',
    }) => Pharmacy({
      'id': id,
      'name': id,
      'status': status,
      'last_heartbeat_at': seen?.toIso8601String(),
      'health': health,
      'median_minutes': median,
    });
    final rows = attentionFor(l, [
      p('fine', seen: now, median: 3),
      p('never'),
      p('gone', seen: now.subtract(const Duration(days: 3))),
      p('sick', seen: now, health: 'problem'),
      p('slow', seen: now, median: 20),
      p('stopped', status: 'stopped'),
    ], now: now);
    expect(rows.map((r) => r.$1.id), ['never', 'gone', 'sick', 'slow']);
    expect(rows[1].$2, 'ما اتصلت من 3 يوم');
  });
}
