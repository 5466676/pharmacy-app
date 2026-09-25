/// Why a product is on the shortage list (النواقص).
enum ShortageReason {
  /// Nothing left.
  outOfStock,

  /// At or under the minimum the owner set.
  belowMinimum,

  /// Enough today, but at the current pace it runs out within the cover period.
  sellingFast,
}

/// What we know about one product to decide whether to reorder it.
class ShortageInput {
  const ShortageInput({
    required this.productId,
    required this.onHandPieces,
    required this.minimumPieces,
    required this.soldPiecesInWindow,
    this.piecesPerPack = 1,
  });

  final String productId;
  final int onHandPieces;

  /// Low-stock threshold, in pieces (0 = none set).
  final int minimumPieces;

  /// Net pieces sold (sold − returned) during the sales window.
  final int soldPiecesInWindow;

  /// Suppliers sell whole boxes: suggestions are rounded up to this.
  final int piecesPerPack;
}

class Shortage {
  const Shortage({
    required this.productId,
    required this.reason,
    required this.onHandPieces,
    required this.suggestedPacks,
    this.daysLeft,
  });

  final String productId;
  final ShortageReason reason;
  final int onHandPieces;

  /// Boxes to order: enough to cover the cover period at the current pace
  /// and to get back above the minimum. At least 1.
  final int suggestedPacks;

  /// Days until it runs out at the current pace (null when it isn't selling).
  final int? daysLeft;
}

/// The shortage list, most urgent first: out of stock, then under the
/// minimum, then selling fast; within each, the soonest to run out first.
///
/// [windowDays] is how far back sales are counted; [coverDays] is how long
/// an order should last.
List<Shortage> findShortages(
  Iterable<ShortageInput> inputs, {
  int windowDays = 30,
  int coverDays = 14,
}) {
  final out = <Shortage>[];
  for (final i in inputs) {
    final sold = i.soldPiecesInWindow < 0 ? 0 : i.soldPiecesInWindow;
    final perDay = sold / windowDays;
    final onHand = i.onHandPieces < 0 ? 0 : i.onHandPieces;
    final int? daysLeft = perDay == 0 ? null : (onHand / perDay).floor();

    final ShortageReason reason;
    if (onHand == 0) {
      reason = ShortageReason.outOfStock;
    } else if (i.minimumPieces > 0 && onHand <= i.minimumPieces) {
      reason = ShortageReason.belowMinimum;
    } else if (daysLeft != null && daysLeft < coverDays) {
      reason = ShortageReason.sellingFast;
    } else {
      continue;
    }

    // Target: cover the period at the current pace, and stay above the minimum.
    final forPace = (perDay * coverDays).ceil();
    final forMinimum = i.minimumPieces + 1;
    final target = forPace > forMinimum ? forPace : forMinimum;
    final missing = target - onHand;
    final pack = i.piecesPerPack < 1 ? 1 : i.piecesPerPack;
    final packs = missing <= 0 ? 1 : (missing / pack).ceil();
    out.add(
      Shortage(
        productId: i.productId,
        reason: reason,
        onHandPieces: onHand,
        suggestedPacks: packs < 1 ? 1 : packs,
        daysLeft: daysLeft,
      ),
    );
  }
  out.sort((a, b) {
    final r = a.reason.index.compareTo(b.reason.index);
    if (r != 0) return r;
    return (a.daysLeft ?? 1 << 30).compareTo(b.daysLeft ?? 1 << 30);
  });
  return out;
}
