import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../club/club_colors.dart';
import '../../club/driver_club_models.dart';
import '../../club/driver_club_repository.dart';
import '../../session/driver_operational_profile.dart';

/// Categoría Club para el escudo del home (oficial o derivada de la nota).
class DriverHomeTierVisual {
  const DriverHomeTierVisual({
    required this.code,
    required this.color,
    this.badgeUrl,
  });

  final String code;
  final Color color;
  final String? badgeUrl;
}

/// Hub Club en segundo plano: si falla, el home usa la nota media.
final driverHomeClubTierProvider = FutureProvider<DriverClubTier?>((ref) async {
  final canOperate = ref
      .watch(driverOperationalProfileProvider)
      .maybeWhen(data: (p) => p.canOperateAsDriver, orElse: () => false);
  if (!canOperate) return null;
  try {
    return (await DriverClubRepository().fetchHub()).tier;
  } catch (_) {
    return null;
  }
});

DriverHomeTierVisual resolveDriverHomeTierVisual({
  DriverClubTier? official,
  double? rating,
}) {
  final officialCode = official?.code.trim().toLowerCase() ?? '';
  if (officialCode.isNotEmpty) {
    return DriverHomeTierVisual(
      code: officialCode,
      color: ClubColors.fromHex(
        official!.colorHex,
        fallback: _colorForCode(officialCode),
      ),
      badgeUrl: official.badgeUrl,
    );
  }
  final code = _codeFromRating(rating);
  return DriverHomeTierVisual(code: code, color: _colorForCode(code));
}

String driverHomeTierShortLabel(AppLocalizations l10n, String code) {
  switch (code.trim().toLowerCase()) {
    case 'elite':
      return l10n.driverHomeMiniTierElite;
    case 'premium':
      return l10n.driverHomeMiniTierPremium;
    case 'pro':
      return l10n.driverHomeMiniTierPro;
    case 'essential':
      return l10n.driverHomeMiniTierEssential;
    default:
      return l10n.driverHomeMiniTierStart;
  }
}

String _codeFromRating(double? rating) {
  if (rating == null) return 'start';
  if (rating >= 4.85) return 'elite';
  if (rating >= 4.70) return 'premium';
  if (rating >= 4.50) return 'pro';
  if (rating >= 4.20) return 'essential';
  return 'start';
}

Color _colorForCode(String code) {
  switch (code) {
    case 'elite':
      return ClubColors.gold;
    case 'premium':
      return ClubColors.violet;
    case 'pro':
      return ClubColors.teal;
    case 'essential':
      return ClubColors.sky;
    default:
      return ClubColors.muted;
  }
}

/// Escudo de categoría (Start / Essential / Pro / Premium / Elite) en el slot del mini perfil.
class DriverHomeTierBadge extends StatelessWidget {
  const DriverHomeTierBadge({
    super.key,
    required this.visual,
    required this.label,
  });

  final DriverHomeTierVisual visual;
  final String label;

  static const double size = 52;

  @override
  Widget build(BuildContext context) {
    final url = visual.badgeUrl?.trim() ?? '';
    return Semantics(
      label: label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: visual.color.withValues(alpha: 0.16),
          border: Border.all(
            color: visual.color.withValues(alpha: 0.55),
            width: 1.4,
          ),
          boxShadow: AppShadows.circularAvatarAmbient,
        ),
        clipBehavior: Clip.antiAlias,
        child: url.isNotEmpty
            ? Image.network(
                url,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    _FallbackMark(color: visual.color, label: label),
              )
            : _FallbackMark(color: visual.color, label: label),
      ),
    );
  }
}

class _FallbackMark extends StatelessWidget {
  const _FallbackMark({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.workspace_premium_rounded, color: color, size: 22),
        const SizedBox(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              height: 1.05,
              letterSpacing: 0.15,
            ),
          ),
        ),
      ],
    );
  }
}

/// Placa destacada del vehículo en el mini perfil.
class DriverHomePlateChip extends StatelessWidget {
  const DriverHomePlateChip({super.key, required this.plate});

  final String plate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.onPrimary, width: 1.6),
      ),
      child: Text(
        plate.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.onPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          height: 1.05,
        ),
      ),
    );
  }
}
