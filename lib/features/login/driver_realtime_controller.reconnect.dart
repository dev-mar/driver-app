part of 'driver_realtime_controller.dart';

mixin _DriverRealtimeReconnectMixin on StateNotifier<DriverRealtimeState> {
  DriverRealtimeController get _rt => this as DriverRealtimeController;

  Future<void> _handleUnexpectedDisconnectWhileAvailable() async {
    if (_rt._userRequestedOffline || _rt._disposed) return;
    await _rt._goOffline(
      internal: true,
      preserveTripState: false,
      retainConnectingIndicator: true,
      preservePendingOffers: true,
    );
    if (_rt._userRequestedOffline || _rt._disposed) return;
    final delayMs = _nextReconnectDelayMs(hasTrip: false);
    await Future<void>.delayed(Duration(milliseconds: delayMs));
    if (_rt._userRequestedOffline || _rt._disposed) return;
    try {
      await _rt._goOnline();
    } catch (e, st) {
      debugPrint('[DRIVER_RT] reconexión disponibilidad tras caída: $e\n$st');
      state = state.copyWith(
        connecting: false,
        online: false,
        errorCode: 'SOCKET',
      );
      _ensureAvailabilityReconnectLoop();
    }
  }

  Future<void> _handleUnexpectedDisconnectWithTrip() async {
    await _rt._goOffline(
      internal: true,
      preserveTripState: true,
      preservePendingOffers: true,
    );
    if (_rt._userRequestedOffline || _rt._disposed) return;
    state = state.copyWith(connecting: true, errorCode: 'SOCKET_RECONNECTING');
    final delayMs = _nextReconnectDelayMs(hasTrip: true);
    await Future<void>.delayed(Duration(milliseconds: delayMs));
    if (_rt._userRequestedOffline || _rt._disposed) return;
    try {
      await _rt._goOnline();
    } catch (e, st) {
      debugPrint('[DRIVER_RT] reconexión tras caída: $e\n$st');
      state = state.copyWith(
        connecting: false,
        online: false,
        errorCode: 'SOCKET',
      );
      _ensureTripReconnectLoop();
    }
  }

  void _cancelTripReconnectLoop() {
    _rt._tripReconnectTimer?.cancel();
    _rt._tripReconnectTimer = null;
    _rt._tripReconnectAttempts = 0;
  }

  void _cancelAvailabilityReconnectLoop() {
    _rt._availabilityReconnectTimer?.cancel();
    _rt._availabilityReconnectTimer = null;
    _rt._availabilityReconnectAttempts = 0;
  }

  int _nextReconnectDelayMs({required bool hasTrip}) {
    if (hasTrip) {
      _rt._tripReconnectAttempts += 1;
      final exp = 1 << (_rt._tripReconnectAttempts - 1).clamp(0, 5);
      final jitter = _rt._reconnectJitterRandom.nextInt(450);
      return (DriverRealtimeController._tripReconnectBaseMs * exp + jitter)
          .clamp(700, DriverRealtimeController._reconnectMaxDelayMs)
          .toInt();
    }
    _rt._availabilityReconnectAttempts += 1;
    final exp = 1 << (_rt._availabilityReconnectAttempts - 1).clamp(0, 5);
    final jitter = _rt._reconnectJitterRandom.nextInt(550);
    return (DriverRealtimeController._availabilityReconnectBaseMs * exp + jitter)
        .clamp(900, DriverRealtimeController._reconnectMaxDelayMs)
        .toInt();
  }

  Future<void> _runAvailabilityReconnectAttempt() async {
    if (_rt._userRequestedOffline || _rt._disposed) {
      _cancelAvailabilityReconnectLoop();
      return;
    }
    if (!_rt._availabilitySessionDesired) {
      _cancelAvailabilityReconnectLoop();
      return;
    }
    if (state.activeTrip != null || state.tripPendingRating != null) {
      _cancelAvailabilityReconnectLoop();
      return;
    }
    if (state.online) {
      _cancelAvailabilityReconnectLoop();
      return;
    }
    if (state.connecting) {
      _ensureAvailabilityReconnectLoop();
      return;
    }
    await _rt.setOnline(true);
    if (!state.online) {
      _ensureAvailabilityReconnectLoop();
    }
  }

  void _ensureAvailabilityReconnectLoop() {
    if (_rt._userRequestedOffline || _rt._disposed) return;
    if (!_rt._availabilitySessionDesired) return;
    if (state.activeTrip != null || state.tripPendingRating != null) return;
    if (state.online) {
      _cancelAvailabilityReconnectLoop();
      return;
    }
    _rt._availabilityReconnectTimer?.cancel();
    final delayMs = _nextReconnectDelayMs(hasTrip: false);
    _rt._availabilityReconnectTimer = Timer(
      Duration(milliseconds: delayMs),
      () => unawaited(_runAvailabilityReconnectAttempt()),
    );
  }

  Future<void> _runTripReconnectAttempt() async {
    if (_rt._userRequestedOffline || _rt._disposed) {
      _cancelTripReconnectLoop();
      return;
    }
    if (state.activeTrip == null && state.tripPendingRating == null) {
      _cancelTripReconnectLoop();
      return;
    }
    if (state.online) {
      _cancelTripReconnectLoop();
      return;
    }
    if (state.connecting) {
      _ensureTripReconnectLoop();
      return;
    }
    await _rt.setOnline(true);
    if (!state.online) {
      _ensureTripReconnectLoop();
    }
  }

  void _ensureTripReconnectLoop() {
    if (_rt._userRequestedOffline || _rt._disposed) return;
    final hasWork = state.activeTrip != null || state.tripPendingRating != null;
    if (!hasWork) return;
    if (state.online) return;
    _rt._tripReconnectTimer?.cancel();
    final delayMs = _nextReconnectDelayMs(hasTrip: true);
    _rt._tripReconnectTimer = Timer(
      Duration(milliseconds: delayMs),
      () => unawaited(_runTripReconnectAttempt()),
    );
  }

  bool get wantsAvailabilitySessionReconnect =>
      _rt._availabilitySessionDesired &&
      !_rt._userRequestedOffline &&
      !_rt._disposed;

  void touchReconnectIfWantedOnline() {
    if (_rt._userRequestedOffline || _rt._disposed) return;
    if (!_rt._availabilitySessionDesired) return;
    if (state.activeTrip != null || state.tripPendingRating != null) return;
    if (state.online) {
      _cancelAvailabilityReconnectLoop();
      return;
    }
    _ensureAvailabilityReconnectLoop();
    if (!state.connecting) {
      unawaited(_rt.setOnline(true));
    }
  }

  void touchReconnectIfHasActiveWork() {
    if (_rt._userRequestedOffline || _rt._disposed) return;
    if (state.activeTrip == null && state.tripPendingRating == null) return;
    if (state.online) {
      _rt._lastTouchReconnect = null;
      return;
    }
    final now = DateTime.now();
    if (_rt._lastTouchReconnect != null &&
        now.difference(_rt._lastTouchReconnect!) <
            const Duration(seconds: 3)) {
      return;
    }
    _rt._lastTouchReconnect = now;
    _ensureTripReconnectLoop();
    if (!state.connecting) {
      unawaited(_rt.setOnline(true));
    }
  }
}
