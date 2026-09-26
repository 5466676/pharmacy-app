import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/providers.dart';
import '../l10n/app_localizations.dart';
import 'common.dart';

/// The last 6 months, newest first, as "2026-09".
List<String> recentMonths(DateTime now, [int count = 6]) => [
  for (var i = 0; i < count; i++)
    () {
      final d = DateTime(now.year, now.month - i);
      return '${d.year}-${d.month.toString().padLeft(2, '0')}';
    }(),
];

class PerformanceScreen extends ConsumerWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final months = recentMonths(DateTime.now());
    final month = ref.watch(performanceMonthProvider) ?? months.first;
    return ListView(
      children: [
        PageHeader(
          title: l.perfTitle,
          trailing: Wrap(
            spacing: DoayaSpacing.xs,
            children: [
              for (final m in months)
                GlassPillButton(
                  label: m,
                  selected: m == month,
                  onPressed: () => ref.read(performanceMonthProvider.notifier).set(m),
                ),
            ],
          ),
        ),
        AsyncView(
          value: ref.watch(performanceProvider),
          retry: () => ref.invalidate(performanceProvider),
          data: (p) => _Table(p),
        ),
      ],
    );
  }
}

class _Table extends StatelessWidget {
  const _Table(this.p);
  final Performance p;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rows = p.rows;
    Widget cell(String s, {TextStyle? style}) => Text(s, style: style ?? DoayaTypography.bodySmall);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.perfSubtitle(formatNumber(p.targetMinutes), formatNumber(p.minCases)),
          style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
        ),
        SizedBox(height: DoayaSpacing.m),
        Panel(
          child: rows.isEmpty
              ? EmptyHint(l.perfEmpty)
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: DoayaSpacing.l,
                    headingTextStyle: DoayaTypography.caption.copyWith(
                      color: DoayaColors.textSecondary,
                    ),
                    columns: [
                      for (final c in [
                        l.colRank,
                        l.colName,
                        l.colCity,
                        l.colCases,
                        l.colAnswered,
                        l.colWithin,
                        l.colResponse,
                        l.colP90,
                        l.colUrgent,
                        l.colOrders,
                        l.colTier,
                      ])
                        DataColumn(label: Text(c)),
                    ],
                    rows: [
                      for (final r in rows)
                        DataRow(
                          cells: [
                            DataCell(cell(r.rank == null ? '—' : formatNumber(r.rank!))),
                            DataCell(cell(r.name, style: DoayaTypography.label)),
                            DataCell(cell(r.city ?? '—')),
                            DataCell(cell(formatNumber(r.cases))),
                            DataCell(cell(percent(l, r.answeredShare))),
                            DataCell(cell(percent(l, r.withinTarget))),
                            DataCell(cell(minutes(l, r.median))),
                            DataCell(cell(minutes(l, r.p90))),
                            DataCell(
                              cell('${formatNumber(r.urgentInTime)} / ${formatNumber(r.urgent)}'),
                            ),
                            DataCell(
                              cell('${formatNumber(r.ordersPrepared)} / ${formatNumber(r.orders)}'),
                            ),
                            DataCell(_Tier(r)),
                          ],
                        ),
                    ],
                  ),
                ),
        ),
        SizedBox(height: DoayaSpacing.sm),
        Text(
          l.rewardsNote,
          style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
        ),
        SizedBox(height: DoayaSpacing.xl),
      ],
    );
  }
}

class _Tier extends StatelessWidget {
  const _Tier(this.r);
  final PharmacyPerformance r;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return switch (r.tier) {
      'gold' => StatusChip(label: l.tierGold, tone: StatusTone.warning, icon: DoayaIcons.trophy),
      'silver' => StatusChip(label: l.tierSilver, tone: StatusTone.accent),
      _ when r.rank == null => StatusChip(label: l.tierFew),
      _ => const Text('—'),
    };
  }
}
