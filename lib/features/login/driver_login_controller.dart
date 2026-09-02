import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/driver_api_client.dart';
import '../../core/storage/driver_secure_storage.dart';
import '../../core/notifications/driver_push_token_service.dart';
import '../../core/session/driver_session_expulsion.dart';
import '../../core/device/driver_device_telemetry.dart';
import '../../core/session/driver_internal_tools_gate.dart';
import '../../core/session/driver_map_preferences_store.dart';
import '../../core/session/driver_must_change_password_gate.dart';
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
  final Map<String, dynamic>? accountDeletion;

  DriverLoginState({
    this.errorMessage,
    this.errorCode,
    this.accountDeletion,
  });
}

class DriverLoginController extends StateNotifier<DriverLoginState> {
  DriverLoginController({DriverApiClient? apiClient})
      : _api = apiClient ?? DriverApiClient(),
        super(DriverLoginState());

  final DriverApiClient _api;

  /// [driverRegistrationInProgress]: el conductor aún debe cargar vehículo; el backend
  /// puede exigir este flag para devolver token aunque el perfil no esté "activo".
  /// [cancelPendingDeletion]: cancela eliminación programada y continúa login normal.
  Future<bool> login({
    required String fullPhone,
    required String password,
    bool driverRegistrationInProgress = false,
    bool cancelPendingDeletion = false,
  }) async {
    state = DriverLoginState();

    try {
      final telemetry = await DriverDeviceTelemetry.toApiPayload();
      final response = await _api.postPublic<Map<String, dynamic>>(
        path: '/api/v2/auth/login',
        data: {
          'password': password,
          'user_name': fullPhone,
          ...telemetry,
          if (driverRegistrationInProgress)
            'driver_registration_in_progress': true,
          if (cancelPendingDeletion) 'cancel_pending_deletion': true,
        },
      );

      final raw = response.data;
      if (raw is! Map) return _fail(code: 'CLIENT_INVALID_RESPONSE');
      final data = Map<String, dynamic>.from(raw as Map);

      if (data['success'] != true) {
        // Algunos backends envían token en data aunque success sea false.
        if (await _tryPersistTokenFromLoginPayload(data, fullPhone: fullPhone)) {
          return true;
        }
        return _failFromPayload(data);
      }

      final payload = data['data'];
      if (payload is! Map) return _fail(code: 'CLIENT_EMPTY_DATA');

      final token = payload['token']?.toString();
      if (token == null || token.isEmpty) {
        return _fail(code: 'CLIENT_TOKEN_MISSING');
      }
      final refreshToken = payload['refresh_token']?.toString();

      await DriverSecureStorage.write(DriverApiClient.tokenStorageKey, token);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await DriverSecureStorage.write(
          DriverApiClient.refreshTokenStorageKey,
          refreshToken,
        );
      }
      await DriverSecureStorage.write(
        DriverInternalToolsGate.storageKeyLoginPhone,
        fullPhone,
      );
      await DriverMustChangePasswordGate.persistFromPayload(
        Map<String, dynamic>.from(payload),
      );
      DriverRegistrationResumeGate.invalidate(resetVehicleFormSkip: true);
      resetDriverSessionExpulsionState();
      DriverPushTokenService.instance.syncTokenIfPossible();
      return true;
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is Map &&
          await _tryPersistTokenFromLoginPayload(
            Map<String, dynamic>.from(body),
            fullPhone: fullPhone,
          )) {
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
      if (body is Map) {
        return _failFromPayload(Map<String, dynamic>.from(body));
      }
      return _fail(
        code: 'NETWORK_REQUEST_FAILED',
        message: e.message,
      );
    } catch (_) {
      return _fail(code: 'CLIENT_UNEXPECTED');
    }
  }

  Future<bool> recoverAccountFromPendingDeletion({
    required String fullPhone,
    required String password,
  }) {
    return login(
      fullPhone: fullPhone,
      password: password,
      cancelPendingDeletion: true,
    );
  }

  /// Extrae token de `data` / `data.data` (nombres habituales en APIs).
  Future<bool> _tryPersistTokenFromLoginPayload(
    Map<String, dynamic> root, {
    required String fullPhone,
  }) async {
    final candidates = <Map<String, dynamic>>[];
    if (root['data'] is Map) {
      candidates.add(Map<String, dynamic>.from(root['data'] as Map));
    }
    candidates.add(root);
    const keys = ['token', 'access_token', 'accessToken', 'driver_token', 'bearer'];
    const refreshKeys = ['refresh_token', 'refreshToken', 'driver_refresh_token'];
    for (final map in candidates) {
      for (final k in keys) {
        final v = map[k];
        if (v != null && v.toString().isNotEmpty) {
          await DriverSecureStorage.write(
            DriverApiClient.tokenStorageKey,
            v.toString(),
          );
          for (final rk in refreshKeys) {
            final rv = map[rk];
            if (rv != null && rv.toString().isNotEmpty) {
              await DriverSecureStorage.write(
                DriverApiClient.refreshTokenStorageKey,
                rv.toString(),
              );
              break;
            }
          }
          await DriverSecureStorage.write(
            DriverInternalToolsGate.storageKeyLoginPhone,
            fullPhone,
          );
          await DriverMustChangePasswordGate.persistFromPayload(map);
          DriverRegistrationResumeGate.invalidate(resetVehicleFormSkip: true);
          resetDriverSessionExpulsionState();
          DriverPushTokenService.instance.syncTokenIfPossible();
          return true;
        }
      }
    }
    return false;
  }

  /// Cierra sesión: borra el token. Navegar a /login después con GoRouter.
  Future<void> logout() async {
    DriverRegistrationResumeGate.invalidate(resetVehicleFormSkip: true);
    await DriverPushTokenService.instance.revokeAllOnServerIfPossible();
    await DriverMapPreferencesStore.clearMapPreferencesForCurrentSession();
    await DriverSecureStorage.delete(DriverApiClient.tokenStorageKey);
    await DriverSecureStorage.delete(DriverApiClient.refreshTokenStorageKey);
    await DriverSecureStorage.delete(DriverInternalToolsGate.storageKeyLoginPhone);
    await DriverMustChangePasswordGate.clear();
    state = DriverLoginState();
  }

  bool _failFromPayload(Map<String, dynamic> data) {
    final code = data['code']?.toString() ?? 'AUTH_LOGIN_FAILED';
    final message = data['message']?.toString();
    final accountDeletion = _extractAccountDeletion(data);
    state = DriverLoginState(
      errorMessage: message,
      errorCode: code,
      accountDeletion: accountDeletion,
    );
    return false;
  }

  Map<String, dynamic>? _extractAccountDeletion(Map<String, dynamic> data) {
    final direct = data['data'];
    if (direct is Map && direct['account_deletion'] is Map) {
      return Map<String, dynamic>.from(direct['account_deletion'] as Map);
    }
    final err = data['error'];
    if (err is Map && err['details'] is Map) {
      final details = Map<String, dynamic>.from(err['details'] as Map);
      if (details['account_deletion'] is Map) {
        return Map<String, dynamic>.from(details['account_deletion'] as Map);
      }
    }
    return null;
  }

  bool _fail({required String code, String? message}) {
    state = DriverLoginState(errorMessage: message, errorCode: code);
    return false;
  }
}
