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
import '../whatsapp.dart';
import 'purchases_screen.dart' show showAddSupplierDialog, showSupplierPicker;

typedef LastPurchase = ({String supplierId, int unitPriceMinor, int piecesPerUnit});

/// The shortage list and each product's last supplier; refreshes with stock.
final _shortagesProvider = FutureProvider<(List<Shortage>, Map<String, LastPurchase>)>((ref) async {
  ref
    ..watch(stockProvider)
    ..watch(productsProvider);
  final acc = ref.watch(accountingProvider);
  return (await acc.shortages(), await acc.lastPurchases());
});

final _ordersProvider = StreamProvider<List<PurchaseOrderRow>>(
  (ref) => ref.watch(accountingProvider).watchOrders(),
);

final _orderLinesProvider = StreamProvider<List<PurchaseOrderLineRow>>(
  (ref) => ref.watch(accountingProvider).watchOrderLines(),
);

/// النواقص: what to reorder, with a suggested quantity and the last supplier.
/// Ticked lines become one draft order per supplier.
class ShortagesTab extends ConsumerStatefulWidget {
  const ShortagesTab({super.key, required this.onOrdersCreated});

  final VoidCallback onOrdersCreated;

  @override
  ConsumerState<ShortagesTab> createState() => _ShortagesTabState();
}

class _ShortagesTabState extends ConsumerState<ShortagesTab> {
  final _unticked = <String>{};
  final _qty = <String, int>{};
  final _supplier = <String, SupplierRow>{};
  var _busy = false;

