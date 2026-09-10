part of 'driver_realtime_controller.dart';

mixin _DriverRealtimeLocationMixin on StateNotifier<DriverRealtimeState> {
  DriverRealtimeController get _rt => this as DriverRealtimeController;

  void _setAvailability(String availability) {
    if (_rt._socket?.connected != true) return;
    _rt._socket!.emit('driver:setAvailability', {'availability': availability});
  }

  Future<void> _emitAvailabilityOnBreakBeforeDisconnect() async {
    final s = _rt._socket;
    if (s == null || s.connected != true) return;
    try {
      await s
          .emitWithAckAsync('driver:setAvailability', {
            'availability': 'on_break',
          })
          .timeout(const Duration(milliseconds: 1200));
    } catch (e) {
      debugPrint('[DRIVER_RT] on_break antes de disconnect: $e');
    }
  }

  /// Confirma `available` con ack. Reintenta `RATE_LIMITED` (2 s en servidor).
  Future<void> _confirmAvailableWithRetry() async {
    if (_rt._disposed || _rt._userRequestedOffline) return;
    if (!_rt._availabilitySessionDesired) return;
    if (state.activeTrip != null || state.tripPendingRating != null) return;
    final socket = _rt._socket;
    if (socket == null || socket.connected != true) return;

    for (var i = 0; i < 3; i++) {
      if (_rt._disposed || socket.connected != true) return;
      try {
        final ack = await socket
            .emitWithAckAsync('driver:setAvailability', {
              'availability': 'available',
            })
            .timeout(const Duration(seconds: 4));
        if (ack is Map) {
          final ok = ack['ok'] == true;
          final code = ack['code']?.toString();
          if (ok) return;
          if (code == 'RATE_LIMITED') {
            await Future<void>.delayed(const Duration(milliseconds: 2200));
            continue;
          }
          debugPrint('[DRIVER_RT] setAvailability available ack=$ack');
          return;
        }
        return;
      } catch (e) {
        debugPrint('[DRIVER_RT] setAvailability available retry: $e');
        await Future<void>.delayed(const Duration(milliseconds: 800));
      }
    }
  }

  void _emitLocationToServer(
    double lat,
    double lng,
    double speed, {
    double bearing = 0,
    bool force = false,
  }) {
    if (_rt._socket?.connected != true) return;
    final now = DateTime.now();
    if (!force && _rt._lastLocationEmittedAt != null) {
      if (now.difference(_rt._lastLocationEmittedAt!) <
          DriverRealtimeController._locationEmitMinInterval) {
        return;
      }
    }
    _rt._lastLocationEmittedAt = now;
    _rt._socket!.emit('location:update', {
      'lat': lat,
      'lng': lng,
      'bearing': bearing,
      'speed': speed,
    });
  }

  void _applyPositionToState(Position pos) {
    state = state.copyWith(
      driverLat: pos.latitude,
      driverLng: pos.longitude,
      driverBearing: pos.heading,
    );
  }

  LocationSettings _gpsFixSettings({
    required LocationAccuracy accuracy,
    required Duration timeLimit,
  }) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: accuracy,
        distanceFilter: 0,
        timeLimit: timeLimit,
      );
    }
    return LocationSettings(
      accuracy: accuracy,
      distanceFilter: 0,
      timeLimit: timeLimit,
    );
  }

  /// Tras permisos/patrón el GPS suele estar frío: lastKnown + fix medio/alto.
  Future<bool> _pushBestEffortFix({required bool force}) async {
    if (_rt._disposed) return false;
    var emitted = false;

    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && _rt._socket?.connected == true) {
        _applyPositionToState(last);
        _emitLocationToServer(
          last.latitude,
          last.longitude,
          last.speed,
          bearing: last.heading,
          force: force,
        );
        emitted = true;
      }
    } catch (e) {
      debugPrint('[DRIVER_RT] getLastKnownPosition: $e');
    }

    Future<Position?> tryFix(LocationAccuracy accuracy, Duration limit) async {
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: _gpsFixSettings(
            accuracy: accuracy,
            timeLimit: limit,
          ),
        );
      } catch (e) {
        debugPrint('[DRIVER_RT] getCurrentPosition($accuracy) falló: $e');
        return null;
      }
    }

    var fresh = await tryFix(LocationAccuracy.medium, const Duration(seconds: 8));
    fresh ??= await tryFix(LocationAccuracy.high, const Duration(seconds: 12));
    if (fresh != null && !_rt._disposed && _rt._socket?.connected == true) {
      _applyPositionToState(fresh);
      _emitLocationToServer(
        fresh.latitude,
        fresh.longitude,
        fresh.speed,
        bearing: fresh.heading,
        force: true,
      );
      emitted = true;
    } else if (!emitted &&
        state.driverLat != null &&
        state.driverLng != null &&
        _rt._socket?.connected == true) {
      _emitLocationToServer(
        state.driverLat!,
        state.driverLng!,
        0,
        bearing: state.driverBearing ?? 0,
        force: true,
      );
      emitted = true;
    }

    if (emitted &&
        !_rt._userRequestedOffline &&
        _rt._availabilitySessionDesired &&
        state.activeTrip == null &&
        state.tripPendingRating == null) {
      unawaited(_confirmAvailableWithRetry());
    }
    return emitted;
  }

  /// Si el switch ya está ON, reinyecta GPS + `available` (resume tras permisos).
  Future<void> _resyncMatchablePresence() async {
    if (_rt._disposed || _rt._userRequestedOffline) return;
    if (!_rt._availabilitySessionDesired) return;
    if (_rt._socket?.connected != true) return;
    await _pushBestEffortFix(force: true);
  }

  void _cancelPresenceHeartbeat() {
    _rt._presenceHeartbeatTimer?.cancel();
    _rt._presenceHeartbeatTimer = null;
  }

  void _cancelGpsPresenceWatchdog() {
    _rt._gpsPresenceRetryTimer?.cancel();
    _rt._gpsPresenceRetryTimer = null;
  }

  void _scheduleGpsPresenceWatchdog() {
    _cancelGpsPresenceWatchdog();
    var attempt = 0;
    _rt._gpsPresenceRetryTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) {
      attempt += 1;
      if (_rt._disposed ||
          _rt._userRequestedOffline ||
          !_rt._availabilitySessionDesired ||
          attempt > 8) {
        timer.cancel();
        return;
      }
      if (_rt._socket?.connected != true) return;
      final last = _rt._lastLocationEmittedAt;
      if (last != null &&
          DateTime.now().difference(last) < const Duration(seconds: 8)) {
        if (attempt >= 3) timer.cancel();
        return;
      }
      unawaited(_pushBestEffortFix(force: true));
    });
  }

  void _startPresenceHeartbeat() {
    _cancelPresenceHeartbeat();
    _rt._presenceHeartbeatTimer = Timer.periodic(const Duration(seconds: 20), (
      _,
    ) {
      final socket = _rt._socket;
      if (socket == null || !socket.connected) return;
      socket.emit('driver:heartbeat', {
        'clientTs': DateTime.now().toIso8601String(),
      });
      // Redis GPS caduca si el conductor no se mueve (distanceFilter). Reenviar último fix.
      final lat = state.driverLat;
      final lng = state.driverLng;
      if (lat != null && lng != null) {
        _emitLocationToServer(
          lat,
          lng,
          0,
          bearing: state.driverBearing ?? 0,
          force: true,
        );
      }
    });
  }

  Future<void> _ensureLocationPermissionForSocket() async {
    final now = DateTime.now();
    final cached = _rt._locationPermissionCached;
    final cachedAt = _rt._locationPermissionCachedAt;
    if (cached != null &&
        cachedAt != null &&
        (cached == LocationPermission.whileInUse ||
            cached == LocationPermission.always) &&
        now.difference(cachedAt) < const Duration(minutes: 3)) {
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _rt._locationPermissionCached = null;
      _rt._locationPermissionCachedAt = null;
      debugPrint('[DRIVER_RT] Permisos de GPS denegados.');
      throw const DriverRealtimeException('NO_GPS');
    }
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      _rt._locationPermissionCached = null;
      _rt._locationPermissionCachedAt = null;
      debugPrint('[DRIVER_RT] Permiso de ubicación insuficiente: $permission');
      throw const DriverRealtimeException('NO_GPS');
    }
    _rt._locationPermissionCached = permission;
    _rt._locationPermissionCachedAt = DateTime.now();
  }

  Future<void> _ensureLocationServiceEnabled() async {
    if (kIsWeb) return;
    if (await Geolocator.isLocationServiceEnabled()) {
      return;
    }
    debugPrint(
      '[DRIVER_RT] Servicio de ubicación apagado; intentando prompt nativo vía getCurrentPosition...',
    );
    try {
      final LocationSettings settings;
      if (defaultTargetPlatform == TargetPlatform.android) {
        settings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 25),
        );
      } else {
        settings = const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 25),
        );
      }
      await Geolocator.getCurrentPosition(locationSettings: settings);
    } on LocationServiceDisabledException {
      debugPrint(
        '[DRIVER_RT] Servicio de ubicación sigue desactivado tras el intento.',
      );
      throw const DriverRealtimeException('GPS_SERVICE_OFF');
    } on TimeoutException {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const DriverRealtimeException('GPS_SERVICE_OFF');
      }
      debugPrint(
        '[DRIVER_RT] GPS activado pero sin fix a tiempo; continúa conexión (presencia reintentará).',
      );
    }
  }

  Future<void> _ensureNotificationPermissionForTripOffers() async {
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    final messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.getNotificationSettings();
    if (_notificationPermissionOk(settings)) {
      return;
    }
    settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    if (_notificationPermissionOk(settings)) {
      return;
    }
    debugPrint(
      '[DRIVER_RT] Permiso de notificaciones denegado: ${settings.authorizationStatus}',
    );
    throw const DriverRealtimeException('NO_NOTIFICATIONS');
  }

  bool _notificationPermissionOk(NotificationSettings settings) {
    final s = settings.authorizationStatus;
    return s == AuthorizationStatus.authorized ||
        s == AuthorizationStatus.provisional;
  }

  Future<void> _startGpsTracking() async {
    await _rt._positionSub?.cancel();
    _scheduleGpsPresenceWatchdog();
    await _pushBestEffortFix(force: true);

    if (_rt._disposed) return;
    _rt._positionSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen(
          (pos) {
            if (kDebugMode) {
              _rt._logVerbose(
                'location:update lat=${pos.latitude}, lng=${pos.longitude}',
              );
            }
            _applyPositionToState(pos);
            _emitLocationToServer(
              pos.latitude,
              pos.longitude,
              pos.speed,
              bearing: pos.heading,
            );
          },
          onError: (Object e, StackTrace st) {
            debugPrint('[DRIVER_RT] positionStream error: $e');
          },
        );
  }
}
