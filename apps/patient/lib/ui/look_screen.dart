import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/look.dart';
import '../l10n/app_localizations.dart';
import '../router.dart';
import 'common.dart';
import 'look_labels.dart';

/// «المظهر»: every choice applies to the whole app at once.
class LookScreen extends ConsumerWidget {
  const LookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: DoayaColors.transparent,
      body: SafeArea(
        child: PhoneBody(
          child: ListView(
            children: [
              ScreenHeader(
                title: l.lookTitle,
                onBack: () => context.canPop() ? context.pop() : context.go(Routes.account),
              ),
              DoayaLookEditor(
                look: ref.watch(lookProvider),
                onChanged: ref.read(lookProvider.notifier).set,
                labels: lookLabels(l),
              ),
              SizedBox(height: DoayaSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
