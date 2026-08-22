import '../network/driver_api_client.dart';
import '../router/app_router.dart';
import '../storage/driver_secure_storage.dart';

/// Coordinación logout + realtime cuando la sesión fue invalidada (REST o socket).
typedef DriverSessionExpulsionHandler = Future<void> Function(
  String code,
  String? message,
);

DriverSessionExpulsionHandler? driverSessionExpulsionHandler;

/// Bloquea re-registro FCM tras expulsión hasta próximo login exitoso.
bool driverSessionSyncBlocked = false;

Future<void> notifyDriverSessionExpelled(String code, {String? message}) async {
  driverSessionSyncBlocked = true;
  final handler = driverSessionExpulsionHandler;
  if (handler != null) {
    await handler(code, message);
    return;
  }
  await DriverSecureStorage.delete(DriverApiClient.tokenStorageKey);
  await DriverSecureStorage.delete(DriverApiClient.refreshTokenStorageKey);
  AppRouter.router.go('/login');
}

void resetDriverSessionExpulsionState() {
  driverSessionSyncBlocked = false;
}
