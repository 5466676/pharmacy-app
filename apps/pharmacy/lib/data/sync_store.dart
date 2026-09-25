import 'package:doaya_core/doaya_core.dart';
import 'package:drift/drift.dart';

import 'database.dart';

/// The device side of sync on the local SQLite database.
///
/// Outgoing: `sync_outbox` (filled by triggers) → the current row, read
/// generically as column → value. Incoming: rows written back the same way,
/// with the triggers paused so they aren't sent back.
class DriftSyncStore implements SyncStore {
  DriftSyncStore(this._db, {required this.deviceId});

  final AppDatabase _db;
  final String deviceId;

  /// Columns that describe this device only and never leave it.
  static const _localColumns = {
    '*': {'synced_at'},
    'devices': {'is_this_device'},
  };

  /// Parents before children, so a first upload arrives in a sensible order.
  static const uploadOrder = [
    'settings',
    'devices',
    'employees',
    'products',
    'product_barcodes',
    'customers',
    'suppliers',
    'stocktakes',
    'purchase_orders',
    'purchase_order_lines',
    'sales',
    'sale_lines',
    'stock_events',
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
  ];

  final _columns = <String, Set<String>>{};

  static bool _synced(String t) => appendOnlyTables.contains(t) || mutableTables.contains(t);
  static String _key(String t) => AppDatabase.syncKeys[t] ?? 'id';

  Future<Set<String>> _cols(String table) async => _columns[table] ??= {
    for (final r in await _db.customSelect('PRAGMA table_info("$table")').get())
      r.read<String>('name'),
  };

  Map<String, Object?> _outgoing(String table, Map<String, Object?> row) {
    final skip = {..._localColumns['*']!, ...?_localColumns[table]};
    return {
      for (final e in row.entries)
        if (!skip.contains(e.key)) e.key: e.value,
    };
  }

  // ─── Outgoing ─────────────────────────────────────────────────────────────

  @override
  Future<List<PendingChange>> pending(int limit) async {
    final entries =
        await (_db.select(_db.syncOutbox)
              ..orderBy([(t) => OrderingTerm.asc(t.id)])
              ..limit(limit * 4))
            .get();
    // One change per row: its latest entry, at its first position.
    final order = <String>[];
    final byKey = <String, List<SyncOutboxRow>>{};
    for (final e in entries) {
      final k = '${e.targetTable}:${e.recordId}';
      if (!byKey.containsKey(k)) order.add(k);
      (byKey[k] ??= []).add(e);
    }
    final out = <PendingChange>[];
    for (final k in order.take(limit)) {
      final list = byKey[k]!;
      final last = list.last;
      final t = last.targetTable;
      Map<String, Object?>? data;
      if (_synced(t) && !last.deleted) {
        final row = await _db
            .customSelect(
              'SELECT * FROM "$t" WHERE "${_key(t)}" = ?',
              variables: [Variable.withString(last.recordId)],
            )
            .getSingleOrNull();
        if (row != null) data = _outgoing(t, row.data);
      }
      out.add(
        PendingChange(
          OutgoingChange(
            table: t,
            id: last.recordId,
            changedAt: DateTime.parse(last.changedAt).toUtc(),
            data: data,
            deleted: data == null,
          ),
          [for (final e in list) e.id],
        ),
      );
    }
    return out;
  }

  @override
  Future<void> acknowledge(Iterable<int> outboxIds) async {
    final ids = outboxIds.toList();
    for (var i = 0; i < ids.length; i += 500) {
      final chunk = ids.sublist(i, i + 500 > ids.length ? ids.length : i + 500);
      await (_db.delete(_db.syncOutbox)..where((t) => t.id.isIn(chunk))).go();
    }
  }

