import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../core/ui/driver_ui_states.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_trip_offer.dart';
import 'driver_trip_payment_chip.dart';
import 'driver_trip_promo_breakdown.dart';
import 'driver_trip_extras_icons.dart';

class DriverTripOfferCard extends StatelessWidget {
  final AppLocalizations l10n;
  final DriverTripOffer offer;
  final bool isProcessing;
  final bool isProcessingAccept;
  final String? errorMessage;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onPreview;

  const DriverTripOfferCard({
    super.key,
    required this.l10n,
    required this.offer,
    required this.isProcessing,
    required this.isProcessingAccept,
    required this.errorMessage,
    required this.onAccept,
    required this.onReject,
    required this.onPreview,
  });

  static String formatPrice(double? value, {String? currencyCode}) {
    return formatTripMoney(value, currencyCode: currencyCode);
  }

  static String formatDistance(double? km) {
    if (km == null) return '—';
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  static String formatDuration(double? minutes) {
    if (minutes == null) return '—';
    final m = minutes.round();
    if (m <= 0) return '<1 min';
    if (m < 60) return '$m min';
    final h = m ~/ 60;
    final rem = m % 60;
    if (rem == 0) return '$h h';
    return '$h h ${rem.toString().padLeft(2, '0')} min';
  }

  static const Color _operationsAccent = Color(0xFFFB923C);
  static const Color _pickupAccent = Color(0xFF00BFA5);

  @override
  Widget build(BuildContext context) {
    final isWebDispatch = offer.isAdminWebDispatch;
    final hasPrice = offer.offeredPrice != null;
    final hasPassenger = (offer.passengerName ?? '').isNotEmpty;
    final passengerRatingValue = offer.passengerRating ?? 5.0;
    final hasRating = !isWebDispatch;
    final badgeColor = isWebDispatch ? _operationsAccent : AppColors.primary;
    final hasPickupMetrics =
        offer.etaMinutes != null || offer.distanceToPickupKm != null;
    final hasExtras =
        offer.tripExtras.isNotEmpty || offer.tripSpecials.isNotEmpty;
    final showPassengerBlock =
        hasPassenger || hasRating || hasPickupMetrics || hasExtras;

    final originText = (offer.originAddress ?? '').isNotEmpty
        ? offer.originAddress!
        : l10n.tripOrigin;
    final destText = (offer.destinationAddress ?? '').isNotEmpty
        ? offer.destinationAddress!
        : l10n.tripDestination;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.7),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.surface.withValues(alpha: 0.34),
                      AppColors.surfaceCard.withValues(alpha: 0.24),
                      AppColors.primary.withValues(alpha: 0.08),
                    ],
                    stops: const [0.0, 0.68, 1.0],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            hasPrice
                                ? formatPrice(
                                    offer.offeredPrice,
                                    currencyCode: offer.currencyCode,
                                  )
                                : l10n.driverTripOfferPriceTbd,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                              height: 1.05,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        DriverTripPaymentChip(
                          l10n: l10n,
                          paymentMethod: offer.paymentMethod,
                        ),
                        if (isWebDispatch) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: badgeColor.withValues(alpha: 0.42),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.support_agent_rounded,
                                  size: 13,
                                  color: badgeColor.withValues(alpha: 0.95),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.driverTripOfferBadgeOperations,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: badgeColor,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (offer.hasPromoBreakdown) ...[
                      const SizedBox(height: 10),
                      DriverTripPromoBreakdown(
                        l10n: l10n,
                        cashDuePassenger: offer.cashDuePassenger,
                        companyGuaranteeToDriver:
                            offer.companyGuaranteeToDriver,
                        currencyCode: offer.currencyCode,
                        isReferralSupport: offer.isPassengerReferralSupport,
                        emphasizeCompanyLine: true,
                      ),
                    ],
                    if (isWebDispatch) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.driverTripOfferOperationsSubtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DriverOfferRouteTimeline(
                      originText: originText,
                      destinationText: destText,
                      tripDistanceKm: offer.tripDistanceKm,
                      etaToDestinationMinutes: offer.etaToDestinationMinutes,
                    ),
                    if (showPassengerBlock) ...[
                      const SizedBox(height: 12),
                      DriverOfferPassengerBlock(
                        l10n: l10n,
                        name: offer.passengerName ??
                            l10n.driverTripRatingPassengerDefault,
                        rating: hasRating ? passengerRatingValue : null,
                        etaToPickupMinutes: offer.etaMinutes,
                        distanceToPickupKm: offer.distanceToPickupKm,
                        extras: offer.tripExtras,
                        specials: offer.tripSpecials,
                      ),
                    ],
                    if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      DriverInlineError(message: errorMessage!),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isProcessing
                                ? null
                                : () {
                                    HapticFeedback.lightImpact();
                                    onReject();
                                  },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: (isProcessing && !isProcessingAccept)
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.error,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.close_rounded, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        l10n.driverTripReject,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: isProcessing
                                ? null
                                : () {
                                    HapticFeedback.lightImpact();
                                    onPreview();
                                  },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(
                                color: AppColors.primary.withValues(alpha: 0.7),
                              ),
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(48, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Tooltip(
                              message: l10n.driverTripOfferDetail,
                              child: const Icon(
                                Icons.map_outlined,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: isProcessing
                                ? null
                                : () {
                                    HapticFeedback.lightImpact();
                                    onAccept();
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isProcessing && isProcessingAccept
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.onPrimary,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        l10n.driverTripAccept,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Origen → destino con distancia y tiempo del viaje sobre la línea.
class DriverOfferRouteTimeline extends StatelessWidget {
  final String originText;
  final String destinationText;
  final double? tripDistanceKm;
  final double? etaToDestinationMinutes;

  const DriverOfferRouteTimeline({
    super.key,
    required this.originText,
    required this.destinationText,
    this.tripDistanceKm,
    this.etaToDestinationMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final hasTripKm = tripDistanceKm != null;
    final hasTripEta = etaToDestinationMinutes != null;
    final hasTripMetrics = hasTripKm || hasTripEta;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            width: 22,
            child: _RouteRail(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  originText,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: hasTripMetrics
                      ? Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (hasTripKm)
                              DriverOfferMetricChip(
                                icon: Icons.route_rounded,
                                label: DriverTripOfferCard.formatDistance(
                                  tripDistanceKm,
                                ),
                              ),
                            if (hasTripEta)
                              DriverOfferMetricChip(
                                icon: Icons.schedule_rounded,
                                label: DriverTripOfferCard.formatDuration(
                                  etaToDestinationMinutes,
                                ),
                              ),
                          ],
                        )
                      : const SizedBox(height: 8),
                ),
                Text(
                  destinationText,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteRail extends StatelessWidget {
  const _RouteRail();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.place_rounded,
          size: 18,
          color: DriverTripOfferCard._pickupAccent,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Center(
              child: Container(
                width: 2.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      DriverTripOfferCard._pickupAccent,
                      AppColors.primary,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const Icon(
          Icons.flag_rounded,
          size: 18,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

/// Pasajero, extras (solo iconos) y ETA/distancia hasta el recojo.
class DriverOfferPassengerBlock extends StatelessWidget {
  final AppLocalizations l10n;
  final String name;
  final double? rating;
  final double? etaToPickupMinutes;
  final double? distanceToPickupKm;
  final List<String> extras;
  final List<String> specials;

  const DriverOfferPassengerBlock({
    super.key,
    required this.l10n,
    required this.name,
    this.rating,
    this.etaToPickupMinutes,
    this.distanceToPickupKm,
    this.extras = const [],
    this.specials = const [],
  });

  @override
  Widget build(BuildContext context) {
    final hasPickupMetrics =
        etaToPickupMinutes != null || distanceToPickupKm != null;
    final hasExtras = extras.isNotEmpty || specials.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(AppFoundation.radiusSm),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: AppColors.primary.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (rating != null) ...[
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 3),
                Text(
                  rating!.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          if (hasPickupMetrics || hasExtras) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (hasPickupMetrics)
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (etaToPickupMinutes != null)
                          DriverOfferMetricChip(
                            icon: Icons.schedule_rounded,
                            label: DriverTripOfferCard.formatDuration(
                              etaToPickupMinutes,
                            ),
                          ),
                        if (distanceToPickupKm != null)
                          DriverOfferMetricChip(
                            icon: Icons.near_me_rounded,
                            label: DriverTripOfferCard.formatDistance(
                              distanceToPickupKm,
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  const Spacer(),
                if (hasExtras)
                  DriverTripExtrasIcons(
                    l10n: l10n,
                    extras: extras,
                    specials: specials,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Chip de métrica (ETA, distancia) en solicitudes de viaje.
class DriverOfferMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool large;

  const DriverOfferMetricChip({
    super.key,
    required this.icon,
    required this.label,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: large ? 17 : 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: large ? 13.5 : 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
