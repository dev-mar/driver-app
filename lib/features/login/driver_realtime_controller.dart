import 'dart:async';

import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../core/config/driver_backend_config.dart';
import '../../core/config/driver_realtime_config.dart';
import '../../core/app_lifecycle/app_lifecycle_state.dart';

final driverRealtimeProvider =
    StateNotifierProvider<DriverRealtimeController, DriverRealtimeState>(
  (ref) => DriverRealtimeController(),
);

class DriverRealtimeState {
  final bool online;
  final bool connecting;
  /// Código de error simple para i18n (NO_INTERNET, NO_GPS, NO_TOKEN, SOCKET,
  /// DRIVER_VEHICLE_REQUIRED, UNKNOWN).
  final String? errorCode;
  /// Ofertas de viaje pendientes (trip:offer) que el conductor puede aceptar/rechazar.
  final List<DriverTripOffer> pendingOffers;
  /// tripId de la oferta que se está procesando (aceptando o rechazando), o null.
  final String? processingOfferTripId;
  /// true si la operación en curso es aceptar, false si es rechazar.
  final bool processingIsAccept;
  /// Mensaje de error textual asociado a la última operación sobre ofertas (opcional).
  final String? offersErrorMessage;
  /// Código de error de oferta para i18n (p. ej. NO_CONNECTION, OFFER_EXPIRED).
  final String? offersErrorCode;
  /// Viaje activo una vez aceptado (ir a recoger → llegó → en trayecto → completado/cancelado).
  final DriverActiveTrip? activeTrip;
  /// Viaje guardado cuando llega a `completed` para mostrar la calificación
  /// sin mantener el mapa visible.
  final DriverActiveTrip? tripPendingRating;
  /// Para evitar que eventos tardíos del backend (por ejemplo `connection:ack`)
  /// restauren un viaje ya finalizado y vuelva a aparecer el mapa después
  /// de la calificación.
  final String? ignoreActiveTripRestoreTripId;
  final int? ignoreActiveTripRestoreUntilMs;
  /// Último trip que el backend marcó (o el conductor marcó) como final.
  final String? lastCompletedTripId;
  /// Acción de cambio de estado en curso: 'arrived' | 'started' | 'completed' para mostrar loading.
  final String? processingTripAction;
  /// Mensaje de error en cambio de estado del viaje (trip:error).
  final String? tripErrorMessage;
  /// Posición actual del conductor (actualizada con location:update) para el mapa.
  final double? driverLat;
  final double? driverLng;
  /// Desde `connection:ack.profile` (nombre para mini perfil en home).
  final String? driverDisplayName;
  /// Ej. "Toyota Corolla · ABC-123" desde `connection:ack.profile.vehicle`.
  final String? driverVehicleLabel;
  /// Valoración media del conductor si el backend la envía en el perfil.
  final double? driverRating;
  /// Foto de perfil del conductor (URL firmada o data URL) desde `connection:ack.profile`.
  final String? driverPictureProfile;
  /// Expiración de la URL firmada para refresco condicional.
  final DateTime? driverPictureExpiresAt;

  /// Valor interno para [copyWith] y poder asignar `null` en campos opcionales.
  static const Object _unset = Object();

  const DriverRealtimeState({
    required this.online,
    required this.connecting,
    this.errorCode,
    this.pendingOffers = const [],
    this.processingOfferTripId,
    this.processingIsAccept = true,
    this.offersErrorMessage,
    this.offersErrorCode,
    this.activeTrip,
    this.tripPendingRating,
    this.ignoreActiveTripRestoreTripId,
    this.ignoreActiveTripRestoreUntilMs,
    this.lastCompletedTripId,
    this.processingTripAction,
    this.tripErrorMessage,
    this.driverLat,
    this.driverLng,
    this.driverDisplayName,
    this.driverVehicleLabel,
    this.driverRating,
    this.driverPictureProfile,
    this.driverPictureExpiresAt,
  });

  DriverRealtimeState copyWith({
    bool? online,
    bool? connecting,
    String? errorCode,
    List<DriverTripOffer>? pendingOffers,
    Object? processingOfferTripId = _unset,
    bool? processingIsAccept,
    String? offersErrorMessage,
    String? offersErrorCode,
    Object? activeTrip = _unset,
    Object? tripPendingRating = _unset,
    Object? ignoreActiveTripRestoreTripId = _unset,
    Object? ignoreActiveTripRestoreUntilMs = _unset,
    Object? lastCompletedTripId = _unset,
    Object? processingTripAction = _unset,
    String? tripErrorMessage,
    Object? driverLat = _unset,
    Object? driverLng = _unset,
    Object? driverDisplayName = _unset,
    Object? driverVehicleLabel = _unset,
    Object? driverRating = _unset,
    Object? driverPictureProfile = _unset,
    Object? driverPictureExpiresAt = _unset,
  }) {
    return DriverRealtimeState(
      online: online ?? this.online,
      connecting: connecting ?? this.connecting,
      errorCode: errorCode,
      pendingOffers: pendingOffers ?? this.pendingOffers,
      processingOfferTripId: identical(processingOfferTripId, _unset)
          ? this.processingOfferTripId
          : processingOfferTripId as String?,
      processingIsAccept: processingIsAccept ?? this.processingIsAccept,
      offersErrorMessage: offersErrorMessage,
      offersErrorCode: offersErrorCode,
      activeTrip:
          identical(activeTrip, _unset) ? this.activeTrip : activeTrip as DriverActiveTrip?,
      tripPendingRating: identical(tripPendingRating, _unset)
          ? this.tripPendingRating
          : tripPendingRating as DriverActiveTrip?,
      ignoreActiveTripRestoreTripId: identical(ignoreActiveTripRestoreTripId, _unset)
          ? this.ignoreActiveTripRestoreTripId
          : ignoreActiveTripRestoreTripId as String?,
      ignoreActiveTripRestoreUntilMs: identical(ignoreActiveTripRestoreUntilMs, _unset)
          ? this.ignoreActiveTripRestoreUntilMs
          : ignoreActiveTripRestoreUntilMs as int?,
      lastCompletedTripId: identical(lastCompletedTripId, _unset)
          ? this.lastCompletedTripId
          : lastCompletedTripId as String?,
      processingTripAction: identical(processingTripAction, _unset)
          ? this.processingTripAction
          : processingTripAction as String?,
      tripErrorMessage: tripErrorMessage,
      driverLat: identical(driverLat, _unset) ? this.driverLat : driverLat as double?,
      driverLng: identical(driverLng, _unset) ? this.driverLng : driverLng as double?,
      driverDisplayName: identical(driverDisplayName, _unset)
          ? this.driverDisplayName
          : driverDisplayName as String?,
      driverVehicleLabel: identical(driverVehicleLabel, _unset)
          ? this.driverVehicleLabel
          : driverVehicleLabel as String?,
      driverRating: identical(driverRating, _unset)
          ? this.driverRating
          : driverRating as double?,
      driverPictureProfile: identical(driverPictureProfile, _unset)
          ? this.driverPictureProfile
          : driverPictureProfile as String?,
      driverPictureExpiresAt: identical(driverPictureExpiresAt, _unset)
          ? this.driverPictureExpiresAt
          : driverPictureExpiresAt as DateTime?,
    );
  }

