import 'package:doaya_patient/data/reminders.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default times spread over waking hours', () {
    expect(defaultTimes(1).map(formatMinutes), ['09:00']);
    expect(defaultTimes(2).map(formatMinutes), ['08:00', '20:00']);
    expect(defaultTimes(3).map(formatMinutes), ['08:00', '14:00', '20:00']);
    expect(defaultTimes(4).map(formatMinutes), ['08:00', '12:40', '17:20', '22:00']);
    expect(defaultTimes(0), isEmpty);
  });

  test('a decision gives one reminder per item with times per day', () {
    final rs = remindersFromDecision('c1', {
      'items': [
        {
          'name': 'Amoxil',
          'quantity': 1,
          'instructions': 'كل 8 ساعات',
          'times_per_day': 3,
          'days': 7,
        },
        {'name': 'Panadol', 'quantity': 1, 'instructions': 'عند اللزوم'},
        {'name': 'Vit D', 'quantity': 1, 'instructions': 'بعد الغدا', 'times_per_day': 1},
      ],
    }, today: DateTime(2026, 9, 26, 15, 30));
    expect(rs.map((r) => (r.id, r.name, r.days)), [('c1:0', 'Amoxil', 7), ('c1:2', 'Vit D', null)]);
    expect(rs.first.start, DateTime(2026, 9, 26));
    expect(rs.first.instructions, 'كل 8 ساعات');
  });

  test('upcoming doses: from now, within the course, none when off', () {
    final r = Reminder(
      id: 'c1:0',
      consultationId: 'c1',
      name: 'Amoxil',
      instructions: 'كل 8 ساعات',
      times: defaultTimes(3),
      start: DateTime(2026, 9, 26),
      days: 2,
    );
    final doses = r.upcoming(DateTime(2026, 9, 26, 15, 30));
    // Today 20:00, then tomorrow's three; the course ends after 2 days.
    expect(doses, [
      DateTime(2026, 9, 26, 20),
      DateTime(2026, 9, 27, 8),
      DateTime(2026, 9, 27, 14),
      DateTime(2026, 9, 27, 20),
    ]);
    expect(r.finishedAt(DateTime(2026, 9, 28)), isTrue);
    expect(r.copyWith(enabled: false).upcoming(DateTime(2026, 9, 26)), isEmpty);

    final ongoing = Reminder(
      id: 'x',
      consultationId: 'c1',
      name: 'Vit D',
      instructions: '',
      times: const [540],
      start: DateTime(2026, 9, 26),
    );
    expect(ongoing.upcoming(DateTime(2026, 9, 26), limit: 5), hasLength(5));
    expect(ongoing.finishedAt(DateTime(2027)), isFalse);
  });

  test('the patient moves a time; saved and read back', () {
    final r = remindersFromDecision('c1', {
      'items': [
        {'name': 'Amoxil', 'quantity': 1, 'instructions': 'x', 'times_per_day': 2, 'days': 5},
      ],
    }, today: DateTime(2026, 9, 26)).single.copyWith(times: [21 * 60, 7 * 60 + 30]);
    expect(r.times.map(formatMinutes), ['07:30', '21:00']);
    final back = decodeReminders(encodeReminders([r])).single;
    expect(back.times, r.times);
    expect((back.days, back.start), (5, DateTime(2026, 9, 26)));
    expect(decodeReminders('garbage'), isEmpty);
  });
}
