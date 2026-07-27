import '../login/driver_realtime_state.dart';

/// Estado derivado de home (mapa vs lista, gates, reconexión) sin mutación de UI.
class DriverHomeViewState {
  const DriverHomeViewState({
    required this.shouldShowMap,
    required this.shouldIgnoreActiveTripRestore,
    required this.shouldAttemptAutoReconnect,
    required this.wantsAvailReconnect,
  });

  final bool shouldShowMap;
  final bool shouldIgnoreActiveTripRestore;
  final bool shouldAttemptAutoReconnect;
  final bool wantsAvailReconnect;

  static DriverHomeViewState compute({
    required DriverRealtimeState realtime,
    required bool wantsAvailReconnectFromNotifier,
    int? nowMs,
  }) {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final activeTrip = realtime.activeTrip;
    final tripPendingRating = realtime.tripPendingRating;
    final ignoreId = realtime.ignoreActiveTripRestoreTripId;
    final ignoreUntil = realtime.ignoreActiveTripRestoreUntilMs;

    final shouldIgnoreActiveTripRestore =
        ignoreId != null &&
        ignoreUntil != null &&
        now <= ignoreUntil &&
        activeTrip?.tripId == ignoreId;

    final shouldShowMap =
        activeTrip != null &&
        (tripPendingRating == null ||
            tripPendingRating.tripId != activeTrip.tripId) &&
        !shouldIgnoreActiveTripRestore;

    final shouldAttemptAutoReconnect =
        activeTrip != null ||
        tripPendingRating != null ||
        shouldIgnoreActiveTripRestore;

    return DriverHomeViewState(
      shouldShowMap: shouldShowMap,
      shouldIgnoreActiveTripRestore: shouldIgnoreActiveTripRestore,
      shouldAttemptAutoReconnect: shouldAttemptAutoReconnect,
      wantsAvailReconnect: wantsAvailReconnectFromNotifier,
    );
  }
}
