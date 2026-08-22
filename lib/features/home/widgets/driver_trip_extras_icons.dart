import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_trip_offer.dart';

/// Iconos compactos de preferencias y requerimientos en la card.
/// Tap abre hoja cerrable (arrastre, tap fuera o Cerrar).
class DriverTripExtrasIcons extends StatelessWidget {
  const DriverTripExtrasIcons({
    super.key,
    required this.l10n,
    required this.extras,
    this.specials = const [],
  });

  final AppLocalizations l10n;
  final List<String> extras;
  final List<String> specials;

  static const Color _muted = Color(0xFF94A3B8);
  static const Color _special = Color(0xFFD97706);

  @override
  Widget build(BuildContext context) {
    final extraCodes = extras
        .map(normalizeDriverTripExtraCode)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    final specialCodes = specials
        .map(normalizeDriverTripSpecialCode)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    if (extraCodes.isEmpty && specialCodes.isEmpty) {
      return const SizedBox.shrink();
    }

    final labels = [
      ...specialCodes.map((c) => driverTripSpecialAlert(l10n, c)),
      ...extraCodes.map((c) => driverTripExtraAlert(l10n, c)),
    ];

    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: labels.join(' · '),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            showDriverTripExtrasSheet(
              context: context,
              l10n: l10n,
              extras: extraCodes,
              specials: specialCodes,
            );
          },
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: specialCodes.isNotEmpty
                  ? _special.withValues(alpha: 0.14)
                  : _muted.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: specialCodes.isNotEmpty
                    ? _special.withValues(alpha: 0.42)
                    : _muted.withValues(alpha: 0.38),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < specialCodes.length; i++) ...[
                  if (i > 0) const SizedBox(width: 5),
                  Icon(
                    driverTripSpecialIcon(specialCodes[i]),
                    size: 13,
                    color: _special.withValues(alpha: 0.95),
                  ),
                ],
                if (specialCodes.isNotEmpty && extraCodes.isNotEmpty)
                  const SizedBox(width: 5),
                for (var i = 0; i < extraCodes.length; i++) ...[
                  if (i > 0) const SizedBox(width: 5),
                  Icon(
                    driverTripExtraIcon(extraCodes[i]),
                    size: 13,
                    color: _muted.withValues(alpha: 0.95),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showDriverTripExtrasSheet({
  required BuildContext context,
  required AppLocalizations l10n,
  required List<String> extras,
  List<String> specials = const [],
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    useRootNavigator: false,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(ctx).bottom),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.driverTripExtrasTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                specials.isNotEmpty
                    ? l10n.driverTripAddonsHint
                    : l10n.driverTripExtrasHint,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: AppColors.textSecondary.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(height: 12),
              for (final code in specials)
                _AddonDetailRow(
                  icon: driverTripSpecialIcon(code),
                  accent: const Color(0xFFD97706),
                  title: driverTripSpecialAlert(l10n, code),
                  detail: driverTripSpecialDetail(l10n, code),
                ),
              for (final code in extras)
                _AddonDetailRow(
                  icon: driverTripExtraIcon(code),
                  accent: AppColors.textSecondary,
                  title: driverTripExtraAlert(l10n, code),
                  detail: driverTripExtraDetail(l10n, code),
                ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppFoundation.radiusSm),
                    ),
                  ),
                  child: Text(l10n.driverTripExtrasClose),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _AddonDetailRow extends StatelessWidget {
  const _AddonDetailRow({
    required this.icon,
    required this.accent,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: AppColors.textSecondary.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

IconData driverTripExtraIcon(String code) {
  switch (normalizeDriverTripExtraCode(code)) {
    case 'pet':
      return Icons.pets_rounded;
    case 'child_seat':
      return Icons.child_care_rounded;
    case 'wheelchair':
      return Icons.accessible_rounded;
    case 'over_4':
      return Icons.groups_rounded;
    case 'luggage':
      return Icons.luggage_rounded;
    case 'ac':
      return Icons.ac_unit_rounded;
    default:
      return Icons.info_outline_rounded;
  }
}

IconData driverTripSpecialIcon(String code) {
  switch (normalizeDriverTripSpecialCode(code)) {
    case 'seats_6':
      return Icons.groups_rounded;
    case 'roof_rack':
      return Icons.airport_shuttle_rounded;
    case 'cargo':
      return Icons.inventory_2_outlined;
    default:
      return Icons.priority_high_rounded;
  }
}

String driverTripExtraAlert(AppLocalizations l10n, String code) {
  switch (normalizeDriverTripExtraCode(code)) {
    case 'pet':
      return l10n.driverTripExtraPetAlert;
    case 'child_seat':
      return l10n.driverTripExtraChildSeat;
    case 'wheelchair':
      return l10n.driverTripExtraWheelchairAlert;
    case 'over_4':
      return l10n.driverTripExtraOver4;
    case 'luggage':
      return l10n.driverTripExtraLuggageAlert;
    case 'ac':
      return l10n.driverTripExtraAcAlert;
    default:
      return code;
  }
}

String driverTripExtraDetail(AppLocalizations l10n, String code) {
  switch (normalizeDriverTripExtraCode(code)) {
    case 'pet':
      return l10n.driverTripExtraPetDetail;
    case 'wheelchair':
      return l10n.driverTripExtraWheelchairDetail;
    case 'luggage':
      return l10n.driverTripExtraLuggageDetail;
    case 'ac':
      return l10n.driverTripExtraAcDetail;
    default:
      return '';
  }
}

String driverTripSpecialAlert(AppLocalizations l10n, String code) {
  switch (normalizeDriverTripSpecialCode(code)) {
    case 'seats_6':
      return l10n.driverTripSpecialSeats6Alert;
    case 'roof_rack':
      return l10n.driverTripSpecialRoofRackAlert;
    case 'cargo':
      return l10n.driverTripSpecialCargoAlert;
    default:
      return code;
  }
}

String driverTripSpecialDetail(AppLocalizations l10n, String code) {
  switch (normalizeDriverTripSpecialCode(code)) {
    case 'seats_6':
      return l10n.driverTripSpecialSeats6Detail;
    case 'roof_rack':
      return l10n.driverTripSpecialRoofRackDetail;
    case 'cargo':
      return l10n.driverTripSpecialCargoDetail;
    default:
      return '';
  }
}

/// Compat para llamadas antiguas que solo tenían título.
String driverTripExtraLabel(AppLocalizations l10n, String code) {
  return driverTripExtraAlert(l10n, code);
}
