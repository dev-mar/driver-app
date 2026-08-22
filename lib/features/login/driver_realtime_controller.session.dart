part of 'driver_realtime_controller.dart';

mixin _DriverRealtimeSessionMixin on StateNotifier<DriverRealtimeState> {
  DriverRealtimeController get _rt => this as DriverRealtimeController;

  /// `connection:ack.profile`: nombre, vehículo y valoración para el mini perfil del home.
  void _applyProfileFromAck(Map<String, dynamic> data) {
    final profileRaw = data['profile'];
    if (profileRaw is! Map) return;
    final map = Map<String, dynamic>.from(profileRaw);
    final fn = map['fullName']?.toString().trim();
    String? vehicleLabel;
    final vehicle = map['vehicle'];
    if (vehicle is Map) {
      vehicleLabel = buildDriverVehicleLabelFromAckMap(
        Map<String, dynamic>.from(vehicle),
      );
    }
    vehicleLabel ??= buildDriverVehicleLabelFromFleetList(map['fleetVehicles']);
    double? rating;
    final r = map['averageRating'] ?? map['rating'] ?? map['driverRating'];
    if (r is num) rating = r.toDouble();
    String? picture;
    final picRaw = map['pictureProfile'] ?? map['picture_profile'];
    if (picRaw != null) {
      final p = picRaw.toString().trim();
      if (p.isNotEmpty) picture = p;
    }
    DateTime? pictureExpiresAt;
    final expRaw =
        map['profilePictureExpiresAt'] ?? map['profile_picture_expires_at'];
    if (expRaw != null) {
      final t = expRaw.toString().trim();
      if (t.isNotEmpty) pictureExpiresAt = DateTime.tryParse(t);
    }

    final newName = (fn != null && fn.isNotEmpty)
        ? fn
        : state.driverDisplayName;
    final newVehicle = vehicleLabel ?? state.driverVehicleLabel;
    final newRating = rating ?? state.driverRating;

    Object? hasVehicleUpd = DriverRealtimeState.copyWithUnset;
    final hv = map['hasVehicle'];
    if (hv is bool) {
      hasVehicleUpd = hv;
    } else {
      final vc = map['vehicleCount'] ?? map['vehicle_count'];
      if (vc is num) {
        hasVehicleUpd = vc.toInt() >= 1;
      }
    }

    state = state.copyWith(
      driverDisplayName: newName,
      driverVehicleLabel: newVehicle,
      driverRating: newRating,
      driverPictureProfile: picture ?? state.driverPictureProfile,
      driverPictureExpiresAt: pictureExpiresAt ?? state.driverPictureExpiresAt,
      hasVehicleRegistered: hasVehicleUpd,
    );
  }

  bool _isAuthSocketErrorCode(String code) => code == 'AUTH';

  Future<bool> _tryRefreshDriverSession() async {
    final refreshToken = await DriverSecureStorage.read(
      'driver_refresh_token',
    );
    if (refreshToken == null || refreshToken.isEmpty) {
      debugPrint('[DRIVER_RT] No hay refresh token para renovar sesión.');
      return false;
    }
    final ok = await _rt._tripRest.tryRefreshSession();
    if (ok) {
      debugPrint('[DRIVER_RT] Refresh de sesión OK. Reintentando socket...');
    } else {
      debugPrint('[DRIVER_RT] Refresh de sesión falló.');
    }
    return ok;
  }

  Future<void> _stopRealtimeAndInvalidateSession() async {
    _rt._userRequestedOffline = true;
    _rt._availabilitySessionDesired = false;
    state = state.copyWith(
      availabilityDesired: false,
      errorCode: state.errorCode,
    );
    _rt._cancelTripReconnectLoop();
    _rt._cancelAvailabilityReconnectLoop();
    _rt._lastTouchReconnect = null;
    _rt._pendingTripCompletedTripId = null;
    await DriverMapPreferencesStore.clearMapPreferencesForCurrentSession();
    await DriverSecureStorage.delete('driver_token');
    await DriverSecureStorage.delete('driver_refresh_token');
    await DriverMustChangePasswordGate.clear();
    await _goOffline(
      internal: true,
      preserveTripState: false,
      retainConnectingIndicator: false,
    );
  }

  bool _shouldRefreshDriverPhoto() {
    final pic = state.driverPictureProfile?.trim() ?? '';
    final exp = state.driverPictureExpiresAt;
    if (pic.isEmpty) return true;
    if (exp == null) return false;
    final now = DateTime.now();
    return now.isAfter(exp.subtract(const Duration(minutes: 2)));
  }

  Future<void> _refreshDriverPhotoFromProfile({bool force = false}) async {
    if (!force && !_shouldRefreshDriverPhoto()) return;
    final last = _rt._lastDriverPhotoRefreshAt;
    final now = DateTime.now();
    if (!force &&
        last != null &&
        now.difference(last) < const Duration(seconds: 30)) {
      return;
    }
    if (_rt._isRefreshingDriverPhoto) return;

    _rt._isRefreshingDriverPhoto = true;
    try {
      final snapshot = await _rt._tripRest.fetchProfilePictureSnapshot();
      if (snapshot != null) {
        state = state.copyWith(
          driverPictureProfile: snapshot.pictureUrl,
          driverPictureExpiresAt: snapshot.expiresAt,
        );
      }
      _rt._lastDriverPhotoRefreshAt = DateTime.now();
    } catch (_) {
      // Fallo silencioso: la UI conserva última foto válida/fallback.
    } finally {
      _rt._isRefreshingDriverPhoto = false;
    }
  }

  /// [forceOffline]: logout u otros casos que deben cortar sesión aunque haya viaje activo.
  Future<void> setOnline(bool value, {bool forceOffline = false}) async {
    if (value == state.online &&
        !state.connecting &&
        !(forceOffline && !value)) {
      return;
    }
    if (value) {
      if (state.activeTrip == null && state.tripPendingRating == null) {
        await refreshGoOnlineGuards();
      }
      if (state.accountBlocked &&
          state.activeTrip == null &&
          state.tripPendingRating == null) {
        state = state.copyWith(errorCode: 'DRIVER_ACCOUNT_BLOCKED');
        return;
      }
      if (state.hasVehicleRegistered == false &&
          state.activeTrip == null &&
          state.tripPendingRating == null) {
        state = state.copyWith(errorCode: 'DRIVER_VEHICLE_REQUIRED');
        return;
      }
      if (state.insufficientCreditsToGoOnline &&
          state.activeTrip == null &&
          state.tripPendingRating == null) {
        state = state.copyWith(errorCode: 'DRIVER_CREDITS_BELOW_MIN');
        return;
      }
      if (state.goOnlineBlocked &&
          state.activeTrip == null &&
          state.tripPendingRating == null) {
        state = state.copyWith(errorCode: 'DRIVER_GO_ONLINE_BLOCKED');
        return;
      }
      _rt._userRequestedOffline = false;
      _rt._availabilitySessionDesired = true;
      state = state.copyWith(
        availabilityDesired: true,
        errorCode: state.errorCode,
      );
      _rt._cancelAvailabilityReconnectLoop();
      await _goOnline();
      return;
    }
    if (!forceOffline &&
        (state.activeTrip != null || state.tripPendingRating != null)) {
      state = state.copyWith(errorCode: 'ACTIVE_TRIP_CANT_GO_OFFLINE');
      return;
    }
    _rt._userRequestedOffline = true;
    _rt._availabilitySessionDesired = false;
    state = state.copyWith(
      availabilityDesired: false,
      errorCode: state.errorCode,
    );
    _rt._cancelTripReconnectLoop();
    _rt._cancelAvailabilityReconnectLoop();
    _rt._lastTouchReconnect = null;
    await _goOffline(userInitiated: true, preserveTripState: false);
    if (forceOffline) {
      _rt._pendingTripCompletedTripId = null;
      _rt._locationPermissionCached = null;
      _rt._locationPermissionCachedAt = null;
      _rt._lastDriverPhotoRefreshAt = null;
      state = state.copyWith(
        driverDisplayName: null,
        driverVehicleLabel: null,
        driverRating: null,
        driverPictureProfile: null,
        driverPictureExpiresAt: null,
        lastCompletedTripId: null,
        ignoreActiveTripRestoreTripId: null,
        ignoreActiveTripRestoreUntilMs: null,
        hasVehicleRegistered: null,
        creditsOnlineGateEnabled: false,
      );
    }
  }

  /// Sincroniza gates operativos desde backend antes de intentar pasar a online.
  Future<void> refreshGoOnlineGuards() async {
    try {
      final sm = await _rt._tripRest.fetchGoOnlineStatusRaw();
      if (sm == null) return;
      final blocked = parseDriverBool(
        sm['goOnlineBlocked'] ?? sm['go_online_blocked'],
      );
      final reasonRaw = sm['goOnlineBlockReason'] ?? sm['go_online_block_reason'];
      final reason = reasonRaw?.toString().trim();
      final accountBlocked = parseDriverBool(
        sm['accountBlocked'] ?? sm['account_blocked'],
      );
      final accountReasonRaw =
          sm['accountBlockReason'] ?? sm['account_block_reason'];
      final accountReason = accountReasonRaw?.toString().trim();
      final creditsBlocked = parseDriverBool(
        sm['insufficientCreditsToGoOnline'] ??
            sm['insufficient_credits_to_go_online'],
      );
      final minCreditsRaw =
          sm['minCreditsToGoOnline'] ?? sm['min_credits_to_go_online'];
      final balanceRaw =
          sm['driverCreditsBalance'] ?? sm['driver_credits_balance'];
      final minCredits = minCreditsRaw is num
          ? minCreditsRaw.toDouble()
          : state.minCreditsToGoOnline;
      final creditsBalance = balanceRaw is num
          ? balanceRaw.toDouble()
          : state.driverCreditsBalance;
      final creditsGateOn = parseDriverBool(
        sm['creditsOnlineGateEnabled'] ?? sm['credits_online_gate_enabled'],
      );
      final clearBlockedError =
          (state.errorCode == 'DRIVER_GO_ONLINE_BLOCKED' && !blocked) ||
          (state.errorCode == 'DRIVER_CREDITS_BELOW_MIN' && !creditsBlocked) ||
          (state.errorCode == 'DRIVER_ACCOUNT_BLOCKED' && !accountBlocked);
      state = state.copyWith(
        goOnlineBlocked: blocked,
        goOnlineBlockReason: (reason != null && reason.isNotEmpty) ? reason : null,
        accountBlocked: accountBlocked,
        accountBlockReason: (accountReason != null && accountReason.isNotEmpty)
            ? accountReason
            : null,
        insufficientCreditsToGoOnline: creditsBlocked,
        minCreditsToGoOnline: minCredits,
        driverCreditsBalance: creditsBalance,
        creditsOnlineGateEnabled: creditsGateOn,
        errorCode: clearBlockedError ? null : state.errorCode,
      );
    } catch (_) {
      // No bloquea el flujo si falla sync.
    }
  }

  Future<void> _goOnline() async {
    if (_rt._goOnlineRun != null) {
      await _rt._goOnlineRun;
      return;
    }
    final run = _performGoOnline();
    _rt._goOnlineRun = run;
    try {
      await run;
    } finally {
      if (identical(_rt._goOnlineRun, run)) {
        _rt._goOnlineRun = null;
      }
    }
  }

  Future<void> _performGoOnline({bool allowAuthRefreshRetry = true}) async {
    _rt._logVerbose('setOnline(true) iniciando...');
    _rt._cancelTripReconnectLoop();
    _rt._cancelAvailabilityReconnectLoop();
    state = state.copyWith(
      connecting: true,
      errorCode: null,
      driverDisplayName: null,
      driverVehicleLabel: null,
      driverRating: null,
      driverPictureProfile: null,
      driverPictureExpiresAt: null,
    );

    try {
      final connList = await Connectivity().checkConnectivity();
      final hasConnection =
          connList.isNotEmpty &&
          !(connList.length == 1 && connList.first == ConnectivityResult.none);
      if (!hasConnection) {
        debugPrint('[DRIVER_RT] Sin conexión a internet. result=$connList');
        throw const DriverRealtimeException('NO_INTERNET');
      }

      final token = await DriverSecureStorage.read(
        'driver_token',
      );
      if (token == null || token.isEmpty) {
        debugPrint('[DRIVER_RT] Token de conductor vacío o nulo.');
        throw const DriverRealtimeException('NO_TOKEN');
      }
      _rt._logVerbose('Token leído. length=${token.length}');

      await _rt._ensureLocationPermissionForSocket();
      await _rt._ensureLocationServiceEnabled();
      await _rt._ensureNotificationPermissionForTripOffers();

      _rt._logVerbose(
        'Conectando socket a ${DriverRealtimeConfig.socketUrl}${DriverRealtimeConfig.socketPath}...',
      );

      final socket = createDriverRealtimeSocket(token: token);
      final completer = Completer<void>();
      _rt._bindDriverRealtimeSocketHandlers(socket, completer);

      _rt._socket = socket;
      await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('[DRIVER_RT] Timeout 15s esperando conexión al socket.');
          throw const DriverRealtimeException('SOCKET');
        },
      );

      state = state.copyWith(online: true, connecting: false, errorCode: null);
      _rt._availabilityReconnectAttempts = 0;
      _rt._tripReconnectAttempts = 0;
      _rt._lastTouchReconnect = null;
      _rt._cancelTripReconnectLoop();
      _rt._cancelAvailabilityReconnectLoop();
      debugPrint('[DRIVER_RT] Estado online=true (GPS en segundo plano).');
      unawaited(DriverPushTokenService.instance.syncTokenIfPossible());
      unawaited(_rt._startGpsTracking());
      await _syncDriverForegroundSession();
    } on DriverRealtimeException catch (e) {
      debugPrint('[DRIVER_RT] Error controlado: ${e.code}');
      if (_isAuthSocketErrorCode(e.code) && allowAuthRefreshRetry) {
        final refreshed = await _tryRefreshDriverSession();
        if (refreshed) {
          await _goOffline(
            internal: true,
            preserveTripState: false,
            preservePendingOffers: true,
          );
          await _performGoOnline(allowAuthRefreshRetry: false);
          return;
        }
        await _stopRealtimeAndInvalidateSession();
        state = state.copyWith(
          online: false,
          connecting: false,
          errorCode: 'AUTH',
        );
        return;
      }

      final preserveTrip =
          state.activeTrip != null || state.tripPendingRating != null;
      await _goOffline(
        internal: true,
        preserveTripState: preserveTrip,
        preservePendingOffers: true,
      );
      state = state.copyWith(
        online: false,
        connecting: false,
        errorCode: e.code,
      );
      if (preserveTrip) {
        _rt._ensureTripReconnectLoop();
      } else if (_rt._availabilitySessionDesired && !_rt._userRequestedOffline) {
        _rt._ensureAvailabilityReconnectLoop();
      }
    } catch (e, stackTrace) {
      debugPrint('[DRIVER_RT] Error inesperado al ir online: $e');
      debugPrint('[DRIVER_RT] $stackTrace');
      final preserveTrip =
          state.activeTrip != null || state.tripPendingRating != null;
      await _goOffline(
        internal: true,
        preserveTripState: preserveTrip,
        preservePendingOffers: true,
      );
      state = state.copyWith(
        online: false,
        connecting: false,
        errorCode: 'UNKNOWN',
      );
      if (preserveTrip) {
        _rt._ensureTripReconnectLoop();
      } else if (_rt._availabilitySessionDesired && !_rt._userRequestedOffline) {
        _rt._ensureAvailabilityReconnectLoop();
      }
    }
  }

  Future<void> _syncDriverForegroundSession() async {
    final err = state.errorCode;
    final rbacBlocked = err != null && err.startsWith('RBAC_');
    final availabilitySessionActive =
        !_rt._disposed &&
        !_rt._userRequestedOffline &&
        _rt._availabilitySessionDesired &&
        !rbacBlocked;

    await DriverForegroundSession.instance.sync(
      availabilitySessionActive: availabilitySessionActive,
      pendingOfferCount: state.pendingOffers.length,
      hasActiveTrip: state.activeTrip != null,
    );
  }

  Future<void> _goOffline({
    bool internal = false,
    bool userInitiated = false,
    bool preserveTripState = false,
    bool retainConnectingIndicator = false,
    bool preservePendingOffers = false,
  }) async {
    await _rt._positionSub?.cancel();
    _rt._positionSub = null;
    _rt._lastLocationEmittedAt = null;
    _rt._cancelPresenceHeartbeat();

    if (userInitiated) {
      await _rt._emitAvailabilityOnBreakBeforeDisconnect();
    }

    try {
      _rt._suppressNextDisconnectHandling = true;
      _rt._socket?.disconnect();
      _rt._socket?.dispose();
    } catch (_) {}
    _rt._socket = null;

    if (_rt._disposed) {
      return;
    }

    final preserve =
        preserveTripState &&
        (state.activeTrip != null || state.tripPendingRating != null);

    state = state.copyWith(
      online: false,
      connecting: retainConnectingIndicator,
      availabilityDesired: userInitiated ? false : state.availabilityDesired,
      errorCode: userInitiated ? null : (internal ? state.errorCode : null),
      pendingOffers: preservePendingOffers ? state.pendingOffers : const [],
      processingOfferTripId: preservePendingOffers
          ? state.processingOfferTripId
          : null,
      processingIsAccept: preservePendingOffers
          ? state.processingIsAccept
          : true,
      offersErrorCodeByTripId: preservePendingOffers
          ? state.offersErrorCodeByTripId
          : const {},
      offersErrorMessageByTripId: preservePendingOffers
          ? state.offersErrorMessageByTripId
          : const {},
      activeTrip: preserve ? state.activeTrip : null,
      tripPendingRating: preserve ? state.tripPendingRating : null,
      processingTripAction: preserve ? state.processingTripAction : null,
      tripErrorMessage: preserve ? state.tripErrorMessage : null,
      tripErrorCode: preserve ? state.tripErrorCode : null,
      driverLat: preserve ? state.driverLat : null,
      driverLng: preserve ? state.driverLng : null,
      driverBearing: preserve ? state.driverBearing : null,
    );
    unawaited(_syncDriverForegroundSession());
  }

  Future<void> _refreshDriverAppCreditsBalance() async {
    if (_rt._disposed) return;
    try {
      final snapshot = await _rt._tripRest.fetchAppCreditsSnapshot();
      if (snapshot == null || _rt._disposed) return;
      state = state.copyWith(
        driverCreditsBalance: snapshot.balance,
        minCreditsToGoOnline: snapshot.minCreditsToGoOnline,
        creditsOnlineGateEnabled: snapshot.onlineGateEnabled,
        insufficientCreditsToGoOnline: snapshot.insufficientCreditsToGoOnline,
      );
    } catch (_) {
      /* best-effort */
    }
  }

  DriverTripOffer _tripOfferFromFcmPayload(Map<String, String> data) {
    return driverTripOfferFromMap(data);
  }

  Future<bool> onNotificationOpenedWithTripOffer(
    Map<String, String> data,
  ) async {
    if (_rt._disposed) return false;
    if (_rt._userRequestedOffline || !_rt._availabilitySessionDesired) {
      return false;
    }
    final tripId = data['tripId']?.trim() ?? '';
    if (tripId.isEmpty) return false;

    final offer = _tripOfferFromFcmPayload(data);
    final list = List<DriverTripOffer>.from(state.pendingOffers);
    final ix = list.indexWhere((o) => o.tripId == tripId);
    if (ix >= 0) {
      list[ix] = offer;
    } else {
      list.add(offer);
    }
    state = state.copyWith(pendingOffers: list);
    _rt._clearOfferErrorForTrip(tripId);
    unawaited(_syncDriverForegroundSession());

    await setOnline(true);
    _rt.touchReconnectIfWantedOnline();
    return true;
  }

  void resyncForegroundService() {
    unawaited(_syncDriverForegroundSession());
  }

  /// Fuerza sincronización de viaje activo vía reconexión (connection:ack).
  Future<void> syncActiveTripFromApi({bool force = false}) async {
    if (_rt._disposed) return;
    if (!force && state.activeTrip != null) return;
    if (!state.online) {
      if (_rt._availabilitySessionDesired || force) {
        await setOnline(true);
      }
      return;
    }
    if (force &&
        (state.activeTrip != null || state.tripPendingRating != null)) {
      _rt.touchReconnectIfHasActiveWork();
    }
  }
}
