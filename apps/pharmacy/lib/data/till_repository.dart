import 'package:doaya_core/doaya_core.dart';
import 'package:drift/drift.dart';

import 'database.dart';
import 'ledger_repository.dart';

class ShiftAlreadyOpen implements Exception {
  const ShiftAlreadyOpen(this.shiftId);
  final String shiftId;
}

/// Cash-drawer shifts (الصندوق): open with a float, cash in/out, close with a
/// count. The expected cash is derived from the employee's own sales,
/// payments and refunds on that device during the shift.
class TillRepository {
  TillRepository(this._db, {UuidV7? ids, DateTime Function()? clock})
    : _ids = ids ?? UuidV7(),
      _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final UuidV7 _ids;
  final DateTime Function() _clock;

  EventMeta _meta(Session s) => EventMeta(
    id: _ids.generate(),
    deviceId: s.deviceId,
    employeeId: s.employeeId,
    occurredAt: _clock().toUtc(),
  );

  Future<void> _insert(TillEvent e) => _db
      .into(_db.tillEvents)
      .insert(
        TillEventsCompanion.insert(
          id: e.id,
          type: e.type.wire,
          shiftId: e.shiftId,
          amountMinor: e.amountMinor,
          note: Value(e.note),
          deviceId: e.meta.deviceId,
          employeeId: e.meta.employeeId,
          occurredAt: e.meta.occurredAt,
        ),
      );

  static TillEvent fromRow(TillEventRow r) => TillEvent(
    meta: EventMeta(
      id: r.id,
      deviceId: r.deviceId,
      employeeId: r.employeeId,
      occurredAt: r.occurredAt,
    ),
    type: TillEventType.fromWire(r.type),
    shiftId: r.shiftId,
    amountMinor: r.amountMinor,
    note: r.note,
  );

  /// The open shift of this employee on this device, if any.
  Future<String?> openShiftId(Session s) async {
    final rows =
        await (_db.select(_db.tillEvents)
              ..where(
                (t) =>
                    t.deviceId.equals(s.deviceId) &
                    t.employeeId.equals(s.employeeId) &
                    t.type.isIn([TillEventType.opened.wire, TillEventType.closed.wire]),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.occurredAt), (t) => OrderingTerm.desc(t.id)]))
            .get();
    final closed = rows
        .where((r) => r.type == TillEventType.closed.wire)
        .map((r) => r.shiftId)
        .toSet();
    for (final r in rows) {
      if (r.type == TillEventType.opened.wire && !closed.contains(r.shiftId)) return r.shiftId;
    }
    return null;
  }

  Future<String> openShift(Session s, {required int floatMinor}) {
    return _db.transaction(() async {
      final existing = await openShiftId(s);
      if (existing != null) throw ShiftAlreadyOpen(existing);
      final m = _meta(s);
      await _insert(
        TillEvent(meta: m, type: TillEventType.opened, shiftId: m.id, amountMinor: floatMinor),
      );
      return m.id;
    });
  }

  Future<void> cashIn(Session s, String shiftId, int amountMinor, {String? note}) => _insert(
    TillEvent(
      meta: _meta(s),
      type: TillEventType.cashIn,
      shiftId: shiftId,
      amountMinor: amountMinor,
      note: note,
    ),
  );

  Future<void> cashOut(Session s, String shiftId, int amountMinor, {required String note}) =>
      _insert(
        TillEvent(
          meta: _meta(s),
          type: TillEventType.cashOut,
          shiftId: shiftId,
          amountMinor: amountMinor,
          note: note,
        ),
      );

  /// Closes the shift with the cash actually counted; returns the summary.
  Future<ShiftSummary> closeShift(Session s, String shiftId, {required int countedMinor}) async {
    await _insert(
      TillEvent(
        meta: _meta(s),
        type: TillEventType.closed,
        shiftId: shiftId,
        amountMinor: countedMinor,
      ),
    );
    return (await summary(shiftId))!;
  }

  /// Live or final reconciliation of one shift.
  Future<ShiftSummary?> summary(String shiftId) async {
    final events = (await (_db.select(
      _db.tillEvents,
    )..where((t) => t.shiftId.equals(shiftId))).get()).map(fromRow).toList();
    if (events.isEmpty) return null;
    final opened = events.firstWhere((e) => e.type == TillEventType.opened);
    final closed = events.where((e) => e.type == TillEventType.closed).firstOrNull;
    final movements = await _movements(
      employeeId: opened.meta.employeeId,
      deviceId: opened.meta.deviceId,
      from: opened.meta.occurredAt,
      to: closed?.meta.occurredAt ?? _clock().toUtc().add(const Duration(seconds: 1)),
    );
    return summarizeShift(events, movements);
  }

  /// Shifts opened in `[from, to)`, newest first (owner's view).
  Future<List<ShiftSummary>> shiftsBetween(DateTime from, DateTime to) async {
    final opened =
        await (_db.select(_db.tillEvents)
              ..where(
                (t) =>
                    t.type.equals(TillEventType.opened.wire) &
                    t.occurredAt.isBiggerOrEqualValue(from.toUtc()) &
                    t.occurredAt.isSmallerThanValue(to.toUtc()),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
            .get();
    return [for (final o in opened) (await summary(o.shiftId))!];
  }

  /// Re-emits whenever till events, sales, returns or payments change.
  Stream<void> watchChanges() => _db
      .tableUpdates(
        TableUpdateQuery.onAllTables([_db.tillEvents, _db.sales, _db.returns, _db.debtEvents]),
      )
      .map((_) {});

  Future<ShiftMovements> _movements({
    required String employeeId,
    required String deviceId,
    required DateTime from,
    required DateTime to,
  }) async {
    bool inShift(DateTime at) => !at.isBefore(from) && at.isBefore(to);
    final sales = await (_db.select(
      _db.sales,
    )..where((t) => t.employeeId.equals(employeeId) & t.deviceId.equals(deviceId))).get();
    final payments =
        await (_db.select(_db.debtEvents)..where(
              (t) =>
                  t.employeeId.equals(employeeId) &
                  t.deviceId.equals(deviceId) &
                  t.type.equals(DebtEventType.paymentReceived.wire),
            ))
            .get();
    final refunds =
        await (_db.select(_db.returns)..where(
              (t) =>
                  t.employeeId.equals(employeeId) &
                  t.deviceId.equals(deviceId) &
                  t.refund.equals(RefundMethod.cash.wire),
            ))
            .get();
    int sum<T>(Iterable<T> rows, int Function(T) amount) => rows.fold(0, (a, r) => a + amount(r));
    final shiftSales = sales.where((x) => inShift(x.occurredAt));
    return ShiftMovements(
      cashSales: sum(
        shiftSales.where((x) => x.payment == PaymentType.cash.wire),
        (x) => x.totalMinor,
      ),
      transferSales: sum(
        shiftSales.where((x) => x.payment == PaymentType.transfer.wire),
        (x) => x.totalMinor,
      ),
      debtPayments: sum(payments.where((x) => inShift(x.occurredAt)), (x) => x.amountMinor),
      cashRefunds: sum(refunds.where((x) => inShift(x.occurredAt)), (x) => x.totalMinor),
    );
  }
}
