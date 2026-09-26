import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../central/central_api.dart';
import '../../central/inbox_controller.dart';
import '../../central/pickup.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
import '../format.dart';
import '../patient_photo.dart';
import '../widgets.dart';
import 'cases_screen.dart' show patientLine;
import 'sync_screen.dart' show syncErrorText;

/// A patient's pickup order: they asked for quantities, the pharmacist sets
/// the final ones (0 drops a line), then it's ready and sold at the counter.
class OrderDetailView extends ConsumerStatefulWidget {
  const OrderDetailView({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends ConsumerState<OrderDetailView> {
  final _quantities = <String, int>{};
  final _note = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _set(String status) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final note = _note.text.trim();
      await ref
          .read(centralApiProvider)!
          .setOrderStatus(
            widget.orderId,
            status,
            quantities: _quantities.isEmpty ? null : Map.of(_quantities),
            note: note.isEmpty ? null : note,
          );
      _quantities.clear();
      await ref.read(inboxProvider.notifier).refresh();
    } on Object catch (e) {
      if (mounted) toast(context, syncErrorText(l, e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _pickup(PatientOrder o) {
    final api = ref.read(centralApiProvider)!;
    ref
        .read(pendingSaleProvider.notifier)
        .set(
          PendingSale(
            lines: [for (final line in o.lines) (line.productId, line.quantity)],
            onSold: () => api.setOrderStatus(o.id, OrderStatus.pickedUp),
          ),
        );
    context.go(Routes.pos);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    final stock = ref.watch(stockProvider).value;
    final products = ref.watch(productsByIdProvider);
    final o = ref.watch(inboxProvider).orders.where((o) => o.id == widget.orderId).firstOrNull;
    if (o == null) return Panel(child: EmptyHint(l.chooseCase));
    final secondary = DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary);
    int qty(OrderLine line) => _quantities[line.productId] ?? line.quantity;
    final total = o.lines.fold(0, (s, line) => s + qty(line) * line.priceMinor);

    return Panel(
      title: o.patient.name,
      trailing: StatusChip(
        label: l.orderStatus(o.status),
        tone: o.open ? StatusTone.warning : StatusTone.neutral,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            [
              patientLine(l, o.patient),
              ltrIsolate(o.patient.phone),
              if (o.handledBy != null) l.handledBy(o.handledBy!),
            ].where((s) => s.isNotEmpty).join('، '),
            style: secondary,
          ),
          if (o.photoId case final photo?) ...[
            SizedBox(height: DoayaSpacing.sm),
            Row(
              children: [
                PatientPhoto(id: photo),
                SizedBox(width: DoayaSpacing.ml),
                Expanded(child: Text(l.prescriptionPhoto, style: secondary)),
              ],
            ),
          ],
          if (o.note != null) ...[
            SizedBox(height: DoayaSpacing.sm),
            NoticeBanner(message: l.orderPatientNote(o.note!)),
          ],
          SizedBox(height: DoayaSpacing.l),
          for (final line in o.lines)
            Padding(
              padding: EdgeInsets.only(bottom: DoayaSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LatinText(line.name, style: DoayaTypography.label),
                        Text(
                          [
                            l.orderRequested(formatQty(line.requested)),
                            formatMoney(line.priceMinor, currency),
                            switch (stock?.onHand(line.productId) ?? 0) {
                              <= 0 => l.outOfStock,
                              final n => l.onHandShort(
                                formatStock(l, n, products[line.productId]?.unitsPerPack ?? 1),
                              ),
                            },
                          ].join('، '),
                          style: secondary,
                        ),
                      ],
                    ),
                  ),
                  if (o.open)
                    QtyStepper(
                      value: qty(line),
                      max: 100,
                      onChanged: (q) => setState(() => _quantities[line.productId] = q),
                    )
                  else
                    Text(formatQty(line.quantity), style: DoayaTypography.label),
                ],
              ),
            ),
          Divider(color: DoayaColors.divider),
          Text(
            l.orderTotal(formatMoney(total, currency)),
            style: DoayaTypography.label.copyWith(color: DoayaColors.price),
          ),
          if (o.pharmacistNote != null) ...[
            SizedBox(height: DoayaSpacing.sm),
            Text(o.pharmacistNote!, style: secondary),
          ],
          SizedBox(height: DoayaSpacing.l),
          if (o.open) ...[
            GlassTextField(label: l.pharmacistNoteLabel, controller: _note, maxLines: 2),
            SizedBox(height: DoayaSpacing.l),
            SagePillButton(
              label: l.markOrderReady,
              icon: DoayaIcons.check,
              size: PillSize.medium,
              expand: true,
              onPressed: _busy ? null : () => _set(OrderStatus.ready),
            ),
            SizedBox(height: DoayaSpacing.sm),
            Wrap(
              spacing: DoayaSpacing.sm,
              children: [
                if (o.status == OrderStatus.sent)
                  GlassPillButton(
                    label: l.startPreparing,
                    onPressed: _busy ? null : () => _set(OrderStatus.preparing),
                  ),
                GlassPillButton(
                  label: l.rejectOrder,
                  onPressed: _busy ? null : () => _set(OrderStatus.rejected),
                ),
              ],
            ),
          ],
          if (o.status == OrderStatus.ready)
            SagePillButton(
              label: l.pickupAndSell,
              icon: DoayaIcons.pos,
              size: PillSize.medium,
              expand: true,
              onPressed: () => _pickup(o),
            ),
        ],
      ),
    );
  }
}
