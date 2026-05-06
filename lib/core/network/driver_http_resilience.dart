import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

import 'driver_resilience_telemetry_service.dart';

final Random _retryJitterRandom = Random();

int? retryAfterMsFromDio(DioException error) {
  final retryAfterRaw = error.response?.headers.value('retry-after');
  if (retryAfterRaw != null) {
    final sec = int.tryParse(retryAfterRaw.trim());
    if (sec != null && sec > 0) return sec * 1000;
  }
  final body = error.response?.data;
  if (body is Map) {
    final envelope = Map<String, dynamic>.from(body);
    final errorObj = envelope['error'];
    if (errorObj is Map) {
      final err = Map<String, dynamic>.from(errorObj);
      final msRaw = err['retry_after_ms'];
      if (msRaw is num && msRaw > 0) return msRaw.toInt();
      final secRaw = err['retry_after_sec'];
      if (secRaw is num && secRaw > 0) return secRaw.toInt() * 1000;
    }
    final topMs = envelope['retry_after_ms'];
    if (topMs is num && topMs > 0) return topMs.toInt();
    final topSec = envelope['retry_after_sec'];
    if (topSec is num && topSec > 0) return topSec.toInt() * 1000;
  }
  return null;
}

bool isRetryableDioFailure(DioException error) {
  final status = error.response?.statusCode ?? 0;
  if (status == 429 || status >= 500) return true;
  return error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.unknown;
}

Future<T> requestWithRetry<T>({
  required Future<T> Function() operation,
  required String flow,
  required String endpoint,
  int maxAttempts = 3,
  int baseDelayMs = 300,
  int maxDelayMs = 5000,
}) async {
  var attempt = 0;
  while (true) {
    attempt += 1;
    try {
      return await operation();
    } on DioException catch (e) {
      final shouldRetry = attempt < maxAttempts && isRetryableDioFailure(e);
      if (!shouldRetry) {
        unawaited(
          DriverResilienceTelemetryService.sendEvent(
            flow: flow,
            endpoint: endpoint,
            event: 'retry_exhausted',
            attempt: attempt,
            statusCode: e.response?.statusCode,
          ),
        );
        rethrow;
      }
      final retryAfterMs = retryAfterMsFromDio(e);
      final expDelay = baseDelayMs * (1 << (attempt - 1).clamp(0, 5));
      final jitter = _retryJitterRandom.nextInt(280);
      final waitMs = max(retryAfterMs ?? 0, expDelay + jitter)
          .clamp(250, maxDelayMs)
          .toInt();
      final statusCode = e.response?.statusCode;
      unawaited(
        DriverResilienceTelemetryService.sendEvent(
          flow: flow,
          endpoint: endpoint,
          event: statusCode == 429 ? 'rate_limited' : 'retry_attempt',
          attempt: attempt,
          waitMs: waitMs,
          statusCode: statusCode,
        ),
      );
      await Future<void>.delayed(Duration(milliseconds: waitMs));
    }
  }
}

Dio buildDriverAuthedDio({
  required String token,
  required String baseUrl,
  Duration connectTimeout = const Duration(seconds: 15),
  Duration receiveTimeout = const Duration(seconds: 20),
}) {
  return Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ),
  );
}
