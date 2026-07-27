import 'package:flutter/foundation.dart';

/// Entorno de compilación de la app conductor.
///
/// Override explícito: `--dart-define=TEXI_APP_ENV=dev|prod`
///
/// Matriz dev/prod (credenciales separadas, solo reemplazar en prod):
/// `.cursor/functional-modules/driver-operations/driver-app-credentials-matrix.md`
enum DriverAppEnvironmentKind {
  dev,
  prod,
}

/// Configuración compile-time dev/prod (URLs, flags de QA y registro).
class DriverAppEnvironment {
  DriverAppEnvironment._();

  static const String _appEnvRaw = String.fromEnvironment(
    'TEXI_APP_ENV',
    defaultValue: '',
  );

  static const String _backendUrlRaw = String.fromEnvironment(
    'TEXI_BACKEND_BASE_URL',
    defaultValue: '',
  );

  static const bool internalToolsDartDefine = bool.fromEnvironment(
    'DRIVER_INTERNAL_TOOLS',
    defaultValue: false,
  );

  static const bool _registrationAllowGalleryDefine = bool.fromEnvironment(
    'DRIVER_REGISTRATION_ALLOW_GALLERY',
    defaultValue: false,
  );

  /// Host pre-prod por defecto (solo entorno dev).
  static const String devBackendDefault = 'https://api.dev.taxitexi.com';

  /// API prod canónica (REST + Socket.IO). No confundir con `api-prod` (panel admin).
  static const String prodBackendCanonical =
      'https://api-prodtx.taxitexi.com';

  static DriverAppEnvironmentKind get kind {
    final normalized = _appEnvRaw.trim().toLowerCase();
    if (normalized == 'prod' || normalized == 'production') {
      return DriverAppEnvironmentKind.prod;
    }
    if (normalized == 'dev' || normalized == 'development') {
      return DriverAppEnvironmentKind.dev;
    }
    return kDebugMode
        ? DriverAppEnvironmentKind.dev
        : DriverAppEnvironmentKind.prod;
  }

  static bool get isDev => kind == DriverAppEnvironmentKind.dev;

  static bool get isProd => kind == DriverAppEnvironmentKind.prod;

  /// Origen HTTPS del backend (REST + Socket.IO). En prod es obligatorio
  /// `--dart-define=TEXI_BACKEND_BASE_URL=...` (no default a api.dev).
  static String get backendBaseUrl {
    final override = _backendUrlRaw.trim();
    if (override.isNotEmpty) {
      final resolved = _resolveProdBackendOverride(override);
      _assertValidBackendUrl(resolved);
      return resolved;
    }
    if (isDev) {
      return devBackendDefault;
    }
    throw StateError(
      'Falta TEXI_BACKEND_BASE_URL en build prod. '
      'Usa --dart-define=TEXI_BACKEND_BASE_URL=https://HOST_API_PROD',
    );
  }

  /// Herramientas internas visibles (menú QA, rutas labs).
  static bool get showsInternalToolsByDefault => internalToolsDartDefine || isDev;

  /// KYC: galería deshabilitada en prod aunque el dart-define la habilite.
  static bool get registrationAllowGallery =>
      isDev && _registrationAllowGalleryDefine;

  static void _assertValidBackendUrl(String url) {
    final parsed = Uri.tryParse(url);
    if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) {
      throw StateError('TEXI_BACKEND_BASE_URL inválida: $url');
    }
    if (parsed.scheme != 'https' && !(isDev && parsed.scheme == 'http')) {
      throw StateError(
        'TEXI_BACKEND_BASE_URL debe usar HTTPS (HTTP solo permitido en dev): $url',
      );
    }
    if (isProd && _looksLikeDevHost(parsed.host)) {
      throw StateError(
        'Build prod no puede apuntar a host de desarrollo: $url',
      );
    }
    if (isProd && _isInvalidProdBackendHost(parsed.host)) {
      throw StateError(
        'Host no válido para API backend en prod: $url. '
        'Usa $prodBackendCanonical',
      );
    }
  }

  /// En prod, corrige hosts legacy compilados por error al canónico `api-prodtx`.
  static String _resolveProdBackendOverride(String url) {
    final trimmed = url.trim();
    final parsed = Uri.tryParse(trimmed);
    if (parsed == null || parsed.host.isEmpty) return trimmed;
    if (isProd && _isInvalidProdBackendHost(parsed.host)) {
      return prodBackendCanonical;
    }
    return trimmed;
  }

  /// Rechaza panel admin y hosts prod con punto (convención descartada).
  static bool _isInvalidProdBackendHost(String host) {
    final h = host.toLowerCase();
    if (h == 'api-prod.taxitexi.com') return true;
    return h.startsWith('api.prod');
  }

  static bool _looksLikeDevHost(String host) {
    final h = host.toLowerCase();
    return h.contains('api.dev.') ||
        h.contains('.dev.') ||
        h.contains('localhost') ||
        h.contains('127.0.0.1') ||
        h.endsWith('.local');
  }
}
