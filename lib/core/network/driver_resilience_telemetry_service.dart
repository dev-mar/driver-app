import 'dart:async';

import 'package:dio/dio.dart';
import '../config/driver_backend_config.dart';
import '../storage/driver_secure_storage.dart';

class DriverResilienceTelemetryService {
  DriverResilienceTelemetryService._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: DriverBackendConfig.baseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: const <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  static final Map<String, DateTime> _lastSentByKey = <String, DateTime>{};
  static const Duration _cooldown = Duration(seconds: 20);

  static Future<void> sendEvent({
    required String flow,
    required String endpoint,
    required String event,
    int? attempt,
    int? waitMs,
    int? statusCode,
  }) async {
    final now = DateTime.now();
    final dedupeKey =
        'driver|$flow|$endpoint|$event|${statusCode ?? 0}|${attempt ?? 0}';
    final prev = _lastSentByKey[dedupeKey];
    if (prev != null && now.difference(prev) < _cooldown) return;
    _lastSentByKey[dedupeKey] = now;

    final token = await DriverSecureStorage.read('driver_token');
    if (token == null || token.isEmpty) return;
    try {
      final payload = <String, dynamic>{
        'app': 'driver',
        'flow': flow,
        'endpoint': endpoint,
        'event': event,
        'attempt': attempt,
        'wait_ms': waitMs,
        'status_code': statusCode,
        'platform': 'flutter',
      }..removeWhere((_, value) => value == null);
      await _dio.post<Map<String, dynamic>>(
        '/api/v2/auth/telemetry/client-resilience',
        data: payload,
        options: Options(
          headers: <String, String>{'Authorization': 'Bearer $token'},
        ),
      );
    } catch (_) {
      // Telemetría best-effort.
    }
  }
}
