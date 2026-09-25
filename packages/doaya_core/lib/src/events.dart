/// Ledger event models. Events are append-only facts: never edited, never
/// deleted. Current state (stock, balances) is always derived from them.
library;

/// Who/where/when for every event. Required for multi-device sync.
class EventMeta {
  const EventMeta({
    required this.id,
    required this.deviceId,
    required this.employeeId,
    required this.occurredAt,
  });

  /// UUIDv7.
  final String id;
  final String deviceId;
  final String employeeId;

  /// Device-local wall clock at the time of the event.
  final DateTime occurredAt;
}

enum StockEventType {
  /// New stock arrives. Opens a batch whose id is this event's id.
  received,

  /// Sold at the counter (negative quantity).
  sold,

  /// Customer brought it back (positive quantity).
  returned,

  /// Manual correction after a count (either sign).
  adjusted,

  /// Removed because it expired (negative quantity).
  expiredRemoved;

  /// Storage name (snake_case, matches the spec).
  String get wire => switch (this) {
    received => 'received',
    sold => 'sold',
    returned => 'returned',
    adjusted => 'adjusted',
    expiredRemoved => 'expired_removed',
  };

  static StockEventType fromWire(String s) =>
      values.firstWhere((t) => t.wire == s, orElse: () => throw FormatException('type: $s'));
}

class StockEvent {
  StockEvent({
    required this.meta,
    required this.type,
    required this.productId,
    required this.batchId,
    required this.quantity,
    this.expiry,
    this.unitCostMinor,
    this.saleId,
    this.note,
  }) {
    _validate();
  }

  final EventMeta meta;
  final StockEventType type;
  final String productId;

  /// The batch this movement touches. For [StockEventType.received] this must
  /// equal `meta.id` (the event opens the batch).
  final String batchId;

  /// Signed change in whole units.
  final int quantity;

  /// Only on `received`: optional expiry date of the batch.
  final DateTime? expiry;

  /// Only on `received`: purchase cost per unit, in minor units.
  final int? unitCostMinor;
  final String? saleId;
  final String? note;

  String get id => meta.id;

  void _validate() {
    switch (type) {
      case StockEventType.received:
        if (quantity <= 0) throw ArgumentError('received quantity must be > 0');
        if (batchId != meta.id) throw ArgumentError('received opens batch == event id');
      case StockEventType.sold || StockEventType.expiredRemoved:
        if (quantity >= 0) throw ArgumentError('${type.wire} quantity must be < 0');
      case StockEventType.returned:
        if (quantity <= 0) throw ArgumentError('returned quantity must be > 0');
      case StockEventType.adjusted:
        if (quantity == 0) throw ArgumentError('adjusted quantity must be != 0');
    }
    if (type != StockEventType.received && (expiry != null || unitCostMinor != null)) {
      throw ArgumentError('expiry/cost only on received');
    }
  }
}

enum DebtEventType {
  debtAdded,
  paymentReceived;

  String get wire => switch (this) {
    debtAdded => 'debt_added',
    paymentReceived => 'payment_received',
  };

  static DebtEventType fromWire(String s) =>
      values.firstWhere((t) => t.wire == s, orElse: () => throw FormatException('type: $s'));
}

class DebtEvent {
  DebtEvent({
    required this.meta,
    required this.type,
    required this.customerId,
    required this.amountMinor,
    required this.currencyCode,
    this.saleId,
    this.note,
  }) {
    if (amountMinor <= 0) throw ArgumentError('amount must be > 0');
  }

  final EventMeta meta;
  final DebtEventType type;
  final String customerId;

  /// Always positive; the type gives the direction.
  final int amountMinor;
  final String currencyCode;
  final String? saleId;
  final String? note;

  String get id => meta.id;

  /// Effect on what the customer owes.
  int get signedMinor => type == DebtEventType.debtAdded ? amountMinor : -amountMinor;
}
