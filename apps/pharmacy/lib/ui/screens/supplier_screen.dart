import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
import '../format.dart';
import '../widgets.dart';
import 'purchases_screen.dart' show PurchaseList;

final _supplierProvider = FutureProvider.family<SupplierRow?, String>((ref, id) {
  ref.watch(suppliersProvider);
  return ref.watch(accountingProvider).supplier(id);
});

/// One supplier: balance, debt age and statement (owner only), payments,
/// returns to the supplier and its purchase invoices.
class SupplierScreen extends ConsumerWidget {
  const SupplierScreen({super.key, required this.supplierId});

  final String supplierId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final supplier = ref.watch(_supplierProvider(supplierId)).value;
    final owner = ref.watch(requireSessionProvider).isOwner;
    final currency = ref.watch(currencyProvider);
    final ledger = ref.watch(supplierLedgerProvider).value ?? SupplierLedger();
    if (supplier == null) return const SizedBox.shrink();
    final balance = ledger.balance(supplierId);
    final open = ledger.openDebts(supplierId);
    final now = ref.watch(clockProvider)();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          leading: RoundIconButton(
            icon: DoayaIcons.back,
            tooltip: l.back,
            onPressed: () => context.go(Routes.purchases),
          ),
          title: supplier.name,
          actions: [
            GlassPillButton(
              label: l.returnToSupplier,
              icon: DoayaIcons.returns,
              size: PillSize.medium,
              onPressed: () => showDialog<void>(
                context: context,
                useRootNavigator: false,
                barrierColor: DoayaColors.scrim,
                builder: (_) => _SupplierReturnDialog(supplier: supplier),
              ),
            ),
            GlassPillButton(
              label: l.paySupplier,
              icon: DoayaIcons.payment,
              size: PillSize.medium,
              onPressed: () => _pay(context, ref, supplier, currency),
            ),
            SagePillButton(
              label: l.newPurchase,
              icon: DoayaIcons.receive,
              size: PillSize.medium,
              onPressed: () => context.go(Routes.newPurchaseFrom(supplierId)),
            ),
          ],
        ),
        if (owner) ...[
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: DoayaIcons.debts,
                  label: l.balanceOwed,
                  value: balance > 0 ? formatMoney(balance, currency) : l.settled,
                  tone: balance > 0 ? StatusTone.warning : StatusTone.accent,
                ),
              ),
              const SizedBox(width: DoayaSpacing.l),
              Expanded(
                child: StatCard(
                  icon: DoayaIcons.clock,
                  label: l.oldestDebt,
                  value: open.isEmpty ? l.none : l.daysAgo(formatQty(open.first.ageInDays(now))),
                  caption: open.isEmpty ? null : formatDate(open.first.since),
                  tone: StatusTone.neutral,
                ),
              ),
              const SizedBox(width: DoayaSpacing.l),
              Expanded(
                child: StatCard(
                  icon: DoayaIcons.person,
                  label: l.repNameLabel,
                  value: supplier.repName ?? l.none,
                  caption: supplier.phone,
                  tone: StatusTone.neutral,
                ),
              ),
            ],
          ),
          const SizedBox(height: DoayaSpacing.xl),
        ],
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (owner) ...[
                Expanded(
                  child: Panel(
                    title: l.statement,
                    child: Expanded(child: _Statement(lines: ledger.statement(supplierId))),
                  ),
                ),
                const SizedBox(width: DoayaSpacing.xl),
              ],
              Expanded(
                child: Panel(
                  title: l.tabInvoices,
                  child: Expanded(child: PurchaseList(supplierId: supplierId)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pay(
    BuildContext context,
    WidgetRef ref,
    SupplierRow supplier,
    Currency currency,
  ) async {
    final l = AppLocalizations.of(context);
    final form = GlobalKey<FormState>();
    final amount = TextEditingController();
    final note = TextEditingController();
    var from = PaidFrom.drawer;
    void submit() {
      if (form.currentState!.validate()) Navigator.of(context).pop(true);
    }

    final ok = await showDoayaDialog<bool>(
      context: context,
      title: l.paySupplier,
      content: StatefulBuilder(
        builder: (context, setState) => Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassTextField(
                label: l.amountLabel(currency.symbol),
                controller: amount,
                autofocus: true,
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
                  Expanded(
                    child: GlassPillButton(
                      label: l.fromDrawer,
                      expand: true,
                      selected: from == PaidFrom.drawer,
                      onPressed: () => setState(() => from = PaidFrom.drawer),
                    ),
                  ),
                  const SizedBox(width: DoayaSpacing.sm),
                  Expanded(
                    child: GlassPillButton(
                      label: l.fromOutside,
                      expand: true,
                      selected: from == PaidFrom.outside,
                      onPressed: () => setState(() => from = PaidFrom.outside),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        GlassPillButton(label: l.cancel, onPressed: () => Navigator.of(context).pop(false)),
        SagePillButton(label: l.confirm, size: PillSize.small, onPressed: submit),
      ],
    );
    if (ok != true) return;
    await ref
        .read(accountingProvider)
        .paySupplier(
          ref.read(requireSessionProvider).stamp,
          supplierId: supplier.id,
          amount: Money.tryParse(amount.text, currency)!,
          paidFrom: from,
          note: note.text,
        );
    if (context.mounted) toast(context, l.saved);
  }
}

class _Statement extends ConsumerWidget {
  const _Statement({required this.lines});

  final List<(SupplierDebtEvent, int)> lines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    if (lines.isEmpty) return EmptyHint(l.noPurchases);
    final head = DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary);
    final rows = lines.reversed.toList(); // newest first

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(l.colDate, style: head)),
            Expanded(flex: 2, child: Text(l.colMovement, style: head)),
            Expanded(child: Text(l.colAmount, style: head)),
            Expanded(
              child: Text(l.colBalance, style: head, textAlign: TextAlign.end),
            ),
          ],
        ),
        const Divider(color: DoayaColors.divider),
        Expanded(
          child: ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final (e, running) = rows[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: DoayaSpacing.xs),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(formatDate(e.meta.occurredAt), style: DoayaTypography.caption),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        [
                          switch (e.type) {
                            SupplierDebtEventType.purchaseOnCredit => l.evPurchaseOnCredit,
                            SupplierDebtEventType.paymentMade => l.evPaymentMade,
                            SupplierDebtEventType.returnCredited => l.evReturnCredited,
                          },
                          ?e.note,
                        ].join('، '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DoayaTypography.caption,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        formatSignedMoney(e.signedMinor, currency),
                        style: DoayaTypography.caption,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        formatMoney(running, currency),
                        textAlign: TextAlign.end,
                        style: DoayaTypography.label,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Return goods to the supplier: product → batch → pieces → value, credited
/// to the account or refunded in cash (into the drawer).
class _SupplierReturnDialog extends ConsumerStatefulWidget {
  const _SupplierReturnDialog({required this.supplier});

  final SupplierRow supplier;

  @override
  ConsumerState<_SupplierReturnDialog> createState() => _SupplierReturnDialogState();
}

class _SupplierReturnDialogState extends ConsumerState<_SupplierReturnDialog> {
  List<ProductRow> _results = const [];
  ProductRow? _product;
  String? _batchId;
  final _pieces = TextEditingController();
  final _credit = TextEditingController();
  final _note = TextEditingController();
  var _cash = false;
  var _busy = false;

  @override
  void dispose() {
    _pieces.dispose();
    _credit.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    final r = q.trim().isEmpty ? const <ProductRow>[] : await ref.read(catalogProvider).search(q);
    if (mounted) setState(() => _results = r);
  }

  /// Owner only: suggest the batch's cost as the credit value.
  void _suggestCredit() {
    if (!ref.read(requireSessionProvider).isOwner || _batchId == null) return;
    final pieces = int.tryParse(toLatinDigits(_pieces.text.trim()));
    final cost = pieces == null
        ? null
        : ref.read(costBookProvider).value?.costOf(_batchId!, pieces);
    if (cost != null) _credit.text = moneyInput(cost, ref.read(currencyProvider));
  }

  Future<void> _confirm() async {
    final l = AppLocalizations.of(context);
    final currency = ref.read(currencyProvider);
    final pieces = int.tryParse(toLatinDigits(_pieces.text.trim()));
    final credit = Money.tryParse(_credit.text, currency);
    if (_product == null || pieces == null || pieces <= 0 || credit == null) {
      toast(context, l.errPurchaseLine, error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(accountingProvider)
          .returnToSupplier(
            ref.read(requireSessionProvider).stamp,
            supplierId: widget.supplier.id,
            items: [
              SupplierReturnItem(
                productId: _product!.id,
                pieces: pieces,
                creditMinor: credit.minor,
                batchId: _batchId,
              ),
            ],
            currency: currency,
            refundInCash: _cash,
            note: _note.text,
          );
      if (!mounted) return;
      toast(context, l.returnSaved);
      Navigator.of(context).pop();
    } on InsufficientStock {
      if (mounted) toast(context, l.errStock, error: true);
    } on PurchaseException {
      if (mounted) toast(context, l.errPurchaseLine, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    final stock = ref.watch(stockProvider).value ?? StockLedger();
    final p = _product;
    final batches = p == null ? const <BatchStock>[] : stock.fefo(p.id);

    return Dialog(
      backgroundColor: DoayaColors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: DoayaSizes.formWidth,
          maxHeight: DoayaSizes.wideFormWidth,
        ),
        child: GlassSurface(
          tone: SurfaceTone.strong,
          blur: true,
          borderRadius: BorderRadius.circular(DoayaRadii.hero),
          padding: const EdgeInsets.all(DoayaSpacing.huge),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                '${l.returnToSupplier}: ${widget.supplier.name}',
                style: DoayaTypography.titleSmall,
              ),
              const SizedBox(height: DoayaSpacing.l),
              if (p == null) ...[
                GlassSearchField(hint: l.posSearchHint, autofocus: true, onChanged: _search),
                const SizedBox(height: DoayaSpacing.sm),
                for (final r in _results.take(6))
                  Padding(
                    padding: const EdgeInsets.only(bottom: DoayaSpacing.s),
                    child: CaseRow(
                      initials: '',
                      title: r.tradeName,
                      subtitle: formatStock(l, stock.onHand(r.id), r.unitsPerPack),
                      onTap: () => setState(() {
                        _product = r;
                        _batchId = stock.fefo(r.id).firstOrNull?.batchId;
                      }),
                    ),
                  ),
              ] else ...[
                Row(
                  children: [
                    Expanded(child: ProductName(product: p)),
                    RoundIconButton(
                      icon: DoayaIcons.close,
                      tooltip: l.close,
                      onPressed: () => setState(() {
                        _product = null;
                        _batchId = null;
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: DoayaSpacing.l),
                Text(l.batchLabel, style: DoayaTypography.label),
                const SizedBox(height: DoayaSpacing.s),
                if (batches.isEmpty) EmptyHint(l.noBatches),
                Wrap(
                  spacing: DoayaSpacing.s,
                  runSpacing: DoayaSpacing.s,
                  children: [
                    for (final b in batches)
                      GlassPillButton(
                        label:
                            '${b.expiry == null ? l.noExpiry : formatDate(b.expiry!)}: '
                            '${formatStock(l, b.quantity, p.unitsPerPack)}',
                        selected: b.batchId == _batchId,
                        onPressed: () => setState(() {
                          _batchId = b.batchId;
                          _suggestCredit();
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: DoayaSpacing.l),
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        label: l.piecesLabel,
                        controller: _pieces,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(_suggestCredit),
                      ),
                    ),
                    const SizedBox(width: DoayaSpacing.sm),
                    Expanded(
                      child: GlassTextField(
                        label: l.creditValueLabel(currency.symbol),
                        controller: _credit,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DoayaSpacing.l),
                GlassTextField(label: '${l.notesLabel} (${l.optional})', controller: _note),
                const SizedBox(height: DoayaSpacing.l),
                Row(
                  children: [
                    Expanded(
                      child: GlassPillButton(
                        label: l.refundCreditAccount,
                        expand: true,
                        selected: !_cash,
                        onPressed: () => setState(() => _cash = false),
                      ),
                    ),
                    const SizedBox(width: DoayaSpacing.sm),
                    Expanded(
                      child: GlassPillButton(
                        label: l.refundCashFromSupplier,
                        expand: true,
                        selected: _cash,
                        onPressed: () => setState(() => _cash = true),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: DoayaSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassPillButton(label: l.cancel, onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: DoayaSpacing.sm),
                  SagePillButton(
                    label: l.confirm,
                    size: PillSize.small,
                    onPressed: _busy || p == null ? null : _confirm,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
