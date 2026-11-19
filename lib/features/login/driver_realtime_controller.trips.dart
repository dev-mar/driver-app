part of 'driver_realtime_controller.dart';

mixin _DriverRealtimeTripsMixin on StateNotifier<DriverRealtimeState> {
  DriverRealtimeController get _rt => this as DriverRealtimeController;

  static const int _retiredOfferTtlMs = 10 * 60 * 1000;

  void _retireOfferTripId(String tripId) {
    final id = tripId.trim();
    if (id.isEmpty) return;
    _rt._retiredOfferUntilMs[id] =
        DateTime.now().millisecondsSinceEpoch + _retiredOfferTtlMs;
  }

  bool _isRetiredOfferTripId(String tripId) {
    final id = tripId.trim();
    final until = _rt._retiredOfferUntilMs[id];
    if (until == null) return false;
    if (DateTime.now().millisecondsSinceEpoch > until) {
      _rt._retiredOfferUntilMs.remove(id);
      return false;
    }
    return true;
  }

  /// Una sola solicitud visible por pasajero. La más nueva gana.
  /// Una oferta de un viaje ya cerrado no vuelve a entrar.
  bool ingestPendingOffer(DriverTripOffer offer) {
    final tripId = offer.tripId.trim();
    if (tripId.isEmpty || state.activeTrip != null) return false;
    if (_isRetiredOfferTripId(tripId)) return false;

    var list = List<DriverTripOffer>.from(state.pendingOffers);
    final passengerId = offer.passengerIdentityUserId?.trim() ?? '';
    if (passengerId.isNotEmpty) {
      final dropped = <String>[];
      for (final existing in list) {
        if (existing.tripId == tripId) continue;
        final other = existing.passengerIdentityUserId?.trim() ?? '';
        if (other != passengerId) continue;
        final existingAt = existing.tripCreatedAt;
        final incomingAt = offer.tripCreatedAt;
        if (existingAt != null &&
            incomingAt != null &&
            !incomingAt.isAfter(existingAt)) {
          _retireOfferTripId(tripId);
          return false;
        }
        if (existingAt == null || incomingAt == null) continue;
        dropped.add(existing.tripId);
      }
      if (dropped.isNotEmpty) {
        for (final id in dropped) {
          _retireOfferTripId(id);
        }
        list = list.where((o) => !dropped.contains(o.tripId)).toList();
      }
    }

    final index = list.indexWhere((o) => o.tripId == tripId);
    final isNew = index < 0;
    if (index >= 0) {
      final prev = list[index];
      final incomingPrice = offer.offeredPrice;
      final currentPrice = prev.offeredPrice;
      if (incomingPrice != null &&
          currentPrice != null &&
          incomingPrice + 0.009 < currentPrice) {
        return false;
      }
      list[index] = DriverTripOffer(
        tripId: offer.tripId,
        offeredPrice: offer.offeredPrice,
        etaMinutes: offer.etaMinutes,
        etaToDestinationMinutes: offer.etaToDestinationMinutes,
        distanceToPickupKm: offer.distanceToPickupKm,
        passengerIdentityUserId:
            offer.passengerIdentityUserId ?? prev.passengerIdentityUserId,
        tripCreatedAt: offer.tripCreatedAt ?? prev.tripCreatedAt,
        passengerName: offer.passengerName ?? prev.passengerName,
        passengerRating: offer.passengerRating,
        currencyCode: offer.currencyCode,
        originAddress: offer.originAddress,
        destinationAddress: offer.destinationAddress,
        tripDistanceKm: offer.tripDistanceKm,
        requestSource: offer.requestSource,
        dispatchMode: offer.dispatchMode,
        paymentMethod: offer.paymentMethod,
        tripExtras: offer.tripExtras,
        tripSpecials: offer.tripSpecials,
        cashDuePassenger: offer.cashDuePassenger ?? prev.cashDuePassenger,
        companyGuaranteeToDriver:
            offer.companyGuaranteeToDriver ?? prev.companyGuaranteeToDriver,
        promoDiscountAmount: offer.promoDiscountAmount,
        supportAmount: offer.supportAmount,
        supportSource: offer.supportSource,
        pickupLat: offer.pickupLat,
        pickupLng: offer.pickupLng,
        destinationLat: offer.destinationLat,
        destinationLng: offer.destinationLng,
        routeOverviewEncoded: offer.routeOverviewEncoded,
        negotiationEnabled: offer.negotiationEnabled,
      );
    } else {
      list.add(offer);
    }
    state = state.copyWith(
      pendingOffers: list,
      processingOfferTripId: null,
      processingIsAccept: true,
    );
    _clearOfferErrorForTrip(tripId);
    return isNew;
  }

  void _clearOfferErrorForTrip(String tripId) {
    final codeMap = Map<String, String>.from(state.offersErrorCodeByTripId);
    final messageMap = Map<String, String>.from(
      state.offersErrorMessageByTripId,
    );
    codeMap.remove(tripId);
    messageMap.remove(tripId);
    state = state.copyWith(
      offersErrorCodeByTripId: codeMap,
      offersErrorMessageByTripId: messageMap,
    );
  }

  void _setOfferErrorForTrip({
    required String tripId,
    String? code,
    String? message,
  }) {
    final codeMap = Map<String, String>.from(state.offersErrorCodeByTripId);
    final messageMap = Map<String, String>.from(
      state.offersErrorMessageByTripId,
    );
    if (code == null || code.isEmpty) {
      codeMap.remove(tripId);
    } else {
      codeMap[tripId] = code;
    }
    if (message == null || message.isEmpty) {
      messageMap.remove(tripId);
    } else {
      messageMap[tripId] = message;
    }
    state = state.copyWith(
      offersErrorCodeByTripId: codeMap,
      offersErrorMessageByTripId: messageMap,
    );
  }

  bool _shouldIgnoreRestoreTrip(String tripId) {
    final id = state.ignoreActiveTripRestoreTripId;
    final untilMs = state.ignoreActiveTripRestoreUntilMs;
    if (id == null || untilMs == null) return false;
    if (id != tripId) return false;
    return DateTime.now().millisecondsSinceEpoch <= untilMs;
  }

  /// Aviso «Ya salgo»: WS o FCM. Pinta la franja aunque la card esté colapsada.
  void applyPassengerEnRouteNotice({
    required String tripId,
    DateTime? sentAt,
    bool playHaptic = true,
  }) {
    final current = state.activeTrip;
    if (current == null || current.tripId != tripId) return;
    if (current.status != 'arrived' && current.status != 'accepted') return;
    final already = current.passengerEnRouteAt;
    final at = sentAt ?? DateTime.now().toUtc();
    state = state.copyWith(
      activeTrip: current.copyWith(passengerEnRouteAt: at),
    );
    if (playHaptic && already == null) {
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.alert);
    }
  }

  void sendTripChatTemplate({
    required String tripId,
    required String templateCode,
  }) {
    if (!driverTripChatPhaseActive(state.activeTrip?.status)) {
      state = state.copyWith(tripChatErrorCode: 'TRIP_CHAT_NOT_AVAILABLE');
      return;
    }
    final socket = _rt._socket;
    if (socket == null || !socket.connected) {
      state = state.copyWith(tripChatErrorCode: 'SOCKET');
      return;
    }
    socket.emit('trip:chat:send', {
      'tripId': tripId,
      'messageKind': 'template',
      'templateCode': templateCode,
    });
  }

  void sendTripChatText({required String tripId, required String text}) {
    final sanitized = text.trim();
    if (sanitized.isEmpty) return;
    if (!driverTripChatPhaseActive(state.activeTrip?.status)) {
      state = state.copyWith(tripChatErrorCode: 'TRIP_CHAT_NOT_AVAILABLE');
      return;
    }
    final socket = _rt._socket;
    if (socket == null || !socket.connected) {
      state = state.copyWith(tripChatErrorCode: 'SOCKET');
      return;
    }
    socket.emit('trip:chat:send', {
      'tripId': tripId,
      'messageKind': 'text',
      'messageText': sanitized,
    });
  }

  void sendArrivalReminder() {
    final tripId = state.activeTrip?.tripId;
    if (tripId == null || tripId.isEmpty) return;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final cooldownUntilMs = state.arrivalReminderCooldownUntilMs;
    if (cooldownUntilMs != null && cooldownUntilMs > nowMs) {
      return;
    }
    final socket = _rt._socket;
    if (socket == null || !socket.connected) {
      state = state.copyWith(arrivalReminderErrorCode: 'SOCKET');
      return;
    }
    socket.emit('trip:arrival_reminder', {'tripId': tripId});
  }

  Future<bool> submitTripRating({
    required String tripId,
    required int stars,
    List<String> feedbackCodes = const [],
  }) async {
    final normalizedTripId = tripId.trim();
    if (normalizedTripId.isEmpty) return false;
    if (stars < 1 || stars > 5) return false;
    if (_rt._tripRatingInFlight.contains(normalizedTripId)) return false;
    _rt._tripRatingInFlight.add(normalizedTripId);
    try {
      final result = await _rt._tripRest.submitTripRating(
        tripId: normalizedTripId,
        stars: stars,
        feedbackCodes: feedbackCodes,
      );
      return result.claimEligible;
    } catch (_) {
      return false;
    } finally {
      _rt._tripRatingInFlight.remove(normalizedTripId);
    }
  }

  Future<void> submitTripClaim({
    required String tripId,
    required String message,
    int? stars,
    List<String> feedbackCodes = const [],
  }) async {
    await _rt._tripRest.submitTripClaim(
      tripId: tripId,
      message: message,
      stars: stars,
      feedbackCodes: feedbackCodes,
    );
  }

  Future<List<DriverRatingFeedbackItem>> fetchDriverRatingFeedbackCatalog({
    required int stars,
  }) async {
    if (stars < 1 || stars > 5) return const [];
    final inFlight = _rt._ratingCatalogInFlight[stars];
    if (inFlight != null) return inFlight;
    final future = _fetchDriverRatingFeedbackCatalogInternal(stars: stars);
    _rt._ratingCatalogInFlight[stars] = future;
    try {
      return await future;
    } finally {
      _rt._ratingCatalogInFlight.remove(stars);
    }
  }

  Future<List<DriverRatingFeedbackItem>>
  _fetchDriverRatingFeedbackCatalogInternal({required int stars}) async {
    return _rt._tripRest.fetchRatingFeedbackCatalog(stars: stars);
  }

  Future<List<DriverTripCancelReasonItem>> fetchTripCancelReasons({
    required String tripId,
    String? locale,
  }) {
    return _rt._tripRest.fetchTripCancelReasons(tripId: tripId, locale: locale);
  }

  void markArrived() {
    final trip = state.activeTrip;
    if (trip == null || _rt._socket?.connected != true) return;
    if (trip.status != 'accepted') {
      debugPrint('[DRIVER_RT] markArrived ignorado: status=${trip.status}');
      return;
    }
    _rt._logVerbose('Enviando trip:arrived tripId=${trip.tripId}');
    _rt._socket!.emit('trip:arrived', {'tripId': trip.tripId});
    state = state.copyWith(
      activeTrip: trip.copyWith(status: 'arrived'),
      processingTripAction: null,
      tripErrorMessage: null,
    );
  }

  void startTrip() {
    final trip = state.activeTrip;
    if (trip == null || _rt._socket?.connected != true) return;
    if (trip.status != 'arrived') {
      debugPrint('[DRIVER_RT] startTrip ignorado: status=${trip.status}');
      return;
    }
    _rt._logVerbose('Enviando trip:started tripId=${trip.tripId}');
    _rt._socket!.emit('trip:started', {'tripId': trip.tripId});
    state = state.copyWith(
      activeTrip: trip.copyWith(status: 'started'),
      processingTripAction: null,
      tripErrorMessage: null,
    );
  }

  void completeTrip() {
    final trip = state.activeTrip;
    if (trip == null) return;
    if (_shouldIgnoreRestoreTrip(trip.tripId)) {
      debugPrint(
        '[DRIVER_RT] completeTrip ignorado por ignoreActiveTripRestoreTripId tripId=${trip.tripId}',
      );
      return;
    }
    if (trip.status != 'started' && trip.status != 'in_trip') {
      debugPrint('[DRIVER_RT] completeTrip ignorado: status=${trip.status}');
      return;
    }
    final completedTripId = trip.tripId;
    final ignoreUntilMs = DateTime.now()
        .add(const Duration(seconds: 60))
        .millisecondsSinceEpoch;
    state = state.copyWith(
      activeTrip: null,
      tripPendingRating: trip.copyWith(status: 'completed'),
      lastCompletedTripId: completedTripId,
      processingTripAction: null,
      tripErrorMessage: null,
      ignoreActiveTripRestoreTripId: completedTripId,
      ignoreActiveTripRestoreUntilMs: ignoreUntilMs,
    );

    final socketConnected = _rt._socket?.connected == true;
    if (socketConnected) {
      _rt._logVerbose('Enviando trip:completed tripId=$completedTripId');
      try {
        _rt._socket!.emit('trip:completed', {'tripId': completedTripId});
      } catch (e) {
        debugPrint('[DRIVER_RT] Error enviando trip:completed: $e');
        _rt._pendingTripCompletedTripId = completedTripId;
      }
    } else {
      debugPrint(
        '[DRIVER_RT] Socket no conectado; guardando trip:completed pendiente tripId=$completedTripId',
      );
      _rt._pendingTripCompletedTripId = completedTripId;
    }
  }

  void clearActiveTrip() {
    state = state.copyWith(
      activeTrip: null,
      tripPendingRating: state.tripPendingRating,
      processingTripAction: null,
      tripErrorMessage: null,
    );
  }

  /// El pasajero (u otro actor) cerró el viaje mientras el socket no estaba.
  /// Quita la carrera local, no abre calificación y deja aviso en home.
  bool applyRemoteTripCancelled(String tripId) {
    final id = tripId.trim();
    if (id.isEmpty) return false;
    _retireOfferTripId(id);
    final matchesActive = state.activeTrip?.tripId == id;
    final matchesPending = state.tripPendingRating?.tripId == id;
    final hadOffer = state.pendingOffers.any((offer) => offer.tripId == id);
    if (!matchesActive && !matchesPending && !hadOffer) return false;
    final cleanedOffers = state.pendingOffers
        .where((offer) => offer.tripId != id)
        .toList(growable: false);
    if (matchesActive || matchesPending) {
      state = state.copyWith(
        pendingOffers: cleanedOffers,
        activeTrip: null,
        tripPendingRating: null,
        lastCompletedTripId: id,
        processingTripAction: null,
        tripErrorMessage: null,
        errorCode: 'TRIP_ENDED_WHILE_AWAY',
        ignoreActiveTripRestoreTripId: id,
        ignoreActiveTripRestoreUntilMs: DateTime.now()
            .add(const Duration(seconds: 60))
            .millisecondsSinceEpoch,
        chatMessages: const [],
      );
      _clearOfferErrorForTrip(id);
      _rt._setAvailability('available');
      unawaited(_rt._syncDriverForegroundSession());
      return true;
    }
    state = state.copyWith(
      pendingOffers: cleanedOffers,
      processingTripAction: null,
      processingOfferTripId: state.processingOfferTripId == id
          ? null
          : state.processingOfferTripId,
    );
    _clearOfferErrorForTrip(id);
    return true;
  }

  /// `connection:ack` sin viaje activo: el servidor ya no tiene la carrera
  /// (típico: el pasajero canceló con la app en Google Maps).
  void releaseLocalTripIfServerHasNone() {
    final pending = state.tripPendingRating;
    if (pending != null && _shouldIgnoreRestoreTrip(pending.tripId)) {
      if (state.activeTrip?.tripId == pending.tripId) {
        state = state.copyWith(activeTrip: null);
      }
      return;
    }
    final localId = state.activeTrip?.tripId ?? pending?.tripId;
    if (localId == null || localId.isEmpty) return;
    applyRemoteTripCancelled(localId);
  }

  Future<void> clearTripPendingRating() async {
    final completedTripId =
        state.tripPendingRating?.tripId ?? state.lastCompletedTripId;
    state = state.copyWith(
      activeTrip: null,
      tripPendingRating: null,
      processingTripAction: null,
      tripErrorMessage: null,
      ignoreActiveTripRestoreTripId: completedTripId,
      ignoreActiveTripRestoreUntilMs: completedTripId == null
          ? null
          : DateTime.now()
                .add(const Duration(seconds: 60))
                .millisecondsSinceEpoch,
    );
    await _rt._requestAvailableAfterTripIfCreditsAllow();
    if (_rt._disposed) return;
    if (state.insufficientCreditsToGoOnline) return;
    if (_rt._availabilitySessionDesired &&
        !_rt._userRequestedOffline &&
        !state.online) {
      unawaited(_rt._goOnline());
    }
  }

  /// Misma transición local que `trip:accepted` por socket. La usa también el HTTP.
  void applyLocalTripAccepted(Map<String, dynamic> data) {
    _rt._cancelAcceptWatchdog();
    final tripId = data['tripId']?.toString();
    final status = data['status']?.toString() ?? 'accepted';
    final estimatedPriceRaw = data['estimatedPrice'];
    final estimatedPrice = estimatedPriceRaw is num
        ? estimatedPriceRaw.toDouble()
        : null;
    final currencyCode = (data['currencyCode'] ?? data['currency'])?.toString();
    _rt._logVerbose('trip:accepted raw data tripId=$tripId');

    final pickupParsed = parseDriverLatLng(data, 'pickupLat', 'pickupLng');
    final (pickupLat, pickupLng) =
        (pickupParsed.$1 != null && pickupParsed.$2 != null)
        ? pickupParsed
        : parseDriverLatLngFromMap(data['origin']);
    final destParsed = parseDriverLatLng(
      data,
      'destinationLat',
      'destinationLng',
    );
    final (destLat, destLng) = (destParsed.$1 != null && destParsed.$2 != null)
        ? destParsed
        : parseDriverLatLngFromMap(data['destination']);
    final passengerName = data['passengerName']?.toString();
    final passengerRating = parseDriverDouble(data['passengerRating']);
    final originAddress = data['originAddress']?.toString();
    final destinationAddress = data['destinationAddress']?.toString();
    final tripDistanceRaw = data['tripDistanceKm'];
    final tripDistanceKm = tripDistanceRaw is num
        ? tripDistanceRaw.toDouble()
        : null;
    final etaDestRaw = data['etaToDestinationMinutes'];
    final etaToDestinationMinutes = etaDestRaw is num
        ? etaDestRaw.toDouble()
        : null;
    final rawRouteEnc = data['routeOverviewEncoded'];
    final routeOverviewEncoded =
        rawRouteEnc != null && rawRouteEnc.toString().trim().isNotEmpty
        ? rawRouteEnc.toString().trim()
        : null;
    String? paymentFromOffer;
    List<String> extrasFromOffer = const [];
    List<String> specialsFromOffer = const [];
    double? cashDueFromOffer;
    double? guaranteeFromOffer;
    String? supportSourceFromOffer;
    if (tripId != null) {
      for (final o in state.pendingOffers) {
        if (o.tripId == tripId) {
          paymentFromOffer = o.paymentMethod;
          extrasFromOffer = o.tripExtras;
          specialsFromOffer = o.tripSpecials;
          cashDueFromOffer = o.cashDuePassenger;
          guaranteeFromOffer = o.companyGuaranteeToDriver;
          supportSourceFromOffer = o.supportSource;
          break;
        }
      }
    }
    final paymentMethod = normalizeDriverTripPaymentMethod(
      data['paymentMethod'] ?? data['payment_method'] ?? paymentFromOffer,
    );
    final parsedExtras = parseDriverTripExtras(
      data['tripExtras'] ?? data['passenger_extras'] ?? data['extras'],
    );
    final tripExtras = parsedExtras.isNotEmpty ? parsedExtras : extrasFromOffer;
    final parsedSpecials = parseDriverTripSpecials(
      data['tripSpecials'] ?? data['passenger_specials'] ?? data['specials'],
    );
    final tripSpecials = parsedSpecials.isNotEmpty
        ? parsedSpecials
        : specialsFromOffer;
    final cashDuePassenger =
        parseDriverDouble(
          data['cashDuePassenger'] ?? data['cash_due_passenger'],
        ) ??
        cashDueFromOffer;
    final companyGuaranteeToDriver =
        parseDriverDouble(
          data['companyGuaranteeToDriver'] ??
              data['company_guarantee_to_driver'],
        ) ??
        guaranteeFromOffer;
    final supportSource =
        (data['supportSource'] ?? data['support_source'])
            ?.toString()
            .trim() ??
        supportSourceFromOffer;

    if (tripId != null) {
      state = state.copyWith(
        pendingOffers: const [],
        processingOfferTripId: null,
        processingIsAccept: false,
        activeTrip: applyPickupWaitFromPayload(
          DriverActiveTrip(
            tripId: tripId,
            status: status,
            estimatedPrice: estimatedPrice,
            pickupLat: pickupLat,
            pickupLng: pickupLng,
            destinationLat: destLat,
            destinationLng: destLng,
            passengerName: passengerName,
            passengerRating: passengerRating,
            currencyCode: currencyCode,
            originAddress: originAddress,
            destinationAddress: destinationAddress,
            tripDistanceKm: tripDistanceKm,
            etaToDestinationMinutes: etaToDestinationMinutes,
            routeOverviewEncoded: routeOverviewEncoded,
            paymentMethod: paymentMethod,
            tripExtras: tripExtras,
            tripSpecials: tripSpecials,
            cashDuePassenger: cashDuePassenger,
            companyGuaranteeToDriver: companyGuaranteeToDriver,
            supportSource: supportSource,
          ),
          data,
        ),
        processingTripAction: null,
        tripErrorMessage: null,
        chatMessages: const [],
      );
      _clearOfferErrorForTrip(tripId);
      _rt._cancelBackgroundOfferWindow();
    } else {
      state = state.copyWith(processingOfferTripId: null);
    }
    unawaited(_rt._syncDriverForegroundSession());
  }

  Future<void> acceptOffer(String tripId) async {
    if (state.activeTrip != null) {
      debugPrint(
        '[DRIVER_RT] acceptOffer bloqueado: ya hay viaje activo ${state.activeTrip?.tripId}.',
      );
      return;
    }
    if (state.processingOfferTripId != null) {
      debugPrint(
        '[DRIVER_RT] acceptOffer ignorado: ya se procesa ${state.processingOfferTripId}.',
      );
      return;
    }
    final exists = state.pendingOffers.any((offer) => offer.tripId == tripId);
    if (!exists) {
      debugPrint(
        '[DRIVER_RT] acceptOffer llamado con tripId=$tripId que no está en pendingOffers.',
      );
      return;
    }
    if (_rt._socket?.connected != true) {
      await _acceptOfferOverRest(tripId);
      return;
    }

    _rt._logVerbose('Enviando trip:accept tripId=$tripId');
    state = state.copyWith(
      processingOfferTripId: tripId,
      processingIsAccept: true,
    );
    _clearOfferErrorForTrip(tripId);
    _rt._socket!.emit('trip:accept', {'tripId': tripId});
    _armAcceptWatchdog(tripId);
  }

  Future<void> _acceptOfferOverRest(String tripId) async {
    state = state.copyWith(
      processingOfferTripId: tripId,
      processingIsAccept: true,
    );
    _clearOfferErrorForTrip(tripId);
    _armAcceptWatchdog(tripId);
    final result = await _rt._tripRest.acceptTripOffer(tripId);
    if (_rt._disposed) return;
    if (state.activeTrip != null && state.activeTrip!.tripId != tripId) return;
    if (state.processingOfferTripId != null &&
        state.processingOfferTripId != tripId) {
      return;
    }
    final data = result.data;
    if (result.ok && data != null) {
      applyLocalTripAccepted(data);
      return;
    }
    _rt._cancelAcceptWatchdog();
    state = state.copyWith(
      processingOfferTripId: null,
      processingIsAccept: false,
    );
    _setOfferErrorForTrip(
      tripId: tripId,
      code: result.code ?? 'NO_CONNECTION',
      message: null,
    );
  }

  void _cancelAcceptWatchdog() {
    _rt._acceptOfferWatchdog?.cancel();
    _rt._acceptOfferWatchdog = null;
  }

  void _armAcceptWatchdog(String tripId) {
    _cancelAcceptWatchdog();
    _rt._acceptOfferWatchdog = Timer(const Duration(seconds: 15), () {
      if (_rt._disposed) return;
      if (state.processingOfferTripId != tripId) return;
      if (state.activeTrip?.tripId == tripId) return;
      state = state.copyWith(
        processingOfferTripId: null,
        processingIsAccept: false,
      );
      _setOfferErrorForTrip(
        tripId: tripId,
        code: 'ACCEPT_TIMEOUT',
        message: null,
      );
    });
  }

  Future<void> rejectOffer(String tripId) async {
    final exists = state.pendingOffers.any((offer) => offer.tripId == tripId);
    if (!exists) {
      debugPrint(
        '[DRIVER_RT] rejectOffer llamado con tripId=$tripId que no está en pendingOffers.',
      );
      return;
    }
    if (_rt._socket?.connected != true) {
      debugPrint('[DRIVER_RT] rejectOffer sin conexión de socket, abortando.');
      state = state.copyWith();
      _setOfferErrorForTrip(
        tripId: tripId,
        code: 'NO_CONNECTION',
        message: null,
      );
      return;
    }

    _rt._logVerbose('Enviando trip:reject tripId=$tripId');
    final updatedOffers = state.pendingOffers
        .where((offer) => offer.tripId != tripId)
        .toList();
    state = state.copyWith(
      pendingOffers: updatedOffers,
      processingOfferTripId: null,
      processingIsAccept: false,
    );
    _clearOfferErrorForTrip(tripId);
    _rt._socket!.emit('trip:reject', {'tripId': tripId});
  }

  Future<bool> cancelAssignedTrip({
    required String reasonCode,
    String? reasonNote,
  }) async {
    final trip = state.activeTrip;
    if (trip == null) return false;
    if (!driverTripCanCancelAssigned(trip.status)) {
      debugPrint(
        '[DRIVER_RT] cancelAssignedTrip ignorado: status=${trip.status}',
      );
      return false;
    }
    if (state.processingTripAction != null) return false;
    final tripId = trip.tripId;
    state = state.copyWith(
      processingTripAction: 'cancel',
      tripErrorMessage: null,
    );
    try {
      await _rt._tripRest.cancelAssignedTrip(
        tripId: tripId,
        reasonCode: reasonCode,
        reasonNote: reasonNote,
      );
    } catch (e) {
      debugPrint('[DRIVER_RT] cancelAssignedTrip error: $e');
      if (state.activeTrip?.tripId == tripId) {
        state = state.copyWith(
          processingTripAction: null,
          tripErrorMessage: DriverTripRestService.waitBlockReasonOf(e) ??
              'cancel_failed',
        );
      }
      return false;
    }
    if (state.activeTrip?.tripId != tripId) return true;
    state = state.copyWith(
      pendingOffers: state.pendingOffers
          .where((o) => o.tripId != tripId)
          .toList(growable: false),
      activeTrip: null,
      tripPendingRating: null,
      lastCompletedTripId: tripId,
      processingTripAction: null,
      tripErrorMessage: null,
      ignoreActiveTripRestoreTripId: tripId,
      ignoreActiveTripRestoreUntilMs: DateTime.now()
          .add(const Duration(seconds: 60))
          .millisecondsSinceEpoch,
      chatMessages: const [],
    );
    _rt._setAvailability('available');
    unawaited(_rt._syncDriverForegroundSession());
    return true;
  }

  Future<String?> sendCounterOffer(String tripId, double amount) async {
    final code = await _rt._tripRest.sendCounterOffer(
      tripId: tripId,
      amount: amount,
    );
    if (_counterOfferNoLongerAvailable(code)) {
      state = state.copyWith(
        pendingOffers: state.pendingOffers
            .where((offer) => offer.tripId != tripId)
            .toList(growable: false),
        processingOfferTripId: state.processingOfferTripId == tripId
            ? null
            : state.processingOfferTripId,
      );
    }
    return code;
  }
}

bool _counterOfferNoLongerAvailable(String? code) {
  return code == 'BID_NOT_FOUND' ||
      code == 'TRIP_NOT_NEGOTIABLE' ||
      code == 'OFFER_EXPIRED' ||
      code == 'TRIP_ALREADY_ACCEPTED' ||
      code == 'TRIP_ALREADY_PROCESSED' ||
      code == 'TRIP_TAKEN' ||
      code == 'TRIP_NOT_AVAILABLE';
}
