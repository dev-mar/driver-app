import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../core/ui/driver_ui_states.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_realtime_state.dart';
import 'driver_active_trip_nav_buttons.dart';
import 'driver_active_trip_status_helpers.dart';
import 'driver_trip_payment_chip.dart';
import 'driver_trip_extras_icons.dart';

class DriverActiveTripCard extends StatelessWidget {
  final DriverActiveTrip trip;
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

  const DriverActiveTripCard({
    super.key,
    required this.trip,
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
    final isProcessing = processingAction != null;
    final canAct =
        !isProcessing &&
        trip.status != 'completed' &&
        trip.status != 'cancelled';
    final hasPassenger =
        trip.passengerName != null && trip.passengerName!.isNotEmpty;
    final hasPickupCoords = trip.pickupLat != null && trip.pickupLng != null;
    final hasDestCoords =
        trip.destinationLat != null && trip.destinationLng != null;
    final hasOriginLine =
        (trip.originAddress != null && trip.originAddress!.isNotEmpty) ||
        hasPickupCoords;
    final hasDestLine =
        (trip.destinationAddress != null &&
            trip.destinationAddress!.isNotEmpty) ||
        hasDestCoords;
    final hasMetrics =
        trip.tripDistanceKm != null || trip.etaToDestinationMinutes != null;
    final hasRouteDetail =
        hasPassenger || hasMetrics || hasOriginLine || hasDestLine;
    final accent = driverActiveTripStatusAccentColor(trip.status);
    final progress = driverActiveTripStatusProgress(trip.status);
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final reminderCooldownLeftSec =
        (arrivalReminderCooldownUntilMs != null &&
            arrivalReminderCooldownUntilMs! > nowMs)
        ? ((arrivalReminderCooldownUntilMs! - nowMs) / 1000).ceil()
        : 0;
    final canSendArrivalReminder =
        trip.status == 'arrived' && canAct && reminderCooldownLeftSec <= 0;

    Widget section({
      required Widget child,
      EdgeInsetsGeometry padding = const EdgeInsets.all(12),
    }) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppFoundation.radiusSm),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
        ),
        child: child,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.65),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          section(
            child: Row(
              children: [
                Icon(Icons.directions_car_rounded, color: accent, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              driverActiveTripStatusLabel(l10n, trip.status),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: accent,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 4,
                          value: progress,
                          backgroundColor: AppColors.border.withValues(
                            alpha: 0.45,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                        ),
                      ),
                      if (trip.estimatedPrice != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.driverTripEstimatedPrice(
                                  formatMoney(
                                    trip.estimatedPrice,
                                    currencyCode: trip.currencyCode,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            DriverTripPaymentChip(
                              l10n: l10n,
                              paymentMethod: trip.paymentMethod,
                            ),
                          ],
                        ),
                        if (trip.tripExtras.isNotEmpty ||
                            trip.tripSpecials.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: DriverTripExtrasIcons(
                              l10n: l10n,
                              extras: trip.tripExtras,
                              specials: trip.tripSpecials,
                            ),
                          ),
                        ],
                      ] else ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              DriverTripPaymentChip(
                                l10n: l10n,
                                paymentMethod: trip.paymentMethod,
                              ),
                              if (trip.tripExtras.isNotEmpty ||
                                  trip.tripSpecials.isNotEmpty)
                                DriverTripExtrasIcons(
                                  l10n: l10n,
                                  extras: trip.tripExtras,
                                  specials: trip.tripSpecials,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (hasRouteDetail) ...[
            const SizedBox(height: 10),
            section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (hasPassenger)
                    Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trip.passengerName!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (trip.passengerRating != null) ...[
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            trip.passengerRating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  if (hasPassenger &&
                      (hasOriginLine || hasDestLine || hasMetrics))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Divider(
                        height: 1,
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                    ),
                  if (trip.originAddress != null &&
                      trip.originAddress!.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.place_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trip.originAddress!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  else if (hasPickupCoords)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.place_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${l10n.driverMapPickupPoint}: ${trip.pickupLat!.toStringAsFixed(5)}, ${trip.pickupLng!.toStringAsFixed(5)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (hasOriginLine && hasDestLine) const SizedBox(height: 6),
                  if (trip.destinationAddress != null &&
                      trip.destinationAddress!.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.flag_rounded,
                          size: 18,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trip.destinationAddress!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  else if (hasDestCoords)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.flag_rounded,
                          size: 18,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${l10n.driverMapDestinationPoint}: ${trip.destinationLat!.toStringAsFixed(5)}, ${trip.destinationLng!.toStringAsFixed(5)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if ((hasOriginLine || hasDestLine) && hasMetrics)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Divider(
                        height: 1,
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                    ),
                  if (hasMetrics)
                    Row(
                      children: [
                        if (trip.tripDistanceKm != null) ...[
                          Icon(
                            Icons.straighten_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${trip.tripDistanceKm!.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        if (trip.tripDistanceKm != null &&
                            trip.etaToDestinationMinutes != null)
                          const SizedBox(width: 14),
                        if (trip.etaToDestinationMinutes != null) ...[
                          Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '~${trip.etaToDestinationMinutes!.round()} min',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ],
          if ((trip.pickupLat != null && trip.pickupLng != null) ||
              (trip.destinationLat != null && trip.destinationLng != null)) ...[
            const SizedBox(height: 10),
            section(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: DriverAssistedTripNavButtons(
                showPickup: trip.pickupLat != null && trip.pickupLng != null,
                showDestination:
                    trip.destinationLat != null && trip.destinationLng != null,
                tripStatus: trip.status,
                l10n: l10n,
                onNavigateToPickup: onNavigateToPickup,
                onNavigateToDestination: onNavigateToDestination,
              ),
            ),
          ],
          if (errorMessage != null && errorMessage!.isNotEmpty) ...[
            const SizedBox(height: 8),
            DriverInlineError(message: errorMessage!),
          ],
          if (driverTripChatPhaseActive(trip.status)) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onOpenChat,
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: Text(l10n.driverTripChatOpenCta),
              ),
            ),
          ],
          if (trip.status == 'accepted' && canAct) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: processingAction == 'arrived' ? null : onMarkArrived,
                icon: processingAction == 'arrived'
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.location_on_rounded, size: 20),
                label: Text(l10n.driverTripArrivedButton),
              ),
            ),
          ],
          if (trip.status == 'arrived' && canAct) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: processingAction == 'started'
                        ? null
                        : onStartTrip,
                    icon: processingAction == 'started'
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : const Icon(Icons.play_arrow_rounded, size: 24),
                    label: Text(l10n.driverTripStartButton),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: canSendArrivalReminder
                      ? 'Notificar nuevamente al pasajero'
                      : 'Disponible en ${reminderCooldownLeftSec > 0 ? reminderCooldownLeftSec : 0}s',
                  child: OutlinedButton(
                    onPressed: canSendArrivalReminder
                        ? onArrivalReminder
                        : null,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(52, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Icon(Icons.campaign_rounded),
                  ),
                ),
              ],
            ),
            if (reminderCooldownLeftSec > 0) ...[
              const SizedBox(height: 6),
              Text(
                'Podrás volver a notificar en ${reminderCooldownLeftSec}s',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ],
          if ((trip.status == 'started' || trip.status == 'in_trip') &&
              canAct) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: processingAction == 'completed'
                    ? null
                    : onCompleteTrip,
                icon: processingAction == 'completed'
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.check_circle_rounded, size: 22),
                label: Text(l10n.driverTripCompleteButton),
              ),
            ),
          ],
          if (trip.status == 'completed') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onReactivate,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l10n.driverTripReactivate,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
