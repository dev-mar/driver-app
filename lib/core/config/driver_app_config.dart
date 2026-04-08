/// Configuración de la app conductor (mapas, etc.).
/// Configurar con:
/// `--dart-define=GOOGLE_MAPS_API_KEY=...`
class DriverAppConfig {
  DriverAppConfig._();

  static String get googleMapsApiKey {
    const key = String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');
    if (key.isEmpty) {
      throw StateError(
        'Falta GOOGLE_MAPS_API_KEY. Define --dart-define=GOOGLE_MAPS_API_KEY=...'
      );
    }
    return key;
  }
}
