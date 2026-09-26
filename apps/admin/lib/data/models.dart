/// What the admin panel reads from Doaya online (backend/app/admin.py,
/// control.py, knowledge.py).
library;

typedef Json = Map<String, Object?>;

DateTime? _time(Object? v) => v is String ? DateTime.tryParse(v)?.toLocal() : null;
double? _num(Object? v) => v is num ? v.toDouble() : null;
int _int(Object? v) => v is num ? v.toInt() : 0;
List<Json> _list(Object? v) => [for (final e in (v as List?) ?? const []) e as Json];

class Overview {
  Overview(this.j);
  final Json j;

  Json get _ph => j['pharmacies']! as Json;
  Json get _status => _ph['by_status']! as Json;
  Json get _patients => j['patients']! as Json;
  Json get _today => j['today']! as Json;
  Json get _response => j['response']! as Json;

  int get days => _int(j['days']);
  int status(String s) => _int(_status[s]);
  int get connected => _int(_ph['connected']);
  int get newPharmacies => _int(_ph['new']);
  int get patients => _int(_patients['registered']);
  int get activePatients => _int(_patients['active']);
  int get newPatients => _int(_patients['new']);
  int get consultationsToday => _int(_today['consultations']);
  int get urgentToday => _int(_today['urgent']);
  int get urgentUnanswered => _int(_today['urgent_unanswered']);
  int get ordersToday => _int(_today['orders']);
  double? get median => _num(_response['median_minutes']);
  double? get p90 => _num(_response['p90_minutes']);
  int get answered => _int(_response['answered']);
  int get unanswered => _int(_response['unanswered']);
  int get targetMinutes => _int(_response['target_minutes']);
  List<DayResponse> get byDay => [
    for (final d in _list(_response['by_day']))
      DayResponse(DateTime.parse(d['day']! as String), _num(d['median']), _num(d['p90'])),
  ];
  int get reviewWaiting => _int(j['review_waiting']);
}

class DayResponse {
  const DayResponse(this.day, this.median, this.p90);
  final DateTime day;
  final double? median;
  final double? p90;
}

/// pending | active | suspended | stopped | removed.
class Pharmacy {
  Pharmacy(this.j);
  final Json j;

  String get id => j['id']! as String;
  String get name => j['name']! as String;
  String get status => j['status']! as String;
  String? get reason => j['status_reason'] as String?;
  String? get city => j['city'] as String?;
  String? get code => j['code'] as String?;
  bool get listed => j['listed'] == true;
  int get patients => _int(j['patients']);
  double? get median => _num(j['median_minutes']);
  DateTime? get lastHeartbeat => _time(j['last_heartbeat_at']);
  bool get connected => j['connected'] == true;
  int get licenceDays => _int(j['licence_days']);

  /// ok | warn | problem, from the last health check.
  String? get health => j['health'] as String?;
  bool get healthRequested => j['health_requested'] == true;

  // Detail only.
  String? get address => j['address'] as String?;
  String? get phone => j['phone'] as String?;
  String? get hours => j['hours'] as String?;
  int get activeKeys => _int(j['active_keys']);
  Json? get heartbeat => j['heartbeat'] as Json?;
  List<HealthCheck> get healthChecks => [
    for (final c in _list((j['health_report'] as Json?)?['checks']))
      HealthCheck(c['id']! as String, c['level']! as String, c['count'] as int?),
  ];
  DateTime? get healthAt => _time(j['health_at']);
  List<AdminActionRecord> get actions => [
    for (final a in _list(j['actions']))
      AdminActionRecord(
        a['action']! as String,
        a['reason'] as String?,
        a['by'] as String? ?? '',
        _time(a['at'])!,
      ),
  ];

  /// Shown once, right after adding the pharmacy or making a new key.
  String? get key => j['key'] as String?;
}

class HealthCheck {
  const HealthCheck(this.id, this.level, this.count);
  final String id;
  final String level;
  final int? count;
}

class AdminActionRecord {
  const AdminActionRecord(this.action, this.reason, this.by, this.at);
  final String action;
  final String? reason;
  final String by;
  final DateTime at;
}

class Performance {
  Performance(this.j);
  final Json j;

