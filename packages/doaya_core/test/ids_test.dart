import 'dart:math';

import 'package:doaya_core/doaya_core.dart';
import 'package:test/test.dart';

void main() {
  test('generates valid RFC 9562 v7 ids', () {
    final g = UuidV7();
    for (var i = 0; i < 1000; i++) {
      expect(UuidV7.isValid(g.generate()), isTrue);
    }
  });

  test('encodes the timestamp', () {
    final at = DateTime.utc(2026, 9, 25, 12, 30, 1, 234);
    final id = UuidV7(clock: () => at).generate();
    expect(UuidV7.timestampOf(id), at);
  });

  test('ids from one generator strictly increase, even within one millisecond', () {
    final at = DateTime.utc(2026);
    final g = UuidV7(clock: () => at, random: Random(1));
    final list = [for (var i = 0; i < 5000; i++) g.generate()];
    for (var i = 1; i < list.length; i++) {
      expect(list[i].compareTo(list[i - 1]), greaterThan(0), reason: 'index $i');
    }
    expect(list.toSet().length, list.length);
  });

  test('later clock sorts later across generators', () {
    final a = UuidV7(clock: () => DateTime.utc(2026, 1, 1)).generate();
    final b = UuidV7(clock: () => DateTime.utc(2026, 1, 2)).generate();
    expect(b.compareTo(a), greaterThan(0));
  });

  test('clock going backwards does not break ordering', () {
    var now = DateTime.utc(2026, 1, 2);
    final g = UuidV7(clock: () => now);
    final first = g.generate();
    now = DateTime.utc(2026, 1, 1);
    expect(g.generate().compareTo(first), greaterThan(0));
  });
}
