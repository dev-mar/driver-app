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

  void _cancelPresenceHeartbeat() {
    _rt._presenceHeartbeatTimer?.cancel();
    _rt._presenceHeartbeatTimer = null;
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
    try {
      final initialPos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).timeout(const Duration(seconds: 15));
      if (_rt._disposed) return;
      state = state.copyWith(
        driverLat: initialPos.latitude,
        driverLng: initialPos.longitude,
        driverBearing: initialPos.heading,
      );
      if (_rt._socket?.connected == true) {
        _emitLocationToServer(
          initialPos.latitude,
          initialPos.longitude,
          initialPos.speed,
          bearing: initialPos.heading,
          force: true,
        );
      }
    } catch (e) {
      debugPrint('[DRIVER_RT] getCurrentPosition inicial falló: $e');
    }

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
            state = state.copyWith(
              driverLat: pos.latitude,
              driverLng: pos.longitude,
              driverBearing: pos.heading,
            );
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
