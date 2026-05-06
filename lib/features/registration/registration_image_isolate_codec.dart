import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Codifica bytes JPEG ya comprimidos a **Base64 crudo** fuera del hilo UI.
///
/// `flutter_image_compress` y `ImagePicker` deben ejecutarse en el isolate principal
/// (plugins / platform channels). Solo la codificación Base64 (CPU puro) se delega
/// con [compute] para reducir picos de frame al cerrar el picker.
Future<String> encodeRegistrationJpegBytesToBase64(List<int> bytes) {
  return compute(_registrationJpegToBase64Worker, bytes);
}

/// Top-level: requisito de [compute].
String _registrationJpegToBase64Worker(List<int> bytes) => base64Encode(bytes);
