import 'driver_app_environment.dart';

/// Host único del despliegue `app_texi_WebSocket` (auth, geo, registro, perfiles, Socket.IO).
///
/// Override por entorno:
/// `--dart-define=TEXI_APP_ENV=dev|prod`
/// `--dart-define=TEXI_BACKEND_BASE_URL=https://api.dev.taxitexi.com`
class DriverBackendConfig {
  DriverBackendConfig._();

  /// `applicationId` Android (FCM / google-services.json). Dev flavor usa suffix `.dev`.
  static String get firebaseAndroidApplicationId => DriverAppEnvironment.isDev
      ? 'com.taxitexi.texi_driver_app.dev'
      : 'com.taxitexi.texi_driver_app';

  static String get baseUrl => DriverAppEnvironment.backendBaseUrl;
}
