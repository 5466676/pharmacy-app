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
import 'purchases_screen.dart' show showSupplierPicker;

/// One invoice line being typed.
class _Line {
  _Line(this.product, {required this.strip, required String salePrice})
    : sale = TextEditingController(text: salePrice);

  final ProductRow product;

  /// Bought as loose strips instead of boxes.
  final bool strip;
  final qty = TextEditingController(text: '1');
  final bonus = TextEditingController();
  final price = TextEditingController();
  final discount = TextEditingController();
  final expiry = TextEditingController();
  final TextEditingController sale;
  final qtyFocus = FocusNode();

  /// Owner-only hint: cheapest / last price seen for this product.
  String? hint;

  int get piecesPerUnit => strip ? 1 : (product.unitsPerPack < 1 ? 1 : product.unitsPerPack);

  /// The typed line, or null while something is missing or wrong.
  PurchaseItem? item(Currency c) {
    final q = _int(qty.text);
    final b = bonus.text.trim().isEmpty ? 0 : _int(bonus.text);
    final p = Money.tryParse(price.text, c);
    final d = discount.text.trim().isEmpty
        ? 0.0
        : double.tryParse(toLatinDigits(discount.text.trim()));
    final e = expiry.text.trim().isEmpty ? null : parseDate(expiry.text);
    if (q == null || b == null || p == null || d == null || d < 0 || d > 100) return null;
    if (q + b <= 0 || (expiry.text.trim().isNotEmpty && e == null)) return null;
    return PurchaseItem(
      productId: product.id,
      quantity: q,
      bonus: b,
      unitPriceMinor: p.minor,
      piecesPerUnit: piecesPerUnit,
      discountBasisPoints: (d * 100).round(),
      expiry: e,
    );
  }

  static int? _int(String s) {
    final v = int.tryParse(toLatinDigits(s.trim()));
    return v == null || v < 0 ? null : v;
  }

  void dispose() {
    for (final c in [qty, bonus, price, discount, expiry, sale]) {
      c.dispose();
    }
    qtyFocus.dispose();
  }
}

/// Purchase invoice entry: supplier, lines (quantity, bonus, price, discount,
/// expiry, new sale price), invoice discount and transport, cash or credit.
class PurchaseFormScreen extends ConsumerStatefulWidget {
  const PurchaseFormScreen({super.key, this.supplierId, this.orderId});

  final String? supplierId;

  /// A purchase order being received: its supplier and lines are filled in,
  /// and it's marked received when the invoice is saved.
  final String? orderId;

  @override
  ConsumerState<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends ConsumerState<PurchaseFormScreen> {
  SupplierRow? _supplier;
  final _invoiceNo = TextEditingController();
  final _invoiceDiscount = TextEditingController();
  final _transport = TextEditingController();
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  final _lines = <_Line>[];
  List<ProductRow> _results = const [];
  Timer? _debounce;
  var _payment = PurchasePayment.credit;
  var _paidFrom = PaidFrom.drawer;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
    if (widget.supplierId != null) {
      ref.read(accountingProvider).supplier(widget.supplierId!).then((s) {
        if (mounted) setState(() => _supplier = s);
      });
    }
    if (widget.orderId != null) _loadOrder(widget.orderId!);
  }

