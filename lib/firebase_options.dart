// Generado a partir de android/app/google-services.json (proyecto texi-prod).
// Para iOS: añadir GoogleService-Info.plist y ejecutar `flutterfire configure`.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configuración Firebase — app conductor (Android: com.taxitexi.texi_driver_app).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions: web no configurado para esta app.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBjgqer8v1_GaXV6zzwl5UQhTMV9GUBSTs',
    appId: '1:935442837361:android:c68446c652c01a37df50d0',
    messagingSenderId: '935442837361',
    projectId: 'texi-prod',
    storageBucket: 'texi-prod.firebasestorage.app',
  );
}
