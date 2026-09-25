import 'dart:async';

import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../format.dart';
import '../widgets.dart';
import 'debts_screen.dart' show showAddCustomerDialog;

/// Point of sale.
///
/// Keyboard-first: the search field keeps focus; a barcode scanner types the
/// code + Enter, which adds the product. Enter on an empty field completes the
/// sale. F2 = focus search, F8 = toggle debt.
class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _CartItem {
  _CartItem(this.product, this.quantity);
  final ProductRow product;
  int quantity;
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  final _cart = <_CartItem>[];
  List<ProductRow> _results = const [];
  var _payment = PaymentType.cash;
  CustomerRow? _customer;
  var _registered = false;
  var _busy = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocus.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ─── Search & add ───────────────────────────────────────────────────────

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () async {
      final r = await ref.read(catalogProvider).search(q);
      if (mounted) setState(() => _results = r);
    });
  }

  Future<void> _onSubmitted(String raw) async {
    // A scanner types + Enter faster than the search debounce: drop it so
    // stale results don't reappear after the field is cleared.
    _debounce?.cancel();
    final q = raw.trim();
    if (q.isEmpty) {
      await _complete();
      return;
    }
    final catalog = ref.read(catalogProvider);
    final byCode = await catalog.byBarcode(q);
    if (!mounted) return;
    if (byCode != null) {
      _add(byCode);
    } else {
      final results = await catalog.search(q);
      if (!mounted) return;
      if (results.isNotEmpty) {
        _add(results.first);
      } else {
        toast(context, AppLocalizations.of(context).barcodeNotFound(q), error: true);
      }
    }
    _search.clear();
    setState(() => _results = const []);
    _searchFocus.requestFocus();
  }

  int _onHand(String productId) => ref.read(stockProvider).value?.onHand(productId) ?? 0;

  void _add(ProductRow p) {
    final l = AppLocalizations.of(context);
    final existing = _cart.where((c) => c.product.id == p.id).firstOrNull;
    final wanted = (existing?.quantity ?? 0) + 1;
    if (wanted > _onHand(p.id)) {
      toast(context, l.errStock, error: true);
      if (_onHand(p.id) <= 0) _showAlternatives(p);
      return;
    }
    setState(() {
      if (existing != null) {
        existing.quantity = wanted;
      } else {
        _cart.add(_CartItem(p, 1));
      }
    });
  }

  void _setQty(_CartItem item, int q) {
    setState(() {
      if (q <= 0) {
        _cart.remove(item);
      } else if (q <= _onHand(item.product.id)) {
        item.quantity = q;
      }
    });
    _searchFocus.requestFocus();
  }

  Future<void> _showAlternatives(ProductRow p) async {
    final l = AppLocalizations.of(context);
    final stock = ref.read(stockProvider).value;
    final currency = ref.read(currencyProvider);
    final alts = (await ref.read(catalogProvider).alternatives(p))
        .where((a) => (stock?.onHand(a.id) ?? 0) > 0)
        .toList();
    if (!mounted) return;
    await showDoayaDialog<void>(
      context: context,
      title: l.alternativesTitle,
      content: alts.isEmpty
          ? EmptyHint(l.noAlternatives)
          : Column(
              children: [
                for (final a in alts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: DoayaSpacing.sm),
                    child: _ResultRow(
                      product: a,
                      onHand: stock?.onHand(a.id) ?? 0,
                      price: formatMoney(a.priceMinor, currency),
                      addLabel: l.addToCart,
                      onAdd: () {
                        Navigator.of(context).pop();
                        _add(a);
                      },
                    ),
                  ),
              ],
            ),
      actions: [GlassPillButton(label: l.close, onPressed: () => Navigator.of(context).pop())],
    );
    _searchFocus.requestFocus();
  }

  // ─── Payment & customer ─────────────────────────────────────────────────

  Future<void> _toggleDebt() async {
    if (_payment == PaymentType.debt) {
      setState(() => _payment = PaymentType.cash);
      return;
    }
    setState(() {
      _payment = PaymentType.debt;
      _registered = true;
    });
    if (_customer == null) await _pickCustomer();
  }

  Future<void> _pickCustomer() async {
    final picked = await showDialog<CustomerRow>(
      context: context,
      barrierColor: DoayaColors.scrim,
      builder: (_) => const _CustomerPicker(),
    );
    if (picked != null) setState(() => _customer = picked);
    _searchFocus.requestFocus();
  }

  // ─── Complete ───────────────────────────────────────────────────────────

  Future<void> _complete() async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    final currency = ref.read(currencyProvider);
    setState(() => _busy = true);
    try {
      final sale = await ref
          .read(ledgerProvider)
          .sell(
            ref.read(requireSessionProvider).stamp,
            cart: [
              for (final c in _cart)
                CartLine(
                  productId: c.product.id,
                  quantity: c.quantity,
                  unitPrice: Money(c.product.priceMinor, currency),
                ),
            ],
            currency: currency,
            payment: _payment,
            customerId: _registered ? _customer?.id : null,
          );
      if (!mounted) return;
      toast(context, l.saleDone(formatMoney(sale.totalMinor, currency)));
      setState(() {
        _cart.clear();
        _payment = PaymentType.cash;
        _customer = null;
        _registered = false;
      });
    } on SaleException catch (e) {
      if (mounted) toast(context, saleErrorText(l, e.code), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
      _searchFocus.requestFocus();
    }
  }

  // ─── UI ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    final stock = ref.watch(stockProvider).value;
    final now = ref.watch(clockProvider)();
    final window = ref.watch(nearExpiryWindowProvider);
    final subtotal = _cart.fold<int>(0, (s, c) => s + c.product.priceMinor * c.quantity);

    String? nudgeFor(String productId) {
      final near = stock?.nearExpiry(now, window, productId: productId) ?? const [];
      if (near.isEmpty) return null;
      final b = near.first;
      return l.nearExpiryNudge(formatQty(b.quantity), formatDate(b.expiry!));
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f2): _searchFocus.requestFocus,
        const SingleActivator(LogicalKeyboardKey.f8): _toggleDebt,
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: l.posTitle,
                  actions: [StatusChip(label: l.scannerReady, dot: true)],
                ),
                GlassSearchField(
                  hint: l.posSearchHint,
                  controller: _search,
                  focusNode: _searchFocus,
                  emphasized: true,
                  height: DoayaSizes.inputBar,
                  onChanged: _onSearchChanged,
                  onSubmitted: _onSubmitted,
                  trailing: const Padding(
                    padding: EdgeInsetsDirectional.only(end: DoayaSpacing.ml),
                    child: Icon(DoayaIcons.barcode, color: DoayaColors.accent),
                  ),
                ),
                const SizedBox(height: DoayaSpacing.l),
                Expanded(
                  child: ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: DoayaSpacing.sm),
                    itemBuilder: (context, i) {
                      final p = _results[i];
                      final onHand = stock?.onHand(p.id) ?? 0;
                      return _ResultRow(
                        product: p,
                        onHand: onHand,
                        price: formatMoney(p.priceMinor, currency),
                        addLabel: onHand > 0 ? l.addToCart : l.showAlternatives,
                        nudge: nudgeFor(p.id),
                        prescriptionLabel: p.prescriptionOnly ? l.prescriptionOnly : null,
                        onAdd: () {
                          if (onHand > 0) {
                            _add(p);
                            _search.clear();
                            setState(() => _results = const []);
                          } else {
                            _showAlternatives(p);
                          }
                          _searchFocus.requestFocus();
                        },
                      );
                    },
                  ),
                ),
                _ShortcutsBar(l: l),
              ],
            ),
          ),
          const SizedBox(width: DoayaSpacing.huge),
          SizedBox(
            width: DoayaSizes.invoiceWidth,
            child: _Invoice(
              l: l,
              currency: currency,
              items: _cart,
              subtotal: subtotal,
              payment: _payment,
              registered: _registered,
              customer: _customer,
              busy: _busy,
              nudgeFor: nudgeFor,
              onQty: _setQty,
              onRegistered: (r) => setState(() {
                _registered = r;
                if (!r) {
                  _customer = null;
                  _payment = PaymentType.cash;
                }
              }),
              onPickCustomer: _pickCustomer,
              onPayment: (p) => p == PaymentType.debt
                  ? _toggleDebt()
                  : setState(() => _payment = PaymentType.cash),
              onComplete: _complete,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.product,
    required this.onHand,
    required this.price,
    required this.addLabel,
    required this.onAdd,
    this.nudge,
    this.prescriptionLabel,
  });

  final ProductRow product;
  final int onHand;
  final String price;
  final String addLabel;
  final VoidCallback onAdd;
  final String? nudge;
  final String? prescriptionLabel;

  @override
  Widget build(BuildContext context) {
    final out = onHand <= 0;
    return GlassSurface(
      shadow: false,
      borderRadius: BorderRadius.circular(DoayaRadii.cardLarge),
      padding: const EdgeInsets.symmetric(horizontal: DoayaSpacing.xl, vertical: DoayaSpacing.ml),
      child: Row(
        children: [
          Container(
            width: DoayaSizes.productThumb,
            height: DoayaSizes.productThumb,
            decoration: BoxDecoration(
              color: DoayaColors.imageWell,
              borderRadius: BorderRadius.circular(DoayaRadii.imageWell),
            ),
            child: Icon(
              DoayaIcons.medicine,
              color: out ? DoayaColors.textSecondary : DoayaColors.accent,
            ),
          ),
          const SizedBox(width: DoayaSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductName(product: product, muted: out),
                if (nudge != null) ...[
                  const SizedBox(height: DoayaSpacing.xs),
                  StatusChip(label: nudge!, tone: StatusTone.warning, icon: DoayaIcons.expiry),
                ],
              ],
            ),
          ),
          if (prescriptionLabel != null) ...[
            StatusChip(label: prescriptionLabel!),
            const SizedBox(width: DoayaSpacing.sm),
          ],
          StockChip(onHand: onHand, threshold: product.lowStockThreshold),
          const SizedBox(width: DoayaSpacing.l),
          SizedBox(
            width: DoayaSizes.priceColumn,
            child: Text(price, style: DoayaTypography.label, textAlign: TextAlign.end),
          ),
          const SizedBox(width: DoayaSpacing.l),
          out
              ? GlassPillButton(label: addLabel, icon: DoayaIcons.swap, onPressed: onAdd)
              : SagePillButton(label: addLabel, size: PillSize.small, onPressed: onAdd),
        ],
      ),
    );
  }
}