  /// F9 saves wherever the focus is (after clicking a button too), unless a
  /// dialog is open on top.
  bool _onKey(KeyEvent e) {
    if (e is! KeyDownEvent || e.logicalKey != LogicalKeyboardKey.f9) return false;
    if (_busy || ModalRoute.of(context)?.isCurrent != true) return false;
    _save();
    return true;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _debounce?.cancel();
    for (final c in [_invoiceNo, _invoiceDiscount, _transport, _search]) {
      c.dispose();
    }
    _searchFocus.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  Future<void> _loadOrder(String orderId) async {
    final acc = ref.read(accountingProvider);
    final order = await acc.order(orderId);
    if (order == null) return;
    final supplier = await acc.supplier(order.supplierId);
    final lines = await acc.orderLines(orderId);
    final catalog = ref.read(catalogProvider);
    if (!mounted) return;
    setState(() => _supplier = supplier);
    for (final x in lines) {
      final p = await catalog.byId(x.productId);
      if (p == null || !mounted) continue;
      await _add(p, strip: false, quantity: x.quantity);
    }
  }

  Future<void> _runSearch(String q) async {
    final r = q.trim().isEmpty ? const <ProductRow>[] : await ref.read(catalogProvider).search(q);
    if (mounted) setState(() => _results = r);
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () => _runSearch(q));
  }

  /// Enter in the search: a barcode scan or the first match adds a box line.
  Future<void> _onSearchSubmitted(String q) async {
    _debounce?.cancel();
    final r = q.trim().isEmpty ? const <ProductRow>[] : await ref.read(catalogProvider).search(q);
    if (!mounted) return;
    if (r.isEmpty) {
      toast(context, AppLocalizations.of(context).barcodeNotFound(q.trim()), error: true);
      return;
    }
    await _add(r.first, strip: false);
  }

  Future<void> _add(ProductRow p, {required bool strip, int quantity = 1}) async {
    final currency = ref.read(currencyProvider);
    final line = _Line(
      p,
      strip: strip,
      salePrice: moneyInput(strip ? (p.stripPriceMinor ?? p.priceMinor) : p.priceMinor, currency),
    );
    line.qty.text = '$quantity';
    setState(() {
      _lines.add(line);
      _results = const [];
      _search.clear();
    });
    line.qtyFocus.requestFocus();
    line.qty.selection = TextSelection(baseOffset: 0, extentOffset: line.qty.text.length);
    await _prefillPrice(line);
  }

  /// Owner only (past purchase prices are owner-only): fills in the last
  /// price from this supplier (else from anyone) for the same unit and shows
  /// the cheapest supplier. Employees type prices from the paper invoice.
  Future<void> _prefillPrice(_Line line) async {
    final l = AppLocalizations.of(context);
    final currency = ref.read(currencyProvider);
    if (!ref.read(requireSessionProvider).isOwner) return;
    final history = (await ref.read(accountingProvider).priceHistory(line.product.id))
        .where((h) => h.piecesPerUnit == line.piecesPerUnit)
        .toList();
    if (!mounted || history.isEmpty) return;
    final mine = history.where((h) => h.supplierId == _supplier?.id).firstOrNull;
    final last = mine ?? history.first;
    if (line.price.text.isEmpty) line.price.text = moneyInput(last.unitPriceMinor, currency);
    final suppliers = {
      for (final s in ref.read(suppliersProvider).value ?? const <SupplierRow>[]) s.id: s.name,
    };
    final best = history.reduce((a, b) => b.unitPriceMinor < a.unitPriceMinor ? b : a);
    line.hint = best.supplierId != last.supplierId && best.unitPriceMinor < last.unitPriceMinor
        ? l.bestPrice(
            formatMoney(best.unitPriceMinor, currency),
            suppliers[best.supplierId] ?? l.none,
          )
        : l.lastPrice(formatMoney(last.unitPriceMinor, currency));
    setState(() {});
  }

  void _remove(_Line line) {
    setState(() => _lines.remove(line));
    line.dispose();
  }

