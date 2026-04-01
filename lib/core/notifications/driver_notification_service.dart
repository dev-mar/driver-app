import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notificaciones locales del conductor: FCM en foreground / data-only en background
/// (ofertas las envía el backend por FCM; ver `sendDriverTripOffer`).
class DriverNotificationService {
  DriverNotificationService._();
  static final DriverNotificationService instance = DriverNotificationService._();

  static const String _channelId = 'texi_driver_trip_offers';
  static const String _channelName = 'Solicitudes de viaje';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Llamar desde main() al arrancar la app.
  Future<void> initialize() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Notificaciones cuando llegan nuevas solicitudes de viaje.',
      importance: Importance.high,
      playSound: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Android 13+ requiere permiso en runtime para mostrar notificaciones.
    if (Platform.isAndroid) {
      try {
        final androidPlugin =
            _plugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.requestNotificationsPermission();
      } catch (_) {
        // Si el permiso ya fue concedido o el SO ignora la llamada, continuamos.
      }
    }

    _initialized = true;
    debugPrint('[DriverNotification] Inicializado.');
  }

  static Future<void> showFcmDataOnlyMessage(RemoteMessage message) async {
    final inst = DriverNotificationService.instance;
    await inst.initialize();
    final title = message.data['title']?.toString().trim();
    final body = message.data['body']?.toString().trim();
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }
    final tripId =
        message.data['tripId']?.toString() ?? message.data['trip_id']?.toString();
    await inst._showFcmRaw(
      title: title?.isNotEmpty == true ? title! : 'Texi Conductor',
      body: body ?? '',
      payload: tripId,
    );
  }

  Future<void> showFcmForegroundMessage(RemoteMessage message) async {
    if (!_initialized) await initialize();
    final n = message.notification;
    final title = n?.title?.trim().isNotEmpty == true
        ? n!.title!.trim()
        : (message.data['title']?.toString().trim().isNotEmpty == true
            ? message.data['title']!.trim()
            : 'Texi Conductor');
    final body = n?.body?.trim().isNotEmpty == true
        ? n!.body!.trim()
        : (message.data['body']?.toString() ?? '');
    final tripId =
        message.data['tripId']?.toString() ?? message.data['trip_id']?.toString();
    await _showFcmRaw(title: title, body: body, payload: tripId);
  }

  Future<void> _showFcmRaw({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Notificaciones FCM y solicitudes de viaje.',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const details = NotificationDetails(android: android);
    final id = (payload ?? title + body).hashCode.abs() % 2147483647;
    await _plugin.show(id, title, body, details, payload: payload);
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null && kDebugMode) {
      debugPrint('[DriverNotification] Tapped payload=${response.payload}');
    }
  }
}
