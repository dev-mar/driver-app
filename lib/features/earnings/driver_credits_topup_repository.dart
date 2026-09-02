import 'package:dio/dio.dart';

import '../../core/media/driver_app_media_uploader.dart';
import '../../core/network/driver_api_client.dart';
import '../../core/storage/driver_secure_storage.dart';
import 'driver_credits_topup_models.dart';

class DriverCreditsTopupRepository {
  DriverCreditsTopupRepository({DriverApiClient? client})
      : _client = client ?? DriverApiClient();

  final DriverApiClient _client;

  Future<DriverTopupCatalog?> fetchCatalog() async {
    try {
      final res = await _client.getWithRetry<Map<String, dynamic>>(
        path: '/api/v2/driver/app-credits/topup',
        flow: 'driver_credits_topup',
        maxAttempts: 2,
      );
      final root = res.data;
      if (root == null || root['success'] != true || root['data'] is! Map) {
        return null;
      }
      return DriverTopupCatalog.fromJson(Map<String, dynamic>.from(root['data'] as Map));
    } on DioException {
      return null;
    }
  }

  Future<String?> uploadReceiptBase64(String base64Raw) async {
    final token = await DriverSecureStorage.read(DriverApiClient.tokenStorageKey);
    if (token == null || token.isEmpty) return null;
    final uploader = DriverAppMediaUploader(apiDio: DriverApiClient.createUsersDio());
    return uploader.uploadTopupReceiptViaPresign(
      bearerToken: token,
      base64Raw: base64Raw,
    );
  }

  Future<DriverTopupTicket?> submitTicket({
    required String packageId,
    String? receiptStorageKey,
    String? originAccount,
    String? transactionRef,
  }) async {
    try {
      final res = await _client.postWithRetry<Map<String, dynamic>>(
        path: '/api/v2/driver/app-credits/topup/tickets',
        flow: 'driver_credits_topup_submit',
        maxAttempts: 1,
        data: <String, dynamic>{
          'packageId': packageId,
          if (receiptStorageKey != null && receiptStorageKey.isNotEmpty)
            'receiptStorageKey': receiptStorageKey,
          if (originAccount != null && originAccount.isNotEmpty)
            'originAccount': originAccount,
          if (transactionRef != null && transactionRef.isNotEmpty)
            'transactionRef': transactionRef,
        },
      );
      final root = res.data;
      if (root == null || root['success'] != true || root['data'] is! Map) {
        throw DriverTopupException(
          root?['code']?.toString() ?? 'DRIVER_TOPUP_SUBMIT',
          root?['message']?.toString() ?? 'No se pudo enviar el comprobante.',
        );
      }
      return DriverTopupTicket.fromJson(Map<String, dynamic>.from(root['data'] as Map));
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is Map) {
        throw DriverTopupException(
          body['code']?.toString() ?? 'DRIVER_TOPUP_SUBMIT',
          body['message']?.toString() ?? 'No se pudo enviar el comprobante.',
        );
      }
      rethrow;
    }
  }
}

class DriverTopupException implements Exception {
  DriverTopupException(this.code, this.message);
  final String code;
  final String message;

  @override
  String toString() => message;
}
