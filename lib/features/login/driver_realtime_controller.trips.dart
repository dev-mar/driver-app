part of 'driver_realtime_controller.dart';

mixin _DriverRealtimeTripsMixin on StateNotifier<DriverRealtimeState> {
  DriverRealtimeController get _rt => this as DriverRealtimeController;

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
      debugPrint('[DRIVER_RT] acceptOffer sin conexión de socket, abortando.');
      state = state.copyWith();
      _setOfferErrorForTrip(
        tripId: tripId,
        code: 'NO_CONNECTION',
        message: null,
      );
      return;
    }

    _rt._logVerbose('Enviando trip:accept tripId=$tripId');
    state = state.copyWith(
      processingOfferTripId: tripId,
      processingIsAccept: true,
    );
    _clearOfferErrorForTrip(tripId);
    _rt._socket!.emit('trip:accept', {'tripId': tripId});
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
}
