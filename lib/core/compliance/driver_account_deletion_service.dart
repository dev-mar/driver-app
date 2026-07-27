import 'package:dio/dio.dart';

import '../network/driver_api_client.dart';

class DriverAccountDeletionStatus {
  const DriverAccountDeletionStatus({
    required this.pending,
    this.graceDays,
    this.deletionRequestedAt,
    this.deletionEffectiveAt,
    this.daysRemaining,
  });

  final bool pending;
  final int? graceDays;
  final String? deletionRequestedAt;
  final String? deletionEffectiveAt;
  final int? daysRemaining;

  factory DriverAccountDeletionStatus.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return const DriverAccountDeletionStatus(pending: false);
    }
    return DriverAccountDeletionStatus(
      pending: json['pending'] == true,
      graceDays: _asInt(json['grace_days']),
      deletionRequestedAt: json['deletion_requested_at']?.toString(),
      deletionEffectiveAt: json['deletion_effective_at']?.toString(),
      daysRemaining: _asInt(json['days_remaining']),
    );
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

sealed class DriverAccountDeletionResult {
  const DriverAccountDeletionResult();
}

class DriverAccountDeletionScheduled extends DriverAccountDeletionResult {
  const DriverAccountDeletionScheduled(this.status, {this.message});

  final DriverAccountDeletionStatus status;
  final String? message;
}

class DriverAccountDeletionCancelled extends DriverAccountDeletionResult {
  const DriverAccountDeletionCancelled({this.message});
  final String? message;
}

class DriverAccountDeletionFailure extends DriverAccountDeletionResult {
  const DriverAccountDeletionFailure(this.message, {this.code});

  final String message;
  final String? code;
}

/// Self-service eliminación de cuenta conductor (ventana de gracia).
class DriverAccountDeletionService {
  DriverAccountDeletionService({
    DriverApiClient? apiClient,
  }) : _apiClient = apiClient ?? DriverApiClient();

  final DriverApiClient _apiClient;

  Future<DriverAccountDeletionResult> scheduleAccountDeletion() async {
    try {
      final response = await _apiClient.deleteWithRetry<Map<String, dynamic>>(
        path: '/api/v2/driver/me/account',
        flow: 'account_delete',
        data: const {'confirm': true},
        maxAttempts: 1,
      );
      final data = DriverApiClient.parseSuccessData(response.data);
      final deletion = DriverAccountDeletionStatus.fromJson(
        data['account_deletion'] as Map<String, dynamic>?,
      );
      return DriverAccountDeletionScheduled(
        deletion,
        message: data['message']?.toString(),
      );
    } on DriverApiSessionException {
      return const DriverAccountDeletionFailure(
        'Sesión expirada. Inicia sesión e intenta de nuevo.',
        code: 'SESSION_EXPIRED',
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = _messageFromResponse(data) ??
          e.message ??
          'No se pudo programar la eliminación.';
      return DriverAccountDeletionFailure(message, code: _codeFromResponse(data));
    } catch (_) {
      return const DriverAccountDeletionFailure(
        'No se pudo programar la eliminación.',
      );
    }
  }

  Future<DriverAccountDeletionResult> cancelAccountDeletion() async {
    try {
      final response = await _apiClient.postWithRetry<Map<String, dynamic>>(
        path: '/api/v2/driver/me/account/deletion/cancel',
        flow: 'account_delete_cancel',
        maxAttempts: 1,
      );
      final data = DriverApiClient.parseSuccessData(response.data);
      return DriverAccountDeletionCancelled(
        message: data['message']?.toString(),
      );
    } on DriverApiSessionException {
      return const DriverAccountDeletionFailure(
        'Sesión expirada. Inicia sesión e intenta de nuevo.',
        code: 'SESSION_EXPIRED',
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = _messageFromResponse(data) ??
          e.message ??
          'No se pudo cancelar la eliminación.';
      return DriverAccountDeletionFailure(message, code: _codeFromResponse(data));
    } catch (_) {
      return const DriverAccountDeletionFailure(
        'No se pudo cancelar la eliminación.',
      );
    }
  }

  static String? _codeFromResponse(dynamic data) {
    if (data is Map) {
      final c = data['code']?.toString().trim();
      if (c != null && c.isNotEmpty) return c;
      final err = data['error'];
      if (err is Map) {
        final ec = err['code']?.toString().trim();
        if (ec != null && ec.isNotEmpty) return ec;
      }
    }
    return null;
  }

  static String? _messageFromResponse(dynamic data) {
    if (data is Map) {
      final m = data['message']?.toString().trim();
      if (m != null && m.isNotEmpty) return m;
      final err = data['error'];
      if (err is Map) {
        final em = err['message']?.toString().trim();
        if (em != null && em.isNotEmpty) return em;
      }
    }
    return null;
  }
}
