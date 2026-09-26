import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../format.dart';
import '../widgets.dart';
import 'expenses_screen.dart';

/// The signed-in employee's cash drawer: open with a float, live expected
/// cash, cash in / out, close with a count (shows shortage / surplus).
class TillScreen extends ConsumerWidget {
  const TillScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    final shift = ref.watch(currentShiftProvider);
    final session = ref.watch(requireSessionProvider).stamp;
    final till = ref.read(tillProvider);

    if (shift.isLoading && !shift.hasValue) return const SizedBox.shrink();
    final s = shift.value;

    if (s == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(title: l.tillTitle),
          Panel(
            child: Column(
              children: [
                Text(l.tillIsClosed, style: DoayaTypography.lead),
                SizedBox(height: DoayaSpacing.l),
                SagePillButton(
                  label: l.openTill,
                  icon: DoayaIcons.till,
                  onPressed: () async {
                    final r = await askAmount(
                      context,
                      title: l.openTill,
                      label: l.openingFloatLabel(currency.symbol),
                      currency: currency,
                      initial: '0',
                    );
                    if (r != null) await till.openShift(session, floatMinor: r.$1);
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    String money(int m) => formatMoney(m, currency);
    Widget row(String label, String value, {bool strong = false, Color? color}) => Padding(
      padding: EdgeInsets.symmetric(vertical: DoayaSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: (strong ? DoayaTypography.label : DoayaTypography.bodySmall).copyWith(
                color: strong ? DoayaColors.textPrimary : DoayaColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: (strong ? DoayaTypography.price : DoayaTypography.label).copyWith(color: color),
          ),
        ],
      ),
    );

    return ListView(
      children: [
        PageHeader(
          title: l.tillTitle,
          actions: [
            StatusChip(label: l.tillOpenedAt(formatTime(s.openedAt)), dot: true),
            GlassPillButton(
              label: l.addCash,
              icon: DoayaIcons.add,
              onPressed: () async {
                final r = await askAmount(
                  context,
                  title: l.addCash,
                  label: l.amountLabel(currency.symbol),
                  currency: currency,
                  allowZero: false,
                  noteLabel: l.reasonLabel,
                );
                if (r != null) await till.cashIn(session, s.shiftId, r.$1, note: r.$2);
              },
            ),
            GlassPillButton(
              label: l.addExpense,
              icon: DoayaIcons.payment,
              onPressed: () => showAddExpense(context, ref),
            ),
            GlassPillButton(
              label: l.withdrawCash,
              icon: DoayaIcons.remove,
              onPressed: () async {
                final r = await askAmount(
                  context,
                  title: l.withdrawCash,
                  label: l.amountLabel(currency.symbol),
                  currency: currency,
                  allowZero: false,
                  noteLabel: l.reasonLabel,
                );
                if (r != null) await till.cashOut(session, s.shiftId, r.$1, note: r.$2!);
              },
            ),
          ],
        ),
        SplitPanes(
          main: Panel(
            child: Column(
              children: [
                row(l.tillFloat, money(s.openingFloat)),
                row(l.tillCashSales, formatSignedMoney(s.movements.cashSales, currency)),
                row(l.tillDebtPayments, formatSignedMoney(s.movements.debtPayments, currency)),
                row(l.tillCashRefunds, formatSignedMoney(-s.movements.cashRefunds, currency)),
                row(l.tillCashIn, formatSignedMoney(s.cashIn, currency)),
                row(l.tillCashOut, formatSignedMoney(-s.cashOut, currency)),
                if (s.movements.drawerPurchases != 0)
                  row(
                    l.tillDrawerPurchases,
                    formatSignedMoney(-s.movements.drawerPurchases, currency),
                  ),
                if (s.movements.drawerExpenses != 0)
                  row(
                    l.tillDrawerExpenses,
                    formatSignedMoney(-s.movements.drawerExpenses, currency),
                  ),
                if (s.movements.supplierCashRefunds != 0)
                  row(
                    l.tillSupplierRefunds,
                    formatSignedMoney(s.movements.supplierCashRefunds, currency),
                  ),
                Divider(color: DoayaColors.divider),
                row(l.tillExpected, money(s.expected), strong: true, color: DoayaColors.price),
                SizedBox(height: DoayaSpacing.sm),
                row(l.tillTransfers, money(s.movements.transferSales)),
              ],
            ),
          ),
          side: Panel(
            title: l.closeTill,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.countHelp,
                  style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
                ),
                SizedBox(height: DoayaSpacing.l),
                SagePillButton(
                  label: l.closeTill,
                  icon: DoayaIcons.check,
                  expand: true,
                  onPressed: () async {
                    final r = await askAmount(
                      context,
                      title: l.closeTill,
                      label: l.countedLabel(currency.symbol),
                      help: l.countHelp,
                      currency: currency,
                    );
                    if (r == null) return;
                    final done = await till.closeShift(session, s.shiftId, countedMinor: r.$1);
                    if (!context.mounted) return;
                    await _showResult(context, done, currency);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showResult(BuildContext context, ShiftSummary s, Currency c) {
    final l = AppLocalizations.of(context);
    return showDoayaDialog<void>(
      context: context,
      title: l.tillClosedResult,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(l.tillExpected, style: DoayaTypography.bodySmall)),
              Text(formatMoney(s.expected, c), style: DoayaTypography.label),
            ],
          ),
          Row(
            children: [
              Expanded(child: Text(l.countedLabel(c.symbol), style: DoayaTypography.bodySmall)),
              Text(formatMoney(s.counted!, c), style: DoayaTypography.label),
            ],
          ),
          SizedBox(height: DoayaSpacing.l),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: differenceChip(l, s.difference, c),
          ),
        ],
      ),
      actions: [
        SagePillButton(
          label: l.close,
          size: PillSize.small,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