  int _money(TextEditingController c, Currency currency) =>
      c.text.trim().isEmpty ? 0 : (Money.tryParse(c.text, currency)?.minor ?? -1);

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final currency = ref.read(currencyProvider);
    if (_supplier == null) {
      toast(context, l.errNeedSupplier, error: true);
      return;
    }
    if (_lines.isEmpty) {
      toast(context, l.errPurchaseEmpty, error: true);
      return;
    }
    final items = [for (final line in _lines) line.item(currency)];
    final sale = [
      for (final line in _lines)
        line.strip ? null : Money.tryParse(line.sale.text, currency)?.minor,
    ];
    final badSale = [for (var i = 0; i < _lines.length; i++) !_lines[i].strip && sale[i] == null];
    if (items.contains(null) || badSale.contains(true)) {
      toast(context, l.errPurchaseLine, error: true);
      return;
    }
    if (_payment == PurchasePayment.cash &&
        _paidFrom == PaidFrom.drawer &&
        ref.read(currentShiftProvider).value == null) {
      toast(context, l.errDrawerClosed, error: true);
      return;
    }
    final discount = _money(_invoiceDiscount, currency);
    final transport = _money(_transport, currency);
    if (discount < 0 || transport < 0) {
      toast(context, l.invalidNumber, error: true);
      return;
    }
    final newPrices = <String, int>{
      for (var i = 0; i < _lines.length; i++)
        if (!_lines[i].strip && sale[i] != _lines[i].product.priceMinor)
          _lines[i].product.id: sale[i]!,
    };
    setState(() => _busy = true);
    try {
      await ref
          .read(accountingProvider)
          .recordPurchase(
            ref.read(requireSessionProvider).stamp,
            supplierId: _supplier!.id,
            items: items.cast<PurchaseItem>(),
            currency: currency,
            payment: _payment,
            paidFrom: _payment == PurchasePayment.cash ? _paidFrom : null,
            invoiceDiscountMinor: discount,
            transportMinor: transport,
            supplierInvoiceNo: _invoiceNo.text,
            newSalePrices: newPrices,
          );
      if (widget.orderId != null) {
        await ref.read(accountingProvider).setOrderStatus(widget.orderId!, 'received');
      }
      if (!mounted) return;
      toast(context, l.purchaseSaved);
      context.go(Routes.purchases);
    } on PurchaseException catch (e) {
      if (mounted) {
        toast(context, switch (e.code) {
          PurchaseError.empty => l.errPurchaseEmpty,
          PurchaseError.discountTooLarge => l.errPurchaseDiscount,
          PurchaseError.badLine || PurchaseError.cashNeedsSource => l.errPurchaseLine,
        }, error: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    ref.watch(currentShiftProvider); // drawer payments need an open till

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          leading: RoundIconButton(
            icon: DoayaIcons.back,
            tooltip: l.back,
            onPressed: () => context.go(Routes.purchases),
          ),
          title: l.newPurchase,
        ),
        Expanded(
          child: Flex(
            direction: isPhoneLayout(context) ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isPhoneLayout(context)) ...[
                // Phone: lines on top, the summary (and save) under them.
                Expanded(flex: 3, child: _linesPane(l, currency)),
                const SizedBox(height: DoayaSpacing.l),
                Expanded(flex: 2, child: _summary(l, currency)),
              ] else ...[
                Expanded(child: _linesPane(l, currency)),
                const SizedBox(width: DoayaSpacing.huge),
                SizedBox(width: DoayaSizes.invoiceWidth, child: _summary(l, currency)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _linesPane(AppLocalizations l, Currency currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassSearchField(
          hint: l.purchaseSearchHint,
          controller: _search,
          focusNode: _searchFocus,
          autofocus: true,
          onChanged: _onSearchChanged,
          onSubmitted: _onSearchSubmitted,
        ),
        const SizedBox(height: DoayaSpacing.sm),
        Expanded(
          child: ListView(
            children: [
              for (final p in _results.take(6))
                Padding(
                  padding: const EdgeInsets.only(bottom: DoayaSpacing.s),
                  child: GlassSurface(
                    shadow: false,
                    borderRadius: BorderRadius.circular(DoayaRadii.tile),
                    padding: const EdgeInsets.all(DoayaSpacing.ml),
                    child: Row(
                      children: [
                        Expanded(child: ProductName(product: p)),
                        if (p.unitsPerPack > 1) ...[
                          GlassPillButton(label: l.addStrip, onPressed: () => _add(p, strip: true)),
                          const SizedBox(width: DoayaSpacing.s),
                        ],
                        SagePillButton(
                          label: p.unitsPerPack > 1 ? l.addBox : l.add,
                          size: PillSize.small,
                          onPressed: () => _add(p, strip: false),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_results.isNotEmpty) const SizedBox(height: DoayaSpacing.l),
              for (final line in _lines) _lineCard(l, currency, line),
              if (_lines.isEmpty && _results.isEmpty) EmptyHint(l.errPurchaseEmpty),
            ],
          ),
        ),
      ],
    );
  }

  Widget _lineCard(AppLocalizations l, Currency currency, _Line line) {
    final item = line.item(currency);
    final secondary = DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary);
    Widget field(
      String label,
      TextEditingController c, {
      FocusNode? focus,
      String? hint,
      bool decimal = true,
      ValueChanged<String>? onSubmitted,
    }) => Expanded(
      child: GlassTextField(
        label: label,
        hint: hint,
        controller: c,
        focusNode: focus,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        textInputAction: TextInputAction.next,
        onChanged: (_) => setState(() {}),
        onSubmitted: onSubmitted,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: DoayaSpacing.sm),
      child: GlassSurface(
        shadow: false,
        borderRadius: BorderRadius.circular(DoayaRadii.tile),
        padding: const EdgeInsets.all(DoayaSpacing.ml),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: LatinText(
                              line.product.tradeName,
                              maxLines: 1,
                              style: DoayaTypography.label,
                            ),
                          ),
                          const SizedBox(width: DoayaSpacing.sm),
                          StatusChip(label: line.strip ? l.unitStrip : l.unitBox),
                        ],
                      ),
                      if (line.hint != null) Text(line.hint!, style: secondary),
                    ],
                  ),
                ),
                Text(
                  item == null ? '' : formatMoney(item.netMinor, currency),
                  style: DoayaTypography.label,
                ),
                const SizedBox(width: DoayaSpacing.sm),
                RoundIconButton(
                  icon: DoayaIcons.delete,
                  tooltip: l.close,
                  size: DoayaSizes.qtyButton + DoayaSpacing.sm,
                  onPressed: () => _remove(line),
                ),
              ],
            ),
            const SizedBox(height: DoayaSpacing.sm),
            ...() {
              final fields = [
                field(l.colQty, line.qty, focus: line.qtyFocus, decimal: false),
                field(l.colBonus, line.bonus, decimal: false),
                field(l.colUnitPrice, line.price),
                field(l.colDiscountPct, line.discount),
                field(
                  l.colExpiry,
                  line.expiry,
                  hint: l.dateFormatHint,
                  onSubmitted: line.strip ? (_) => _searchFocus.requestFocus() : null,
                ),
                if (!line.strip)
                  field(l.colSalePrice, line.sale, onSubmitted: (_) => _searchFocus.requestFocus()),
              ];
              // Phone: three fields per row.
              final perRow = isPhoneLayout(context) ? 3 : fields.length;
              return [
                for (var i = 0; i < fields.length; i += perRow) ...[
                  if (i > 0) const SizedBox(height: DoayaSpacing.sm),
                  Row(
                    children: [
                      for (final (j, f) in fields.skip(i).take(perRow).indexed) ...[
                        if (j > 0) const SizedBox(width: DoayaSpacing.s),
                        f,
                      ],
                    ],
                  ),
                ],
              ];
            }(),
          ],
        ),
      ),
    );
  }

  Widget _summary(AppLocalizations l, Currency currency) {
    final items = [for (final line in _lines) line.item(currency)].whereType<PurchaseItem>();
    final gross = items.fold(0, (s, i) => s + i.grossMinor);
    final lineDiscounts = items.fold(0, (s, i) => s + i.lineDiscountMinor);
    final discount = _money(_invoiceDiscount, currency).clamp(0, 1 << 62);
    final transport = _money(_transport, currency).clamp(0, 1 << 62);
    final total = gross - lineDiscounts - discount + transport;
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);

    Widget amount(String label, int minor, {bool signed = false, bool strong = false}) => Padding(
      padding: const EdgeInsets.only(bottom: DoayaSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(child: Text(label, style: strong ? DoayaTypography.label : secondary)),
          Text(
            signed ? formatSignedMoney(minor, currency) : formatMoney(minor, currency),
            style: strong ? DoayaTypography.price : DoayaTypography.label,
          ),
        ],
      ),
    );

    return GlassSurface(
      tone: SurfaceTone.strong,
      borderRadius: BorderRadius.circular(DoayaRadii.hero),
      padding: const EdgeInsets.all(DoayaSpacing.xxl),
      child: ListView(
        children: [
          GlassPillButton(
            label: _supplier?.name ?? l.chooseSupplier,
            icon: DoayaIcons.receive,
            size: PillSize.medium,
            expand: true,
            selected: _supplier != null,
            onPressed: () async {
              final s = await showSupplierPicker(context);
              if (s != null) setState(() => _supplier = s);
            },
          ),
          const SizedBox(height: DoayaSpacing.l),
          GlassTextField(
            label: '${l.supplierInvoiceNoLabel} (${l.optional})',
            controller: _invoiceNo,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: DoayaSpacing.l),
          Row(
            children: [
              Expanded(
                child: GlassTextField(
                  label: l.invoiceDiscountLabel,
                  controller: _invoiceDiscount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: DoayaSpacing.sm),
              Expanded(
                child: GlassTextField(
                  label: l.transportLabel,
                  controller: _transport,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: DoayaSpacing.l),
          amount(l.gross, gross),
          if (lineDiscounts > 0) amount(l.lineDiscounts, -lineDiscounts, signed: true),
          if (discount > 0) amount(l.invoiceDiscountLabel, -discount, signed: true),
          if (transport > 0) amount(l.transportLabel, transport, signed: true),
          const SizedBox(height: DoayaSpacing.xs),
          amount(l.purchaseTotal, total, strong: true),
          const SizedBox(height: DoayaSpacing.l),
          Row(
            children: [
              Expanded(
                child: GlassPillButton(
                  label: l.payCredit,
                  icon: DoayaIcons.debts,
                  expand: true,
                  selected: _payment == PurchasePayment.credit,
                  onPressed: () => setState(() => _payment = PurchasePayment.credit),
                ),
              ),
              const SizedBox(width: DoayaSpacing.sm),
              Expanded(
                child: GlassPillButton(
                  label: l.payCash,
                  icon: DoayaIcons.cash,
                  expand: true,
                  selected: _payment == PurchasePayment.cash,
                  onPressed: () => setState(() => _payment = PurchasePayment.cash),
                ),
              ),
            ],
          ),
          if (_payment == PurchasePayment.cash) ...[
            const SizedBox(height: DoayaSpacing.ml),
            Text(l.paidFromLabel, style: secondary),
            const SizedBox(height: DoayaSpacing.s),
            Row(
              children: [
                Expanded(
                  child: GlassPillButton(
                    label: l.fromDrawer,
                    expand: true,
                    selected: _paidFrom == PaidFrom.drawer,
                    onPressed: () => setState(() => _paidFrom = PaidFrom.drawer),
                  ),
                ),
                const SizedBox(width: DoayaSpacing.sm),
                Expanded(
                  child: GlassPillButton(
                    label: l.fromOutside,
                    expand: true,
                    selected: _paidFrom == PaidFrom.outside,
                    onPressed: () => setState(() => _paidFrom = PaidFrom.outside),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: DoayaSpacing.xl),
          SagePillButton(
            label: '${l.savePurchase} (F9)',
            expand: true,
            onPressed: _busy ? null : _save,
          ),
        ],
      ),
    );
  }
}
