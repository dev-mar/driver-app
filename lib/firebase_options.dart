// Firebase Android por entorno (compile-time TEXI_APP_ENV).
// Debe coincidir con android/app/src/{dev|prod}/google-services.json.
//
// Dev:  texi-prod · com.taxitexi.texi_driver_app.dev
// Prod: prodtexiappgm · com.taxitexi.texi_driver_app

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'core/config/driver_app_environment.dart';

/// Configuración Firebase — app conductor.
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions: web no configurado para esta app.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return DriverAppEnvironment.isProd ? androidProd : androidDev;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions: añade GoogleService-Info.plist y flutterfire configure.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions: plataforma no soportada.',
        );
    }
  }

  /// Pre-prod / flavor dev (`src/dev/google-services.json`).
  static const FirebaseOptions androidDev = FirebaseOptions(
    apiKey: 'AIzaSyBjgqer8v1_GaXV6zzwl5UQhTMV9GUBSTs',
    appId: '1:935442837361:android:c68446c652c01a37df50d0',
    messagingSenderId: '935442837361',
    projectId: 'texi-prod',
    storageBucket: 'texi-prod.firebasestorage.app',
  );

  /// Play Store / flavor prod (`src/prod/google-services.json`).
  static const FirebaseOptions androidProd = FirebaseOptions(
    apiKey: 'AIzaSyC9tAzsQNcJOh91C5JlZxVXYmGW9j67WNk',
    appId: '1:464855616265:android:065bf042e1885d4ac6a1d8',
    messagingSenderId: '464855616265',
    projectId: 'prodtexiappgm',
    storageBucket: 'prodtexiappgm.firebasestorage.app',
  );
}
