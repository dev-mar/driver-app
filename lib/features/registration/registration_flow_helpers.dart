import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../gen_l10n/app_localizations.dart';
import 'driver_registration_controller.dart';
import 'registration_flow_bindings.dart';

/// Código de discado de Bolivia (sin `+`).
const String kBoliviaDialDigits = '591';

/// Largo del número local boliviano (sin código de país).
const int kBoliviaLocalPhoneLength = 8;

final _nonDigits = RegExp(r'\D');
final _boliviaLocalMobile = RegExp(r'^[567]\d{7}$');

bool registrationIsBoliviaDialCode(String? phoneCode) {
  return (phoneCode ?? '').replaceAll(_nonDigits, '') == kBoliviaDialDigits;
}

/// `true` si el país de registro es Bolivia (código 591 o nombre).
bool registrationPhoneCountryIsBolivia({
  String? phoneCode,
  String? countryName,
}) {
  if (registrationIsBoliviaDialCode(phoneCode)) return true;
  return countryName?.toLowerCase().trim() == 'bolivia';
}

/// Número local BO: exactamente 8 dígitos e inicia en 5, 6 o 7 (ej. `7#######`).
bool isValidBoliviaLocalMobile(String raw) {
  final d = raw.replaceAll(_nonDigits, '');
  return _boliviaLocalMobile.hasMatch(d);
}

final _registrationEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');

/// Validación visual de correo (el API sigue aceptando vacío).
bool isValidRegistrationEmail(String raw) {
  final v = raw.trim();
  if (v.isEmpty || v.length > 254) return false;
  return _registrationEmail.hasMatch(v);
}

/// Solo dígitos, máximo 8; si pegan `591` + local, deja el local.
class BoliviaLocalPhoneInputFormatter extends TextInputFormatter {
  const BoliviaLocalPhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var d = newValue.text.replaceAll(_nonDigits, '');
    if (d.startsWith(kBoliviaDialDigits) && d.length > kBoliviaLocalPhoneLength) {
      d = d.substring(kBoliviaDialDigits.length);
    }
    if (d.length > kBoliviaLocalPhoneLength) {
      d = d.substring(0, kBoliviaLocalPhoneLength);
    }
    return TextEditingValue(
      text: d,
      selection: TextSelection.collapsed(offset: d.length),
    );
  }
}

/// Fuerza MAYÚSCULAS en el campo de placa.
class RegistrationUpperCasePlateFormatter extends TextInputFormatter {
  const RegistrationUpperCasePlateFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

final _vehicleModelYearDigits = RegExp(r'^\d{4}$');

/// Año del vehículo: exactamente 4 dígitos (sin rango de catálogo).
bool isValidVehicleModelYearText(String? raw) {
  return _vehicleModelYearDigits.hasMatch((raw ?? '').trim());
}

/// Validación de campo año: requerido + 4 dígitos.
String? validateVehicleModelYear(String? v, AppLocalizations l10n) {
  if (v == null || v.trim().isEmpty) return l10n.driverRegValidationRequired;
  if (!isValidVehicleModelYearText(v)) {
    return l10n.driverRegSnackVehicleYearInvalid;
  }
  return null;
}

final vehicleYearInputFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(4),
];

const registrationCarColorSuggestions = [
  'Negro',
  'Blanco',
  'Gris',
  'Plata',
  'Rojo',
  'Azul',
  'Verde',
  'Amarillo',
  'Naranja',
  'Violeta',
  'Marrón',
  'Beige',
  'Dorado',
  'Otro',
];

List<MapEntry<String, String>> registrationGenderChoices(AppLocalizations l10n) =>
    [
      MapEntry('Male', l10n.driverProfileGenderMale),
      MapEntry('Female', l10n.driverProfileGenderFemale),
      MapEntry('Other', l10n.driverRegGenderOther),
    ];

/// Edad mínima para operar como conductor (alineada a política / Play 18+).
const int kDriverRegistrationMinAgeYears = 18;

