import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _deviceEmailChannel = MethodChannel('texi_driver/device_email');

/// Cuenta Google del dispositivo (selector nativo en Android).
/// En iOS no hay picker de cuentas: el campo usa Autofill del teclado.
Future<String?> pickDeviceAccountEmail() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    return null;
  }
  try {
    final raw = await _deviceEmailChannel.invokeMethod<String>('pickEmail');
    final email = raw?.trim();
    if (email == null || email.isEmpty || !email.contains('@')) return null;
    return email;
  } on PlatformException {
    return null;
  } on MissingPluginException {
    return null;
  }
}
