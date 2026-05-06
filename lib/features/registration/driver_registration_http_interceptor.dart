import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// `X-Request-Id` + logs mínimos en debug (sin datos sensibles ni cuerpos grandes).
final class DriverRegistrationRequestIdInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent(
      'X-Request-Id',
      () => 'drv-${DateTime.now().microsecondsSinceEpoch}',
    );
    if (kDebugMode) {
      debugPrint(
        '[DriverRegistration] → ${options.method} ${options.uri} '
        'rid=${options.headers['X-Request-Id']}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final rid = response.requestOptions.headers['X-Request-Id'];
      debugPrint(
        '[DriverRegistration] ← ${response.statusCode} ${response.requestOptions.uri} rid=$rid',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final rid = err.requestOptions.headers['X-Request-Id'];
      debugPrint(
        '[DriverRegistration] ✗ ${err.response?.statusCode} ${err.requestOptions.uri} rid=$rid '
        'type=${err.type}',
      );
      if (err.error != null) {
        debugPrint('[DriverRegistration] ✗ underlying: ${err.error}');
      }
    }
    handler.next(err);
  }
}
