import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../data/shop.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';
import 'common.dart';
import 'photo_widgets.dart';
import '../data/photos.dart';

/// From design/patient_order.html: the lines, a note, where to pick it up,
/// the total, «أرسل الطلب للصيدلية». Paid at the pharmacy.
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _note = TextEditingController();
  PickedPhoto? _photo;
  var _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final o = await ref.read(cartProvider.notifier).order(note: _note.text, photo: _photo);
      if (!mounted) return;
      toast(context, l.orderSent);
      // Back from the order goes to «طلباتي», not to the empty cart.
      GoRouter.of(context)
        ..go(Routes.orders)
        ..push(Routes.order(o.id));
    } on Object catch (e) {
      if (mounted) toast(context, errorText(l, e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lines = ref.watch(cartProvider).values.toList();
    final total = ref.watch(cartTotalProvider);
    final pharmacy = ref.watch(authProvider).patient?.pharmacy;
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    final card = BorderRadius.circular(DoayaRadii.card);
    return Scaffold(
      backgroundColor: DoayaColors.transparent,
      body: SafeArea(
        child: PhoneBody(
          child: ListView(
            children: [
              ScreenHeader(
                title: l.cartTitle,
                onBack: () => context.canPop() ? context.pop() : context.go(Routes.home),
              ),
              if (lines.isEmpty) ...[
                SizedBox(height: DoayaSpacing.huge),
                Text(l.cartEmpty, textAlign: TextAlign.center, style: secondary),
                SizedBox(height: DoayaSpacing.l),
                Center(
                  child: GlassPillButton(
                    label: l.browseShelf,
                    icon: DoayaIcons.medicine,
                    onPressed: () => context.push(Routes.shelf),
                  ),
                ),
              ] else ...[
                for (final line in lines)
                  Padding(
                    padding: EdgeInsets.only(bottom: DoayaSpacing.sm),
                    child: GlassSurface(
                      borderRadius: card,
                      padding: EdgeInsets.all(DoayaSpacing.ml),
                      child: Row(
                        children: [
                          SizedBox.square(
                            dimension: DoayaSizes.productThumb,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: DoayaColors.imageWell,
                                borderRadius: BorderRadius.circular(DoayaRadii.imageWell),
                              ),
                              child: Center(
                                child: ProductImage(
                                  url: line.item.photoUrl,
                                  size: DoayaSizes.iconL,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: DoayaSpacing.ml),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LatinText(line.item.tradeName, style: DoayaTypography.label),
                                Text(
                                  formatPrice(line.item.priceMinor, line.item.currency),
                                  style: DoayaTypography.priceSmall,
                                ),
                                if (line.item.prescriptionOnly)
                                  Text(l.prescriptionOnly, style: secondary),
                              ],
                            ),
                          ),
                          QuantityStepper(
                            value: line.quantity,
                            max: Cart.maxQuantity,
                            onChanged: (q) => ref.read(cartProvider.notifier).set(line.item, q),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: DoayaSpacing.l),
                GlassTextField(label: l.noteToPharmacist, controller: _note, maxLines: 2),
                SizedBox(height: DoayaSpacing.l),
                if (_photo case final photo?)
                  Row(
                    children: [
                      PhotoThumb(bytes: photo.bytes, size: DoayaSizes.productImage),
                      SizedBox(width: DoayaSpacing.ml),
                      Expanded(child: Text(l.prescriptionPhotoHint, style: secondary)),
                      GlassPillButton(
                        label: l.removePhoto,
                        size: PillSize.small,
                        onPressed: () => setState(() => _photo = null),
                      ),
                    ],
                  )
                else
                  GlassPillButton(
                    label: l.attachPrescription,
                    icon: DoayaIcons.camera,
                    expand: true,
                    onPressed: () async {
                      final picked = await pickPhoto(context, ref);
                      if (picked != null && mounted) setState(() => _photo = picked);
                    },
                  ),
                SizedBox(height: DoayaSpacing.l),
                if (pharmacy != null)
                  GlassSurface(
                    borderRadius: card,
                    padding: EdgeInsets.all(DoayaSpacing.l),
                    child: Row(
                      children: [
                        Icon(DoayaIcons.pharmacy, color: DoayaColors.accent),
                        SizedBox(width: DoayaSpacing.ml),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.pickupFrom(pharmacy.name), style: DoayaTypography.label),
                              if (pharmacy.hours != null)
                                Text(l.pharmacyHours(pharmacy.hours!), style: secondary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: DoayaSpacing.l),
                Text(
                  l.orderTotal(formatPrice(total, lines.first.item.currency)),
                  style: DoayaTypography.lead.copyWith(color: DoayaColors.price),
                ),
                Text(l.finalQuantitiesHint, style: secondary),
                SizedBox(height: DoayaSpacing.l),
                BusyButton(label: l.sendOrder, busy: _busy, onPressed: _send),
                SizedBox(height: DoayaSpacing.sm),
                Text(l.payAtPickup, textAlign: TextAlign.center, style: secondary),
              ],
              SizedBox(height: DoayaSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
