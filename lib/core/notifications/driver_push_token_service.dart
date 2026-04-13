import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/driver_backend_config.dart';

class DriverPushTokenService {
  DriverPushTokenService._();
  static final DriverPushTokenService instance = DriverPushTokenService._();
  static const _storage = FlutterSecureStorage();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: DriverBackendConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ),
  );

  Future<void> syncTokenIfPossible() async {
    try {
      final bearer = await _storage.read(key: 'driver_token');
      if (bearer == null || bearer.isEmpty) return;
      if (Firebase.apps.isEmpty) return;
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      final platform = kIsWeb
          ? 'web'
          : (defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android');
      await _dio.post<Map<String, dynamic>>(
        '/api/v2/driver/push-token',
        data: {
          'token': token,
          'provider': 'fcm',
          'platform': platform,
          'app_id': DriverBackendConfig.firebaseAndroidApplicationId,
        },
        options: Options(headers: {'Authorization': 'Bearer $bearer'}),
      );
    } catch (_) {
      // No bloquear el flujo principal si FCM no está listo.
    }
  }

  /// Logout: deja de enviar FCM a este dispositivo/cuenta hasta el próximo login + sync.
  Future<void> revokeAllOnServerIfPossible() async {
    try {
      final bearer = await _storage.read(key: 'driver_token');
      if (bearer == null || bearer.isEmpty) return;
      await _dio.delete<Map<String, dynamic>>(
        '/api/v2/driver/push-token',
        options: Options(headers: {'Authorization': 'Bearer $bearer'}),
      );
    } catch (_) {
      // Cierre de sesión no debe fallar por red.
    }
  }
}

