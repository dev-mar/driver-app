import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Canal y IDs para notificaciones de la app conductor (Google Play compliant).
/// Solo se usan para ofertas de viaje cuando la app está en segundo plano.
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

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      debugPrint('[DriverNotification] Tapped payload=${response.payload}');
      // Opcional: abrir pantalla concreta o refrescar ofertas.
    }
  }

  /// Muestra notificación de nueva oferta solo si la app está en segundo plano.
  /// Cumple con políticas de Google: no notificar cuando la app está visible.
  Future<void> showTripOfferNotificationIfBackground({
    required bool isAppInForeground,
    required String tripId,
    String? priceInfo,
    String? originAddress,
    String? destinationAddress,
    double? etaMinutes,
    double? distanceKm,
  }) async {
    if (isAppInForeground || !_initialized) return;
    final safeOrigin =
        (originAddress ?? '').isNotEmpty ? originAddress! : 'Punto de origen';
    final safeDest =
        (destinationAddress ?? '').isNotEmpty ? destinationAddress! : 'Destino del viaje';

    String title = 'Nueva solicitud de viaje';
    if (priceInfo != null && priceInfo.isNotEmpty) {
      title = 'Nueva solicitud - \$$priceInfo';
    }

    final parts = <String>[];
    parts.add('Desde: $safeOrigin');
    parts.add('Hasta: $safeDest');
      if (etaMinutes != null && distanceKm != null) {
      final m = etaMinutes.round();
      final dist =
          distanceKm < 1 ? '${(distanceKm * 1000).round()} m' : '${distanceKm.toStringAsFixed(1)} km';
      parts.add('~$m min / $dist');
    }
    final body = parts.join(' · ');
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Notificaciones de nuevas solicitudes de viaje.',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: android);
    final id = tripId.hashCode.abs() % 2147483647;
    await _plugin.show(
      id,
      title,
      body,
      details,
      payload: tripId,
    );
    debugPrint('[DriverNotification] Mostrada oferta tripId=$tripId');
  }
}
