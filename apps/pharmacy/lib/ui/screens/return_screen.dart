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
import 'pos_screen.dart' show showCustomerPicker;

final _recentSalesProvider = StreamProvider<List<SaleRow>>(
  (ref) => ref.watch(ledgerProvider).watchRecentSales(limit: 60),
);

/// Lines of a sale + pieces still returnable per line.
final _saleDetailProvider = FutureProvider.family<(List<SaleLineRow>, Map<String, int>), String>((
  ref,
  saleId,
) async {
  ref.watch(stockProvider); // refresh after a return
  final ledger = ref.watch(ledgerProvider);
  return (await ledger.linesOf(saleId), await ledger.returnablePieces(saleId));
});

enum _Mode { invoice, free }

class _FreeItem {
  _FreeItem(this.product, {required this.strip, required String price})
    : price = TextEditingController(text: price);
  final ProductRow product;
  final bool strip;
  int quantity = 1;
  final TextEditingController price;

  int get piecesPerUnit => strip ? 1 : (product.unitsPerPack < 1 ? 1 : product.unitsPerPack);
}

/// Returns: against a past invoice, or free-form (product + price).
class ReturnScreen extends ConsumerStatefulWidget {
  const ReturnScreen({super.key});

  @override
  ConsumerState<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends ConsumerState<ReturnScreen> {
  var _mode = _Mode.invoice;
  var _saleQuery = '';
  SaleRow? _sale;
  final _qty = <String, int>{}; // saleLineId → selling units to return
  final _free = <_FreeItem>[];
  List<ProductRow> _results = const [];
  var _refund = RefundMethod.cash;
  CustomerRow? _customer;
  var _busy = false;

  @override
  void dispose() {
    for (final f in _free) {
      f.price.dispose();
    }
    super.dispose();
  }

  void _selectSale(SaleRow s, Map<String, CustomerRow> customers) {
    setState(() {
      _sale = s;
      _qty.clear();
      _customer = s.customerId == null ? null : customers[s.customerId];
      _refund = s.payment == PaymentType.debt.wire ? RefundMethod.debtCredit : RefundMethod.cash;
    });
  }

  List<ReturnItem> _items(Currency c, List<SaleLineRow> lines) {
    if (_mode == _Mode.invoice) {
      return [
        for (final l in lines)
          if ((_qty[l.id] ?? 0) > 0)
            ReturnItem(
              productId: l.productId,
              quantity: _qty[l.id]!,
              unitPrice: Money(l.unitPriceMinor, c),
              piecesPerUnit: l.piecesPerUnit,
              saleLineId: l.id,
            ),
      ];
    }
    return [
      for (final f in _free)
        ReturnItem(
          productId: f.product.id,
          quantity: f.quantity,
          unitPrice: Money.tryParse(f.price.text, c) ?? Money.zero(c),
          piecesPerUnit: f.piecesPerUnit,
        ),
    ];
  }

  Future<void> _confirm(List<ReturnItem> items) async {
    final l = AppLocalizations.of(context);
    final currency = ref.read(currencyProvider);
    setState(() => _busy = true);
    try {
      final r = await ref
          .read(ledgerProvider)
          .processReturn(
            ref.read(requireSessionProvider).stamp,
            items: items,
            currency: currency,
            refund: _refund,
            saleId: _mode == _Mode.invoice ? _sale?.id : null,
            customerId: _customer?.id,
          );
      if (!mounted) return;
      toast(context, l.returnDone(formatMoney(r.totalMinor, currency)));
      context.go(Routes.pos);
    } on ReturnException catch (e) {
      if (mounted) toast(context, _errorText(l, e.code), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _errorText(AppLocalizations l, ReturnError e) => switch (e) {
    ReturnError.empty || ReturnError.badQuantity => l.errReturnEmpty,
    ReturnError.moreThanSold => l.errReturnTooMany,
    ReturnError.creditNeedsCustomer => l.errReturnNeedsCustomer,
    ReturnError.creditMoreThanDebt => l.errReturnCreditTooBig,
    ReturnError.unknownProduct => l.errReturnUnknown,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    final products = ref.watch(productsByIdProvider);
    final customers = {
      for (final c in ref.watch(customersProvider).value ?? const <CustomerRow>[]) c.id: c,
    };
    final detail = _sale == null ? null : ref.watch(_saleDetailProvider(_sale!.id)).value;
    final lines = detail?.$1 ?? const <SaleLineRow>[];
    final items = _items(currency, lines);
    final total = items.fold<int>(0, (s, i) => s + i.total.minor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          leading: RoundIconButton(
            icon: DoayaIcons.back,
            tooltip: l.back,
            onPressed: () => context.go(Routes.pos),
          ),
          title: l.returnsTitle,
          actions: [
            GlassPillButton(
              label: l.returnFromInvoice,
              selected: _mode == _Mode.invoice,
              onPressed: () => setState(() => _mode = _Mode.invoice),
            ),
            GlassPillButton(
              label: l.returnFree,
              selected: _mode == _Mode.free,
              onPressed: () => setState(() {
                _mode = _Mode.free;
                if (_refund == RefundMethod.debtCredit && _customer == null) {
                  _refund = RefundMethod.cash;
                }
              }),
            ),
          ],
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _mode == _Mode.invoice
                    ? _invoicePane(l, currency, customers, products, lines, detail?.$2 ?? const {})
                    : _freePane(l, currency),
              ),
              const SizedBox(width: DoayaSpacing.huge),
              SizedBox(width: DoayaSizes.invoiceWidth, child: _summary(l, currency, items, total)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _invoicePane(
    AppLocalizations l,
    Currency currency,
    Map<String, CustomerRow> customers,
    Map<String, ProductRow> products,
    List<SaleLineRow> lines,
    Map<String, int> returnable,
  ) {
    final sales = (ref.watch(_recentSalesProvider).value ?? const <SaleRow>[]).where((s) {
      final q = toLatinDigits(_saleQuery.trim());
      if (q.isEmpty) return true;
      return (customers[s.customerId]?.name.contains(q) ?? false);
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: DoayaSizes.listPaneWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassSearchField(
                hint: l.pickInvoice,
                onChanged: (v) => setState(() => _saleQuery = v),
              ),
              const SizedBox(height: DoayaSpacing.ml),
              Expanded(
                child: sales.isEmpty
                    ? EmptyHint(l.noInvoices)
                    : ListView.separated(
                        itemCount: sales.length,
                        separatorBuilder: (_, _) => const SizedBox(height: DoayaSpacing.s),
                        itemBuilder: (context, i) {
                          final s = sales[i];
                          final name = s.customerId == null
                              ? l.walkInCustomer
                              : customers[s.customerId]?.name ?? l.none;
                          return CaseRow(
                            initials: formatTime(s.occurredAt),
                            title: name,
                            subtitle: formatDate(s.occurredAt),
                            selected: s.id == _sale?.id,
                            trailing: StatusChip(
                              label: formatMoney(s.totalMinor, currency),
                              tone: s.payment == PaymentType.debt.wire
                                  ? StatusTone.warning
                                  : StatusTone.accent,
                            ),
                            onTap: () => _selectSale(s, customers),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(width: DoayaSpacing.xl),
        Expanded(
          child: _sale == null
              ? EmptyHint(l.pickInvoice)
              : ListView(
                  children: [
                    for (final line in lines)
                      Builder(
                        builder: (context) {
                          final p = products[line.productId];
                          final maxUnits = (returnable[line.id] ?? 0) ~/ line.piecesPerUnit;
                          final unit = line.piecesPerUnit == 1 && (p?.unitsPerPack ?? 1) > 1
                              ? l.unitStrip
                              : l.unitBox;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: DoayaSpacing.sm),
                            child: GlassSurface(
                              shadow: false,
                              borderRadius: BorderRadius.circular(DoayaRadii.tile),
                              padding: const EdgeInsets.all(DoayaSpacing.ml),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        LatinText(
                                          p?.tradeName ?? l.none,
                                          style: DoayaTypography.label,
                                        ),
                                        Text(
                                          '${l.lineItem(unit, formatQty(line.quantity))}، '
                                          '${l.returnable(formatQty(maxUnits))}',
                                          style: DoayaTypography.caption.copyWith(
                                            color: DoayaColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    formatMoney(line.unitPriceMinor, currency),
                                    style: DoayaTypography.caption,
                                  ),
                                  const SizedBox(width: DoayaSpacing.l),
                                  _Stepper(
                                    value: _qty[line.id] ?? 0,
                                    max: maxUnits,
                                    onChanged: (v) => setState(() => _qty[line.id] = v),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _freePane(AppLocalizations l, Currency currency) {
    Future<void> search(String q) async {
      final r = await ref.read(catalogProvider).search(q);
      if (mounted) setState(() => _results = r);
    }

    void add(ProductRow p, {required bool strip}) {
      final price = strip ? (p.stripPriceMinor ?? p.priceMinor) : p.priceMinor;
      setState(() {
        _free.add(_FreeItem(p, strip: strip, price: moneyInput(price, currency)));
        _results = const [];
      });
    }

    return ListView(
      children: [
        GlassSearchField(hint: l.posSearchHint, onChanged: search),
        const SizedBox(height: DoayaSpacing.sm),
        for (final p in _results)
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
                    GlassPillButton(label: l.addStrip, onPressed: () => add(p, strip: true)),
                    const SizedBox(width: DoayaSpacing.s),
                  ],
                  SagePillButton(
                    label: p.unitsPerPack > 1 ? l.addBox : l.addToCart,
                    size: PillSize.small,
                    onPressed: () => add(p, strip: false),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: DoayaSpacing.l),
        for (final f in _free)
          Padding(
            padding: const EdgeInsets.only(bottom: DoayaSpacing.sm),
            child: GlassSurface(
              shadow: false,
              borderRadius: BorderRadius.circular(DoayaRadii.tile),
              padding: const EdgeInsets.all(DoayaSpacing.ml),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LatinText(f.product.tradeName, style: DoayaTypography.label),
                        Text(
                          f.strip ? l.unitStrip : l.unitBox,
                          style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: DoayaSizes.priceColumn,
                    child: GlassTextField(
                      label: l.unitPriceLabel,
                      controller: f.price,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: DoayaSpacing.l),
                  _Stepper(
                    value: f.quantity,
                    max: 9999,
                    onChanged: (v) => setState(() {
                      if (v <= 0) {
                        _free.remove(f);
                        f.price.dispose();
                      } else {
                        f.quantity = v;
                      }
                    }),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _summary(AppLocalizations l, Currency currency, List<ReturnItem> items, int total) {
    return GlassSurface(
      tone: SurfaceTone.strong,
      borderRadius: BorderRadius.circular(DoayaRadii.hero),
      padding: const EdgeInsets.all(DoayaSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.refundMethod, style: DoayaTypography.lead),
          const SizedBox(height: DoayaSpacing.l),
          GlassPillButton(
            label: l.refundCash,
            icon: DoayaIcons.cash,
            size: PillSize.medium,
            expand: true,
            selected: _refund == RefundMethod.cash,
            onPressed: () => setState(() => _refund = RefundMethod.cash),
          ),
          const SizedBox(height: DoayaSpacing.sm),
          GlassPillButton(
            label: l.refundDebtCredit,
            icon: DoayaIcons.debts,
            size: PillSize.medium,
            expand: true,
            selected: _refund == RefundMethod.debtCredit,
            onPressed: () async {
              if (_customer == null) {
                final c = await showCustomerPicker(context);
                if (c == null) return;
                _customer = c;
              }
              setState(() => _refund = RefundMethod.debtCredit);
            },
          ),
          if (_customer != null) ...[
            const SizedBox(height: DoayaSpacing.sm),
            StatusChip(label: _customer!.name, icon: DoayaIcons.person),
          ],
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text(l.returnTotal, style: DoayaTypography.label)),
              Text(formatMoney(total, currency), style: DoayaTypography.price),
            ],
          ),
          const SizedBox(height: DoayaSpacing.l),
          SagePillButton(
            label: l.confirmReturn,
            expand: true,
            onPressed: _busy || items.isEmpty ? null : () => _confirm(items),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.max, required this.onChanged});

  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RoundIconButton(
          icon: DoayaIcons.remove,
          tooltip: '−',
          size: DoayaSizes.qtyButton + DoayaSpacing.sm,
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: DoayaSpacing.giant,
          child: Text(formatQty(value), textAlign: TextAlign.center, style: DoayaTypography.label),
        ),
        RoundIconButton(
          icon: DoayaIcons.add,
          tooltip: '+',
          size: DoayaSizes.qtyButton + DoayaSpacing.sm,
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}
