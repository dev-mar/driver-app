import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/notifications/driver_push_token_service.dart';
import '../../core/config/driver_backend_config.dart';
import '../../core/session/driver_internal_tools_gate.dart';
import '../../core/session/driver_registration_resume_gate.dart';

final driverLoginControllerProvider =
    StateNotifierProvider<DriverLoginController, DriverLoginState>((ref) {
  return DriverLoginController();
});

/// Convención de errores (login/realtime):
/// 1) Controller emite `errorCode` estable (no texto UI hardcodeado).
/// 2) UI mapea `errorCode` -> `l10n`.
/// 3) `errorMessage` queda solo como fallback para mensajes backend.
/// 4) Códigos nuevos deben agregarse también al mapping de pantalla.
class DriverLoginState {
  final String? errorMessage;
  final String? errorCode;
  DriverLoginState({this.errorMessage, this.errorCode});
}

class DriverLoginController extends StateNotifier<DriverLoginState> {
  DriverLoginController() : super(DriverLoginState());

  static const _storage = FlutterSecureStorage();

  // Base URL del backend unificado para autenticación de conductor.
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: DriverBackendConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  /// [driverRegistrationInProgress]: el conductor aún debe cargar vehículo; el backend
  /// puede exigir este flag para devolver token aunque el perfil no esté "activo".
  Future<bool> login({
    required String fullPhone,
    required String password,
    bool driverRegistrationInProgress = false,
  }) async {
    state = DriverLoginState();

    try {
      final response = await _dio.post(
        '/api/v2/auth/login',
        data: {
          'brand': 'Texi Driver App',
          'ip': '0.0.0.0',
          'model': _deviceModel(),
          'os': Platform.operatingSystem,
          'password': password,
          'user_name': fullPhone,
          if (driverRegistrationInProgress)
            'driver_registration_in_progress': true,
        },
      );

      final data = response.data;
      if (data is! Map) return _fail(code: 'CLIENT_INVALID_RESPONSE');

      if (data['success'] != true) {
        // Algunos backends envían token en data aunque success sea false.
        if (await _tryPersistTokenFromLoginPayload(data, fullPhone: fullPhone)) {
          return true;
        }
        return _fail(
          code: data['code']?.toString() ?? 'AUTH_LOGIN_FAILED',
          message: data['message']?.toString(),
        );
      }

      final payload = data['data'];
      if (payload is! Map) return _fail(code: 'CLIENT_EMPTY_DATA');

      final token = payload['token']?.toString();
      if (token == null || token.isEmpty) {
        return _fail(code: 'CLIENT_TOKEN_MISSING');
      }
      final refreshToken = payload['refresh_token']?.toString();

      await _storage.write(key: 'driver_token', value: token);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _storage.write(key: 'driver_refresh_token', value: refreshToken);
      }
      await _storage.write(
        key: DriverInternalToolsGate.storageKeyLoginPhone,
        value: fullPhone,
      );
      DriverRegistrationResumeGate.invalidate();
      DriverPushTokenService.instance.syncTokenIfPossible();
      return true;
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is Map &&
          await _tryPersistTokenFromLoginPayload(body, fullPhone: fullPhone)) {
        return true;
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return _fail(code: 'NETWORK_TIMEOUT');
      }
      if (e.type == DioExceptionType.connectionError) {
        return _fail(code: 'NETWORK_CONNECTION');
      }
      final msg = body is Map ? body['message']?.toString() : null;
      final code = body is Map ? body['code']?.toString() : null;
      return _fail(
        code: code ?? 'NETWORK_REQUEST_FAILED',
        message: msg ?? e.message,
      );
    } catch (_) {
      return _fail(code: 'CLIENT_UNEXPECTED');
    }
  }

  /// Extrae token de `data` / `data.data` (nombres habituales en APIs).
  Future<bool> _tryPersistTokenFromLoginPayload(
    Map<dynamic, dynamic> root, {
    required String fullPhone,
  }) async {
    final candidates = <Map<dynamic, dynamic>>[];
    if (root['data'] is Map) candidates.add(root['data'] as Map);
    candidates.add(root);
    const keys = ['token', 'access_token', 'accessToken', 'driver_token', 'bearer'];
    const refreshKeys = ['refresh_token', 'refreshToken', 'driver_refresh_token'];
    for (final map in candidates) {
      for (final k in keys) {
        final v = map[k];
        if (v != null && v.toString().isNotEmpty) {
          await _storage.write(key: 'driver_token', value: v.toString());
          for (final rk in refreshKeys) {
            final rv = map[rk];
            if (rv != null && rv.toString().isNotEmpty) {
              await _storage.write(key: 'driver_refresh_token', value: rv.toString());
              break;
            }
          }
          await _storage.write(
            key: DriverInternalToolsGate.storageKeyLoginPhone,
            value: fullPhone,
          );
          DriverRegistrationResumeGate.invalidate();
          DriverPushTokenService.instance.syncTokenIfPossible();
          return true;
        }
      }
    }
    return false;
  }

  /// Cierra sesión: borra el token. Navegar a /login después con GoRouter.
  Future<void> logout() async {
    DriverRegistrationResumeGate.invalidate();
    await _storage.delete(key: 'driver_token');
    await _storage.delete(key: 'driver_refresh_token');
    await _storage.delete(key: DriverInternalToolsGate.storageKeyLoginPhone);
    state = DriverLoginState();
  }

  bool _fail({required String code, String? message}) {
    state = DriverLoginState(errorMessage: message, errorCode: code);
    return false;
  }

  String _deviceModel() {
    try {
      return Platform.localHostname;
    } catch (_) {
      return 'Unknown';
    }
  }
}

