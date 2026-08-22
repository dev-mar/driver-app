import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/session/driver_registration_resume_gate.dart';
import '../../gen_l10n/app_localizations.dart';
import 'driver_registration_controller.dart';
import 'driver_registration_draft_store.dart';
import 'driver_registration_models.dart';
import 'registration_flow_bindings.dart';
import 'registration_flow_draft_service.dart';
import 'registration_flow_mode.dart';
import 'registration_flow_step_metadata.dart';

Future<void> _restoreLocalDraftIfPresent({
  required RegistrationFlowMode mode,
  required RegistrationFlowBindings form,
  required RegistrationFlowDraftService draftService,
  required DriverRegistrationFlowController notifier,
  required void Function(VoidCallback fn) setState,
  required bool Function() isMounted,
}) async {
  if (mode.galleryCompletionOnly || mode.addVehicleOnly) return;

  DriverRegistrationDraft? draft;
  try {
    draft = await DriverRegistrationDraftStore.load();
  } catch (_) {
    return;
  }
  if (draft == null || !isMounted()) return;

  await draftService.restoreIntoForm(draft, notifier);
  if (draft.licenseCategoryId != null) {
    for (final item in DriverLicenseCategory.legacyBoliviaFallback) {
      if (item.id == draft.licenseCategoryId) {
        form.licenseCategory = item;
        break;
      }
    }
  }
  setState(() {});
}

Future<void> bootstrapRegistrationFlow({
  required BuildContext context,
  required WidgetRef ref,
  required RegistrationFlowMode mode,
  required RegistrationFlowBindings form,
  required RegistrationFlowDraftService draftService,
  required void Function(VoidCallback fn) setState,
  required bool Function() isMounted,
}) async {
  final notifier = ref.read(driverRegistrationFlowControllerProvider.notifier);

  await _restoreLocalDraftIfPresent(
    mode: mode,
    form: form,
    draftService: draftService,
    notifier: notifier,
    setState: setState,
    isMounted: isMounted,
  );
  if (!isMounted() || !context.mounted) return;

  if (mode.openFromProfileStep != null) {
    final ok = await notifier.openProfileRegistrationStep(
      mode.openFromProfileStep!,
      preselectedCountryId: mode.profilePreselectedCountryId,
    );
    if (!context.mounted) return;
    if (ok) {
      final flowAfter = ref.read(driverRegistrationFlowControllerProvider);
      final redirectFrom = flowAfter.profileRedirectFromStep;
      final redirectTo = flowAfter.profileRedirectToStep;
      if (redirectFrom != null &&
          redirectTo != null &&
          redirectFrom != redirectTo) {
        final l10nRedirect = AppLocalizations.of(context);
        final labels = registrationFlowStepLabels(l10nRedirect);
        final maxI = labels.length - 1;
        final fromLabel = labels[redirectFrom.clamp(0, maxI)];
        final toLabel = labels[redirectTo.clamp(0, maxI)];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10nRedirect.driverRegProfileRedirectSnackbar(
                fromLabel,
                toLabel,
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        notifier.clearProfileRedirectNotice();
      }
      await notifier.rehydrateFromServerIfNeeded(
        form,
        step: ref.read(driverRegistrationFlowControllerProvider).step,
        force: true,
      );
      await draftService.persist();
    }
    if (!isMounted() || !context.mounted) return;
    setState(() {});
  } else if (mode.galleryCompletionOnly) {
    form.clearVehicleOnlyFields();
    notifier.resetFlow();
    await notifier.applyCompleteVehicleGalleryFromSession(
      mode.completeVehicleGalleryForAssetId!.trim(),
    );
    if (!context.mounted) return;
  } else if (mode.addVehicleOnly) {
    form.clearVehicleOnlyFields();
    notifier.resetFlow();
    await notifier.applyAddVehicleOnlyFromSession();
    if (!context.mounted) return;
  } else if (mode.resumeAfterLogin) {
    final done = await notifier.applyResumeFromApi();
    if (!context.mounted) return;
    if (done) {
      DriverRegistrationResumeGate.invalidate();
      context.goNamed(AppRouter.home);
      return;
    }
    await notifier.rehydrateFromServerIfNeeded(
      form,
      step: ref.read(driverRegistrationFlowControllerProvider).step,
      force: true,
    );
    await draftService.persist();
    if (!isMounted() || !context.mounted) return;
    setState(() {});
  } else {
    notifier.loadCountries();
  }

  unawaited(draftService.persist());
}
