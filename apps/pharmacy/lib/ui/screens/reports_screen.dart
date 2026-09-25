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

enum _Group { product, employee, day }

/// "15.5%" from basis points, isolated LTR so the % stays on the right
/// inside Arabic text. Null when there's nothing to show (no revenue, or
/// some cost unknown: a margin would look better than it is).
String? formatMargin(ProfitSummary p) {
  final bp = p.marginBasisPoints;
  if (bp == null || !p.complete) return null;
  return ltrIsolate('${formatNumber(bp / 100, decimals: 1)}%');
}

/// Owner only: revenue, cost of goods, profit and margin for a period,
/// grouped by product, employee or day; stock value at cost.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  var _period = ReportPeriod.today;
  var _group = _Group.product;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    final report = ref.watch(profitReportProvider(_period)).value;
    final value = ref.watch(stockValueProvider);
    final total = report?.total ?? ProfitSummary.zero;

    return ListView(
      children: [
        PageHeader(
          title: l.reportsTitle,
          actions: [
            for (final (p, label) in [
              (ReportPeriod.today, l.periodToday),
              (ReportPeriod.week, l.periodWeek),
              (ReportPeriod.month, l.periodMonth),
            ])
              GlassPillButton(
                label: label,
                selected: _period == p,
                onPressed: () => setState(() => _period = p),
              ),
          ],
        ),
        LayoutBuilder(
          builder: (context, c) {
            final cards = [
              StatCard(
                icon: DoayaIcons.sales,
                label: l.netSales,
                value: formatMoney(total.revenueMinor, currency),
                tone: StatusTone.neutral,
              ),
              StatCard(
                icon: DoayaIcons.receive,
                label: l.costOfGoods,
                value: formatMoney(total.costMinor, currency),
                caption: total.complete
                    ? null
                    : l.piecesWithoutCost(formatQty(total.unknownCostPieces)),
                tone: StatusTone.neutral,
              ),
              StatCard(
                icon: DoayaIcons.reports,
                label: l.grossProfit,
                value: formatSignedMoney(total.profitMinor, currency),
                caption: total.complete
                    ? switch (formatMargin(total)) {
                        null => null,
                        final m => l.marginCaption(m),
                      }
                    : l.costIncomplete,
                tone: total.profitMinor >= 0 ? StatusTone.success : StatusTone.danger,
              ),
              StatCard(
                icon: DoayaIcons.inventory,
                label: l.stockValueAtCost,
                value: formatMoney(value.costMinor, currency),
                caption: value.unknownCostPieces == 0
                    ? null
                    : l.piecesWithoutCost(formatQty(value.unknownCostPieces)),
                tone: StatusTone.neutral,
              ),
            ];
            if (isPhoneLayout(context)) {
              final w = (c.maxWidth - DoayaSpacing.l) / 2;
              return Wrap(
                spacing: DoayaSpacing.l,
                runSpacing: DoayaSpacing.l,
                children: [for (final card in cards) SizedBox(width: w, child: card)],
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, card) in cards.indexed) ...[
                    if (i > 0) const SizedBox(width: DoayaSpacing.l),
                    Expanded(child: card),
                  ],
                ],
              ),
            );
          },
        ),
        if (!total.complete) ...[
          const SizedBox(height: DoayaSpacing.l),
          NoticeBanner(
            message: l.unknownCostNotice(formatQty(total.unknownCostPieces)),
            icon: DoayaIcons.warning,
          ),
        ],
        const SizedBox(height: DoayaSpacing.xl),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final (g, label) in [
                (_Group.product, l.byProduct),
                (_Group.employee, l.byEmployee),
                (_Group.day, l.byDay),
              ]) ...[
                GlassPillButton(
                  label: label,
                  selected: _group == g,
                  onPressed: () => setState(() => _group = g),
                ),
                const SizedBox(width: DoayaSpacing.s),
              ],
            ],
          ),
        ),
        const SizedBox(height: DoayaSpacing.l),
        Panel(child: report == null ? const SizedBox.shrink() : _table(l, currency, report)),
      ],
    );
  }

  Widget _table(AppLocalizations l, Currency currency, ProfitReport report) {
    final products = ref.watch(productsByIdProvider);
    final employees = {
      for (final e in ref.watch(allEmployeesProvider).value ?? const <EmployeeRow>[]) e.id: e,
    };
    final List<(Widget, ProfitSummary)> rows = switch (_group) {
      _Group.product => [
        for (final e in ProfitReport.ranked(report.byProduct))
          (
            LatinText(
              products[e.key]?.tradeName ?? l.none,
              maxLines: 1,
              style: DoayaTypography.label,
            ),
            e.value,
          ),
      ],
      _Group.employee => [
        for (final e in ProfitReport.ranked(report.byEmployee))
          (Text(employees[e.key]?.name ?? l.none, style: DoayaTypography.label), e.value),
      ],
      _Group.day => [
        for (final e in report.byDay.entries.toList()..sort((a, b) => b.key.compareTo(a.key)))
          (Text(formatDate(e.key), style: DoayaTypography.label), e.value),
      ],
    };
    if (rows.isEmpty) return EmptyHint(l.noReportData);

    final head = DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary);
    Widget num(String text, {TextStyle? style}) => Expanded(
      child: Text(text, textAlign: TextAlign.end, style: style ?? DoayaTypography.bodySmall),
    );

    if (isPhoneLayout(context)) {
      // Phone: each row on two lines, name + profit, then sales and cost.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (name, p) in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: DoayaSpacing.ml),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: name),
                      Text(
                        formatSignedMoney(p.profitMinor, currency),
                        style: DoayaTypography.label.copyWith(
                          color: p.profitMinor >= 0 ? DoayaColors.price : DoayaColors.dangerText,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    [
                      '${l.colRevenue}: ${formatMoney(p.revenueMinor, currency)}',
                      '${l.colCost}: ${formatMoney(p.costMinor, currency)}',
                      if (formatMargin(p) case final m?) '${l.colMargin}: $m',
                      if (!p.complete) l.costIncomplete,
                    ].join('، '),
                    style: head,
                  ),
                ],
              ),
            ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(flex: 2, child: Text(_groupLabel(l), style: head)),
            num(l.colRevenue, style: head),
            num(l.colCost, style: head),
            num(l.colProfit, style: head),
            num(l.colMargin, style: head),
          ],
        ),
        const Divider(color: DoayaColors.divider),
        for (final (name, p) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: DoayaSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Flexible(child: name),
                      if (!p.complete) ...[
                        const SizedBox(width: DoayaSpacing.s),
                        StatusChip(label: l.costIncomplete, tone: StatusTone.warning),
                      ],
                    ],
                  ),
                ),
                num(formatMoney(p.revenueMinor, currency)),
                num(formatMoney(p.costMinor, currency)),
                num(
                  formatSignedMoney(p.profitMinor, currency),
                  style: DoayaTypography.label.copyWith(
                    color: p.profitMinor >= 0 ? DoayaColors.price : DoayaColors.dangerText,
                  ),
                ),
                num(formatMargin(p) ?? ''),
              ],
            ),
          ),
      ],
    );
  }

  String _groupLabel(AppLocalizations l) => switch (_group) {
    _Group.product => l.colProduct,
    _Group.employee => l.colEmployee,
    _Group.day => l.colDate,
  };
}
