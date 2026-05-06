import '../../features/session/driver_operational_profile.dart';

/// Evita llamadas repetidas a [GET /api/v2/driver/me-profile] en redirects de GoRouter.
class DriverRegistrationResumeGate {
  DriverRegistrationResumeGate._();

  static DateTime? _until;
  static bool? _cached;

  static void invalidate() {
    _until = null;
    _cached = null;
  }

  /// `true` si el conductor debe completar el flujo de registro antes de operar como “listo”.
  static Future<bool> needsResume() async {
    final now = DateTime.now();
    if (_until != null && now.isBefore(_until!) && _cached != null) {
      return _cached!;
    }
    try {
      final p = await DriverOperationalProfile.fetch();
      var need = p.needsResumeRegistration;
      // Documentación: vehículo se completa desde el menú; no forzar /register si solo falta flota (paso ≥4).
      final s = p.suggestedClientStep;
      if (need && s != null && s >= 4) {
        need = false;
      }
      _cached = need;
      _until = now.add(const Duration(seconds: 15));
      return need;
    } catch (_) {
      _cached = false;
      _until = now.add(const Duration(seconds: 5));
      return false;
    }
  }
}
