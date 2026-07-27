import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'driver_api_client.dart';
import 'request_policy_cache.dart';

final driverApiClientProvider = Provider<DriverApiClient>(
  (ref) => DriverApiClient(),
);

const _meProfileCacheKey = 'driver_me_profile';
const _appCreditsCacheKey = 'driver_app_credits';

final _meProfileCache = RequestPolicyCache<Map<String, dynamic>>(
  defaultTtl: const Duration(seconds: 15),
);

final _appCreditsCache = RequestPolicyCache<Map<String, dynamic>>(
  defaultTtl: const Duration(seconds: 15),
);

/// Perfil plano `GET /api/v2/driver/me-profile` → `data` (cache 15 s).
class DriverMeProfileService {
  DriverMeProfileService(this._client);

  final DriverApiClient _client;

  Future<Map<String, dynamic>> fetchData({bool forceRefresh = false}) {
    return _meProfileCache.run(
      key: _meProfileCacheKey,
      ttl: const Duration(seconds: 15),
      forceRefresh: forceRefresh,
      fetcher: () async {
        final response = await _client.getWithRetry<Map<String, dynamic>>(
          path: '/api/v2/driver/me-profile',
          flow: 'driver_me_profile',
        );
        return DriverApiClient.parseSuccessData(response.data);
      },
    );
  }
}

/// Saldo y política `GET /api/v2/driver/app-credits` → `data` (cache 15 s).
class DriverAppCreditsService {
  DriverAppCreditsService(this._client);

  final DriverApiClient _client;

  Future<Map<String, dynamic>> fetchData({bool forceRefresh = false}) {
    return _appCreditsCache.run(
      key: _appCreditsCacheKey,
      ttl: const Duration(seconds: 15),
      forceRefresh: forceRefresh,
      fetcher: () async {
        final response = await _client.getWithRetry<Map<String, dynamic>>(
          path: '/api/v2/driver/app-credits',
          flow: 'driver_app_credits',
          maxAttempts: 2,
        );
        return DriverApiClient.parseSuccessData(response.data);
      },
    );
  }
}

final driverMeProfileServiceProvider = Provider<DriverMeProfileService>(
  (ref) => DriverMeProfileService(ref.watch(driverApiClientProvider)),
);

final driverAppCreditsServiceProvider = Provider<DriverAppCreditsService>(
  (ref) => DriverAppCreditsService(ref.watch(driverApiClientProvider)),
);

final driverMeProfileDataProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.watch(driverMeProfileServiceProvider).fetchData();
});

final driverAppCreditsDataProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.watch(driverAppCreditsServiceProvider).fetchData();
});
