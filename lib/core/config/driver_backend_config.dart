/// Host único del despliegue `app_texi_WebSocket` (auth, geo, registro, perfiles, Socket.IO).
///
/// Mismo valor por defecto que la app pasajero. Override local:
/// `flutter run --dart-define=TEXI_BACKEND_BASE_URL=https://bk-websockets-pre-prod.taxitexi.com`
class DriverBackendConfig {
  DriverBackendConfig._();

  /// `applicationId` Android (FCM / google-services.json).
  static const String firebaseAndroidApplicationId =
      'com.taxitexi.texi_driver_app';

  static const String baseUrl = String.fromEnvironment(
    'TEXI_BACKEND_BASE_URL',
    defaultValue: 'https://bk-websockets-pre-prod.taxitexi.com',
  );
}
