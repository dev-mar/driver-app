import 'dart:async' show unawaited;

import 'package:dio/dio.dart';

import '../session/driver_session_expulsion.dart';

String? stableApiErrorCodeFromResponse(dynamic data) {
  if (data is! Map) return null;
  final map = Map<String, dynamic>.from(data);
  final code = map['code']?.toString();
  if (code != null && code.isNotEmpty) return code;
  final err = map['error'];
  if (err is Map) {
    final nested = Map<String, dynamic>.from(err);
    final nestedCode = nested['code']?.toString();
    if (nestedCode != null && nestedCode.isNotEmpty) return nestedCode;
  }
  return null;
}

void attachDriverSessionInvalidatedInterceptor(Dio dio) {
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) {
        final status = error.response?.statusCode;
        if (status == 401) {
          final code = stableApiErrorCodeFromResponse(error.response?.data) ??
              'SESSION_SUPERSEDED';
          unawaited(notifyDriverSessionExpelled(code));
        }
        return handler.next(error);
      },
    ),
  );
}
