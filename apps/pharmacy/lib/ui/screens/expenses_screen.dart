import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../format.dart';
import '../widgets.dart';

/// The expense kinds offered as chips; anything else is typed by hand and
/// stored as its own name.
const expenseCategories = ['rent', 'salaries', 'electricity', 'generator', 'internet'];

String expenseCategoryLabel(AppLocalizations l, String category) =>
    expenseCategories.contains(category) ? l.expenseCategory(category) : category;

/// "أيلول 2026".
String monthLabel(AppLocalizations l, DateTime month) =>
    '${l.monthName('${month.month}')} ${month.year}';

DateTime _nextMonth(DateTime m) => DateTime(m.year, m.month + 1);

final _expensesProvider = StreamProvider.autoDispose.family<List<ExpenseEvent>, DateTime>(
  (ref, month) => ref.watch(accountingProvider).watchExpensesBetween(month, _nextMonth(month)),
);

/// A month's profit and loss; refreshes on any stock movement, purchase or
/// expense.
final _pnlProvider = FutureProvider.autoDispose.family<ProfitAndLoss, DateTime>((ref, month) {
  ref
    ..watch(stockProvider)
    ..watch(costBookProvider)
    ..watch(_expensesProvider(month));
  return ref.watch(accountingProvider).profitAndLossBetween(month, _nextMonth(month));
});