  /// Queues every existing row, for the first upload of a device that
  /// already has history (the counter PC creating the pharmacy on its
  /// server). Master rows keep their own edit time; rows without one use
  /// the epoch so they never override newer edits already on a server.
  Future<void> seedOutbox() async {
    await _db.transaction(() async {
      await _db.delete(_db.syncOutbox).go();
      for (final t in uploadOrder) {
        final cols = await _cols(t);
        final parts = [
          if (cols.contains('updated_at')) 'updated_at',
          if (cols.contains('occurred_at')) 'occurred_at',
          "'1970-01-01T00:00:00.000Z'",
        ];
        final at = parts.length == 1 ? parts.single : 'COALESCE(${parts.join(', ')})';
        await _db.customStatement(
          'INSERT INTO sync_outbox (table_name, row_id, deleted, changed_at) '
          "SELECT '$t', \"${_key(t)}\", 0, $at FROM \"$t\"",
        );
      }
    });
  }

  Future<int> outboxCount() async {
    final c = _db.syncOutbox.id.count();
    return (await (_db.selectOnly(_db.syncOutbox)..addColumns([c])).getSingle()).read(c) ?? 0;
  }

  // ─── Incoming ─────────────────────────────────────────────────────────────

  @override
  Future<int> cursor() async => int.tryParse(await getState('cursor') ?? '') ?? 0;

  Future<String?> getState(String key) async => (await (_db.select(
    _db.syncState,
  )..where((t) => t.key.equals(key))).getSingleOrNull())?.value;

  Future<void> setState(String key, String? value) async {
    if (value == null) {
      await (_db.delete(_db.syncState)..where((t) => t.key.equals(key))).go();
    } else {
      await _db
          .into(_db.syncState)
          .insertOnConflictUpdate(SyncStateCompanion.insert(key: key, value: value));
    }
  }

  @override
  Future<void> apply(List<IncomingChange> changes, int cursor) async {
    final touched = <String>{};
    // Rows can arrive before their parent (an edited parent gets a newer
    // sequence number than its older children), so foreign keys are checked
    // off while applying; the data was consistent on the device that wrote it.
    await _db.customStatement('PRAGMA foreign_keys = OFF');
    try {
      await _db.transaction(() async {
        await setState('applying', '1');
        for (final c in changes) {
          if (!_synced(c.table)) continue;
          if (await _applyOne(c)) touched.add(c.table);
        }
        await setState('cursor', '$cursor');
        await setState('applying', null);
      });
    } finally {
      await _db.customStatement('PRAGMA foreign_keys = ON');
    }
    if (touched.isNotEmpty) {
      _db.markTablesUpdated([
        for (final t in _db.allTables)
          if (touched.contains(t.actualTableName)) t,
      ]);
    }
  }

  Future<bool> _applyOne(IncomingChange c) async {
    final t = c.table, k = _key(t);
    if (mutableTables.contains(t)) {
      // A newer local edit not pushed yet keeps its value (it will win on
      // the server too).
      final local =
          await (_db.select(_db.syncOutbox)
                ..where((o) => o.targetTable.equals(t) & o.recordId.equals(c.id))
                ..orderBy([(o) => OrderingTerm.desc(o.id)])
                ..limit(1))
              .getSingleOrNull();
      if (local != null &&
          newerThan(DateTime.parse(local.changedAt).toUtc(), deviceId, c.changedAt, c.deviceId)) {
        return false;
      }
      if (c.deleted) {
        await _db.customStatement('DELETE FROM "$t" WHERE "$k" = ?', [c.id]);
        return true;
      }
    }
    final data = c.data;
    if (data == null) return false;
    final known = await _cols(t);
    final skip = {..._localColumns['*']!, ...?_localColumns[t]};
    final cols = [
      for (final name in data.keys)
        if (known.contains(name) && !skip.contains(name)) name,
    ];
    if (!cols.contains(k)) return false;
    final names = cols.map((n) => '"$n"').join(', ');
    final marks = List.filled(cols.length, '?').join(', ');
    final values = [for (final n in cols) data[n]];
    if (appendOnlyTables.contains(t)) {
      await _db.customStatement('INSERT OR IGNORE INTO "$t" ($names) VALUES ($marks)', values);
    } else {
      final set = [
        for (final n in cols)
          if (n != k) '"$n" = excluded."$n"',
      ].join(', ');
      await _db.customStatement(
        'INSERT INTO "$t" ($names) VALUES ($marks) '
        'ON CONFLICT("$k") DO ${set.isEmpty ? 'NOTHING' : 'UPDATE SET $set'}',
        values,
      );
    }
    return true;
  }
}
