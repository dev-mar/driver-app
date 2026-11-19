import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../core/ui/driver_ui_states.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_trip_offer.dart';
import 'driver_offer_see_on_map_button.dart';
import 'driver_trip_extras_icons.dart';
import 'driver_trip_payment_chip.dart';
import 'driver_trip_place_icon.dart';
import 'driver_trip_promo_breakdown.dart';

class DriverTripOfferCard extends StatelessWidget {
  final AppLocalizations l10n;
  final DriverTripOffer offer;
  final bool isProcessing;
  final bool isProcessingAccept;
  final String? errorMessage;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final Future<String?> Function(double amount)? onCounter;
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
    this.onCounter,
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
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
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
                              if (isWebDispatch) ...[
                                const SizedBox(height: 6),
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
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 5,
                          child: DriverTripPaymentTile(
                            l10n: l10n,
                            paymentMethod: offer.paymentMethod,
                            compact: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        DriverOfferSeeOnMapButton(
                          l10n: l10n,
                          enabled: !isProcessing,
                          onPressed: onPreview,
                        ),
                      ],
                    ),
                    if (offer.hasPromoBreakdown) ...[
                      const SizedBox(height: 10),
                      DriverTripPromoBreakdown(
                        l10n: l10n,
                        tripFare: offer.offeredPrice,
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
                    if (offer.negotiationEnabled && onCounter != null) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: isProcessing
                              ? null
                              : () => _askDriverCounterOffer(
                                    context,
                                    l10n,
                                    offer,
                                    onCounter!,
                                  ),
                          child: Text(l10n.driverTripCounter),
                        ),
                      ),
                    ],
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

/// 10, 20, 40 y 60 % del costo actual, redondeados al entero más cercano.
/// Un incremento de 0 no se ofrece: no superaría el monto del pasajero.
List<({int percent, int addon})> driverCounterAddons(double base) {
  if (base.isNaN || base.isInfinite || base <= 0) return const [];
  const percents = <int>[10, 20, 40, 60];
  final baseCents = (base * 100).round();
  final steps = <({int percent, int addon})>[];
  for (final percent in percents) {
    final addon = ((baseCents * percent) / 10000).round();
    if (addon < 1) continue;
    steps.add((percent: percent, addon: addon));
  }
  return steps;
}

double driverCounterTotal(double base, int addon) {
  final cents = (base * 100).round() + addon * 100;
  return cents / 100;
}

Future<void> _askDriverCounterOffer(
  BuildContext context,
  AppLocalizations l10n,
  DriverTripOffer offer,
  Future<String?> Function(double amount) onCounter,
) async {
  final base = offer.offeredPrice;
  if (base == null || base <= 0) return;
  final steps = driverCounterAddons(base);
  final amount = await showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppFoundation.radiusLg),
      ),
    ),
    builder: (sheetContext) {
      return _DriverCounterOfferSheet(
        l10n: l10n,
        base: base,
        currencyCode: offer.currencyCode,
        steps: steps,
      );
    },
  );
  if (amount == null || !context.mounted) return;
  final code = await onCounter(amount);
  if (!context.mounted) return;
  final message = switch (code) {
    null => l10n.driverTripCounterSent,
    'OFFER_ABOVE_CAP' => l10n.driverTripCounterAboveCap,
    'COUNTER_NOT_HIGHER' => l10n.driverTripCounterNotHigher,
    'NO_CONNECTION' => l10n.driverOfferErrorNoConnection,
    'BID_NOT_FOUND' ||
    'TRIP_NOT_NEGOTIABLE' ||
    'OFFER_EXPIRED' ||
    'TRIP_ALREADY_ACCEPTED' ||
    'TRIP_ALREADY_PROCESSED' ||
    'TRIP_TAKEN' ||
    'TRIP_NOT_AVAILABLE' => l10n.driverOfferErrorExpired,
    _ => l10n.driverTripCounterFailed,
  };
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    ),
  );
}

class _DriverCounterOfferSheet extends StatefulWidget {
  const _DriverCounterOfferSheet({
    required this.l10n,
    required this.base,
    required this.currencyCode,
    required this.steps,
  });

  final AppLocalizations l10n;
  final double base;
  final String? currencyCode;
  final List<({int percent, int addon})> steps;

