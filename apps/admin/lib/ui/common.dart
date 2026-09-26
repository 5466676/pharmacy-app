import 'package:doaya_core/doaya_core.dart' show SyncApiException, SyncNetworkException;
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';

/// The owner's words for a failed call.
String errorText(AppLocalizations l, Object e) => switch (e) {
  SyncNetworkException() => l.errNetwork,
  SyncApiException(code: 'bad_credentials') => l.errBadCredentials,
  SyncApiException(code: 'too_many_attempts') => l.errTooMany,
  SyncApiException(code: 'reason_required') => l.errReasonRequired,
  SyncApiException(code: 'bad_status') => l.errBadStatus,
  SyncApiException(code: 'code_taken') => l.errCodeTaken,
  SyncApiException(code: 'bad_code') => l.errBadCode,
  SyncApiException(code: 'note_has_dose') => l.errNoteHasDose,
  SyncApiException(:final code) => l.errGeneric(code),
  _ => l.errGeneric('$e'),
};

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

/// d/m/yyyy H:mm, English digits.
String formatDateTime(DateTime d) {
  final l = d.toLocal();
  final m = l.minute.toString().padLeft(2, '0');
  return '${l.day}/${l.month}/${l.year} ${l.hour}:$m';
}

String formatDate(DateTime d) {
  final l = d.toLocal();
  return '${l.day}/${l.month}/${l.year}';
}

/// "من 3 ساعة" / "هلق".
String ago(AppLocalizations l, DateTime? t, {DateTime? now}) {
  if (t == null) return l.never;
  final d = (now ?? DateTime.now()).difference(t);
  if (d.inMinutes < 1) return l.justNow;
  if (d.inHours < 1) return l.agoMinutes(formatNumber(d.inMinutes));
  if (d.inDays < 1) return l.agoHours(formatNumber(d.inHours));
  return l.agoDays(formatNumber(d.inDays));
}

String minutes(AppLocalizations l, double? m) =>
    m == null ? '—' : l.minutesShort(formatNumber(m, decimals: m < 10 ? 1 : 0));

String percent(AppLocalizations l, double? share) =>
    share == null ? '—' : l.percent(formatNumber(share * 100));

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: DoayaSpacing.l),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: DoayaTypography.title),
              if (subtitle != null) ...[
                SizedBox(height: DoayaSpacing.xs),
                Text(
                  subtitle!,
                  style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

/// A titled surface.
class Panel extends StatelessWidget {
  const Panel({super.key, this.title, this.trailing, required this.child});

  final String? title;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) => GlassSurface(
    padding: EdgeInsets.all(DoayaSpacing.l),
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
          SizedBox(height: DoayaSpacing.m),
        ],
        child,
      ],
    ),
  );
}

class EmptyHint extends StatelessWidget {
  const EmptyHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(DoayaSpacing.xl),
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
      ),
    ),
  );
}

/// Loading, an error with «جرّب مرة تانية», or the data.
class AsyncView<T> extends ConsumerWidget {
  const AsyncView({super.key, required this.value, required this.retry, required this.data});

  final AsyncValue<T> value;
  final VoidCallback retry;
  final Widget Function(T data) data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return switch (value) {
      AsyncData(:final value) => data(value),
      AsyncError(:final error) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorText(l, error), textAlign: TextAlign.center, style: DoayaTypography.body),
            SizedBox(height: DoayaSpacing.m),
            GlassPillButton(label: l.retry, icon: DoayaIcons.refresh, onPressed: retry),
          ],
        ),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

/// A label over a value, in a small tile.
class Fact extends StatelessWidget {
  const Fact({super.key, required this.label, required this.value, this.ltr = false});

  final String label;
  final String value;
  final bool ltr;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: DoayaSpacing.m, vertical: DoayaSpacing.sm),
    decoration: BoxDecoration(
      color: DoayaColors.subtleFill,
      borderRadius: BorderRadius.circular(DoayaRadii.tile),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary)),
        ltr
            ? LatinText(value, style: DoayaTypography.label)
            : Text(value, style: DoayaTypography.label),
      ],
    ),
  );
}
