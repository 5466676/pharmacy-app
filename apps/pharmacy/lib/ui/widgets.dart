import 'package:doaya_core/doaya_core.dart';
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../l10n/app_localizations.dart';
import 'format.dart';

/// Screen title row with optional trailing actions.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.actions = const [], this.leading});

  final String title;
  final List<Widget> actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DoayaSpacing.xl),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: DoayaSpacing.ml)],
          Expanded(child: Text(title, style: DoayaTypography.title)),
          for (final a in actions) ...[const SizedBox(width: DoayaSpacing.sm), a],
        ],
      ),
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
      padding: padding ?? const EdgeInsets.all(DoayaSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
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

/// Stock chip: "متوفر · ٢٤" / "باقي ٣" / "نفد".
class StockChip extends StatelessWidget {
  const StockChip({super.key, required this.onHand, required this.threshold});

  final int onHand;
  final int threshold;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (onHand <= 0) return StatusChip(label: l.outOfStock, tone: StatusTone.danger);
    if (onHand <= threshold) {
      return StatusChip(label: l.lowLeft(formatQty(onHand)), tone: StatusTone.warning);
    }
    return StatusChip(label: l.inStock(formatQty(onHand)), tone: StatusTone.accent);
  }
}

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
};

String stockEventLabel(AppLocalizations l, StockEventType t) => switch (t) {
  StockEventType.received => l.evReceived,
  StockEventType.sold => l.evSold,
  StockEventType.returned => l.evReturned,
  StockEventType.adjusted => l.evAdjusted,
  StockEventType.expiredRemoved => l.evExpiredRemoved,
};

/// Parses "d/m/yyyy" (Latin or Arabic digits). Null if empty or invalid.
DateTime? parseDate(String input) {
  final s = input.trim().replaceAllMapped(
    RegExp('[٠-٩]'),
    (m) => String.fromCharCode(m[0]!.codeUnitAt(0) - 0x0660 + 0x30),
  );
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
