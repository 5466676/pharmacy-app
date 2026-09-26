import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../data/providers.dart';
import '../data/shop.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';
import 'common.dart';
import 'photo_widgets.dart';
import 'shelf_screens.dart' show CartButton;

/// «طلباتي»: the pickup orders, newest first.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final all = ref.watch(ordersProvider);
    final secondary = DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(ordersProvider.future),
      child: PhoneBody(
        child: ListView(
          children: [
            ScreenHeader(title: l.ordersTitle, trailing: const CartButton()),
            ...switch (all) {
              AsyncData(:final value) when value.isEmpty => [
                const SizedBox(height: DoayaSpacing.huge),
                Text(
                  l.noOrders,
                  textAlign: TextAlign.center,
                  style: DoayaTypography.bodyMedium.copyWith(color: DoayaColors.textSecondary),
                ),
                const SizedBox(height: DoayaSpacing.l),
                Center(
                  child: GlassPillButton(
                    label: l.browseShelf,
                    icon: DoayaIcons.medicine,
                    onPressed: () => context.push(Routes.shelf),
                  ),
                ),
              ],
              AsyncData(:final value) => [
                for (final o in value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: DoayaSpacing.sm),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(DoayaRadii.card),
                        onTap: () => context.push(Routes.order(o.id)),
                        child: GlassSurface(
                          borderRadius: BorderRadius.circular(DoayaRadii.card),
                          padding: const EdgeInsets.all(DoayaSpacing.l),
                          child: Row(
                            children: [
                              const Icon(DoayaIcons.bag, color: DoayaColors.accent),
                              const SizedBox(width: DoayaSpacing.ml),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LatinText(
                                      o.lines.map((x) => x.name).join(', '),
                                      style: DoayaTypography.label,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      [
                                        l.orderLines(o.lines.length),
                                        formatPrice(o.totalMinor, o.currency),
                                        formatDate(o.createdAt),
                                      ].join('، '),
                                      style: secondary,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: DoayaSpacing.sm),
                              StatusChip(label: l.orderStatus(o.status), tone: orderTone(o.status)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
              AsyncError(:final error) => [
                NoticeBanner(
                  message: errorText(l, error),
                  action: GlassPillButton(
                    label: l.retry,
                    size: PillSize.small,
                    onPressed: () => ref.invalidate(ordersProvider),
                  ),
                ),
              ],
              _ => [const Center(child: CircularProgressIndicator())],
            },
          ],
        ),
      ),
    );
  }
}

/// One order: what was asked, what the pharmacist settled on, the steps.
class OrderScreen extends ConsumerWidget {
  const OrderScreen({super.key, required this.id});

  final String id;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDoayaDialog<bool>(
      context: context,
      title: l.cancelOrder,
      content: Text(l.cancelOrderConfirm, style: DoayaTypography.bodyMedium),
      actions: [
        GlassPillButton(label: l.keepOrder, onPressed: () => Navigator.pop(context, false)),
        SagePillButton(label: l.cancelOrder, onPressed: () => Navigator.pop(context, true)),
      ],
    );
    if (!(ok ?? false)) return;
    try {
      await ref.read(orderProvider(id).notifier).cancel();
    } on Object catch (e) {
      if (context.mounted) toast(context, errorText(l, e), error: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(orderProvider(id));
    final pharmacy = ref.watch(authProvider).patient?.pharmacy;
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    return Scaffold(
      backgroundColor: DoayaColors.transparent,
      body: SafeArea(
        child: PhoneBody(
          child: switch (async) {
            AsyncValue(value: final o?) => ListView(
              children: [
                ScreenHeader(
                  title: l.orderTitle(formatDate(o.createdAt)),
                  onBack: () => context.canPop() ? context.pop() : context.go(Routes.orders),
                  trailing: StatusChip(label: l.orderStatus(o.status), tone: orderTone(o.status)),
                ),
                if (!{OrderStatus.rejected, OrderStatus.cancelled}.contains(o.status)) ...[
                  _OrderSteps(status: o.status),
                  const SizedBox(height: DoayaSpacing.l),
                ],
                GlassSurface(
                  borderRadius: BorderRadius.circular(DoayaRadii.cardLarge),
                  padding: const EdgeInsets.all(DoayaSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final line in o.lines)
                        Padding(
                          padding: const EdgeInsets.only(bottom: DoayaSpacing.ml),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LatinText(
                                      line.name,
                                      style: DoayaTypography.label.copyWith(
                                        color: line.quantity == 0
                                            ? DoayaColors.textSecondary
                                            : null,
                                      ),
                                    ),
                                    if (line.changed)
                                      Text(
                                        line.quantity == 0
                                            ? l.lineDropped(formatNumber(line.requested))
                                            : l.lineChanged(
                                                formatNumber(line.requested),
                                                formatNumber(line.quantity),
                                              ),
                                        style: DoayaTypography.caption.copyWith(
                                          color: DoayaColors.warningText,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                l.lineQtyPrice(
                                  formatNumber(line.quantity),
                                  formatPrice(line.priceMinor, o.currency),
                                ),
                                style: secondary,
                              ),
                            ],
                          ),
                        ),
                      const Divider(color: DoayaColors.divider),
                      Text(
                        l.orderTotal(formatPrice(o.totalMinor, o.currency)),
                        style: DoayaTypography.lead.copyWith(color: DoayaColors.price),
                      ),
                    ],
                  ),
                ),
                if (o.photoId case final photo?) ...[
                  const SizedBox(height: DoayaSpacing.ml),
                  // A ListView stretches its children: keep the thumbnail square.
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: PhotoThumb(id: photo, size: DoayaSizes.productImage),
                  ),
                ],
                if (o.note != null) ...[
                  const SizedBox(height: DoayaSpacing.ml),
                  Text('${l.noteToPharmacist}: ${o.note}', style: secondary),
                ],
                if (o.pharmacistNote != null) ...[
                  const SizedBox(height: DoayaSpacing.ml),
                  NoticeBanner(
                    message: [
                      if (o.handledBy != null) l.decisionBy(o.handledBy!),
                      o.pharmacistNote!,
                    ].join(': '),
                    tone: StatusTone.accent,
                    icon: DoayaIcons.pharmacy,
                  ),
                ],
                if (pharmacy != null && !o.finished) ...[
                  const SizedBox(height: DoayaSpacing.ml),
                  StatusChip(label: l.pickupAt(pharmacy.name), tone: StatusTone.accent),
                ],
                if (o.cancellable) ...[
                  const SizedBox(height: DoayaSpacing.huge),
                  GlassPillButton(
                    label: l.cancelOrder,
                    icon: DoayaIcons.close,
                    expand: true,
                    onPressed: () => _cancel(context, ref),
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

class _OrderSteps extends StatelessWidget {
  const _OrderSteps({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const order = [
      OrderStatus.sent,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.pickedUp,
    ];
    final labels = [l.stepSent, l.stepPreparing, l.stepReady, l.stepPickedUp];
    final at = order.indexOf(status);
    return GlassSurface(
      borderRadius: BorderRadius.circular(DoayaRadii.card),
      padding: const EdgeInsets.all(DoayaSpacing.l),
      child: Row(
        children: [
          for (var i = 0; i < order.length; i++)
            Expanded(
              child: Column(
                children: [
                  Icon(
                    i <= at ? DoayaIcons.check : DoayaIcons.clock,
                    size: DoayaSizes.iconS,
                    color: i <= at ? DoayaColors.accent : DoayaColors.dotInactive,
                  ),
                  const SizedBox(height: DoayaSpacing.xs),
                  Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: DoayaTypography.caption.copyWith(
                      color: i == at ? DoayaColors.accent : DoayaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
