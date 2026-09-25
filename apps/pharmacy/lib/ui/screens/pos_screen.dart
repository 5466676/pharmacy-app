import 'dart:async';

import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
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
  _CartItem(this.product, this.quantity, {required this.strip});
  final ProductRow product;
  int quantity;

  /// Selling single strips instead of whole boxes.
  final bool strip;

  int get piecesPerUnit => strip ? 1 : (product.unitsPerPack < 1 ? 1 : product.unitsPerPack);
  int get unitPriceMinor =>
      strip ? (product.stripPriceMinor ?? product.priceMinor) : product.priceMinor;
  int get pieces => quantity * piecesPerUnit;
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
  final _discount = TextEditingController();
  final _tendered = TextEditingController();

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
    _discount.dispose();
    _tendered.dispose();
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

  /// Pieces of [productId] already in the cart (boxes + strips).
  int _piecesInCart(String productId, {_CartItem? except}) =>
      _cart.where((c) => c.product.id == productId && c != except).fold(0, (s, c) => s + c.pieces);

  void _add(ProductRow p, {bool strip = false}) {
    final l = AppLocalizations.of(context);
    final asStrip = strip && p.unitsPerPack > 1;
    final existing = _cart.where((c) => c.product.id == p.id && c.strip == asStrip).firstOrNull;
    final item = existing ?? _CartItem(p, 0, strip: asStrip);
    if (_piecesInCart(p.id) + item.piecesPerUnit > _onHand(p.id)) {
      toast(context, l.errStock, error: true);
      if (_onHand(p.id) <= 0) _showAlternatives(p);
      return;
    }
    setState(() {
      item.quantity++;
      if (existing == null) _cart.add(item);
    });
  }

  void _setQty(_CartItem item, int q) {
    setState(() {
      if (q <= 0) {
        _cart.remove(item);
      } else if (_piecesInCart(item.product.id, except: item) + q * item.piecesPerUnit <=
          _onHand(item.product.id)) {
        item.quantity = q;
      } else {
        toast(context, AppLocalizations.of(context).errStock, error: true);
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
    final picked = await showCustomerPicker(context);
    if (picked != null) setState(() => _customer = picked);
    _searchFocus.requestFocus();
  }

  // ─── Complete ───────────────────────────────────────────────────────────

  Future<void> _openTill() async {
    final l = AppLocalizations.of(context);
    final currency = ref.read(currencyProvider);
    final r = await askAmount(
      context,
      title: l.openTill,
      label: l.openingFloatLabel(currency.symbol),
      currency: currency,
      initial: '0',
    );
    if (r != null) {
      await ref
          .read(tillProvider)
          .openShift(ref.read(requireSessionProvider).stamp, floatMinor: r.$1);
    }
    _searchFocus.requestFocus();
  }

  int _discountMinor(Currency c) => Money.tryParse(_discount.text, c)?.minor ?? 0;
  int? _tenderedMinor(Currency c) =>
      _tendered.text.trim().isEmpty ? null : Money.tryParse(_tendered.text, c)?.minor;

  Future<void> _complete() async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    final currency = ref.read(currencyProvider);
    if (ref.read(currentShiftProvider).value == null) {
      await _openTill();
      return;
    }
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
                  unitPrice: Money(c.unitPriceMinor, currency),
                  piecesPerUnit: c.piecesPerUnit,
                ),
            ],
            currency: currency,
            payment: _payment,
            customerId: _registered ? _customer?.id : null,
            discountMinor: _discountMinor(currency),
            tenderedMinor: _tenderedMinor(currency),
          );
      if (!mounted) return;
      final change = sale.changeMinor;
      toast(
        context,
        change != null && change > 0
            ? '${l.saleDone(formatMoney(sale.totalMinor, currency))}، '
                  '${l.changeDue}: ${formatMoney(change, currency)}'
            : l.saleDone(formatMoney(sale.totalMinor, currency)),
      );
      _discount.clear();
      _tendered.clear();
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
    final subtotal = _cart.fold<int>(0, (s, c) => s + c.unitPriceMinor * c.quantity);

    String? nudgeFor(String productId) {
      final near = stock?.nearExpiry(now, window, productId: productId) ?? const [];
      if (near.isEmpty) return null;
      final b = near.first;
      final p = ref.read(productsByIdProvider)[productId];
      return l.nearExpiryNudge(
        formatStock(l, b.quantity, p?.unitsPerPack ?? 1),
        formatDate(b.expiry!),
      );
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
                  actions: [
                    StatusChip(label: l.scannerReady, dot: true),
                    GlassPillButton(
                      label: l.returnsButton,
                      icon: DoayaIcons.returns,
                      onPressed: () => context.go(Routes.returns),
                    ),
                  ],
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
                        addLabel: onHand <= 0
                            ? l.showAlternatives
                            : (p.unitsPerPack > 1 ? l.addBox : l.addToCart),
                        nudge: nudgeFor(p.id),
                        prescriptionLabel: p.prescriptionOnly ? l.prescriptionOnly : null,
                        stripLabel: p.unitsPerPack > 1 && onHand > 0 ? l.addStrip : null,
                        onAddStrip: () {
                          _add(p, strip: true);
                          _search.clear();
                          setState(() => _results = const []);
                          _searchFocus.requestFocus();
                        },
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
              onPayment: (p) =>
                  p == PaymentType.debt ? _toggleDebt() : setState(() => _payment = p),
              onComplete: _complete,
              discount: _discount,
              tendered: _tendered,
              discountMinor: _discountMinor(currency),
              tenderedMinor: _tenderedMinor(currency),
              onAmountsChanged: () => setState(() {}),
              tillOpen: ref.watch(currentShiftProvider).value != null,
              onOpenTill: _openTill,
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
    this.stripLabel,
    this.onAddStrip,
  });

  final ProductRow product;
  final int onHand;
  final String price;
  final String addLabel;
  final VoidCallback onAdd;
  final String? nudge;
  final String? prescriptionLabel;
  final String? stripLabel;
  final VoidCallback? onAddStrip;

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
          StockChip(product: product, onHand: onHand),
          const SizedBox(width: DoayaSpacing.l),
          SizedBox(
            width: DoayaSizes.priceColumn,
            child: Text(price, style: DoayaTypography.label, textAlign: TextAlign.end),
          ),
          const SizedBox(width: DoayaSpacing.l),
          if (stripLabel != null) ...[
            GlassPillButton(label: stripLabel!, onPressed: onAddStrip),
            const SizedBox(width: DoayaSpacing.s),
          ],
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
    required this.discount,
    required this.tendered,
    required this.discountMinor,
    required this.tenderedMinor,
    required this.onAmountsChanged,
    required this.tillOpen,
    required this.onOpenTill,
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
  final TextEditingController discount;
  final TextEditingController tendered;
  final int discountMinor;
  final int? tenderedMinor;
  final VoidCallback onAmountsChanged;
  final bool tillOpen;
  final VoidCallback onOpenTill;

  @override
  Widget build(BuildContext context) {
    final total = subtotal - discountMinor;
    final change = payment == PaymentType.cash && tenderedMinor != null
        ? tenderedMinor! - total
        : null;
    final invalid = discountMinor > subtotal || (change != null && change < 0);
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
                                      item.strip
                                          ? l.perStrip(formatMoney(item.unitPriceMinor, currency))
                                          : l.perUnit(formatMoney(item.unitPriceMinor, currency)),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GlassTextField(
                  label: l.discountLabel(currency.symbol),
                  controller: discount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => onAmountsChanged(),
                ),
              ),
              if (payment == PaymentType.cash) ...[
                const SizedBox(width: DoayaSpacing.sm),
                Expanded(
                  child: GlassTextField(
                    label: l.tenderedLabel(currency.symbol),
                    controller: tendered,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => onAmountsChanged(),
                    // Keyboard-first: type the amount received, press Enter.
                    onSubmitted: (_) {
                      if (tillOpen && !busy && items.isNotEmpty && !invalid) onComplete();
                    },
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: DoayaSpacing.sm),
          GlassSurface(
            shadow: false,
            borderRadius: BorderRadius.circular(DoayaRadii.card),
            padding: const EdgeInsets.symmetric(
              horizontal: DoayaSpacing.l,
              vertical: DoayaSpacing.ml,
            ),
            child: Column(
              children: [
                _TotalRow(label: l.subtotal, value: formatMoney(subtotal, currency)),
                if (discountMinor > 0)
                  _TotalRow(label: l.discount, value: formatSignedMoney(-discountMinor, currency)),
                const Divider(color: DoayaColors.divider),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(child: Text(l.total, style: DoayaTypography.label)),
                    Text(formatMoney(total, currency), style: DoayaTypography.price),
                  ],
                ),
                if (change != null)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          change < 0 ? l.errTendered : l.changeDue,
                          style: DoayaTypography.bodySmall.copyWith(
                            color: change < 0 ? DoayaColors.dangerText : DoayaColors.accent,
                          ),
                        ),
                      ),
                      if (change >= 0)
                        Text(
                          formatMoney(change, currency),
                          style: DoayaTypography.titleSmall.copyWith(color: DoayaColors.accent),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: DoayaSpacing.sm),
          Row(
            children: [
              for (final (p, label, icon) in [
                (PaymentType.cash, l.paymentCash, DoayaIcons.cash),
                (PaymentType.debt, l.paymentDebt, DoayaIcons.debts),
                (PaymentType.transfer, l.paymentTransfer, DoayaIcons.transfer),
              ]) ...[
                if (p != PaymentType.cash) const SizedBox(width: DoayaSpacing.s),
                Expanded(
                  child: _maybeTooltip(
                    p == PaymentType.transfer ? l.paymentTransferHint : null,
                    GlassPillButton(
                      label: label,
                      icon: icon,
                      size: PillSize.medium,
                      selected: payment == p,
                      expand: true,
                      onPressed: () => onPayment(p),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: DoayaSpacing.sm),
          if (tillOpen)
            SagePillButton(
              label: l.completeSale,
              expand: true,
              onPressed: busy || items.isEmpty || invalid ? null : onComplete,
            )
          else
            NoticeBanner(
              message: l.tillClosedBanner,
              icon: DoayaIcons.cash,
              action: SagePillButton(
                label: l.openTill,
                size: PillSize.medium,
                expand: true,
                onPressed: onOpenTill,
              ),
            ),
        ],
      ),
    );
  }
}

Widget _maybeTooltip(String? message, Widget child) =>
    message == null ? child : Tooltip(message: message, child: child);

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

/// Search existing customers or create one. Returns the chosen customer.
Future<CustomerRow?> showCustomerPicker(BuildContext context) => showDialog<CustomerRow>(
  context: context,
  useRootNavigator: false,
  barrierColor: DoayaColors.scrim,
  builder: (_) => const _CustomerPicker(),
);

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
