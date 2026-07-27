import 'package:flutter/material.dart';

import 'driver_registration_models.dart';

/// Estado de formulario del flujo de registro (controllers, imágenes, keys).
class RegistrationFlowBindings {
  final formPersonal = GlobalKey<FormState>();
  final formId = GlobalKey<FormState>();
  final formLicense = GlobalKey<FormState>();
  final formVehicle = GlobalKey<FormState>();

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneLocalCtrl = TextEditingController();
  final birthDateCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final passwordConfirmCtrl = TextEditingController();

  final docNumberCtrl = TextEditingController();
  final docExpireCtrl = TextEditingController();

  final licenseExpireCtrl = TextEditingController();

  final vehicleBrandCtrl = TextEditingController();
  final vehicleModelCtrl = TextEditingController();
  final vehicleYearCtrl = TextEditingController(text: '2020');
  final vehicleColorCtrl = TextEditingController();
  final vehicleVinCtrl = TextEditingController();
  final vehiclePlateCtrl = TextEditingController();
  final vehicleInsuranceCtrl = TextEditingController();
  final vehicleTitleCtrl = TextEditingController();

  String? genderValue;
  DriverLicenseCategory? licenseCategory;

  String? idFrontB64;
  String? idBackB64;
  String? faceB64;
  String? licFrontB64;
  String? licBackB64;
  String? carFrontB64;
  String? carBackB64;
  String? carLeftB64;
  String? carRightB64;

  final draftImagePaths = <String, String?>{};

  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    phoneLocalCtrl.dispose();
    birthDateCtrl.dispose();
    addressCtrl.dispose();
    passwordCtrl.dispose();
    passwordConfirmCtrl.dispose();
    docNumberCtrl.dispose();
    docExpireCtrl.dispose();
    licenseExpireCtrl.dispose();
    vehicleBrandCtrl.dispose();
    vehicleModelCtrl.dispose();
    vehicleYearCtrl.dispose();
    vehicleColorCtrl.dispose();
    vehicleVinCtrl.dispose();
    vehiclePlateCtrl.dispose();
    vehicleInsuranceCtrl.dispose();
    vehicleTitleCtrl.dispose();
  }

  void clearVehicleOnlyFields() {
    vehicleBrandCtrl.clear();
    vehicleModelCtrl.clear();
    vehicleYearCtrl.text = '2020';
    vehicleColorCtrl.clear();
    vehicleVinCtrl.clear();
    vehiclePlateCtrl.clear();
    vehicleInsuranceCtrl.clear();
    vehicleTitleCtrl.clear();
    carFrontB64 = null;
    carBackB64 = null;
    carLeftB64 = null;
    carRightB64 = null;
    draftImagePaths['carFront'] = null;
    draftImagePaths['carBack'] = null;
    draftImagePaths['carLeft'] = null;
    draftImagePaths['carRight'] = null;
  }
}
