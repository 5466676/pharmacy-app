import 'events.dart';
import 'purchases.dart';

// ─── Cost of goods & profit ──────────────────────────────────────────────────

/// What one batch cost in total, and how many pieces it held.
class BatchCost {
  const BatchCost({required this.totalMinor, required this.pieces});
  final int totalMinor;
  final int pieces;
}

/// Looks up batch costs (from purchase lines) to value stock movements.
/// Batches without a recorded cost (received before purchasing existed, or
/// adjusted in) are "unknown", never guessed.
class CostBook {
  CostBook(this._costs);

  final Map<String, BatchCost> _costs;

  bool knows(String batchId) => _costs.containsKey(batchId);

  /// Cost of [pieces] from [batchId], or null when unknown.
  int? costOf(String batchId, int pieces) {
    final c = _costs[batchId];
    if (c == null || c.pieces == 0) return null;
    return (c.totalMinor * pieces / c.pieces).round();
  }
}

/// Profit of a set of movements (e.g. one sale, one day).
class ProfitSummary {
  const ProfitSummary({
    required this.revenueMinor,
    required this.costMinor,
    required this.unknownCostPieces,
  });

  final int revenueMinor;

  /// Cost of the pieces whose cost is known.
  final int costMinor;

  /// Pieces sold whose cost is unknown (profit is incomplete when > 0).
  final int unknownCostPieces;

  int get profitMinor => revenueMinor - costMinor;
  bool get complete => unknownCostPieces == 0;

  /// Margin in basis points of revenue (1500 = 15%), null without revenue.
  int? get marginBasisPoints =>
      revenueMinor == 0 ? null : (profitMinor * 10000 / revenueMinor).round();

  ProfitSummary operator +(ProfitSummary o) => ProfitSummary(
    revenueMinor: revenueMinor + o.revenueMinor,
    costMinor: costMinor + o.costMinor,
    unknownCostPieces: unknownCostPieces + o.unknownCostPieces,
  );

  static const zero = ProfitSummary(revenueMinor: 0, costMinor: 0, unknownCostPieces: 0);
}

/// Profit for [revenueMinor] earned by [stockEvents] (a sale's `sold`
/// events, and optionally its `returned` events, which give cost back).
ProfitSummary profitOf({
  required int revenueMinor,
  required Iterable<StockEvent> stockEvents,
  required CostBook costs,
}) {
  var cost = 0, unknown = 0;
  for (final e in stockEvents) {
    if (e.type != StockEventType.sold && e.type != StockEventType.returned) continue;
    final pieces = -e.quantity; // sold: +pieces out; returned: −pieces back
    final c = costs.costOf(e.batchId, pieces.abs());
    if (c == null) {
      unknown += pieces;
    } else {
      cost += pieces.sign * c;
    }
  }
  return ProfitSummary(revenueMinor: revenueMinor, costMinor: cost, unknownCostPieces: unknown);
}

// ─── Stocktake ───────────────────────────────────────────────────────────────

/// One product counted during a stocktake session.
class StocktakeCount {
  const StocktakeCount({
    required this.productId,
    required this.countedPieces,
    required this.systemPiecesAtCount,
  });

  final String productId;
  final int countedPieces;

  /// What the system said at the moment of counting. Sales that happen after
  /// the count don't change the difference, so the shop never stops selling.
  final int systemPiecesAtCount;

  int get difference => countedPieces - systemPiecesAtCount;
}

/// Adjustments a stocktake produces: product → pieces (non-zero only). The
/// last count of a product wins.
Map<String, int> stocktakeAdjustments(Iterable<StocktakeCount> counts) {
  final last = <String, StocktakeCount>{};
  for (final c in counts) {
    last[c.productId] = c;
  }
  return {
    for (final c in last.values)
      if (c.difference != 0) c.productId: c.difference,
  };
}

// ─── Expenses & P&L ──────────────────────────────────────────────────────────

class ExpenseEvent {
  ExpenseEvent({
    required this.meta,
    required this.category,
    required this.amountMinor,
    required this.currencyCode,
    required this.paidFrom,
    this.note,
  }) {
    if (amountMinor <= 0) throw ArgumentError('amount must be > 0');
    if (category.trim().isEmpty) throw ArgumentError('category required');
  }

  final EventMeta meta;

  /// e.g. `rent`, `salaries`, `electricity`, `generator`, `internet`, or a
  /// custom name typed by the owner.
  final String category;
  final int amountMinor;
  final String currencyCode;
  final PaidFrom paidFrom;
  final String? note;

  String get id => meta.id;
}

/// Monthly (or any period) profit and loss.
class ProfitAndLoss {
  const ProfitAndLoss({
    required this.salesMinor,
    required this.refundsMinor,
    required this.costOfGoodsMinor,
    required this.expensesByCategory,
    required this.unknownCostPieces,
  });

  final int salesMinor;
  final int refundsMinor;
  final int costOfGoodsMinor;
  final Map<String, int> expensesByCategory;
  final int unknownCostPieces;

  int get netSalesMinor => salesMinor - refundsMinor;
  int get grossProfitMinor => netSalesMinor - costOfGoodsMinor;
  int get expensesMinor => expensesByCategory.values.fold(0, (a, b) => a + b);
  int get netProfitMinor => grossProfitMinor - expensesMinor;
}

ProfitAndLoss profitAndLoss({
  required int salesMinor,
  required int refundsMinor,
  required ProfitSummary goods,
  required Iterable<ExpenseEvent> expenses,
}) {
  final byCategory = <String, int>{};
  for (final e in expenses) {
    byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amountMinor;
  }
  return ProfitAndLoss(
    salesMinor: salesMinor,
    refundsMinor: refundsMinor,
    costOfGoodsMinor: goods.costMinor,
    expensesByCategory: byCategory,
    unknownCostPieces: goods.unknownCostPieces,
  );
}
