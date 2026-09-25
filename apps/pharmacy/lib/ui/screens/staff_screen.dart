import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/reports.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../format.dart';
import '../widgets.dart';

final _rangeProvider = Provider.family<(DateTime, DateTime), ReportPeriod>(
  (ref, p) => periodRange(p, ref.watch(clockProvider)()),
);

final _salesProvider = StreamProvider.family<List<SaleRow>, ReportPeriod>((ref, p) {
  final (from, to) = ref.watch(_rangeProvider(p));
  return ref.watch(ledgerProvider).watchSalesBetween(from, to);
});

final _linesProvider = StreamProvider.family<List<SaleLineRow>, ReportPeriod>((ref, p) {
  final (from, to) = ref.watch(_rangeProvider(p));
  return ref.watch(ledgerProvider).watchLinesBetween(from, to);
});

final _paymentsProvider = StreamProvider.family<List<DebtEventRow>, ReportPeriod>((ref, p) {
  final (from, to) = ref.watch(_rangeProvider(p));
  return ref.watch(ledgerProvider).watchPaymentsBetween(from, to);
});

final _returnsProvider = StreamProvider.family<List<ReturnRow>, ReportPeriod>((ref, p) {
  final (from, to) = ref.watch(_rangeProvider(p));
  return ref.watch(ledgerProvider).watchReturnsBetween(from, to);
});

final _summariesProvider = Provider.family<List<EmployeeSummary>, ReportPeriod>((ref, p) {
  return summarizeByEmployee(
    sales: ref.watch(_salesProvider(p)).value ?? const [],
    lines: ref.watch(_linesProvider(p)).value ?? const [],
    payments: ref.watch(_paymentsProvider(p)).value ?? const [],
    returns: ref.watch(_returnsProvider(p)).value ?? const [],
  );
});

/// Owner-only: what each employee sold and how much cash they should hand in.
class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> {
  var _period = ReportPeriod.today;
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (!ref.watch(requireSessionProvider).isOwner) return EmptyHint(l.ownerOnly);
    final currency = ref.watch(currencyProvider);
    final summaries = ref.watch(_summariesProvider(_period));
    final employees = {
      for (final e in ref.watch(allEmployeesProvider).value ?? const <EmployeeRow>[]) e.id: e,
    };
    final selected =
        summaries.where((s) => s.employeeId == _selected).firstOrNull ?? summaries.firstOrNull;

