import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Acceso serializado a Keystore / preferencias cifradas (Android release).
///
/// Varias instancias de [FlutterSecureStorage] en paralelo pueden bloquear o
/// devolver `BadPaddingException` / `BAD_DECRYPT` al leer. Si el cifrado local
/// está corrupto (backup de Play Store sin la clave), se resetea el almacén
/// para no bloquear registro ni login.
class DriverSecureStorage {
  DriverSecureStorage._();

  static const FlutterSecureStorage instance = FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
  );

  static Future<void>? _chain = Future<void>.value();
  static bool _resetting = false;

  static Future<T> run<T>(
    Future<T> Function(FlutterSecureStorage storage) operation,
  ) {
    final scheduled = _chain!.then((_) => operation(instance));
    _chain = scheduled.then((_) {}, onError: (_) {});
    return scheduled;
  }

  static bool isCorruptCryptoError(Object error) {
    final raw = error.toString().toLowerCase();
    return raw.contains('badpadding') ||
        raw.contains('bad_decrypt') ||
        raw.contains('bad decrypt') ||
        raw.contains('openssl_internal') ||
        (raw.contains('cipher') && raw.contains('dofinal'));
  }

  static Future<void> _resetIfCorrupt(Object error) async {
    if (_resetting || !isCorruptCryptoError(error)) return;
    _resetting = true;
    try {
      await instance.deleteAll();
    } catch (_) {}
    _resetting = false;
  }

  static Future<String?> read(
    String key, {
    Duration timeout = const Duration(seconds: 4),
  }) {
    return run((storage) async {
      try {
        return await storage.read(key: key).timeout(
              timeout,
              onTimeout: () => null,
            );
      } on Object catch (e) {
        await _resetIfCorrupt(e);
        try {
          return await storage.read(key: key).timeout(
                timeout,
                onTimeout: () => null,
              );
        } catch (_) {
          return null;
        }
      }
    });
  }

  static Future<void> write(String key, String value) {
    return run((storage) async {
      try {
        await storage.write(key: key, value: value);
      } on Object catch (e) {
        await _resetIfCorrupt(e);
        await storage.write(key: key, value: value);
      }
    });
  }

  static Future<void> delete(String key) {
    return run((storage) async {
      try {
        await storage.delete(key: key);
      } on Object catch (e) {
        await _resetIfCorrupt(e);
      }
    });
  }
}
