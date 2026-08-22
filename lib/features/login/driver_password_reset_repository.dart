import 'package:dio/dio.dart';

import '../../core/device/driver_device_telemetry.dart';
import '../../core/network/driver_api_client.dart';

class DriverPasswordResetException implements Exception {
  DriverPasswordResetException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => message;
}

class DriverPasswordResetChallenge {
  const DriverPasswordResetChallenge({
    required this.channel,
    this.challengeId,
    this.waDeepLink,
    this.emailMasked,
    this.emailOnFile = false,
    this.emailRequired = false,
    this.expiresIn,
  });

  final String channel;
  final String? challengeId;
  final String? waDeepLink;
  final String? emailMasked;
  final bool emailOnFile;
  final bool emailRequired;
  final int? expiresIn;

  bool get isWhatsAppInbound => channel == 'whatsapp_inbound';
  bool get isEmail => channel == 'email';
}

class DriverPasswordResetRepository {
  DriverPasswordResetRepository({Dio? dio})
      : _dio = dio ?? DriverApiClient.createPublicDio();

  final Dio _dio;

  Future<DriverPasswordResetChallenge> start({
    required String phoneE164,
    required String channel,
    String? email,
  }) async {
    try {
      final telemetry = await DriverDeviceTelemetry.toApiPayload();
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v2/driver/auth/password-reset/start',
        data: <String, dynamic>{
          'user_name': phoneE164,
          'channel': channel,
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
          ...telemetry,
        },
      );
      return _challengeFromResponse(response.data);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<void> complete({
    required String phoneE164,
    required String channel,
    required String newPassword,
    String? email,
    String? emailCode,
  }) async {
    try {
      final telemetry = await DriverDeviceTelemetry.toApiPayload();
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v2/driver/auth/password-reset/complete',
        data: <String, dynamic>{
          'user_name': phoneE164,
          'channel': channel,
          'new_password': newPassword,
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
          if (emailCode != null && emailCode.trim().isNotEmpty)
            'email_code': emailCode.trim(),
          ...telemetry,
        },
      );
      final data = response.data;
      if (data == null || data['success'] != true) {
        throw DriverPasswordResetException(
          _extractMessage(data),
          code: _extractCode(data),
        );
      }
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  Future<String?> getChallengeStatus({
    required String phoneE164,
    required String challengeId,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v2/auth/challenge-status',
        queryParameters: <String, String>{
          'phone_e164': phoneE164,
          'challenge_id': challengeId,
        },
      );
      final data = response.data;
      if (data == null || data['success'] != true) return null;
      final inner = data['data'];
      if (inner is! Map) return null;
      final status = inner['status']?.toString().trim();
      if (status == null || status.isEmpty) return null;
      return status;
    } on DioException {
      return null;
    }
  }

  DriverPasswordResetChallenge _challengeFromResponse(Map<String, dynamic>? data) {
    if (data == null || data['success'] != true) {
      throw DriverPasswordResetException(
        _extractMessage(data),
        code: _extractCode(data),
      );
    }
    final inner = data['data'];
    final map = inner is Map ? Map<String, dynamic>.from(inner) : <String, dynamic>{};
    final channel = map['verification_channel']?.toString().trim() ?? '';
    final expiresRaw = map['expires_in'];
    int? expiresIn;
    if (expiresRaw is int) {
      expiresIn = expiresRaw;
    } else if (expiresRaw is num) {
      expiresIn = expiresRaw.toInt();
    }
    return DriverPasswordResetChallenge(
      channel: channel.isEmpty ? 'whatsapp_inbound' : channel,
      challengeId: map['challenge_id']?.toString(),
      waDeepLink: map['wa_deep_link']?.toString(),
      emailMasked: map['email_masked']?.toString(),
      emailOnFile: map['email_on_file'] == true,
      emailRequired: map['email_required'] == true,
      expiresIn: expiresIn,
    );
  }

  DriverPasswordResetException _fromDio(DioException e) {
    final data = e.response?.data;
    Map<String, dynamic>? map;
    if (data is Map) {
      map = Map<String, dynamic>.from(data);
    }
    return DriverPasswordResetException(
      map != null ? _extractMessage(map) : (e.message ?? 'No se pudo restablecer la contraseña.'),
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
    return 'No se pudo restablecer la contraseña.';
  }
}
