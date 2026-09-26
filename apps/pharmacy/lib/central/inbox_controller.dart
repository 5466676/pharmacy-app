import 'dart:async';

import 'package:doaya_core/doaya_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sync/sync_controller.dart';
import 'central_api.dart';

enum InboxPhase {
  /// This device isn't linked to a pharmacy server.
  notLinked,

  /// The pharmacy server isn't linked to Doaya online yet (owner's step).
  notConnected,

  /// No internet at the pharmacy (or the central server is down); selling
  /// is not affected.
  offline,
  loading,
  ready,
}

class InboxState {
  const InboxState({
    this.phase = InboxPhase.loading,
    this.cases = const [],
    this.orders = const [],
    this.newUrgent = const {},
    this.lastUpdated,
  });

  final InboxPhase phase;
  final List<CaseBrief> cases;
  final List<PatientOrder> orders;

  /// Urgent cases that arrived with the last refresh (the shell rings).
  final Set<String> newUrgent;
  final DateTime? lastUpdated;

  int get waiting => cases.where((c) => c.open).length + orders.where((o) => o.open).length;
  bool get anyUrgent => cases.any((c) => c.urgent && c.open);
}

/// How often the inbox refreshes while the app runs; off whenever
/// background sync is off (tests).
final inboxIntervalProvider = Provider<Duration?>(
  (ref) => ref.watch(syncIntervalProvider) == null ? null : const Duration(seconds: 15),
);

/// The central API through this device's pharmacy server (null when not linked).
final centralApiProvider = Provider<CentralApi?>((ref) {
  ref.watch(syncProvider.select((s) => s.link));
  final client = ref.read(syncProvider.notifier).client;
  return client == null ? null : CentralApi(client);
});

/// Patients' cases and orders for this pharmacy, refreshed in the
/// background. Never touches selling.
class InboxController extends Notifier<InboxState> {
  Timer? _timer;
  Future<void>? _running;

  @override
  InboxState build() {
    final api = ref.watch(centralApiProvider);
    ref.onDispose(() => _timer?.cancel());
    if (api == null) return const InboxState(phase: InboxPhase.notLinked);
    final every = ref.watch(inboxIntervalProvider);
    if (every != null) _timer = Timer.periodic(every, (_) => refresh());
    scheduleMicrotask(refresh);
    return const InboxState();
  }

  Future<void> refresh() => _running ??= _refresh().whenComplete(() => _running = null);

  Future<void> _refresh() async {
    final api = ref.read(centralApiProvider);
    if (api == null) return;
    try {
      final (cases, orders) = (await api.cases(), await api.orders());
      final known = state.cases.map((c) => c.id).toSet();
      final firstLoad = state.phase != InboxPhase.ready;
      state = InboxState(
        phase: InboxPhase.ready,
        cases: cases,
        orders: orders,
        newUrgent: firstLoad
            ? {for (final c in cases.where((c) => c.urgent && c.open)) c.id}
            : {for (final c in cases.where((c) => c.urgent && !known.contains(c.id))) c.id},
        lastUpdated: DateTime.now(),
      );
    } on SyncApiException catch (e) {
      state = InboxState(
        phase: e.code == 'central_not_configured' ? InboxPhase.notConnected : InboxPhase.offline,
        cases: state.cases,
        orders: state.orders,
      );
    } on SyncNetworkException {
      state = InboxState(phase: InboxPhase.offline, cases: state.cases, orders: state.orders);
    }
  }
}

final inboxProvider = NotifierProvider<InboxController, InboxState>(InboxController.new);
