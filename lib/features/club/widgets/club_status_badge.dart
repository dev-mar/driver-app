import 'package:flutter/material.dart';

import '../../../gen_l10n/app_localizations.dart';
import '../club_colors.dart';

class ClubStatusBadge extends StatelessWidget {
  const ClubStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final key = status.toLowerCase();
    late final String label;
    late final Color color;
    if (key.contains('complete')) {
      label = l10n.driverClubStatusDone;
      color = ClubColors.teal;
    } else if (key.contains('progress') || key.contains('proceso')) {
      label = l10n.driverClubStatusProgress;
      color = ClubColors.sky;
    } else {
      label = l10n.driverClubStatusPending;
      color = ClubColors.gold;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
