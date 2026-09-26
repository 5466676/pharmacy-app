import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/system_lock.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';
import 'format.dart';

/// Screens that sell or change stock and money: closed while the system is
/// locked. Everything else (reports, inventory, debts, backups, export)
/// stays open: the pharmacy's records are its own.
bool isWriteRoute(String location) => [
  Routes.pos,
  Routes.newProduct,
  Routes.stocktake,
  Routes.newPurchase,
  Routes.till,
].any(location.startsWith);

/// Wraps every page of the shell: a reminder when the licence is ending,
/// a notice when the system is locked, and the locked panel in place of
/// the screens that sell or change stock.
class LockGate extends ConsumerWidget {
  const LockGate({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(systemLockProvider).value ?? const LockSnapshot();
    final l = AppLocalizations.of(context);
    if (snap.locked && isWriteRoute(location)) return LockedPanel(snap: snap);
    final notice = snap.locked
        ? NoticeBanner(tone: StatusTone.danger, icon: DoayaIcons.warning, message: l.lockReadOnly)
        : snap.endingSoon
        ? NoticeBanner(
            icon: DoayaIcons.clock,
            message: l.lockEndingSoon(formatQty(snap.daysLeft!.clamp(0, 999))),
          )
        : null;
    if (notice == null) return child;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        notice,
        SizedBox(height: DoayaSpacing.m),
        Expanded(child: child),
      ],
    );
  }
}

class LockedPanel extends StatelessWidget {
  const LockedPanel({super.key, required this.snap});

  final LockSnapshot snap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lock = snap.lock;
    final why = lock != null && lock.stoppedByOwner ? l.lockStopped : l.lockLicenceEnded;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: DoayaSizes.formWidth),
        child: GlassSurface(
          padding: EdgeInsets.all(DoayaSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(DoayaIcons.warning, size: DoayaSizes.iconL, color: DoayaColors.dangerText),
              SizedBox(height: DoayaSpacing.m),
              Text(l.lockTitle, textAlign: TextAlign.center, style: DoayaTypography.title),
              SizedBox(height: DoayaSpacing.sm),
              Text(why, textAlign: TextAlign.center, style: DoayaTypography.body),
              if (lock?.reason != null && lock!.stoppedByOwner) ...[
                SizedBox(height: DoayaSpacing.sm),
                Text(
                  l.lockReason(lock.reason!),
                  textAlign: TextAlign.center,
                  style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
                ),
              ],
              SizedBox(height: DoayaSpacing.l),
              Text(
                l.lockStillOpen,
                textAlign: TextAlign.center,
                style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
