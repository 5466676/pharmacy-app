import 'dart:math' as math;

import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../data/providers.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';
import 'common.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final days = ref.watch(overviewDaysProvider);
    final ranges = {1: l.rangeToday, 7: l.rangeWeek, 30: l.rangeMonth, 90: l.rangeQuarter};
    return ListView(
      children: [
        PageHeader(
          title: l.navOverview,
          subtitle: l.overviewSubtitle(formatNumber(days)),
          trailing: Wrap(
            spacing: DoayaSpacing.xs,
            children: [
              for (final e in ranges.entries)
                GlassPillButton(
                  label: e.value,
                  selected: e.key == days,
                  onPressed: () => ref.read(overviewDaysProvider.notifier).set(e.key),
                ),
              RoundIconButton(
                icon: DoayaIcons.refresh,
                tooltip: l.retry,
                onPressed: () => ref
                  ..invalidate(overviewProvider)
                  ..invalidate(pharmaciesProvider),
              ),
            ],
          ),
        ),
        AsyncView(
          value: ref.watch(overviewProvider),
          retry: () => ref.invalidate(overviewProvider),
          data: (o) => _Body(o),
        ),
      ],
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body(this.o);
  final Overview o;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    const n = formatNumber;
    final slow = o.median != null && o.median! > o.targetMinutes;
    final kpis = [
      StatCard(
        icon: DoayaIcons.pharmacy,
        label: l.kpiPharmacies,
        value: n(o.status('active')),
        caption: l.kpiPharmaciesCaption(n(o.connected), n(o.newPharmacies)),
        onTap: () => context.go(Routes.pharmacies),
      ),
      StatCard(
        icon: DoayaIcons.person,
        label: l.kpiPatients,
        value: n(o.patients),
        caption: l.kpiPatientsCaption(n(o.activePatients), n(o.newPatients)),
      ),
      StatCard(
        icon: DoayaIcons.chat,
        label: l.kpiToday,
        value: n(o.consultationsToday),
        caption: l.kpiTodayCaption(n(o.ordersToday)),
      ),
      StatCard(
        icon: DoayaIcons.clock,
        label: l.kpiResponse,
        value: minutes(l, o.median),
        caption: l.kpiResponseCaption(n(o.targetMinutes), n(o.unanswered)),
        tone: slow ? StatusTone.warning : StatusTone.accent,
      ),
      StatCard(
        icon: DoayaIcons.warning,
        label: l.kpiUrgent,
        value: n(o.urgentToday),
        caption: l.kpiUrgentCaption(n(o.urgentUnanswered)),
        tone: o.urgentUnanswered > 0 ? StatusTone.danger : StatusTone.accent,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final columns = c.maxWidth > 1100 ? 5 : (c.maxWidth > 700 ? 3 : 2);
            final gap = DoayaSpacing.m;
            final w = (c.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [for (final k in kpis) SizedBox(width: w, child: k)],
            );
          },
        ),
        SizedBox(height: DoayaSpacing.m),
        if (o.reviewWaiting > 0) ...[
          NoticeBanner(
            tone: StatusTone.accent,
            icon: DoayaIcons.review,
            message: l.reviewWaiting(n(o.reviewWaiting)),
            action: GlassPillButton(
              label: l.openReview,
              onPressed: () => context.go(Routes.review),
            ),
          ),
          SizedBox(height: DoayaSpacing.m),
        ],
        LayoutBuilder(
          builder: (context, c) {
            final chart = Panel(
              title: l.chartTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.chartLegend,
                    style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
                  ),
                  SizedBox(height: DoayaSpacing.m),
                  o.byDay.isEmpty
                      ? EmptyHint(l.chartEmpty)
                      : SizedBox(
                          height: 220,
                          child: ResponseChart(days: o.byDay, target: o.targetMinutes.toDouble()),
                        ),
                ],
              ),
            );
            const attention = _Attention();
            if (c.maxWidth < 900) {
              return Column(
                children: [
                  chart,
                  SizedBox(height: DoayaSpacing.m),
                  attention,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: chart),
                SizedBox(width: DoayaSpacing.m),
                const Expanded(flex: 2, child: attention),
              ],
            );
          },
        ),
        SizedBox(height: DoayaSpacing.m),
        Text(
          l.paymentsOff,
          style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
        ),
        SizedBox(height: DoayaSpacing.xl),
      ],
    );
  }
}