    Widget periodChip(ReportPeriod p, String label) => Padding(
      padding: const EdgeInsetsDirectional.only(start: DoayaSpacing.s),
      child: GlassPillButton(
        label: label,
        selected: _period == p,
        onPressed: () => setState(() => _period = p),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: l.staffTitle,
          actions: [
            periodChip(ReportPeriod.today, l.periodToday),
            periodChip(ReportPeriod.week, l.periodWeek),
            periodChip(ReportPeriod.month, l.periodMonth),
          ],
        ),
        Expanded(
          child: summaries.isEmpty
              ? EmptyHint(l.staffNoActivity)
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: DoayaSizes.listPaneWidth,
                      child: ListView.separated(
                        itemCount: summaries.length,
                        separatorBuilder: (_, _) => const SizedBox(height: DoayaSpacing.sm),
                        itemBuilder: (context, i) {
                          final s = summaries[i];
                          final name = employees[s.employeeId]?.name ?? l.none;
                          return CaseRow(
                            initials: initialsOf(name),
                            title: name,
                            subtitle: l.staffSalesCount(formatQty(s.salesCount)),
                            selected: s.employeeId == selected?.employeeId,
                            trailing: StatusChip(
                              label: formatMoney(s.totalSalesMinor, currency),
                              tone: StatusTone.accent,
                            ),
                            onTap: () => setState(() => _selected = s.employeeId),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: DoayaSpacing.huge),
                    Expanded(
                      child: selected == null
                          ? const SizedBox.shrink()
                          : _EmployeeAccount(
                              summary: selected,
                              name: employees[selected.employeeId]?.name ?? l.none,
                              currency: currency,
                            ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _EmployeeAccount extends ConsumerStatefulWidget {
  const _EmployeeAccount({required this.summary, required this.name, required this.currency});

  final EmployeeSummary summary;
  final String name;
  final Currency currency;

  @override
  ConsumerState<_EmployeeAccount> createState() => _EmployeeAccountState();
}

class _EmployeeAccountState extends ConsumerState<_EmployeeAccount> {
  final _open = <String>{};

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = widget.summary;
    final c = widget.currency;
    final products = ref.watch(productsByIdProvider);
    final customers = {
      for (final x in ref.watch(customersProvider).value ?? const <CustomerRow>[]) x.id: x,
    };
    final devices = {
      for (final d in ref.watch(devicesProvider).value ?? const <DeviceRow>[]) d.id: d,
    };
    final lines = ref.watch(_allLinesBySaleProvider(s.sales.map((x) => x.id).join(',')));
    String productName(String id) => products[id]?.tradeName ?? l.none;

    Widget stat(
      IconData icon,
      String label,
      String value, {
      StatusTone tone = StatusTone.neutral,
    }) => StatCard(icon: icon, label: label, value: value, tone: tone);

    return ListView(
      children: [
        LayoutBuilder(
          builder: (context, box) {
            const gap = DoayaSpacing.l;
            final w = (box.maxWidth - gap * 2) / 3;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final card in [
                  stat(
                    DoayaIcons.sales,
                    l.staffTotalSales,
                    formatMoney(s.totalSalesMinor, c),
                    tone: StatusTone.success,
                  ),
                  stat(DoayaIcons.cash, l.staffCashSales, formatMoney(s.cashSalesMinor, c)),
                  stat(
                    DoayaIcons.debts,
                    l.staffDebtSales,
                    formatMoney(s.debtSalesMinor, c),
                    tone: StatusTone.warning,
                  ),
                  stat(
                    DoayaIcons.payment,
                    l.staffPayments,
                    formatMoney(s.paymentsCollectedMinor, c),
                  ),
                  stat(DoayaIcons.receive, l.staffDiscounts, formatMoney(s.discountMinor, c)),
                  stat(DoayaIcons.inventory, l.staffUnits, formatQty(s.unitsSold)),
                  stat(DoayaIcons.returns, l.staffReturns, formatQty(s.returnsCount)),
                  stat(
                    DoayaIcons.cash,
                    l.staffCashRefunds,
                    formatMoney(s.cashRefundsMinor, c),
                    tone: s.cashRefundsMinor > 0 ? StatusTone.danger : StatusTone.neutral,
                  ),
                ])
                  SizedBox(width: w, child: card),
              ],
            );
          },
        ),
        const SizedBox(height: DoayaSpacing.l),
        GlassSurface(
          tone: SurfaceTone.selected,
          borderRadius: BorderRadius.circular(DoayaRadii.card),
          padding: const EdgeInsets.all(DoayaSpacing.xl),
          child: Row(
            children: [
              const Icon(DoayaIcons.cash, color: DoayaColors.accent),
              const SizedBox(width: DoayaSpacing.ml),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.staffCashToHandIn, style: DoayaTypography.label),
                    Text(
                      l.staffCashHint,
                      style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(formatMoney(s.cashToHandInMinor, c), style: DoayaTypography.price),
            ],
          ),
        ),
        const SizedBox(height: DoayaSpacing.l),
        Panel(
          title: l.staffTopProducts,
          child: Wrap(
            spacing: DoayaSpacing.sm,
            runSpacing: DoayaSpacing.sm,
            children: [
              for (final e in s.topProducts())
                StatusChip(
                  label: l.lineItem(ltrIsolate(productName(e.key)), formatQty(e.value)),
                  tone: StatusTone.accent,
                ),
            ],
          ),
        ),
        const SizedBox(height: DoayaSpacing.l),
        Panel(
          title: l.staffInvoices,
          child: Column(
            children: [
              for (final sale in s.sales)
                Padding(
                  padding: const EdgeInsets.only(bottom: DoayaSpacing.sm),
                  child: GlassSurface(
                    shadow: false,
                    borderRadius: BorderRadius.circular(DoayaRadii.tile),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () => setState(
                          () =>
                              _open.contains(sale.id) ? _open.remove(sale.id) : _open.add(sale.id),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(DoayaSpacing.ml),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${formatDate(sale.occurredAt)}، ${formatTime(sale.occurredAt)}',
                                      style: DoayaTypography.bodySmall,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      sale.customerId == null
                                          ? l.walkInCustomer
                                          : customers[sale.customerId]?.name ?? l.none,
                                      style: DoayaTypography.bodySmall,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      devices[sale.deviceId]?.name ?? l.none,
                                      style: DoayaTypography.caption.copyWith(
                                        color: DoayaColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  StatusChip(
                                    label: sale.payment == 'debt' ? l.paymentDebt : l.paymentCash,
                                    tone: sale.payment == 'debt'
                                        ? StatusTone.warning
                                        : StatusTone.accent,
                                  ),
                                  const SizedBox(width: DoayaSpacing.l),
                                  SizedBox(
                                    width: DoayaSizes.priceColumn,
                                    child: Text(
                                      formatMoney(sale.totalMinor, c),
                                      style: DoayaTypography.label,
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                              if (_open.contains(sale.id))
                                for (final line in lines.value?[sale.id] ?? const <SaleLineRow>[])
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      top: DoayaSpacing.s,
                                      start: DoayaSpacing.l,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            l.lineItem(
                                              ltrIsolate(productName(line.productId)),
                                              formatQty(line.quantity),
                                            ),
                                            style: DoayaTypography.caption,
                                          ),
                                        ),
                                        Text(
                                          formatMoney(line.unitPriceMinor * line.quantity, c),
                                          style: DoayaTypography.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Lines grouped by sale id, for the given comma-joined sale ids.
final _allLinesBySaleProvider = FutureProvider.family<Map<String, List<SaleLineRow>>, String>((
  ref,
  ids,
) async {
  ref.watch(stockProvider); // refresh when new sales land
  final ledger = ref.watch(ledgerProvider);
  final out = <String, List<SaleLineRow>>{};
  for (final id in ids.split(',').where((x) => x.isNotEmpty)) {
    out[id] = await ledger.linesOf(id);
  }
  return out;
});
