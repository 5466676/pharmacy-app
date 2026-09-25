/// Device ⇄ server sync: the engine and the two interfaces it drives.
///
/// The server (backend/app/sync.py) keeps the latest version of every row;
/// devices push their local changes (an outbox) and pull everything after a
/// cursor. Ledgers are append-only and merge freely; master data is
/// last-writer-wins on (changedAt, deviceId).
library;

/// Tables whose rows never change once written. Must match the server.
const appendOnlyTables = {
  'stock_events',
  'sales',
  'sale_lines',
  'debt_events',
  'returns',
  'return_lines',
  'till_events',
  'purchases',
  'purchase_lines',
  'supplier_debt_events',
  'supplier_returns',
  'expense_events',
  'stocktake_counts',
};

/// Master data: edited in place, last writer wins, may be deleted.
const mutableTables = {
  'devices',
  'settings',
  'employees',
  'products',
  'product_barcodes',
  'customers',
  'suppliers',
  'stocktakes',
  'purchase_orders',
  'purchase_order_lines',
};

/// A local change waiting to be pushed.
class OutgoingChange {
  const OutgoingChange({
    required this.table,
    required this.id,
    required this.changedAt,
    this.data,
    this.deleted = false,
  });

  final String table;
  final String id;

  /// UTC time of the change (ISO-8601); decides last-writer-wins.
  final DateTime changedAt;

  /// The row as column → value; null when deleted.
  final Map<String, Object?>? data;
  final bool deleted;

  String get key => '$table:$id';

  Map<String, Object?> toJson() => {
    'table': table,
    'id': id,
    'changed_at': changedAt.toUtc().toIso8601String(),
    if (!deleted) 'data': data,
    'deleted': deleted,
  };
}

/// An outbox entry: the change plus the local outbox ids it covers.
class PendingChange {
  const PendingChange(this.change, this.outboxIds);
  final OutgoingChange change;
  final List<int> outboxIds;
}

/// A change made on another device.
class IncomingChange {
  const IncomingChange({
    required this.table,
    required this.id,
    required this.changedAt,
    required this.deviceId,
    required this.seq,
    this.data,
    this.deleted = false,
  });

  factory IncomingChange.fromJson(Map<String, Object?> j) => IncomingChange(
    table: j['table']! as String,
    id: j['id']! as String,
    data: (j['data'] as Map<String, Object?>?),
    deleted: j['deleted'] as bool? ?? false,
    changedAt: DateTime.parse(j['changed_at']! as String).toUtc(),
    deviceId: j['device_id']! as String,
    seq: j['seq']! as int,
  );

  final String table;
  final String id;
  final Map<String, Object?>? data;
  final bool deleted;
  final DateTime changedAt;
  final String deviceId;
  final int seq;
}

class PushResult {
  const PushResult({this.accepted = const {}, this.rejected = const {}, this.conflicts = const {}});

  factory PushResult.fromJson(Map<String, Object?> j) => PushResult(
    accepted: {...(j['accepted'] as List).cast<String>()},
    rejected: {
      for (final r in (j['rejected'] as List).cast<Map<String, Object?>>())
        '${r['table']}:${r['id']}',
    },
    conflicts: {...(j['conflicts'] as List).cast<String>()},
  );

  /// Keys (`table:id`) stored or superseded: done on the device.
  final Set<String> accepted;

  /// Keys the server can never take (unknown table, deleting a ledger row).
  final Set<String> rejected;

  /// Ledger keys that already existed with a different body.
  final Set<String> conflicts;
}

class PullPage {
  const PullPage({
    required this.changes,
    required this.cursor,
    required this.more,
    required this.latest,
  });

  factory PullPage.fromJson(Map<String, Object?> j) => PullPage(
    changes: [
      for (final c in (j['changes'] as List).cast<Map<String, Object?>>())
        IncomingChange.fromJson(c),
    ],
    cursor: j['cursor']! as int,
    more: j['more']! as bool,
    latest: j['latest']! as int,
  );

