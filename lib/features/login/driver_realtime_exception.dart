/// Excepción de control de flujo en realtime (códigos estables → l10n en UI).
class DriverRealtimeException implements Exception {
  const DriverRealtimeException(this.code);

  final String code;

  @override
  String toString() => 'DriverRealtimeException($code)';
}
