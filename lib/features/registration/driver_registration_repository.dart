import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/config/driver_backend_config.dart';
import '../../core/device/driver_device_telemetry.dart';
import '../../core/media/driver_app_media_uploader.dart';
import '../../core/notifications/driver_push_token_service.dart';
import 'driver_registration_http_interceptor.dart';
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
            (Dio(
              BaseOptions(
                baseUrl: DriverBackendConfig.baseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 60),
                headers: const {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            )..interceptors.add(DriverRegistrationRequestIdInterceptor())),
        _storage = storage ?? const FlutterSecureStorage();

  final Dio _geoDio;
  final Dio _usersDio;
  final FlutterSecureStorage _storage;

  late final DriverAppMediaUploader _mediaUploader =
      DriverAppMediaUploader(apiDio: _usersDio);

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
        'Sesión no disponible. Completa el paso anterior o vuelve a abrir el registro.',
      );
    }
    return token;
  }

  /// Respuestas HTML típicas de nginx/Cloudflare u otros proxies (no JSON de nuestro API).
  static bool _looksLikeProxyHtmlError(String s) {
    final l = s.toLowerCase();
    return l.contains('<html') ||
        l.contains('<!doctype') ||
        l.contains('nginx/') ||
        l.contains('cloudflare') ||
        (l.contains('<title>') && l.contains('internal server error'));
  }

  /// Texto único para UI cuando hay HTML de infraestructura (no envelope JSON del API).
  /// Detalle técnico (nginx, límites Express, etc.) solo en logs de depuración.
  static const String _kUserMsgNonJsonInfrastructure =
      'No pudimos guardar los datos en este momento. Suele solucionarse intentando de nuevo '
      'más tarde, con buena señal Wi‑Fi o datos. Si te ocurre varias veces seguidas, '
      'escríbenos a soporte y cuéntanos a qué hora intentaste.';

  static String _friendlyHtmlProxyErrorHint() => _kUserMsgNonJsonInfrastructure;

  String _extractErrorMessage(dynamic data) {
    if (data is String) {
      final t = data.trim();
      if (t.isEmpty) return 'Error del servidor';
      if (_looksLikeProxyHtmlError(t)) return _friendlyHtmlProxyErrorHint();
      return t;
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
    if (body is String) {
      final t = body.trim();
      if (t.isNotEmpty && _looksLikeProxyHtmlError(t)) {
        return _friendlyHtmlProxyErrorHint();
      }
    }
    if (code == 413) {
      return 'El envío supera el límite permitido (HTTP 413). Prueba con fotos más livianas '
          'u otra red; si usas subida directa, el tope también puede estar en el proxy.';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      final path = e.requestOptions.uri.path;
      if (path.contains('vehicles/catalog')) {
        return 'Tiempo de espera al descargar el catálogo de vehículos (${e.type.name}). '
            'Intenta de nuevo con buena señal; si persiste, puede hacer falta ajustar el proxy '
            '(timeouts o buffers) hacia el backend.';
      }
      return 'Tiempo de espera al contactar el servidor (${e.type.name}). '
          'Reintenta con una buena conexión.';
    }
    final underlyingStr = e.error?.toString() ?? '';
    if (underlyingStr.contains('Connection closed while receiving') ||
        underlyingStr.contains('Connection closed before')) {
      final isCatalog = e.requestOptions.uri.path.contains('vehicles/catalog');
      return isCatalog
          ? 'El catálogo de vehículos no terminó de descargarse: el servidor o el proxy '
              'cerraron la conexión a mitad de la respuesta (JSON muy grande). '
              'Revisa en nginx: gzip para application/json, proxy_buffers / proxy_busy_buffers_size '
              'y proxy_read_timeout hacia Node. ($underlyingStr)'
          : 'La conexión se cerró antes de recibir la respuesta completa. ($underlyingStr)';
    }
    if (e.type == DioExceptionType.connectionError) {
      final hint = _shortUnderlyingError(e);
      return 'No se pudo establecer conexión con el servidor.${hint.isNotEmpty ? ' $hint' : ''}';
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
    if (e.type == DioExceptionType.unknown || code == null) {
      final hint = _shortUnderlyingError(e);
      if (hint.isNotEmpty) buf.write(' — $hint');
    }
    return buf.toString();
  }

  /// Causa subyacente (SocketException, TLS, JSON…) sin volcar stack completo.
  static String _shortUnderlyingError(DioException e) {
    final o = e.error;
    if (o == null) return '';
    if (o is FormatException) {
      final m = o.message;
      return m.length > 160 ? '${m.substring(0, 160)}…' : m;
    }
    if (o is IOException) {
      final m = o.toString();
      return m.length > 200 ? '${m.substring(0, 200)}…' : m;
    }
    final m = o.toString();
    if (m == 'null' || m.isEmpty) return '';
    return m.length > 200 ? '${m.substring(0, 200)}…' : m;
  }

  void _logDioIfDebug(String label, DioException e) {
    if (!kDebugMode) return;
    debugPrint('[DriverRegistration] $label DioException type=${e.type} '
        'status=${e.response?.statusCode} uri=${e.requestOptions.uri}');
    if (e.error != null) {
      debugPrint('[DriverRegistration] $label underlying: ${e.error}');
    }
    final data = e.response?.data;
    if (data == null) return;
    if (data is String) {
      final n = data.length;
      final preview = n > 400 ? '${data.substring(0, 400)}… ($n chars)' : data;
      debugPrint('[DriverRegistration] response body: $preview');
      if (_looksLikeProxyHtmlError(data)) {
        debugPrint(
          '[DriverRegistration] diag: cuerpo HTML de proxy/servidor (no JSON del API). '
          'Correlacionar rid con nginx error.log y logs Node; POST /api/v2 en Node usa '
          'API_V2_JSON_LIMIT (env); nginx suele usar client_max_body_size por location.',
        );
      }
      return;
    }
    debugPrint('[DriverRegistration] response data: $data');
  }

  /// Solo depuración: suma longitudes de valores `String` en el mapa (sin serializar JSON completo).
  static int _debugApproxMapStringChars(Map<String, dynamic> map) {
    var n = 0;
    for (final Object? v in map.values) {
      if (v is String) n += v.length;
    }
    return n;
  }

  Future<String?> uploadRegistrationImageViaPresign({
    required String uuid,
    required String purpose,
    required String base64Raw,
    String contentType = 'image/jpeg',
  }) async {
    final bearer = await _requireBearerToken();
    return _mediaUploader.uploadRegistrationImageViaPresign(
      bearerToken: bearer,
      uuid: uuid,
      purpose: purpose,
      base64Raw: base64Raw,
      contentType: contentType,
    );
  }

  Future<String?> uploadVehicleImageViaPresign({
    required String vehicleAssetId,
    required String purpose,
    required String base64Raw,
    String contentType = 'image/jpeg',
  }) async {
    final bearer = await _requireBearerToken();
    return _mediaUploader.uploadVehicleImageViaPresign(
      bearerToken: bearer,
      vehicleAssetId: vehicleAssetId,
      purpose: purpose,
      base64Raw: base64Raw,
      contentType: contentType,
    );
  }

  Future<({String uuid, bool tokenSaved, bool presignUploadAvailable})> submitPersonalInfo(
    Map<String, dynamic> body,
  ) async {
    try {
      final telemetry = await DriverDeviceTelemetry.toApiPayload();
      final payload = Map<String, dynamic>.from(body);
      telemetry.forEach((key, value) {
        payload.putIfAbsent(key, () => value);
      });
      final response = await _usersDio.post<Map<String, dynamic>>(
        '/api/v2/driver/registration/personal-info',
        data: payload,
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
      final presign = inner['presign_upload_available'] == true;
      return (uuid: uuid, tokenSaved: tokenSaved, presignUploadAvailable: presign);
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
      if (kDebugMode) {
        final approx = _debugApproxMapStringChars(body);
        final sizeHint = approx >= 1024 * 1024
            ? '~${(approx / (1024 * 1024)).toStringAsFixed(2)} MiB'
            : '~${(approx / 1024).toStringAsFixed(0)} KiB';
        debugPrint(
          '[DriverRegistration] submitDocumentInfo document_type=$docType '
          'approx chars in string fields=$approx ($sizeHint en strings Base64+campos; JSON serializado algo mayor)',
        );
      }
      final telemetry = await DriverDeviceTelemetry.toApiPayload();
      final payload = Map<String, dynamic>.from(body);
      telemetry.forEach((key, value) {
        payload.putIfAbsent(key, () => value);
      });
      final response = await _usersDio.post<Map<String, dynamic>>(
        '/api/v2/driver/documents',
        data: payload,
        options: Options(
          headers: headers,
          sendTimeout: const Duration(minutes: 3),
          receiveTimeout: const Duration(minutes: 2),
        ),
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
      final telemetry = await DriverDeviceTelemetry.toApiPayload();
      final payload = <String, dynamic>{'uuid': uuid};
      telemetry.forEach((key, value) {
        payload.putIfAbsent(key, () => value);
      });
      final response = await _usersDio.put<Map<String, dynamic>>(
        '/api/v2/driver/registration/activate',
        data: payload,
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

  /// Vehículos del conductor en flota (solo texto / etiquetas; sin galería).
  /// Origen: `GET /api/v2/vehicles`.
  Future<List<DriverVehicleSummary>> fetchMyVehicleSummaries() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) {
      throw DriverRegistrationException('Sesión no disponible. Inicia sesión de nuevo.');
    }
    try {
      final response = await _usersDio.get<Map<String, dynamic>>(
        '/api/v2/vehicles',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      final data = response.data;
      if (data == null) {
        throw DriverRegistrationException('Respuesta vacía (vehículos)');
      }
      if (data['success'] != true) {
        throw DriverRegistrationException(_extractErrorMessage(data));
      }
      final raw = data['data'];
      if (raw is! Map) {
        throw DriverRegistrationException('Respuesta sin data (vehículos)');
      }
      final inner = Map<String, dynamic>.from(raw);
      final list = inner['vehicles'];
      if (list is! List) {
        throw DriverRegistrationException('Formato inválido de listado de vehículos');
      }
      final out = <DriverVehicleSummary>[];
      for (final e in list) {
        final m = e is Map<String, dynamic> ? e : (e is Map ? Map<String, dynamic>.from(e) : null);
        if (m == null) continue;
        final row = DriverVehicleSummary.fromApiJson(m);
        if (row != null) out.add(row);
      }
      return out;
    } on DioException catch (e) {
      _logDioIfDebug('fetchMyVehicleSummaries', e);
      throw DriverRegistrationException(_messageFromDioException(e));
    }
  }

  /// Catálogo canónico (`vehicle_type` / `category` / servicios / marca-modelo). Requiere Bearer.
  /// Origen: `GET /api/v2/vehicles/catalog` en dos partes (`scope=registration` + `scope=extensions`)
  /// para evitar un JSON único demasiado grande (proxies que cortan el cuerpo).
  Future<VehicleCatalog> fetchVehicleCatalog() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) {
      throw DriverRegistrationException('Sesión no disponible. Inicia sesión de nuevo.');
    }
    try {
      final core = await _fetchVehicleCatalogScope(
        token: token,
        scope: 'registration',
      );
      // Servidor legacy sin `scope`: suele ignorar el query y devolver el catálogo completo.
      if (core.vehicleTypes.isNotEmpty &&
          core.manufacturers.isNotEmpty &&
          core.vehicleModels.isNotEmpty) {
        return core;
      }
      final ext = await _fetchVehicleCatalogScope(
        token: token,
        scope: 'extensions',
      );
      return VehicleCatalog.mergeRegistrationSlices(core, ext);
    } on DioException catch (e) {
      _logDioIfDebug('fetchVehicleCatalog', e);
      throw DriverRegistrationException(_messageFromDioException(e));
    }
  }

  Future<VehicleCatalog> _fetchVehicleCatalogScope({
    required String token,
    required String scope,
  }) async {
    try {
      final response = await _usersDio.get<Map<String, dynamic>>(
        '/api/v2/vehicles/catalog',
        queryParameters: {'scope': scope},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          receiveTimeout: const Duration(minutes: 3),
          sendTimeout: const Duration(seconds: 60),
        ),
      );
      final data = response.data;
      if (data == null) {
        throw DriverRegistrationException('Respuesta vacía (catálogo vehículo)');
      }
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
      _logDioIfDebug('fetchVehicleCatalog scope=$scope', e);
      rethrow;
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

  /// Fotos del vehículo: `POST /api/v2/vehicles/images` (cada ítem: `image_storage_key` o `image`).
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
          sendTimeout: const Duration(minutes: 3),
          receiveTimeout: const Duration(minutes: 2),
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
