import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../gen_l10n/app_localizations.dart';

/// Atajo desde Ingresos y créditos hacia la pantalla de recargas.
class DriverCreditsTopupEntryCard extends StatelessWidget {
  const DriverCreditsTopupEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Material(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
          onTap: () {
            HapticFeedback.lightImpact();
            context.pushNamed(AppRouter.creditsTopup);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.driverTopupOpenFromEarnings,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.driverTopupOpenFromEarningsHint,
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.95),
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
