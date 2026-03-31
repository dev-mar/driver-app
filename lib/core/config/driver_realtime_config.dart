import 'driver_backend_config.dart';

class DriverRealtimeConfig {
  DriverRealtimeConfig._();

  /// Mismo origen que REST (`TEXI_BACKEND_BASE_URL`).
  static String get socketUrl => DriverBackendConfig.baseUrl;

  /// Path de Socket.IO (contrato: `/socket.io/`).
  static const String socketPath = '/socket.io/';

  /// Intervalo en segundos para enviar ubicación (respaldo; el stream usa distanceFilter).
  static const int locationUpdateSeconds = 5;
}
