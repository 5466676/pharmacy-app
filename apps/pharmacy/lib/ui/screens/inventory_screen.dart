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

enum InventoryFilter { all, low, nearExpiry, out }

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  var _filter = InventoryFilter.all;
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final products = ref.watch(productsProvider).value ?? const <ProductRow>[];
    final stock = ref.watch(stockProvider).value ?? StockLedger();
    final currency = ref.watch(currencyProvider);
    final now = ref.watch(clockProvider)();
    final window = ref.watch(nearExpiryWindowProvider);

    DateTime? nearest(String id) =>
        stock.fefo(id).where((b) => b.expiry != null).firstOrNull?.expiry;
    bool isNear(String id) => stock.nearExpiry(now, window, productId: id).isNotEmpty;

    final q = _query.trim().toLowerCase();
    final list = products.where((p) {
      if (q.isNotEmpty &&
          !p.tradeName.toLowerCase().contains(q) &&
          !(p.arabicName?.contains(q) ?? false) &&
          !p.activeIngredient.contains(q)) {
        return false;
      }
      final onHand = stock.onHand(p.id);
      return switch (_filter) {
        InventoryFilter.all => true,
        InventoryFilter.low => onHand > 0 && onHand <= lowStockPieces(p),
        InventoryFilter.out => onHand <= 0,
        InventoryFilter.nearExpiry => isNear(p.id),
      };
    }).toList();

    Widget filter(InventoryFilter f, String label) => Padding(
      padding: const EdgeInsetsDirectional.only(end: DoayaSpacing.s),
      child: GlassPillButton(
        label: label,
        selected: _filter == f,
        onPressed: () => setState(() => _filter = f),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: l.inventoryTitle,
          actions: [
            SagePillButton(
              label: l.addProduct,
              icon: DoayaIcons.add,
              size: PillSize.medium,
              onPressed: () => context.go(Routes.newProduct),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: DoayaSizes.desktopSearchWidth,
              child: GlassSearchField(hint: l.search, onChanged: (v) => setState(() => _query = v)),
            ),
            const SizedBox(width: DoayaSpacing.l),
            filter(InventoryFilter.all, l.filterAll),
            filter(InventoryFilter.low, l.filterLow),
            filter(InventoryFilter.nearExpiry, l.filterNearExpiry),
            filter(InventoryFilter.out, l.filterOut),
          ],
        ),
        const SizedBox(height: DoayaSpacing.l),
        _HeaderRow(l: l),
        Expanded(
          child: list.isEmpty
              ? EmptyHint(l.noProducts)
              : ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: DoayaSpacing.s),
                  itemBuilder: (context, i) {
                    final p = list[i];
                    final exp = nearest(p.id);
                    final near = isNear(p.id);
                    return GlassSurface(
                      shadow: false,
                      borderRadius: BorderRadius.circular(DoayaRadii.card),
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          onTap: () => context.go(Routes.product(p.id)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DoayaSpacing.xl,
                              vertical: DoayaSpacing.ml,
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 4, child: ProductName(product: p)),
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: StockChip(product: p, onHand: stock.onHand(p.id)),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: exp == null
                                        ? Text(l.none, style: DoayaTypography.caption)
                                        : StatusChip(
                                            label: formatDate(exp),
                                            tone: near ? StatusTone.warning : StatusTone.neutral,
                                          ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    formatMoney(p.priceMinor, currency),
                                    style: DoayaTypography.label,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    p.shelf ?? l.none,
                                    style: DoayaTypography.caption.copyWith(
                                      color: DoayaColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final s = DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DoayaSpacing.xl, vertical: DoayaSpacing.sm),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(l.colProduct, style: s)),
          Expanded(flex: 2, child: Text(l.colStock, style: s)),
          Expanded(flex: 2, child: Text(l.colNearestExpiry, style: s)),
          Expanded(flex: 2, child: Text(l.colPrice, style: s)),
          Expanded(child: Text(l.colShelf, style: s)),
        ],
      ),
    );
  }
}
