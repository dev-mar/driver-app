import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../core/ui/driver_ui_states.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_trip_offer.dart';

class DriverTripOfferCard extends StatelessWidget {
  final AppLocalizations l10n;
  final DriverTripOffer offer;
  final bool isProcessing;
  final bool isProcessingAccept;
  final String? errorMessage;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const DriverTripOfferCard({
    super.key,
    required this.l10n,
    required this.offer,
    required this.isProcessing,
    required this.isProcessingAccept,
    required this.errorMessage,
    required this.onAccept,
    required this.onReject,
  });

  static String _formatPrice(double? value, {String? currencyCode}) {
    return formatMoney(value, currencyCode: currencyCode);
  }

  static String _formatDistance(double? km) {
    if (km == null) return '—';
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  static String _formatDurationWithUnit(BuildContext context, double? minutes) {
    if (minutes == null) return '—';
    final m = minutes.round();
    if (m <= 0) return '<1 min';
    if (m < 60) return '$m min';
    final h = m ~/ 60;
    final rem = m % 60;
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'es') {
      if (rem == 0) return '$h h';
      return '$h h ${rem.toString().padLeft(2, '0')} min';
    }
    if (rem == 0) return '$h h';
    return '$h h ${rem.toString().padLeft(2, '0')} min';
  }

  static const Color _operationsAccent = Color(0xFFFB923C);

  @override
  Widget build(BuildContext context) {
    final isWebDispatch = offer.isAdminWebDispatch;
    final hasPrice = offer.offeredPrice != null;
    final hasRouteEta = offer.etaToDestinationMinutes != null;
    final hasTripKm = offer.tripDistanceKm != null;
    final hasPassenger = (offer.passengerName ?? '').isNotEmpty;
    final passengerRatingValue = offer.passengerRating ?? 5.0;
    final hasRating = !isWebDispatch;
    final showChips = hasRouteEta || hasTripKm;
    final badgeColor = isWebDispatch ? _operationsAccent : AppColors.primary;

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
                      AppColors.primary.withValues(alpha: 0.06),
                    ],
                    stops: const [0.0, 0.72, 1.0],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            hasPrice
                                ? _formatPrice(
                                    offer.offeredPrice,
                                    currencyCode: offer.currencyCode,
                                  )
                                : l10n.driverTripOfferPriceTbd,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
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
                                isWebDispatch
                                    ? Icons.support_agent_rounded
                                    : Icons.bolt_rounded,
                                size: 13,
                                color: badgeColor.withValues(alpha: 0.95),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isWebDispatch
                                    ? l10n.driverTripOfferBadgeOperations
                                    : l10n.driverTripOfferBadgeNew,
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
                    ),
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
                    if (showChips) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (hasRouteEta)
                            DriverOfferMetricChip(
                              icon: Icons.schedule_rounded,
                              label: _formatDurationWithUnit(
                                context,
                                offer.etaToDestinationMinutes,
                              ),
                              large: true,
                            ),
                          if (hasTripKm)
                            DriverOfferMetricChip(
                              icon: Icons.route_rounded,
                              label: _formatDistance(offer.tripDistanceKm),
                              large: true,
                            ),
                        ],
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
                    DriverOfferOriginRow(
                      originText: originText,
                      distanceToPickupKm: offer.distanceToPickupKm,
                    ),
                    const SizedBox(height: 6),
                    DriverOfferCompactAddressLine(
                      icon: Icons.flag_rounded,
                      text: destText,
                      iconColor: AppColors.primary,
                    ),
                    const SizedBox(height: 10),
                    if (hasPassenger || hasRating) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.38),
                          borderRadius: BorderRadius.circular(
                            AppFoundation.radiusSm,
                          ),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.55),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_rounded,
                              size: 18,
                              color: AppColors.primary.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                offer.passengerName ??
                                    l10n.driverTripRatingPassengerDefault,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasRating) ...[
                              Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                passengerRatingValue.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                      DriverInlineError(message: errorMessage!),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isProcessing ? null : onReject,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: Size.zero,
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
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: isProcessing ? null : onAccept,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: Size.zero,
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
              fontSize: large ? 13.5 : 11.5,
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

class DriverOfferOriginRow extends StatelessWidget {
  final String originText;
  final double? distanceToPickupKm;

  const DriverOfferOriginRow({
    super.key,
    required this.originText,
    required this.distanceToPickupKm,
  });

  @override
  Widget build(BuildContext context) {
    final distanceText = DriverTripOfferCard._formatDistance(distanceToPickupKm);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.place_rounded, size: 16, color: const Color(0xFF00BFA5)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            originText,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (distanceToPickupKm != null) ...[
          const SizedBox(width: 10),
          Text(
            distanceText,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class DriverOfferCompactAddressLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const DriverOfferCompactAddressLine({
    super.key,
    required this.icon,
    required this.text,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

