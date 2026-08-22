import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/session/driver_registration_resume_gate.dart';
import '../../core/theme/app_colors.dart';
import '../../gen_l10n/app_localizations.dart';
import '../session/driver_operational_profile.dart';

void dismissRegistrationToProfile({
  required BuildContext context,
  required WidgetRef ref,
  required AppLocalizations l10n,
}) {
  ref.invalidate(driverOperationalProfileProvider);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(l10n.driverRegProfileStepSaved),
      behavior: SnackBarBehavior.floating,
    ),
  );
  if (context.canPop()) {
    context.pop();
  } else {
    context.goNamed(AppRouter.profile);
  }
}

Future<void> showRegistrationOnboardingActivationComplete({
  required BuildContext context,
  required WidgetRef ref,
  required AppLocalizations l10n,
}) async {
  ref.invalidate(driverOperationalProfileProvider);
  DriverRegistrationResumeGate.invalidate();
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(l10n.driverRegOnboardingDoneTitle),
      content: Text(
        l10n.driverRegOnboardingDoneBody,
        style: const TextStyle(
          color: AppColors.textSecondary,
          height: 1.4,
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            if (context.mounted) context.goNamed(AppRouter.home);
          },
          child: Text(l10n.driverRegOnboardingDoneCta),
        ),
      ],
    ),
  );
}
