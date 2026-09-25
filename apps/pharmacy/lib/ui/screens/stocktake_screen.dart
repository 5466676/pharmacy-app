import 'dart:async';

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

final _openStocktakeProvider = StreamProvider<StocktakeRow?>(
  (ref) => ref.watch(accountingProvider).watchOpenStocktake(),
);

final _appliedStocktakesProvider = StreamProvider<List<StocktakeRow>>(
  (ref) => ref.watch(accountingProvider).watchAppliedStocktakes(),
);

final _countsProvider = StreamProvider.family<List<StocktakeCountRow>, String>(
  (ref, id) => ref.watch(accountingProvider).watchCounts(id),
);

/// The last count of each product (a recount replaces the earlier one).
Map<String, StocktakeCountRow> lastCounts(List<StocktakeCountRow> rows) => {
  for (final r in rows) r.productId: r,
};

/// Cost of [pieces] of a product, valued at its most recently received batch
/// with a known cost. Null when no batch of it has a cost.
int? pieceCost(StockLedger stock, CostBook costs, String productId, int pieces) {
  final batches = stock.batchesOf(productId).where((b) => costs.knows(b.batchId)).toList()
    ..sort((a, b) => (b.receivedAt ?? DateTime(0)).compareTo(a.receivedAt ?? DateTime(0)));
  if (batches.isEmpty) return null;
  return costs.costOf(batches.first.batchId, pieces);
}

/// Whether a product on [shelf] belongs to a stocktake of [scope]: no scope
/// means everything; otherwise case-insensitive prefix, so "B" covers B1, B2…
bool inShelfScope(String? shelf, String? scope) {
  if (scope == null || scope.trim().isEmpty) return true;
  return shelf?.trim().toUpperCase().startsWith(scope.trim().toUpperCase()) ?? false;
}

/// "+2 علبة" / "−1 ظرف" / "مطابق".
String formatStockDifference(AppLocalizations l, int pieces, int unitsPerPack) {
  if (pieces == 0) return l.balanced;
  final text = formatStock(l, pieces.abs(), unitsPerPack);
  return pieces > 0 ? '؜+$text' : '؜-$text';
}

/// Stocktaking without stopping sales: count products one by one (blind:
/// the system quantity isn't shown before counting), see the differences,
/// and the owner applies the session as stock adjustments.
class StocktakeScreen extends ConsumerWidget {
  const StocktakeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final open = ref.watch(_openStocktakeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          leading: RoundIconButton(
            icon: DoayaIcons.back,
            tooltip: l.back,
            onPressed: () => context.go(Routes.inventory),
          ),
          title: l.stocktakeTitle,
        ),
        Expanded(
          child: switch (open) {
            AsyncData(value: final st?) => _Session(stocktake: st),
            AsyncData() => const _Start(),
            _ => const SizedBox.shrink(),
          },
        ),
      ],
    );
  }
}

class _Start extends ConsumerStatefulWidget {
  const _Start();

  @override
  ConsumerState<_Start> createState() => _StartState();
}

class _StartState extends ConsumerState<_Start> {
  final _scope = TextEditingController();

  @override
  void dispose() {
    _scope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final past = ref.watch(_appliedStocktakesProvider).value ?? const <StocktakeRow>[];
    final employees = {
      for (final e in ref.watch(allEmployeesProvider).value ?? const <EmployeeRow>[]) e.id: e,
    };
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);