  static const initial =
      DriverRealtimeState(
        online: false,
        connecting: false,
        errorCode: null,
        pendingOffers: [],
        processingOfferTripId: null,
        processingIsAccept: true,
        offersErrorMessage: null,
        offersErrorCode: null,
        activeTrip: null,
        tripPendingRating: null,
        ignoreActiveTripRestoreTripId: null,
        ignoreActiveTripRestoreUntilMs: null,
        lastCompletedTripId: null,
        processingTripAction: null,
        tripErrorMessage: null,
        driverLat: null,
        driverLng: null,
        driverDisplayName: null,
        driverVehicleLabel: null,
        driverRating: null,
        driverPictureProfile: null,
        driverPictureExpiresAt: null,
      );
}

/// Valor visual del switch "En línea": ON con socket, reconectando o con viaje /
/// calificación pendiente aunque `online` sea false (caída de red durante carrera).
extension DriverRealtimeStateAvailabilityUi on DriverRealtimeState {
  bool get availabilitySwitchVisualOn {
    if (online) return true;
    if (connecting) return true;
    return activeTrip != null || tripPendingRating != null;
  }
}

(double?, double?) _parseLatLng(dynamic m, String latKey, String lngKey) {
  if (m is! Map) return (null, null);
  final map = m;
  final lat = map[latKey];
  final lng = map[lngKey];
  if (lat is num && lng is num) return (lat.toDouble(), lng.toDouble());
  return (null, null);
}

String _socketConnectErrorToCode(dynamic data) {
  final s = data?.toString() ?? '';
  if (s.contains('DRIVER_VEHICLE_REQUIRED')) {
    return 'DRIVER_VEHICLE_REQUIRED';
  }
  return 'SOCKET';
}

(double?, double?) _parseLatLngFromMap(dynamic o) {
  if (o is! Map) return (null, null);
  final m = Map<String, dynamic>.from(o);
  final lat = m['lat'] ?? m['latitude'];
  final lng = m['lng'] ?? m['longitude'];
  if (lat is num && lng is num) return (lat.toDouble(), lng.toDouble());
  return (null, null);
}

class DriverRealtimeController extends StateNotifier<DriverRealtimeState> {
  DriverRealtimeController() : super(DriverRealtimeState.initial);

  static const _storage = FlutterSecureStorage();
  static Dio? _profileHttp;

  static Dio _profileDio () {
    _profileHttp ??= Dio(
      BaseOptions(
        baseUrl: DriverBackendConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: <String, String>{'Accept': 'application/json'},
      ),
    );
    return _profileHttp!;
  }

  io.Socket? _socket;
  Future<void>? _goOnlineRun;
  StreamSubscription<Position>? _positionSub;
  Timer? _tripReconnectTimer;
  DateTime? _lastTouchReconnect;
  bool _disposed = false;
  /// `true` tras apagar el switch o logout: no auto-reconectar por `onDisconnect`.
  bool _userRequestedOffline = false;
  /// Si el conductor intenta finalizar viaje sin socket conectado (por red
  /// caída o background), guardamos el tripId para reintentarlo en
  /// cuanto se restablezca la conexión.
  String? _pendingTripCompletedTripId;
  bool _isRefreshingDriverPhoto = false;
  DateTime? _lastDriverPhotoRefreshAt;

  /// Última vez que el servidor recibió `location:update` (anti saturación).
  DateTime? _lastLocationEmittedAt;
  static const _locationEmitMinInterval = Duration(milliseconds: 2800);

  /// Evita `checkPermission` repetido en reconexiones seguidas.
  DateTime? _locationPermissionCachedAt;
  LocationPermission? _locationPermissionCached;

