import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final driverLoginControllerProvider =
    StateNotifierProvider<DriverLoginController, DriverLoginState>((ref) {
  return DriverLoginController();
});

class DriverLoginState {
  final String? errorMessage;
  DriverLoginState({this.errorMessage});
}

class DriverLoginController extends StateNotifier<DriverLoginState> {
  DriverLoginController() : super(DriverLoginState());

  static const _storage = FlutterSecureStorage();

  // Base URL fija para el backend de autenticación de conductor.
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://ec2-3-150-198-57.us-east-2.compute.amazonaws.com:8001',
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
        '/api/v1/auth/login',
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
      if (data is! Map) return _fail('Respuesta inválida del servidor');

      if (data['success'] != true) {
        // Algunos backends envían token en data aunque success sea false.
        if (await _tryPersistTokenFromLoginPayload(data)) {
          return true;
        }
        return _fail(data['message']?.toString() ?? 'Error al iniciar sesión');
      }

      final payload = data['data'];
      if (payload is! Map) return _fail('Respuesta sin datos');

      final token = payload['token']?.toString();
      if (token == null || token.isEmpty) {
        return _fail('No se recibió token');
      }

      await _storage.write(key: 'driver_token', value: token);
      return true;
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is Map && await _tryPersistTokenFromLoginPayload(body)) {
        return true;
      }
      final msg = body is Map ? body['message']?.toString() : null;
      return _fail(msg ?? e.message ?? 'Error de conexión');
    } catch (_) {
      return _fail('Error inesperado');
    }
  }

  /// Extrae token de `data` / `data.data` (nombres habituales en APIs).
  Future<bool> _tryPersistTokenFromLoginPayload(Map<dynamic, dynamic> root) async {
    final candidates = <Map<dynamic, dynamic>>[];
    if (root['data'] is Map) candidates.add(root['data'] as Map);
    candidates.add(root);
    const keys = ['token', 'access_token', 'accessToken', 'driver_token', 'bearer'];
    for (final map in candidates) {
      for (final k in keys) {
        final v = map[k];
        if (v != null && v.toString().isNotEmpty) {
          await _storage.write(key: 'driver_token', value: v.toString());
          return true;
        }
      }
    }
    return false;
  }

  /// Cierra sesión: borra el token. Navegar a /login después con GoRouter.
  Future<void> logout() async {
    await _storage.delete(key: 'driver_token');
    state = DriverLoginState();
  }

  bool _fail(String message) {
    state = DriverLoginState(errorMessage: message);
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

