import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../core/ui/driver_ui_states.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_trip_offer.dart';
import 'driver_offer_card.dart';
import 'driver_offer_preview_map.dart';
import 'driver_trip_extras_icons.dart';
import 'driver_trip_payment_chip.dart';
import 'driver_trip_promo_breakdown.dart';

/// Previsualización de una solicitud pendiente.
///
/// No llama a accept/reject por sí sola: [onAccept] es el único camino al
/// viaje activo. [onBack] solo cierra esta vista.
class DriverOfferPreviewView extends StatelessWidget {
  const DriverOfferPreviewView({
    super.key,
    required this.offer,
    required this.isProcessing,
    required this.isProcessingAccept,
    this.errorMessage,
    required this.onBack,
    required this.onAccept,
  });

  final DriverTripOffer offer;
  final bool isProcessing;
  final bool isProcessingAccept;
  final String? errorMessage;
  final VoidCallback onBack;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasPrice = offer.offeredPrice != null;
    final passengerName = (offer.passengerName ?? '').trim().isNotEmpty
        ? offer.passengerName!
        : l10n.driverTripRatingPassengerDefault;
    final originText = (offer.originAddress ?? '').isNotEmpty
        ? offer.originAddress!
        : l10n.tripOrigin;
    final destText = (offer.destinationAddress ?? '').isNotEmpty
        ? offer.destinationAddress!
        : l10n.tripDestination;
    final hasTripKm = offer.tripDistanceKm != null;
    final hasTripEta = offer.etaToDestinationMinutes != null;
    final hasExtras =
        offer.tripExtras.isNotEmpty || offer.tripSpecials.isNotEmpty;

    return Stack(
      children: [
        Positioned.fill(
          child: DriverOfferPreviewMap(offer: offer),
        ),
        if (hasTripKm || hasTripEta)
          Positioned(
            top: 8,
            left: 16,
            right: 16,
            child: SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasTripKm) ...[
                        Icon(
                          Icons.route_rounded,
                          size: 16,
                          color: AppColors.primary.withValues(alpha: 0.95),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DriverTripOfferCard.formatDistance(
                            offer.tripDistanceKm,
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                      if (hasTripKm && hasTripEta)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            width: 1,
                            height: 12,
                            color: AppColors.border,
                          ),
                        ),
                      if (hasTripEta) ...[
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: AppColors.primary.withValues(alpha: 0.95),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DriverTripOfferCard.formatDuration(
                            offer.etaToDestinationMinutes,
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 420),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard.withValues(alpha: 0.97),
                    borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.65),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.driverTripOfferDetailTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.9,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hasPrice
                              ? DriverTripOfferCard.formatPrice(
                                  offer.offeredPrice,
                                  currencyCode: offer.currencyCode,
                                )
                              : l10n.driverTripOfferPriceTbd,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.center,
                          child: DriverTripPaymentChip(
                            l10n: l10n,
                            paymentMethod: offer.paymentMethod,
                          ),
                        ),
                        if (offer.hasPromoBreakdown) ...[
                          const SizedBox(height: 10),
                          DriverTripPromoBreakdown(
                            l10n: l10n,
                            cashDuePassenger: offer.cashDuePassenger,
                            companyGuaranteeToDriver:
                                offer.companyGuaranteeToDriver,
                            currencyCode: offer.currencyCode,
                            isReferralSupport:
                                offer.isPassengerReferralSupport,
                            emphasizeCompanyLine: true,
                          ),
                        ],
                        const SizedBox(height: 12),
                        _AddressMini(
                          icon: Icons.place_rounded,
                          iconColor: const Color(0xFF00BFA5),
                          text: originText,
                        ),
                        const SizedBox(height: 6),
                        _AddressMini(
                          icon: Icons.flag_rounded,
                          iconColor: AppColors.primary,
                          text: destText,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.38),
                            borderRadius: BorderRadius.circular(
                              AppFoundation.radiusSm,
                            ),
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.55),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      passengerName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (!offer.isAdminWebDispatch) ...[
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      (offer.passengerRating ?? 5.0)
                                          .toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (offer.etaMinutes != null ||
                                  offer.distanceToPickupKm != null) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    if (offer.etaMinutes != null)
                                      DriverOfferMetricChip(
                                        icon: Icons.schedule_rounded,
                                        label:
                                            DriverTripOfferCard.formatDuration(
                                          offer.etaMinutes,
                                        ),
                                      ),
                                    if (offer.distanceToPickupKm != null)
                                      DriverOfferMetricChip(
                                        icon: Icons.near_me_rounded,
                                        label:
                                            DriverTripOfferCard.formatDistance(
                                          offer.distanceToPickupKm,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                              if (hasExtras) ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: DriverTripExtrasIcons(
                                    l10n: l10n,
                                    extras: offer.tripExtras,
                                    specials: offer.tripSpecials,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (errorMessage != null &&
                            errorMessage!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          DriverInlineError(message: errorMessage!),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.check_circle_outline_rounded,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            l10n.driverTripAccept,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isProcessing && isProcessingAccept
                                    ? null
                                    : () {
                                        HapticFeedback.lightImpact();
                                        onBack();
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textPrimary,
                                  side: BorderSide(
                                    color: AppColors.border.withValues(
                                      alpha: 0.9,
                                    ),
                                  ),
                                  minimumSize: const Size(0, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  l10n.driverTripOfferPreviewBack,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddressMini extends StatelessWidget {
  const _AddressMini({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}
