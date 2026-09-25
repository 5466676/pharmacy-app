import 'events.dart';

/// Cash-drawer (الصندوق) events. Each employee opens a shift on a device
/// with a starting float and closes it by counting the cash. Append-only.
enum TillEventType {
  /// Shift opened; amount = starting float in the drawer.
  opened,

  /// Cash put into the drawer outside a sale (e.g. change added).
  cashIn,

  /// Cash taken out (expense, handed to the owner…); needs a note.
  cashOut,

  /// Shift closed; amount = cash actually counted.
  closed;

  String get wire => switch (this) {
    opened => 'opened',
    cashIn => 'cash_in',
    cashOut => 'cash_out',
    closed => 'closed',
  };

  static TillEventType fromWire(String s) =>
      values.firstWhere((t) => t.wire == s, orElse: () => throw FormatException('till: $s'));
}

class TillEvent {
  TillEvent({
    required this.meta,
    required this.type,
    required this.shiftId,
    required this.amountMinor,
    this.note,
  }) {
    if (amountMinor < 0) throw ArgumentError('amount must be >= 0');
    if (type == TillEventType.opened && shiftId != meta.id) {
      throw ArgumentError('opened starts the shift: shiftId == event id');
    }
    if ((type == TillEventType.cashIn || type == TillEventType.cashOut) && amountMinor == 0) {
      throw ArgumentError('cash in/out must be > 0');
    }
  }

  final EventMeta meta;
  final TillEventType type;

  /// The id of the `opened` event of this shift.
  final String shiftId;
  final int amountMinor;
  final String? note;

  String get id => meta.id;
}

/// Money movements that touched the drawer during a shift, in minor units.
class ShiftMovements {
  const ShiftMovements({
    this.cashSales = 0,
    this.debtPayments = 0,
    this.cashRefunds = 0,
    this.transferSales = 0,
    this.drawerPurchases = 0,
    this.drawerExpenses = 0,
    this.supplierCashRefunds = 0,
  });

  /// Totals of cash sales (after discount).
  final int cashSales;

  /// Debt payments received in cash.
  final int debtPayments;

  /// Cash paid back for returns.
  final int cashRefunds;

  /// Paid by transfer (Sham Cash…): NOT in the drawer, shown for reference.
  final int transferSales;

  /// Supplier invoices paid in cash out of the drawer.
  final int drawerPurchases;

  /// Expenses paid out of the drawer.
  final int drawerExpenses;

  /// Cash a supplier handed back for returned goods, put in the drawer.
  final int supplierCashRefunds;
}

/// A shift's reconciliation.
class ShiftSummary {
  ShiftSummary({
    required this.shiftId,
    required this.employeeId,
    required this.deviceId,
    required this.openedAt,
    required this.openingFloat,
    required this.movements,
    required this.cashIn,
    required this.cashOut,
    this.closedAt,
    this.counted,
  });

  final String shiftId;
  final String employeeId;
  final String deviceId;
  final DateTime openedAt;
  final DateTime? closedAt;
  final int openingFloat;
  final ShiftMovements movements;
  final int cashIn;
  final int cashOut;

  /// Cash counted at closing (null while open).
  final int? counted;

  bool get isOpen => closedAt == null;

  /// What should be in the drawer:
  /// float + cash sales + debt payments − cash refunds + cash in − cash out
  /// − purchases and expenses paid from the drawer + supplier cash refunds.
  int get expected =>
      openingFloat +
      movements.cashSales +
      movements.debtPayments -
      movements.cashRefunds +
      cashIn -
      cashOut -
      movements.drawerPurchases -
      movements.drawerExpenses +
      movements.supplierCashRefunds;

  /// counted − expected: negative = shortage (عجز), positive = surplus (زيادة).
  int? get difference => counted == null ? null : counted! - expected;
}

/// Builds the summary of one shift from its till events. [movements] are the
/// sales/payments/refunds by that employee on that device between opening and
/// closing (or now, while open).
ShiftSummary summarizeShift(List<TillEvent> shiftEvents, ShiftMovements movements) {
  final opened = shiftEvents.firstWhere(
    (e) => e.type == TillEventType.opened,
    orElse: () => throw ArgumentError('shift has no opened event'),
  );
  final closed = shiftEvents.where((e) => e.type == TillEventType.closed).firstOrNull;
  var cashIn = 0, cashOut = 0;
  for (final e in shiftEvents) {
    if (e.type == TillEventType.cashIn) cashIn += e.amountMinor;
    if (e.type == TillEventType.cashOut) cashOut += e.amountMinor;
  }
  return ShiftSummary(
    shiftId: opened.shiftId,
    employeeId: opened.meta.employeeId,
    deviceId: opened.meta.deviceId,
    openedAt: opened.meta.occurredAt,
    closedAt: closed?.meta.occurredAt,
    openingFloat: opened.amountMinor,
    movements: movements,
    cashIn: cashIn,
    cashOut: cashOut,
    counted: closed?.amountMinor,
  );
}

/// Change to give back: amount received − total. Null if nothing was entered;
/// throws if the customer paid less than the total.
int? changeDue({required int totalMinor, int? tenderedMinor}) {
  if (tenderedMinor == null) return null;
  if (tenderedMinor < totalMinor) throw ArgumentError('tendered < total');
  return tenderedMinor - totalMinor;
}