  String get month => j['month']! as String;
  int get targetMinutes => _int(j['target_minutes']);
  int get minCases => _int(j['min_cases']);
  List<PharmacyPerformance> get rows => [
    for (final r in _list(j['pharmacies'])) PharmacyPerformance(r),
  ];
}

class PharmacyPerformance {
  PharmacyPerformance(this.j);
  final Json j;

  int? get rank => j['rank'] as int?;
  String get name => j['name']! as String;
  String? get city => j['city'] as String?;
  int get cases => _int(j['cases']);
  int get answered => _int(j['answered']);
  int get unanswered => _int(j['unanswered']);
  double? get answeredShare => _num(j['answered_share']);
  double? get withinTarget => _num(j['within_target_share']);
  double? get median => _num(j['median_minutes']);
  double? get p90 => _num(j['p90_minutes']);
  int get urgent => _int(j['urgent']);
  int get urgentInTime => _int(j['urgent_in_time']);
  int get orders => _int(j['orders']);
  int get ordersPrepared => _int(j['orders_prepared']);
  int get ordersRejected => _int(j['orders_rejected']);

  /// gold | silver | null.
  String? get tier => j['tier'] as String?;
}

class ReviewItem {
  ReviewItem(this.j);
  final Json j;

  int get id => _int(j['id']);

  /// red_flag | guard_block | correction | patient_edit | llm_down.
  String get kind => j['kind']! as String;
  Json get detail => (j['detail'] as Json?) ?? const {};
  DateTime get at => _time(j['created_at'])!;
  bool get reviewed => j['reviewed'] == true;
  String? get note => j['review_note'] as String?;
  int? get age => j['age'] as int?;
  String? get sex => j['sex'] as String?;
  String? get pharmacy => j['pharmacy'] as String?;
  bool get urgent => j['urgent'] == true;
  String? get redFlag => j['red_flag'] as String?;

  // Detail only.
  List<ReviewMessage> get messages => [
    for (final m in _list(j['messages']))
      ReviewMessage(
        m['role']! as String,
        m['text']! as String,
        m['author'] as String?,
        m['photo'] == true,
        _time(m['at'])!,
      ),
  ];
  Json? get summary => j['summary'] as Json?;
}

class ReviewMessage {
  const ReviewMessage(this.role, this.text, this.author, this.photo, this.at);
  final String role;
  final String text;
  final String? author;
  final bool photo;
  final DateTime at;
}

class KnowledgeNote {
  KnowledgeNote(this.j);
  final Json j;

  String get id => j['id']! as String;
  String get title => j['title']! as String;
  String get text => j['text']! as String;
  List<String> get tags => [for (final t in (j['tags'] as List?) ?? const []) t as String];
  bool get enabled => j['enabled'] == true;
  int? get sourceLogId => j['source_log_id'] as int?;
  DateTime? get updatedAt => _time(j['updated_at']);
}

class AdminSettings {
  AdminSettings(this.j);
  final Json j;

  String get llmBaseUrl => j['llm_base_url']! as String;
  String get llmModel => j['llm_model']! as String;
  String get ambulance => j['emergency_ambulance']! as String;
  String get general => j['emergency_general']! as String;
  List<String> get corsOrigins => [
    for (final o in (j['cors_origins'] as List?) ?? const []) o as String,
  ];
  String get serverVersion => j['server_version']! as String;
}

// ─── The assistant (Phase 4b) ───────────────────────────────────────────────

class AssistantModel {
  AssistantModel(this.j);
  final Json j;

  /// lm_studio | ollama | hosted.
  String get provider => j['provider']! as String;
  String get baseUrl => j['base_url']! as String;
  String get model => j['model']! as String;
  int get timeout => _int(j['timeout_seconds']);
  bool get hasKey => j['has_key'] == true;

  /// panel | settings.
  String get source => j['source']! as String;
  DateTime? get updatedAt => _time(j['updated_at']);
  String? get updatedBy => j['updated_by'] as String?;
  Map<String, String> get providers => {
    for (final e in ((j['providers'] as Json?) ?? const {}).entries) e.key: e.value! as String,
  };
  int? get ms => j['ms'] as int?;
}

class AssistantStats {
  AssistantStats(this.j);
  final Json j;

