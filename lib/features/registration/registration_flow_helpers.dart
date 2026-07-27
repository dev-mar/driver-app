import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../gen_l10n/app_localizations.dart';
import 'driver_registration_controller.dart';
import 'registration_flow_bindings.dart';

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
  final digits = form.phoneLocalCtrl.text.replaceAll(RegExp(r'\D'), '');
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
  return msg;
}
