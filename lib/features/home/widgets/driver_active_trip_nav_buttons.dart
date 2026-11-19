import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../gen_l10n/app_localizations.dart';
import 'driver_maps_navigate_mark.dart';

/// Origen primero mientras el conductor todavía no inició el viaje.
bool driverNavigateToPickupFirst(String status) {
  switch (status) {
    case 'accepted':
    case 'arrived':
      return true;
    case 'started':
    case 'in_trip':
    case 'completed':
    case 'cancelled':
      return false;
    default:
      return true;
  }
}

/// Atajo compacto a Maps, alineado a las direcciones del viaje.
/// No imita los CTA primarios (Llegué / Iniciar).
class DriverAssistedTripNavButtons extends StatelessWidget {
  const DriverAssistedTripNavButtons({
    super.key,
    required this.showPickup,
    required this.showDestination,
    required this.tripStatus,
    required this.l10n,
    required this.onNavigateToPickup,
    required this.onNavigateToDestination,
  });

  final bool showPickup;
  final bool showDestination;
  final String tripStatus;
  final AppLocalizations l10n;
  final VoidCallback onNavigateToPickup;
  final VoidCallback onNavigateToDestination;

  @override
  Widget build(BuildContext context) {
    final isPickup = driverNavigateToPickupFirst(tripStatus)
        ? showPickup
        : !showDestination;
    final onTap = isPickup ? onNavigateToPickup : onNavigateToDestination;
    final tooltip = isPickup
        ? l10n.driverTripNavigatePickup
        : l10n.driverTripNavigateDestination;

    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        excludeFromSemantics: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            borderRadius: BorderRadius.circular(AppFoundation.radiusSm),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppFoundation.spacingXs,
                  vertical: AppFoundation.spacingXs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const DriverMapsNavigateMark(size: 40),
                          const SizedBox(height: 2),
                          Text(
                            l10n.driverTripOpenMapsCta,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              height: 1.05,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mismo atajo que la tarjeta, en el círculo del mapa (debajo del GPS).
class DriverMapAssistedNavButton extends StatelessWidget {
  const DriverMapAssistedNavButton({
    super.key,
    required this.tooltip,
    required this.onPressed,
  });

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        excludeFromSemantics: true,
        child: Material(
          color: AppColors.surfaceCard.withValues(alpha: 0.94),
          shape: const CircleBorder(),
          elevation: 10,
          shadowColor: Colors.black.withValues(alpha: 0.28),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              HapticFeedback.lightImpact();
              onPressed();
            },
            child: const SizedBox(
              width: 48,
              height: 48,
              child: Center(child: DriverMapsNavigateArrow(size: 28)),
            ),
          ),
        ),
      ),
    );
  }
}
