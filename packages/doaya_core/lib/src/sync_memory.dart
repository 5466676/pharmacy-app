import 'sync.dart';

/// An in-memory server with the same rules as backend/app/sync.py, for tests.
class InMemorySyncServer {
  final _rows = <String, _ServerRow>{}; // key → row
  var _seq = 0;

  /// Set to make the next call fail (simulates the network dropping).
  bool failNext = false;

  SyncTransport transportFor(String deviceId) => _MemoryTransport(this, deviceId);

  int get latest => _seq;

  void _maybeFail() {
    if (failNext) {
      failNext = false;
      throw const SyncNetworkException('simulated network failure');
    }
  }

  PushResult _push(String deviceId, List<OutgoingChange> changes) {
    _maybeFail();
    final accepted = <String>{}, rejected = <String>{}, conflicts = <String>{};
    for (final c in changes) {
      final existing = _rows[c.key];
      if (appendOnlyTables.contains(c.table)) {
        if (c.deleted || c.data == null) {
          rejected.add(c.key);
          continue;
        }
        if (existing == null) {
          _rows[c.key] = _ServerRow(c.table, c.id, c.data, false, c.changedAt, deviceId, ++_seq);
        } else if (!_sameData(existing.data, c.data)) {
          conflicts.add(c.key);
        }
        accepted.add(c.key);
      } else if (mutableTables.contains(c.table)) {
        if (existing == null ||
            newerThan(c.changedAt, deviceId, existing.changedAt, existing.deviceId)) {
          _rows[c.key] = _ServerRow(
            c.table,
            c.id,
            c.deleted ? null : c.data,
            c.deleted,
            c.changedAt,
            deviceId,
            ++_seq,
          );
        }
        accepted.add(c.key);
      } else {
        rejected.add(c.key);
      }
    }
    return PushResult(accepted: accepted, rejected: rejected, conflicts: conflicts);
  }

  PullPage _pull(String deviceId, int after, int limit) {
    _maybeFail();
    final rows = _rows.values.where((r) => r.seq > after).toList()
      ..sort((a, b) => a.seq.compareTo(b.seq));
    final page = rows.take(limit).toList();
    return PullPage(
      changes: [
        for (final r in page)
          if (r.deviceId != deviceId)
            IncomingChange(
              table: r.table,
              id: r.id,
              data: r.data,
              deleted: r.deleted,
              changedAt: r.changedAt,
              deviceId: r.deviceId,
              seq: r.seq,
            ),
      ],
      cursor: page.isEmpty ? after : page.last.seq,
      more: page.length == limit,
      latest: _seq,
    );
  }

  static bool _sameData(Map<String, Object?>? a, Map<String, Object?>? b) =>
      a != null &&
      b != null &&
      a.length == b.length &&
      a.entries.every((e) => b.containsKey(e.key) && b[e.key] == e.value);
}

class _ServerRow {
  _ServerRow(this.table, this.id, this.data, this.deleted, this.changedAt, this.deviceId, this.seq);
  final String table;
  final String id;
  final Map<String, Object?>? data;
  final bool deleted;
  final DateTime changedAt;
  final String deviceId;
  final int seq;
}

class _MemoryTransport implements SyncTransport {
  _MemoryTransport(this.server, this.deviceId);
  final InMemorySyncServer server;
  final String deviceId;

  @override
  Future<PushResult> push(List<OutgoingChange> changes) async => server._push(deviceId, changes);

  @override
  Future<PullPage> pull({required int after, required int limit}) async =>
      server._pull(deviceId, after, limit);
}

/// A device's tables in memory with an outbox, for engine tests.
class InMemorySyncStore implements SyncStore {
  InMemorySyncStore(this.deviceId, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final String deviceId;
  final DateTime Function() _clock;
  final tables = <String, Map<String, Map<String, Object?>>>{};
  final _outbox = <({int id, String table, String rowId, bool deleted, DateTime at})>[];
  var _nextOutbox = 1;
  var _cursor = 0;

  void write(String table, String id, Map<String, Object?> data) {
    (tables[table] ??= {})[id] = data;
    _outbox.add((id: _nextOutbox++, table: table, rowId: id, deleted: false, at: _clock().toUtc()));
  }

  void delete(String table, String id) {
    tables[table]?.remove(id);
    _outbox.add((id: _nextOutbox++, table: table, rowId: id, deleted: true, at: _clock().toUtc()));
  }

  int get outboxLength => _outbox.length;

  @override
  Future<List<PendingChange>> pending(int limit) async {
    // One change per row: its latest outbox entry, at its first position.
    final order = <String>[];
    final byKey =
        <String, List<({int id, String table, String rowId, bool deleted, DateTime at})>>{};
    for (final e in _outbox) {
      final k = '${e.table}:${e.rowId}';
      if (!byKey.containsKey(k)) order.add(k);
      (byKey[k] ??= []).add(e);
    }
    return [
      for (final k in order.take(limit))
        () {
          final entries = byKey[k]!;
          final last = entries.last;
          final data = tables[last.table]?[last.rowId];
          return PendingChange(
            OutgoingChange(
              table: last.table,
              id: last.rowId,
              changedAt: last.at,
              data: data,
              deleted: last.deleted || data == null,
            ),
            [for (final e in entries) e.id],
          );
        }(),
    ];
  }

  @override
  Future<void> acknowledge(Iterable<int> outboxIds) async {
    final done = outboxIds.toSet();
    _outbox.removeWhere((e) => done.contains(e.id));
  }

  @override
  Future<int> cursor() async => _cursor;

  @override
  Future<void> apply(List<IncomingChange> changes, int cursor) async {
    for (final c in changes) {
      if (mutableTables.contains(c.table)) {
        // A local edit not pushed yet that is newer keeps its value.
        final local = _outbox.where((e) => e.table == c.table && e.rowId == c.id).lastOrNull;
        if (local != null && newerThan(local.at, deviceId, c.changedAt, c.deviceId)) continue;
        if (c.deleted) {
          tables[c.table]?.remove(c.id);
        } else {
          (tables[c.table] ??= {})[c.id] = c.data!;
        }
      } else {
        (tables[c.table] ??= {}).putIfAbsent(c.id, () => c.data!);
      }
    }
    _cursor = cursor;
  }
}
