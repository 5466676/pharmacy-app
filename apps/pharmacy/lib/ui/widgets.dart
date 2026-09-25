import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../l10n/app_localizations.dart';
import 'format.dart';

/// Whether this window uses the phone layout (bottom navigation, one column).
bool isPhoneLayout(BuildContext context) =>
    MediaQuery.sizeOf(context).width < DoayaSizes.phoneLayoutWidth;

/// Screen title row with optional trailing actions.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.actions = const [], this.leading});

  final String title;
  final List<Widget> actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final titleRow = Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: DoayaSpacing.ml)],
        Expanded(child: Text(title, style: DoayaTypography.title)),
        if (!isPhoneLayout(context))
          for (final a in actions) ...[const SizedBox(width: DoayaSpacing.sm), a],
      ],
    );
    if (!isPhoneLayout(context) || actions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: DoayaSpacing.xl),
        child: titleRow,
      );
    }
    // Phone: actions wrap under the title.
    return Padding(
      padding: const EdgeInsets.only(bottom: DoayaSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titleRow,
          const SizedBox(height: DoayaSpacing.sm),
          Wrap(spacing: DoayaSpacing.sm, runSpacing: DoayaSpacing.sm, children: actions),
        ],
      ),
    );
  }
}

/// A main pane and a side pane: side by side on desktop, stacked on a phone.
class SplitPanes extends StatelessWidget {
  const SplitPanes({
    super.key,
    required this.main,
    required this.side,
    this.sideWidth = DoayaSizes.invoiceWidth,
  });

  final Widget main;
  final Widget side;
  final double sideWidth;

  @override
  Widget build(BuildContext context) {
    if (isPhoneLayout(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          main,
          const SizedBox(height: DoayaSpacing.l),
          side,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: main),
        const SizedBox(width: DoayaSpacing.xl),
        SizedBox(width: sideWidth, child: side),
      ],
    );
  }
}

/// Large card with a title (dashboard panels, detail sections).
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.title, this.trailing, this.padding});

  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      borderRadius: BorderRadius.circular(DoayaRadii.hero),
      padding:
          padding ?? EdgeInsets.all(isPhoneLayout(context) ? DoayaSpacing.l : DoayaSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            if (isPhoneLayout(context) && trailing != null) ...[
              // Phone: the actions go under the title.
              Text(title!, style: DoayaTypography.lead),
              const SizedBox(height: DoayaSpacing.sm),
              Align(alignment: AlignmentDirectional.centerStart, child: trailing),
            ] else
              Row(
                children: [
                  Expanded(child: Text(title!, style: DoayaTypography.lead)),
                  ?trailing,
                ],
              ),
            const SizedBox(height: DoayaSpacing.l),
          ],
          child,
        ],
      ),
    );
  }
}

/// Muted centred text for empty lists.
class EmptyHint extends StatelessWidget {
  const EmptyHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(DoayaSpacing.huge),
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
      ),
    ),
  );
}

/// "4 علبة" / "2 علبة و1 ظرف" / "2 ظرف", from a stock count in pieces.
String formatStock(AppLocalizations l, int pieces, int unitsPerPack) {
  if (unitsPerPack <= 1) return l.units(formatQty(pieces));
  final (packs, loose) = splitPieces(pieces, unitsPerPack);
  if (loose == 0) return l.units(formatQty(packs));
  if (packs == 0) return l.stripsOnly(formatQty(loose));
  return l.packsAndStrips(formatQty(packs), formatQty(loose));
}

/// Stock chip: "متوفر: 24 علبة" / "باقي 3 علبة" / "نفد".
class StockChip extends StatelessWidget {
  const StockChip({super.key, required this.product, required this.onHand});

  final ProductRow product;

  /// In pieces (strips when the box is split).
  final int onHand;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = formatStock(l, onHand, product.unitsPerPack);
    if (onHand <= 0) return StatusChip(label: l.outOfStock, tone: StatusTone.danger);
    if (onHand <= lowStockPieces(product)) {
      return StatusChip(label: l.lowLeft(text), tone: StatusTone.warning);
    }
    return StatusChip(label: l.inStock(text), tone: StatusTone.accent);
  }
}

/// The low-stock threshold (set in boxes) in pieces.
int lowStockPieces(ProductRow p) => p.lowStockThreshold * (p.unitsPerPack < 1 ? 1 : p.unitsPerPack);

/// Product name block: Latin trade name + Arabic name / ingredient under it.
class ProductName extends StatelessWidget {
  const ProductName({super.key, required this.product, this.muted = false});

  final ProductRow product;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    // Latin parts are isolated so the RTL line doesn't reorder them.
    final sub = [
      if (product.arabicName != null) product.arabicName!,
      ltrIsolate(product.activeIngredient),
      if (product.strength != null) ltrIsolate(product.strength!),
    ].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LatinText(
          product.tradeName,
          maxLines: 1,
          style: DoayaTypography.label.copyWith(
            color: muted ? DoayaColors.textSecondary : DoayaColors.textPrimary,
          ),
        ),
        const SizedBox(height: DoayaSpacing.xxs),
        Text(
          sub,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
        ),
      ],
    );
  }
}

