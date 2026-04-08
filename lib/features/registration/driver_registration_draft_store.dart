import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DriverRegistrationDraft {
  const DriverRegistrationDraft({
    required this.step,
    this.userUuid,
    this.carUuid,
    this.selectedCountryName,
    this.selectedCountryPhoneCode,
    this.selectedDepartmentName,
    this.selectedLocalityId,
    this.selectedLocalityLabel,
    this.selectedCountryId,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneLocal,
    this.birthDateIso,
    this.address,
    this.genderValue,
    this.documentNumber,
    this.documentExpireIso,
    this.licenseExpireIso,
    this.licenseCategoryId,
    this.idFrontPath,
    this.idBackPath,
    this.facePath,
    this.licenseFrontPath,
    this.licenseBackPath,
    this.vehicleBrand,
    this.vehicleModel,
    this.vehicleYear,
    this.vehicleColor,
    this.vehicleVin,
    this.vehiclePlate,
    this.vehicleInsurance,
    this.vehicleTitle,
    this.carFrontPath,
    this.carBackPath,
    this.carLeftPath,
    this.carRightPath,
    // Compat legado: drafts anteriores guardaban base64 directo.
    this.idFrontB64,
    this.idBackB64,
    this.faceB64,
    this.licenseFrontB64,
    this.licenseBackB64,
    this.carFrontB64,
    this.carBackB64,
    this.carLeftB64,
    this.carRightB64,
  });

  final int step;
  final String? userUuid;
  final String? carUuid;
  final String? selectedCountryName;
  final String? selectedCountryPhoneCode;
  final String? selectedDepartmentName;
  final int? selectedLocalityId;
  final String? selectedLocalityLabel;
  final int? selectedCountryId;

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneLocal;
  final String? birthDateIso;
  final String? address;
  final String? genderValue;

  final String? documentNumber;
  final String? documentExpireIso;
  final String? licenseExpireIso;
  final int? licenseCategoryId;

  final String? idFrontPath;
  final String? idBackPath;
  final String? facePath;
  final String? licenseFrontPath;
  final String? licenseBackPath;

  final String? vehicleBrand;
  final String? vehicleModel;
  final String? vehicleYear;
  final String? vehicleColor;
  final String? vehicleVin;
  final String? vehiclePlate;
  final String? vehicleInsurance;
  final String? vehicleTitle;

  final String? carFrontPath;
  final String? carBackPath;
  final String? carLeftPath;
  final String? carRightPath;

  // Compat drafts viejos.
  final String? idFrontB64;
  final String? idBackB64;
  final String? faceB64;
  final String? licenseFrontB64;
  final String? licenseBackB64;
  final String? carFrontB64;
  final String? carBackB64;
  final String? carLeftB64;
  final String? carRightB64;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'step': step,
      'userUuid': userUuid,
      'carUuid': carUuid,
      'selectedCountryName': selectedCountryName,
      'selectedCountryPhoneCode': selectedCountryPhoneCode,
      'selectedDepartmentName': selectedDepartmentName,
      'selectedLocalityId': selectedLocalityId,
      'selectedLocalityLabel': selectedLocalityLabel,
      'selectedCountryId': selectedCountryId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneLocal': phoneLocal,
      'birthDateIso': birthDateIso,
      'address': address,
      'genderValue': genderValue,
      'documentNumber': documentNumber,
      'documentExpireIso': documentExpireIso,
      'licenseExpireIso': licenseExpireIso,
      'licenseCategoryId': licenseCategoryId,
      'idFrontPath': idFrontPath,
      'idBackPath': idBackPath,
      'facePath': facePath,
      'licenseFrontPath': licenseFrontPath,
      'licenseBackPath': licenseBackPath,
      'vehicleBrand': vehicleBrand,
      'vehicleModel': vehicleModel,
      'vehicleYear': vehicleYear,
      'vehicleColor': vehicleColor,
      'vehicleVin': vehicleVin,
      'vehiclePlate': vehiclePlate,
      'vehicleInsurance': vehicleInsurance,
      'vehicleTitle': vehicleTitle,
      'carFrontPath': carFrontPath,
      'carBackPath': carBackPath,
      'carLeftPath': carLeftPath,
      'carRightPath': carRightPath,
      'savedAt': DateTime.now().toIso8601String(),
    };
  }

  static DriverRegistrationDraft? fromJson(Map<String, dynamic> json) {
    final rawStep = json['step'];
    int step = 0;
    if (rawStep is int) {
      step = rawStep;
    } else if (rawStep is num) {
      step = rawStep.toInt();
    } else if (rawStep != null) {
      step = int.tryParse(rawStep.toString()) ?? 0;
    }
    int? intOrNull(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v == null) return null;
      return int.tryParse(v.toString());
    }

    return DriverRegistrationDraft(
      step: step.clamp(0, 5),
      userUuid: json['userUuid']?.toString(),
      carUuid: json['carUuid']?.toString(),
      selectedCountryName: json['selectedCountryName']?.toString(),
      selectedCountryPhoneCode: json['selectedCountryPhoneCode']?.toString(),
      selectedDepartmentName: json['selectedDepartmentName']?.toString(),
      selectedLocalityId: intOrNull(json['selectedLocalityId']),
      selectedLocalityLabel: json['selectedLocalityLabel']?.toString(),
      selectedCountryId: intOrNull(json['selectedCountryId']),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString(),
      phoneLocal: json['phoneLocal']?.toString(),
      birthDateIso: json['birthDateIso']?.toString(),
      address: json['address']?.toString(),
      genderValue: json['genderValue']?.toString(),
      documentNumber: json['documentNumber']?.toString(),
      documentExpireIso: json['documentExpireIso']?.toString(),
      licenseExpireIso: json['licenseExpireIso']?.toString(),
      licenseCategoryId: intOrNull(json['licenseCategoryId']),
      idFrontB64: json['idFrontB64']?.toString(),
      idBackB64: json['idBackB64']?.toString(),
      faceB64: json['faceB64']?.toString(),
      licenseFrontB64: json['licenseFrontB64']?.toString(),
      licenseBackB64: json['licenseBackB64']?.toString(),
      idFrontPath: json['idFrontPath']?.toString(),
      idBackPath: json['idBackPath']?.toString(),
      facePath: json['facePath']?.toString(),
      licenseFrontPath: json['licenseFrontPath']?.toString(),
      licenseBackPath: json['licenseBackPath']?.toString(),
      vehicleBrand: json['vehicleBrand']?.toString(),
      vehicleModel: json['vehicleModel']?.toString(),
      vehicleYear: json['vehicleYear']?.toString(),
      vehicleColor: json['vehicleColor']?.toString(),
      vehicleVin: json['vehicleVin']?.toString(),
      vehiclePlate: json['vehiclePlate']?.toString(),
      vehicleInsurance: json['vehicleInsurance']?.toString(),
      vehicleTitle: json['vehicleTitle']?.toString(),
      carFrontB64: json['carFrontB64']?.toString(),
      carBackB64: json['carBackB64']?.toString(),
      carLeftB64: json['carLeftB64']?.toString(),
      carRightB64: json['carRightB64']?.toString(),
      carFrontPath: json['carFrontPath']?.toString(),
      carBackPath: json['carBackPath']?.toString(),
      carLeftPath: json['carLeftPath']?.toString(),
      carRightPath: json['carRightPath']?.toString(),
    );
  }
}

class DriverRegistrationDraftStore {
  DriverRegistrationDraftStore._();

  static const _storage = FlutterSecureStorage();
  static const _key = 'driver_registration_flow_draft_v1';

  static Future<void> save(DriverRegistrationDraft draft) async {
    final raw = jsonEncode(draft.toJson());
    await _storage.write(key: _key, value: raw);
  }

  static Future<DriverRegistrationDraft?> load() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    return DriverRegistrationDraft.fromJson(decoded);
  }

  static Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}
