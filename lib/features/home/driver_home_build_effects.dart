import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../login/driver_realtime_controller.dart';
import 'driver_home_view_state.dart';

/// Efectos de build (post-frame): reconexión, rating sheet, wakelock.
void runDriverHomeBuildEffects({
  required BuildContext context,
  required WidgetRef ref,
  required DriverHomeViewState view,
  required DriverRealtimeState realtime,
  required bool blockOnlineForTrips,
  required bool mounted,
  required void Function() syncKeepScreenOn,
  required void Function(BuildContext, DriverActiveTrip) showRatingSheet,
  required String? lastRatedTripId,
  required bool isRatingSheetOpen,
  required void Function(String?) setLastRatedTripId,
  required void Function(bool) setRatingSheetOpen,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) syncKeepScreenOn();
  });

  final online = realtime.online;
  final connecting = realtime.connecting;
  final activeTrip = realtime.activeTrip;
  final tripPendingRating = realtime.tripPendingRating;

  if (view.shouldAttemptAutoReconnect &&
      !online &&
      !connecting &&
      !blockOnlineForTrips) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(driverRealtimeProvider.notifier)
          .touchReconnectIfHasActiveWork();
    });
  }

  if (view.wantsAvailReconnect &&
      !online &&
      !connecting &&
      !blockOnlineForTrips &&
      activeTrip == null &&
      tripPendingRating == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(driverRealtimeProvider.notifier)
          .touchReconnectIfWantedOnline();
    });
  }

  if (tripPendingRating != null &&
      tripPendingRating.tripId != lastRatedTripId &&
      !isRatingSheetOpen) {
    setLastRatedTripId(tripPendingRating.tripId);
    setRatingSheetOpen(true);
    final tripToRate = tripPendingRating;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showRatingSheet(context, tripToRate);
    });
  }
}
