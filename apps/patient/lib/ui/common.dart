import 'package:doaya_core/doaya_core.dart' show SyncApiException, SyncNetworkException;
import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// The patient's words for a failed call.
String errorText(AppLocalizations l, Object e) => switch (e) {
  SyncNetworkException() => l.errNetwork,
  SyncApiException(code: 'phone_taken') => l.errPhoneTaken,
  SyncApiException(code: 'bad_credentials') => l.errBadCredentials,
  SyncApiException(code: 'too_many_attempts') => l.errTooMany,
  SyncApiException(code: 'pharmacy_not_found') => l.errPharmacyNotFound,
  SyncApiException(code: 'consultation_closed') => l.consultationClosed,
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

/// d/m/yyyy, English digits.
String formatDate(DateTime d) {
  final l = d.toLocal();
  return '${l.day}/${l.month}/${l.year}';
}

/// HH:mm.
String formatTime(DateTime d) {
  final l = d.toLocal();
  return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
}

/// A phone-width column on any screen (the web app on a laptop too).
class PhoneBody extends StatelessWidget {
  const PhoneBody({super.key, required this.child, this.padding = true});

  final Widget child;
  final bool padding;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: DoayaSizes.phoneMaxWidth),
      child: padding
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: DoayaSpacing.screenGutter),
              child: child,
            )
          : child,
    ),
  );
}

/// A full-width primary button with a busy state.
class BusyButton extends StatelessWidget {
  const BusyButton({super.key, required this.label, required this.busy, required this.onPressed});

  final String label;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SagePillButton(
    label: label,
    size: PillSize.large,
    expand: true,
    onPressed: busy ? null : onPressed,
  );
}

/// Emergency lines (Syria: 110 ambulance, 112 emergency), overridable at
/// build time: `--dart-define=DOAYA_AMBULANCE=…`, `DOAYA_EMERGENCY=…`.
const ambulanceNumber = String.fromEnvironment('DOAYA_AMBULANCE', defaultValue: '110');
const emergencyNumber = String.fromEnvironment('DOAYA_EMERGENCY', defaultValue: '112');

/// While the saved session is being read.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: DoayaColors.transparent,
    body: Center(child: DoayaLogo(size: DoayaSizes.logoLarge)),
  );
}

/// A screen title row with an optional back button.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.onBack, this.trailing});

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: DoayaSpacing.l),
    child: Row(
      children: [
        if (onBack != null) ...[
          RoundIconButton(
            icon: DoayaIcons.back,
            tooltip: AppLocalizations.of(context).cancel,
            onPressed: onBack,
          ),
          const SizedBox(width: DoayaSpacing.ml),
        ],
        Expanded(child: Text(title, style: DoayaTypography.title)),
        ?trailing,
      ],
    ),
  );
}

StatusTone consultTone(String status) => switch (status) {
  'ready' => StatusTone.success,
  'emergency' || 'needs_doctor' => StatusTone.danger,
  'summary' => StatusTone.warning,
  'sent' || 'preparing' => StatusTone.accent,
  _ => StatusTone.neutral,
};