  bool _toBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }
    return false;
  }

  /// `connection:ack.profile`: nombre, vehículo y valoración para el mini perfil del home.
  void _applyProfileFromAck(Map<String, dynamic> data) {
    final profileRaw = data['profile'];
    if (profileRaw is! Map) return;
    final map = Map<String, dynamic>.from(profileRaw);
    final fn = map['fullName']?.toString().trim();
    String? vehicleLabel;
    final vehicle = map['vehicle'];
    if (vehicle is Map) {
      final vm = Map<String, dynamic>.from(vehicle);
      final brand = vm['brand']?.toString().trim() ?? '';
      final model = vm['model']?.toString().trim() ?? '';
      final plate = vm['licensePlate']?.toString().trim() ?? '';
      final modelLine = [brand, model].where((s) => s.isNotEmpty).join(' ');
      if (modelLine.isNotEmpty && plate.isNotEmpty) {
        vehicleLabel = '$modelLine · $plate';
      } else if (modelLine.isNotEmpty) {
        vehicleLabel = modelLine;
      } else if (plate.isNotEmpty) {
        vehicleLabel = plate;
      }
    }
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
    final expRaw = map['profilePictureExpiresAt'] ?? map['profile_picture_expires_at'];
    if (expRaw != null) {
      final t = expRaw.toString().trim();
      if (t.isNotEmpty) pictureExpiresAt = DateTime.tryParse(t);
    }

    final newName =
        (fn != null && fn.isNotEmpty) ? fn : state.driverDisplayName;
    final newVehicle = vehicleLabel ?? state.driverVehicleLabel;
    final newRating = rating ?? state.driverRating;

    state = state.copyWith(
      driverDisplayName: newName,
      driverVehicleLabel: newVehicle,
      driverRating: newRating,
      driverPictureProfile: picture ?? state.driverPictureProfile,
      driverPictureExpiresAt: pictureExpiresAt ?? state.driverPictureExpiresAt,
    );
  }

  bool _shouldIgnoreRestoreTrip(String tripId) {
    final id = state.ignoreActiveTripRestoreTripId;
    final untilMs = state.ignoreActiveTripRestoreUntilMs;
    if (id == null || untilMs == null) return false;
    if (id != tripId) return false;
    return DateTime.now().millisecondsSinceEpoch <= untilMs;
  }

  void _setAvailability(String availability) {
    if (_socket?.connected != true) return;
    _socket!.emit('driver:setAvailability', {
      'availability': availability,
    });
  }

  /// Emite al socket respetando [_locationEmitMinInterval] salvo [force].
  void _emitLocationToServer (
    double lat,
    double lng,
    double speed, {
    bool force = false,
  }) {
    if (_socket?.connected != true) return;
    final now = DateTime.now();
    if (!force && _lastLocationEmittedAt != null) {
      if (now.difference(_lastLocationEmittedAt!) < _locationEmitMinInterval) {
        return;
      }
    }
    _lastLocationEmittedAt = now;
    _socket!.emit('location:update', {
      'lat': lat,
      'lng': lng,
      'bearing': 0,
      'speed': speed,
    });
  }

  Future<void> _ensureLocationPermissionForSocket () async {
    final now = DateTime.now();
    final cached = _locationPermissionCached;
    final cachedAt = _locationPermissionCachedAt;
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
      _locationPermissionCached = null;
      _locationPermissionCachedAt = null;
      debugPrint('[DRIVER_RT] Permisos de GPS denegados.');
      throw const _RealtimeException('NO_GPS');
    }
    _locationPermissionCached = permission;
    _locationPermissionCachedAt = DateTime.now();
  }

  bool _shouldRefreshDriverPhoto() {
    final pic = state.driverPictureProfile?.trim() ?? '';
    final exp = state.driverPictureExpiresAt;
    if (pic.isEmpty) return true;
    if (exp == null) return false;
    final now = DateTime.now();
    // Refrescar antes de expirar para evitar imagen rota en UI.
    return now.isAfter(exp.subtract(const Duration(minutes: 2)));
  }

  Future<void> _refreshDriverPhotoFromProfile({bool force = false}) async {
    if (_isRefreshingDriverPhoto) return;
    if (!force && !_shouldRefreshDriverPhoto()) return;
    final last = _lastDriverPhotoRefreshAt;
    final now = DateTime.now();
    if (!force && last != null && now.difference(last) < const Duration(seconds: 30)) {
      return;
    }
    _isRefreshingDriverPhoto = true;
    try {
      final token = await _storage.read(key: 'driver_token');
      if (token == null || token.isEmpty) return;
      final res = await _profileDio().get<Map<String, dynamic>>(
        '/api/v2/driver/me-profile',
        options: Options(
          headers: <String, String>{'Authorization': 'Bearer $token'},
        ),
      );
      final root = res.data;
      if (root == null || root['success'] != true) return;
      final data = root['data'];
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      final rawPic = map['picture_profile']?.toString().trim();
      DateTime? exp;
      final rawExp = map['profile_picture_expires_at']?.toString().trim();
      if (rawExp != null && rawExp.isNotEmpty) {
        exp = DateTime.tryParse(rawExp);
      }
      if (rawPic != null && rawPic.isNotEmpty) {
        state = state.copyWith(
          driverPictureProfile: rawPic,
          driverPictureExpiresAt: exp,
        );
      }
      _lastDriverPhotoRefreshAt = DateTime.now();
    } catch (_) {
      // Fallo silencioso: la UI conserva última foto válida/fallback.
    } finally {
      _isRefreshingDriverPhoto = false;
    }
  }

  /// [forceOffline]: logout u otros casos que deben cortar sesión aunque haya viaje activo.
  Future<void> setOnline(bool value, {bool forceOffline = false}) async {
    if (value == state.online && !state.connecting) return;
    if (value) {
      _userRequestedOffline = false;
      await _goOnline();
      return;
    }
    if (!forceOffline &&
        (state.activeTrip != null || state.tripPendingRating != null)) {
      state = state.copyWith(errorCode: 'ACTIVE_TRIP_CANT_GO_OFFLINE');
      return;
    }
    _userRequestedOffline = true;
    _cancelTripReconnectLoop();
    _lastTouchReconnect = null;
    await _goOffline(userInitiated: true, preserveTripState: false);
  }

  Future<void> _handleUnexpectedDisconnectWithTrip() async {
    await _goOffline(internal: true, preserveTripState: true);
    if (_userRequestedOffline || _disposed) return;
    state = state.copyWith(connecting: true, errorCode: 'SOCKET_RECONNECTING');
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (_userRequestedOffline || _disposed) return;
    try {
      await _goOnline();
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
    _tripReconnectTimer?.cancel();
    _tripReconnectTimer = null;
  }

  /// Reintentos periódicos mientras haya viaje (o calificación) y el usuario
  /// no pidió offline explícitamente.
  void _ensureTripReconnectLoop() {
    if (_userRequestedOffline || _disposed) return;
    final hasWork =
        state.activeTrip != null || state.tripPendingRating != null;
    if (!hasWork) return;
    if (state.online) return;
    _tripReconnectTimer?.cancel();
    if (!state.connecting) {
      unawaited(setOnline(true));
    }
    _tripReconnectTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      if (_userRequestedOffline || _disposed) {
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
      if (state.connecting) return;
      await setOnline(true);
    });
  }

  /// Llamado desde el home cuando hay trabajo activo pero el socket no está
  /// arriba (p. ej. vuelta del segundo plano sin evento disconnect).
  void touchReconnectIfHasActiveWork() {
    if (_userRequestedOffline || _disposed) return;
    if (state.activeTrip == null && state.tripPendingRating == null) return;
    if (state.online) {
      _lastTouchReconnect = null;
      return;
    }
    final now = DateTime.now();
    if (_lastTouchReconnect != null &&
        now.difference(_lastTouchReconnect!) < const Duration(seconds: 3)) {
      return;
    }
    _lastTouchReconnect = now;
    _ensureTripReconnectLoop();
    if (!state.connecting) {
      unawaited(setOnline(true));
    }
  }

  Future<void> _goOnline() async {
    if (_goOnlineRun != null) {
      await _goOnlineRun;
      return;
    }
    final run = _performGoOnline();
    _goOnlineRun = run;
    try {
      await run;
    } finally {
      if (identical(_goOnlineRun, run)) {
        _goOnlineRun = null;
      }
    }
  }

  Future<void> _performGoOnline() async {
    debugPrint('[DRIVER_RT] setOnline(true) iniciando...');
    _cancelTripReconnectLoop();
    state = state.copyWith(connecting: true, errorCode: null);

    try {
      // connectivity_plus 6.x devuelve List<ConnectivityResult>
      final connList = await Connectivity().checkConnectivity();
      final hasConnection = connList.isNotEmpty &&
          !(connList.length == 1 && connList.first == ConnectivityResult.none);
      if (!hasConnection) {
        debugPrint('[DRIVER_RT] Sin conexión a internet. result=$connList');
        throw const _RealtimeException('NO_INTERNET');
      }

      final token = await _storage.read(key: 'driver_token');
      if (token == null || token.isEmpty) {
        debugPrint('[DRIVER_RT] Token de conductor vacío o nulo.');
        throw const _RealtimeException('NO_TOKEN');
      }
      debugPrint('[DRIVER_RT] Token leído. length=${token.length}');

      await _ensureLocationPermissionForSocket();

      debugPrint(
          '[DRIVER_RT] Conectando socket a ${DriverRealtimeConfig.socketUrl}${DriverRealtimeConfig.socketPath}...');

      final socket = io.io(
        DriverRealtimeConfig.socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setPath(DriverRealtimeConfig.socketPath)
            .setExtraHeaders({
              'Authorization': 'Bearer $token',
            })
            .setAuth({'token': token})
            .build(),
      );

      final completer = Completer<void>();

      socket.onDisconnect((data) {
        debugPrint('[DRIVER_RT] disconnect data=$data');
        if (_disposed) return;
        if (_userRequestedOffline) return;
        final hasTrip =
            state.activeTrip != null || state.tripPendingRating != null;
        if (hasTrip) {
          unawaited(_handleUnexpectedDisconnectWithTrip());
          return;
        }
        unawaited(_goOffline(internal: true, preserveTripState: false));
      });

      socket.onConnect((_) {
        debugPrint('[DRIVER_RT] Socket conectado correctamente.');
        if (!completer.isCompleted) completer.complete();
        // Alineación con el contrato: al estar online, el conductor debe
        // estar en disponibilidad "available" para recibir ofertas.
        _setAvailability('available');
        // Reintento seguro de finalización pendiente.
        final pending = _pendingTripCompletedTripId;
        if (pending != null) {
          debugPrint('[DRIVER_RT] Reintentando trip:completed pendiente tripId=$pending');
          try {
            socket.emit('trip:completed', {'tripId': pending});
          } catch (e) {
            debugPrint('[DRIVER_RT] Error reintentando trip:completed: $e');
            return;
          }
          _pendingTripCompletedTripId = null;
        }
      });
      socket.onConnectError((data) {
        debugPrint('[DRIVER_RT] onConnectError recibido. data=$data');
        if (!completer.isCompleted) {
          completer.completeError(
            _RealtimeException(_socketConnectErrorToCode(data)),
          );
        }
      });
      socket.onError((data) {
        debugPrint('[DRIVER_RT] onError recibido en socket. data=$data');
        if (!completer.isCompleted) {
          completer.completeError(
            _RealtimeException(_socketConnectErrorToCode(data)),
          );
        }
      });
      socket.on('driver:availability_ack', (data) {
        debugPrint('[DRIVER_RT] driver:availability_ack data=$data');
      });
      socket.on('driver:availability_error', (data) {
        debugPrint('[DRIVER_RT] driver:availability_error data=$data');
        if (data is Map) {
          final code = data['code']?.toString();
          if (code != null && code.startsWith('RBAC_')) {
            state = state.copyWith(
              online: false,
              connecting: false,
              errorCode: code,
            );
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
          }
        }
      });

      // Listeners de viajes (servidor → conductor).
      socket.on('trip:offer', (data) {
        try {
          if (data is! Map) return;
          final tripId = data['tripId']?.toString();
          if (tripId == null || tripId.isEmpty) return;
          final offeredPriceRaw = data['offeredPrice'];
          final etaMinutesRaw = data['etaMinutes'];
          final etaDestRaw = data['etaToDestinationMinutes'];
          final distanceToPickupRaw = data['distanceToPickupKm'];
          final offeredPrice =
              offeredPriceRaw is num ? offeredPriceRaw.toDouble() : null;
          final etaMinutes =
              etaMinutesRaw is num ? etaMinutesRaw.toDouble() : null;
          final etaToDestinationMinutes =
              etaDestRaw is num ? etaDestRaw.toDouble() : null;
          final distanceToPickupKm = distanceToPickupRaw is num
              ? distanceToPickupRaw.toDouble()
              : null;
          final passengerName = data['passengerName']?.toString();
          final passengerRatingRaw = data['passengerRating'];
          final passengerRating = passengerRatingRaw is num
              ? passengerRatingRaw.toDouble()
              : null;
          final originAddress = data['originAddress']?.toString();
          final destinationAddress = data['destinationAddress']?.toString();
          final tripDistanceRaw = data['tripDistanceKm'];
          final tripDistanceKm =
              tripDistanceRaw is num ? tripDistanceRaw.toDouble() : null;

          debugPrint(
              '[DRIVER_RT] trip:offer recibido tripId=$tripId, price=$offeredPrice, eta=$etaMinutes, dist=$distanceToPickupKm');

          // Segundo plano / app cerrada: FCM desde backend (`sendDriverTripOffer`).
          // En primer plano: beep si el conductor está libre (lista + socket).
          final inForeground = DriverAppVisibility.isInForeground.value;
          final isBusy = state.activeTrip != null;

          final existingIndex = state.pendingOffers
              .indexWhere((offer) => offer.tripId == tripId);
          final isNewOffer = existingIndex < 0;

          if (inForeground && isNewOffer && !isBusy) {
            SystemSound.play(SystemSoundType.alert);
          }

          final updatedOffers = List<DriverTripOffer>.from(state.pendingOffers);
          final newOffer = DriverTripOffer(
            tripId: tripId,
            offeredPrice: offeredPrice,
            etaMinutes: etaMinutes,
            etaToDestinationMinutes: etaToDestinationMinutes,
            distanceToPickupKm: distanceToPickupKm,
            passengerName: passengerName,
            passengerRating: passengerRating,
            originAddress: originAddress,
            destinationAddress: destinationAddress,
            tripDistanceKm: tripDistanceKm,
          );
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
            offersErrorMessage: null,
          );
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
          debugPrint('[DRIVER_RT] trip:accepted raw data=$data');

          final pickupParsed = _parseLatLng(data, 'pickupLat', 'pickupLng');
          final (pickupLat, pickupLng) = (pickupParsed.$1 != null && pickupParsed.$2 != null)
              ? pickupParsed
              : _parseLatLngFromMap(data['origin']);
          final destParsed = _parseLatLng(data, 'destinationLat', 'destinationLng');
          final (destLat, destLng) = (destParsed.$1 != null && destParsed.$2 != null)
              ? destParsed
              : _parseLatLngFromMap(data['destination']);
          final passengerName = data['passengerName']?.toString();
          final passengerRatingRaw = data['passengerRating'];
          final passengerRating = passengerRatingRaw is num ? passengerRatingRaw.toDouble() : null;
          final originAddress = data['originAddress']?.toString();
          final destinationAddress = data['destinationAddress']?.toString();
          final tripDistanceRaw = data['tripDistanceKm'];
          final tripDistanceKm = tripDistanceRaw is num ? tripDistanceRaw.toDouble() : null;
          final etaDestRaw = data['etaToDestinationMinutes'];
          final etaToDestinationMinutes = etaDestRaw is num ? etaDestRaw.toDouble() : null;
          debugPrint(
              '[DRIVER_RT] trip:accepted recibido tripId=$tripId status=$status '
              'pickup=($pickupLat,$pickupLng) dest=($destLat,$destLng)');

          if (tripId != null) {
            final updatedOffers = state.pendingOffers
                .where((offer) => offer.tripId != tripId)
                .toList();
            state = state.copyWith(
              pendingOffers: updatedOffers,
              processingOfferTripId: null,
              offersErrorMessage: null,
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
                originAddress: originAddress,
                destinationAddress: destinationAddress,
                tripDistanceKm: tripDistanceKm,
                etaToDestinationMinutes: etaToDestinationMinutes,
              ),
              processingTripAction: null,
              tripErrorMessage: null,
            );
          } else {
            state = state.copyWith(
              processingOfferTripId: null,
            );
          }
        } catch (e) {
          debugPrint('[DRIVER_RT] Error manejando trip:accepted: $e');
        }
      });

      socket.on('trip:rejected', (data) {
        try {
          if (data is! Map) return;
          final tripId = data['tripId']?.toString();
          debugPrint('[DRIVER_RT] trip:rejected recibido tripId=$tripId');

          if (tripId != null) {
            final updatedOffers = state.pendingOffers
                .where((offer) => offer.tripId != tripId)
                .toList();
            state = state.copyWith(
              pendingOffers: updatedOffers,
              processingOfferTripId: null,
              offersErrorMessage: null,
              offersErrorCode: null,
            );
          } else {
            state = state.copyWith(
              processingOfferTripId: null,
            );
          }
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
          debugPrint(
              '[DRIVER_RT] trip:error code=$code message=$message');

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
          final updatedOffers = (isOfferNoLongerAvailable && targetTripId != null)
              ? state.pendingOffers
                  .where((offer) => offer.tripId != targetTripId)
                  .toList()
              : state.pendingOffers;

          state = state.copyWith(
            pendingOffers: updatedOffers,
            processingOfferTripId: null,
            offersErrorMessage: message ?? 'Error al actualizar el viaje',
            offersErrorCode: normalized,
            processingTripAction: null,
            tripErrorMessage: message ?? 'Error al actualizar el viaje',
          );
        } catch (e) {
          debugPrint('[DRIVER_RT] Error manejando trip:error: $e');
        }
      });

      // Algunos backends envían un solo evento trip:status con { tripId, status }.
      socket.on('trip:status', (data) {
        try {
          if (data is! Map) return;
          final tripId = data['tripId']?.toString();
          final newStatusRaw = data['status']?.toString();
          final newStatus = newStatusRaw?.trim().toLowerCase();
          final isFinal = _toBool(data['isFinal']) ||
              newStatus == 'completed' ||
              newStatus == 'cancelled' ||
              newStatus == 'expired';
          if (tripId == null || newStatus == null) return;
          if (state.activeTrip?.tripId != tripId) return;
          debugPrint('[DRIVER_RT] trip:status tripId=$tripId status=$newStatus');
          // Actualizamos estado y, si es estado final, sacamos el mapa
          // inmediatamente para evitar que quede la ruta pintada.
          if (isFinal && (newStatus == 'completed' || newStatus == 'cancelled' || newStatus == 'expired')) {
            if (newStatus == 'completed') {
              final ignoreUntilMs = DateTime.now()
                  .add(const Duration(seconds: 60))
                  .millisecondsSinceEpoch;
              state = state.copyWith(
                activeTrip: null,
                tripPendingRating: state.activeTrip!.copyWith(status: newStatus),
                lastCompletedTripId: tripId,
                processingTripAction: null,
                tripErrorMessage: null,
                ignoreActiveTripRestoreTripId: tripId,
                ignoreActiveTripRestoreUntilMs: ignoreUntilMs,
              );
              _setAvailability('available');
            } else {
              state = state.copyWith(
                activeTrip: null,
                tripPendingRating: null,
                lastCompletedTripId: tripId,
                processingTripAction: null,
                tripErrorMessage: null,
              );
              _setAvailability('available');
            }
          } else {
            state = state.copyWith(
              activeTrip: state.activeTrip!.copyWith(status: newStatus),
              processingTripAction: null,
              tripErrorMessage: null,
            );
          }
        } catch (e) {
          debugPrint('[DRIVER_RT] Error manejando trip:status: $e');
        }
      });

      void updateActiveTripStatus(String newStatus) {
        final current = state.activeTrip;
        if (current == null) return;
        state = state.copyWith(
          activeTrip: current.copyWith(status: newStatus),
          processingTripAction: null,
          tripErrorMessage: null,
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
              tripPendingRating: state.activeTrip!.copyWith(status: 'completed'),
              lastCompletedTripId: tripId,
              processingTripAction: null,
              tripErrorMessage: null,
              ignoreActiveTripRestoreTripId: tripId,
              ignoreActiveTripRestoreUntilMs: ignoreUntilMs,
            );
            _setAvailability('available');
          } else {
            state = state.copyWith(processingTripAction: null);
          }
        } catch (e) {
          debugPrint('[DRIVER_RT] Error manejando trip:completed: $e');
        }
      });

      socket.on('trip:cancelled', (data) {
        try {
          if (data is! Map) return;
          final tripId = data['tripId']?.toString();
          final reason = data['reason']?.toString();
          debugPrint(
              '[DRIVER_RT] trip:cancelled tripId=$tripId reason=$reason');
          if (tripId != null && state.activeTrip?.tripId == tripId) {
            state = state.copyWith(
              activeTrip: state.activeTrip!.copyWith(status: 'cancelled'),
              tripPendingRating: null,
              lastCompletedTripId: tripId,
              processingTripAction: null,
              tripErrorMessage: null,
            );
            _setAvailability('available');
          } else {
            state = state.copyWith(
              activeTrip: null,
              tripPendingRating: null,
              lastCompletedTripId: tripId,
              processingTripAction: null,
            );
          }
        } catch (e) {
          debugPrint('[DRIVER_RT] Error manejando trip:cancelled: $e');
        }
      });

      socket.on('connection:ack', (data) {
        try {
          if (data is! Map || data['ok'] != true) return;
          debugPrint('[DRIVER_RT] connection:ack data=$data');
          _applyProfileFromAck(Map<String, dynamic>.from(data));
          if (_shouldRefreshDriverPhoto()) {
            unawaited(_refreshDriverPhotoFromProfile());
          }
          final hasActiveTrip = data['hasActiveTrip'] == true;
          final activeTripData = data['activeTrip'];
          if (hasActiveTrip && activeTripData is Map) {
            final tripId = activeTripData['tripId']?.toString();
            final status =
                activeTripData['status']?.toString().toLowerCase() ?? 'accepted';
            final isFinal = _toBool(activeTripData['isFinal']) ||
                status == 'completed' ||
                status == 'cancelled' ||
                status == 'expired';
            final estimatedPriceRaw = activeTripData['estimatedPrice'];
            final estimatedPrice = estimatedPriceRaw is num
                ? estimatedPriceRaw.toDouble()
                : null;
            final pickupParsed = _parseLatLng(activeTripData, 'pickupLat', 'pickupLng');
            final (pickupLat, pickupLng) = (pickupParsed.$1 != null && pickupParsed.$2 != null)
                ? pickupParsed
                : _parseLatLngFromMap(activeTripData['origin']);
            final destParsed = _parseLatLng(activeTripData, 'destinationLat', 'destinationLng');
            final (destLat, destLng) = (destParsed.$1 != null && destParsed.$2 != null)
                ? destParsed
                : _parseLatLngFromMap(activeTripData['destination']);
            final passengerName = activeTripData['passengerName']?.toString();
            final passengerRatingRaw = activeTripData['passengerRating'];
            final passengerRating = passengerRatingRaw is num ? passengerRatingRaw.toDouble() : null;
            final originAddress = activeTripData['originAddress']?.toString();
            final destinationAddress = activeTripData['destinationAddress']?.toString();
            final tripDistanceRaw = activeTripData['tripDistanceKm'];
            final tripDistanceKm = tripDistanceRaw is num ? tripDistanceRaw.toDouble() : null;
            final etaDestRaw = activeTripData['etaToDestinationMinutes'];
            final etaToDestinationMinutes = etaDestRaw is num ? etaDestRaw.toDouble() : null;
            if (tripId != null) {
              if (_shouldIgnoreRestoreTrip(tripId)) {
                state = state.copyWith(
                  activeTrip: null,
                  tripPendingRating: state.tripPendingRating,
                  processingTripAction: null,
                  tripErrorMessage: null,
                );
              } else {
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
                originAddress: originAddress,
                destinationAddress: destinationAddress,
                tripDistanceKm: tripDistanceKm,
                etaToDestinationMinutes: etaToDestinationMinutes,
              );

              // Si ya estamos en flujo de rating para este mismo trip, no
              // restauremos el mapa aunque el backend aún mande estados
              // intermedios (evita que reaparezca "trayecto" después de
              // finalizar).
              final existingPending = state.tripPendingRating;
              if (existingPending != null && existingPending.tripId == tripId) {
                state = state.copyWith(
                  activeTrip: null,
                  tripPendingRating: existingPending,
                  processingTripAction: null,
                  tripErrorMessage: null,
                );
                debugPrint(
                    '[DRIVER_RT] connection:ack llegó durante rating -> ignorando restore mapa tripId=$tripId');
              } else if (isFinal) {
                // Si el backend ya considera el viaje final, NO lo restauramos
                // como "viaje activo" (para que no vuelva el mapa y el estado).
                final ignoreUntilMs = DateTime.now()
                    .add(const Duration(seconds: 60))
                    .millisecondsSinceEpoch;
                state = state.copyWith(
                  activeTrip: null,
                  tripPendingRating: parsedTrip,
                  lastCompletedTripId: tripId,
                  processingTripAction: null,
                  tripErrorMessage: null,
                  ignoreActiveTripRestoreTripId: tripId,
                  ignoreActiveTripRestoreUntilMs: ignoreUntilMs,
                );
                debugPrint(
                    '[DRIVER_RT] connection:ack recibió viaje final -> guardando para rating tripId=$tripId status=$status');
              } else {
                state = state.copyWith(
                  activeTrip: parsedTrip,
                  tripPendingRating: null,
                  processingTripAction: null,
                );
                debugPrint(
                    '[DRIVER_RT] connection:ack restaurado activeTrip=$tripId status=$status');
              }
              }
            }
          }
        } catch (e) {
          debugPrint('[DRIVER_RT] Error manejando connection:ack: $e');
        }
      });

      _socket = socket;
      await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('[DRIVER_RT] Timeout 15s esperando conexión al socket.');
          throw const _RealtimeException('SOCKET');
        },
      );

      state = state.copyWith(
        online: true,
        connecting: false,
        errorCode: null,
      );
      _lastTouchReconnect = null;
      _cancelTripReconnectLoop();
      debugPrint('[DRIVER_RT] Estado online=true (GPS en segundo plano).');
      unawaited(_startGpsTracking());
    } on _RealtimeException catch (e) {
      debugPrint('[DRIVER_RT] Error controlado: ${e.code}');
      final preserveTrip = state.activeTrip != null ||
          state.tripPendingRating != null;
      await _goOffline(internal: true, preserveTripState: preserveTrip);
      state = state.copyWith(
        online: false,
        connecting: false,
        errorCode: e.code,
      );
      if (preserveTrip) _ensureTripReconnectLoop();
    } catch (e, stackTrace) {
      debugPrint('[DRIVER_RT] Error inesperado al ir online: $e');
      debugPrint('[DRIVER_RT] $stackTrace');
      final preserveTrip = state.activeTrip != null ||
          state.tripPendingRating != null;
      await _goOffline(internal: true, preserveTripState: preserveTrip);
      state = state.copyWith(
        online: false,
        connecting: false,
        errorCode: 'UNKNOWN',
      );
      if (preserveTrip) _ensureTripReconnectLoop();
    }
  }

  Future<void> _goOffline({
    bool internal = false,
    bool userInitiated = false,
    bool preserveTripState = false,
  }) async {
    await _positionSub?.cancel();
    _positionSub = null;
    _lastLocationEmittedAt = null;

    try {
      _socket?.disconnect();
      _socket?.dispose();
    } catch (_) {}
    _socket = null;

    final preserve = preserveTripState &&
        (state.activeTrip != null || state.tripPendingRating != null);

    state = state.copyWith(
      online: false,
      connecting: false,
      errorCode: userInitiated ? null : (internal ? state.errorCode : null),
      pendingOffers: [],
      processingOfferTripId: null,
      offersErrorMessage: null,
      offersErrorCode: null,
      activeTrip: preserve ? state.activeTrip : null,
      tripPendingRating: preserve ? state.tripPendingRating : null,
      processingTripAction: preserve ? state.processingTripAction : null,
      tripErrorMessage: preserve ? state.tripErrorMessage : null,
      driverLat: preserve ? state.driverLat : null,
      driverLng: preserve ? state.driverLng : null,
    );
  }

  /// GPS e inyección de `location:update` sin bloquear el paso a `online:true`
  /// (el fix del GPS ya no atrasa el interruptor ni el connection:ack).
  Future<void> _startGpsTracking() async {
    _positionSub?.cancel();
    try {
      final initialPos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(const Duration(seconds: 8));
      if (_disposed) return;
      state = state.copyWith(
        driverLat: initialPos.latitude,
        driverLng: initialPos.longitude,
      );
      if (_socket?.connected == true) {
        _emitLocationToServer(
          initialPos.latitude,
          initialPos.longitude,
          initialPos.speed,
          force: true,
        );
      }
    } catch (e) {
      debugPrint('[DRIVER_RT] getCurrentPosition inicial falló: $e');
    }

    if (_disposed) return;
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      if (kDebugMode) {
        debugPrint(
          '[DRIVER_RT] location:update lat=${pos.latitude}, lng=${pos.longitude}',
        );
      }
      state = state.copyWith(
        driverLat: pos.latitude,
        driverLng: pos.longitude,
      );
      _emitLocationToServer(pos.latitude, pos.longitude, pos.speed);
    }, onError: (Object e, StackTrace st) {
      debugPrint('[DRIVER_RT] positionStream error: $e');
    });
  }

  /// Marcar que el conductor llegó al punto de recogida (trip:arrived).
  void markArrived() {
    final trip = state.activeTrip;
    if (trip == null || _socket?.connected != true) return;
    if (trip.status != 'accepted') {
      debugPrint(
          '[DRIVER_RT] markArrived ignorado: status=${trip.status}');
      return;
    }
    debugPrint('[DRIVER_RT] Enviando trip:arrived tripId=${trip.tripId}');
    _socket!.emit('trip:arrived', {'tripId': trip.tripId});
    // Actualización optimista: la UI pasa a "En punto de recogida" de inmediato.
    state = state.copyWith(
      activeTrip: trip.copyWith(status: 'arrived'),
      processingTripAction: null,
      tripErrorMessage: null,
    );
  }

  /// Iniciar viaje con pasajero a bordo (trip:started).
  void startTrip() {
    final trip = state.activeTrip;
    if (trip == null || _socket?.connected != true) return;
    if (trip.status != 'arrived') {
      debugPrint('[DRIVER_RT] startTrip ignorado: status=${trip.status}');
      return;
    }
    debugPrint('[DRIVER_RT] Enviando trip:started tripId=${trip.tripId}');
    _socket!.emit('trip:started', {'tripId': trip.tripId});
    state = state.copyWith(
      activeTrip: trip.copyWith(status: 'started'),
      processingTripAction: null,
      tripErrorMessage: null,
    );
  }

  /// Finalizar viaje (trip:completed).
  void completeTrip() {
    final trip = state.activeTrip;
    if (trip == null) return;
    if (_shouldIgnoreRestoreTrip(trip.tripId)) {
      // Evita reenviar completed si el backend aún está en estado de eventos
      // tardíos y el trip ya fue finalizado.
      debugPrint(
          '[DRIVER_RT] completeTrip ignorado por ignoreActiveTripRestoreTripId tripId=${trip.tripId}');
      return;
    }
    if (trip.status != 'started') {
      debugPrint(
          '[DRIVER_RT] completeTrip ignorado: status=${trip.status}');
      return;
    }
    // Marcamos el viaje como completado de forma optimista, pero
    // dejando el mapa fuera de pantalla para que el conductor vuelva a
    // solicitudes y solo vea la calificación.
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
      // Evita que eventos tardíos (connection:ack/status) reinyecten un
      // activeTrip en estado "started" durante la transición a calificación.
      ignoreActiveTripRestoreTripId: completedTripId,
      ignoreActiveTripRestoreUntilMs: ignoreUntilMs,
    );

    final socketConnected = _socket?.connected == true;
    if (socketConnected) {
      debugPrint('[DRIVER_RT] Enviando trip:completed tripId=$completedTripId');
      try {
        _socket!.emit('trip:completed', {'tripId': completedTripId});
      } catch (e) {
        debugPrint('[DRIVER_RT] Error enviando trip:completed: $e');
        // Guardamos para reintentar si falló el emit.
        _pendingTripCompletedTripId = completedTripId;
      }
    } else {
      // Si no hay conexión actual, guardamos para reintentar en cuanto el
      // socket vuelva a conectar.
      debugPrint(
          '[DRIVER_RT] Socket no conectado; guardando trip:completed pendiente tripId=$completedTripId');
      _pendingTripCompletedTripId = completedTripId;
    }
  }

  /// Limpia el viaje activo (usado tras pantalla de calificación).
  void clearActiveTrip() {
    state = state.copyWith(
      activeTrip: null,
      tripPendingRating: state.tripPendingRating,
      processingTripAction: null,
      tripErrorMessage: null,
    );
  }

  /// Limpia el trip guardado para la pantalla de calificación.
  void clearTripPendingRating() {
    final completedTripId =
        state.tripPendingRating?.tripId ?? state.lastCompletedTripId;
    state = state.copyWith(
      // Al terminar la calificación, el conductor debe volver a la lista
      // de solicitudes: por seguridad limpiamos tanto el pending rating
      // como cualquier viaje activo que pudiera haberse restaurado por
      // eventos tardíos del backend (connection:ack/status).
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
    // Asegura que el backend nos marque disponibles para recibir nuevas ofertas.
    _setAvailability('available');

    // Si por algún motivo el socket se cayó al finalizar, reintentamos
    // para que el switch vuelva a estar activo sin intervención manual.
    if (!state.online) {
      unawaited(_goOnline());
    }
  }

  /// El conductor acepta una oferta de viaje concreta (trip:accept).
  Future<void> acceptOffer(String tripId) async {
    final exists = state.pendingOffers
        .any((offer) => offer.tripId == tripId);
    if (!exists) {
      debugPrint(
          '[DRIVER_RT] acceptOffer llamado con tripId=$tripId que no está en pendingOffers.');
      return;
    }
    if (_socket?.connected != true) {
      debugPrint(
          '[DRIVER_RT] acceptOffer sin conexión de socket, abortando.');
      state = state.copyWith(
        offersErrorMessage: 'No hay conexión con el servidor.',
        offersErrorCode: 'NO_CONNECTION',
      );
      return;
    }

    debugPrint('[DRIVER_RT] Enviando trip:accept tripId=$tripId');
    state = state.copyWith(
      processingOfferTripId: tripId,
      processingIsAccept: true,
      offersErrorMessage: null,
      offersErrorCode: null,
    );
    _socket!.emit('trip:accept', {
      'tripId': tripId,
    });
  }

  /// El conductor rechaza una oferta de viaje concreta (trip:reject).
  Future<void> rejectOffer(String tripId) async {
    final exists = state.pendingOffers
        .any((offer) => offer.tripId == tripId);
    if (!exists) {
      debugPrint(
          '[DRIVER_RT] rejectOffer llamado con tripId=$tripId que no está en pendingOffers.');
      return;
    }
    if (_socket?.connected != true) {
      debugPrint(
          '[DRIVER_RT] rejectOffer sin conexión de socket, abortando.');
      state = state.copyWith(
        offersErrorMessage: 'No hay conexión con el servidor.',
        offersErrorCode: 'NO_CONNECTION',
      );
      return;
    }

    debugPrint('[DRIVER_RT] Enviando trip:reject tripId=$tripId');
    final updatedOffers = state.pendingOffers
        .where((offer) => offer.tripId != tripId)
        .toList();
    state = state.copyWith(
      pendingOffers: updatedOffers,
      processingOfferTripId: null,
      processingIsAccept: false,
      offersErrorMessage: null,
      offersErrorCode: null,
    );
    _socket!.emit('trip:reject', {
      'tripId': tripId,
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelTripReconnectLoop();
    unawaited(_goOffline(internal: true, preserveTripState: false));
    super.dispose();
  }
}

class _RealtimeException implements Exception {
  final String code;
  const _RealtimeException(this.code);

  @override
  String toString() => 'RealtimeException($code)';
}

/// Modelo de la oferta de viaje (trip:offer) recibida por el conductor.
/// Incluye datos opcionales para UX: distancia al origen, pasajero, direcciones.
class DriverTripOffer {
  final String tripId;
  final double? offeredPrice;
  final double? etaMinutes;
  /// ETA hacia destino (origen → destino) que retorna el backend para `trip:offer`.
  final double? etaToDestinationMinutes;
  final double? distanceToPickupKm;
  final String? passengerName;
  final double? passengerRating;
  final String? originAddress;
  final String? destinationAddress;
  final double? tripDistanceKm;

  const DriverTripOffer({
    required this.tripId,
    this.offeredPrice,
    this.etaMinutes,
    this.etaToDestinationMinutes,
    this.distanceToPickupKm,
    this.passengerName,
    this.passengerRating,
    this.originAddress,
    this.destinationAddress,
    this.tripDistanceKm,
  });
}

/// Viaje activo del conductor (aceptado → llegó → en trayecto → completado/cancelado).
class DriverActiveTrip {
  final String tripId;
  /// accepted | arrived | started | completed | cancelled
  final String status;
  final double? estimatedPrice;
  final double? pickupLat;
  final double? pickupLng;
  final double? destinationLat;
  final double? destinationLng;
  final String? passengerName;
  final double? passengerRating;
  final String? originAddress;
  final String? destinationAddress;
  final double? tripDistanceKm;
  final double? etaToDestinationMinutes;

  const DriverActiveTrip({
    required this.tripId,
    required this.status,
    this.estimatedPrice,
    this.pickupLat,
    this.pickupLng,
    this.destinationLat,
    this.destinationLng,
    this.passengerName,
    this.passengerRating,
    this.originAddress,
    this.destinationAddress,
    this.tripDistanceKm,
    this.etaToDestinationMinutes,
  });

  DriverActiveTrip copyWith({
    String? tripId,
    String? status,
    double? estimatedPrice,
    double? pickupLat,
    double? pickupLng,
    double? destinationLat,
    double? destinationLng,
    String? passengerName,
    double? passengerRating,
    String? originAddress,
    String? destinationAddress,
    double? tripDistanceKm,
    double? etaToDestinationMinutes,
  }) {
    return DriverActiveTrip(
      tripId: tripId ?? this.tripId,
      status: status ?? this.status,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      passengerName: passengerName ?? this.passengerName,
      passengerRating: passengerRating ?? this.passengerRating,
      originAddress: originAddress ?? this.originAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      tripDistanceKm: tripDistanceKm ?? this.tripDistanceKm,
      etaToDestinationMinutes: etaToDestinationMinutes ?? this.etaToDestinationMinutes,
    );
  }
}

