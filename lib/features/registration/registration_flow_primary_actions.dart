import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/session/driver_registration_resume_gate.dart';
import '../../core/theme/app_colors.dart';
import '../../gen_l10n/app_localizations.dart';
import '../login/driver_login_controller.dart';
import '../login/driver_realtime_controller.dart';
import '../session/driver_operational_profile.dart';
import 'driver_registration_controller.dart';
import 'driver_registration_draft_media_store.dart';
import 'driver_registration_draft_store.dart';
import 'registration_flow_bindings.dart';
import 'registration_flow_completion.dart';
import 'registration_flow_draft_service.dart';
import 'registration_flow_helpers.dart';
import 'registration_flow_mode.dart';
import 'registration_passenger_upgrade_otp_dialog.dart';

typedef RegistrationInvalidStepValidation = void Function();

Future<void> handleRegistrationPrimaryAction({
  required BuildContext context,
  required WidgetRef ref,
  required AppLocalizations l10n,
  required RegistrationFlowMode mode,
  required RegistrationFlowBindings form,
  required RegistrationFlowDraftService draftService,
  required RegistrationInvalidStepValidation onInvalidStepValidation,
  required bool Function() isMounted,
}) async {
  final flow = ref.read(driverRegistrationFlowControllerProvider);
  final notifier = ref.read(driverRegistrationFlowControllerProvider.notifier);
  if (flow.loading) return;
  notifier.clearError();

  if (mode.profilePhotosLocked) {
    if (context.mounted) {
      dismissRegistrationToProfile(context: context, ref: ref, l10n: l10n);
    }
    return;
  }
  if (mode.profileCompletionUx &&
      mode.profileFieldsReadOnly &&
      flow.step == 0) {
    if (context.mounted) {
      dismissRegistrationToProfile(context: context, ref: ref, l10n: l10n);
    }
    return;
  }

  Future<void> persistDraft() => draftService.persist();

  switch (flow.step) {
    case 0:
      if (!form.formPersonal.currentState!.validate()) {
        onInvalidStepValidation();
        if (registrationBirthDateIsUnderMinAge(form.birthDateCtrl.text) &&
            context.mounted) {
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              icon: Icon(
                Icons.cake_outlined,
                color: Theme.of(ctx).colorScheme.primary,
              ),
              title: Text(l10n.driverRegAgeRequirementDialogTitle),
              content: Text(l10n.driverRegAgeRequirementDialogBody),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l10n.driverLoginAccountDeletionDismiss),
                ),
              ],
            ),
          );
        }
        return;
      }
      if (!flow.isBoliviaSelected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.driverRegSnackSelectCountryCoverage),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      if (!isValidBoliviaLocalMobile(form.phoneLocalCtrl.text)) {
        onInvalidStepValidation();
        return;
      }
      if (flow.selectedLocalityId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.driverRegSnackSelectDepartmentLocality),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      if (form.passwordCtrl.text != form.passwordConfirmCtrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.driverRegSnackPasswordsMismatch),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      await notifier.submitPersonalInfo(
        firstName: form.firstNameCtrl.text.trim(),
        lastName: form.lastNameCtrl.text.trim(),
        email: form.emailCtrl.text.trim(),
        birthDateIso: form.birthDateCtrl.text.trim(),
        phoneNumber: composeRegistrationFullPhone(form, flow),
        localityId: flow.selectedLocalityId!,
        address: form.addressCtrl.text.trim(),
        genderApiValue: form.genderValue ?? 'Other',
        password: form.passwordCtrl.text,
        referralCode: form.referralCodeCtrl.text.trim(),
      );
      if (!context.mounted) return;
      var stUpgrade = ref.read(driverRegistrationFlowControllerProvider);
      if (stUpgrade.passengerUpgradeOtpRequired) {
        final phone = composeRegistrationFullPhone(form, flow);
        final challenge = await notifier.requestPassengerUpgradeOtp(phone);
        if (!context.mounted) return;
        if (challenge == null) return;
        if (challenge.isWhatsAppInbound) {
          final inbound = await showPassengerUpgradeWhatsAppInboundDialog(
            context: context,
            l10n: l10n,
            waDeepLink: challenge.waDeepLink,
            pollStatus: () => notifier.pollPassengerUpgradeChallenge(
              phoneE164: phone,
              challengeId: challenge.challengeId!,
            ),
          );
          if (!context.mounted) return;
          if (inbound != PassengerUpgradeInboundResult.verified) {
            notifier.clearPassengerUpgradePrompt();
            if (inbound == PassengerUpgradeInboundResult.expired) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.driverRegPassengerUpgradeExpired),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            return;
          }
          await notifier.submitPersonalInfo(
            firstName: form.firstNameCtrl.text.trim(),
            lastName: form.lastNameCtrl.text.trim(),
            email: form.emailCtrl.text.trim(),
            birthDateIso: form.birthDateCtrl.text.trim(),
            phoneNumber: phone,
            localityId: flow.selectedLocalityId!,
            address: form.addressCtrl.text.trim(),
            genderApiValue: form.genderValue ?? 'Other',
            password: form.passwordCtrl.text,
            referralCode: form.referralCodeCtrl.text.trim(),
          );
        } else {
          final code = await showPassengerUpgradeOtpDialog(
            context: context,
            l10n: l10n,
          );
          if (!context.mounted) return;
          if (code == null || code.trim().isEmpty) {
            notifier.clearPassengerUpgradePrompt();
            return;
          }
          await notifier.submitPersonalInfo(
            firstName: form.firstNameCtrl.text.trim(),
            lastName: form.lastNameCtrl.text.trim(),
            email: form.emailCtrl.text.trim(),
            birthDateIso: form.birthDateCtrl.text.trim(),
            phoneNumber: phone,
            localityId: flow.selectedLocalityId!,
            address: form.addressCtrl.text.trim(),
            genderApiValue: form.genderValue ?? 'Other',
            password: form.passwordCtrl.text,
            referralCode: form.referralCodeCtrl.text.trim(),
            upgradeVerificationCode: code.trim(),
          );
        }
      }
      unawaited(persistDraft());
      if (!context.mounted) return;
      final st0 = ref.read(driverRegistrationFlowControllerProvider);
      if (st0.globalError == null && mode.profileCompletionUx) {
        dismissRegistrationToProfile(context: context, ref: ref, l10n: l10n);
      }
      return;
    case 1:
    case 2:
      if (mode.profileCompletionUx && mode.profileFieldsReadOnly) {
        final hasNew = form.idFrontB64 != null ||
            form.idBackB64 != null ||
            form.faceB64 != null;
        if (!hasNew) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.driverRegSnackChangeAtLeastOnePhoto),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      } else if (!form.formId.currentState!.validate()) {
        onInvalidStepValidation();
        return;
      }
      final licenseTypeId = form.licenseCategory?.id ??
          flow.registeredLicenseDocumentTypeId;
      if ((form.idFrontB64 == null &&
              (form.idFrontStorageKey == null || form.idFrontStorageKey!.isEmpty)) ||
          (form.idBackB64 == null &&
              (form.idBackStorageKey == null || form.idBackStorageKey!.isEmpty)) ||
          (form.faceB64 == null &&
              (form.faceStorageKey == null || form.faceStorageKey!.isEmpty)) ||
          form.docExpireCtrl.text.isEmpty ||
          licenseTypeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.driverRegSnackIdentityIncomplete),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      final uuidDocs = flow.userUuid;
      if (uuidDocs == null) return;
      form.licenseExpireCtrl.text = form.docExpireCtrl.text.trim();
      await notifier.submitCombinedIdentityAndLicenseDocuments(
        uuid: uuidDocs,
        documentNumber: form.docNumberCtrl.text.trim(),
        licenseCategoryTypeId: licenseTypeId,
        frontB64: form.idFrontB64,
        backB64: form.idBackB64,
        faceB64: form.faceB64,
        frontStorageKey: form.idFrontStorageKey,
        backStorageKey: form.idBackStorageKey,
        faceStorageKey: form.faceStorageKey,
        licenseFrontStorageKey: form.licFrontStorageKey,
        licenseBackStorageKey: form.licBackStorageKey,
        expireDateIso: form.docExpireCtrl.text.trim(),
      );
      unawaited(persistDraft());
      if (!context.mounted) return;
      final stDocs = ref.read(driverRegistrationFlowControllerProvider);
      if (stDocs.globalError == null && mode.profileCompletionUx) {
        dismissRegistrationToProfile(context: context, ref: ref, l10n: l10n);
      }
      return;
    case 3:
      await notifier.completeLoginAndContinue(
        fullPhone: composeRegistrationFullPhone(form, flow),
        password: form.passwordCtrl.text,
      );
      if (!context.mounted) return;
      final st3 = ref.read(driverRegistrationFlowControllerProvider);
      if (st3.globalError == null && mode.profileCompletionUx) {
        unawaited(persistDraft());
        dismissRegistrationToProfile(context: context, ref: ref, l10n: l10n);
        return;
      }
      if (st3.globalError == null &&
          !mode.addVehicleOnly &&
          !mode.galleryCompletionOnly) {
        unawaited(DriverRegistrationDraftStore.clear());
        unawaited(DriverRegistrationDraftMediaStore.clearAll());
        await showRegistrationOnboardingActivationComplete(
          context: context,
          ref: ref,
          l10n: l10n,
        );
        return;
      }
      unawaited(persistDraft());
      return;
    case 4:
      if (mode.profileCompletionUx && flow.carUuid != null) {
        final hasNew = form.carFrontB64 != null ||
            form.carBackB64 != null ||
            form.carLeftB64 != null ||
            form.carRightB64 != null;
        if (!hasNew) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.driverRegSnackChangeAtLeastOnePhoto),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        await notifier.submitVehicleImagesChanged(
          carId: flow.carUuid!,
          frontB64: form.carFrontB64,
          backB64: form.carBackB64,
          leftB64: form.carLeftB64,
          rightB64: form.carRightB64,
        );
        unawaited(persistDraft());
        if (!context.mounted) return;
        final stV = ref.read(driverRegistrationFlowControllerProvider);
        if (stV.globalError == null) {
          dismissRegistrationToProfile(context: context, ref: ref, l10n: l10n);
        }
        return;
      }
      if (!form.formVehicle.currentState!.validate()) {
        onInvalidStepValidation();
        return;
      }
      if (useIntegratedCatalogVehicleFields(flow) &&
          (flow.catalogVehicleModelId == null ||
              form.vehicleBrandCtrl.text.trim().isEmpty ||
              form.vehicleModelCtrl.text.trim().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.driverRegSnackSelectCatalogBrandModel),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      if (flow.vehicleCatalogLoading ||
          flow.vehicleCatalogError != null ||
          flow.vehicleCatalog == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.driverRegSnackVehicleCatalogNotReady),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      final yearText = form.vehicleYearCtrl.text.trim();
      if (!isValidVehicleModelYearText(yearText)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.driverRegSnackVehicleYearInvalid),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      final y = int.parse(yearText);
      final cat = flow.vehicleCatalog;
      var needsCustom = false;
      if (cat != null) {
        for (final m in cat.manufacturers) {
          if (m.id == flow.catalogManufacturerId && m.isCatchAll) {
            needsCustom = true;
            break;
          }
        }
        if (!needsCustom) {
          for (final e in cat.vehicleModels) {
            if (e.id == flow.catalogVehicleModelId && e.isCatchAll) {
              needsCustom = true;
              break;
            }
          }
        }
      }
      if (needsCustom && flow.catalogCustomProposal == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.driverRegSnackCatalogCustomRequired),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      await notifier.submitVehicle(
        brand: form.vehicleBrandCtrl.text.trim(),
        model: form.vehicleModelCtrl.text.trim(),
        year: y,
        color: form.vehicleColorCtrl.text.trim(),
        licensePlate: form.vehiclePlateCtrl.text.trim().toUpperCase(),
        vin: form.vehicleVinCtrl.text.trim().toUpperCase(),
      );
      unawaited(persistDraft());
      return;
    case 5:
      if (mode.profileCompletionUx) {
        final hasNew = form.carFrontB64 != null ||
            form.carBackB64 != null ||
            form.carLeftB64 != null ||
            form.carRightB64 != null;
        if (!hasNew) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.driverRegSnackChangeAtLeastOnePhoto),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        final carIdProfile = flow.carUuid;
        if (carIdProfile == null) return;
        await notifier.submitVehicleImagesChanged(
          carId: carIdProfile,
          frontB64: form.carFrontB64,
          backB64: form.carBackB64,
          leftB64: form.carLeftB64,
          rightB64: form.carRightB64,
        );
        unawaited(persistDraft());
        if (!context.mounted) return;
        final stP = ref.read(driverRegistrationFlowControllerProvider);
        if (stP.globalError != null) return;
        HapticFeedback.mediumImpact();
        unawaited(DriverRegistrationDraftStore.clear());
        unawaited(DriverRegistrationDraftMediaStore.clearAll());
        dismissRegistrationToProfile(context: context, ref: ref, l10n: l10n);
        return;
      }
      if (form.carFrontB64 == null ||
          form.carBackB64 == null ||
          form.carLeftB64 == null ||
          form.carRightB64 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.driverRegSnackVehiclePhotosIncomplete),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      final carId = flow.carUuid;
      if (carId == null) return;
      await notifier.submitVehicleImages(
        carId: carId,
        frontB64: form.carFrontB64!,
        backB64: form.carBackB64!,
        leftB64: form.carLeftB64!,
        rightB64: form.carRightB64!,
      );
      unawaited(persistDraft());
      if (!context.mounted) return;
      final st = ref.read(driverRegistrationFlowControllerProvider);
      if (st.globalError != null) return;
      HapticFeedback.mediumImpact();
      if (mode.profileCompletionUx) {
        unawaited(DriverRegistrationDraftStore.clear());
        unawaited(DriverRegistrationDraftMediaStore.clearAll());
        dismissRegistrationToProfile(context: context, ref: ref, l10n: l10n);
        return;
      }
      if (mode.galleryCompletionOnly) {
        unawaited(DriverRegistrationDraftStore.clear());
        unawaited(DriverRegistrationDraftMediaStore.clearAll());
        ref.invalidate(driverOperationalProfileProvider);
        DriverRegistrationResumeGate.invalidate();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.driverMyVehiclesPhotosSavedSnackbar),
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed(AppRouter.home);
        }
      } else if (mode.resumeAfterLogin || mode.addVehicleOnly) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surfaceCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              mode.addVehicleOnly
                  ? l10n.driverRegAddVehicleDoneTitle
                  : l10n.driverRegResumeDoneTitle,
            ),
            content: Text(
              mode.addVehicleOnly
                  ? l10n.driverRegAddVehicleDoneBody
                  : l10n.driverRegResumeDoneBody,
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  unawaited(DriverRegistrationDraftStore.clear());
                  unawaited(DriverRegistrationDraftMediaStore.clearAll());
                  ref.invalidate(driverOperationalProfileProvider);
                  DriverRegistrationResumeGate.invalidate();
                  if (context.mounted) context.goNamed(AppRouter.home);
                },
                child: Text(
                  mode.addVehicleOnly
                      ? l10n.driverRegAddVehicleDoneCta
                      : l10n.driverRegResumeDoneCta,
                ),
              ),
            ],
          ),
        );
      } else {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surfaceCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(l10n.driverRegDoneTitle),
            content: Text(l10n.driverRegDoneBody),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  unawaited(DriverRegistrationDraftStore.clear());
                  unawaited(DriverRegistrationDraftMediaStore.clearAll());
                  unawaited(() async {
                    await ref
                        .read(driverRealtimeProvider.notifier)
                        .setOnline(false, forceOffline: true);
                    if (!context.mounted) return;
                    ref.invalidate(driverRealtimeProvider);
                    await ref.read(driverLoginControllerProvider.notifier).logout();
                    if (!context.mounted) return;
                    context.goNamed(AppRouter.login);
                  }());
                },
                child: Text(l10n.driverRegDoneGoLogin),
              ),
            ],
          ),
        );
      }
      return;
  }
}