/// `true` si [isoDate] es parseable y la persona tiene menos de [minAge] años.
bool registrationBirthDateIsUnderMinAge(
  String? isoDate, {
  int minAge = kDriverRegistrationMinAgeYears,
  DateTime? now,
}) {
  final raw = isoDate?.trim() ?? '';
  if (raw.isEmpty) return false;
  final born = DateTime.tryParse(raw);
  if (born == null) return false;
  final today = now ?? DateTime.now();
  var age = today.year - born.year;
  if (today.month < born.month ||
      (today.month == born.month && today.day < born.day)) {
    age -= 1;
  }
  return age < minAge;
}

String localizedRegistrationColor(BuildContext context, String color) {
  final l10n = AppLocalizations.of(context);
  return switch (color) {
    'Negro' => l10n.driverRegColorBlack,
    'Blanco' => l10n.driverRegColorWhite,
    'Gris' => l10n.driverRegColorGray,
    'Plata' => l10n.driverRegColorSilver,
    'Rojo' => l10n.driverRegColorRed,
    'Azul' => l10n.driverRegColorBlue,
    'Verde' => l10n.driverRegColorGreen,
    'Amarillo' => l10n.driverRegColorYellow,
    'Naranja' => l10n.driverRegColorOrange,
    'Violeta' => l10n.driverRegColorViolet,
    'Marrón' => l10n.driverRegColorBrown,
    'Beige' => l10n.driverRegColorBeige,
    'Dorado' => l10n.driverRegColorGold,
    _ => color,
  };
}

Color registrationColorFromName(String name) {
  return switch (name) {
    'Negro' => const Color(0xFF1A1A1A),
    'Blanco' => const Color(0xFFF5F5F5),
    'Gris' => const Color(0xFF9E9E9E),
    'Plata' => const Color(0xFFC0C0C0),
    'Rojo' => const Color(0xFFD32F2F),
    'Azul' => const Color(0xFF1976D2),
    'Verde' => const Color(0xFF388E3C),
    'Amarillo' => const Color(0xFFFBC02D),
    'Naranja' => const Color(0xFFF57C00),
    'Violeta' => const Color(0xFF7B1FA2),
    'Marrón' => const Color(0xFF795548),
    'Beige' => const Color(0xFFD7CCC8),
    'Dorado' => const Color(0xFFFFD700),
    _ => AppColors.textSecondary,
  };
}

String composeRegistrationFullPhone(
  RegistrationFlowBindings form,
  DriverRegistrationFlowState flow,
) {
  final code = flow.selectedCountryPhoneCode?.trim() ?? '';
  final digits = form.phoneLocalCtrl.text.replaceAll(_nonDigits, '');
  if (code.isEmpty) return digits.isEmpty ? '' : '+$digits';
  return '+$code$digits';
}

String formatRegistrationServiceLocation(DriverRegistrationFlowState flow) {
  final parts = <String>[];
  final c = flow.selectedCountryName?.trim();
  if (c != null && c.isNotEmpty) parts.add(c);
  final d = flow.selectedDepartmentName?.trim();
  if (d != null && d.isNotEmpty) parts.add(d);
  final l = flow.selectedLocalityLabel?.trim();
  if (l != null && l.isNotEmpty) parts.add(l);
  if (parts.isEmpty) return '—';
  return parts.join(' · ');
}

bool useIntegratedCatalogVehicleFields(DriverRegistrationFlowState flow) {
  final c = flow.vehicleCatalog;
  return c != null && c.catalogExtensionsAvailable && !c.compatibilityMode;
}

ThemeData registrationInputTheme(BuildContext context) {
  return Theme.of(context).copyWith(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFill,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      floatingLabelStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        fontSize: 13.5,
      ),
      errorStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.85)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.55)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error.withValues(alpha: 0.82), width: 1.15),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.6),
      ),
    ),
  );
}

