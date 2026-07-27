import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../gen_l10n/app_localizations.dart';

String driverActiveTripStatusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'accepted':
      return l10n.driverTripStatusAccepted;
    case 'arrived':
      return l10n.driverTripStatusArrived;
    case 'started':
    case 'in_trip':
      return l10n.driverTripStatusStarted;
    case 'completed':
      return l10n.driverTripStatusCompleted;
    case 'cancelled':
      return l10n.driverTripStatusCancelled;
    default:
      return l10n.driverTripStatusInProgress;
  }
}

Color driverActiveTripStatusAccentColor(String status) {
  switch (status) {
    case 'accepted':
      return const Color(0xFF2F7DFF);
    case 'arrived':
      return const Color(0xFFEF9F2F);
    case 'started':
    case 'in_trip':
      return const Color(0xFF8A4DFF);
    case 'completed':
      return AppColors.success;
    case 'cancelled':
      return AppColors.error;
    default:
      return AppColors.primary;
  }
}

double driverActiveTripStatusProgress(String status) {
  switch (status) {
    case 'accepted':
      return 0.33;
    case 'arrived':
      return 0.66;
    case 'started':
    case 'in_trip':
      return 0.9;
    case 'completed':
    case 'cancelled':
      return 1;
    default:
      return 0.2;
  }
}