class _ShortcutsBar extends StatelessWidget {
  const _ShortcutsBar({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    Widget key(String k, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DoayaSpacing.sm,
            vertical: DoayaSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: DoayaColors.surfaceRaised,
            borderRadius: BorderRadius.circular(DoayaRadii.key),
            border: Border.all(color: DoayaColors.border),
          ),
          child: LatinText(k, style: DoayaTypography.caption),
        ),
        const SizedBox(width: DoayaSpacing.xs),
        Text(label, style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary)),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(top: DoayaSpacing.ml),
      child: Wrap(
        spacing: DoayaSpacing.l,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            l.shortcuts,
            style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
          ),
          key('F2', l.shortcutSearch),
          key('F8', l.shortcutDebt),
          key('Enter', l.shortcutComplete),
        ],
      ),
    );
  }
}

class _Invoice extends StatelessWidget {
  const _Invoice({
    required this.l,
    required this.currency,
    required this.items,
    required this.subtotal,
    required this.payment,
    required this.registered,
    required this.customer,
    required this.busy,
    required this.nudgeFor,
    required this.onQty,
    required this.onRegistered,
    required this.onPickCustomer,
    required this.onPayment,
    required this.onComplete,
  });

  final AppLocalizations l;
  final Currency currency;
  final List<_CartItem> items;
  final int subtotal;
  final PaymentType payment;
  final bool registered;
  final CustomerRow? customer;
  final bool busy;
  final String? Function(String productId) nudgeFor;
  final void Function(_CartItem, int) onQty;
  final ValueChanged<bool> onRegistered;
  final VoidCallback onPickCustomer;
  final ValueChanged<PaymentType> onPayment;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      tone: SurfaceTone.strong,
      borderRadius: BorderRadius.circular(DoayaRadii.hero),
      padding: const EdgeInsets.all(DoayaSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.invoice, style: DoayaTypography.lead),
          const SizedBox(height: DoayaSpacing.l),
          Row(
            children: [
              Expanded(
                child: GlassPillButton(
                  label: l.walkInCustomer,
                  selected: !registered,
                  expand: true,
                  onPressed: () => onRegistered(false),
                ),
              ),
              const SizedBox(width: DoayaSpacing.s),
              Expanded(
                child: GlassPillButton(
                  label: l.registeredCustomer,
                  selected: registered,
                  expand: true,
                  onPressed: () => onRegistered(true),
                ),
              ),
            ],
          ),
          if (registered) ...[
            const SizedBox(height: DoayaSpacing.sm),
            GlassPillButton(
              label: customer?.name ?? l.chooseCustomer,
              icon: DoayaIcons.person,
              selected: customer != null,
              expand: true,
              onPressed: onPickCustomer,
            ),
          ],
          const SizedBox(height: DoayaSpacing.l),
          Expanded(
            child: items.isEmpty
                ? EmptyHint(l.cartEmpty)
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const Divider(color: DoayaColors.divider, height: DoayaSpacing.xl),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      final nudge = nudgeFor(item.product.id);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LatinText(
                                      item.product.tradeName,
                                      maxLines: 1,
                                      style: DoayaTypography.label,
                                    ),
                                    Text(
                                      l.perUnit(formatMoney(item.product.priceMinor, currency)),
                                      style: DoayaTypography.caption.copyWith(
                                        color: DoayaColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _QtyStepper(
                                quantity: item.quantity,
                                onChanged: (q) => onQty(item, q),
                              ),
                            ],
                          ),
                          if (nudge != null) ...[
                            const SizedBox(height: DoayaSpacing.xs),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: StatusChip(
                                label: nudge,
                                tone: StatusTone.warning,
                                icon: DoayaIcons.expiry,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
          ),
          const SizedBox(height: DoayaSpacing.ml),
          GlassSurface(
            shadow: false,
            borderRadius: BorderRadius.circular(DoayaRadii.card),
            padding: const EdgeInsets.all(DoayaSpacing.l),
            child: Column(
              children: [
                _TotalRow(label: l.subtotal, value: formatMoney(subtotal, currency)),
                const Divider(color: DoayaColors.divider),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(child: Text(l.total, style: DoayaTypography.label)),
                    Text(formatMoney(subtotal, currency), style: DoayaTypography.price),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: DoayaSpacing.ml),
          Row(
            children: [
              Expanded(
                child: GlassPillButton(
                  label: l.paymentCash,
                  icon: DoayaIcons.cash,
                  size: PillSize.medium,
                  selected: payment == PaymentType.cash,
                  expand: true,
                  onPressed: () => onPayment(PaymentType.cash),
                ),
              ),
              const SizedBox(width: DoayaSpacing.sm),
              Expanded(
                child: GlassPillButton(
                  label: l.paymentDebt,
                  icon: DoayaIcons.debts,
                  size: PillSize.medium,
                  selected: payment == PaymentType.debt,
                  expand: true,
                  onPressed: () => onPayment(PaymentType.debt),
                ),
              ),
            ],
          ),
          const SizedBox(height: DoayaSpacing.ml),
          SagePillButton(
            label: l.completeSale,
            expand: true,
            onPressed: busy || items.isEmpty ? null : onComplete,
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData icon, VoidCallback onTap) => SizedBox.square(
      dimension: DoayaSizes.qtyButton,
      child: Material(
        color: DoayaColors.subtleFill,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Icon(icon, size: DoayaSizes.iconSidebar),
        ),
      ),
    );
    return GlassSurface(
      shadow: false,
      borderRadius: BorderRadius.circular(DoayaRadii.pill),
      padding: const EdgeInsets.all(DoayaSpacing.xxs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(DoayaIcons.remove, () => onChanged(quantity - 1)),
          SizedBox(
            width: DoayaSpacing.huge + DoayaSpacing.xs,
            child: Text(
              formatQty(quantity),
              textAlign: TextAlign.center,
              style: DoayaTypography.label,
            ),
          ),
          btn(DoayaIcons.add, () => onChanged(quantity + 1)),
        ],
      ),
    );
  }
}

/// Search existing customers or create one.
class _CustomerPicker extends ConsumerStatefulWidget {
  const _CustomerPicker();

