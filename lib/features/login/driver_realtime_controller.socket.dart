part of 'driver_realtime_controller.dart';

mixin _DriverRealtimeSocketMixin on StateNotifier<DriverRealtimeState> {
  DriverRealtimeController get _rt => this as DriverRealtimeController;

/// Registra todos los listeners Socket.IO del conductor (sin cambiar contrato WS).
void _bindDriverRealtimeSocketHandlers(
  io.Socket socket,
  Completer<void> completer,
) {
        socket.onDisconnect((data) {
          _rt._logVerbose('disconnect data=$data');
          if (_rt._disposed) return;
          if (_rt._userRequestedOffline) return;
          if (_rt._suppressNextDisconnectHandling) {
            _rt._suppressNextDisconnectHandling = false;
            return;
          }
          final hasTrip =
              state.activeTrip != null || state.tripPendingRating != null;
          if (hasTrip) {
            unawaited(_rt._handleUnexpectedDisconnectWithTrip());
            return;
          }
          // Sin viaje activo: el SO suele cortar el WebSocket en segundo plano;
          // reconectar para no apagar el interruptor ni perder ofertas/FCM.
          unawaited(_rt._handleUnexpectedDisconnectWhileAvailable());
        });
  
        socket.onConnect((_) {
          _rt._logVerbose('Socket conectado correctamente.');
          if (!completer.isCompleted) completer.complete();
          // AlineaciÃ³n con el contrato: al estar online, el conductor debe
          // estar en disponibilidad "available" para recibir ofertas.
          _rt._setAvailability('available');
          _rt._startPresenceHeartbeat();
          socket.emit('driver:heartbeat', {
            'clientTs': DateTime.now().toIso8601String(),
          });
          // Reintento seguro de finalizaciÃ³n pendiente.
          final pending = _rt._pendingTripCompletedTripId;
          if (pending != null) {
            _rt._logVerbose('Reintentando trip:completed pendiente tripId=$pending');
            try {
              socket.emit('trip:completed', {'tripId': pending});
            } catch (e) {
              debugPrint('[DRIVER_RT] Error reintentando trip:completed: $e');
              return;
            }
            _rt._pendingTripCompletedTripId = null;
          }
        });
        socket.onConnectError((data) {
          _rt._logVerbose('onConnectError recibido. data=$data');
          if (!completer.isCompleted) {
            completer.completeError(
              DriverRealtimeException(socketConnectErrorToCode(data)),
            );
          }
        });
        socket.onError((data) {
          _rt._logVerbose('onError recibido en socket. data=$data');
          if (!completer.isCompleted) {
            completer.completeError(
              DriverRealtimeException(socketConnectErrorToCode(data)),
            );
          }
        });
        socket.on('driver:availability_ack', (data) {
          _rt._logVerbose('driver:availability_ack data=$data');
        });
        socket.on('driver:availability_error', (data) {
          debugPrint('[DRIVER_RT] driver:availability_error data=$data');
          if (data is Map) {
            final code = data['code']?.toString();
            if (code == 'DRIVER_GO_ONLINE_BLOCKED') {
              final msg = data['message']?.toString().trim();
              state = state.copyWith(
                goOnlineBlocked: true,
                goOnlineBlockReason: (msg != null && msg.isNotEmpty) ? msg : null,
                errorCode: 'DRIVER_GO_ONLINE_BLOCKED',
                availabilityDesired: false,
              );
              _rt._availabilitySessionDesired = false;
              return;
            }
            if (code == 'DRIVER_CREDITS_BELOW_MIN') {
              final minRaw = data['minCreditsToGoOnline'];
              final balanceRaw = data['driverCreditsBalance'];
              state = state.copyWith(
                insufficientCreditsToGoOnline: true,
                minCreditsToGoOnline: minRaw is num
                    ? minRaw.toDouble()
                    : state.minCreditsToGoOnline,
                driverCreditsBalance: balanceRaw is num
                    ? balanceRaw.toDouble()
                    : state.driverCreditsBalance,
                errorCode: 'DRIVER_CREDITS_BELOW_MIN',
                availabilityDesired: false,
              );
              _rt._availabilitySessionDesired = false;
              return;
            }
            if (code == 'DRIVER_ACCOUNT_BLOCKED') {
              final msg = data['message']?.toString().trim();
              state = state.copyWith(
                accountBlocked: true,
                accountBlockReason: (msg != null && msg.isNotEmpty) ? msg : null,
                errorCode: 'DRIVER_ACCOUNT_BLOCKED',
                availabilityDesired: false,
              );
              _rt._availabilitySessionDesired = false;
              return;
            }
            if (code != null && code.startsWith('RBAC_')) {
              state = state.copyWith(
                online: false,
                connecting: false,
                errorCode: code,
              );
              unawaited(_rt._syncDriverForegroundSession());
            }
          }
        });
  
        socket.on('gps:error', (data) {
          debugPrint('[DRIVER_RT] gps:error data=$data');
          if (data is Map) {
            final code = data['code']?.toString();
            if (code != null && code.startsWith('RBAC_')) {
              state = state.copyWith(
                online: false,
                connecting: false,
                errorCode: code,
              );
              unawaited(_rt._syncDriverForegroundSession());
            }
          }
        });
  
        // Listeners de viajes (servidor â†’ conductor).
        socket.on('trip:offer', (data) {
          try {
            if (data is! Map) return;
            final newOffer = driverTripOfferFromMap(data);
            final tripId = newOffer.tripId;
            if (tripId.isEmpty) return;
  
            _rt._logVerbose(
              'trip:offer recibido tripId=$tripId, source=${newOffer.requestSource}, '
              'price=${newOffer.offeredPrice}, eta=${newOffer.etaMinutes}',
            );
  
            // Segundo plano / app cerrada: FCM desde backend (`sendDriverTripOffer`).
            // En primer plano: beep si el conductor estÃ¡ libre (lista + socket).
            final inForeground = DriverAppVisibility.isInForeground.value;
            final isBusy = state.activeTrip != null;
  
            final existingIndex = state.pendingOffers.indexWhere(
              (offer) => offer.tripId == tripId,
            );
            final isNewOffer = existingIndex < 0;
  
            if (inForeground && isNewOffer && !isBusy) {
              SystemSound.play(SystemSoundType.alert);
            }
  
            final updatedOffers = List<DriverTripOffer>.from(state.pendingOffers);
            if (existingIndex >= 0) {
              updatedOffers[existingIndex] = newOffer;
            } else {
              updatedOffers.add(newOffer);
            }
  
            state = state.copyWith(
              pendingOffers: updatedOffers,
              // Al recibir una nueva oferta, limpiamos estados previos de procesamiento/errores.
              processingOfferTripId: null,
              processingIsAccept: true,
            );
            _rt._clearOfferErrorForTrip(tripId);
            unawaited(_rt._syncDriverForegroundSession());
          } catch (e) {
            debugPrint('[DRIVER_RT] Error parseando trip:offer: $e');
          }
        });
  
        socket.on('trip:accepted', (data) {
          try {
            if (data is! Map) return;
            final tripId = data['tripId']?.toString();
            final status = data['status']?.toString() ?? 'accepted';
            final estimatedPriceRaw = data['estimatedPrice'];
            final estimatedPrice = estimatedPriceRaw is num
                ? estimatedPriceRaw.toDouble()
                : null;
            final currencyCode = (data['currencyCode'] ?? data['currency'])
                ?.toString();
            _rt._logVerbose('trip:accepted raw data=$data');
  
            final pickupParsed = parseDriverLatLng(data, 'pickupLat', 'pickupLng');
            final (
              pickupLat,
              pickupLng,
            ) = (pickupParsed.$1 != null && pickupParsed.$2 != null)
                ? pickupParsed
                : parseDriverLatLngFromMap(data['origin']);
            final destParsed = parseDriverLatLng(
              data,
              'destinationLat',
              'destinationLng',
            );
            final (
              destLat,
              destLng,
            ) = (destParsed.$1 != null && destParsed.$2 != null)
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
            _rt._logVerbose(
              'trip:accepted recibido tripId=$tripId status=$status '
              'pickup=($pickupLat,$pickupLng) dest=($destLat,$destLng)',
            );
  
            if (tripId != null) {
              final updatedOffers = state.pendingOffers
                  .where((offer) => offer.tripId != tripId)
                  .toList();
              state = state.copyWith(
                pendingOffers: updatedOffers,
                processingOfferTripId: null,
                activeTrip: DriverActiveTrip(
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
                ),
                processingTripAction: null,
                tripErrorMessage: null,
                chatMessages: const [],
              );
              _rt._clearOfferErrorForTrip(tripId);
            } else {
              state = state.copyWith(processingOfferTripId: null);
            }
            unawaited(_rt._syncDriverForegroundSession());
          } catch (e) {
            debugPrint('[DRIVER_RT] Error manejando trip:accepted: $e');
          }
        });
  
        socket.on('trip:rejected', (data) {
          try {
            if (data is! Map) return;
            final tripId = data['tripId']?.toString();
            _rt._logVerbose('trip:rejected recibido tripId=$tripId');
  
            if (tripId != null) {
              final updatedOffers = state.pendingOffers
                  .where((offer) => offer.tripId != tripId)
                  .toList();
              state = state.copyWith(
                pendingOffers: updatedOffers,
                processingOfferTripId: null,
              );
              _rt._clearOfferErrorForTrip(tripId);
            } else {
              state = state.copyWith(processingOfferTripId: null);
            }
            unawaited(_rt._syncDriverForegroundSession());
          } catch (e) {
            debugPrint('[DRIVER_RT] Error manejando trip:rejected: $e');
          }
        });
  
        socket.on('trip:error', (data) {
          try {
            if (data is! Map) return;
            final code = data['code']?.toString();
            final message = data['message']?.toString();
            final tripId = data['tripId']?.toString();
            debugPrint('[DRIVER_RT] trip:error code=$code message=$message');
  
            final normalized = code?.trim().toUpperCase();
            final isOfferNoLongerAvailable =
                normalized == 'OFFER_EXPIRED' ||
                normalized == 'TRIP_ALREADY_PROCESSED' ||
                normalized == 'TRIP_NOT_AVAILABLE' ||
                normalized == 'TRIP_TAKEN' ||
                normalized == 'OFFER_ALREADY_TAKEN';
  
            final targetTripId = (tripId != null && tripId.isNotEmpty)
                ? tripId
                : state.processingOfferTripId;
            final updatedOffers =
                (isOfferNoLongerAvailable && targetTripId != null)
                ? state.pendingOffers
                      .where((offer) => offer.tripId != targetTripId)
                      .toList()
                : state.pendingOffers;
  
            state = state.copyWith(
              pendingOffers: updatedOffers,
              processingOfferTripId: null,
              processingTripAction: null,
              tripErrorMessage: message,
              tripErrorCode: normalized ?? 'TRIP_UPDATE_FAILED',
              arrivalReminderErrorCode: null,
            );
            if (targetTripId != null && targetTripId.isNotEmpty) {
              _rt._setOfferErrorForTrip(
                tripId: targetTripId,
                code: normalized,
                message: message,
              );
            }
          } catch (e) {
            debugPrint('[DRIVER_RT] Error manejando trip:error: $e');
          }
        });
  
        // Algunos backends envÃ­an un solo evento trip:status con { tripId, status }.
        socket.on('trip:status', (data) {
          try {
            if (data is! Map) return;
            final tripId = extractTripIdFromPayload(data);
            final newStatusRaw = data['status']?.toString();
            final newStatus = newStatusRaw?.trim().toLowerCase();
            final isFinal =
                parseDriverBool(data['isFinal']) ||
                newStatus == 'completed' ||
                newStatus == 'cancelled' ||
                newStatus == 'expired';
            if (tripId == null || newStatus == null) return;
            debugPrint(
              '[DRIVER_RT] trip:status tripId=$tripId status=$newStatus',
            );
            final activeTripMatches = state.activeTrip?.tripId == tripId;
            final pendingContainsTrip = state.pendingOffers.any(
              (o) => o.tripId == tripId,
            );
            final cleanedPendingOffers = state.pendingOffers
                .where((o) => o.tripId != tripId)
                .toList(growable: false);
  
            if (isFinal && pendingContainsTrip && !activeTripMatches) {
              state = state.copyWith(
                pendingOffers: cleanedPendingOffers,
                processingOfferTripId: state.processingOfferTripId == tripId
                    ? null
                    : state.processingOfferTripId,
              );
              _rt._clearOfferErrorForTrip(tripId);
              unawaited(_rt._syncDriverForegroundSession());
              return;
            }
  
            if (!activeTripMatches) return;
            // Actualizamos estado y, si es estado final, sacamos el mapa
            // inmediatamente para evitar que quede la ruta pintada.
            if (isFinal &&
                (newStatus == 'completed' ||
                    newStatus == 'cancelled' ||
                    newStatus == 'expired')) {
              if (newStatus == 'completed') {
                final ignoreUntilMs = DateTime.now()
                    .add(const Duration(seconds: 60))
                    .millisecondsSinceEpoch;
                state = state.copyWith(
                  pendingOffers: cleanedPendingOffers,
                  activeTrip: null,
                  tripPendingRating: state.activeTrip!.copyWith(
                    status: newStatus,
                  ),
                  lastCompletedTripId: tripId,
                  processingTripAction: null,
                  tripErrorMessage: null,
                  ignoreActiveTripRestoreTripId: tripId,
                  ignoreActiveTripRestoreUntilMs: ignoreUntilMs,
                  chatMessages: const [],
                );
                _rt._setAvailability('available');
                unawaited(_rt._refreshDriverAppCreditsBalance());
              } else {
                state = state.copyWith(
                  pendingOffers: cleanedPendingOffers,
                  activeTrip: null,
                  tripPendingRating: null,
                  lastCompletedTripId: tripId,
                  processingTripAction: null,
                  tripErrorMessage: null,
                  chatMessages: const [],
                );
                _rt._setAvailability('available');
              }
            } else {
              final chatOk = driverTripChatPhaseActive(newStatus);
              state = state.copyWith(
                activeTrip: state.activeTrip!.copyWith(status: newStatus),
                processingTripAction: null,
                tripErrorMessage: null,
                chatMessages: chatOk ? state.chatMessages : const [],
                tripChatErrorCode: chatOk ? state.tripChatErrorCode : null,
              );
            }
          } catch (e) {
            debugPrint('[DRIVER_RT] Error manejando trip:status: $e');
          }
        });
  
        void updateActiveTripStatus(String newStatus) {
          final current = state.activeTrip;
          if (current == null) return;
          final chatOk = driverTripChatPhaseActive(newStatus);
          state = state.copyWith(
            activeTrip: current.copyWith(status: newStatus),
            processingTripAction: null,
            tripErrorMessage: null,
            chatMessages: chatOk ? state.chatMessages : const [],
            tripChatErrorCode: chatOk ? state.tripChatErrorCode : null,
          );
        }
  
        socket.on('trip:arrived', (data) {
          try {
            if (data is! Map) return;
            final tripId = data['tripId']?.toString();
            debugPrint('[DRIVER_RT] trip:arrived (eco) tripId=$tripId');
            if (tripId != null && state.activeTrip?.tripId == tripId) {
              updateActiveTripStatus('arrived');
            } else {
              state = state.copyWith(processingTripAction: null);
            }
          } catch (e) {
            debugPrint('[DRIVER_RT] Error manejando trip:arrived: $e');
          }
        });
  
        socket.on('trip:started', (data) {
          try {
            if (data is! Map) return;
            final tripId = data['tripId']?.toString();
            debugPrint('[DRIVER_RT] trip:started (eco) tripId=$tripId');
            if (tripId != null && state.activeTrip?.tripId == tripId) {
              updateActiveTripStatus('started');
            } else {
              state = state.copyWith(processingTripAction: null);
            }
          } catch (e) {
            debugPrint('[DRIVER_RT] Error manejando trip:started: $e');
          }
        });
  
        socket.on('trip:completed', (data) {
          try {
            if (data is! Map) return;
            final tripId = data['tripId']?.toString();
            debugPrint('[DRIVER_RT] trip:completed (eco) tripId=$tripId');
            if (tripId != null && state.activeTrip?.tripId == tripId) {
              final ignoreUntilMs = DateTime.now()
                  .add(const Duration(seconds: 60))
                  .millisecondsSinceEpoch;
              state = state.copyWith(
                activeTrip: null,
                tripPendingRating: state.activeTrip!.copyWith(
                  status: 'completed',
                ),
                lastCompletedTripId: tripId,
                processingTripAction: null,
                tripErrorMessage: null,
                ignoreActiveTripRestoreTripId: tripId,
                ignoreActiveTripRestoreUntilMs: ignoreUntilMs,
                chatMessages: const [],
              );
              _rt._setAvailability('available');
            } else {
              state = state.copyWith(processingTripAction: null);
            }
            unawaited(_rt._syncDriverForegroundSession());
            unawaited(_rt._refreshDriverAppCreditsBalance());
          } catch (e) {
            debugPrint('[DRIVER_RT] Error manejando trip:completed: $e');
          }
        });
  
        socket.on('trip:cancelled', (data) {
          try {
            if (data is! Map) return;
            final tripId = extractTripIdFromPayload(data);
            final reason = data['reason']?.toString();
            final cleanedPendingOffers = state.pendingOffers
                .where((o) => o.tripId != tripId)
                .toList(growable: false);
            debugPrint(
              '[DRIVER_RT] trip:cancelled tripId=$tripId reason=$reason',
            );
            if (tripId != null && state.activeTrip?.tripId == tripId) {
              state = state.copyWith(
                pendingOffers: cleanedPendingOffers,
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
              _rt._clearOfferErrorForTrip(tripId);
              _rt._setAvailability('available');
            } else {
              state = state.copyWith(
                pendingOffers: cleanedPendingOffers,
                processingTripAction: null,
                processingOfferTripId: state.processingOfferTripId == tripId
                    ? null
                    : state.processingOfferTripId,
              );
              if (tripId != null) {
                _rt._clearOfferErrorForTrip(tripId);
              }
            }
            unawaited(_rt._syncDriverForegroundSession());
          } catch (e) {
            debugPrint('[DRIVER_RT] Error manejando trip:cancelled: $e');
          }
        });
  
        socket.on('trip:chat:new', (data) {
          try {
            if (data is! Map) return;
            final tripId = data['tripId']?.toString();
            if (tripId == null || state.activeTrip?.tripId != tripId) return;
            if (!driverTripChatPhaseActive(state.activeTrip?.status)) return;
            final id =
                data['id']?.toString() ??
                '${DateTime.now().millisecondsSinceEpoch}-${state.chatMessages.length}';
            final senderRole = data['senderRole']?.toString() ?? 'passenger';
            final messageKind = data['messageKind']?.toString() ?? 'text';
            final templateCode = data['templateCode']?.toString();
            final messageText = data['messageText']?.toString().trim() ?? '';
            if (messageText.isEmpty) return;
            final createdAt = DateTime.tryParse(
              data['createdAt']?.toString() ?? '',
            );
            final next = List<DriverTripChatMessage>.from(state.chatMessages)
              ..add(
                DriverTripChatMessage(
                  id: id,
                  tripId: tripId,
                  senderRole: senderRole,
                  messageKind: messageKind,
                  templateCode: templateCode,
                  messageText: messageText,
                  createdAt: createdAt,
                ),
              );
            state = state.copyWith(chatMessages: next, tripChatErrorCode: null);
            final fromOtherRole = senderRole != 'driver';
            if (fromOtherRole) {
              final inForeground = DriverAppVisibility.isInForeground.value;
              final chatSheetOpen = DriverTripChatVisibility.isOpenForTrip(
                tripId,
              );
              if (!chatSheetOpen &&
                  inForeground &&
                  DriverNotificationService.shouldPlayForegroundChatAlert()) {
                SystemSound.play(SystemSoundType.alert);
                HapticFeedback.lightImpact();
              }
              if (!chatSheetOpen) {
                unawaited(
                  DriverNotificationService.instance
                      .showTripChatMessageIfBackground(
                        isAppInForeground: inForeground,
                        tripId: tripId,
                        senderRole: senderRole,
                        messageText: messageText,
                        notifyInForeground: true,
                      ),
                );
              }
            }
          } catch (e) {
            debugPrint('[DRIVER_RT] Error manejando trip:chat:new: $e');
          }
        });
  
        socket.on('trip:chat:error', (data) {
          final code =
              (data is Map ? data['code'] : null)?.toString() ??
              'TRIP_CHAT_ERROR';
          state = state.copyWith(tripChatErrorCode: code);
        });
  
        socket.on('trip:arrival_reminder:ack', (data) {
          try {
            if (data is! Map) return;
            final cooldownSecRaw = data['cooldownSec'];
            final cooldownSec = cooldownSecRaw is num
                ? cooldownSecRaw.toInt()
                : 45;
            final until = DateTime.now()
                .add(Duration(seconds: cooldownSec))
                .millisecondsSinceEpoch;
            state = state.copyWith(
              arrivalReminderCooldownUntilMs: until,
              arrivalReminderErrorCode: null,
            );
          } catch (_) {}
        });
  
        socket.on('trip:arrival_reminder:error', (data) {
          try {
            if (data is! Map) return;
            final code =
                data['code']?.toString() ?? 'TRIP_ARRIVAL_REMINDER_ERROR';
            final retryAfterRaw = data['retryAfterSec'];
            final retryAfter = retryAfterRaw is num ? retryAfterRaw.toInt() : 0;
            final until = retryAfter > 0
                ? DateTime.now()
                      .add(Duration(seconds: retryAfter))
                      .millisecondsSinceEpoch
                : state.arrivalReminderCooldownUntilMs;
            state = state.copyWith(
              arrivalReminderErrorCode: code,
              arrivalReminderCooldownUntilMs: until,
            );
          } catch (_) {}
        });
  
        socket.on('connection:ack', (data) {
          try {
            if (data is! Map || data['ok'] != true) return;
            _rt._logVerbose('connection:ack data=$data');
            _rt._applyProfileFromAck(Map<String, dynamic>.from(data));
            if (_rt._shouldRefreshDriverPhoto()) {
              unawaited(_rt._refreshDriverPhotoFromProfile());
            }
            final statusRaw = data['status'];
            if (statusRaw is Map) {
              final sm = Map<String, dynamic>.from(statusRaw);
              final blocked = parseDriverBool(
                sm['goOnlineBlocked'] ?? sm['go_online_blocked'],
              );
              final reasonRaw =
                  sm['goOnlineBlockReason'] ?? sm['go_online_block_reason'];
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
                sm['creditsOnlineGateEnabled'] ??
                    sm['credits_online_gate_enabled'],
              );
              final hadBlockedError =
                  state.errorCode == 'DRIVER_GO_ONLINE_BLOCKED';
              state = state.copyWith(
                goOnlineBlocked: blocked,
                goOnlineBlockReason: (reason != null && reason.isNotEmpty)
                    ? reason
                    : null,
                accountBlocked: accountBlocked,
                accountBlockReason:
                    (accountReason != null && accountReason.isNotEmpty)
                    ? accountReason
                    : null,
                insufficientCreditsToGoOnline: creditsBlocked,
                minCreditsToGoOnline: minCredits,
                driverCreditsBalance: creditsBalance,
                creditsOnlineGateEnabled: creditsGateOn,
                errorCode: !blocked && hadBlockedError ? null : state.errorCode,
                availabilityDesired:
                    (blocked || accountBlocked || creditsBlocked) &&
                        state.activeTrip == null &&
                        state.tripPendingRating == null
                    ? false
                    : state.availabilityDesired,
              );
              if ((blocked || accountBlocked || creditsBlocked) &&
                  state.activeTrip == null &&
                  state.tripPendingRating == null) {
                _rt._availabilitySessionDesired = false;
              }
            }
            final hasActiveTrip = data['hasActiveTrip'] == true;
            final activeTripData = data['activeTrip'];
            if (hasActiveTrip && activeTripData is Map) {
              final tripId = activeTripData['tripId']?.toString();
              final status =
                  activeTripData['status']?.toString().toLowerCase() ??
                  'accepted';
              final isFinal =
                  parseDriverBool(activeTripData['isFinal']) ||
                  status == 'completed' ||
                  status == 'cancelled' ||
                  status == 'expired';
              final estimatedPriceRaw = activeTripData['estimatedPrice'];
              final estimatedPrice = estimatedPriceRaw is num
                  ? estimatedPriceRaw.toDouble()
                  : null;
              final currencyCode =
                  (activeTripData['currencyCode'] ?? activeTripData['currency'])
                      ?.toString();
              final pickupParsed = parseDriverLatLng(
                activeTripData,
                'pickupLat',
                'pickupLng',
              );
              final (
                pickupLat,
                pickupLng,
              ) = (pickupParsed.$1 != null && pickupParsed.$2 != null)
                  ? pickupParsed
                  : parseDriverLatLngFromMap(activeTripData['origin']);
              final destParsed = parseDriverLatLng(
                activeTripData,
                'destinationLat',
                'destinationLng',
              );
              final (
                destLat,
                destLng,
              ) = (destParsed.$1 != null && destParsed.$2 != null)
                  ? destParsed
                  : parseDriverLatLngFromMap(activeTripData['destination']);
              final passengerName = activeTripData['passengerName']?.toString();
              final passengerRating = parseDriverDouble(
                activeTripData['passengerRating'],
              );
              final originAddress = activeTripData['originAddress']?.toString();
              final destinationAddress = activeTripData['destinationAddress']
                  ?.toString();
              final tripDistanceRaw = activeTripData['tripDistanceKm'];
              final tripDistanceKm = tripDistanceRaw is num
                  ? tripDistanceRaw.toDouble()
                  : null;
              final etaDestRaw = activeTripData['etaToDestinationMinutes'];
              final etaToDestinationMinutes = etaDestRaw is num
                  ? etaDestRaw.toDouble()
                  : null;
              final rawRouteEncAck = activeTripData['routeOverviewEncoded'];
              final routeOverviewEncoded =
                  rawRouteEncAck != null &&
                      rawRouteEncAck.toString().trim().isNotEmpty
                  ? rawRouteEncAck.toString().trim()
                  : null;
              if (tripId != null) {
                if (_rt._shouldIgnoreRestoreTrip(tripId)) {
                  state = state.copyWith(
                    activeTrip: null,
                    tripPendingRating: state.tripPendingRating,
                    processingTripAction: null,
                    tripErrorMessage: null,
                  );
                } else {
                  final existingTrip = state.activeTrip;
                  final parsedTrip = DriverActiveTrip(
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
                  );
                  // El ack a veces trae solo status/coords; no pisar direcciÃ³n/pasajero ya mostrados.
                  final mergedTrip =
                      (existingTrip != null && existingTrip.tripId == tripId)
                      ? existingTrip.copyWith(
                          status: status,
                          estimatedPrice:
                              estimatedPrice ?? existingTrip.estimatedPrice,
                          pickupLat: pickupLat ?? existingTrip.pickupLat,
                          pickupLng: pickupLng ?? existingTrip.pickupLng,
                          destinationLat: destLat ?? existingTrip.destinationLat,
                          destinationLng: destLng ?? existingTrip.destinationLng,
                          passengerName:
                              passengerName ?? existingTrip.passengerName,
                          passengerRating:
                              passengerRating ?? existingTrip.passengerRating,
                          currencyCode: currencyCode ?? existingTrip.currencyCode,
                          originAddress:
                              originAddress ?? existingTrip.originAddress,
                          destinationAddress:
                              destinationAddress ??
                              existingTrip.destinationAddress,
                          tripDistanceKm:
                              tripDistanceKm ?? existingTrip.tripDistanceKm,
                          etaToDestinationMinutes:
                              etaToDestinationMinutes ??
                              existingTrip.etaToDestinationMinutes,
                          routeOverviewEncoded:
                              routeOverviewEncoded ??
                              existingTrip.routeOverviewEncoded,
                        )
                      : parsedTrip;
  
                  // Si ya estamos en flujo de rating para este mismo trip, no
                  // restauremos el mapa aunque el backend aÃºn mande estados
                  // intermedios (evita que reaparezca "trayecto" despuÃ©s de
                  // finalizar).
                  final existingPending = state.tripPendingRating;
                  if (existingPending != null &&
                      existingPending.tripId == tripId) {
                    state = state.copyWith(
                      activeTrip: null,
                      tripPendingRating: existingPending,
                      processingTripAction: null,
                      tripErrorMessage: null,
                    );
                    debugPrint(
                      '[DRIVER_RT] connection:ack llegÃ³ durante rating -> ignorando restore mapa tripId=$tripId',
                    );
                  } else if (isFinal) {
                    // Si el backend ya considera el viaje final, NO lo restauramos
                    // como "viaje activo" (para que no vuelva el mapa y el estado).
                    final ignoreUntilMs = DateTime.now()
                        .add(const Duration(seconds: 60))
                        .millisecondsSinceEpoch;
                    state = state.copyWith(
                      activeTrip: null,
                      tripPendingRating: mergedTrip,
                      lastCompletedTripId: tripId,
                      processingTripAction: null,
                      tripErrorMessage: null,
                      ignoreActiveTripRestoreTripId: tripId,
                      ignoreActiveTripRestoreUntilMs: ignoreUntilMs,
                    );
                    debugPrint(
                      '[DRIVER_RT] connection:ack recibiÃ³ viaje final -> guardando para rating tripId=$tripId status=$status',
                    );
                  } else {
                    state = state.copyWith(
                      activeTrip: mergedTrip,
                      tripPendingRating: null,
                      processingTripAction: null,
                    );
                    debugPrint(
                      '[DRIVER_RT] connection:ack restaurado activeTrip=$tripId status=$status',
                    );
                  }
                }
              }
            }
          } catch (e) {
            debugPrint('[DRIVER_RT] Error manejando connection:ack: $e');
          }
        });
        socket.on('driver:force_logout', (data) {
          final msg = data is Map ? data['message']?.toString() : null;
          final code = data is Map ? data['code']?.toString() : null;
          final errorCode = switch (code) {
            'SESSION_SUPERSEDED' => 'SESSION_SUPERSEDED',
            'DEVICE_RESET' => 'DEVICE_BOUND_TO_OTHER',
            _ => 'AUTH',
          };
          unawaited(
            notifyDriverSessionExpelled(
              errorCode,
              message: msg,
            ),
          );
          state = state.copyWith(
            accountBlocked: code == 'DRIVER_ACCOUNT_BLOCKED' || code == 'DEVICE_RESET',
            accountBlockReason: msg,
            online: false,
            connecting: false,
            availabilityDesired: false,
            errorCode: errorCode,
          );
        });
}
}
