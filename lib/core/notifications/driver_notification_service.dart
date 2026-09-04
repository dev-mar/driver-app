import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../gen_l10n/app_localizations.dart';
import 'driver_fcm_navigation.dart';

/// Notificaciones locales del conductor: FCM en foreground / data-only en background
/// (ofertas las envía el backend por FCM; ver `sendDriverTripOffer`).
class DriverNotificationService {
  DriverNotificationService._();
  static final DriverNotificationService instance =
      DriverNotificationService._();

  static const String _channelId = 'texi_driver_trip_offers';
  static const String _channelName = 'Solicitudes de viaje';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  static const int _quietHoursStart = 22; // 22:00
  static const int _quietHoursEnd = 7; // 07:00
  static const String _chatVibrationLevel = 'medium'; // low | medium | high

  AppLocalizations _l10nForCurrentLocale() {
    final raw = WidgetsBinding.instance.platformDispatcher.locale;
    final code = raw.languageCode.toLowerCase();
    final Locale loc = (code == 'en' || code == 'es')
        ? raw
        : const Locale('es');
    return lookupAppLocalizations(loc);
  }

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
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _initialized = true;
    debugPrint('[DriverNotification] Inicializado.');
  }

  /// Android 13+: solicitar tras divulgación in-app (Google Play).
  Future<void> requestAndroidPostNotificationsPermission() async {
    if (!Platform.isAndroid) return;
    try {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.requestNotificationsPermission();
    } catch (_) {
      // Permiso ya concedido o no disponible en esta versión.
    }
  }

  static Future<void> showFcmDataOnlyMessage(RemoteMessage message) async {
    final inst = DriverNotificationService.instance;
    await inst.initialize();
    final event = message.data['event']?.toString();
    String? title;
    String? body;
    if (event == 'passenger_en_route') {
      final l10n = inst._l10nForCurrentLocale();
      title = l10n.driverNotifyPassengerEnRouteTitle;
      body = l10n.driverNotifyPassengerEnRouteBody;
    } else {
      title = message.data['title']?.toString().trim();
      body = message.data['body']?.toString().trim();
    }
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }
    final tripId =
        message.data['tripId']?.toString() ??
        message.data['trip_id']?.toString();
    await inst._showFcmRaw(
      title: title?.isNotEmpty == true ? title! : 'Texi Conductor',
      body: body ?? '',
      payload: tripId,
    );
  }

  Future<void> showPassengerEnRouteIfBackground({
    required bool isAppInForeground,
    required String tripId,
  }) async {
    if (isAppInForeground) return;
    await initialize();
    final l10n = _l10nForCurrentLocale();
    await _showFcmRaw(
      title: l10n.driverNotifyPassengerEnRouteTitle,
      body: l10n.driverNotifyPassengerEnRouteBody,
      payload: tripId,
    );
  }

  Future<void> showFcmForegroundMessage(RemoteMessage message) async {
    if (!_initialized) await initialize();
    final event = message.data['event']?.toString();
    if (event == 'passenger_en_route') {
      return;
    }
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
        message.data['tripId']?.toString() ??
        message.data['trip_id']?.toString();
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
    final details = NotificationDetails(android: android);
    final id = (payload ?? title + body).hashCode.abs() % 2147483647;
    await _plugin.show(id, title, body, details, payload: payload);
  }

  void _onNotificationTapped(NotificationResponse response) {
    handleDriverLocalNotificationTap(response.payload);
    if (response.payload != null && kDebugMode) {
      debugPrint('[DriverNotification] Tapped payload=${response.payload}');
    }
  }

  Future<void> showTripChatMessageIfBackground({
    required bool isAppInForeground,
    required String tripId,
    required String senderRole,
    required String messageText,
    bool notifyInForeground = false,
  }) async {
    await initialize();
    if (isAppInForeground && !notifyInForeground) return;
    final quiet = isWithinQuietHours();
    final android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Mensajes de chat del viaje activo.',
      importance: Importance.high,
      priority: Priority.high,
      playSound: !quiet,
      enableVibration: !quiet,
      vibrationPattern: quiet ? null : _chatVibrationPattern(),
    );
    final details = NotificationDetails(android: android);
    final l10n = _l10nForCurrentLocale();
    final who = senderRole == 'passenger'
        ? l10n.driverNotifyChatSenderPassenger
        : l10n.driverNotifyChatSenderDriver;
    await _plugin.show(
      (tripId + messageText).hashCode.abs() % 2147483647,
      l10n.driverNotifyChatTitle,
      l10n.driverNotifyChatBody(who, messageText),
      details,
      payload: 'chat:$tripId',
    );
  }

  static bool isWithinQuietHours([DateTime? now]) {
    final h = (now ?? DateTime.now()).hour;
    if (_quietHoursStart < _quietHoursEnd) {
      return h >= _quietHoursStart && h < _quietHoursEnd;
    }
    return h >= _quietHoursStart || h < _quietHoursEnd;
  }

  static bool shouldPlayForegroundChatAlert([DateTime? now]) {
    return !isWithinQuietHours(now);
  }

  static Int64List? _chatVibrationPattern() {
    switch (_chatVibrationLevel) {
      case 'low':
        return Int64List.fromList(<int>[0, 80, 80, 80]);
      case 'high':
        return Int64List.fromList(<int>[0, 180, 110, 180, 110, 180]);
      case 'medium':
      default:
        return Int64List.fromList(<int>[0, 120, 90, 120]);
    }
  }
}
