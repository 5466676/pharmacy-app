import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../data/reports.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
import '../format.dart';
import '../widgets.dart';
import 'reports_screen.dart' show formatMargin;

final _todaySalesProvider = StreamProvider<List<SaleRow>>((ref) {
  final now = ref.watch(clockProvider)();
  final start = DateTime(now.year, now.month, now.day);
  return ref.watch(ledgerProvider).watchSalesSince(start);
});

final _recentSalesProvider = StreamProvider<List<SaleRow>>(
  (ref) => ref.watch(ledgerProvider).watchRecentSales(limit: 8),
);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(requireSessionProvider);
    final currency = ref.watch(currencyProvider);
    final stock = ref.watch(stockProvider).value ?? StockLedger();
    final debts = ref.watch(debtsProvider).value ?? DebtLedger();
    final products = ref.watch(productsByIdProvider);
    final today = ref.watch(_todaySalesProvider).value ?? const [];
    final recent = ref.watch(_recentSalesProvider).value ?? const [];
    final employees = {
      for (final e in ref.watch(allEmployeesProvider).value ?? const <EmployeeRow>[]) e.id: e,
    };
    final devices = {
      for (final d in ref.watch(devicesProvider).value ?? const <DeviceRow>[]) d.id: d,
    };
    final customers = {
      for (final c in ref.watch(customersProvider).value ?? const <CustomerRow>[]) c.id: c,
    };
    final now = ref.watch(clockProvider)();
    final window = ref.watch(nearExpiryWindowProvider);

    final near = stock
        .nearExpiry(now, window)
        .where((b) => products.containsKey(b.productId))
        .toList();
    final low = stock.lowStock({for (final p in products.values) p.id: lowStockPieces(p)});
    final todayTotal = today.fold<int>(0, (s, x) => s + x.totalMinor);
    final profit = session.isOwner
        ? ref.watch(profitReportProvider(ReportPeriod.today)).value?.total ?? ProfitSummary.zero
        : ProfitSummary.zero;
    final suppliers = session.isOwner
        ? ref.watch(supplierLedgerProvider).value ?? SupplierLedger()
        : SupplierLedger();

    return ListView(
      children: [
        PageHeader(
          title: l.greeting(session.employee.name),
          actions: [
            SagePillButton(
              label: l.newSale,
              icon: DoayaIcons.add,
              size: PillSize.medium,
              onPressed: () => context.go(Routes.pos),
            ),
          ],
        ),
        LayoutBuilder(
          builder: (context, c) {
            const gap = DoayaSpacing.l;
            final w = (c.maxWidth - gap * 3) / 4;
            final cards = [
              StatCard(
                icon: DoayaIcons.sales,
                label: l.statSalesToday,
                value: formatMoney(todayTotal, currency),
                caption: l.statSalesCount(formatQty(today.length)),
                tone: StatusTone.success,
                onTap: () => context.go(Routes.pos),
              ),
              StatCard(
                icon: DoayaIcons.debts,
                label: l.statOpenDebts,
                value: formatMoney(debts.totalOpen, currency),
                caption: l.statCustomersCount(formatQty(debts.openDebts().length)),
                tone: StatusTone.neutral,
                onTap: () => context.go(Routes.debts),
              ),
              StatCard(
                icon: DoayaIcons.expiry,
                label: l.statNearExpiry,
                value: formatQty(near.map((b) => b.productId).toSet().length),
                caption: l.statWithinDays(formatQty(window.inDays)),
                tone: near.isEmpty ? StatusTone.neutral : StatusTone.warning,
                onTap: () => context.go(Routes.inventory),
              ),
              StatCard(
                icon: DoayaIcons.inventory,
                label: l.statLowStock,
                value: formatQty(low.length),
                caption: l.statProductsCount(formatQty(low.length)),
                tone: low.isEmpty ? StatusTone.neutral : StatusTone.danger,
                onTap: () => context.go(Routes.shortages),
              ),
              // Owner only: profit and what we owe suppliers.
              if (session.isOwner) ...[
                StatCard(
                  icon: DoayaIcons.reports,
                  label: l.statProfitToday,
                  value: formatSignedMoney(profit.profitMinor, currency),
                  caption: profit.complete
                      ? switch (formatMargin(profit)) {
                          null => null,
                          final m => l.marginCaption(m),
                        }
                      : l.costIncomplete,
                  tone: profit.complete ? StatusTone.success : StatusTone.warning,
                  onTap: () => context.go(Routes.reports),
                ),
                StatCard(
                  icon: DoayaIcons.receive,
                  label: l.statSupplierDebts,
                  value: formatMoney(suppliers.totalOwed, currency),
                  caption: l.suppliersOwedCount(formatQty(suppliers.owedCount)),
                  tone: StatusTone.neutral,
                  onTap: () => context.go(Routes.purchases),
                ),
              ],
            ];
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [for (final card in cards) SizedBox(width: w, child: card)],
            );
          },
        ),
        const SizedBox(height: DoayaSpacing.xl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Panel(
                title: l.recentSales,
                child: recent.isEmpty
                    ? EmptyHint(l.noSalesYet)
                    : Column(
                        children: [
                          _SalesHeader(l: l),
                          for (final s in recent)
                            _SaleRowView(
                              sale: s,
                              currency: currency,
                              employee: employees[s.employeeId]?.name ?? l.none,
                              device: devices[s.deviceId]?.name ?? l.none,
                              customer: s.customerId == null
                                  ? l.walkInCustomer
                                  : customers[s.customerId]?.name ?? l.none,
                              l: l,
                            ),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: DoayaSpacing.xl),
            Expanded(
              flex: 2,
              child: Panel(
                title: l.nearExpiryAlerts,
                child: near.isEmpty
                    ? EmptyHint(l.noNearExpiry)
                    : Column(
                        children: [
                          for (final b in near.take(8))
                            Padding(
                              padding: const EdgeInsets.only(bottom: DoayaSpacing.sm),
                              child: NoticeBanner(
                                tone: b.expiry!.isBefore(now)
                                    ? StatusTone.danger
                                    : StatusTone.warning,
                                icon: DoayaIcons.expiry,
                                message: l.nearExpiryAlertLine(
                                  formatStock(l, b.quantity, products[b.productId]!.unitsPerPack),
                                  ltrIsolate(products[b.productId]!.tradeName),
                                  formatDate(b.expiry!),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SalesHeader extends StatelessWidget {
  const _SalesHeader({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final s = DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary);
    return Padding(
      padding: const EdgeInsets.only(bottom: DoayaSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(l.colTime, style: s)),
          Expanded(flex: 2, child: Text(l.colCustomer, style: s)),
          Expanded(flex: 2, child: Text(l.colTotal, style: s)),
          Expanded(child: Text(l.colPayment, style: s)),
          Expanded(child: Text(l.colEmployee, style: s)),
          Expanded(child: Text(l.colDevice, style: s)),
        ],
      ),
    );
  }
}

class _SaleRowView extends StatelessWidget {
  const _SaleRowView({
    required this.sale,
    required this.currency,
    required this.employee,
    required this.device,
    required this.customer,
    required this.l,
  });

  final SaleRow sale;
  final Currency currency;
  final String employee;
  final String device;
  final String customer;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DoayaSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(formatTime(sale.occurredAt), style: DoayaTypography.bodySmall)),
          Expanded(flex: 2, child: Text(customer, style: DoayaTypography.bodySmall, maxLines: 1)),
          Expanded(
            flex: 2,
            child: Text(formatMoney(sale.totalMinor, currency), style: DoayaTypography.label),
          ),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: paymentChip(l, sale.payment),
            ),
          ),
          Expanded(child: Text(employee, style: DoayaTypography.caption, maxLines: 1)),
          Expanded(child: Text(device, style: DoayaTypography.caption, maxLines: 1)),
        ],
      ),
    );
  }
}
