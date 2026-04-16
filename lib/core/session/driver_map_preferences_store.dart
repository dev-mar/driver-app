import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverMapPreferencesStore {
  DriverMapPreferencesStore._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'driver_token';
  static const String _globalNamespace = 'global';
  static const List<String> _baseKeys = [
    'driver.map.lightweight_mode',
    'driver.map.show_toll_refs',
    'driver.map.show_signal_refs',
    'driver.map.reference_confidence',
    'driver.map.follow_navigation_camera',
  ];

  static String keyFor(String baseKey, String namespace) => '$baseKey.$namespace';

  static Future<String> resolveNamespaceFromCurrentSession() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token == null || token.isEmpty) return _globalNamespace;
      final identity = _extractIdentityFromJwt(token);
      if (identity == null || identity.isEmpty) return _globalNamespace;
      return identity;
    } catch (_) {
      return _globalNamespace;
    }
  }

  static Future<void> clearMapPreferencesForCurrentSession() async {
    final namespace = await resolveNamespaceFromCurrentSession();
    await clearMapPreferencesForNamespace(namespace, includeGlobal: true);
  }

  static Future<void> clearMapPreferencesForNamespace(
    String namespace, {
    bool includeGlobal = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final namespaces = <String>{namespace};
    if (includeGlobal) namespaces.add(_globalNamespace);

    for (final base in _baseKeys) {
      // Limpia keys legacy sin namespace (versiones anteriores).
      await prefs.remove(base);
      for (final ns in namespaces) {
        await prefs.remove(keyFor(base, ns));
      }
    }
  }

  static String? _extractIdentityFromJwt(String token) {
    final parts = token.split('.');
    if (parts.length < 2) return null;
    try {
      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final data = jsonDecode(decoded);
      if (data is! Map<String, dynamic>) return null;
      final raw = data['identity_user_id'] ??
          data['identityUserId'] ??
          data['uuid'] ??
          data['sub'] ??
          data['userId'];
      final parsed = raw?.toString().trim();
      if (parsed == null || parsed.isEmpty) return null;
      final safe = parsed.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      return safe.isEmpty ? null : safe;
    } catch (_) {
      return null;
    }
  }
}