  Future<void> _create(List<Shortage> list, Map<String, LastPurchase> last) async {
    final l = AppLocalizations.of(context);
    final suppliers = {
      for (final s in ref.read(suppliersProvider).value ?? const <SupplierRow>[]) s.id: s,
    };
    final bySupplier = <String, List<(String, int)>>{};
    for (final s in list) {
      if (_unticked.contains(s.productId)) continue;
      final supplierId = _supplier[s.productId]?.id ?? last[s.productId]?.supplierId;
      if (supplierId == null || !suppliers.containsKey(supplierId)) {
        toast(context, l.errShortageNeedsSupplier, error: true);
        return;
      }
      bySupplier.putIfAbsent(supplierId, () => []).add((
        s.productId,
        _qty[s.productId] ?? s.suggestedPacks,
      ));
    }
    setState(() => _busy = true);
    try {
      final ids = await ref.read(accountingProvider).createOrders(bySupplier);
      if (!mounted) return;
      toast(context, l.ordersCreated(formatQty(ids.length)));
      setState(() {
        _unticked.clear();
        _qty.clear();
      });
      widget.onOrdersCreated();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final owner = ref.watch(requireSessionProvider).isOwner;
    final currency = ref.watch(currencyProvider);
    final products = ref.watch(productsByIdProvider);
    final suppliers = {
      for (final s in ref.watch(suppliersProvider).value ?? const <SupplierRow>[]) s.id: s,
    };
    final data = ref.watch(_shortagesProvider).value;
    if (data == null) return const SizedBox.shrink();
    final (all, last) = data;
    final list = all.where((s) => products.containsKey(s.productId)).toList();
    if (list.isEmpty) return EmptyHint(l.noShortages);
    final ticked = list.where((s) => !_unticked.contains(s.productId)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (!isPhoneLayout(context)) const Spacer(),
            Flexible(
              child: SagePillButton(
                label: l.createOrders(formatQty(ticked)),
                icon: DoayaIcons.send,
                size: PillSize.medium,
                expand: isPhoneLayout(context),
                onPressed: _busy || ticked == 0 ? null : () => _create(list, last),
              ),
            ),
          ],
        ),
        SizedBox(height: DoayaSpacing.ml),
        Expanded(
          child: ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, _) => SizedBox(height: DoayaSpacing.s),
            itemBuilder: (context, i) {
              final s = list[i];
              final p = products[s.productId]!;
              final lp = last[s.productId];
              final supplier = _supplier[s.productId] ?? suppliers[lp?.supplierId];
              final on = !_unticked.contains(s.productId);
              final (reason, tone) = switch (s.reason) {
                ShortageReason.outOfStock => (l.reasonOutOfStock, StatusTone.danger),
                ShortageReason.belowMinimum => (l.reasonBelowMinimum, StatusTone.warning),
                ShortageReason.sellingFast => (l.reasonSellingFast, StatusTone.neutral),
              };
              final check = Checkbox(
                value: on,
                activeColor: DoayaColors.accent,
                onChanged: (v) => setState(
                  () => v == true ? _unticked.remove(s.productId) : _unticked.add(s.productId),
                ),
              );
              final reasonInfo = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusChip(label: reason, tone: tone),
                  SizedBox(height: DoayaSpacing.xxs),
                  Text(
                    [
                      formatStock(l, s.onHandPieces, p.unitsPerPack),
                      if (s.daysLeft != null && s.onHandPieces > 0)
                        l.runsOutIn(formatQty(s.daysLeft!)),
                    ].join('، '),
                    style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
                  ),
                ],
              );
              final qty = QtyStepper(
                value: _qty[s.productId] ?? s.suggestedPacks,
                max: 9999,
                onChanged: (v) => setState(() {
                  if (v <= 0) {
                    _unticked.add(s.productId);
                  } else {
                    _qty[s.productId] = v;
                  }
                }),
              );
              final supplierPick = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassPillButton(
                    label: supplier?.name ?? l.chooseSupplier,
                    selected: supplier != null,
                    expand: true,
                    onPressed: () async {
                      final picked = await showSupplierPicker(context);
                      if (picked != null) {
                        setState(() => _supplier[s.productId] = picked);
                      }
                    },
                  ),
                  if (owner && lp != null && lp.supplierId == supplier?.id)
                    Padding(
                      padding: EdgeInsets.only(top: DoayaSpacing.xxs),
                      child: Text(
                        l.lastPrice(formatMoney(lp.unitPriceMinor, currency)),
                        textAlign: TextAlign.center,
                        style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
                      ),
                    ),
                ],
              );
              if (isPhoneLayout(context)) {
                // Phone: name + quantity, the reason, then the supplier.
                return GlassSurface(
                  shadow: false,
                  borderRadius: BorderRadius.circular(DoayaRadii.tile),
                  padding: EdgeInsets.all(DoayaSpacing.ml),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          check,
                          Expanded(
                            child: ProductName(product: p, muted: !on),
                          ),
                          qty,
                        ],
                      ),
                      SizedBox(height: DoayaSpacing.xs),
                      reasonInfo,
                      SizedBox(height: DoayaSpacing.sm),
                      supplierPick,
                    ],
                  ),
                );
              }
              return GlassSurface(
                shadow: false,
                borderRadius: BorderRadius.circular(DoayaRadii.tile),
                padding: EdgeInsets.all(DoayaSpacing.ml),
                child: Row(
                  children: [
                    check,
                    SizedBox(width: DoayaSpacing.sm),
                    Expanded(
                      flex: 3,
                      child: ProductName(product: p, muted: !on),
                    ),
                    Expanded(flex: 3, child: reasonInfo),
                    qty,
                    SizedBox(width: DoayaSpacing.l),
                    SizedBox(
                      width: DoayaSizes.employeeTile + DoayaSpacing.huge,
                      child: supplierPick,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// الطلبيات: orders by status; open one to edit, copy it for WhatsApp /
/// Telegram, or turn it into a purchase invoice when the goods arrive.
class OrdersTab extends ConsumerWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final orders = ref.watch(_ordersProvider).value ?? const <PurchaseOrderRow>[];
    final lines = ref.watch(_orderLinesProvider).value ?? const <PurchaseOrderLineRow>[];
    final suppliers = {
      for (final s in ref.watch(suppliersProvider).value ?? const <SupplierRow>[]) s.id: s,
    };
    if (orders.isEmpty) return EmptyHint(l.noOrders);

    return ListView.separated(
      itemCount: orders.length,
      separatorBuilder: (_, _) => SizedBox(height: DoayaSpacing.s),
      itemBuilder: (context, i) {
        final o = orders[i];
        final name = suppliers[o.supplierId]?.name ?? l.none;
        final count = lines.where((x) => x.orderId == o.id).length;
        return CaseRow(
          initials: initialsOf(name),
          title: name,
          subtitle: '${formatDate(o.createdAt)}، ${l.itemsCount(formatQty(count))}',
          trailing: orderStatusChip(l, o.status),
          onTap: () => showDialog<void>(
            context: context,
            useRootNavigator: false,
            barrierColor: DoayaColors.scrim,
            builder: (_) => _OrderDialog(orderId: o.id),
          ),
        );
      },
    );
  }
}

StatusChip orderStatusChip(AppLocalizations l, String status) => switch (status) {
  'sent' => StatusChip(label: l.orderSent, tone: StatusTone.warning),
  'received' => StatusChip(label: l.orderReceived, tone: StatusTone.accent),
  _ => StatusChip(label: l.orderDraft),
};

/// The message sent to the supplier. Each line starts with a number and the
/// Latin drug name, so chat apps lay it out left to right and keep it tidy.
String orderMessage(
  AppLocalizations l, {
  required String pharmacy,
  required DateTime date,
  required List<(String, int)> lines,
}) => [
  l.orderMessageHeader(pharmacy),
  l.orderMessageDate(formatDate(date)),
  '',
  for (final (i, (name, qty)) in lines.indexed) '${i + 1}. $name: ${l.units(formatQty(qty))}',
  '',
  l.orderMessageThanks,
].join('\n');

class _OrderDialog extends ConsumerWidget {
  const _OrderDialog({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final order = (ref.watch(_ordersProvider).value ?? const <PurchaseOrderRow>[])
        .where((o) => o.id == orderId)
        .firstOrNull;
    if (order == null) return const SizedBox.shrink();
    final lines = (ref.watch(_orderLinesProvider).value ?? const <PurchaseOrderLineRow>[])
        .where((x) => x.orderId == orderId)
        .toList();
    final products = ref.watch(productsByIdProvider);
    final supplier = (ref.watch(suppliersProvider).value ?? const <SupplierRow>[])
        .where((s) => s.id == order.supplierId)
        .firstOrNull;
    final acc = ref.read(accountingProvider);
    final open = order.status != 'received';

    String message() => orderMessage(
      l,
      pharmacy: ref.read(settingsProvider).value?['pharmacy_name'] ?? l.appName,
      date: ref.read(clockProvider)(),
      lines: [for (final x in lines) (products[x.productId]?.tradeName ?? l.none, x.quantity)],
    );

    Future<void> copy() async {
      await Clipboard.setData(ClipboardData(text: message()));
      if (order.status == 'draft') await acc.setOrderStatus(orderId, 'sent');
      if (context.mounted) toast(context, l.orderCopied);
    }

    // Opens the supplier's chat with the order typed in. Without a number,
    // asks for it first. The message is also copied, in case WhatsApp
    // doesn't take the text.
    Future<void> sendWhatsApp() async {
      var number = whatsappNumber(supplier?.phone);
      if (number == null && supplier != null) {
        toast(context, l.errNoPhone, error: true);
        final updated = await showAddSupplierDialog(context, ref, existing: supplier);
        number = whatsappNumber(updated?.phone);
      }
      if (number == null) return;
      final text = message();
      await Clipboard.setData(ClipboardData(text: text));
      final opened = await ref.read(whatsappProvider)(number, text: text);
      if (order.status == 'draft') await acc.setOrderStatus(orderId, 'sent');
      if (!opened && context.mounted) toast(context, l.whatsappFailed, error: true);
    }

    return Dialog(
      backgroundColor: DoayaColors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: DoayaSizes.formWidth,
          maxHeight: DoayaSizes.wideFormWidth,
        ),
        child: GlassSurface(
          tone: SurfaceTone.strong,
          blur: true,
          borderRadius: BorderRadius.circular(DoayaRadii.hero),
          padding: EdgeInsets.all(DoayaSpacing.huge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.orderTitle(supplier?.name ?? l.none),
                      style: DoayaTypography.titleSmall,
                    ),
                  ),
                  orderStatusChip(l, order.status),
                ],
              ),
              SizedBox(height: DoayaSpacing.l),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final x in lines)
                      Padding(
                        padding: EdgeInsets.only(bottom: DoayaSpacing.sm),
                        child: Row(
                          children: [
                            Expanded(
                              child: LatinText(
                                products[x.productId]?.tradeName ?? l.none,
                                maxLines: 1,
                                style: DoayaTypography.label,
                              ),
                            ),
                            if (open)
                              QtyStepper(
                                value: x.quantity,
                                max: 9999,
                                onChanged: (v) => acc.setOrderLineQuantity(x.id, v),
                              )
                            else
                              Text(l.units(formatQty(x.quantity)), style: DoayaTypography.label),
                          ],
                        ),
                      ),
                    if (lines.isEmpty) EmptyHint(l.noOrders),
                  ],
                ),
              ),
              SizedBox(height: DoayaSpacing.xl),
              Wrap(
                spacing: DoayaSpacing.sm,
                runSpacing: DoayaSpacing.sm,
                children: [
                  if (open && lines.isNotEmpty) ...[
                    SagePillButton(
                      label: l.sendWhatsApp,
                      icon: DoayaIcons.chat,
                      size: PillSize.small,
                      onPressed: sendWhatsApp,
                    ),
                    GlassPillButton(label: l.copyOrder, icon: DoayaIcons.share, onPressed: copy),
                    GlassPillButton(
                      label: l.receiveOrder,
                      icon: DoayaIcons.receive,
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go(Routes.purchaseFromOrder(orderId));
                      },
                    ),
                  ],
                  if (open)
                    GlassPillButton(
                      label: l.deleteOrder,
                      icon: DoayaIcons.delete,
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await acc.deleteOrder(orderId);
                      },
                    ),
                  GlassPillButton(label: l.close, onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