  @override
  State<_DriverCounterOfferSheet> createState() =>
      _DriverCounterOfferSheetState();
}

class _DriverCounterOfferSheetState extends State<_DriverCounterOfferSheet> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final selected = _selected == null ? null : widget.steps[_selected!];
    final total = selected == null
        ? null
        : driverCounterTotal(widget.base, selected.addon);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.driverTripCounterTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.commonClose,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                color: AppColors.textSecondary,
              ),
            ],
          ),
          Text(
            l10n.driverTripCounterHint,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: AppColors.textSecondary.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.driverTripCounterCurrent,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DriverTripOfferCard.formatPrice(
              widget.base,
              currencyCode: widget.currencyCode,
            ),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: AppColors.textPrimary,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.driverTripCounterAdd,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          if (widget.steps.isEmpty)
            Text(
              l10n.driverTripCounterNotHigher,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            )
          else
            Row(
              children: [
                for (var i = 0; i < widget.steps.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _CounterStepChip(
                      selected: _selected == i,
                      addonLabel: l10n.driverTripCounterAddon(
                        widget.steps[i].addon,
                      ),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selected = i);
                      },
                    ),
                  ),
                ],
              ],
            ),
          const SizedBox(height: 16),
          Text(
            l10n.driverTripCounterTotal,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            total == null
                ? '—'
                : DriverTripOfferCard.formatPrice(
                    total,
                    currencyCode: widget.currencyCode,
                  ),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: total == null
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop(total);
                  },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              disabledBackgroundColor: AppColors.surface,
              disabledForegroundColor: AppColors.textSecondary,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.driverTripCounterSend,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterStepChip extends StatelessWidget {
  const _CounterStepChip({
    required this.selected,
    required this.addonLabel,
    required this.onTap,
  });

  final bool selected;
  final String addonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.onPrimary : AppColors.textPrimary;
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 72,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            addonLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: fg,
              height: 1.05,
              letterSpacing: -0.4,
            ),
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
          SizedBox(
            width: 22,
            child: _RouteRail(
              pickupIcon: resolveDriverTripPlaceIcon(
                originText,
                kind: DriverTripPlaceKind.pickup,
              ),
              destinationIcon: resolveDriverTripPlaceIcon(
                destinationText,
                kind: DriverTripPlaceKind.destination,
              ),
            ),
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
  const _RouteRail({
    required this.pickupIcon,
    required this.destinationIcon,
  });

  final IconData pickupIcon;
  final IconData destinationIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          pickupIcon,
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
        Icon(
          destinationIcon,
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
  final bool describeExtras;

  const DriverOfferPassengerBlock({
    super.key,
    required this.l10n,
    required this.name,
    this.rating,
    this.etaToPickupMinutes,
    this.distanceToPickupKm,
    this.extras = const [],
    this.specials = const [],
    this.describeExtras = false,
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (rating != null) ...[
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        if (hasPickupMetrics) ...[
                          if (rating != null)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(99),
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary.withValues(
                                          alpha: 0.2,
                                        ),
                                        DriverTripOfferCard._pickupAccent
                                            .withValues(alpha: 0.85),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            const Spacer(),
                          if (etaToPickupMinutes != null)
                            _PickupInlineMetric(
                              icon: Icons.schedule_rounded,
                              label: DriverTripOfferCard.formatDuration(
                                etaToPickupMinutes,
                              ),
                            ),
                          if (etaToPickupMinutes != null &&
                              distanceToPickupKm != null)
                            const SizedBox(width: 8),
                          if (distanceToPickupKm != null)
                            _PickupInlineMetric(
                              icon: Icons.near_me_rounded,
                              label: DriverTripOfferCard.formatDistance(
                                distanceToPickupKm,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasExtras) ...[
            const SizedBox(height: 10),
            if (describeExtras)
              DriverTripExtrasDescribedList(
                l10n: l10n,
                extras: extras,
                specials: specials,
              )
            else
              DriverTripExtrasIcons(
                l10n: l10n,
                extras: extras,
                specials: specials,
              ),
          ],
        ],
      ),
    );
  }
}

class _PickupInlineMetric extends StatelessWidget {
  const _PickupInlineMetric({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: DriverTripOfferCard._pickupAccent),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.1,
          ),
        ),
      ],
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
