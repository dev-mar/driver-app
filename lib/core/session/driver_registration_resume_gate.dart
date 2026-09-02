import '../../features/session/driver_operational_profile.dart';

/// Evita llamadas repetidas a [GET /api/v2/driver/me-profile] en redirects de GoRouter.
class DriverRegistrationResumeGate {
  DriverRegistrationResumeGate._();

  static const wizardLocation = '/register?resumeAfterLogin=1';
  static const vehicleFormLocation = '/register?addVehicleOnly=1';

  static DateTime? _until;
  static DriverOperationalProfile? _profile;
  static bool _fetchFailed = false;

  /// Si el conductor cierra el alta de vehículo, no reabrirla hasta un login nuevo.
  static bool _skipVehicleFormThisSession = false;

  static void invalidate({bool resetVehicleFormSkip = false}) {
    _until = null;
    _profile = null;
    _fetchFailed = false;
    DriverOperationalProfile.invalidateCaches();
    if (resetVehicleFormSkip) {
      _skipVehicleFormThisSession = false;
    }
  }

  static void skipVehicleFormThisSession() {
    _skipVehicleFormThisSession = true;
  }

  static Future<DriverOperationalProfile?> _loadProfile() async {
    final now = DateTime.now();
    if (_until != null && now.isBefore(_until!)) {
      if (_fetchFailed) return null;
      if (_profile != null) return _profile;
    }
    try {
      _profile = await DriverOperationalProfile.fetch();
      _fetchFailed = false;
      _until = now.add(const Duration(seconds: 15));
      return _profile;
    } catch (_) {
      _profile = null;
      _fetchFailed = true;
      _until = now.add(const Duration(seconds: 5));
      return null;
    }
  }

  static bool _wizardNeeded(DriverOperationalProfile p) {
    var need = p.needsResumeRegistration;
    // Identidad/licencia/activación: forzar asistente. Vehículo (paso ≥4) va por addVehicleOnly.
    final s = p.suggestedClientStep;
    if (need && s != null && s >= 4) {
      need = false;
    }
    return need;
  }

  /// `true` si el conductor debe completar documentos/activación antes de operar.
  static Future<bool> needsResume() async {
    final p = await _loadProfile();
    if (p == null) return false;
    return _wizardNeeded(p);
  }

  /// Mismo criterio que el banner del home: cuenta activa y cero vehículos vivos.
  static Future<bool> needsVehicleFormAutoOpen() async {
    if (_skipVehicleFormThisSession) return false;
    final p = await _loadProfile();
    if (p == null) return false;
    if (_wizardNeeded(p)) return false;
    return p.needsVehicleRegistration;
  }

  /// Destino tras login / sesión restaurada.
  /// Identidad/licencia pendientes → wizard. Si solo falta vehículo → home;
  /// el formulario se abre desde el home (loading + me-profile), no en este redirect.
  static Future<String> nextPostAuthLocation() async {
    if (await needsResume()) return wizardLocation;
    return '/home';
  }

  /// Redirect desde `/home` (u otras) hacia el alta de documentos. No pisa `/register`
  /// ni abre el formulario de vehículo aquí (reusar `/register` dejaba el resumen).
  static Future<String?> registerRedirectFrom(String location) async {
    if (location.startsWith('/register')) return null;
    if (await needsResume()) return wizardLocation;
    return null;
  }
}