  @override
  ConsumerState<_CustomerPicker> createState() => _CustomerPickerState();
}

class _CustomerPickerState extends ConsumerState<_CustomerPicker> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final all = ref.watch(customersProvider).value ?? const [];
    final debts = ref.watch(debtsProvider).value;
    final currency = ref.watch(currencyProvider);
    final q = _query.trim();
    final list = q.isEmpty
        ? all
        : all.where((c) => c.name.contains(q) || (c.phone?.contains(q) ?? false)).toList();

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
              Text(l.chooseCustomer, style: DoayaTypography.titleSmall),
              const SizedBox(height: DoayaSpacing.l),
              GlassSearchField(
                hint: l.search,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: DoayaSpacing.ml),
              Expanded(
                child: list.isEmpty
                    ? EmptyHint(l.noCustomers)
                    : ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: DoayaSpacing.s),
                        itemBuilder: (context, i) {
                          final c = list[i];
                          final bal = debts?.balance(c.id) ?? 0;
                          return CaseRow(
                            initials: initialsOf(c.name),
                            title: c.name,
                            subtitle: bal > 0
                                ? l.owes(formatMoney(bal, currency))
                                : (c.phone ?? l.settled),
                            onTap: () => Navigator.of(context).pop(c),
                          );
                        },
                      ),
              ),
              const SizedBox(height: DoayaSpacing.ml),
              GlassPillButton(
                label: l.newCustomer,
                icon: DoayaIcons.customer,
                expand: true,
                onPressed: () async {
                  final created = await showAddCustomerDialog(context, ref, initialName: _query);
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
