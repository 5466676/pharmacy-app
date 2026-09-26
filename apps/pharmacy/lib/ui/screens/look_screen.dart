import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart' show isDesktopPlatform;
import '../../data/look_store.dart';
import '../../l10n/app_localizations.dart';
import '../look_labels.dart';
import '../widgets.dart';

/// «المظهر» of this device: for every employee, applied at once.
class LookScreen extends ConsumerWidget {
  const LookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ListView(
      children: [
        PageHeader(title: l.lookTitle),
        Text(
          l.lookSubtitle,
          style: DoayaTypography.bodySmall.copyWith(color: DoayaColors.textSecondary),
        ),
        SizedBox(height: DoayaSpacing.l),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: DoayaSizes.wideFormWidth),
            child: DoayaLookEditor(
              look: ref.watch(lookProvider),
              onChanged: ref.read(lookProvider.notifier).set,
              labels: lookLabels(l),
              // The counter PC never blurs, whatever the style.
              blurAvailable: !isDesktopPlatform,
            ),
          ),
        ),
        SizedBox(height: DoayaSpacing.xl),
      ],
    );
  }
}
