import 'package:dio/dio.dart';

import '../../core/media/driver_app_media_uploader.dart';
import '../../core/network/driver_api_client.dart';
import '../../core/storage/driver_secure_storage.dart';
import 'driver_company_payout_models.dart';

class DriverCompanyPayoutRepository {
  DriverCompanyPayoutRepository({DriverApiClient? client})
      : _client = client ?? DriverApiClient();

  final DriverApiClient _client;

  Future<DriverCompanyPayoutSnapshot?> fetchSnapshot() async {
    try {
      final res = await _client.getWithRetry<Map<String, dynamic>>(
        path: '/api/v2/driver/company-payout',
        flow: 'driver_company_payout',
        maxAttempts: 2,
      );
      final root = res.data;
      if (root == null || root['success'] != true || root['data'] is! Map) {
        return null;
      }
      return DriverCompanyPayoutSnapshot.fromJson(
        Map<String, dynamic>.from(root['data'] as Map),
      );
    } on DioException {
      return null;
    }
  }

  Future<String?> uploadQrBase64(String base64Raw) async {
    final token = await DriverSecureStorage.read(DriverApiClient.tokenStorageKey);
    if (token == null || token.isEmpty) return null;
    final uploader = DriverAppMediaUploader(apiDio: DriverApiClient.createUsersDio());
    return uploader.uploadCompanyPayoutQrViaPresign(
      bearerToken: token,
      base64Raw: base64Raw,
    );
  }

  Future<DriverCompanyPayoutRequest> submitRequest({
    required String qrStorageKey,
  }) async {
    try {
      final res = await _client.postWithRetry<Map<String, dynamic>>(
        path: '/api/v2/driver/company-payout/requests',
        flow: 'driver_company_payout_submit',
        maxAttempts: 1,
        data: <String, dynamic>{'qrStorageKey': qrStorageKey},
      );
      final root = res.data;
      if (root == null || root['success'] != true || root['data'] is! Map) {
        throw DriverCompanyPayoutException(
          root?['code']?.toString() ?? 'DRIVER_PAYOUT_SUBMIT',
          root?['message']?.toString() ?? 'No se pudo enviar la solicitud.',
        );
      }
      return DriverCompanyPayoutRequest.fromJson(
        Map<String, dynamic>.from(root['data'] as Map),
      );
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is Map) {
        throw DriverCompanyPayoutException(
          body['code']?.toString() ?? 'DRIVER_PAYOUT_SUBMIT',
          body['message']?.toString() ?? 'No se pudo enviar la solicitud.',
        );
      }
      rethrow;
    }
  }
}
