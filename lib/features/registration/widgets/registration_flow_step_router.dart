import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../driver_registration_controller.dart';
import '../registration_flow_bindings.dart';
import '../registration_step_actions.dart';
import 'steps/registration_step_access.dart';
import 'steps/registration_step_identity.dart';
import 'steps/registration_step_license.dart';
import 'steps/registration_step_personal.dart';
import 'steps/registration_step_vehicle.dart';
import 'steps/registration_step_vehicle_photos.dart';

/// Enruta el paso activo del flujo de registro al widget correspondiente.
class RegistrationFlowStepRouter extends ConsumerWidget {
  const RegistrationFlowStepRouter({
    super.key,
    required this.flow,
    required this.notifier,
    required this.bindings,
    required this.actions,
    required this.showValidationErrors,
    required this.showTechnicalCatalogs,
  });

  final DriverRegistrationFlowState flow;
  final DriverRegistrationFlowController notifier;
  final RegistrationFlowBindings bindings;
  final RegistrationStepActions actions;
  final bool showValidationErrors;
  final bool showTechnicalCatalogs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (flow.step) {
      case 0:
        return RegistrationStepPersonal(
          bindings: bindings,
          actions: actions,
          showValidationErrors: showValidationErrors,
          flow: flow,
          notifier: notifier,
        );
      case 1:
        return RegistrationStepIdentity(
          bindings: bindings,
          actions: actions,
          showValidationErrors: showValidationErrors,
        );
      case 2:
        return RegistrationStepLicense(
          bindings: bindings,
          actions: actions,
          showValidationErrors: showValidationErrors,
          flow: flow,
        );
      case 3:
        return RegistrationStepAccess(
          bindings: bindings,
          actions: actions,
          showValidationErrors: showValidationErrors,
          flow: flow,
        );
      case 4:
        return RegistrationStepVehicle(
          bindings: bindings,
          actions: actions,
          showValidationErrors: showValidationErrors,
          flow: flow,
          notifier: notifier,
          showTechnicalCatalogs: showTechnicalCatalogs,
        );
      case 5:
        return RegistrationStepVehiclePhotos(
          bindings: bindings,
          actions: actions,
          showValidationErrors: showValidationErrors,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
