import 'dart:convert';

/// A dose reminder built from the pharmacist's decision: the medicine, the
/// pharmacist's own instructions (shown in every notification), and when.
/// The times come from the pharmacist's «times per day»; the patient may
/// move them, never add doses the pharmacist didn't give.
class Reminder {
  const Reminder({
    required this.id,
    required this.consultationId,
    required this.name,
    required this.instructions,
    required this.times,
    required this.start,
    this.days,
    this.enabled = true,
  });

  factory Reminder.fromJson(Map<String, Object?> j) => Reminder(
    id: j['id']! as String,
    consultationId: j['consultation_id']! as String,
    name: j['name']! as String,
    instructions: j['instructions']! as String,
    times: [for (final t in j['times']! as List) t as int],
    start: DateTime.parse(j['start']! as String),
    days: j['days'] as int?,
    enabled: j['enabled'] as bool? ?? true,
  );

  final String id;
  final String consultationId;
  final String name;
  final String instructions;

  /// Minutes after midnight, sorted.
  final List<int> times;

  /// The first day (local, at midnight).
  final DateTime start;

  /// How many days; null: until the patient turns it off.
  final int? days;
  final bool enabled;

  DateTime? get end => days == null ? null : start.add(Duration(days: days!));

  Map<String, Object?> toJson() => {
    'id': id,
    'consultation_id': consultationId,
    'name': name,
    'instructions': instructions,
    'times': times,
    'start': start.toIso8601String(),
    'days': days,
    'enabled': enabled,
  };

  Reminder copyWith({List<int>? times, bool? enabled}) => Reminder(
    id: id,
    consultationId: consultationId,
    name: name,
    instructions: instructions,
    times: times == null ? this.times : ([...times]..sort()),
    start: start,
    days: days,
    enabled: enabled ?? this.enabled,
  );

  /// The doses from [from] on, in order, at most [limit].
  List<DateTime> upcoming(DateTime from, {int limit = 64}) {
    final out = <DateTime>[];
    if (!enabled || times.isEmpty) return out;
    var day = DateTime(from.year, from.month, from.day);
    if (day.isBefore(start)) day = start;
    final last = end;
    while (out.length < limit && (last == null || day.isBefore(last))) {
      for (final m in times) {
        final at = DateTime(day.year, day.month, day.day, m ~/ 60, m % 60);
        if (!at.isBefore(from) && out.length < limit) out.add(at);
      }
      day = DateTime(day.year, day.month, day.day + 1);
    }
    return out;
  }

  bool finishedAt(DateTime now) => end != null && !now.isBefore(end!);
}

/// Waking hours the default times are spread over: 8:00 to 22:00.
const _firstDose = 8 * 60;
const _lastDose = 22 * 60;

/// Default dose times for [perDay] doses a day, spread over waking hours
/// (1: 9:00; 2: 8:00 and 20:00; 3: 8:00, 14:00, 20:00…).
List<int> defaultTimes(int perDay) {
  if (perDay <= 0) return const [];
  if (perDay == 1) return const [9 * 60];
  if (perDay <= 3) {
    // Even gaps of 12 h / 6 h from 8:00, the way pharmacists say them.
    final gap = perDay == 2 ? 12 * 60 : 6 * 60;
    return [for (var i = 0; i < perDay; i++) _firstDose + i * gap];
  }
  const span = _lastDose - _firstDose;
  return [for (var i = 0; i < perDay; i++) _firstDose + (span * i / (perDay - 1)).round()];
}

/// The reminders a decision offers: one per item with times per day.
List<Reminder> remindersFromDecision(
  String consultationId,
  Map<String, Object?> decision, {
  required DateTime today,
}) {
  final items = (decision['items'] as List? ?? const []).cast<Map<String, Object?>>();
  final start = DateTime(today.year, today.month, today.day);
  return [
    for (final (i, item) in items.indexed)
      if (item['times_per_day'] case final int perDay when perDay > 0)
        Reminder(
          id: '$consultationId:$i',
          consultationId: consultationId,
          name: item['name']! as String,
          instructions: item['instructions']! as String,
          times: defaultTimes(perDay),
          start: start,
          days: item['days'] as int?,
        ),
  ];
}

String encodeReminders(Iterable<Reminder> rs) => jsonEncode([for (final r in rs) r.toJson()]);

List<Reminder> decodeReminders(String? s) {
  if (s == null) return [];
  try {
    return [for (final j in jsonDecode(s) as List) Reminder.fromJson(j as Map<String, Object?>)];
  } on Object {
    return [];
  }
}

/// "08:00" from minutes after midnight.
String formatMinutes(int m) =>
    '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
