import 'driver_registration_models.dart';
import 'registration_flow_bindings.dart';

bool registrationFieldIsBlank(String? value) {
  return value == null || value.trim().isEmpty;
}

void registrationSetTextIfEmpty({
  required String? value,
  required void Function(String text) assign,
  required String Function() read,
}) {
  final next = value?.trim();
  if (next == null || next.isEmpty) return;
  if (!registrationFieldIsBlank(read())) return;
  assign(next);
}

/// Normaliza fechas del backend a `YYYY-MM-DD` (mismo formato que el date picker).
String? registrationNormalizeIsoDate(String? raw) {
  final s = raw?.trim();
  if (s == null || s.isEmpty) return null;
  if (s.length >= 10 && RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(s.substring(0, 10))) {
    return s.substring(0, 10);
  }
  final parsed = DateTime.tryParse(s);
  if (parsed == null) return null;
  final utc = parsed.isUtc ? parsed : parsed.toUtc();
  final y = utc.year.toString().padLeft(4, '0');
  final m = utc.month.toString().padLeft(2, '0');
  final d = utc.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Extrae la parte local del teléfono a partir de E.164 y el código de país (sin +).
String? registrationParseLocalPhonePart({
  required String? fullPhone,
  required String? countryPhoneCode,
}) {
  final raw = fullPhone?.trim();
  if (raw == null || raw.isEmpty) return null;
  var digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;

  final code = countryPhoneCode?.replaceAll(RegExp(r'\D'), '') ?? '';
  if (code.isNotEmpty && digits.startsWith(code)) {
    digits = digits.substring(code.length);
  }
  return digits.isEmpty ? null : digits;
}

/// Rellena solo campos vacíos del formulario desde `GET /api/v2/driver/me-profile`.
void mergeMeProfileIntoRegistrationForm({
  required Map<String, dynamic> profile,
  required RegistrationFlowBindings form,
  String? countryPhoneCode,
}) {
  registrationSetTextIfEmpty(
    value: profile['first_name']?.toString(),
    read: () => form.firstNameCtrl.text,
    assign: (v) => form.firstNameCtrl.text = v,
  );
  registrationSetTextIfEmpty(
    value: profile['last_name']?.toString(),
    read: () => form.lastNameCtrl.text,
    assign: (v) => form.lastNameCtrl.text = v,
  );
  registrationSetTextIfEmpty(
    value: profile['email']?.toString(),
    read: () => form.emailCtrl.text,
    assign: (v) => form.emailCtrl.text = v,
  );
  registrationSetTextIfEmpty(
    value: profile['address']?.toString(),
    read: () => form.addressCtrl.text,
    assign: (v) => form.addressCtrl.text = v,
  );
  registrationSetTextIfEmpty(
    value: registrationNormalizeIsoDate(profile['birth_date']?.toString()),
    read: () => form.birthDateCtrl.text,
    assign: (v) => form.birthDateCtrl.text = v,
  );
  registrationSetTextIfEmpty(
    value: profile['identity_document_number']?.toString(),
    read: () => form.docNumberCtrl.text,
    assign: (v) => form.docNumberCtrl.text = v,
  );
  registrationSetTextIfEmpty(
    value: profile['license_document_number']?.toString(),
    read: () => form.docNumberCtrl.text,
    assign: (v) => form.docNumberCtrl.text = v,
  );
  registrationSetTextIfEmpty(
    value: registrationNormalizeIsoDate(profile['identity_expires_at']?.toString()),
    read: () => form.docExpireCtrl.text,
    assign: (v) => form.docExpireCtrl.text = v,
  );
  registrationSetTextIfEmpty(
    value: registrationNormalizeIsoDate(profile['license_expires_at']?.toString()),
    read: () => form.licenseExpireCtrl.text,
    assign: (v) => form.licenseExpireCtrl.text = v,
  );

  final gender = profile['gender']?.toString().trim();
  if (form.genderValue == null && gender != null && gender.isNotEmpty) {
    form.genderValue = gender;
  }

  final localPhone = registrationParseLocalPhonePart(
    fullPhone: profile['phone_number']?.toString(),
    countryPhoneCode: countryPhoneCode,
  );
  registrationSetTextIfEmpty(
    value: localPhone,
    read: () => form.phoneLocalCtrl.text,
    assign: (v) => form.phoneLocalCtrl.text = v,
  );
}

/// Rellena campos de vehículo vacíos desde `GET /api/v2/vehicles`.
void mergeVehicleSummaryIntoRegistrationForm({
  required RegistrationFlowBindings form,
  required String brand,
  required String model,
  int? year,
  String? color,
  String? vin,
  String? licensePlate,
}) {
  registrationSetTextIfEmpty(
    value: brand,
    read: () => form.vehicleBrandCtrl.text,
    assign: (v) => form.vehicleBrandCtrl.text = v,
  );
  registrationSetTextIfEmpty(
    value: model,
    read: () => form.vehicleModelCtrl.text,
    assign: (v) => form.vehicleModelCtrl.text = v,
  );
  if (year != null &&
      (registrationFieldIsBlank(form.vehicleYearCtrl.text) ||
          form.vehicleYearCtrl.text.trim() == '2020')) {
    form.vehicleYearCtrl.text = year.toString();
  }
  registrationSetTextIfEmpty(
    value: color,
    read: () => form.vehicleColorCtrl.text,
    assign: (v) => form.vehicleColorCtrl.text = v,
  );
  registrationSetTextIfEmpty(
    value: vin,
    read: () => form.vehicleVinCtrl.text,
    assign: (v) => form.vehicleVinCtrl.text = v,
  );
  registrationSetTextIfEmpty(
    value: licensePlate,
    read: () => form.vehiclePlateCtrl.text,
    assign: (v) => form.vehiclePlateCtrl.text = v,
  );
}

/// Heurística: ¿faltan datos visibles en el paso actual y conviene consultar servidor?
bool registrationFormStepNeedsServerRehydrate({
  required RegistrationFlowBindings form,
  required int step,
  bool geoMissing = false,
}) {
  switch (step.clamp(0, 5)) {
    case 0:
      return registrationFieldIsBlank(form.firstNameCtrl.text) ||
          registrationFieldIsBlank(form.emailCtrl.text) ||
          registrationFieldIsBlank(form.phoneLocalCtrl.text) ||
          geoMissing;
    case 1:
      return registrationFieldIsBlank(form.docNumberCtrl.text) ||
          registrationFieldIsBlank(form.docExpireCtrl.text) ||
          (form.idFrontB64 == null && form.idBackB64 == null && form.faceB64 == null);
    case 2:
      return registrationFieldIsBlank(form.licenseExpireCtrl.text) ||
          form.licenseCategory == null ||
          (form.licFrontB64 == null && form.licBackB64 == null);
    case 3:
      return registrationFieldIsBlank(form.passwordCtrl.text);
    case 4:
      return registrationFieldIsBlank(form.vehicleBrandCtrl.text) ||
          registrationFieldIsBlank(form.vehicleModelCtrl.text) ||
          registrationFieldIsBlank(form.vehiclePlateCtrl.text);
    case 5:
      return form.carFrontB64 == null &&
          form.carBackB64 == null &&
          form.carLeftB64 == null &&
          form.carRightB64 == null;
    default:
      return false;
  }
}

int? registrationParseLicenseDocumentTypeId(Map<String, dynamic> profile) {
  final raw = profile['license_document_type_id'] ??
      profile['license_category_document_type_id'] ??
      profile['license_document_type'];
  if (raw is int) return raw > 1 ? raw : null;
  if (raw is num) {
    final n = raw.toInt();
    return n > 1 ? n : null;
  }
  final parsed = int.tryParse(raw?.toString().trim() ?? '');
  if (parsed == null || parsed <= 1) return null;
  return parsed;
}

/// Recupera la categoría de licencia registrada (no editable desde perfil).
void applyLicenseCategoryFromProfile({
  required RegistrationFlowBindings form,
  required List<DriverLicenseCategory> categories,
  int? documentTypeId,
}) {
  if (documentTypeId == null || documentTypeId <= 1) return;
  final list = categories.isNotEmpty
      ? categories
      : DriverLicenseCategory.legacyBoliviaFallback;
  for (final item in list) {
    if (item.id == documentTypeId) {
      form.licenseCategory = item;
      return;
    }
  }
  form.licenseCategory = DriverLicenseCategory(
    id: documentTypeId,
    label: 'Cat. $documentTypeId',
  );
}

void applyRegisteredImagesToForm({
  required RegistrationFlowBindings form,
  required Map<String, dynamic> data,
}) {
  void applyDoc(Map<String, dynamic> doc) {
    final code = doc['definition_code']?.toString() ?? '';
    final imgs = doc['images'];
    if (imgs is! List) return;
    for (final raw in imgs) {
      if (raw is! Map) continue;
      final key = raw['key']?.toString() ?? '';
      final url = raw['image_url']?.toString();
      final sk = raw['storage_key']?.toString();
      if (code == 'DRIVER_IDENTITY') {
        if (key == 'front_image') {
          form.idFrontPreviewUrl ??= (url != null && url.isNotEmpty) ? url : null;
          form.idFrontStorageKey ??= (sk != null && sk.isNotEmpty) ? sk : null;
        } else if (key == 'back_image') {
          form.idBackPreviewUrl ??= (url != null && url.isNotEmpty) ? url : null;
          form.idBackStorageKey ??= (sk != null && sk.isNotEmpty) ? sk : null;
        } else if (key == 'face_image') {
          form.facePreviewUrl ??= (url != null && url.isNotEmpty) ? url : null;
          form.faceStorageKey ??= (sk != null && sk.isNotEmpty) ? sk : null;
        }
      } else if (code == 'DRIVER_LICENSE') {
        if (key == 'front_image') {
          form.licFrontPreviewUrl ??= (url != null && url.isNotEmpty) ? url : null;
          form.licFrontStorageKey ??= (sk != null && sk.isNotEmpty) ? sk : null;
        } else if (key == 'back_image') {
          form.licBackPreviewUrl ??= (url != null && url.isNotEmpty) ? url : null;
          form.licBackStorageKey ??= (sk != null && sk.isNotEmpty) ? sk : null;
        }
      }
    }
  }

  final docs = data['documents'];
  if (docs is List) {
    for (final d in docs) {
      if (d is Map) applyDoc(Map<String, dynamic>.from(d));
    }
  }

  final vehicles = data['vehicles'];
  if (vehicles is List && vehicles.isNotEmpty) {
    final first = vehicles.first;
    if (first is Map) {
      final imgs = first['images'];
      if (imgs is List) {
        for (final raw in imgs) {
          if (raw is! Map) continue;
          final key = raw['key']?.toString() ?? '';
          final url = raw['image_url']?.toString();
          final sk = raw['storage_key']?.toString();
          if (key == 'vehicle_front') {
            form.carFrontPreviewUrl ??= (url != null && url.isNotEmpty) ? url : null;
            form.carFrontStorageKey ??= (sk != null && sk.isNotEmpty) ? sk : null;
          } else if (key == 'vehicle_back') {
            form.carBackPreviewUrl ??= (url != null && url.isNotEmpty) ? url : null;
            form.carBackStorageKey ??= (sk != null && sk.isNotEmpty) ? sk : null;
          } else if (key == 'vehicle_left') {
            form.carLeftPreviewUrl ??= (url != null && url.isNotEmpty) ? url : null;
            form.carLeftStorageKey ??= (sk != null && sk.isNotEmpty) ? sk : null;
          } else if (key == 'vehicle_right') {
            form.carRightPreviewUrl ??= (url != null && url.isNotEmpty) ? url : null;
            form.carRightStorageKey ??= (sk != null && sk.isNotEmpty) ? sk : null;
          }
        }
      }
    }
  }
}
