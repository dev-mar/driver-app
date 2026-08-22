import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/driver_api_client.dart';
import '../../core/network/driver_profile_api_providers.dart';
import '../../core/network/request_policy_cache.dart';

/// Snapshot mínimo del perfil conductor para gating operativo (viajes / registro vehículo).
class DriverOperationalProfile {
  const DriverOperationalProfile({
    this.uuid,
    required this.needsVehicleRegistration,
    required this.canOperateAsDriver,
    required this.registrationPhase,
    required this.needsResumeRegistration,
    this.registrationFlowPhase = '',
    this.suggestedClientStep,
    this.registrationCountryId,
    this.mustChangePassword = false,
  });

  final String? uuid;
  final bool needsVehicleRegistration;
  final bool canOperateAsDriver;
  final String registrationPhase;

  /// `true` si falta al menos un paso del alta (KYC, activación o vehículo) según backend.
  final bool needsResumeRegistration;

  /// Forzar asistente `/register?resumeAfterLogin=1` (documentos / activación). Si solo falta vehículo (`suggested_client_step` ≥ 4), el conductor completa desde el menú.
  bool get shouldForceRegistrationWizard =>
      needsResumeRegistration &&
      (suggestedClientStep == null || suggestedClientStep! < 4);

  /// Fase canónica del flujo: `identity` | `license` | `activation` | `vehicle_registration` | `complete`.
  final String registrationFlowPhase;

  /// Paso sugerido en la app (0–5, alineado a `DriverRegistrationFlowScreen`).
  final int? suggestedClientStep;

  /// `reference.countries.id` vía localidad del staff; para `registration.country_id` en alta vehículo v2.
  final int? registrationCountryId;

  /// Tras reset de soporte: debe crear una contraseña propia antes de operar.
  final bool mustChangePassword;

  factory DriverOperationalProfile.fromJson(Map<String, dynamic> json) {
    final u = json['uuid']?.toString();
    final rawCountry = json['registration_country_id'];
    int? countryId;
    if (rawCountry is int) {
      countryId = rawCountry;
    } else if (rawCountry is num) {
      countryId = rawCountry.toInt();
    } else if (rawCountry != null) {
      countryId = int.tryParse(rawCountry.toString());
    }
    final flowPhase = json['registration_flow_phase']?.toString() ?? '';
    final regPhase = json['registration_phase']?.toString() ?? '';
    final explicitResume = json['needs_resume_registration'] == true;
    final pendingLegacy = regPhase == 'pending_account';
    final needsResume = explicitResume ||
        pendingLegacy ||
        (flowPhase.isNotEmpty && flowPhase != 'complete');

    int? step;
    final rawStep = json['suggested_client_step'];
    if (rawStep is int) {
      step = rawStep;
    } else if (rawStep is num) {
      step = rawStep.toInt();
    } else if (rawStep != null) {
      step = int.tryParse(rawStep.toString());
    }

    return DriverOperationalProfile(
      uuid: u != null && u.isNotEmpty ? u : null,
      needsVehicleRegistration: json['needs_vehicle_registration'] == true,
      canOperateAsDriver: json['can_operate_as_driver'] == true,
      registrationPhase: regPhase,
      needsResumeRegistration: needsResume,
      registrationFlowPhase: flowPhase,
      suggestedClientStep: step,
      registrationCountryId: countryId,
      mustChangePassword: json['must_change_password'] == true ||
          json['must_change_password'] == 'true' ||
          json['must_change_password'] == 1 ||
          json['must_change_password'] == '1',
    );
  }

  static Future<DriverOperationalProfile> fetch({
    DriverMeProfileService? meProfileService,
  }) async {
    return _operationalProfileCache.run(
      key: _operationalProfileCacheKey,
      fetcher: () async {
        final service = meProfileService ??
            DriverMeProfileService(DriverApiClient());
        final data = await service.fetchData();
        return DriverOperationalProfile.fromJson(data);
      },
      ttl: const Duration(seconds: 15),
    );
  }
}

const String _operationalProfileCacheKey = 'driver_operational_profile';
final RequestPolicyCache<DriverOperationalProfile> _operationalProfileCache =
    RequestPolicyCache<DriverOperationalProfile>(
      defaultTtl: const Duration(seconds: 15),
    );

final driverOperationalProfileProvider =
    FutureProvider.autoDispose<DriverOperationalProfile>((ref) async {
  final meProfile = ref.watch(driverMeProfileServiceProvider);
  return DriverOperationalProfile.fetch(meProfileService: meProfile);
});

/// GET autenticado con retry (historial, QA, etc.).
Future<Response<T>> driverAuthedGetWithRetry<T>({
  required String path,
  required String flow,
  int maxAttempts = 3,
  Map<String, dynamic>? queryParameters,
}) {
  return DriverApiClient().getWithRetry<T>(
    path: path,
    flow: flow,
    maxAttempts: maxAttempts,
    queryParameters: queryParameters,
  );
}

/// Perfil `data` sin Riverpod (resume gate, etc.).
Future<Map<String, dynamic>> fetchDriverMeProfileData() {
  return DriverMeProfileService(DriverApiClient()).fetchData();
}

/// Créditos `data` sin Riverpod.
Future<Map<String, dynamic>> fetchDriverAppCreditsData() {
  return DriverAppCreditsService(DriverApiClient()).fetchData();
}
