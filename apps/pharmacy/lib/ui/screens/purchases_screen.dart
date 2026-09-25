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

final purchasesListProvider = StreamProvider.family<List<PurchaseRow>, String?>(
  (ref, supplierId) => ref.watch(accountingProvider).watchPurchases(supplierId: supplierId),
);

final _purchaseLinesProvider = FutureProvider.family<List<PurchaseLineRow>, String>(
  (ref, id) => ref.watch(accountingProvider).purchaseLines(id),
);

enum _Tab { invoices, suppliers }

/// Purchases: supplier invoices and the suppliers list. Everyone can enter
/// invoices; totals and supplier balances are shown to the owner only.
class PurchasesScreen extends ConsumerStatefulWidget {
  const PurchasesScreen({super.key});

  @override
  ConsumerState<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen> {
  var _tab = _Tab.invoices;
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final owner = ref.watch(requireSessionProvider).isOwner;
    final currency = ref.watch(currencyProvider);
    final ledger = ref.watch(supplierLedgerProvider).value ?? SupplierLedger();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: l.purchasesTitle,
          actions: [
            if (owner && ledger.totalOwed > 0)
              StatusChip(
                label: '${l.balanceOwed}: ${formatMoney(ledger.totalOwed, currency)}',
                tone: StatusTone.warning,
              ),
            GlassPillButton(
              label: l.addSupplier,
              icon: DoayaIcons.add,
              size: PillSize.medium,
              onPressed: () async {
                final s = await showAddSupplierDialog(context, ref);
                if (s != null && context.mounted) context.go(Routes.supplier(s.id));
              },
            ),
            SagePillButton(
              label: l.newPurchase,
              icon: DoayaIcons.receive,
              size: PillSize.medium,
              onPressed: () => context.go(Routes.newPurchase),
            ),
          ],
        ),
        Row(
          children: [
            GlassPillButton(
              label: l.tabInvoices,
              selected: _tab == _Tab.invoices,
              onPressed: () => setState(() => _tab = _Tab.invoices),
            ),
            const SizedBox(width: DoayaSpacing.s),
            GlassPillButton(
              label: l.tabSuppliers,
              selected: _tab == _Tab.suppliers,
              onPressed: () => setState(() => _tab = _Tab.suppliers),
            ),
            const Spacer(),
            SizedBox(
              width: DoayaSizes.desktopSearchWidth,
              child: GlassSearchField(hint: l.search, onChanged: (v) => setState(() => _query = v)),
            ),
          ],
        ),
        const SizedBox(height: DoayaSpacing.l),
        Expanded(
          child: _tab == _Tab.invoices
              ? PurchaseList(query: _query)
              : _SupplierList(query: _query, ledger: ledger, owner: owner),
        ),
      ],
    );
  }
}

/// Purchase invoices, newest first (optionally of one supplier).
class PurchaseList extends ConsumerWidget {
  const PurchaseList({super.key, this.supplierId, this.query = '', this.shrinkWrap = false});

  final String? supplierId;
  final String query;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final owner = ref.watch(requireSessionProvider).isOwner;
    final currency = ref.watch(currencyProvider);
    final suppliers = {
      for (final s in ref.watch(suppliersProvider).value ?? const <SupplierRow>[]) s.id: s,
    };
    final employees = {
      for (final e in ref.watch(allEmployeesProvider).value ?? const <EmployeeRow>[]) e.id: e,
    };
    final q = toLatinDigits(query.trim());
    final list = (ref.watch(purchasesListProvider(supplierId)).value ?? const <PurchaseRow>[])
        .where(
          (p) =>
              q.isEmpty ||
              (suppliers[p.supplierId]?.name.contains(q) ?? false) ||
              (p.supplierInvoiceNo?.contains(q) ?? false),
        )
        .toList();
    if (list.isEmpty) return EmptyHint(l.noPurchases);

    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: DoayaSpacing.s),
      itemBuilder: (context, i) {
        final p = list[i];
        final who = employees[p.employeeId]?.name ?? l.none;
        final parts = [
          '${formatDate(p.occurredAt)}، ${formatTime(p.occurredAt)}',
          if (p.supplierInvoiceNo != null) '${l.colInvoiceNo}: ${p.supplierInvoiceNo}',
          l.purchaseBy(who),
        ];
        return CaseRow(
          initials: initialsOf(suppliers[p.supplierId]?.name ?? '?'),
          title: suppliers[p.supplierId]?.name ?? l.none,
          subtitle: parts.join('، '),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _purchasePaymentChip(l, p),
              if (owner) ...[
                const SizedBox(width: DoayaSpacing.sm),
                Text(formatMoney(p.totalMinor, currency), style: DoayaTypography.label),
              ],
            ],
          ),
          onTap: () => showPurchaseDetail(context, p),
        );
      },
    );
  }
}