  int get hours => _int(j['hours']);
  int get replies => _int(j['replies']);
  int get down => _int(j['down']);
  int get guardBlocks => _int(j['guard_blocks']);
  int get redFlagsRules => _int(j['red_flags_rules']);
  int get redFlagsModel => _int(j['red_flags_model']);
  int get doctorAdvice => _int(j['doctor_advice']);
  int? get medianMs => j['median_ms'] as int?;
  int? get slowestMs => j['slowest_ms'] as int?;
  DateTime? get lastDownAt => _time(j['last_down_at']);
}

class PromptSet {
  PromptSet(this.kind, this.j);
  final String kind;
  final Json j;

  int? get activeId => j['active_id'] as int?;
  String get text => j['text']! as String;
  String get defaultText => j['default']! as String;
  List<String> get locked => [for (final t in (j['locked'] as List?) ?? const []) t as String];
  List<PromptVersionView> get versions => [
    for (final v in _list(j['versions'])) PromptVersionView(v),
  ];
}

class PromptVersionView {
  PromptVersionView(this.j);
  final Json j;

  int get id => _int(j['id']);
  String get kind => j['kind']! as String;
  String get text => j['text']! as String;
  String? get note => j['note'] as String?;

  /// draft | active | retired.
  String get status => j['status']! as String;
  bool get ready => j['ready'] == true;
  TestResult? get test => j['test'] == null ? null : TestResult(j['test']! as Json);
  DateTime get createdAt => _time(j['created_at'])!;
}

class TestResult {
  TestResult(this.j);
  final Json j;

  bool get passed => j['passed'] == true;
  bool get summaryOk => j['summary_ok'] == true;
  int get missed => _int(j['missed']);
  int get falseAlarms => _int(j['false_alarms']);
  List<TestCase> get cases => [for (final c in _list(j['cases'])) TestCase(c)];
}

class TestCase {
  TestCase(this.j);
  final Json j;

  String get text => j['text']! as String;

  /// emergency | doctor | normal.
  String get expected => j['expected']! as String;
  String get got => j['got']! as String;
  String? get source => j['source'] as String?;
  bool get passed => j['passed'] == true;
  bool get guardBlocked => j['guard_blocked'] == true;
  bool get modelDown => j['model_down'] == true;
  bool get falseAlarm => j['false_alarm'] == true;
  String? get reply => j['reply'] as String?;
}

class SafetyExample {
  SafetyExample(this.j);
  final Json j;

  int get id => _int(j['id']);
  String get text => j['text']! as String;

  /// emergency | doctor | normal.
  String get label => j['label']! as String;
  String? get note => j['note'] as String?;
  bool get enabled => j['enabled'] == true;
}

class SandboxTurn {
  SandboxTurn(this.j);
  final Json j;

  /// reply | emergency | doctor | summary | fallback.
  String get kind => j['kind']! as String;
  String get text => j['text']! as String;
  List<String> get quickReplies => [
    for (final q in (j['quick_replies'] as List?) ?? const []) q as String,
  ];
  String? get redFlagSource => j['red_flag_source'] as String?;
  bool get guardBlocked => j['guard_blocked'] == true;
  Json? get summary => j['summary'] as Json?;
}

// ─── Patients and their files (Phase 5) ─────────────────────────────────────

class PatientRow {
  PatientRow(this.j);
  final Json j;

  String get id => j['id']! as String;
  String get name => j['name']! as String;
  String get phone => j['phone']! as String;
  int? get age => j['age'] as int?;
  String? get sex => j['sex'] as String?;
  String? get city => j['city'] as String?;
  String? get pharmacy => j['pharmacy'] as String?;
  int get cases => _int(j['cases']);
  bool get hasFile => j['has_file'] == true;
}

class PatientFileView {
  PatientFileView(this.j);
  final Json j;

  PatientRow get patient => PatientRow(j['patient']! as Json);
  bool get consented => j['consent_at'] != null;
  List<Json> get facts => _list(j['facts']);
  List<Json> get pastFacts => _list(j['past_facts']);
  List<Json> get proposals => _list(j['proposals']);
  List<Json> get history => _list(j['history']);
  List<Json> get orders => _list(j['orders']);
  List<({String by, DateTime at})> get opened => [
    for (final o in _list(j['opened'])) (by: o['by']! as String, at: _time(o['at'])!),
  ];
}
