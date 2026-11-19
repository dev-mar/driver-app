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
    this.showLabels = false,
  });

  final AppLocalizations l10n;
  final List<String> extras;
  final List<String> specials;
  final bool showLabels;

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
          borderRadius: BorderRadius.circular(12),
          child: showLabels
              ? ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final code in specialCodes)
                        _ExtraChip(
                          icon: driverTripSpecialIcon(code),
                          label: driverTripSpecialChipLabel(l10n, code),
                          color: _special,
                        ),
                      for (final code in extraCodes)
                        _ExtraChip(
                          icon: driverTripExtraIcon(code),
                          label: driverTripExtraChipLabel(l10n, code),
                          color: _muted,
                        ),
                    ],
                  ),
                )
              : ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final code in specialCodes)
                        _ExtraGlyphTile(
                          icon: driverTripSpecialIcon(code),
                          color: _special,
                        ),
                      for (final code in extraCodes)
                        _ExtraGlyphTile(
                          icon: driverTripExtraIcon(code),
                          color: _muted,
                        ),
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

/// Lista descrita de extras para el detalle del viaje.
class DriverTripExtrasDescribedList extends StatelessWidget {
  const DriverTripExtrasDescribedList({
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.driverTripExtrasTitle,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        for (final code in specialCodes)
          _AddonDetailRow(
            icon: driverTripSpecialIcon(code),
            accent: _special,
            title: driverTripSpecialAlert(l10n, code),
            detail: driverTripSpecialDetail(l10n, code),
          ),
        for (final code in extraCodes)
          _AddonDetailRow(
            icon: driverTripExtraIcon(code),
            accent: _muted,
            title: driverTripExtraAlert(l10n, code),
            detail: driverTripExtraDetail(l10n, code),
          ),
      ],
    );
  }
}

class _ExtraGlyphTile extends StatelessWidget {
  const _ExtraGlyphTile({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.28),
            color.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.2),
      ),
      child: Icon(icon, size: 22, color: color.withValues(alpha: 0.98)),
    );
  }
}

class _ExtraChip extends StatelessWidget {
  const _ExtraChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.42), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color.withValues(alpha: 0.95)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
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
                if (detail.isNotEmpty) ...[
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String driverTripExtraChipLabel(AppLocalizations l10n, String code) {
  switch (normalizeDriverTripExtraCode(code)) {
    case 'pet':
      return l10n.driverTripExtraPet;
    case 'child_seat':
      return l10n.driverTripExtraChildSeat;
    case 'wheelchair':
      return l10n.driverTripExtraWheelchair;
    case 'over_4':
      return l10n.driverTripExtraOver4;
    case 'luggage':
      return l10n.driverTripExtraLuggage;
    case 'ac':
      return l10n.driverTripExtraAc;
    default:
      return code;
  }
}

String driverTripSpecialChipLabel(AppLocalizations l10n, String code) {
  switch (normalizeDriverTripSpecialCode(code)) {
    case 'seats_6':
      return l10n.driverTripSpecialSeats6;
    case 'roof_rack':
      return l10n.driverTripSpecialRoofRack;
    case 'cargo':
      return l10n.driverTripSpecialCargo;
    default:
      return code;
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
