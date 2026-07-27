import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../core/ui/driver_ui_states.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_active_trip_map.dart';
import '../../login/driver_realtime_controller.dart';
import '../driver_home_online_errors.dart';
import 'driver_active_trip_sheet.dart';
import 'driver_home_menu.dart';
import 'driver_offer_card.dart';

/// Vista mapa + tarjeta retraíble del viaje activo.
class DriverHomeActiveTripView extends ConsumerWidget {
  const DriverHomeActiveTripView({
    super.key,
    required this.trip,
    required this.expanded,
    required this.onExpandedChanged,
    required this.tripErrorMessage,
    required this.onOpenNavigation,
    required this.onReactivate,
    required this.onOpenChat,
  });

  final DriverActiveTrip trip;
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
  final String? tripErrorMessage;
  final Future<void> Function({
    required double lat,
    required double lng,
    required String label,
  })
  onOpenNavigation;
  final VoidCallback onReactivate;
  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final realtime = ref.watch(driverRealtimeProvider);

    return DriverActiveTripMapView(
      driverLat: realtime.driverLat,
      driverLng: realtime.driverLng,
      driverBearing: realtime.driverBearing,
      trip: trip,
      bottomCard: DriverRetractableTripCard(
        trip: trip,
        expanded: expanded,
        onExpandedChanged: onExpandedChanged,
        processingAction: realtime.processingTripAction,
        errorMessage: tripErrorMessage,
        onMarkArrived: () =>
            ref.read(driverRealtimeProvider.notifier).markArrived(),
        onStartTrip: () => ref.read(driverRealtimeProvider.notifier).startTrip(),
        onCompleteTrip: () =>
            ref.read(driverRealtimeProvider.notifier).completeTrip(),
        onArrivalReminder: () => ref
            .read(driverRealtimeProvider.notifier)
            .sendArrivalReminder(),
        arrivalReminderCooldownUntilMs: realtime.arrivalReminderCooldownUntilMs,
        onNavigateToPickup: () {
          if (trip.pickupLat == null || trip.pickupLng == null) return;
          onOpenNavigation(
            lat: trip.pickupLat!,
            lng: trip.pickupLng!,
            label: l10n.tripOrigin,
          );
        },
        onNavigateToDestination: () {
          if (trip.destinationLat == null || trip.destinationLng == null) {
            return;
          }
          onOpenNavigation(
            lat: trip.destinationLat!,
            lng: trip.destinationLng!,
            label: l10n.tripDestination,
          );
        },
        onReactivate: onReactivate,
        onOpenChat: onOpenChat,
      ),
    );
  }
}

/// Lista de disponibilidad, gates y ofertas pendientes (home sin mapa).
class DriverHomeRequestsPanel extends ConsumerWidget {
  const DriverHomeRequestsPanel({
    super.key,
    required this.localAuth,
    required this.listFade,
    required this.listSlide,
    required this.errorMessage,
    required this.showProminentGateError,
    required this.blockOnlineForTrips,
    required this.onAfterOnlineEnabled,
  });

  final LocalAuthentication localAuth;
  final Animation<double> listFade;
  final Animation<Offset> listSlide;
  final String? errorMessage;
  final bool showProminentGateError;
  final bool blockOnlineForTrips;
  final Future<void> Function(BuildContext context) onAfterOnlineEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final realtime = ref.watch(driverRealtimeProvider);
    final pendingOffers = realtime.pendingOffers;

    return FadeTransition(
      opacity: listFade,
      child: SlideTransition(
        position: listSlide,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: CustomScrollView(
            slivers: [
              if (showProminentGateError && errorMessage != null)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DriverInlineError(message: errorMessage!),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              if (realtime.showDriverCreditsLowWarning)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DriverInlineInfo(
                        message: l10n.driverHomeCreditsLowWarning(
                          realtime.driverCreditsBalance.toStringAsFixed(2),
                          realtime.minCreditsToGoOnline.toStringAsFixed(2),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            context.pushNamed(AppRouter.earningsCredits);
                          },
                          child: Text(l10n.driverEarningsCreditsMenu),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              if (blockOnlineForTrips)
                SliverToBoxAdapter(
                  child: DriverHomeVehicleRegistrationBanner(),
                ),
              SliverToBoxAdapter(
                child: DriverHomeOnlineAvailabilityPanel(
                  localAuth: localAuth,
                  onAfterOnlineEnabled: onAfterOnlineEnabled,
                ),
              ),
              if (errorMessage != null && !showProminentGateError)
                SliverToBoxAdapter(
                  child: DriverHomeOnlinePermissionErrorSection(
                    errorMessage: errorMessage!,
                    errorCode: realtime.errorCode,
                    l10n: l10n,
                  ),
                ),
              SliverToBoxAdapter(
                child: SizedBox(height: AppFoundation.spacingXl),
              ),
              if (pendingOffers.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _DriverHomeOffersHeader(count: pendingOffers.length),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final offer = pendingOffers[index];
                      final perOfferCode =
                          realtime.offersErrorCodeByTripId[offer.tripId];
                      final offerErrorMessage = driverHomeOfferErrorMessage(
                        l10n: l10n,
                        perOfferCode: perOfferCode,
                        fallbackMessage:
                            realtime.offersErrorMessageByTripId[offer.tripId],
                      );
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < pendingOffers.length - 1 ? 8 : 0,
                        ),
                        child: DriverTripOfferCard(
                          l10n: l10n,
                          offer: offer,
                          isProcessing:
                              realtime.processingOfferTripId == offer.tripId,
                          isProcessingAccept:
                              realtime.processingOfferTripId == offer.tripId &&
                              realtime.processingIsAccept,
                          errorMessage: offerErrorMessage,
                          onAccept: () => ref
                              .read(driverRealtimeProvider.notifier)
                              .acceptOffer(offer.tripId),
                          onReject: () => ref
                              .read(driverRealtimeProvider.notifier)
                              .rejectOffer(offer.tripId),
                        ),
                      );
                    }, childCount: pendingOffers.length),
                  ),
                ),
              ] else ...[
                SliverToBoxAdapter(
                  child: Text(
                    l10n.driverHomeRequestsTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: DriverEmptyStateCard(
                    message: l10n.driverHomeRequestsEmpty,
                    icon: Icons.hourglass_empty_rounded,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverHomeOffersHeader extends StatelessWidget {
  const _DriverHomeOffersHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(AppFoundation.radiusSm),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.6),
                ),
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                color: const Color(0xFF9FB2CB),
                size: 20,
              ),
            ),
            const SizedBox(width: AppFoundation.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.driverHomeRequestsTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l10n.driverHomeMiniStatusOnline,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppFoundation.spacingSm,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppFoundation.radiusSm),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.7),
                ),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: AppColors.textPrimary.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppFoundation.spacingMd),
      ],
    );
  }
}
