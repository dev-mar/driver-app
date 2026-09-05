import 'package:dio/dio.dart';

import '../../core/network/driver_api_client.dart';
import 'driver_realtime_state.dart';
import '../home/widgets/driver_trip_cancel_reason.dart';

/// REST auxiliar del flujo realtime (foto perfil, gates online, rating, créditos).
class DriverTripRestService {
  DriverTripRestService({DriverApiClient? client})
      : _client = client ?? DriverApiClient();

  final DriverApiClient _client;

  static const _realtimeConnectTimeout = Duration(seconds: 10);
  static const _realtimeReceiveTimeout = Duration(seconds: 15);

  Future<bool> tryRefreshSession() => _client.tryRefreshSession();

  Future<DriverProfilePictureSnapshot?> fetchProfilePictureSnapshot() async {
    try {
      final res = await _client.getWithRetry<Map<String, dynamic>>(
        path: '/api/v2/driver/me-profile',
        flow: 'driver_profile_picture',
        maxAttempts: 2,
        connectTimeout: _realtimeConnectTimeout,
        receiveTimeout: _realtimeReceiveTimeout,
      );
      final data = DriverApiClient.parseSuccessData(res.data);
      final rawPic = data['picture_profile']?.toString().trim();
      DateTime? exp;
      final rawExp = data['profile_picture_expires_at']?.toString().trim();
      if (rawExp != null && rawExp.isNotEmpty) {
        exp = DateTime.tryParse(rawExp);
      }
      if (rawPic == null || rawPic.isEmpty) return null;
      return DriverProfilePictureSnapshot(
        pictureUrl: rawPic,
        expiresAt: exp,
      );
    } on DriverApiSessionException {
      return null;
    } on DriverApiResponseException {
      return null;
    } on DioException {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchGoOnlineStatusRaw() async {
    try {
      final res = await _client.getWithRetry<Map<String, dynamic>>(
        path: '/drivers/me/status',
        flow: 'driver_go_online_guards',
        maxAttempts: 2,
        connectTimeout: _realtimeConnectTimeout,
        receiveTimeout: _realtimeReceiveTimeout,
      );
      final root = res.data;
      if (root == null || root['ok'] != true) return null;
      final data = root['data'];
      if (data is! Map) return null;
      return Map<String, dynamic>.from(data);
    } on DriverApiSessionException {
      return null;
    } on DioException {
      return null;
    }
  }

  Future<DriverTripRatingResult> submitTripRating({
    required String tripId,
    required int stars,
    List<String> feedbackCodes = const [],
  }) async {
    final res = await _client.postWithRetry<Map<String, dynamic>>(
      path: '/drivers/me/trips/$tripId/rating',
      flow: 'driver_trip_rating',
      maxAttempts: 2,
      data: <String, dynamic>{
        'stars': stars,
        if (feedbackCodes.isNotEmpty) 'feedbackCodes': feedbackCodes,
      },
      connectTimeout: _realtimeConnectTimeout,
      receiveTimeout: _realtimeReceiveTimeout,
    );
    final data = DriverApiClient.parseSuccessData(res.data);
    return DriverTripRatingResult(
      claimEligible: data['claimEligible'] == true || data['claim_eligible'] == true,
    );
  }

  Future<void> submitTripClaim({
    required String tripId,
    required String message,
    int? stars,
    List<String> feedbackCodes = const [],
  }) async {
    await _client.postWithRetry<Map<String, dynamic>>(
      path: '/drivers/me/trips/$tripId/claim',
      flow: 'driver_trip_claim',
      maxAttempts: 1,
      data: <String, dynamic>{
        'message': message,
        'stars': ?stars,
        if (feedbackCodes.isNotEmpty) 'feedbackCodes': feedbackCodes,
      },
      connectTimeout: _realtimeConnectTimeout,
      receiveTimeout: _realtimeReceiveTimeout,
    );
  }

  Future<List<DriverRatingFeedbackItem>> fetchRatingFeedbackCatalog({
    required int stars,
  }) async {
    if (stars < 1 || stars > 5) return const [];
    try {
      final res = await _client.getWithRetry<Map<String, dynamic>>(
        path: '/drivers/me/trips/rating-feedback-catalog',
        flow: 'driver_trip_rating',
        maxAttempts: 3,
        queryParameters: <String, dynamic>{'stars': stars},
        connectTimeout: _realtimeConnectTimeout,
        receiveTimeout: _realtimeReceiveTimeout,
      );
      final body = res.data ?? const <String, dynamic>{};
      final data = body['data'];
      if (data is! Map) return const [];
      final items = data['items'];
      if (items is! List) return const [];
      return items
          .whereType<Map>()
          .map(
            (m) =>
                DriverRatingFeedbackItem.fromJson(Map<String, dynamic>.from(m)),
          )
          .toList(growable: false);
    } on DriverApiSessionException {
      return const [];
    } on DioException {
      return const [];
    }
  }

  Future<List<DriverTripCancelReasonItem>> fetchTripCancelReasons({
    required String tripId,
    String? locale,
  }) async {
    final res = await _client.getWithRetry<Map<String, dynamic>>(
      path: '/drivers/me/trips/$tripId/cancel-reasons',
      flow: 'driver_trip_cancel',
      maxAttempts: 2,
      queryParameters: <String, dynamic>{
        if (locale != null && locale.trim().isNotEmpty) 'locale': locale.trim(),
      },
      connectTimeout: _realtimeConnectTimeout,
      receiveTimeout: _realtimeReceiveTimeout,
    );
    final body = res.data ?? const <String, dynamic>{};
    final data = body['data'];
    if (data is! Map) return const [];
    final items = data['items'];
    if (items is! List) return const [];
    return items
        .whereType<Map>()
        .map(
          (m) => DriverTripCancelReasonItem.fromJson(
            Map<String, dynamic>.from(m),
          ),
        )
        .where((e) => e.code.isNotEmpty)
        .toList(growable: false);
  }

  static String? waitBlockReasonOf(Object e) {
    if (e is! DioException) return null;
    final data = e.response?.data;
    if (data is Map) {
      final err = data['error'];
      if (err is Map) {
        final w = err['waitBlockReason']?.toString().trim();
        if (w != null && w.isNotEmpty) return w;
      }
      final direct = data['waitBlockReason']?.toString().trim();
      if (direct != null && direct.isNotEmpty) return direct;
    }
    return null;
  }

  Future<void> cancelAssignedTrip({
    required String tripId,
    required String reasonCode,
    String? reasonNote,
  }) async {
    final note = reasonNote?.trim();
    await _client.postWithRetry<Map<String, dynamic>>(
      path: '/drivers/me/trips/$tripId/cancel',
      flow: 'driver_trip_cancel',
      maxAttempts: 1,
      data: <String, dynamic>{
        'reasonCode': reasonCode,
        if (note != null && note.isNotEmpty) 'reasonNote': note,
      },
      connectTimeout: _realtimeConnectTimeout,
      receiveTimeout: _realtimeReceiveTimeout,
    );
  }

  Future<DriverAppCreditsSnapshot?> fetchAppCreditsSnapshot() async {
    try {
      final res = await _client.getWithRetry<Map<String, dynamic>>(
        path: '/api/v2/driver/app-credits',
        flow: 'driver_app_credits_refresh',
        maxAttempts: 2,
        connectTimeout: _realtimeConnectTimeout,
        receiveTimeout: _realtimeReceiveTimeout,
      );
      final data = DriverApiClient.parseSuccessData(res.data);
      final balRaw = data['balance'];
      final balance = balRaw is num ? balRaw.toDouble() : 0.0;
      final minRaw =
          data['minBalanceToGoOnline'] ?? data['min_balance_to_go_online'];
      final minCredits = minRaw is num ? minRaw.toDouble() : 0.0;
      final gateRaw = data['onlineGateEnabled'] ?? data['online_gate_enabled'];
      final gateOn = gateRaw == true;
      return DriverAppCreditsSnapshot(
        balance: balance,
        minCreditsToGoOnline: minCredits,
        onlineGateEnabled: gateOn,
        insufficientCreditsToGoOnline: gateOn && balance < minCredits,
      );
    } on DriverApiSessionException {
      return null;
    } on DriverApiResponseException {
      return null;
    } on DioException {
      return null;
    }
  }
}

class DriverTripRatingResult {
  const DriverTripRatingResult({required this.claimEligible});

  final bool claimEligible;
}

class DriverProfilePictureSnapshot {
  const DriverProfilePictureSnapshot({
    required this.pictureUrl,
    this.expiresAt,
  });

  final String pictureUrl;
  final DateTime? expiresAt;
}

class DriverAppCreditsSnapshot {
  const DriverAppCreditsSnapshot({
    required this.balance,
    required this.minCreditsToGoOnline,
    required this.onlineGateEnabled,
    required this.insufficientCreditsToGoOnline,
  });

  final double balance;
  final double minCreditsToGoOnline;
  final bool onlineGateEnabled;
  final bool insufficientCreditsToGoOnline;
}