/// Pharmacies that need a look: not heard from, a health problem, slow.
class _Attention extends ConsumerWidget {
  const _Attention();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Panel(
      title: l.attentionTitle,
      child: AsyncView(
        value: ref.watch(pharmaciesProvider),
        retry: () => ref.invalidate(pharmaciesProvider),
        data: (list) {
          final rows = attentionFor(l, list);
          if (rows.isEmpty) return EmptyHint(l.attentionNone);
          return Column(
            children: [
              for (final (p, why, tone) in rows)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(p.name, style: DoayaTypography.label),
                  subtitle: Text(
                    why,
                    style: DoayaTypography.caption.copyWith(color: tone.foreground),
                  ),
                  trailing: Icon(
                    DoayaIcons.back,
                    size: DoayaSizes.iconXs,
                    color: DoayaColors.textSecondary,
                  ),
                  onTap: () => context.go(Routes.pharmacy(p.id)),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Active pharmacies to look at, and why.
List<(Pharmacy, String, StatusTone)> attentionFor(
  AppLocalizations l,
  List<Pharmacy> list, {
  int targetMinutes = 10,
  DateTime? now,
}) {
  now ??= DateTime.now();
  final out = <(Pharmacy, String, StatusTone)>[];
  for (final p in list.where((p) => p.status == 'active')) {
    final seen = p.lastHeartbeat;
    if (seen == null) {
      out.add((p, l.attentionNeverConnected, StatusTone.warning));
    } else if (now.difference(seen) > const Duration(days: 1)) {
      out.add((p, l.attentionOffline(ago(l, seen, now: now)), StatusTone.danger));
    } else if (p.health == 'problem') {
      out.add((p, l.attentionHealth, StatusTone.danger));
    } else if (p.median != null && p.median! > targetMinutes * 1.5) {
      out.add((p, l.attentionSlow(minutes(l, p.median)), StatusTone.warning));
    }
  }
  return out;
}

/// Median first response per day (line), up to P90 (band), and the target
/// (dashed). One scale for everything; colours from the design tokens.
class ResponseChart extends StatelessWidget {
  const ResponseChart({super.key, required this.days, required this.target});

  final List<DayResponse> days;
  final double target;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.infinite,
    painter: _ChartPainter(
      days: days,
      target: target,
      line: DoayaColors.accent,
      band: DoayaColors.accent.withValues(alpha: .16),
      grid: DoayaColors.divider,
      goal: DoayaColors.warningText,
      label: DoayaTypography.micro.copyWith(color: DoayaColors.textSecondary),
    ),
  );
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.days,
    required this.target,
    required this.line,
    required this.band,
    required this.grid,
    required this.goal,
    required this.label,
  });

  final List<DayResponse> days;
  final double target;
  final Color line, band, grid, goal;
  final TextStyle label;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 34.0, bottom = 22.0, top = 8.0, right = 8.0;
    final top90 = days.map((d) => d.p90 ?? d.median ?? 0).fold<double>(target, math.max);
    final max = (top90 / 5).ceil() * 5.0;
    final w = size.width - left - right, h = size.height - top - bottom;
    // Time runs left to right, like any clock-driven chart.
    double x(int i) => left + (days.length == 1 ? w / 2 : w * i / (days.length - 1));
    double y(double v) => top + h * (1 - v / max);

    void text(String s, Offset at, {bool center = false, bool end = false}) {
      final tp = TextPainter(
        text: TextSpan(text: s, style: label),
        textDirection: TextDirection.ltr,
      )..layout();
      final double dx = end ? -tp.width : (center ? -tp.width / 2 : 0);
      tp.paint(canvas, at + Offset(dx, -tp.height / 2));
    }

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    final step = max <= 20 ? 5.0 : (max / 4 / 5).ceil() * 5.0;
    for (var v = 0.0; v <= max; v += step) {
      canvas.drawLine(Offset(left, y(v)), Offset(left + w, y(v)), gridPaint);
      text(formatNumber(v), Offset(left - 6, y(v)), end: true);
    }

    // Target, dashed.
    final goalPaint = Paint()
      ..color = goal
      ..strokeWidth = 1;
    for (var sx = left; sx < left + w; sx += 8) {
      canvas.drawLine(
        Offset(sx, y(target)),
        Offset(math.min(sx + 4, left + w), y(target)),
        goalPaint,
      );
    }

    // Band up to P90.
    final bandPath = Path();
    for (var i = 0; i < days.length; i++) {
      final p = Offset(x(i), y(days[i].p90 ?? days[i].median ?? 0));
      i == 0 ? bandPath.moveTo(p.dx, p.dy) : bandPath.lineTo(p.dx, p.dy);
    }
    for (var i = days.length - 1; i >= 0; i--) {
      bandPath.lineTo(x(i), y(days[i].median ?? 0));
    }
    canvas.drawPath(bandPath..close(), Paint()..color = band);

    // Median line and its last point.
    final linePath = Path();
    for (var i = 0; i < days.length; i++) {
      final p = Offset(x(i), y(days[i].median ?? 0));
      i == 0 ? linePath.moveTo(p.dx, p.dy) : linePath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = line
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      Offset(x(days.length - 1), y(days.last.median ?? 0)),
      4,
      Paint()..color = line,
    );

    // A few dates under the axis.
    final marks = {0, days.length ~/ 2, days.length - 1};
    for (final i in marks) {
      final d = days[i].day;
      text(
        '${d.day}/${d.month}',
        Offset(x(i), size.height - bottom / 2),
        center: i != 0 && i != days.length - 1,
        end: i == days.length - 1 && days.length > 1,
      );
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.days != days || old.line != line || old.grid != grid || old.label != label;
}
