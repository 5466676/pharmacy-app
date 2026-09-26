import 'dart:typed_data';

import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/photos.dart';
import '../l10n/app_localizations.dart';

/// Camera or gallery, then the picked photo (null if cancelled).
Future<PickedPhoto?> pickPhoto(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final source = await showModalBottomSheet<PhotoSource>(
    context: context,
    backgroundColor: DoayaColors.transparent,
    builder: (context) => SafeArea(
      child: Padding(
        padding: EdgeInsets.all(DoayaSpacing.floatingInset),
        child: GlassSurface(
          tone: SurfaceTone.strong,
          blur: true,
          borderRadius: BorderRadius.circular(DoayaRadii.sheet),
          padding: EdgeInsets.all(DoayaSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SagePillButton(
                label: l.takePhoto,
                icon: DoayaIcons.camera,
                expand: true,
                onPressed: () => Navigator.pop(context, PhotoSource.camera),
              ),
              SizedBox(height: DoayaSpacing.sm),
              GlassPillButton(
                label: l.fromGallery,
                icon: DoayaIcons.gallery,
                expand: true,
                onPressed: () => Navigator.pop(context, PhotoSource.gallery),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  if (source == null) return null;
  return ref.read(photoPickerProvider)(source);
}

/// A sent photo (by id) or a picked one (bytes); tap to see it whole.
class PhotoThumb extends ConsumerWidget {
  const PhotoThumb({super.key, this.id, this.bytes, this.size = DoayaSizes.productImage * 2});

  final String? id;
  final Uint8List? bytes;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = bytes ?? (id == null ? null : ref.watch(photoProvider(id!)).value);
    final radius = BorderRadius.circular(DoayaRadii.imageWell);
    return SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: radius,
        child: data == null
            ? ColoredBox(
                color: DoayaColors.imageWell,
                child: Center(child: Icon(DoayaIcons.camera, color: DoayaColors.textSecondary)),
              )
            : Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => _open(context, data),
                  child: Image.memory(data, fit: BoxFit.cover),
                ),
              ),
      ),
    );
  }

  void _open(BuildContext context, Uint8List data) {
    final l = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      barrierColor: DoayaColors.scrim,
      builder: (context) => Dialog(
        backgroundColor: DoayaColors.transparent,
        insetPadding: EdgeInsets.all(DoayaSpacing.l),
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
    );
  }
}
