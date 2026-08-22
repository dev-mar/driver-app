import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/driver_app_environment.dart';
import '../storage/driver_secure_storage.dart';

/// Pantallas internas (QA / soporte) visibles solo para números autorizados.
///
/// Criterio actual: el número nacional comienza con [qaNationalPrefix] (p. ej. Bolivia
/// +591 → dígitos `591` + `10011…`).
class DriverInternalToolsGate {
  DriverInternalToolsGate._();

  static const String storageKeyLoginPhone = 'driver_login_phone_e164';

  /// Prefijo de 5 dígitos del número local para usuarios que ven herramientas internas.
  static const String qaNationalPrefix = '10011';

  static bool phoneAllowsInternalTools(String? e164OrDigits) {
    if (e164OrDigits == null || e164OrDigits.isEmpty) return false;
    final d = e164OrDigits.replaceAll(RegExp(r'\D'), '');
    if (d.length < 8) return false;
    if (d.startsWith('591') && d.length > 3) {
      return d.substring(3).startsWith(qaNationalPrefix);
    }
    return d.startsWith(qaNationalPrefix);
  }

  static Future<bool> asyncAllowsInternalTools() async {
    final phone = await DriverSecureStorage.read(storageKeyLoginPhone);
    return phoneAllowsInternalTools(phone);
  }

  /// Ruta `/registered-images` y entradas de menú QA.
  static Future<bool> asyncAllowsInternalToolsRoute() async {
    if (DriverAppEnvironment.showsInternalToolsByDefault) return true;
    return asyncAllowsInternalTools();
  }
}

/// `true` si el build o el teléfono guardado al login autorizan herramientas internas.
final driverInternalToolsVisibleProvider = FutureProvider<bool>((ref) async {
  return DriverInternalToolsGate.asyncAllowsInternalToolsRoute();
});
