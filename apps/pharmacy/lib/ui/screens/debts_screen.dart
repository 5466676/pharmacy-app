import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../format.dart';
import '../widgets.dart';

/// Customers & debts: list with balances on one side, history + payment on
/// the other.
class DebtsScreen extends ConsumerStatefulWidget {
  const DebtsScreen({super.key});

  @override
  ConsumerState<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends ConsumerState<DebtsScreen> {
  String? _selectedId;
  var _query = '';
  var _owingOnly = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    final customers = ref.watch(customersProvider).value ?? const [];
    final debts = ref.watch(debtsProvider).value ?? DebtLedger();
    final q = toLatinDigits(_query.trim());
    final list = customers.where((c) {
      if (_owingOnly && debts.balance(c.id) <= 0) return false;
      return q.isEmpty || c.name.contains(q) || (c.phone?.contains(q) ?? false);
    }).toList()..sort((a, b) => debts.balance(b.id).compareTo(debts.balance(a.id)));
    final selected = customers.where((c) => c.id == _selectedId).firstOrNull;
    final phone = isPhoneLayout(context);
    final Widget listPane = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassSearchField(hint: l.search, onChanged: (v) => setState(() => _query = v)),
        SizedBox(height: DoayaSpacing.ml),
        Row(
          children: [
            GlassPillButton(
              label: l.filterAll,
              selected: !_owingOnly,
              onPressed: () => setState(() => _owingOnly = false),
            ),
            SizedBox(width: DoayaSpacing.s),
            GlassPillButton(
              label: l.filterOwing,
              selected: _owingOnly,
              onPressed: () => setState(() => _owingOnly = true),
            ),
          ],
        ),
        SizedBox(height: DoayaSpacing.ml),
        Expanded(
          child: list.isEmpty
              ? EmptyHint(l.noCustomers)
              : ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => SizedBox(height: DoayaSpacing.sm),
                  itemBuilder: (context, i) {
                    final c = list[i];
                    final bal = debts.balance(c.id);
                    return CaseRow(
                      initials: initialsOf(c.name),
                      title: c.name,
                      subtitle: c.phone ?? '',
                      selected: c.id == _selectedId,
                      trailing: StatusChip(
                        label: bal > 0 ? formatMoney(bal, currency) : l.settled,
                        tone: bal > 0 ? StatusTone.warning : StatusTone.neutral,
                      ),
                      onTap: () => setState(() => _selectedId = c.id),
                    );
                  },
                ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: l.debtsTitle,
          actions: [
            StatusChip(
              label: '${l.totalOpenDebts}: ${formatMoney(debts.totalOpen, currency)}',
              tone: debts.totalOpen > 0 ? StatusTone.warning : StatusTone.neutral,
            ),
            SagePillButton(
              label: l.addCustomer,
              icon: DoayaIcons.customer,
              size: PillSize.medium,
              onPressed: () async {
                final c = await showAddCustomerDialog(context, ref);
                if (c != null) setState(() => _selectedId = c.id);
              },
            ),
          ],
        ),
        Expanded(
          child: phone
              ? (selected == null
                    ? listPane
                    : ListView(
                        children: [
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: RoundIconButton(
                              icon: DoayaIcons.back,
                              tooltip: l.back,
                              onPressed: () => setState(() => _selectedId = null),
                            ),
                          ),
                          SizedBox(height: DoayaSpacing.sm),
                          _CustomerDetail(customer: selected, balance: debts.balance(selected.id)),
                        ],
                      ))
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: DoayaSizes.listPaneWidth, child: listPane),
                    SizedBox(width: DoayaSpacing.huge),
                    Expanded(
                      child: selected == null
                          ? const SizedBox.shrink()
                          : _CustomerDetail(
                              customer: selected,
                              balance: debts.balance(selected.id),
                            ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _CustomerDetail extends ConsumerWidget {
  const _CustomerDetail({required this.customer, required this.balance});

  final CustomerRow customer;
  final int balance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    final history = ref.watch(_historyProvider(customer.id)).value ?? const [];

    return Panel(
      title: customer.name,
      trailing: SagePillButton(
        label: l.recordPayment,
        icon: DoayaIcons.payment,
        size: PillSize.medium,
        onPressed: balance > 0 ? () => _recordPayment(context, ref, currency) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                l.balance,
                style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
              ),
              SizedBox(width: DoayaSpacing.ml),
              Text(
                balance > 0 ? formatMoney(balance, currency) : l.settled,
                style: DoayaTypography.price.copyWith(
                  color: balance > 0 ? DoayaColors.warningText : DoayaColors.price,
                ),
              ),
            ],
          ),
          if (customer.phone != null)
            LatinText(
              customer.phone!,
              style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
            ),
          SizedBox(height: DoayaSpacing.l),
          for (final e in history)
            Padding(
              padding: EdgeInsets.only(bottom: DoayaSpacing.sm),
              child: Row(
                children: [
                  StatusChip(
                    label: switch (e.type) {
                      'debt_added' => l.debtAdded,
                      'debt_credited' => l.debtCredited,
                      _ => l.paymentReceived,
                    },
                    tone: e.type == 'debt_added' ? StatusTone.warning : StatusTone.accent,
                  ),
                  SizedBox(width: DoayaSpacing.ml),
                  Expanded(
                    child: Text(
                      '${formatDate(e.occurredAt)}، ${formatTime(e.occurredAt)}',
                      style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
                    ),
                  ),
                  Text(
                    formatSignedMoney(
                      e.type == 'debt_added' ? e.amountMinor : -e.amountMinor,
                      currency,
                    ),
                    style: DoayaTypography.label,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _recordPayment(BuildContext context, WidgetRef ref, Currency currency) async {
    final l = AppLocalizations.of(context);
    final amount = TextEditingController(text: moneyInput(balance, currency));
    final form = GlobalKey<FormState>();
    final ok = await showDoayaDialog<bool>(
      context: context,
      title: l.recordPayment,
      content: Form(
        key: form,
        child: GlassTextField(
          label: l.amountLabel(currency.symbol),
          controller: amount,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            final m = Money.tryParse(v ?? '', currency);
            if (m == null || m.isZero) return l.invalidNumber;
            if (m.minor > balance) return l.paymentTooLarge;
            return null;
          },
          onSubmitted: (_) {
            if (form.currentState!.validate()) Navigator.of(context).pop(true);
          },
        ),
      ),
      actions: [
        GlassPillButton(label: l.cancel, onPressed: () => Navigator.of(context).pop(false)),
        SagePillButton(
          label: l.confirm,
          size: PillSize.small,
          onPressed: () {
            if (form.currentState!.validate()) Navigator.of(context).pop(true);
          },
        ),
      ],
    );
    if (ok != true) return;
    await ref
        .read(ledgerProvider)
        .recordPayment(
          ref.read(requireSessionProvider).stamp,
          customerId: customer.id,
          amount: Money.tryParse(amount.text, currency)!,
        );
  }
}

final _historyProvider = StreamProvider.family<List<DebtEventRow>, String>(
  (ref, id) => ref.watch(ledgerProvider).watchDebtHistory(id),
);

/// New-customer dialog; returns the created customer.
Future<CustomerRow?> showAddCustomerDialog(
  BuildContext context,
  WidgetRef ref, {
  String initialName = '',
}) async {
  final l = AppLocalizations.of(context);
  final form = GlobalKey<FormState>();
  final name = TextEditingController(text: initialName);
  final phone = TextEditingController();
  final ok = await showDoayaDialog<bool>(
    context: context,
    title: l.newCustomer,
    content: Form(
      key: form,
      child: Column(
        children: [
          GlassTextField(
            label: l.customerNameLabel,
            controller: name,
            autofocus: true,
            validator: (v) => (v ?? '').trim().isEmpty ? l.required : null,
          ),
          SizedBox(height: DoayaSpacing.l),
          GlassTextField(
            label: '${l.phoneLabel} (${l.optional})',
            controller: phone,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    ),
    actions: [
      GlassPillButton(label: l.cancel, onPressed: () => Navigator.of(context).pop(false)),
      SagePillButton(
        label: l.save,
        size: PillSize.small,
        onPressed: () {
          if (form.currentState!.validate()) Navigator.of(context).pop(true);
        },
      ),
    ],
  );
  if (ok != true) return null;
  return ref.read(peopleProvider).addCustomer(name: name.text, phone: phone.text);
}
