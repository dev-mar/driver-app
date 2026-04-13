import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../router/app_router.dart';

/// Contador que incrementa cuando el usuario abre la app desde un tap en FCM
/// (`event=trip_offer`). [DriverHomeScreen] muestra un SnackBar y fusiona la oferta.
final ValueNotifier<int> driverFcmTripOfferOpenBump = ValueNotifier<int>(0);

/// Datos de la última notificación de oferta abierta (se consume una vez en Home).
Map<String, String>? _pendingTripOfferFromNotification;

/// Obtiene y borra el payload guardado al abrir desde la notificación.
Map<String, String>? takePendingTripOfferFromNotification() {
  final m = _pendingTripOfferFromNotification;
  _pendingTripOfferFromNotification = null;
  return m;
}

/// Llamar desde [FirebaseMessaging.onMessageOpenedApp] y [getInitialMessage].
void handleDriverFcmNotificationOpen(RemoteMessage message) {
  final event = message.data['event']?.toString();
  if (event != 'trip_offer') return;
  final tid = message.data['tripId']?.toString().trim();
  if (tid != null && tid.isNotEmpty) {
    _pendingTripOfferFromNotification = {
      for (final e in message.data.entries)
        e.key: e.value?.toString() ?? '',
    };
  }
  driverFcmTripOfferOpenBump.value = driverFcmTripOfferOpenBump.value + 1;
  try {
    AppRouter.router.go('/home');
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('[DriverFCM] router.go(/home) error: $e $st');
    }
  }
}
