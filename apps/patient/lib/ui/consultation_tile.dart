import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';

import '../data/models.dart';
import '../l10n/app_localizations.dart';
import 'common.dart';

/// One consultation in a list: what it was about, when, where it stands.
class ConsultationTile extends StatelessWidget {
  const ConsultationTile({super.key, required this.consultation, required this.onTap});

  final Consultation consultation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = consultation;
    final radius = BorderRadius.circular(DoayaRadii.card);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: GlassSurface(
          borderRadius: radius,
          padding: const EdgeInsets.all(DoayaSpacing.l),
          child: Row(
            children: [
              Icon(
                c.urgent ? DoayaIcons.warning : DoayaIcons.chat,
                size: DoayaSizes.iconM,
                color: c.urgent ? DoayaColors.dangerText : DoayaColors.accent,
              ),
              const SizedBox(width: DoayaSpacing.ml),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.title.isEmpty ? l.assistantTitle : c.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DoayaTypography.label,
                    ),
                    Text(
                      '${formatDate(c.updatedAt)}، ${formatTime(c.updatedAt)}',
                      style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DoayaSpacing.sm),
              StatusChip(label: l.status(c.status), tone: consultTone(c.status)),
            ],
          ),
        ),
      ),
    );
  }
}
