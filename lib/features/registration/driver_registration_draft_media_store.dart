import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DriverRegistrationDraftMediaStore {
  DriverRegistrationDraftMediaStore._();

  static Future<Directory> _draftDir() async {
    final base = await getTemporaryDirectory();
    final dir = Directory('${base.path}${Platform.pathSeparator}driver_registration_draft');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<String?> persistBase64({
    required String key,
    required String? base64Image,
    String? existingPath,
  }) async {
    if (base64Image == null || base64Image.isEmpty) return null;
    final dir = await _draftDir();
    final path = existingPath ??
        '${dir.path}${Platform.pathSeparator}$key.b64';
    final file = File(path);
    await file.writeAsString(base64Image, flush: true);
    return path;
  }

  static Future<String?> restoreBase64(String? path) async {
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    if (!await file.exists()) return null;
    final raw = await file.readAsString();
    if (raw.isEmpty) return null;
    // Validación mínima: debe decodificar.
    try {
      base64Decode(raw);
      return raw;
    } catch (_) {
      return null;
    }
  }

  static Future<void> deletePath(String? path) async {
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> clearAll() async {
    final dir = await _draftDir();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
