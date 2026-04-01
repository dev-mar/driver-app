import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/config/driver_backend_config.dart';

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
  });

  final String? uuid;
  final bool needsVehicleRegistration;
  final bool canOperateAsDriver;
  final String registrationPhase;

  /// `true` si falta al menos un paso del alta (KYC, activación o vehículo) según backend.
  final bool needsResumeRegistration;

  /// Fase canónica del flujo: `identity` | `license` | `activation` | `vehicle_registration` | `complete`.
  final String registrationFlowPhase;

  /// Paso sugerido en la app (0–5, alineado a `DriverRegistrationFlowScreen`).
  final int? suggestedClientStep;

  /// `reference.countries.id` / `public.departments.country_id` vía localidad del staff; para `registration.country_id` en alta vehículo v2.
  final int? registrationCountryId;

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
    );
  }

  static Future<DriverOperationalProfile> fetch() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'driver_token');
    if (token == null || token.isEmpty) {
      throw StateError('no_token');
    }
    final dio = Dio(
      BaseOptions(
        baseUrl: DriverBackendConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: <String, String>{
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    final response = await dio.get<Map<String, dynamic>>('/api/v2/driver/me-profile');
    final root = response.data;
    if (root == null || root['success'] != true) {
      throw StateError('profile_fail');
    }
    final data = root['data'];
    if (data is! Map) {
      throw StateError('bad_format');
    }
    return DriverOperationalProfile.fromJson(Map<String, dynamic>.from(data));
  }
}

final driverOperationalProfileProvider =
    FutureProvider.autoDispose<DriverOperationalProfile>((ref) async {
  return DriverOperationalProfile.fetch();
});
