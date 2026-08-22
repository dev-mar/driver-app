import 'package:dio/dio.dart';

import '../config/driver_backend_config.dart';
import '../device/driver_device_telemetry.dart';
import '../storage/driver_secure_storage.dart';
import 'driver_http_resilience.dart';
import 'driver_session_guard.dart';

/// Cliente HTTP autenticado del conductor (Bearer + retry + telemetría).
class DriverApiClient {
  DriverApiClient({
    String? baseUrl,
  }) : _baseUrl = baseUrl ?? DriverBackendConfig.baseUrl;

  final String _baseUrl;

  static const String tokenStorageKey = 'driver_token';
  static const String refreshTokenStorageKey = 'driver_refresh_token';

  /// Dio sin Bearer (login, refresh).
  static Dio createPublicDio({
    String? baseUrl,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 15),
  }) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl ?? DriverBackendConfig.baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: const <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// Geo/registro: solo Accept (sin Content-Type forzado).
  static Dio createGeoDio({
    String? baseUrl,
    Duration connectTimeout = const Duration(seconds: 20),
    Duration receiveTimeout = const Duration(seconds: 20),
  }) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl ?? DriverBackendConfig.baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: const <String, String>{'Accept': 'application/json'},
      ),
    );
  }

  /// Registro usuario/vehículo (payloads JSON grandes, timeout largo).
  static Dio createUsersDio({
    String? baseUrl,
    List<Interceptor> interceptors = const [],
    Duration connectTimeout = const Duration(seconds: 20),
    Duration receiveTimeout = const Duration(seconds: 60),
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? DriverBackendConfig.baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: const <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    for (final interceptor in interceptors) {
      dio.interceptors.add(interceptor);
    }
    return dio;
  }

  Future<String?> readToken() => DriverSecureStorage.read(tokenStorageKey);

  Future<String> requireToken() async {
    final token = await readToken();
    if (token == null || token.isEmpty) {
      throw const DriverApiSessionException();
    }
    return token;
  }

  Dio _authedDio(String token) {
    final dio = buildDriverAuthedDio(
      token: token,
      baseUrl: _baseUrl,
    );
    attachDriverSessionInvalidatedInterceptor(dio);
    return dio;
  }

  Future<Response<T>> getWithRetry<T>({
    required String path,
    required String flow,
    int maxAttempts = 3,
    Map<String, dynamic>? queryParameters,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) async {
    final token = await requireToken();
    final dio = _authedDio(token);
    if (connectTimeout != null || receiveTimeout != null) {
      dio.options.connectTimeout = connectTimeout ?? dio.options.connectTimeout;
      dio.options.receiveTimeout = receiveTimeout ?? dio.options.receiveTimeout;
    }
    return requestWithRetry<Response<T>>(
      flow: flow,
      endpoint: path,
      maxAttempts: maxAttempts,
      operation: () => dio.get<T>(
        path,
        queryParameters: queryParameters,
      ),
    );
  }

  Future<Response<T>> postWithRetry<T>({
    required String path,
    required String flow,
    Object? data,
    int maxAttempts = 3,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) async {
    final token = await requireToken();
    final dio = _authedDio(token);
    if (connectTimeout != null || receiveTimeout != null) {
      dio.options.connectTimeout = connectTimeout ?? dio.options.connectTimeout;
      dio.options.receiveTimeout = receiveTimeout ?? dio.options.receiveTimeout;
    }
    return requestWithRetry<Response<T>>(
      flow: flow,
      endpoint: path,
      maxAttempts: maxAttempts,
      operation: () => dio.post<T>(path, data: data),
    );
  }

  /// DELETE autenticado (p. ej. eliminación de cuenta). Sin retry por defecto.
  Future<Response<T>> deleteWithRetry<T>({
    required String path,
    required String flow,
    Object? data,
    int maxAttempts = 1,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) async {
    final token = await requireToken();
    final dio = _authedDio(token);
    if (connectTimeout != null || receiveTimeout != null) {
      dio.options.connectTimeout = connectTimeout ?? dio.options.connectTimeout;
      dio.options.receiveTimeout = receiveTimeout ?? dio.options.receiveTimeout;
    }
    return requestWithRetry<Response<T>>(
      flow: flow,
      endpoint: path,
      maxAttempts: maxAttempts,
      operation: () => dio.delete<T>(path, data: data),
    );
  }

  /// POST público sin Bearer (login, refresh). Sin retry — feedback inmediato al usuario.
  Future<Response<T>> postPublic<T>({
    required String path,
    Object? data,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 15),
  }) {
    final dio = createPublicDio(
      baseUrl: _baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    );
    return dio.post<T>(path, data: data);
  }

  /// Renueva access token vía `POST /api/v2/auth/refresh`. Devuelve `false` si falla.
  Future<bool> tryRefreshSession() async {
    final refreshToken = await DriverSecureStorage.read(refreshTokenStorageKey);
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      final telemetry = await DriverDeviceTelemetry.toApiPayload();
      final res = await postPublic<Map<String, dynamic>>(
        path: '/api/v2/auth/refresh',
        data: <String, dynamic>{
          'refresh_token': refreshToken,
          ...telemetry,
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      );
      final body = res.data;
      if (body == null) return false;
      final token = body['token']?.toString();
      final newRefreshToken = body['refresh_token']?.toString();
      if (token == null || token.isEmpty) return false;
      await DriverSecureStorage.write(tokenStorageKey, token);
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await DriverSecureStorage.write(
          refreshTokenStorageKey,
          newRefreshToken,
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Parsea envelope `{ success, data }` o lanza [DriverApiResponseException].
  static Map<String, dynamic> parseSuccessData(Map<String, dynamic>? root) {
    if (root == null) {
      throw const DriverApiResponseException('empty_response');
    }
    if (root['success'] != true) {
      final msg = root['message']?.toString();
      throw DriverApiResponseException(msg ?? 'request_failed');
    }
    final data = root['data'];
    if (data is! Map) {
      throw const DriverApiResponseException('bad_format');
    }
    return Map<String, dynamic>.from(data);
  }
}

class DriverApiSessionException implements Exception {
  const DriverApiSessionException();

  @override
  String toString() => 'no_token';
}

class DriverApiResponseException implements Exception {
  const DriverApiResponseException(this.code);
  final String code;

  @override
  String toString() => code;
}
