import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/config/driver_backend_config.dart';
import '../../core/notifications/driver_push_token_service.dart';
import 'driver_registration_models.dart';

class DriverRegistrationException implements Exception {
  DriverRegistrationException(this.message, {this.details});
  final String message;
  final String? details;

  @override
  String toString() => details != null ? '$message ($details)' : message;
}

/// Acceso HTTP a geo + registro de conductor + vehículo (con token tras login).
class DriverRegistrationRepository {
  DriverRegistrationRepository({
    Dio? geoDio,
    Dio? usersDio,
    FlutterSecureStorage? storage,
  })  : _geoDio = geoDio ??
            Dio(
              BaseOptions(
                baseUrl: DriverBackendConfig.baseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                headers: const {
                  'Accept': 'application/json',
                },
              ),
            ),
        _usersDio = usersDio ??
            Dio(
              BaseOptions(
                baseUrl: DriverBackendConfig.baseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 60),
                headers: const {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ),
        _storage = storage ?? const FlutterSecureStorage();

  final Dio _geoDio;
  final Dio _usersDio;
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'driver_token';

  Future<List<GeoCountry>> fetchCountries() async {
    final response = await _geoDio.get<Map<String, dynamic>>(
      '/api/v2/geo/full-tree',
    );
    final data = response.data;
    if (data == null) throw DriverRegistrationException('Respuesta vacía (países)');
    if (data['code']?.toString() != 'OK') {
      throw DriverRegistrationException(
        data['message']?.toString() ?? 'Error al cargar países',
      );
    }
    final list = data['data'];
    if (list is! List) {
      throw DriverRegistrationException('Formato inválido de países');
    }
    final out = <GeoCountry>[];
    for (final e in list) {
      if (e is Map<String, dynamic>) {
        final c = GeoCountry.fromJson(e);
        if (c != null) out.add(c);
      }
    }
    out.sort((a, b) => a.name.compareTo(b.name));
    return out;
  }

  /// Categorías de licencia por país (`countryId` alineado al catálogo geo / `reference.countries` en backend).
  Future<List<DriverLicenseCategory>> fetchLicenseCategories({required int countryId}) async {
    final response = await _geoDio.get<Map<String, dynamic>>(
      '/api/v2/geo/license-categories',
      queryParameters: <String, dynamic>{'countryId': countryId},
    );
    final data = response.data;
    if (data == null) {
      throw DriverRegistrationException('Respuesta vacía (categorías de licencia)');
    }
    if (data['code']?.toString() != 'OK') {
      throw DriverRegistrationException(
        data['message']?.toString() ?? 'Error al cargar categorías de licencia',
      );
    }
    final list = data['data'];
    if (list is! List) {
      throw DriverRegistrationException('Formato inválido de categorías de licencia');
    }
    final out = <DriverLicenseCategory>[];
    for (final e in list) {
      if (e is Map<String, dynamic>) {
        final c = DriverLicenseCategory.fromApiJson(e);
        if (c != null) out.add(c);
      }
    }
    return out;
  }

  /// [countryName] debe coincidir con el `name` del país (ej. "Bolivia").
  Future<List<GeoDepartment>> fetchDepartmentsForCountry(String countryName) async {
    final path = Uri.encodeComponent(countryName);
    final response = await _geoDio.get<Map<String, dynamic>>(
      '/api/v2/geo/full-tree/$path',
    );
    final data = response.data;
    if (data == null) {
      throw DriverRegistrationException('Respuesta vacía (departamentos)');
    }
    if (data['code']?.toString() != 'OK') {
      throw DriverRegistrationException(
        data['message']?.toString() ?? 'Error al cargar departamentos',
      );
    }
    final payload = data['data'];
    if (payload is! Map) {
      throw DriverRegistrationException('Formato inválido de departamentos');
    }
    final depts = payload['departments'];
    if (depts is! List) {
      throw DriverRegistrationException('Sin lista de departamentos');
    }
    final out = <GeoDepartment>[];
    for (final e in depts) {
      if (e is Map<String, dynamic>) {
        final d = GeoDepartment.fromJson(e);
        if (d != null) out.add(d);
      }
    }
    out.sort((a, b) => a.name.compareTo(b.name));
    return out;
  }

  Future<bool> _tryPersistTokenFromResponse(Map<String, dynamic> data) async {
    final inner = data['data'];
    if (inner is! Map) return false;
    final m = Map<String, dynamic>.from(inner);
    const keys = ['token', 'access_token', 'accessToken', 'driver_token', 'bearer'];
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().isNotEmpty) {
        await _storage.write(key: _tokenKey, value: v.toString());
        DriverPushTokenService.instance.syncTokenIfPossible();
        return true;
      }
    }
    return false;
  }

  /// Si ya hay token (p. ej. guardado por personal-info o login).
  Future<bool> hasDriverToken() async {
    final t = await _storage.read(key: _tokenKey);
    return t != null && t.isNotEmpty;
  }

  Future<String> _requireBearerToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) {
      throw DriverRegistrationException(
        'Sesión no disponible. Completá el paso anterior o reabrí el registro.',
      );
    }
    return token;
  }

  String _extractErrorMessage(dynamic data) {
    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    if (data is! Map) return 'Error del servidor';
    final msg = data['message']?.toString();
    final nestedData = data['data'];
    if (nestedData is Map) {
      final innerMessage = nestedData['message']?.toString();
      if (innerMessage != null && innerMessage.isNotEmpty) return innerMessage;
      final innerError = nestedData['error'];
      if (innerError is String && innerError.isNotEmpty) return innerError;
      if (innerError is Map) {
        final em = innerError['message']?.toString();
        if (em != null && em.isNotEmpty) return em;
      }
    }
    final err = data['error'];
    if (err is String && err.isNotEmpty) {
      return msg != null && msg.isNotEmpty ? msg : err;
    }
    if (err is Map) {
      final d = err['details']?.toString();
      if (d != null && d.isNotEmpty) return '$msg\n$d';
      final em = err['message']?.toString();
      if (em != null && em.isNotEmpty) return em;
      final ec = err['code']?.toString();
      if (ec != null && ec.isNotEmpty && msg != null && msg.isNotEmpty) {
        return '$msg ($ec)';
      }
    }
    final code = data['code']?.toString();
    if (code != null && code.isNotEmpty && msg != null && msg.isNotEmpty) {
      return '$msg ($code)';
    }
    return msg ?? 'Error del servidor';
  }

  /// Mensaje útil cuando el cuerpo no es JSON o viene vacío (p. ej. 500 HTML).
  String _messageFromDioException(DioException e) {
    final code = e.response?.statusCode;
    final body = e.response?.data;
    if (code == 413) {
      final s = body is String ? body.toLowerCase() : '';
      // Infra actual: tope principal en Express body JSON (API_V2_JSON_LIMIT). Solo si el cuerpo
      // es HTML/texto típico de proxy/CDN mencionamos capa intermedia (no nginx por defecto).
      final hintProxy = s.contains('cloudflare') ||
              s.contains('nginx') ||
              s.contains('request entity too large')
          ? ' Si el HTML/texto del error menciona un proxy o CDN, el límite puede estar ahí.'
          : '';
      return 'Las fotos o el envío superan el límite permitido (HTTP 413). '
          'Probá imágenes más livianas. En nuestro backend el JSON suele ir limitado por '
          'API_V2_JSON_LIMIT (Express); con subida por S3 (URL firmada) el tope es otro.$hintProxy';
    }
    final fromJson = _extractErrorMessage(body);
    if (fromJson != 'Error del servidor') return fromJson;
    final type = e.type.name;
    final buf = StringBuffer('Error del servidor');
    if (code != null) buf.write(' (HTTP $code)');
    if (e.message != null && e.message!.isNotEmpty) {
      buf.write(': ${e.message}');
    } else {
      buf.write(' ($type)');
    }
    return buf.toString();
  }

  void _logDioIfDebug(String label, DioException e) {
    if (!kDebugMode) return;
    debugPrint('[DriverRegistration] $label DioException type=${e.type} '
        'status=${e.response?.statusCode} uri=${e.requestOptions.uri}');
    debugPrint('[DriverRegistration] response data: ${e.response?.data}');
  }

  Future<({String uuid, bool tokenSaved})> submitPersonalInfo(Map<String, dynamic> body) async {
    try {
      final response = await _usersDio.post<Map<String, dynamic>>(
        '/api/v2/driver/registration/personal-info',
        data: body,
      );
      final data = response.data;
      if (data == null) throw DriverRegistrationException('Respuesta vacía');
      if (data['success'] != true) {
        throw DriverRegistrationException(_extractErrorMessage(data));
      }
      final inner = data['data'];
      if (inner is! Map) {
        throw DriverRegistrationException('Respuesta sin data');
      }
      final uuid = inner['uuid']?.toString();
      if (uuid == null || uuid.isEmpty) {
        throw DriverRegistrationException('No se recibió uuid del usuario');
      }
      final tokenSaved = await _tryPersistTokenFromResponse(data);
      return (uuid: uuid, tokenSaved: tokenSaved);
    } on DioException catch (e) {
      final d = e.response?.data;
      throw DriverRegistrationException(_extractErrorMessage(d));
    }
  }

  /// Devuelve si en la respuesta vino un token guardado (sesión para vehículo).
  Future<bool> submitDocumentInfo(Map<String, dynamic> body) async {
    try {
      final bearer = await _requireBearerToken();
      final uuid = body['uuid']?.toString();
      final docType = body['document_type'];
      final idempotencyKey = ( uuid != null &&
              uuid.isNotEmpty &&
              docType != null)
          ? 'app-doc-$uuid-$docType'
          : null;
      final headers = <String, dynamic>{
        'Authorization': 'Bearer $bearer',
        ...? (idempotencyKey != null
            ? <String, dynamic>{'Idempotency-Key': idempotencyKey}
            : null),
      };
      final response = await _usersDio.post<Map<String, dynamic>>(
        '/api/v2/driver/documents',
        data: body,
        options: Options(headers: headers),
      );
      final data = response.data;
      if (data == null) throw DriverRegistrationException('Respuesta vacía');
      if (data['success'] != true) {
        throw DriverRegistrationException(_extractErrorMessage(data));
      }
      return _tryPersistTokenFromResponse(data);
    } on DioException catch (e) {
      _logDioIfDebug('submitDocumentInfo', e);
      throw DriverRegistrationException(_messageFromDioException(e));
    }
  }

  /// Activa / actualiza estado del usuario para permitir login tras documentación (licencia).
  /// Debe llamarse **antes** de `POST /api/v2/auth/login` en el flujo de registro.
  Future<void> driverUpdateUserStatus({required String uuid}) async {
    try {
      final bearer = await _requireBearerToken();
      final response = await _usersDio.put<Map<String, dynamic>>(
        '/api/v2/driver/registration/activate',
        data: <String, dynamic>{'uuid': uuid},
        options: Options(
          headers: <String, dynamic>{'Authorization': 'Bearer $bearer'},
        ),
      );
      final data = response.data;
      if (data == null) throw DriverRegistrationException('Respuesta vacía');
      if (data['success'] != true) {
        throw DriverRegistrationException(_extractErrorMessage(data));
      }
    } on DioException catch (e) {
      _logDioIfDebug('driverUpdateUserStatus', e);
      throw DriverRegistrationException(_messageFromDioException(e));
    }
  }

  /// Estado para reanudar registro (misma fuente que la app usa al cerrarse a mitad de flujo).
  Future<DriverRegistrationStatusDto> fetchRegistrationStatus({String? uuid}) async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) {
      throw DriverRegistrationException('Sesión no disponible.');
    }
    try {
      final response = await _usersDio.get<Map<String, dynamic>>(
        '/api/v2/driver/registration',
        queryParameters: (uuid != null && uuid.isNotEmpty) ? <String, dynamic>{'uuid': uuid} : null,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      final data = response.data;
      if (data == null) throw DriverRegistrationException('Respuesta vacía (estado registro)');
      if (data['success'] != true) {
        throw DriverRegistrationException(_extractErrorMessage(data));
      }
      final raw = data['data'];
      if (raw is! Map) {
        throw DriverRegistrationException('Respuesta sin data (estado registro)');
      }
      return DriverRegistrationStatusDto.fromJson(Map<String, dynamic>.from(raw));
    } on DioException catch (e) {
      _logDioIfDebug('fetchRegistrationStatus', e);
      throw DriverRegistrationException(_messageFromDioException(e));
    }
  }

  /// Catálogo canónico (`vehicle_type` / `category` / servicios / marca-modelo). Requiere Bearer.
  /// Origen: `GET /api/v2/vehicles/catalog`.
  Future<VehicleCatalog> fetchVehicleCatalog() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) {
      throw DriverRegistrationException('Sesión no disponible. Inicia sesión de nuevo.');
    }
    try {
      final response = await _usersDio.get<Map<String, dynamic>>(
        '/api/v2/vehicles/catalog',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      final data = response.data;
      if (data == null) throw DriverRegistrationException('Respuesta vacía (catálogo vehículo)');
      if (data['success'] != true) {
        throw DriverRegistrationException(_extractErrorMessage(data));
      }
      final raw = data['data'];
      if (raw is! Map) {
        throw DriverRegistrationException('Respuesta sin data (catálogo vehículo)');
      }
      final inner = Map<String, dynamic>.from(raw);
      final catalog = VehicleCatalog.fromJson(inner);
      if (catalog == null) {
        throw DriverRegistrationException('Formato inválido del catálogo de vehículos');
      }
      return catalog;
    } on DioException catch (e) {
      _logDioIfDebug('fetchVehicleCatalog', e);
      throw DriverRegistrationException(_messageFromDioException(e));
    }
  }

  /// Registro de vehículo canónico. Origen: `POST /api/v2/vehicles`.
  /// Devuelve el UUID del activo (mismo valor en `public.vehicles.uuid` para fotos).
  Future<String> submitVehicle(Map<String, dynamic> body) async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) {
      throw DriverRegistrationException('Sesión no disponible. Inicia sesión de nuevo.');
    }
    try {
      final response = await _usersDio.post<Map<String, dynamic>>(
        '/api/v2/vehicles',
        data: body,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      final data = response.data;
      if (data == null) throw DriverRegistrationException('Respuesta vacía');
      if (data['success'] != true) {
        throw DriverRegistrationException(_extractErrorMessage(data));
      }
      final inner = data['data'];
      if (inner is! Map) {
        throw DriverRegistrationException('Respuesta sin data (vehículo)');
      }
      final raw = Map<String, dynamic>.from(inner);
      final id =
          raw['vehicle_asset_id']?.toString() ?? raw['car_uuid']?.toString();
      if (id == null || id.isEmpty) {
        throw DriverRegistrationException('No se recibió vehicle_asset_id');
      }
      return id;
    } on DioException catch (e) {
      _logDioIfDebug('submitVehicle', e);
      throw DriverRegistrationException(_messageFromDioException(e));
    }
  }

  /// Fotos del vehículo: `POST /api/v2/vehicles/images` (presign: `/api/v2/vehicles/media/presign`).
  Future<void> submitVehicleImages(Map<String, dynamic> body) async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) {
      throw DriverRegistrationException('Sesión no disponible.');
    }
    try {
      final response = await _usersDio.post<Map<String, dynamic>>(
        '/api/v2/vehicles/images',
        data: body,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      final data = response.data;
      if (data == null) throw DriverRegistrationException('Respuesta vacía');
      if (data['success'] != true) {
        throw DriverRegistrationException(_extractErrorMessage(data));
      }
    } on DioException catch (e) {
      _logDioIfDebug('submitVehicleImages', e);
      throw DriverRegistrationException(_messageFromDioException(e));
    }
  }
}
