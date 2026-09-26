import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/catalog_repository.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
import '../format.dart';
import '../widgets.dart';

final _productProvider = FutureProvider.family<ProductRow?, String>((ref, id) {
  ref.watch(productsProvider); // refresh after edits
  return ref.watch(catalogProvider).byId(id);
});

final _eventsProvider = StreamProvider.family<List<StockEvent>, String>(
  (ref, id) => ref.watch(ledgerProvider).watchProductEvents(id),
);

/// One product: stock by batch, receive / count / remove expired, history.
class ProductScreen extends ConsumerWidget {
  const ProductScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(_productProvider(productId)).value;
    if (p == null) return const SizedBox.shrink();
    final stock = ref.watch(stockProvider).value ?? StockLedger();
    final events = ref.watch(_eventsProvider(productId)).value ?? const [];
    final currency = ref.watch(currencyProvider);
    final now = ref.watch(clockProvider)();
    final window = ref.watch(nearExpiryWindowProvider);
    final batches = stock.fefo(p.id);
    final session = ref.watch(requireSessionProvider).stamp;
    final ledger = ref.read(ledgerProvider);

    return ListView(
      children: [
        PageHeader(
          leading: RoundIconButton(
            icon: DoayaIcons.back,
            tooltip: l.back,
            onPressed: () => context.go(Routes.inventory),
          ),
          title: l.productDetail,
          actions: [
            GlassPillButton(
              label: l.edit,
              icon: DoayaIcons.edit,
              size: PillSize.medium,
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute<void>(builder: (_) => ProductFormScreen(existing: p))),
            ),
          ],
        ),
        Panel(
          child: Wrap(
            spacing: DoayaSpacing.xl,
            runSpacing: DoayaSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: DoayaSizes.employeeTile * 2),
                child: ProductName(product: p),
              ),
              StockChip(product: p, onHand: stock.onHand(p.id)),
              Text(formatMoney(p.priceMinor, currency), style: DoayaTypography.price),
            ],
          ),
        ),
        SizedBox(height: DoayaSpacing.xl),
        Panel(
          title: l.batches,
          trailing: Wrap(
            spacing: DoayaSpacing.sm,
            children: [
              GlassPillButton(
                label: l.adjustStock,
                icon: DoayaIcons.adjust,
                onPressed: () => _adjust(context, ref, p, stock.onHand(p.id)),
              ),
              SagePillButton(
                label: l.receiveStock,
                icon: DoayaIcons.receive,
                size: PillSize.small,
                onPressed: () => _receive(context, ref, p, currency),
              ),
            ],
          ),
          child: batches.isEmpty
              ? EmptyHint(l.none)
              : Column(
                  children: [
                    for (final b in batches)
                      Padding(
                        padding: EdgeInsets.only(bottom: DoayaSpacing.sm),
                        child: Wrap(
                          spacing: DoayaSpacing.l,
                          runSpacing: DoayaSpacing.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              l.batchReceived(formatDate(b.receivedAt ?? now)),
                              style: DoayaTypography.bodySmall,
                            ),
                            _ExpiryChip(expiry: b.expiry, now: now, window: window, l: l),
                            Text(
                              formatStock(l, b.quantity, p.unitsPerPack),
                              style: DoayaTypography.label,
                            ),
                            if (b.expiry != null && !b.expiry!.isAfter(now.add(window)))
                              GlassPillButton(
                                label: l.removeExpired,
                                icon: DoayaIcons.delete,
                                onPressed: () async {
                                  final ok = await _confirm(
                                    context,
                                    l.removeExpiredConfirm(formatQty(b.quantity)),
                                  );
                                  if (ok) await ledger.removeExpired(session, batchId: b.batchId);
                                },
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        SizedBox(height: DoayaSpacing.xl),
        Panel(
          title: l.history,
          child: Column(
            children: [
              for (final e in events.take(50))
                Padding(
                  padding: EdgeInsets.only(bottom: DoayaSpacing.s),
                  child: Row(
                    children: [
                      SizedBox(
                        width: DoayaSizes.priceColumn,
                        child: Text(stockEventLabel(l, e.type), style: DoayaTypography.bodySmall),
                      ),
                      Expanded(
                        child: Text(
                          '${formatDate(e.meta.occurredAt)}، ${formatTime(e.meta.occurredAt)}',
                          style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
                        ),
                      ),
                      Text(
                        formatSignedQty(e.quantity),
                        style: DoayaTypography.label.copyWith(
                          color: e.quantity > 0 ? DoayaColors.price : DoayaColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _receive(
    BuildContext context,
    WidgetRef ref,
    ProductRow p,
    Currency currency,
  ) async {
    final l = AppLocalizations.of(context);
    final form = GlobalKey<FormState>();
    final qty = TextEditingController();
    final expiry = TextEditingController();
    final cost = TextEditingController();
    final ok = await showDoayaDialog<bool>(
      context: context,
      title: l.receiveStock,
      content: Form(
        key: form,
        child: Column(
          children: [
            GlassTextField(
              label: p.unitsPerPack > 1 ? l.receiveQtyBoxes : l.quantityLabel,
              controller: qty,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => (int.tryParse(v ?? '') ?? 0) > 0 ? null : l.invalidNumber,
            ),
            SizedBox(height: DoayaSpacing.l),
            GlassTextField(
              label: '${l.expiryLabel} (${l.optional})',
              hint: l.expiryHint,
              controller: expiry,
              textDirection: TextDirection.ltr,
              validator: (v) =>
                  (v ?? '').trim().isEmpty || parseDate(v!) != null ? null : l.invalidDate,
            ),
            SizedBox(height: DoayaSpacing.l),
            GlassTextField(
              label: '${l.unitCostLabel} (${l.optional})',
              controller: cost,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (v ?? '').trim().isEmpty || Money.tryParse(v!, currency) != null
                  ? null
                  : l.invalidNumber,
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
    if (ok != true) return;
    await ref
        .read(ledgerProvider)
        .receive(
          ref.read(requireSessionProvider).stamp,
          productId: p.id,
          quantity: int.parse(qty.text) * (p.unitsPerPack < 1 ? 1 : p.unitsPerPack),
          expiry: parseDate(expiry.text),
          unitCostMinor: Money.tryParse(cost.text, currency)?.minor,
        );
  }

  Future<void> _adjust(BuildContext context, WidgetRef ref, ProductRow p, int onHand) async {
    final l = AppLocalizations.of(context);
    final form = GlobalKey<FormState>();
    final ppu = p.unitsPerPack < 1 ? 1 : p.unitsPerPack;
    final (packs, loose) = splitPieces(onHand < 0 ? 0 : onHand, ppu);
    final actual = TextEditingController(text: '$packs');
    final strips = TextEditingController(text: '$loose');
    final ok = await showDoayaDialog<bool>(
      context: context,
      title: l.adjustStock,
      content: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.adjustHelp,
              style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
            ),
            SizedBox(height: DoayaSpacing.l),
            GlassTextField(
              label: ppu > 1 ? l.receiveQtyBoxes : l.actualQtyLabel,
              controller: actual,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => int.tryParse(v ?? '') == null ? l.invalidNumber : null,
            ),
            if (ppu > 1) ...[
              SizedBox(height: DoayaSpacing.l),
              GlassTextField(
                label: l.looseStripsLabel,
                controller: strips,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  return n == null || n >= ppu ? l.invalidNumber : null;
                },
              ),
            ],
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
    if (ok != true) return;
    await ref
        .read(ledgerProvider)
        .adjust(
          ref.read(requireSessionProvider).stamp,
          productId: p.id,
          delta: int.parse(actual.text) * ppu + (ppu > 1 ? int.parse(strips.text) : 0) - onHand,
        );
  }

  Future<bool> _confirm(BuildContext context, String message) async {
    final l = AppLocalizations.of(context);
    return await showDoayaDialog<bool>(
          context: context,
          title: l.removeExpired,
          content: Text(message, style: DoayaTypography.body),
          actions: [
            GlassPillButton(label: l.cancel, onPressed: () => Navigator.of(context).pop(false)),
            SagePillButton(
              label: l.confirm,
              size: PillSize.small,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ) ??
        false;
  }
}

class _ExpiryChip extends StatelessWidget {
  const _ExpiryChip({
    required this.expiry,
    required this.now,
    required this.window,
    required this.l,
  });

  final DateTime? expiry;
  final DateTime now;
  final Duration window;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final e = expiry;
    if (e == null) return StatusChip(label: l.noExpiry);
    if (e.isBefore(now)) return StatusChip(label: l.expiredLabel, tone: StatusTone.danger);
    return StatusChip(
      label: l.expiresOn(formatDate(e)),
      tone: e.isAfter(now.add(window)) ? StatusTone.neutral : StatusTone.warning,
    );
  }
}

/// Create or edit a product.
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.existing});

  final ProductRow? existing;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _trade = TextEditingController(text: widget.existing?.tradeName);
  late final _arabic = TextEditingController(text: widget.existing?.arabicName);
  late final _ingredient = TextEditingController(text: widget.existing?.activeIngredient);
  late final _strength = TextEditingController(text: widget.existing?.strength);
  late final _formField = TextEditingController(text: widget.existing?.form);
  late final _manufacturer = TextEditingController(text: widget.existing?.manufacturer);
  late final _shelf = TextEditingController(text: widget.existing?.shelf);
  late final _price = TextEditingController();
  late final _threshold = TextEditingController(text: '${widget.existing?.lowStockThreshold ?? 5}');
  final _barcodes = TextEditingController();
  late final _unitsPerPack = TextEditingController(text: '${widget.existing?.unitsPerPack ?? 1}');
  final _stripPrice = TextEditingController();
  late var _rx = widget.existing?.prescriptionOnly ?? false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    if (p != null) {
      _price.text = moneyInput(p.priceMinor, ref.read(currencyProvider));
      if (p.stripPriceMinor != null) {
        _stripPrice.text = moneyInput(p.stripPriceMinor!, ref.read(currencyProvider));
      }
      ref.read(catalogProvider).barcodesOf(p.id).then((c) => _barcodes.text = c.join(', '));
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final l = AppLocalizations.of(context);
    final currency = ref.read(currencyProvider);
    final draft = ProductDraft(
      tradeName: _trade.text,
      arabicName: _arabic.text,
      activeIngredient: _ingredient.text,
      strength: _strength.text,
      form: _formField.text,
      manufacturer: _manufacturer.text,
      shelf: _shelf.text,
      priceMinor: Money.tryParse(_price.text, currency)!.minor,
      prescriptionOnly: _rx,
      lowStockThreshold: int.parse(_threshold.text),
      barcodes: _barcodes.text.split(RegExp(r'[,،\s]+')),
      unitsPerPack: int.parse(_unitsPerPack.text),
      stripPriceMinor: Money.tryParse(_stripPrice.text, currency)?.minor,
    );
    final catalog = ref.read(catalogProvider);
    final deviceId = ref.read(requireSessionProvider).device.id;
    try {
      if (widget.existing == null) {
        final p = await catalog.create(draft, deviceId: deviceId);
        if (mounted) context.go(Routes.product(p.id));
      } else {
        await catalog.update(widget.existing!.id, draft, deviceId: deviceId);
        ref.invalidate(productsProvider);
        if (mounted) Navigator.of(context).pop();
      }
    } on DuplicateBarcode catch (e) {
      setState(() => _error = l.duplicateBarcode(e.barcode));
    } on UnitsPerPackLocked {
      setState(() => _error = l.unitsPerPackLocked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    String? req(String? v) => (v ?? '').trim().isEmpty ? l.required : null;
    Widget field(
      String label,
      TextEditingController c, {
      String? Function(String?)? validator,
      TextDirection? dir,
      TextInputType? kb,
      bool optional = false,
    }) => GlassTextField(
      label: optional ? '$label (${l.optional})' : label,
      controller: c,
      validator: validator,
      textDirection: dir,
      keyboardType: kb,
    );
    Widget pair(Widget a, Widget b) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        SizedBox(width: DoayaSpacing.l),
        Expanded(child: b),
      ],
    );
    final gap = SizedBox(height: DoayaSpacing.l);

    final body = Form(
      key: _form,
      child: ListView(
        children: [
          PageHeader(
            leading: RoundIconButton(
              icon: DoayaIcons.back,
              tooltip: l.back,
              onPressed: () => widget.existing == null
                  ? context.go(Routes.inventory)
                  : Navigator.of(context).pop(),
            ),
            title: widget.existing == null ? l.productFormNew : l.productFormEdit,
            actions: [SagePillButton(label: l.save, size: PillSize.medium, onPressed: _save)],
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DoayaSizes.wideFormWidth),
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null) ...[
                    NoticeBanner(
                      message: _error!,
                      tone: StatusTone.danger,
                      icon: DoayaIcons.danger,
                    ),
                    gap,
                  ],
                  pair(
                    field(l.tradeNameLabel, _trade, validator: req, dir: TextDirection.ltr),
                    field(l.arabicNameLabel, _arabic, optional: true),
                  ),
                  gap,
                  pair(
                    field(l.ingredientLabel, _ingredient, validator: req, dir: TextDirection.ltr),
                    field(l.strengthLabel, _strength, optional: true, dir: TextDirection.ltr),
                  ),
                  gap,
                  pair(
                    field(l.formLabel, _formField, optional: true),
                    field(l.manufacturerLabel, _manufacturer, optional: true),
                  ),
                  gap,
                  pair(
                    field(
                      l.priceLabel(currency.symbol),
                      _price,
                      kb: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) =>
                          Money.tryParse(v ?? '', currency) == null ? l.invalidNumber : null,
                    ),
                    field(
                      l.lowThresholdLabel,
                      _threshold,
                      kb: TextInputType.number,
                      validator: (v) => (int.tryParse(v ?? '') ?? -1) >= 0 ? null : l.invalidNumber,
                    ),
                  ),
                  gap,
                  pair(
                    field(
                      '${l.unitsPerPackLabel} (${l.unitsPerPackHelp})',
                      _unitsPerPack,
                      kb: TextInputType.number,
                      validator: (v) => (int.tryParse(v ?? '') ?? 0) >= 1 ? null : l.invalidNumber,
                    ),
                    field(
                      l.stripPriceLabel(currency.symbol),
                      _stripPrice,
                      kb: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        final many = (int.tryParse(_unitsPerPack.text) ?? 1) > 1;
                        if (!many) return null;
                        final m = Money.tryParse(v ?? '', currency);
                        return m == null || m.isZero ? l.invalidNumber : null;
                      },
                    ),
                  ),
                  gap,
                  pair(
                    field(l.shelfLabel, _shelf, optional: true),
                    field(l.barcodesLabel, _barcodes, optional: true, dir: TextDirection.ltr),
                  ),
                  gap,
                  Material(
                    type: MaterialType.transparency,
                    child: SwitchListTile(
                      value: _rx,
                      onChanged: (v) => setState(() => _rx = v),
                      title: Text(l.prescriptionLabel, style: DoayaTypography.bodyMedium),
                      activeThumbColor: DoayaColors.onSage,
                      activeTrackColor: DoayaColors.accent,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    // Pushed on top of the shell when editing: give it its own scaffold.
    if (widget.existing != null) {
      return Scaffold(
        body: Padding(padding: EdgeInsets.all(DoayaSpacing.huge), child: body),
      );
    }
    return body;
  }
}