    return ListView(
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.stocktakeHelp, style: secondary),
              const SizedBox(height: DoayaSpacing.l),
              Row(
                children: [
                  Expanded(
                    child: GlassTextField(label: l.scopeLabel, controller: _scope),
                  ),
                  const SizedBox(width: DoayaSpacing.l),
                  SagePillButton(
                    label: l.startStocktake,
                    icon: DoayaIcons.adjust,
                    size: PillSize.medium,
                    onPressed: () => ref
                        .read(accountingProvider)
                        .startStocktake(ref.read(requireSessionProvider).stamp, scope: _scope.text),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: DoayaSpacing.xl),
        Panel(
          title: l.pastStocktakes,
          child: past.isEmpty
              ? EmptyHint(l.noStocktakes)
              : Column(
                  children: [
                    for (final st in past)
                      Padding(
                        padding: const EdgeInsets.only(bottom: DoayaSpacing.sm),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                [
                                  formatDate(st.appliedAt!),
                                  if (st.scope != null) l.stocktakeScope(st.scope!),
                                  employees[st.startedBy]?.name ?? l.none,
                                ].join('، '),
                                style: DoayaTypography.label,
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
}

class _Session extends ConsumerStatefulWidget {
  const _Session({required this.stocktake});

  final StocktakeRow stocktake;

  @override
  ConsumerState<_Session> createState() => _SessionState();
}

class _SessionState extends ConsumerState<_Session> {
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  final _boxes = TextEditingController();
  final _strips = TextEditingController();
  final _boxesFocus = FocusNode();
  final _stripsFocus = FocusNode();
  List<ProductRow> _results = const [];
  ProductRow? _product;
  Timer? _debounce;
  var _showCounted = true;
  var _busy = false;

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [_search, _boxes, _strips]) {
      c.dispose();
    }
    for (final f in [_searchFocus, _boxesFocus, _stripsFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  Future<List<ProductRow>> _find(String q) async =>
      q.trim().isEmpty ? const <ProductRow>[] : await ref.read(catalogProvider).search(q);

  void _select(ProductRow p) {
    setState(() {
      _product = p;
      _results = const [];
      _search.clear();
      _boxes.clear();
      _strips.clear();
    });
    _boxesFocus.requestFocus();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final p = _product;
    if (p == null) return;
    final ppu = p.unitsPerPack < 1 ? 1 : p.unitsPerPack;
    final boxes = _boxes.text.trim().isEmpty ? 0 : int.tryParse(toLatinDigits(_boxes.text.trim()));
    final strips = _strips.text.trim().isEmpty
        ? 0
        : int.tryParse(toLatinDigits(_strips.text.trim()));
    if (boxes == null || strips == null || boxes < 0 || strips < 0) {
      toast(context, l.invalidNumber, error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(accountingProvider)
          .count(
            ref.read(requireSessionProvider).stamp,
            stocktakeId: widget.stocktake.id,
            productId: p.id,
            countedPieces: boxes * ppu + strips,
          );
      if (!mounted) return;
      setState(() => _product = null);
      _searchFocus.requestFocus();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _apply(int adjustments) async {
    final l = AppLocalizations.of(context);
    final ok = await showDoayaDialog<bool>(
      context: context,
      title: l.applyStocktake,
      content: Text(l.applyConfirm(formatQty(adjustments)), style: DoayaTypography.bodyMedium),
      actions: [
        GlassPillButton(label: l.cancel, onPressed: () => Navigator.of(context).pop(false)),
        SagePillButton(
          label: l.confirm,
          size: PillSize.small,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (ok != true) return;
    final done = await ref
        .read(accountingProvider)
        .applyStocktake(ref.read(requireSessionProvider).stamp, widget.stocktake.id);
    if (mounted) toast(context, l.stocktakeApplied(formatQty(done.length)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final owner = ref.watch(requireSessionProvider).isOwner;
    final currency = ref.watch(currencyProvider);
    final products = ref.watch(productsProvider).value ?? const <ProductRow>[];
    final byId = ref.watch(productsByIdProvider);
    final stock = ref.watch(stockProvider).value ?? StockLedger();
    final costs = owner ? ref.watch(costBookProvider).value ?? CostBook(const {}) : null;
    final counts = lastCounts(
      ref.watch(_countsProvider(widget.stocktake.id)).value ?? const <StocktakeCountRow>[],
    );
    final scope = widget.stocktake.scope;
    final inScope = products.where((p) => inShelfScope(p.shelf, scope)).toList();
    final notCounted = inScope.where((p) => !counts.containsKey(p.id)).toList();
    final differences = counts.values.where((c) => c.countedPieces != c.systemPiecesAtCount).length;

    var shortage = 0, surplus = 0;
    if (costs != null) {
      for (final c in counts.values) {
        final d = c.countedPieces - c.systemPiecesAtCount;
        final v = d == 0 ? null : pieceCost(stock, costs, c.productId, d.abs());
        if (v == null) continue;
        if (d < 0) {
          shortage += v;
        } else {
          surplus += v;
        }
      }
    }

    final phone = isPhoneLayout(context);
    return Flex(
      direction: phone ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (phone)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: DoayaSizes.formWidth / 2),
            child: _countPane(l),
          )
        else
          SizedBox(width: DoayaSizes.invoiceWidth, child: _countPane(l)),
        const SizedBox(width: DoayaSpacing.huge, height: DoayaSpacing.l),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  StatusChip(
                    label: l.stocktakeOpen(formatDate(widget.stocktake.startedAt)),
                    dot: true,
                  ),
                  if (scope != null) ...[
                    const SizedBox(width: DoayaSpacing.s),
                    StatusChip(label: l.stocktakeScope(scope)),
                  ],
                  const Spacer(),
                  if (owner)
                    SagePillButton(
                      label: l.applyStocktake,
                      icon: DoayaIcons.check,
                      size: PillSize.medium,
                      onPressed: counts.isEmpty ? null : () => _apply(differences),
                    )
                  else
                    Text(
                      l.ownerAppliesNote,
                      style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
                    ),
                ],
              ),
              if (owner && (shortage > 0 || surplus > 0)) ...[
                const SizedBox(height: DoayaSpacing.sm),
                Row(
                  children: [
                    if (shortage > 0)
                      StatusChip(
                        label: l.shortageValue(formatMoney(shortage, currency)),
                        tone: StatusTone.danger,
                      ),
                    const SizedBox(width: DoayaSpacing.s),
                    if (surplus > 0)
                      StatusChip(
                        label: l.surplusValue(formatMoney(surplus, currency)),
                        tone: StatusTone.warning,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: DoayaSpacing.l),
              Row(
                children: [
                  GlassPillButton(
                    label: l.tabCounted(formatQty(counts.length)),
                    selected: _showCounted,
                    onPressed: () => setState(() => _showCounted = true),
                  ),
                  const SizedBox(width: DoayaSpacing.s),
                  GlassPillButton(
                    label: l.tabNotCounted(formatQty(notCounted.length)),
                    selected: !_showCounted,
                    onPressed: () => setState(() => _showCounted = false),
                  ),
                ],
              ),
              const SizedBox(height: DoayaSpacing.ml),
              Expanded(
                child: _showCounted
                    ? _countedList(l, currency, byId, stock, costs, counts)
                    : ListView(
                        children: [
                          for (final p in notCounted)
                            Padding(
                              padding: const EdgeInsets.only(bottom: DoayaSpacing.s),
                              child: GestureDetector(
                                onTap: () => _select(p),
                                child: GlassSurface(
                                  shadow: false,
                                  borderRadius: BorderRadius.circular(DoayaRadii.tile),
                                  padding: const EdgeInsets.all(DoayaSpacing.ml),
                                  child: ProductName(product: p),
                                ),
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

  Widget _countPane(AppLocalizations l) {
    final p = _product;
    return GlassSurface(
      tone: SurfaceTone.strong,
      borderRadius: BorderRadius.circular(DoayaRadii.hero),
      padding: const EdgeInsets.all(DoayaSpacing.xxl),
      child: ListView(
        children: [
          GlassSearchField(
            hint: l.countSearchHint,
            controller: _search,
            focusNode: _searchFocus,
            autofocus: true,
            onChanged: (q) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 150), () async {
                final r = await _find(q);
                if (mounted) setState(() => _results = r);
              });
            },
            onSubmitted: (q) async {
              _debounce?.cancel();
              final r = await _find(q);
              if (!mounted) return;
              if (r.isEmpty) {
                toast(context, l.barcodeNotFound(q.trim()), error: true);
              } else {
                _select(r.first);
              }
            },
          ),
          const SizedBox(height: DoayaSpacing.sm),
          for (final r in _results.take(6))
            Padding(
              padding: const EdgeInsets.only(bottom: DoayaSpacing.s),
              child: GestureDetector(
                onTap: () => _select(r),
                child: GlassSurface(
                  shadow: false,
                  borderRadius: BorderRadius.circular(DoayaRadii.tile),
                  padding: const EdgeInsets.all(DoayaSpacing.ml),
                  child: ProductName(product: r),
                ),
              ),
            ),
          if (p != null) ...[
            const SizedBox(height: DoayaSpacing.l),
            ProductName(product: p),
            const SizedBox(height: DoayaSpacing.l),
            GlassTextField(
              label: l.countedBoxesLabel,
              controller: _boxes,
              focusNode: _boxesFocus,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => p.unitsPerPack > 1 ? _stripsFocus.requestFocus() : _save(),
            ),
            if (p.unitsPerPack > 1) ...[
              const SizedBox(height: DoayaSpacing.l),
              GlassTextField(
                label: l.countedStripsLabel,
                controller: _strips,
                focusNode: _stripsFocus,
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _save(),
              ),
            ],
            const SizedBox(height: DoayaSpacing.l),
            SagePillButton(label: l.saveCount, expand: true, onPressed: _busy ? null : _save),
            const SizedBox(height: DoayaSpacing.sm),
            Text(
              l.blindCountNote,
              style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _countedList(
    AppLocalizations l,
    Currency currency,
    Map<String, ProductRow> products,
    StockLedger stock,
    CostBook? costs,
    Map<String, StocktakeCountRow> counts,
  ) {
    final head = DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary);
    // Differences first, biggest first; matching counts after.
    final rows = counts.values.toList()
      ..sort(
        (a, b) => (b.countedPieces - b.systemPiecesAtCount).abs().compareTo(
          (a.countedPieces - a.systemPiecesAtCount).abs(),
        ),
      );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(flex: 2, child: Text(l.colProduct, style: head)),
            Expanded(child: Text(l.colCounted, style: head)),
            Expanded(child: Text(l.colSystem, style: head)),
            Expanded(child: Text(l.colDifference, style: head)),
          ],
        ),
        const Divider(color: DoayaColors.divider),
        Expanded(
          child: ListView(
            children: [
              for (final c in rows)
                Builder(
                  builder: (context) {
                    final p = products[c.productId];
                    final ppu = p?.unitsPerPack ?? 1;
                    final d = c.countedPieces - c.systemPiecesAtCount;
                    final value = costs == null || d == 0
                        ? null
                        : pieceCost(stock, costs, c.productId, d.abs());
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: DoayaSpacing.xs),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: LatinText(
                              p?.tradeName ?? l.none,
                              maxLines: 1,
                              style: DoayaTypography.label,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              formatStock(l, c.countedPieces, ppu),
                              style: DoayaTypography.bodySmall,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              formatStock(l, c.systemPiecesAtCount, ppu),
                              style: DoayaTypography.bodySmall,
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: StatusChip(
                                label: [
                                  formatStockDifference(l, d, ppu),
                                  if (value != null) formatMoney(value, currency),
                                ].join('، '),
                                tone: d == 0
                                    ? StatusTone.accent
                                    : d < 0
                                    ? StatusTone.danger
                                    : StatusTone.warning,
                              ),
                            ),
                          ),
                        ],
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
}
