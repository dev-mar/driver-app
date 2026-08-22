import 'package:dio/dio.dart';

import '../../core/network/driver_api_client.dart';
import 'driver_club_models.dart';

class DriverClubException implements Exception {
  DriverClubException(this.message, {this.code});
  final String message;
  final String? code;
  @override
  String toString() => message;
}

class DriverClubRepository {
  DriverClubRepository({DriverApiClient? client})
      : _client = client ?? DriverApiClient();

  final DriverApiClient _client;

  Future<DriverClubHub> fetchHub() async {
    try {
      final res = await _client.getWithRetry<Map<String, dynamic>>(
        path: '/api/v2/driver/club/referrals',
        flow: 'club_referrals',
      );
      final data = res.data;
      if (data == null || data['success'] != true) {
        throw DriverClubException(
          _msg(data),
          code: _code(data),
        );
      }
      final inner = data['data'];
      if (inner is! Map) {
        throw DriverClubException('Respuesta sin data');
      }
      return DriverClubHub.fromJson(Map<String, dynamic>.from(inner));
    } on DioException catch (e) {
      final d = e.response?.data;
      throw DriverClubException(_msg(d is Map ? Map<String, dynamic>.from(d) : null), code: _code(d is Map ? Map<String, dynamic>.from(d) : null));
    }
  }

  Future<void> claimCode(String code) async {
    try {
      final res = await _client.postWithRetry<Map<String, dynamic>>(
        path: '/api/v2/driver/club/referrals/claim',
        flow: 'club_claim',
        data: <String, dynamic>{'referral_code': code.trim()},
      );
      final data = res.data;
      if (data == null || data['success'] != true) {
        throw DriverClubException(_msg(data), code: _code(data));
      }
    } on DioException catch (e) {
      final d = e.response?.data;
      throw DriverClubException(
        _msg(d is Map ? Map<String, dynamic>.from(d) : null),
        code: _code(d is Map ? Map<String, dynamic>.from(d) : null),
      );
    }
  }

  String _msg(Map<String, dynamic>? data) {
    if (data == null) return 'No se pudo cargar el Club.';
    final m = data['message']?.toString();
    if (m != null && m.trim().isNotEmpty) return m;
    return 'No se pudo cargar el Club.';
  }

  String? _code(Map<String, dynamic>? data) {
    if (data == null) return null;
    final c = data['code']?.toString();
    if (c != null && c.isNotEmpty) return c;
    final err = data['error'];
    if (err is Map) return err['code']?.toString();
    return null;
  }
}
