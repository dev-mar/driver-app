import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../gen_l10n/app_localizations.dart';

/// Botones de apertura de navegación externa con pulso suave y copy que clarifica el gesto.
class DriverAssistedTripNavButtons extends StatefulWidget {
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
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _t = CurvedAnimation(parent: _pulse, curve: Curves.easeInOutCubic);
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
    final title = isPickup
        ? widget.l10n.driverTripNavigatePickup
        : widget.l10n.driverTripNavigateDestination;
    final subtitle = isPickup
        ? widget.l10n.tripOrigin
        : widget.l10n.tripDestination;
    final icon = isPickup ? Icons.near_me_rounded : Icons.turn_right_rounded;
    final onTap = isPickup
        ? widget.onNavigateToPickup
        : widget.onNavigateToDestination;

    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        final wave = isPickup ? _t.value : (1 - _t.value);
        return _assistedNavPill(
          context,
          glow: 0.24 + 0.52 * wave,
          iconScale: 1.0 + 0.09 * wave,
          isPickup: isPickup,
          title: title,
          subtitle: subtitle,
          icon: icon,
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
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

  Widget _assistedNavPill(
    BuildContext context, {
    required double glow,
    required double iconScale,
    required bool isPickup,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final borderColor = AppColors.primary.withValues(
      alpha: isPickup ? glow * 0.55 : glow * 0.7,
    );
    final bg = isPickup
        ? AppColors.primary.withValues(alpha: 0.12 + 0.06 * glow)
        : AppColors.primary.withValues(alpha: 0.88 + 0.06 * glow);
    final fg = isPickup ? AppColors.textPrimary : AppColors.onPrimary;
    final subFg = isPickup
        ? AppColors.textSecondary.withValues(alpha: 0.9)
        : AppColors.onPrimary.withValues(alpha: 0.88);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: isPickup ? 1.25 : 1.15,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: isPickup ? 0.08 : 0.2,
                ),
                blurRadius: 10 + 6 * glow,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            child: Row(
              children: [
                Transform.scale(
                  scale: iconScale,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          (isPickup ? AppColors.primary : AppColors.onPrimary)
                              .withValues(alpha: isPickup ? 0.18 : 0.22),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: isPickup ? AppColors.primary : AppColors.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: fg,
                                height: 1.15,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 16,
                            color: subFg,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: subFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
