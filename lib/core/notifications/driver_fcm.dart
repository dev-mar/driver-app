import 'dart:async' show unawaited;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import 'driver_fcm_navigation.dart';
import 'driver_notification_service.dart';
import 'driver_push_token_service.dart';

@pragma('vm:entry-point')
Future<void> driverFirebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (message.notification != null) {
    return;
  }
  await DriverNotificationService.showFcmDataOnlyMessage(message);
}

Future<void> setupDriverFirebaseMessaging() async {
  final messaging = FirebaseMessaging.instance;

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    unawaited(
      DriverNotificationService.instance.showFcmForegroundMessage(message),
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen(handleDriverFcmNotificationOpen);

  messaging.onTokenRefresh.listen((_) {
    unawaited(DriverPushTokenService.instance.syncTokenIfPossible());
  });
}
