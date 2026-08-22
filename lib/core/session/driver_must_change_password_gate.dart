import '../storage/driver_secure_storage.dart';

/// Tras un reset de **soporte**, el conductor debe crear su propia contraseña
/// antes de home / registro.
///
/// Solo lee storage local. No llama red ni `me-profile`: el login ya persiste
/// el flag del payload. Si no hay clave local (sesión previa a este feature),
/// se asume que no hay que forzar — no se toca online/offline ni el home.
class DriverMustChangePasswordGate {
  DriverMustChangePasswordGate._();

  static const String storageKey = 'driver_must_change_password';

  static bool flagTrue(dynamic value) {
    return value == true ||
        value == 'true' ||
        value == 1 ||
        value == '1';
  }

  static Future<bool?> readLocal() async {
    final raw = await DriverSecureStorage.read(storageKey);
    if (raw == null || raw.isEmpty) return null;
    return flagTrue(raw);
  }

  static Future<void> setRequired(bool value) async {
    await DriverSecureStorage.write(storageKey, value ? '1' : '0');
  }

  static Future<void> persistFromPayload(Map<String, dynamic>? payload) async {
    if (payload == null) return;
    await setRequired(flagTrue(payload['must_change_password']));
  }

  static Future<void> clear() => setRequired(false);

  /// `true` solo si el último login (o reset de staff) dejó el flag local.
  /// Sin clave o con `0` → no bloquea. Nunca espera red.
  static Future<bool> needsChange() async {
    return await readLocal() == true;
  }
}
