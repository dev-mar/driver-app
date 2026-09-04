import '../../gen_l10n/app_localizations.dart';
import 'driver_registration_controller.dart';
import 'registration_flow_mode.dart';

List<String> registrationFlowStepLabels(AppLocalizations l10n) => [
      l10n.driverRegStepData,
      l10n.driverRegStepIdentity,
      l10n.driverRegStepLicense,
      l10n.driverRegStepAccess,
      l10n.driverRegStepVehicle,
      l10n.driverRegStepPhotos,
    ];

List<String> registrationFlowVisibleStepLabels(
  AppLocalizations l10n,
  RegistrationFlowMode mode,
) {
  if (mode.galleryCompletionOnly) {
    return [l10n.driverRegStepPhotos];
  }
  if (mode.addVehicleOnly) {
    return [l10n.driverRegStepVehicle, l10n.driverRegStepPhotos];
  }
  if (mode.profileCompletionUx) {
    return registrationFlowStepLabels(l10n);
  }
  return [
    l10n.driverRegStepData,
    l10n.driverRegStepLicense,
    l10n.driverRegStepAccess,
  ];
}

int registrationFlowVisibleStepIndex(
  DriverRegistrationFlowState flow,
  RegistrationFlowMode mode,
) {
  if (mode.galleryCompletionOnly) return 0;
  if (mode.addVehicleOnly) return (flow.step - 4).clamp(0, 1);
  if (mode.profileCompletionUx) return flow.step.clamp(0, 5);
  if (flow.step <= 0) return 0;
  if (flow.step <= 2) return 1;
  return 2;
}

String registrationFlowScaffoldTitle(
  AppLocalizations l10n,
  RegistrationFlowMode mode,
) {
  if (mode.galleryCompletionOnly) {
    return l10n.driverMyVehiclesCompletePhotosTitle;
  }
  if (mode.addVehicleOnly) {
    return l10n.driverRegAddVehicleTitle;
  }
  if (mode.profileCompletionUx) {
    return l10n.driverRegTitleProfileCompletion;
  }
  return l10n.driverRegTitle;
}