  final List<IncomingChange> changes;
  final int cursor;
  final bool more;
  final int latest;
}

/// Last-writer-wins order: does a change at ([aAt], [aDevice]) beat one at
/// ([bAt], [bDevice])? Later time wins; the device id breaks exact ties.
/// The same rule as the server.
bool newerThan(DateTime aAt, String aDevice, DateTime bAt, String bDevice) {
  final c = aAt.compareTo(bAt);
  return c != 0 ? c > 0 : aDevice.compareTo(bDevice) > 0;
}

/// Thrown by transports when the server can't be reached.
class SyncNetworkException implements Exception {
  const SyncNetworkException(this.message);
  final String message;
  @override
  String toString() => 'SyncNetworkException: $message';
}

/// The network side (HTTP in the app, in-memory in tests).
abstract interface class SyncTransport {
  Future<PushResult> push(List<OutgoingChange> changes);
  Future<PullPage> pull({required int after, required int limit});
}

/// The device side (drift in the app, in-memory in tests).
abstract interface class SyncStore {
  /// Up to [limit] local changes not yet pushed, oldest first, one per row.
  Future<List<PendingChange>> pending(int limit);

  /// Forgets outbox entries the server has handled.
  Future<void> acknowledge(Iterable<int> outboxIds);

  Future<int> cursor();

  /// Applies other devices' changes and saves [cursor], all or nothing.
  Future<void> apply(List<IncomingChange> changes, int cursor);
}

class SyncProgress {
  const SyncProgress({
    required this.pushed,
    required this.pulled,
    required this.cursor,
    required this.latest,
  });
  final int pushed;
  final int pulled;
  final int cursor;

  /// Newest change on the server; cursor/latest is the download progress.
  final int latest;
}

class SyncReport {
  const SyncReport({
    required this.pushed,
    required this.pulled,
    required this.rejected,
    required this.conflicts,
  });
  final int pushed;
  final int pulled;
  final int rejected;
  final int conflicts;
}

/// One sync run: push the whole outbox, then pull until up to date.
///
/// Safe to interrupt anywhere: outbox entries are only forgotten after the
/// server answered, and each pulled page is applied together with its
/// cursor. The next run carries on from there.
class SyncEngine {
  SyncEngine(this.store, this.transport, {this.pushBatch = 500, this.pullLimit = 500});

  final SyncStore store;
  final SyncTransport transport;
  final int pushBatch;
  final int pullLimit;

  Future<SyncReport> sync({void Function(SyncProgress)? onProgress}) async {
    var pushed = 0, pulled = 0, rejected = 0, conflicts = 0;
    var cursor = await store.cursor();

    while (true) {
      final batch = await store.pending(pushBatch);
      if (batch.isEmpty) break;
      final result = await transport.push([for (final p in batch) p.change]);
      final done = <int>[];
      for (final p in batch) {
        final k = p.change.key;
        if (result.accepted.contains(k) || result.rejected.contains(k)) {
          done.addAll(p.outboxIds);
        }
      }
      if (done.isEmpty) {
        throw StateError('server accepted none of ${batch.length} changes');
      }
      await store.acknowledge(done);
      pushed += batch.where((p) => result.accepted.contains(p.change.key)).length;
      rejected += batch.where((p) => result.rejected.contains(p.change.key)).length;
      conflicts += result.conflicts.length;
      onProgress?.call(
        SyncProgress(pushed: pushed, pulled: pulled, cursor: cursor, latest: cursor),
      );
    }

    while (true) {
      final page = await transport.pull(after: cursor, limit: pullLimit);
      await store.apply(page.changes, page.cursor);
      cursor = page.cursor;
      pulled += page.changes.length;
      onProgress?.call(
        SyncProgress(pushed: pushed, pulled: pulled, cursor: cursor, latest: page.latest),
      );
      if (!page.more) break;
    }
    return SyncReport(pushed: pushed, pulled: pulled, rejected: rejected, conflicts: conflicts);
  }
}
