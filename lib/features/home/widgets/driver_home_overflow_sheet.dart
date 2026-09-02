import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../gen_l10n/app_localizations.dart';

Future<void> showDriverHomeOverflowSheet({
  required BuildContext context,
  required bool canClub,
  required VoidCallback onLogout,
}) async {
  HapticFeedback.lightImpact();
  final l10n = AppLocalizations.of(context);
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppFoundation.spacingLg,
            0,
            AppFoundation.spacingLg,
            AppFoundation.spacingLg,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
              boxShadow: AppShadows.soft,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.driverHomeMenuTitle,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _sectionLabel(l10n.driverHomeMenuSectionAccount),
                  _row(
                    ctx,
                    icon: Icons.person_outline_rounded,
                    label: l10n.driverProfileMenu,
                    onTap: () => context.goNamed(AppRouter.profile),
                  ),
                  _row(
                    ctx,
                    icon: Icons.directions_car_outlined,
                    label: l10n.driverHomeMenuAddVehicle,
                    onTap: () => context.pushNamed(AppRouter.myVehicles),
                  ),
                  const SizedBox(height: 10),
                  _sectionLabel(l10n.driverHomeMenuSectionActivity),
                  _row(
                    ctx,
                    icon: Icons.route_outlined,
                    label: l10n.driverTripHistoryMenu,
                    onTap: () => context.pushNamed(AppRouter.tripHistory),
                  ),
                  _row(
                    ctx,
                    icon: Icons.account_balance_wallet_outlined,
                    label: l10n.driverEarningsCreditsMenu,
                    onTap: () => context.pushNamed(AppRouter.earningsCredits),
                  ),
                  _row(
                    ctx,
                    icon: Icons.qr_code_2_rounded,
                    label: l10n.driverTopupMenu,
                    onTap: () => context.pushNamed(AppRouter.creditsTopup),
                  ),
                  if (canClub)
                    _row(
                      ctx,
                      icon: Icons.workspace_premium_outlined,
                      label: l10n.driverClubMenu,
                      accent: AppColors.primary,
                      onTap: () => context.pushNamed(AppRouter.club),
                    ),
                  const SizedBox(height: 10),
                  _sectionLabel(l10n.driverHomeMenuSectionSession),
                  _row(
                    ctx,
                    icon: Icons.logout_rounded,
                    label: l10n.driverLogout,
                    accent: AppColors.error,
                    onTap: onLogout,
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

Widget _sectionLabel(String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 2),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.9),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
      ),
    ),
  );
}

Widget _row(
  BuildContext sheetContext, {
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  Color? accent,
}) {
  final color = accent ?? AppColors.textPrimary;
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Material(
      color: AppColors.surface.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(AppFoundation.radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppFoundation.radiusSm),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(sheetContext).pop();
          Future<void>.microtask(onTap);
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
