import 'package:doaya_core/doaya_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/catalog_repository.dart';
import 'data/database.dart';
import 'data/ledger_repository.dart';
import 'data/people_repository.dart';
import 'data/till_repository.dart';

/// Overridden in `main()` (on-disk DB) and in tests (in-memory DB).
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('override databaseProvider'),
);

/// Overridable clock (tests pin "now").
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final idsProvider = Provider<UuidV7>((ref) => UuidV7(clock: ref.watch(clockProvider)));

final catalogProvider = Provider(
  (ref) => CatalogRepository(
    ref.watch(databaseProvider),
    ids: ref.watch(idsProvider),
    clock: ref.watch(clockProvider),
  ),
);

final ledgerProvider = Provider(
  (ref) => LedgerRepository(
    ref.watch(databaseProvider),
    ids: ref.watch(idsProvider),
    clock: ref.watch(clockProvider),
  ),
);

final tillProvider = Provider(
  (ref) => TillRepository(
    ref.watch(databaseProvider),
    ids: ref.watch(idsProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Live summary of the signed-in employee's open shift on this device
/// (null when the till is closed). Refreshes on every sale/refund/till event.
final currentShiftProvider = StreamProvider<ShiftSummary?>((ref) async* {
  final till = ref.watch(tillProvider);
  final session = ref.watch(sessionProvider);
  if (session == null) {
    yield null;
    return;
  }
  Future<ShiftSummary?> load() async {
    final id = await till.openShiftId(session.stamp);
    return id == null ? null : till.summary(id);
  }

  yield await load();
  await for (final _ in till.watchChanges()) {
    yield await load();
  }
});

final peopleProvider = Provider(
  (ref) => PeopleRepository(
    ref.watch(databaseProvider),
    ids: ref.watch(idsProvider),
    clock: ref.watch(clockProvider),
  ),
);

// ─── Device & session ────────────────────────────────────────────────────────

/// This machine's registration; null until first-run setup is done.
final thisDeviceProvider = FutureProvider<DeviceRow?>(
  (ref) => ref.watch(peopleProvider).thisDevice(),
);

class AppSession {
  const AppSession({required this.device, required this.employee});

  final DeviceRow device;
  final EmployeeRow employee;

  bool get isOwner => employee.role == EmployeeRole.owner.name;
  Session get stamp => Session(deviceId: device.id, employeeId: employee.id);
}

class SessionNotifier extends Notifier<AppSession?> {
  @override
  AppSession? build() => null;

  void signIn(DeviceRow device, EmployeeRow employee) =>
      state = AppSession(device: device, employee: employee);

  void signOut() => state = null;
}

final sessionProvider = NotifierProvider<SessionNotifier, AppSession?>(SessionNotifier.new);

/// The signed-in session. Only read this below the login gate.
final requireSessionProvider = Provider<AppSession>((ref) {
  final s = ref.watch(sessionProvider);
  if (s == null) throw StateError('not signed in');
  return s;
});

// ─── Live data (drift watch queries) ─────────────────────────────────────────

final settingsProvider = StreamProvider<Map<String, String>>(
  (ref) => ref.watch(peopleProvider).watchSettings(),
);

final currencyProvider = Provider<Currency>(
  (ref) => PeopleRepository.currencyFrom(ref.watch(settingsProvider).value ?? const {}),
);

final nearExpiryWindowProvider = Provider<Duration>(
  (ref) => Duration(
    days: PeopleRepository.nearExpiryDaysFrom(ref.watch(settingsProvider).value ?? const {}),
  ),
);

final stockProvider = StreamProvider<StockLedger>((ref) => ref.watch(ledgerProvider).watchStock());

final debtsProvider = StreamProvider<DebtLedger>((ref) => ref.watch(ledgerProvider).watchDebts());

final productsProvider = StreamProvider<List<ProductRow>>(
  (ref) => ref.watch(catalogProvider).watchAll(),
);

final productsByIdProvider = Provider<Map<String, ProductRow>>(
  (ref) => {for (final p in ref.watch(productsProvider).value ?? const <ProductRow>[]) p.id: p},
);

final customersProvider = StreamProvider<List<CustomerRow>>(
  (ref) => ref.watch(peopleProvider).watchCustomers(),
);

final employeesProvider = StreamProvider<List<EmployeeRow>>(
  (ref) => ref.watch(peopleProvider).watchEmployees(),
);

final allEmployeesProvider = StreamProvider<List<EmployeeRow>>(
  (ref) => ref.watch(peopleProvider).watchEmployees(activeOnly: false),
);

final devicesProvider = StreamProvider<List<DeviceRow>>(
  (ref) => ref.watch(peopleProvider).watchDevices(),
);
