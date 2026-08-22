import 'package:dio/dio.dart';

import '../../core/device/driver_device_telemetry.dart';
import '../../core/network/driver_api_client.dart';

class DriverChangePasswordException implements Exception {
  DriverChangePasswordException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => message;
}

class DriverChangePasswordRepository {
  DriverChangePasswordRepository({DriverApiClient? apiClient})
      : _api = apiClient ?? DriverApiClient();

  final DriverApiClient _api;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final telemetry = await DriverDeviceTelemetry.toApiPayload();
      final response = await _api.postWithRetry<Map<String, dynamic>>(
        path: '/api/v2/driver/auth/change-password',
        flow: 'driver_change_password',
        data: <String, dynamic>{
          'current_password': currentPassword,
          'new_password': newPassword,
          ...telemetry,
        },
        maxAttempts: 2,
      );
      final data = response.data;
      if (data == null || data['success'] != true) {
        throw DriverChangePasswordException(
          _extractMessage(data),
          code: _extractCode(data),
        );
      }
    } on DriverChangePasswordException {
      rethrow;
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  DriverChangePasswordException _fromDio(DioException e) {
    final data = e.response?.data;
    Map<String, dynamic>? map;
    if (data is Map) {
      map = Map<String, dynamic>.from(data);
    }
    return DriverChangePasswordException(
      map != null
          ? _extractMessage(map)
          : (e.message ?? 'No se pudo actualizar la contraseña.'),
      code: _extractCode(map),
    );
  }

  String? _extractCode(Map<String, dynamic>? data) {
    if (data == null) return null;
    final error = data['error'];
    if (error is Map && error['code'] != null) {
      return error['code'].toString();
    }
    final code = data['code']?.toString().trim();
    return (code == null || code.isEmpty) ? null : code;
  }

  String _extractMessage(Map<String, dynamic>? data) {
    if (data == null) return 'Respuesta vacía';
    final message = data['message']?.toString().trim();
    if (message != null && message.isNotEmpty) return message;
    return 'No se pudo actualizar la contraseña.';
  }
}