String localizedRegistrationFlowError(String raw, AppLocalizations l10n) {
  final msg = raw.trim();
  final low = msg.toLowerCase();
  if (low.contains('reg_passenger_exists_upgrade_required')) {
    return l10n.driverRegErrorPassengerUpgradeRequired;
  }
  if (low.contains('reg_duplicate_user')) {
    return l10n.driverRegErrorDuplicatePhoneDriver;
  }
  if (low.contains('reg_passenger_upgrade_otp_invalid')) {
    return l10n.driverRegErrorUpgradeOtpInvalid;
  }
  if (low.contains('reg_passenger_upgrade_not_found')) {
    return l10n.driverRegErrorUpgradeOtpNotFound;
  }
  if (low.contains('pass_auth_wa_outbound_send_failed') ||
      low.contains('pass_auth_wa_outbound_not_configured') ||
      low.contains('pass_auth_wa_outbound_template_required') ||
      low.contains('pass_auth_wa_not_configured')) {
    return l10n.driverRegErrorUpgradeWhatsAppSend;
  }
  if (low.contains('account_deletion_pending')) {
    return l10n.driverRegErrorAccountDeletionPending;
  }
  if (low.contains('vehicle_limit_reached') ||
      low.contains('solo puedes tener un vehículo')) {
    return l10n.driverMyVehiclesAddLockedBody;
  }
  if (low.contains('reg_media_quota_exceeded') ||
      low.contains('límite de subidas') ||
      low.contains('rate_limit') ||
      low.contains('demasiados intentos') ||
      low.contains('demasiadas solicitudes') ||
      low.contains('demasiados envíos') ||
      low.contains('demasiadas consultas')) {
    return l10n.driverRegErrorRateLimited;
  }
  if (low.contains('registration_section_not_editable') ||
      low.contains('no admite cambios en su estado')) {
    return l10n.driverRegErrorSectionNotEditable;
  }
  if (low.contains('sin conexión a internet') ||
      low.contains('socketexception') ||
      low.contains('network is unreachable') ||
      low.contains('connection failed') ||
      low.contains('no se pudo establecer conexión')) {
    return l10n.driverRegErrorNoConnection;
  }
  if (low.contains('driver_id_bridge_missing') ||
      low.contains('legacy para asignar service types')) {
    return l10n.driverRegErrorVehicleServiceBridgeMissing;
  }
  if (low.contains('no se encontró el identificador de usuario')) {
    return l10n.driverRegErrorMissingUserId;
  }
  if (low.contains('espera a que cargue el catálogo del vehículo')) {
    return l10n.driverRegErrorVehicleCatalogLoading;
  }
  if (low.contains('catálogo del servidor no incluye tipo/categoría')) {
    return l10n.driverRegErrorVehicleCatalogIncomplete;
  }
  if (low.contains('completa tipo de vehículo y categoría')) {
    return l10n.driverRegErrorVehicleTypeCategoryRequired;
  }
  if (low.contains('selected category is invalid')) {
    return l10n.driverRegErrorVehicleCategoryInvalid;
  }
  if (low.contains('no services are configured for this category')) {
    return l10n.driverRegErrorVehicleNoServicesConfigured;
  }
  if (low.contains('servicio seleccionado que no aplica a la categoría')) {
    return l10n.driverRegErrorVehicleServiceNotAllowedForCategory;
  }
  if (low.contains('catálogo no trae código de servicio')) {
    return l10n.driverRegErrorVehicleServiceCodeMissing;
  }
  if (low.contains('sesión no disponible')) {
    return l10n.driverRegErrorSessionUnavailable;
  }
  if (low.contains('catalog_custom_required') ||
      low.contains('completa fabricante') ||
      low.contains('completa marca, modelo y año')) {
    return l10n.driverRegSnackCatalogCustomRequired;
  }
  if (low.contains('badpadding') ||
      low.contains('bad_decrypt') ||
      low.contains('bad decrypt') ||
      low.contains('openssl_internal') ||
      (low.contains('platformexception') && low.contains('cipher'))) {
    return l10n.driverRegErrorSecureStorage;
  }
  return msg;
}
