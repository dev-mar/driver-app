/// Configuración de la app conductor (mapas, etc.).
/// Configurar con:
/// `--dart-define=GOOGLE_MAPS_API_KEY=...`
class DriverAppConfig {
  DriverAppConfig._();

  static const String _googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static bool get hasGoogleMapsApiKey => _googleMapsApiKey.isNotEmpty;

  static String? get googleMapsApiKeyOrNull =>
      _googleMapsApiKey.isEmpty ? null : _googleMapsApiKey;

  static String get googleMapsApiKey {
    final key = googleMapsApiKeyOrNull;
    if (key == null) {
      throw StateError(
        'Falta GOOGLE_MAPS_API_KEY. Define --dart-define=GOOGLE_MAPS_API_KEY=...'
      );
    }
    return key;
  }
}
