import '../../gen_l10n/app_localizations.dart';
import '../login/driver_realtime_state.dart';

/// Mensaje l10n para `DriverRealtimeState.errorCode` (home / switch online).
String? driverHomeOnlineErrorMessage({
  required AppLocalizations l10n,
  required DriverRealtimeState realtime,
  void Function()? onAuthSessionExpired,
}) {
  switch (realtime.errorCode) {
    case 'AUTH':
      onAuthSessionExpired?.call();
      return l10n.driverOnlineErrorSessionExpiredReLogin;
    case 'NO_INTERNET':
      return l10n.driverOnlineErrorNoInternet;
    case 'NO_GPS':
      return l10n.driverOnlineErrorNoGps;
    case 'GPS_SERVICE_OFF':
      return l10n.driverOnlineErrorGpsServiceOff;
    case 'NO_NOTIFICATIONS':
      return l10n.driverOnlineErrorNoNotifications;
    case 'NO_TOKEN':
      return l10n.driverOnlineErrorNoToken;
    case 'SOCKET':
      return l10n.driverOnlineErrorSocket;
    case 'DRIVER_VEHICLE_REQUIRED':
      return l10n.driverOnlineErrorVehicleRequired;
    case 'DRIVER_GO_ONLINE_BLOCKED':
      return l10n.driverOnlineErrorGoOnlineBlocked;
    case 'DRIVER_CREDITS_BELOW_MIN':
      return l10n.driverOnlineErrorCreditsBelowMin(
        realtime.minCreditsToGoOnline.toStringAsFixed(0),
        realtime.driverCreditsBalance.toStringAsFixed(2),
      );
    case 'DRIVER_ACCOUNT_BLOCKED':
      onAuthSessionExpired?.call();
      return l10n.driverOnlineErrorAccountBlocked;
    case 'UNKNOWN':
      return l10n.driverOnlineErrorUnknown;
    case 'ACTIVE_TRIP_CANT_GO_OFFLINE':
      return l10n.driverOnlineErrorActiveTripCantGoOffline;
    case 'SOCKET_RECONNECTING':
      return l10n.driverOnlineErrorReconnecting;
    case 'RBAC_FORBIDDEN':
      return l10n.driverOnlineErrorRbacForbidden;
    case 'RBAC_NO_IDENTITY':
    case 'RBAC_NO_AUTH':
      return l10n.driverOnlineErrorRbacSession;
    case 'RBAC_RESOLVE':
    case 'RBAC_ERROR':
    case 'RBAC_CONFIG':
      return l10n.driverOnlineErrorRbacTechnical;
    default:
      return null;
  }
}

String? driverHomeTripActionErrorMessage({
  required AppLocalizations l10n,
  required DriverRealtimeState realtime,
}) {
  return switch (realtime.tripErrorCode) {
    'TRIP_UPDATE_FAILED' => l10n.driverTripErrorGeneric,
    _ => realtime.tripErrorMessage,
  };
}

String? driverHomeOfferErrorMessage({
  required AppLocalizations l10n,
  required String? perOfferCode,
  String? fallbackMessage,
}) {
  final mapped = switch (perOfferCode) {
    'NO_CONNECTION' => l10n.driverOfferErrorNoConnection,
    'OFFER_EXPIRED' => l10n.driverOfferErrorExpired,
    'TRIP_ALREADY_PROCESSED' ||
    'TRIP_NOT_AVAILABLE' ||
    'TRIP_TAKEN' ||
    'OFFER_ALREADY_TAKEN' => l10n.driverOfferErrorTaken,
    'RBAC_FORBIDDEN' => l10n.driverOnlineErrorRbacForbidden,
    'RBAC_NO_IDENTITY' || 'RBAC_NO_AUTH' => l10n.driverOnlineErrorRbacSession,
    'RBAC_RESOLVE' || 'RBAC_ERROR' || 'RBAC_CONFIG' =>
      l10n.driverOnlineErrorRbacTechnical,
    _ => null,
  };
  return mapped ?? fallbackMessage;
}