StatusChip _purchasePaymentChip(AppLocalizations l, PurchaseRow p) {
  if (p.payment == PurchasePayment.credit.wire) {
    return StatusChip(label: l.payCredit, tone: StatusTone.warning);
  }
  return StatusChip(
    label: '${l.payCash}، ${p.paidFrom == PaidFrom.drawer.wire ? l.fromDrawer : l.fromOutside}',
    tone: StatusTone.accent,
  );
}

/// Read-only view of one purchase invoice. Prices only for the owner.
Future<void> showPurchaseDetail(BuildContext context, PurchaseRow p) {
  final l = AppLocalizations.of(context);
  return showDoayaDialog<void>(
    context: context,
    title: l.newPurchase,
    maxWidth: DoayaSizes.wideFormWidth,
    content: _PurchaseDetail(purchase: p),
    actions: [GlassPillButton(label: l.close, onPressed: () => Navigator.of(context).pop())],
  );
}

class _PurchaseDetail extends ConsumerWidget {
  const _PurchaseDetail({required this.purchase});

  final PurchaseRow purchase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final owner = ref.watch(requireSessionProvider).isOwner;
    final currency = ref.watch(currencyProvider);
    final products = ref.watch(productsByIdProvider);
    final lines = ref.watch(_purchaseLinesProvider(purchase.id)).value ?? const [];
    final secondary = DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary);

    Widget amountRow(String label, int minor, {bool signed = false}) => Padding(
      padding: const EdgeInsets.only(top: DoayaSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: secondary)),
          Text(
            signed ? formatSignedMoney(minor, currency) : formatMoney(minor, currency),
            style: DoayaTypography.label,
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: DoayaSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LatinText(
                        products[line.productId]?.tradeName ?? l.none,
                        style: DoayaTypography.label,
                      ),
                      Text(
                        [
                          '${l.colQty}: ${formatQty(line.quantity)} '
                              '${line.piecesPerUnit == 1 && (products[line.productId]?.unitsPerPack ?? 1) > 1 ? l.unitStrip : l.unitBox}',
                          if (line.bonus > 0) '${l.colBonus}: ${formatQty(line.bonus)}',
                          if (line.expiry != null) '${l.colExpiry}: ${formatDate(line.expiry!)}',
                        ].join('، '),
                        style: secondary,
                      ),
                    ],
                  ),
                ),
                if (owner)
                  Text(formatMoney(line.costMinor, currency), style: DoayaTypography.label),
              ],
            ),
          ),
        if (owner) ...[
          const Divider(color: DoayaColors.divider),
          amountRow(l.gross, purchase.grossMinor),
          if (purchase.lineDiscountsMinor > 0)
            amountRow(l.lineDiscounts, -purchase.lineDiscountsMinor, signed: true),
          if (purchase.invoiceDiscountMinor > 0)
            amountRow(l.invoiceDiscountLabel, -purchase.invoiceDiscountMinor, signed: true),
          if (purchase.transportMinor > 0) amountRow(l.transportLabel, purchase.transportMinor),
          amountRow(l.purchaseTotal, purchase.totalMinor),
        ],
      ],
    );
  }
}

class _SupplierList extends ConsumerWidget {
  const _SupplierList({required this.query, required this.ledger, required this.owner});

  final String query;
  final SupplierLedger ledger;
  final bool owner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    final q = toLatinDigits(query.trim());
    final list =
        (ref.watch(suppliersProvider).value ?? const <SupplierRow>[])
            .where(
              (s) =>
                  q.isEmpty ||
                  s.name.contains(q) ||
                  (s.repName?.contains(q) ?? false) ||
                  (s.phone?.contains(q) ?? false),
            )
            .toList()
          ..sort((a, b) => ledger.balance(b.id).compareTo(ledger.balance(a.id)));
    if (list.isEmpty) return EmptyHint(l.noSuppliers);

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: DoayaSpacing.s),
      itemBuilder: (context, i) {
        final s = list[i];
        final bal = ledger.balance(s.id);
        return CaseRow(
          initials: initialsOf(s.name),
          title: s.name,
          subtitle: [?s.repName, ?s.phone].join('، '),
          trailing: owner
              ? StatusChip(
                  label: bal > 0 ? formatMoney(bal, currency) : l.settled,
                  tone: bal > 0 ? StatusTone.warning : StatusTone.neutral,
                )
              : null,
          onTap: () => context.go(Routes.supplier(s.id)),
        );
      },
    );
  }
}