/// User-facing message for a failed sale.
String saleErrorText(AppLocalizations l, SaleError e) => switch (e) {
  SaleError.emptyCart => l.errEmptyCart,
  SaleError.debtNeedsCustomer => l.errDebtNeedsCustomer,
  SaleError.discountTooLarge => l.errDiscount,
  SaleError.insufficientStock => l.errStock,
  SaleError.badQuantity => l.errBadQty,
  SaleError.tenderedTooLow => l.errTendered,
};

String stockEventLabel(AppLocalizations l, StockEventType t) => switch (t) {
  StockEventType.received => l.evReceived,
  StockEventType.sold => l.evSold,
  StockEventType.returned => l.evReturned,
  StockEventType.adjusted => l.evAdjusted,
  StockEventType.expiredRemoved => l.evExpiredRemoved,
  StockEventType.returnedToSupplier => l.evReturnedToSupplier,
};

/// Parses "d/m/yyyy" (English or Arabic-keyboard digits). Null if empty or invalid.
DateTime? parseDate(String input) {
  final s = toLatinDigits(input.trim());
  final m = RegExp(r'^(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{2,4})$').firstMatch(s);
  if (m == null) return null;
  final d = int.parse(m[1]!), mo = int.parse(m[2]!);
  var y = int.parse(m[3]!);
  if (y < 100) y += 2000;
  final date = DateTime.utc(y, mo, d);
  if (date.day != d || date.month != mo) return null;
  return date;
}

/// Shows a short message at the bottom.
void toast(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? DoayaColors.dangerText : DoayaColors.accent,
        content: Text(message, style: DoayaTypography.label.copyWith(color: DoayaColors.onSage)),
      ),
    );
}

/// Asks for an amount (and optionally a reason). Returns (minor units, note)
/// or null when cancelled.
Future<(int, String?)?> askAmount(
  BuildContext context, {
  required String title,
  required String label,
  required Currency currency,
  String? help,
  String? noteLabel,
  bool allowZero = true,
  String initial = '',
}) async {
  final l = AppLocalizations.of(context);
  final form = GlobalKey<FormState>();
  final amount = TextEditingController(text: initial);
  final note = TextEditingController();
  void submit() {
    if (form.currentState!.validate()) Navigator.of(context).pop(true);
  }

  final ok = await showDoayaDialog<bool>(
    context: context,
    title: title,
    content: Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (help != null) ...[
            Text(help, style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary)),
            const SizedBox(height: DoayaSpacing.l),
          ],
          GlassTextField(
            label: label,
            controller: amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              final m = Money.tryParse(v ?? '', currency);
              if (m == null || (!allowZero && m.isZero)) return l.invalidNumber;
              return null;
            },
            onSubmitted: (_) => noteLabel == null ? submit() : null,
          ),
          if (noteLabel != null) ...[
            const SizedBox(height: DoayaSpacing.l),
            GlassTextField(
              label: noteLabel,
              controller: note,
              validator: (v) => (v ?? '').trim().isEmpty ? l.required : null,
              onSubmitted: (_) => submit(),
            ),
          ],
        ],
      ),
    ),
    actions: [
      GlassPillButton(label: l.cancel, onPressed: () => Navigator.of(context).pop(false)),
      SagePillButton(label: l.confirm, size: PillSize.small, onPressed: submit),
    ],
  );
  if (ok != true) return null;
  return (
    Money.tryParse(amount.text, currency)!.minor,
    noteLabel == null ? null : note.text.trim(),
  );
}

/// "عجز 10 ل.س" / "زيادة 5 ل.س" / "مطابق".
StatusChip differenceChip(AppLocalizations l, int? difference, Currency c) {
  if (difference == null) return StatusChip(label: l.shiftOpenNow, dot: true);
  if (difference == 0) return StatusChip(label: l.balanced, tone: StatusTone.accent);
  if (difference < 0) {
    return StatusChip(label: l.shortage(formatMoney(-difference, c)), tone: StatusTone.danger);
  }
  return StatusChip(label: l.surplus(formatMoney(difference, c)), tone: StatusTone.warning);
}

/// Payment chip for a stored sale: نقدي / دين / تحويل.
StatusChip paymentChip(AppLocalizations l, String payment) => switch (payment) {
  'debt' => StatusChip(label: l.paymentDebt, tone: StatusTone.warning),
  'transfer' => StatusChip(label: l.paymentTransfer, tone: StatusTone.neutral),
  _ => StatusChip(label: l.paymentCash, tone: StatusTone.accent),
};

/// − value + with bounds.
class QtyStepper extends StatelessWidget {
  const QtyStepper({super.key, required this.value, required this.max, required this.onChanged});

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
