import 'events.dart';

/// Current state of one batch, derived from events.
class BatchStock {
  BatchStock({required this.batchId, required this.productId, this.expiry, this.receivedAt});

  final String batchId;
  final String productId;
  final DateTime? expiry;
  final DateTime? receivedAt;
  int quantity = 0;
}

/// A slice of a sale taken from one batch.
class Allocation {
  const Allocation(this.batchId, this.quantity);

  final String batchId;

  /// Positive number of units taken.
  final int quantity;

  @override
  bool operator ==(Object other) =>
      other is Allocation && other.batchId == batchId && other.quantity == quantity;

  @override
  int get hashCode => Object.hash(batchId, quantity);

  @override
  String toString() => 'Allocation($batchId, $quantity)';
}

class InsufficientStock implements Exception {
  const InsufficientStock(this.productId, this.requested, this.available);

  final String productId;
  final int requested;
  final int available;

  @override
  String toString() => 'InsufficientStock($productId: wanted $requested, have $available)';
}

/// Stock derived from an append-only list of [StockEvent]s.
///
/// Folding is order-independent (sums), so events from several devices merge
/// without conflicts; duplicates (same id) are ignored, so re-sync is harmless.
class StockLedger {
  StockLedger([Iterable<StockEvent> events = const []]) {
    events.forEach(apply);
  }

  final _seen = <String>{};
  final _batches = <String, BatchStock>{};

  /// Folds one event in. Returns false if it was already applied.
  bool apply(StockEvent e) {
    if (!_seen.add(e.id)) return false;
    final batch = _batches.putIfAbsent(
      e.batchId,
      () => BatchStock(batchId: e.batchId, productId: e.productId),
    );
    if (e.type == StockEventType.received) {
      // A movement may arrive before its `received` (sync order); fill in.
      final opened = BatchStock(
        batchId: e.batchId,
        productId: e.productId,
        expiry: e.expiry,
        receivedAt: e.meta.occurredAt,
      )..quantity = batch.quantity;
      _batches[e.batchId] = opened;
      opened.quantity += e.quantity;
    } else {
      batch.quantity += e.quantity;
    }
    return true;
  }

  int get eventCount => _seen.length;

  Iterable<BatchStock> batchesOf(String productId) =>
      _batches.values.where((b) => b.productId == productId);

  int onHand(String productId) => batchesOf(productId).fold(0, (sum, b) => sum + b.quantity);

  Map<String, int> onHandByProduct() {
    final out = <String, int>{};
    for (final b in _batches.values) {
      out[b.productId] = (out[b.productId] ?? 0) + b.quantity;
    }
    return out;
  }

  /// Batches with positive stock in first-expiring-first-out order.
  /// Batches without expiry come last; ties break by receive time, then id.
  List<BatchStock> fefo(String productId) {
    final list = batchesOf(productId).where((b) => b.quantity > 0).toList()..sort(_fefoOrder);
    return list;
  }

  static int _fefoOrder(BatchStock a, BatchStock b) {
    final ea = a.expiry, eb = b.expiry;
    if (ea != null && eb != null) {
      final c = ea.compareTo(eb);
      if (c != 0) return c;
    } else if (ea != null) {
      return -1;
    } else if (eb != null) {
      return 1;
    }
    final ra = a.receivedAt, rb = b.receivedAt;
    if (ra != null && rb != null) {
      final c = ra.compareTo(rb);
      if (c != 0) return c;
    }
    return a.batchId.compareTo(b.batchId);
  }

  /// Splits [quantity] units across batches, earliest expiry first.
  ///
  /// If batches can't cover it but the product's total on-hand can (e.g. an
  /// unbatched adjustment made stock positive), the remainder is taken from
  /// the last batch touched. Throws [InsufficientStock] otherwise.
  List<Allocation> allocate(String productId, int quantity) {
    if (quantity <= 0) throw ArgumentError('quantity must be > 0');
    final available = onHand(productId);
    if (available < quantity) throw InsufficientStock(productId, quantity, available);

    final out = <Allocation>[];
    var left = quantity;
    for (final b in fefo(productId)) {
      if (left == 0) break;
      final take = b.quantity < left ? b.quantity : left;
      out.add(Allocation(b.batchId, take));
      left -= take;
    }
    if (left > 0) {
      // Stock exists outside positive batches (negative corrections elsewhere).
      final fallback = out.isNotEmpty ? out.removeLast() : null;
      final batchId = fallback?.batchId ?? batchesOf(productId).first.batchId;
      out.add(Allocation(batchId, (fallback?.quantity ?? 0) + left));
    }
    return out;
  }

  /// Positive-stock batches expiring on or before [now] + [window].
  List<BatchStock> nearExpiry(DateTime now, Duration window, {String? productId}) {
    final limit = now.add(window);
    return _batches.values
        .where(
          (b) =>
              b.quantity > 0 &&
              b.expiry != null &&
              !b.expiry!.isAfter(limit) &&
              (productId == null || b.productId == productId),
        )
        .toList()
      ..sort(_fefoOrder);
  }

  /// Positive-stock batches already past expiry at [now].
  List<BatchStock> expired(DateTime now) =>
      nearExpiry(now, Duration.zero).where((b) => b.expiry!.isBefore(now)).toList();

  /// Products whose on-hand is at or below their threshold.
  /// [thresholds] maps product id → low-stock threshold.
  Map<String, int> lowStock(Map<String, int> thresholds) {
    final onHandMap = onHandByProduct();
    return {
      for (final MapEntry(key: id, value: t) in thresholds.entries)
        if ((onHandMap[id] ?? 0) <= t) id: onHandMap[id] ?? 0,
    };
  }
}

/// Customer balances derived from [DebtEvent]s. Idempotent like [StockLedger].
class DebtLedger {
  DebtLedger([Iterable<DebtEvent> events = const []]) {
    events.forEach(apply);
  }

  final _seen = <String>{};
  final _balances = <String, int>{};

  bool apply(DebtEvent e) {
    if (!_seen.add(e.id)) return false;
    _balances[e.customerId] = (_balances[e.customerId] ?? 0) + e.signedMinor;
    return true;
  }

  /// What [customerId] owes, in minor units (negative = credit).
  int balance(String customerId) => _balances[customerId] ?? 0;

  /// Customers who owe something, largest first.
  List<MapEntry<String, int>> openDebts() =>
      _balances.entries.where((e) => e.value > 0).toList()
        ..sort((a, b) => b.value.compareTo(a.value));

  int get totalOpen => openDebts().fold(0, (s, e) => s + e.value);
}
