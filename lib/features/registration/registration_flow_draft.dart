import 'driver_registration_controller.dart';
import 'registration_flow_bindings.dart';

/// Snapshot inmutable para persistir borrador tras `await` sin depender del widget.
class RegistrationDraftPersistSnapshot {
  const RegistrationDraftPersistSnapshot({
    required this.flow,
    required this.paths,
    this.idFrontB64,
    this.idBackB64,
    this.faceB64,
    this.licFrontB64,
    this.licBackB64,
    this.carFrontB64,
    this.carBackB64,
    this.carLeftB64,
    this.carRightB64,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneLocal,
    required this.birthDateIso,
    required this.address,
    this.genderValue,
    required this.documentNumber,
    required this.documentExpireIso,
    required this.licenseExpireIso,
    this.licenseCategoryId,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.vehicleColor,
    required this.vehicleVin,
    required this.vehiclePlate,
    required this.vehicleInsurance,
    required this.vehicleTitle,
  });

  final DriverRegistrationFlowState flow;
  final Map<String, String?> paths;
  final String? idFrontB64;
  final String? idBackB64;
  final String? faceB64;
  final String? licFrontB64;
  final String? licBackB64;
  final String? carFrontB64;
  final String? carBackB64;
  final String? carLeftB64;
  final String? carRightB64;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneLocal;
  final String birthDateIso;
  final String address;
  final String? genderValue;
  final String documentNumber;
  final String documentExpireIso;
  final String licenseExpireIso;
  final int? licenseCategoryId;
  final String vehicleBrand;
  final String vehicleModel;
  final String vehicleYear;
  final String vehicleColor;
  final String vehicleVin;
  final String vehiclePlate;
  final String vehicleInsurance;
  final String vehicleTitle;
}

RegistrationDraftPersistSnapshot captureRegistrationDraftSnapshot({
  required DriverRegistrationFlowState flow,
  required RegistrationFlowBindings form,
}) {
  return RegistrationDraftPersistSnapshot(
    flow: flow,
    paths: Map<String, String?>.from(form.draftImagePaths),
    idFrontB64: form.idFrontB64,
    idBackB64: form.idBackB64,
    faceB64: form.faceB64,
    licFrontB64: form.licFrontB64,
    licBackB64: form.licBackB64,
    carFrontB64: form.carFrontB64,
    carBackB64: form.carBackB64,
    carLeftB64: form.carLeftB64,
    carRightB64: form.carRightB64,
    firstName: form.firstNameCtrl.text.trim(),
    lastName: form.lastNameCtrl.text.trim(),
    email: form.emailCtrl.text.trim(),
    phoneLocal: form.phoneLocalCtrl.text.trim(),
    birthDateIso: form.birthDateCtrl.text.trim(),
    address: form.addressCtrl.text.trim(),
    genderValue: form.genderValue,
    documentNumber: form.docNumberCtrl.text.trim(),
    documentExpireIso: form.docExpireCtrl.text.trim(),
    licenseExpireIso: form.licenseExpireCtrl.text.trim(),
    licenseCategoryId: form.licenseCategory?.id,
    vehicleBrand: form.vehicleBrandCtrl.text.trim(),
    vehicleModel: form.vehicleModelCtrl.text.trim(),
    vehicleYear: form.vehicleYearCtrl.text.trim(),
    vehicleColor: form.vehicleColorCtrl.text.trim(),
    vehicleVin: form.vehicleVinCtrl.text.trim(),
    vehiclePlate: form.vehiclePlateCtrl.text.trim(),
    vehicleInsurance: form.vehicleInsuranceCtrl.text.trim(),
    vehicleTitle: form.vehicleTitleCtrl.text.trim(),
  );
}
