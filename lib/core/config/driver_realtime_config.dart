class DriverRealtimeConfig {
  DriverRealtimeConfig._();

  /// URL base del backend de Socket.IO para conductor.
  /// Debe ser la MISMA que usa el pasajero para websockets.
  static const String socketUrl =
      'https://bk-websockets-pre-prod.taxitexi.com';

  /// Path de Socket.IO (según contrato: solo '/socket.io/', sin /api/v1).
  static const String socketPath = '/socket.io/';

  /// Intervalo en segundos para enviar ubicación (respaldo; el stream usa distanceFilter).
  static const int locationUpdateSeconds = 5;
}

