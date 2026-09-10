import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../gen_l10n/app_localizations.dart';

/// Atajo a Maps dentro del detalle del viaje: no imita los CTA primarios (Llegué / Iniciar).
class DriverAssistedTripNavButtons extends StatefulWidget {
  const DriverAssistedTripNavButtons({
    super.key,
    required this.showPickup,
    required this.showDestination,
    required this.tripStatus,
    required this.l10n,
    required this.onNavigateToPickup,
    required this.onNavigateToDestination,
    this.pickupHint,
    this.destinationHint,
  });

  final bool showPickup;
  final bool showDestination;
  final String tripStatus;
  final AppLocalizations l10n;
  final VoidCallback onNavigateToPickup;
  final VoidCallback onNavigateToDestination;
  final String? pickupHint;
  final String? destinationHint;

  @override
  State<DriverAssistedTripNavButtons> createState() =>
      DriverAssistedTripNavButtonsState();
}

class DriverAssistedTripNavButtonsState extends State<DriverAssistedTripNavButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _t = CurvedAnimation(parent: _pulse, curve: AppMotion.standard);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navToPickupFirst = _shouldNavigateToPickupFirst(widget.tripStatus);
    final canUsePickup = widget.showPickup;
    final canUseDestination = widget.showDestination;
    final shouldUsePickup = navToPickupFirst
        ? canUsePickup
        : !canUseDestination;
    final isPickup = shouldUsePickup;
    final fallbackHint = isPickup
        ? widget.l10n.tripOrigin
        : widget.l10n.tripDestination;
    final addressHint = isPickup ? widget.pickupHint : widget.destinationHint;
    final hint = (addressHint != null && addressHint.trim().isNotEmpty)
        ? addressHint.trim()
        : fallbackHint;
    final onTap = isPickup
        ? widget.onNavigateToPickup
        : widget.onNavigateToDestination;

    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        final wave = 0.55 + 0.45 * _t.value;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.14 + 0.08 * wave),
                    AppColors.surface.withValues(alpha: 0.35),
                  ],
                ),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.28 + 0.22 * wave),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                child: Row(
                  children: [
                    Transform.scale(
                      scale: 0.96 + 0.06 * wave,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(
                                alpha: 0.28 + 0.22 * wave,
                              ),
                              blurRadius: 10 + 6 * wave,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          isPickup
                              ? Icons.explore_rounded
                              : Icons.near_me_rounded,
                          color: AppColors.onPrimary,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.l10n.driverTripOpenMapsCta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hint,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.95,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.north_east_rounded,
                      size: 18,
                      color: AppColors.primary.withValues(alpha: 0.9),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _shouldNavigateToPickupFirst(String status) {
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
}