/// Records an expense: its kind, amount, and whether it came out of the
/// drawer (needs an open till) or from outside. Anyone can; the owner sees
/// the totals in [ExpensesScreen]. Returns true when saved.
Future<bool> showAddExpense(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final currency = ref.read(currencyProvider);
  final form = GlobalKey<FormState>();
  final amount = TextEditingController();
  final custom = TextEditingController();
  final note = TextEditingController();
  var category = expenseCategories.first;
  var from = ref.read(currentShiftProvider).value == null ? PaidFrom.outside : PaidFrom.drawer;
  void submit() {
    if (form.currentState!.validate()) Navigator.of(context).pop(true);
  }

  final ok = await showDoayaDialog<bool>(
    context: context,
    title: l.addExpenseTitle,
    content: StatefulBuilder(
      builder: (context, setState) {
        Widget choice(String label, bool selected, VoidCallback onPressed) =>
            GlassPillButton(label: label, selected: selected, onPressed: onPressed);
        return Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.expenseCategoryLabel,
                style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
              ),
              const SizedBox(height: DoayaSpacing.s),
              Wrap(
                spacing: DoayaSpacing.s,
                runSpacing: DoayaSpacing.s,
                children: [
                  for (final c in [...expenseCategories, 'other'])
                    choice(l.expenseCategory(c), category == c, () => setState(() => category = c)),
                ],
              ),
              if (category == 'other') ...[
                const SizedBox(height: DoayaSpacing.l),
                GlassTextField(
                  label: l.expenseCustomLabel,
                  controller: custom,
                  autofocus: true,
                  validator: (v) => (v ?? '').trim().isEmpty ? l.required : null,
                ),
              ],
              const SizedBox(height: DoayaSpacing.l),
              GlassTextField(
                label: l.amountLabel(currency.symbol),
                controller: amount,
                autofocus: category != 'other',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final m = Money.tryParse(v ?? '', currency);
                  return m == null || m.isZero ? l.invalidNumber : null;
                },
                onSubmitted: (_) => submit(),
              ),
              const SizedBox(height: DoayaSpacing.l),
              GlassTextField(label: '${l.notesLabel} (${l.optional})', controller: note),
              const SizedBox(height: DoayaSpacing.l),
              Text(
                l.paidFromLabel,
                style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
              ),
              const SizedBox(height: DoayaSpacing.s),
              Row(
                children: [
                  for (final (i, (f, label)) in [
                    (PaidFrom.drawer, l.fromDrawer),
                    (PaidFrom.outside, l.fromOutside),
                  ].indexed) ...[
                    if (i > 0) const SizedBox(width: DoayaSpacing.sm),
                    Expanded(
                      child: GlassPillButton(
                        label: label,
                        expand: true,
                        selected: from == f,
                        onPressed: () => setState(() => from = f),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    ),
    actions: [
      GlassPillButton(label: l.cancel, onPressed: () => Navigator.of(context).pop(false)),
      SagePillButton(label: l.confirm, size: PillSize.small, onPressed: submit),
    ],
  );
  if (ok != true || !context.mounted) return false;
  if (from == PaidFrom.drawer && ref.read(currentShiftProvider).value == null) {
    toast(context, l.errDrawerClosed, error: true);
    return false;
  }
  await ref
      .read(accountingProvider)
      .addExpense(
        ref.read(requireSessionProvider).stamp,
        category: category == 'other' ? custom.text : category,
        amount: Money.tryParse(amount.text, currency)!,
        paidFrom: from,
        note: note.text,
      );
  if (context.mounted) toast(context, l.expenseSaved);
  return true;
}

/// Owner only: a month's profit and loss (sales − customer returns − cost
/// of goods − expenses) and the month's expenses.
class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  DateTime? _month;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(clockProvider)();
    final current = DateTime(now.year, now.month);
    final month = _month ?? current;

    return ListView(
      children: [
        PageHeader(
          title: l.expensesTitle,
          actions: [
            GlassPillButton(
              label: l.previousMonth,
              onPressed: () => setState(() => _month = DateTime(month.year, month.month - 1)),
            ),
            StatusChip(label: monthLabel(l, month), tone: StatusTone.accent),
            GlassPillButton(
              label: l.nextMonth,
              onPressed: month == current ? null : () => setState(() => _month = _nextMonth(month)),
            ),
            SagePillButton(
              label: l.addExpense,
              icon: DoayaIcons.add,
              size: PillSize.medium,
              onPressed: () => showAddExpense(context, ref),
            ),
          ],
        ),
        SplitPanes(
          main: _Statement(month: month),
          side: _ExpenseList(month: month),
        ),
      ],
    );
  }
}

class _Statement extends ConsumerWidget {
  const _Statement({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    final pnl = ref.watch(_pnlProvider(month)).value;
    if (pnl == null) return Panel(title: l.pnlTitle, child: const SizedBox.shrink());

    Widget line(
      String label,
      int minor, {
      bool strong = false,
      bool signed = false,
      Color? color,
    }) => Padding(
      padding: const EdgeInsets.symmetric(vertical: DoayaSpacing.xs),
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
            signed ? formatSignedMoney(minor, currency) : formatMoney(minor, currency),
            style: (strong ? DoayaTypography.price : DoayaTypography.label).copyWith(color: color),
          ),
        ],
      ),
    );
    const divider = Divider(color: DoayaColors.divider);
    final categories = pnl.expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final net = pnl.netProfitMinor;

    return Panel(
      title: l.pnlTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          line(l.pnlSales, pnl.salesMinor),
          line(l.pnlRefunds, -pnl.refundsMinor, signed: true),
          line(l.pnlNetSales, pnl.netSalesMinor, strong: true),
          line(l.pnlCostOfGoods, -pnl.costOfGoodsMinor, signed: true),
          if (pnl.unknownCostPieces > 0)
            Text(
              l.piecesWithoutCost(formatQty(pnl.unknownCostPieces)),
              style: DoayaTypography.caption.copyWith(color: DoayaColors.warningText),
            ),
          line(l.pnlGrossProfit, pnl.grossProfitMinor, strong: true, signed: true),
          divider,
          for (final e in categories) line(expenseCategoryLabel(l, e.key), -e.value, signed: true),
          line(l.pnlExpenses, -pnl.expensesMinor, strong: true, signed: true),
          divider,
          line(
            net >= 0 ? l.pnlNetProfit : l.pnlNetLoss,
            net,
            strong: true,
            signed: true,
            color: net >= 0 ? DoayaColors.price : DoayaColors.dangerText,
          ),
          if (pnl.unknownCostPieces > 0) ...[
            const SizedBox(height: DoayaSpacing.l),
            NoticeBanner(
              message: l.unknownCostNotice(formatQty(pnl.unknownCostPieces)),
              icon: DoayaIcons.warning,
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpenseList extends ConsumerWidget {
  const _ExpenseList({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    final expenses = ref.watch(_expensesProvider(month)).value ?? const <ExpenseEvent>[];
    final employees = {
      for (final e in ref.watch(allEmployeesProvider).value ?? const <EmployeeRow>[]) e.id: e,
    };
    final secondary = DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary);

    return Panel(
      title: l.expensesListTitle,
      child: expenses.isEmpty
          ? EmptyHint(l.noExpenses)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final e in expenses)
                  Padding(
                    padding: const EdgeInsets.only(bottom: DoayaSpacing.ml),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                expenseCategoryLabel(l, e.category),
                                style: DoayaTypography.label,
                              ),
                            ),
                            Text(
                              formatMoney(e.amountMinor, currency),
                              style: DoayaTypography.label.copyWith(color: DoayaColors.price),
                            ),
                          ],
                        ),
                        Text(
                          [
                            formatDate(e.meta.occurredAt),
                            e.paidFrom == PaidFrom.drawer
                                ? l.expenseFromDrawerTag
                                : l.expenseFromOutsideTag,
                            ?employees[e.meta.employeeId]?.name,
                            ?e.note,
                          ].join('، '),
                          style: secondary,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
