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
  });

  final String? uuid;
  final bool needsVehicleRegistration;
  final bool canOperateAsDriver;
  final String registrationPhase;

  factory DriverOperationalProfile.fromJson(Map<String, dynamic> json) {
    final u = json['uuid']?.toString();
    return DriverOperationalProfile(
      uuid: u != null && u.isNotEmpty ? u : null,
      needsVehicleRegistration: json['needs_vehicle_registration'] == true,
      canOperateAsDriver: json['can_operate_as_driver'] == true,
      registrationPhase: json['registration_phase']?.toString() ?? '',
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
