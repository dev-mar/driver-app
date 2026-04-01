import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../router/app_router.dart';

/// Contador que incrementa cuando el usuario abre la app desde un tap en FCM
/// (`event=trip_offer`). [DriverHomeScreen] muestra un SnackBar de ayuda.
final ValueNotifier<int> driverFcmTripOfferOpenBump = ValueNotifier<int>(0);

/// Llamar desde [FirebaseMessaging.onMessageOpenedApp] y [getInitialMessage].
void handleDriverFcmNotificationOpen(RemoteMessage message) {
  final event = message.data['event']?.toString();
  if (event != 'trip_offer') return;
  driverFcmTripOfferOpenBump.value = driverFcmTripOfferOpenBump.value + 1;
  try {
    AppRouter.router.go('/home');
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('[DriverFCM] router.go(/home) error: $e $st');
    }
  }
}
