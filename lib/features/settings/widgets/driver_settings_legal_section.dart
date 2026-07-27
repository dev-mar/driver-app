import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/compliance/driver_account_deletion_service.dart';
import '../../../core/compliance/driver_legal_links.dart';
import '../../../core/network/driver_profile_api_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../features/login/driver_login_controller.dart';
import '../../../gen_l10n/app_localizations.dart';

Future<void> showDriverAccountDeletionDialog(
  BuildContext context,
  AppLocalizations l10n,
  WidgetRef ref, {
  required int graceDays,
}) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        icon: Icon(Icons.person_remove_outlined, color: AppColors.primary),
        title: Text(l10n.driverLegalDeleteAccountTitle),
        content: Text(l10n.driverLegalDeleteAccountBody(graceDays)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await openDriverAccountDeletionInfo(context);
            },
            child: Text(l10n.driverLegalDeleteAccountAction),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (!context.mounted) return;
              await _runDriverAccountDeletionSchedule(context, l10n, ref);
            },
            child: Text(l10n.driverLegalDeleteAccountConfirmSchedule),
          ),
        ],
      );
    },
  );
}

Future<void> _runDriverAccountDeletionSchedule(
  BuildContext context,
  AppLocalizations l10n,
  WidgetRef ref,
) async {
  if (!context.mounted) return;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(width: AppFoundation.spacingMd),
          Expanded(child: Text(l10n.driverLegalDeleteAccountScheduling)),
        ],
      ),
    ),
  );

  final result = await DriverAccountDeletionService().scheduleAccountDeletion();
  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pop();

  switch (result) {
    case DriverAccountDeletionScheduled(:final message):
      await ref.read(driverLoginControllerProvider.notifier).logout();
      ref.invalidate(driverMeProfileDataProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? l10n.driverLegalDeleteAccountScheduledSuccess),
        ),
      );
      context.goNamed(AppRouter.login);
    case DriverAccountDeletionCancelled():
      break;
    case DriverAccountDeletionFailure(:final message):
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}

Future<void> _runDriverAccountDeletionCancel(
  BuildContext context,
  AppLocalizations l10n,
  WidgetRef ref,
) async {
  if (!context.mounted) return;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(width: AppFoundation.spacingMd),
          Expanded(child: Text(l10n.driverLegalDeleteAccountCancelling)),
        ],
      ),
    ),
  );

  final result = await DriverAccountDeletionService().cancelAccountDeletion();
  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pop();

  switch (result) {
    case DriverAccountDeletionCancelled(:final message):
      ref.invalidate(driverMeProfileDataProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? l10n.driverLegalDeleteAccountCancelSuccess),
        ),
      );
    case DriverAccountDeletionScheduled():
      break;
    case DriverAccountDeletionFailure(:final message):
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}

/// Sección legal requerida por Google Play (privacidad, términos, eliminación).
class DriverSettingsLegalSection extends ConsumerWidget {
  const DriverSettingsLegalSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(driverMeProfileDataProvider);

    return profileAsync.when(
      loading: () => _buildLegalCard(context, l10n, ref, null),
      error: (_, _) => _buildLegalCard(context, l10n, ref, null),
      data: (profile) {
        final deletion = DriverAccountDeletionStatus.fromJson(
          profile['account_deletion'] as Map<String, dynamic>?,
        );
        return _buildLegalCard(context, l10n, ref, deletion);
      },
    );
  }

  Widget _buildLegalCard(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
    DriverAccountDeletionStatus? deletion,
  ) {
    final graceDays = deletion?.graceDays ?? 20;
    final pending = deletion?.pending == true;
    final effectiveDate = formatDriverAccountDeletionDate(
          context,
          deletion?.deletionEffectiveAt,
        ) ??
        l10n.driverLegalDeleteAccountPendingDateFallback;
    final daysRemaining = deletion?.daysRemaining ?? graceDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppFoundation.spacingXs,
            AppFoundation.spacingLg,
            AppFoundation.spacingXs,
            AppFoundation.spacingXs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.driverLegalSectionTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppFoundation.spacingXs),
              Text(
                l10n.driverLegalSectionSubtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.85),
                      height: 1.35,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppFoundation.spacingSm),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            children: [
              _LegalRow(
                icon: Icons.privacy_tip_outlined,
                label: l10n.driverLegalPrivacyPolicy,
                onTap: () {
                  HapticFeedback.selectionClick();
                  openDriverPrivacyPolicy(context);
                },
              ),
              Divider(
                height: 1,
                indent: 52,
                color: AppColors.border.withValues(alpha: 0.28),
              ),
              _LegalRow(
                icon: Icons.description_outlined,
                label: l10n.driverLegalTermsOfService,
                onTap: () {
                  HapticFeedback.selectionClick();
                  openDriverTerms(context);
                },
              ),
              if (!pending) ...[
                Divider(
                  height: 1,
                  indent: 52,
                  color: AppColors.border.withValues(alpha: 0.28),
                ),
                _LegalRow(
                  icon: Icons.person_remove_outlined,
                  label: l10n.driverLegalDeleteAccountTitle,
                  labelColor: AppColors.error,
                  iconColor: AppColors.error.withValues(alpha: 0.9),
                  trailing: Icons.chevron_right_rounded,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    showDriverAccountDeletionDialog(
                      context,
                      l10n,
                      ref,
                      graceDays: graceDays,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        if (pending) ...[
          const SizedBox(height: AppFoundation.spacingSm),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.35),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppFoundation.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.driverLegalDeleteAccountPendingTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppFoundation.spacingSm),
                  Text(
                    l10n.driverLegalDeleteAccountPendingBody(
                      effectiveDate,
                      daysRemaining,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppFoundation.spacingMd),
                  FilledButton(
                    onPressed: () =>
                        _runDriverAccountDeletionCancel(context, l10n, ref),
                    child: Text(l10n.driverLegalDeleteAccountCancelAction),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LegalRow extends StatelessWidget {
  const _LegalRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
    this.trailing = Icons.open_in_new_rounded,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;
  final IconData trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppFoundation.spacingLg,
            vertical: AppFoundation.spacingMd + 2,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: iconColor ?? AppColors.textSecondary,
              ),
              const SizedBox(width: AppFoundation.spacingMd),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: labelColor ?? AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Icon(
                trailing,
                size: 16,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? formatDriverAccountDeletionDate(BuildContext context, String? iso) {
  if (iso == null || iso.isEmpty) return null;
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return null;
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.yMMMd(locale).format(parsed.toLocal());
}
