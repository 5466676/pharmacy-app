import 'dart:typed_data';

import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../central/inbox_controller.dart';
import '../l10n/app_localizations.dart';

/// A patient's photo (a prescription, a box), through the pharmacy's own
/// server; kept in memory while the app runs.
final patientPhotoProvider = FutureProvider.family<Uint8List, String>(
  (ref, id) => ref.read(centralApiProvider)!.photo(id),
);

/// A thumbnail; click to read the prescription full size.
class PatientPhoto extends ConsumerWidget {
  const PatientPhoto({super.key, required this.id, this.size = DoayaSizes.productImage * 1.6});

  final String id;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(patientPhotoProvider(id)).value;
    return SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DoayaRadii.imageWell),
        child: data == null
            ? ColoredBox(
                color: DoayaColors.imageWell,
                child: Center(child: Icon(DoayaIcons.camera, color: DoayaColors.textSecondary)),
              )
            : Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => showDialog<void>(
                    context: context,
                    barrierColor: DoayaColors.scrim,
                    builder: (context) => Dialog(
                      backgroundColor: DoayaColors.transparent,
                      insetPadding: EdgeInsets.all(DoayaSpacing.huge),
                      child: Stack(
                        children: [
                          InteractiveViewer(maxScale: 5, child: Image.memory(data)),
                          PositionedDirectional(
                            top: DoayaSpacing.sm,
                            end: DoayaSpacing.sm,
                            child: RoundIconButton(
                              icon: DoayaIcons.close,
                              tooltip: l.close,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: Image.memory(data, fit: BoxFit.cover),
                ),
              ),
      ),
    );
  }
}
