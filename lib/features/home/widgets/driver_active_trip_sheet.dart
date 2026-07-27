import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_realtime_state.dart';
import 'driver_active_trip_card.dart';
import 'driver_active_trip_status_helpers.dart';

/// Panel inferior retraíble: colapsado muestra barra con estado y precio; expandido muestra detalle del viaje.
class DriverRetractableTripCard extends StatelessWidget {
  final DriverActiveTrip trip;
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
  final String? processingAction;
  final String? errorMessage;
  final VoidCallback onMarkArrived;
  final VoidCallback onStartTrip;
  final VoidCallback onCompleteTrip;
  final VoidCallback onArrivalReminder;
  final int? arrivalReminderCooldownUntilMs;
  final VoidCallback onNavigateToPickup;
  final VoidCallback onNavigateToDestination;
  final VoidCallback onReactivate;
  final VoidCallback onOpenChat;

  const DriverRetractableTripCard({
    super.key,
    required this.trip,
    required this.expanded,
    required this.onExpandedChanged,
    required this.processingAction,
    required this.errorMessage,
    required this.onMarkArrived,
    required this.onStartTrip,
    required this.onCompleteTrip,
    required this.onArrivalReminder,
    required this.arrivalReminderCooldownUntilMs,
    required this.onNavigateToPickup,
    required this.onNavigateToDestination,
    required this.onReactivate,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = driverActiveTripStatusAccentColor(trip.status);

    // Un solo árbol con Column + AnimatedSize evita clipping/erratas de altura
    // al alternar expandido/colapsado (antes solo quedaban visibles los botones inferiores).
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (expanded) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onExpandedChanged(false),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            DriverActiveTripCard(
              trip: trip,
              processingAction: processingAction,
              errorMessage: errorMessage,
              onMarkArrived: onMarkArrived,
              onStartTrip: onStartTrip,
              onCompleteTrip: onCompleteTrip,
              onArrivalReminder: onArrivalReminder,
              arrivalReminderCooldownUntilMs: arrivalReminderCooldownUntilMs,
              onNavigateToPickup: onNavigateToPickup,
              onNavigateToDestination: onNavigateToDestination,
              onReactivate: onReactivate,
              onOpenChat: onOpenChat,
            ),
          ] else
            Material(
              color: AppColors.surfaceCard.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
              child: InkWell(
                onTap: () => onExpandedChanged(true),
                borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.directions_car_rounded,
                        color: accent,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driverActiveTripStatusLabel(l10n, trip.status),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                minHeight: 3,
                                value: driverActiveTripStatusProgress(trip.status),
                                backgroundColor: AppColors.border.withValues(
                                  alpha: 0.45,
                                ),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  accent,
                                ),
                              ),
                            ),
                            if (trip.estimatedPrice != null)
                              Text(
                                formatMoney(
                                  trip.estimatedPrice,
                                  currencyCode: trip.currencyCode,
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: AppColors.textSecondary,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