/// New-supplier dialog; returns the created supplier.
Future<SupplierRow?> showAddSupplierDialog(
  BuildContext context,
  WidgetRef ref, {
  String initialName = '',
}) async {
  final l = AppLocalizations.of(context);
  final form = GlobalKey<FormState>();
  final name = TextEditingController(text: initialName);
  final rep = TextEditingController();
  final phone = TextEditingController();
  void submit() {
    if (form.currentState!.validate()) Navigator.of(context).pop(true);
  }

  final ok = await showDoayaDialog<bool>(
    context: context,
    title: l.addSupplier,
    content: Form(
      key: form,
      child: Column(
        children: [
          GlassTextField(
            label: l.supplierNameLabel,
            controller: name,
            autofocus: true,
            validator: (v) => (v ?? '').trim().isEmpty ? l.required : null,
          ),
          const SizedBox(height: DoayaSpacing.l),
          GlassTextField(label: '${l.repNameLabel} (${l.optional})', controller: rep),
          const SizedBox(height: DoayaSpacing.l),
          GlassTextField(
            label: '${l.phoneLabel} (${l.optional})',
            controller: phone,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            onSubmitted: (_) => submit(),
          ),
        ],
      ),
    ),
    actions: [
      GlassPillButton(label: l.cancel, onPressed: () => Navigator.of(context).pop(false)),
      SagePillButton(label: l.save, size: PillSize.small, onPressed: submit),
    ],
  );
  if (ok != true) return null;
  return ref
      .read(accountingProvider)
      .addSupplier(name: name.text, repName: rep.text, phone: toLatinDigits(phone.text));
}

/// Supplier picker with search and "new supplier".
Future<SupplierRow?> showSupplierPicker(BuildContext context) => showDialog<SupplierRow>(
  context: context,
  useRootNavigator: false,
  barrierColor: DoayaColors.scrim,
  builder: (_) => const _SupplierPicker(),
);

class _SupplierPicker extends ConsumerStatefulWidget {
  const _SupplierPicker();

  @override
  ConsumerState<_SupplierPicker> createState() => _SupplierPickerState();
}

class _SupplierPickerState extends ConsumerState<_SupplierPicker> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final all = ref.watch(suppliersProvider).value ?? const <SupplierRow>[];
    final q = toLatinDigits(_query.trim());
    final list = q.isEmpty
        ? all
        : all.where((s) => s.name.contains(q) || (s.repName?.contains(q) ?? false)).toList();

    return Dialog(
      backgroundColor: DoayaColors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: DoayaSizes.dialogWidth,
          maxHeight: DoayaSizes.formWidth,
        ),
        child: GlassSurface(
          tone: SurfaceTone.strong,
          blur: true,
          borderRadius: BorderRadius.circular(DoayaRadii.hero),
          padding: const EdgeInsets.all(DoayaSpacing.huge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.chooseSupplier, style: DoayaTypography.titleSmall),
              const SizedBox(height: DoayaSpacing.l),
              GlassSearchField(
                hint: l.search,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                onSubmitted: (_) {
                  if (list.length == 1) Navigator.of(context).pop(list.first);
                },
              ),
              const SizedBox(height: DoayaSpacing.ml),
              Expanded(
                child: list.isEmpty
                    ? EmptyHint(l.noSuppliers)
                    : ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: DoayaSpacing.s),
                        itemBuilder: (context, i) {
                          final s = list[i];
                          return CaseRow(
                            initials: initialsOf(s.name),
                            title: s.name,
                            subtitle: s.repName ?? '',
                            onTap: () => Navigator.of(context).pop(s),
                          );
                        },
                      ),
              ),
              const SizedBox(height: DoayaSpacing.ml),
              GlassPillButton(
                label: l.addSupplier,
                icon: DoayaIcons.add,
                expand: true,
                onPressed: () async {
                  final created = await showAddSupplierDialog(context, ref, initialName: _query);
                  if (created != null && context.mounted) Navigator.of(context).pop(created);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
