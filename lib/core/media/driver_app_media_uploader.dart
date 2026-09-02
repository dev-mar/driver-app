import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// POST presign en API v2 + PUT binario a Azure Blob (URL SAS; JSON liviano en el endpoint final).
///
/// Usado en registro (`/driver/media/presign`), galería vehículo (`/vehicles/media/presign`), etc.
final class DriverAppMediaUploader {
  DriverAppMediaUploader({
    required Dio apiDio,
    Dio? blobPutDio,
  })  : _api = apiDio,
        _blobPutClient = blobPutDio ?? _defaultBlobPutClient();

  final Dio _api;
  final Dio _blobPutClient;

  static Dio _defaultBlobPutClient() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 45),
        sendTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(seconds: 90),
        validateStatus: (status) => status != null && status >= 200 && status < 400,
      ),
    );
  }

  Future<String?> uploadRegistrationImageViaPresign({
    required String bearerToken,
    required String uuid,
    required String purpose,
    required String base64Raw,
    String contentType = 'image/jpeg',
  }) {
    return _decodeAndPresignPut(
      bearerToken: bearerToken,
      presignPath: '/api/v2/driver/media/presign',
      presignBody: <String, dynamic>{
        'uuid': uuid,
        'purpose': purpose,
        'content_type': contentType,
      },
      base64Raw: base64Raw,
      contentType: contentType,
      debugPurpose: purpose,
    );
  }

  /// Activo v2 (`vehicle_asset_id` = uuid devuelto por `POST /api/v2/vehicles`).
  Future<String?> uploadVehicleImageViaPresign({
    required String bearerToken,
    required String vehicleAssetId,
    required String purpose,
    required String base64Raw,
    String contentType = 'image/jpeg',
  }) {
    return _decodeAndPresignPut(
      bearerToken: bearerToken,
      presignPath: '/api/v2/vehicles/media/presign',
      presignBody: <String, dynamic>{
        'vehicle_asset_id': vehicleAssetId,
        'purpose': purpose,
        'content_type': contentType,
      },
      base64Raw: base64Raw,
      contentType: contentType,
      debugPurpose: purpose,
    );
  }

  Future<String?> uploadTopupReceiptViaPresign({
    required String bearerToken,
    required String base64Raw,
    String contentType = 'image/jpeg',
  }) {
    return _decodeAndPresignPut(
      bearerToken: bearerToken,
      presignPath: '/api/v2/driver/app-credits/topup/receipt/presign',
      presignBody: <String, dynamic>{
        'content_type': contentType,
      },
      base64Raw: base64Raw,
      contentType: contentType,
      debugPurpose: 'topup_receipt',
    );
  }

  Future<String?> _decodeAndPresignPut({
    required String bearerToken,
    required String presignPath,
    required Map<String, dynamic> presignBody,
    required String base64Raw,
    required String contentType,
    required String debugPurpose,
  }) async {
    List<int> bytes;
    try {
      bytes = base64Decode(base64Raw.trim());
    } catch (_) {
      return null;
    }
    if (bytes.isEmpty) return null;
    final body = Map<String, dynamic>.from(presignBody);
    body['content_length'] = bytes.length;
    return _presignThenPut(
      bearerToken: bearerToken,
      presignPath: presignPath,
      presignBody: body,
      bytes: bytes,
      contentType: contentType,
      debugPurpose: debugPurpose,
    );
  }

  Future<String?> _presignThenPut({
    required String bearerToken,
    required String presignPath,
    required Map<String, dynamic> presignBody,
    required List<int> bytes,
    required String contentType,
    required String debugPurpose,
  }) async {
    try {
      final pres = await _api.post<Map<String, dynamic>>(
        presignPath,
        data: presignBody,
        options: Options(headers: <String, dynamic>{'Authorization': 'Bearer $bearerToken'}),
      );
      final data = pres.data;
      if (data == null || data['success'] != true) return null;
      final inner = data['data'];
      if (inner is! Map) return null;
      final uploadUrl = inner['upload_url']?.toString();
      final storageKey = inner['storage_key']?.toString();
      if (uploadUrl == null ||
          storageKey == null ||
          uploadUrl.isEmpty ||
          storageKey.isEmpty) {
        return null;
      }
      final hdr = <String, String>{'Content-Type': contentType};
      final rh = inner['required_headers'];
      if (rh is Map) {
        rh.forEach((k, v) {
          if (k != null && v != null) {
            hdr[k.toString()] = v.toString();
          }
        });
      }
      await _blobPutClient.put<void>(
        uploadUrl,
        data: bytes,
        options: Options(headers: hdr),
      );
      return storageKey;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DriverMedia] presign/blob PUT falló purpose=$debugPurpose: $e');
      }
      return null;
    }
  }
}
