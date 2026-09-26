import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../data/shop.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';
import 'common.dart';

/// The bag in the top bar, with how many items are in the cart.
class CartButton extends ConsumerWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final count = ref.watch(cartCountProvider);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        RoundIconButton(
          icon: DoayaIcons.bag,
          tooltip: l.cartTitle,
          onPressed: () => context.push(Routes.cart),
        ),
        if (count > 0)
          PositionedDirectional(
            top: -DoayaSpacing.xxs,
            end: -DoayaSpacing.xxs,
            child: Container(
              constraints: const BoxConstraints(minWidth: DoayaSizes.badge),
              height: DoayaSizes.badge,
              padding: const EdgeInsets.symmetric(horizontal: DoayaSpacing.xs),
              decoration: BoxDecoration(
                color: DoayaColors.accent,
                borderRadius: BorderRadius.circular(DoayaRadii.pill),
              ),
              alignment: Alignment.center,
              child: Text(formatNumber(count), style: DoayaTypography.badge),
            ),
          ),
      ],
    );
  }
}

/// A grid of shelf products, three to a row (design/patient_home.html).
class ShelfGrid extends StatelessWidget {
  const ShelfGrid({super.key, required this.items});

  final List<ShelfItem> items;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        const columns = 3;
        final width = (box.maxWidth - DoayaSpacing.m * (columns - 1)) / columns;
        return Wrap(
          spacing: DoayaSpacing.m,
          runSpacing: DoayaSpacing.m,
          children: [
            for (final i in items)
              SizedBox(
                width: width,
                child: ProductCard(
                  image: ProductImage(url: i.photoUrl),
                  name: i.tradeName,
                  price: formatPrice(i.priceMinor, i.currency),
                  status: i.available
                      ? null
                      : StatusChip(label: l.unavailable, tone: StatusTone.warning),
                  onTap: () => context.push(Routes.product(i.productId)),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Everything on the pharmacy's shelf, with search (available first).
class ShelfScreen extends ConsumerStatefulWidget {
  const ShelfScreen({super.key, this.query = ''});

  final String query;

  @override
  ConsumerState<ShelfScreen> createState() => _ShelfScreenState();
}

class _ShelfScreenState extends ConsumerState<ShelfScreen> {
  late final _search = TextEditingController(text: widget.query);
  late var _query = widget.query;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final found = ref.watch(shelfProvider(_query));
    return Scaffold(
      backgroundColor: DoayaColors.transparent,
      body: SafeArea(
        child: PhoneBody(
          child: ListView(
            children: [
              ScreenHeader(
                title: l.shelfTitle,
                onBack: () => context.canPop() ? context.pop() : context.go(Routes.home),
                trailing: const CartButton(),
              ),
              GlassSearchField(
                hint: l.searchHint,
                controller: _search,
                autofocus: widget.query.isEmpty,
                onSubmitted: (q) => setState(() => _query = q.trim()),
                onChanged: (q) {
                  if (q.isEmpty) setState(() => _query = '');
                },
              ),
              const SizedBox(height: DoayaSpacing.xl),
              ...switch (found) {
                AsyncData(:final value) when value.isEmpty => [
                  Center(
                    child: Text(
                      l.noResults,
                      style: DoayaTypography.bodyMedium.copyWith(color: DoayaColors.textSecondary),
                    ),
                  ),
                ],
                AsyncData(:final value) => [ShelfGrid(items: value)],
                AsyncError(:final error) => [
                  NoticeBanner(
                    message: errorText(l, error),
                    action: GlassPillButton(
                      label: l.retry,
                      size: PillSize.small,
                      onPressed: () => ref.invalidate(shelfProvider(_query)),
                    ),
                  ),
                ],
                _ => [const Center(child: CircularProgressIndicator())],
              },
              const SizedBox(height: DoayaSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// From design/patient_product_detail.html: name, what it is, available or
/// not, price, and «اطلب من صيدليتي».
class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  var _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(shelfItemProvider(widget.productId));
    final inCart = ref.watch(cartProvider)[widget.productId]?.quantity ?? 0;
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    return Scaffold(
      backgroundColor: DoayaColors.transparent,
      body: SafeArea(
        child: PhoneBody(
          child: switch (async) {
            AsyncData(value: final i) => ListView(
              children: [
                ScreenHeader(
                  title: '',
                  onBack: () => context.canPop() ? context.pop() : context.go(Routes.shelf),
                  trailing: const CartButton(),
                ),
                GlassSurface(
                  tone: SurfaceTone.strong,
                  blur: true,
                  height: DoayaSizes.productImage * 2.4,
                  borderRadius: BorderRadius.circular(DoayaRadii.hero),
                  child: Center(
                    child: ProductImage(url: i.photoUrl, size: DoayaSizes.logoLarge),
                  ),
                ),
                const SizedBox(height: DoayaSpacing.xl),
                LatinText(i.tradeName, style: DoayaTypography.title),
                if (i.arabicName != null) Text(i.arabicName!, style: secondary),
                const SizedBox(height: DoayaSpacing.ml),
                Wrap(
                  spacing: DoayaSpacing.sm,
                  runSpacing: DoayaSpacing.sm,
                  children: [
                    StatusChip(
                      label: i.available ? l.available : l.unavailable,
                      tone: i.available ? StatusTone.success : StatusTone.warning,
                    ),
                    StatusChip(
                      label: i.prescriptionOnly ? l.prescriptionOnly : l.noPrescription,
                      tone: i.prescriptionOnly ? StatusTone.warning : StatusTone.accent,
                      icon: i.prescriptionOnly ? DoayaIcons.warning : DoayaIcons.check,
                    ),
                  ],
                ),
                const SizedBox(height: DoayaSpacing.xl),
                for (final (label, value) in [
                  (l.ingredient, i.activeIngredient),
                  (l.strength, i.strength),
                  (l.dosageForm, i.form),
                ])
                  if (value != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: DoayaSpacing.xs),
                      child: Row(
                        children: [
                          SizedBox(
                            width: DoayaSizes.summaryLabelWidth,
                            child: Text(label, style: secondary),
                          ),
                          Expanded(child: LatinText(value, style: DoayaTypography.bodyMedium)),
                        ],
                      ),
                    ),
                const SizedBox(height: DoayaSpacing.ml),
                NoticeBanner(
                  message: i.prescriptionOnly ? l.rxHint : l.askPharmacistHint,
                  tone: i.prescriptionOnly ? StatusTone.warning : StatusTone.accent,
                  icon: i.prescriptionOnly ? DoayaIcons.warning : DoayaIcons.pharmacy,
                ),
                const SizedBox(height: DoayaSpacing.huge),
                Row(
                  children: [
                    Text(formatPrice(i.priceMinor, i.currency), style: DoayaTypography.price),
                    const Spacer(),
                    if (i.available)
                      QuantityStepper(
                        value: _quantity,
                        min: 1,
                        max: Cart.maxQuantity,
                        onChanged: (q) => setState(() => _quantity = q),
                      ),
                  ],
                ),
                const SizedBox(height: DoayaSpacing.l),
                SagePillButton(
                  label: i.available ? l.orderFromPharmacy : l.unavailable,
                  icon: DoayaIcons.bag,
                  size: PillSize.large,
                  expand: true,
                  onPressed: i.available
                      ? () {
                          ref.read(cartProvider.notifier).add(i, _quantity);
                          toast(context, l.addedToCart);
                        }
                      : null,
                ),
                if (inCart > 0) ...[
                  const SizedBox(height: DoayaSpacing.sm),
                  GlassPillButton(
                    label: '${l.viewCart} (${l.inCart(formatNumber(inCart))})',
                    expand: true,
                    onPressed: () => context.push(Routes.cart),
                  ),
                ],
                const SizedBox(height: DoayaSpacing.xl),
              ],
            ),
            AsyncError(:final error) => Center(child: NoticeBanner(message: errorText(l, error))),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }
}
