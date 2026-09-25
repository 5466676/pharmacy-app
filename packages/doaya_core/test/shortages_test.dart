import 'package:doaya_core/doaya_core.dart';
import 'package:test/test.dart';

void main() {
  ShortageInput p(String id, int onHand, {int min = 0, int sold = 0, int pack = 1}) =>
      ShortageInput(
        productId: id,
        onHandPieces: onHand,
        minimumPieces: min,
        soldPiecesInWindow: sold,
        piecesPerPack: pack,
      );

  test('reasons, most urgent first; healthy products are left out', () {
    final list = findShortages([
      p('fast', 20, sold: 60), // 2/day → 10 days left < 14
      p('healthy', 100, min: 5, sold: 30), // 1/day → 100 days
      p('low', 3, min: 5),
      p('out', 0, min: 2),
      p('idle', 50), // not selling, no minimum
    ]);
    expect(list.map((s) => (s.productId, s.reason)), [
      ('out', ShortageReason.outOfStock),
      ('low', ShortageReason.belowMinimum),
      ('fast', ShortageReason.sellingFast),
    ]);
    expect(list.last.daysLeft, 10);
  });

  test('suggested quantity covers the pace and the minimum, in whole boxes', () {
    // 3/day for 14 days = 42 pieces, have 6 → 36 missing; boxes of 10 → 4.
    final s = findShortages([p('a', 6, min: 6, sold: 90, pack: 10)]).single;
    expect((s.reason, s.suggestedPacks), (ShortageReason.belowMinimum, 4));
    // Not selling: just get back above the minimum (min 5 → 6), have 0.
    expect(findShortages([p('b', 0, min: 5)]).single.suggestedPacks, 6);
    // Never less than one box.
    expect(findShortages([p('c', 0)]).single.suggestedPacks, 1);
  });

  test('negative stock and net returns are treated as zero', () {
    final s = findShortages([p('a', -2, sold: -3)]).single;
    expect((s.onHandPieces, s.daysLeft, s.suggestedPacks), (0, null, 1));
  });
}
