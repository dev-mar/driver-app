import 'dart:async';

import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../core/config/driver_backend_config.dart';
import '../../core/config/driver_realtime_config.dart';
import '../../core/app_lifecycle/app_lifecycle_state.dart';
import '../../core/notifications/driver_push_token_service.dart';
import '../../core/notifications/driver_notification_service.dart';
import '../../core/foreground/driver_foreground_session.dart';
import '../../core/session/driver_map_preferences_store.dart';

final driverRealtimeProvider =
    StateNotifierProvider<DriverRealtimeController, DriverRealtimeState>(
  (ref) => DriverRealtimeController(),
);

/// Convención de errores (login/realtime):
/// - Estado/controladores publican códigos (`errorCode`, `tripErrorCode`) en
///   lugar de textos hardcodeados para UI.
/// - La pantalla (`driver_home_screen`) traduce códigos con `l10n`.
/// - Mensajes textuales solo se permiten como fallback de backend.
class DriverRealtimeState {
  final bool online;
  final bool connecting;
  /// Conductor quiere sesión de disponibilidad/ofertas (switch ON), aunque el socket falle temporalmente.
  final bool availabilityDesired;
  /// Código de error simple para i18n (NO_INTERNET, NO_GPS, GPS_SERVICE_OFF,
  /// NO_NOTIFICATIONS, NO_TOKEN, SOCKET, DRIVER_VEHICLE_REQUIRED, UNKNOWN).
  final String? errorCode;
  /// Ofertas de viaje pendientes (trip:offer) que el conductor puede aceptar/rechazar.
  final List<DriverTripOffer> pendingOffers;
  /// tripId de la oferta que se está procesando (aceptando o rechazando), o null.
  final String? processingOfferTripId;
  /// true si la operación en curso es aceptar, false si es rechazar.
  final bool processingIsAccept;
  /// Estado de error por oferta (`tripId`) para evitar contaminar otras tarjetas.
  final Map<String, String> offersErrorCodeByTripId;
  final Map<String, String> offersErrorMessageByTripId;
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
  /// Código de error en cambio de estado del viaje (trip:error).
  final String? tripErrorCode;
  final int? arrivalReminderCooldownUntilMs;
  final String? arrivalReminderErrorCode;
  /// Posición actual del conductor (actualizada con location:update) para el mapa.
  final double? driverLat;
  final double? driverLng;
  final double? driverBearing;
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
  final List<DriverTripChatMessage> chatMessages;
  final String? tripChatErrorCode;

  /// Valor interno para [copyWith] y poder asignar `null` en campos opcionales.
  static const Object _unset = Object();

  const DriverRealtimeState({
    required this.online,
    required this.connecting,
    this.availabilityDesired = false,
    this.errorCode,
    this.pendingOffers = const [],
    this.processingOfferTripId,
    this.processingIsAccept = true,
    this.offersErrorCodeByTripId = const {},
    this.offersErrorMessageByTripId = const {},
    this.activeTrip,
    this.tripPendingRating,
    this.ignoreActiveTripRestoreTripId,
    this.ignoreActiveTripRestoreUntilMs,
    this.lastCompletedTripId,
    this.processingTripAction,
    this.tripErrorMessage,
    this.tripErrorCode,
    this.arrivalReminderCooldownUntilMs,
    this.arrivalReminderErrorCode,
    this.driverLat,
    this.driverLng,
    this.driverBearing,
    this.driverDisplayName,
    this.driverVehicleLabel,
    this.driverRating,
    this.driverPictureProfile,
    this.driverPictureExpiresAt,
    this.chatMessages = const [],
    this.tripChatErrorCode,
  });

  DriverRealtimeState copyWith({
    bool? online,
    bool? connecting,
    bool? availabilityDesired,
    String? errorCode,
    List<DriverTripOffer>? pendingOffers,
    Object? processingOfferTripId = _unset,
    bool? processingIsAccept,
    Map<String, String>? offersErrorCodeByTripId,
    Map<String, String>? offersErrorMessageByTripId,
    Object? activeTrip = _unset,
    Object? tripPendingRating = _unset,
    Object? ignoreActiveTripRestoreTripId = _unset,
    Object? ignoreActiveTripRestoreUntilMs = _unset,
    Object? lastCompletedTripId = _unset,
    Object? processingTripAction = _unset,
    String? tripErrorMessage,
    String? tripErrorCode,
    Object? arrivalReminderCooldownUntilMs = _unset,
    String? arrivalReminderErrorCode,
    Object? driverLat = _unset,
    Object? driverLng = _unset,
    Object? driverBearing = _unset,
    Object? driverDisplayName = _unset,
    Object? driverVehicleLabel = _unset,
    Object? driverRating = _unset,
    Object? driverPictureProfile = _unset,
    Object? driverPictureExpiresAt = _unset,
    List<DriverTripChatMessage>? chatMessages,
    String? tripChatErrorCode,
  }) {
    return DriverRealtimeState(
      online: online ?? this.online,
      connecting: connecting ?? this.connecting,
      availabilityDesired: availabilityDesired ?? this.availabilityDesired,
      errorCode: errorCode,
      pendingOffers: pendingOffers ?? this.pendingOffers,
      processingOfferTripId: identical(processingOfferTripId, _unset)
          ? this.processingOfferTripId
          : processingOfferTripId as String?,
      processingIsAccept: processingIsAccept ?? this.processingIsAccept,
      offersErrorCodeByTripId:
          offersErrorCodeByTripId ?? this.offersErrorCodeByTripId,
      offersErrorMessageByTripId:
          offersErrorMessageByTripId ?? this.offersErrorMessageByTripId,
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
      tripErrorCode: tripErrorCode,
      arrivalReminderCooldownUntilMs: identical(arrivalReminderCooldownUntilMs, _unset)
          ? this.arrivalReminderCooldownUntilMs
          : arrivalReminderCooldownUntilMs as int?,
      arrivalReminderErrorCode: arrivalReminderErrorCode,
      driverLat: identical(driverLat, _unset) ? this.driverLat : driverLat as double?,
      driverLng: identical(driverLng, _unset) ? this.driverLng : driverLng as double?,
      driverBearing: identical(driverBearing, _unset)
          ? this.driverBearing
          : driverBearing as double?,
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
      chatMessages: chatMessages ?? this.chatMessages,
      tripChatErrorCode: tripChatErrorCode,
    );
  }

  static const initial =
      DriverRealtimeState(
        online: false,
        connecting: false,
        availabilityDesired: false,
        errorCode: null,
        pendingOffers: [],
        processingOfferTripId: null,
        processingIsAccept: true,
        offersErrorCodeByTripId: {},
        offersErrorMessageByTripId: {},
        activeTrip: null,
        tripPendingRating: null,
        ignoreActiveTripRestoreTripId: null,
        ignoreActiveTripRestoreUntilMs: null,
        lastCompletedTripId: null,
        processingTripAction: null,
        tripErrorMessage: null,
        tripErrorCode: null,
        arrivalReminderCooldownUntilMs: null,
        arrivalReminderErrorCode: null,
        driverLat: null,
        driverLng: null,
        driverBearing: null,
        driverDisplayName: null,
        driverVehicleLabel: null,
        driverRating: null,
        driverPictureProfile: null,
        driverPictureExpiresAt: null,
        chatMessages: [],
        tripChatErrorCode: null,
      );
}

/// Chat pasajero–conductor: solo en `accepted` / `arrived` (antes de iniciar el trayecto).
bool driverTripChatPhaseActive(String? tripStatus) {
  return tripStatus == 'accepted' || tripStatus == 'arrived';
}

class DriverTripChatMessage {
  final String id;
  final String tripId;
  final String senderRole;
  final String messageKind;
  final String? templateCode;
  final String messageText;
  final DateTime? createdAt;

  const DriverTripChatMessage({
    required this.id,
    required this.tripId,
    required this.senderRole,
    required this.messageKind,
    required this.templateCode,
    required this.messageText,
    required this.createdAt,
  });
}

/// Valor visual del switch "En línea": ON con socket, reconectando o con viaje /
/// calificación pendiente aunque `online` sea false (caída de red durante carrera).
extension DriverRealtimeStateAvailabilityUi on DriverRealtimeState {
  bool get availabilitySwitchVisualOn {
    if (online) return true;
    if (connecting) return true;
    if (activeTrip != null || tripPendingRating != null) return true;
    return availabilityDesired;
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

double? _asDouble(dynamic raw) {
  if (raw is num) return raw.toDouble();
  if (raw is String) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    return double.tryParse(value);
  }
  return null;
}

String _socketConnectErrorToCode(dynamic data) {
  final s = data?.toString() ?? '';
  final up = s.toUpperCase();
  if (up.contains('AUTH_FAILED') ||
      up.contains('UNAUTHORIZED') ||
      up.contains('AUTH_REQUIRED') ||
      up.contains('DRIVER_NOT_FOUND') ||
      up.contains('INVALID_PAYLOAD_CONTENT')) {
    return 'AUTH';
  }
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
  static const bool _verboseRealtimeLogs = false;

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
  Timer? _availabilityReconnectTimer;
  Timer? _presenceHeartbeatTimer;
  DateTime? _lastTouchReconnect;
  bool _disposed = false;
  /// `true` tras apagar el switch o logout: no auto-reconectar por `onDisconnect`.
  bool _userRequestedOffline = false;
  /// `true` mientras el conductor quiere estar disponible (switch ON en esta sesión).
  bool _availabilitySessionDesired = false;
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

  void _logVerbose(String message) {
    if (!_verboseRealtimeLogs) return;
    debugPrint('[DRIVER_RT] $message');
  }

  void _clearOfferErrorForTrip(String tripId) {
    final codeMap = Map<String, String>.from(state.offersErrorCodeByTripId);
    final messageMap = Map<String, String>.from(state.offersErrorMessageByTripId);
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
    final messageMap = Map<String, String>.from(state.offersErrorMessageByTripId);
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

  bool _toBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }
    return false;
  }

  String? _extractTripIdFromPayload(Map data) {
    final directKeys = <String>[
      'tripId',
      'trip_id',
      'offerTripId',
      'offer_id',
      'requestId',
    ];
    for (final key in directKeys) {
      final raw = data[key]?.toString().trim();
      if (raw != null && raw.isNotEmpty) {
        return raw;
      }
    }
    final nestedTrip = data['trip'];
    if (nestedTrip is Map) {
      final raw = nestedTrip['tripId']?.toString().trim() ??
          nestedTrip['id']?.toString().trim();
      if (raw != null && raw.isNotEmpty) {
        return raw;
      }
    }
    return null;
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

  /// Antes de desconectar por offline explícito: el backend excluye ofertas con `availability = available`.
  /// Sin esto, `is_online` y `available` pueden persistir hasta la gracia de `disconnect`.
  Future<void> _emitAvailabilityOnBreakBeforeDisconnect() async {
    final s = _socket;
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

  /// Emite al socket respetando [_locationEmitMinInterval] salvo [force].
  void _emitLocationToServer (
    double lat,
    double lng,
    double speed, {
    double bearing = 0,
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
      'bearing': bearing,
      'speed': speed,
    });
  }

  void _cancelPresenceHeartbeat() {
    _presenceHeartbeatTimer?.cancel();
    _presenceHeartbeatTimer = null;
  }

  /// Heartbeat explícito de presencia para mantener `last_ping` cuando
  /// el sistema reduce temporalmente la frecuencia de GPS en background.
  void _startPresenceHeartbeat() {
    _cancelPresenceHeartbeat();
    _presenceHeartbeatTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      final socket = _socket;
      if (socket == null || !socket.connected) return;
      socket.emit('driver:heartbeat', {
        'clientTs': DateTime.now().toIso8601String(),
      });
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
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      _locationPermissionCached = null;
      _locationPermissionCachedAt = null;
      debugPrint('[DRIVER_RT] Permiso de ubicación insuficiente: $permission');
      throw const _RealtimeException('NO_GPS');
    }
    _locationPermissionCached = permission;
    _locationPermissionCachedAt = DateTime.now();
  }

  Future<void> _ensureLocationServiceEnabled () async {
    if (kIsWeb) return;
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      debugPrint('[DRIVER_RT] Servicio de ubicación del sistema desactivado.');
      throw const _RealtimeException('GPS_SERVICE_OFF');
    }
  }

  /// Notificaciones son necesarias para ofertas en segundo plano (FCM).
  Future<void> _ensureNotificationPermissionForTripOffers () async {
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
        '[DRIVER_RT] Permiso de notificaciones denegado: ${settings.authorizationStatus}');
    throw const _RealtimeException('NO_NOTIFICATIONS');
  }

  bool _notificationPermissionOk (NotificationSettings settings) {
    final s = settings.authorizationStatus;
    return s == AuthorizationStatus.authorized ||
        s == AuthorizationStatus.provisional;
  }

  bool _isAuthSocketErrorCode(String code) => code == 'AUTH';

  Future<bool> _tryRefreshDriverSession() async {
    final refreshToken = await _storage.read(key: 'driver_refresh_token');
    if (refreshToken == null || refreshToken.isEmpty) {
      debugPrint('[DRIVER_RT] No hay refresh token para renovar sesión.');
      return false;
    }
    try {
      final res = await _profileDio().post<Map<String, dynamic>>(
        '/api/v2/auth/refresh',
        data: <String, dynamic>{'refresh_token': refreshToken},
      );
      final body = res.data;
      if (body == null) return false;
      final token = body['token']?.toString();
      final newRefreshToken = body['refresh_token']?.toString();
      if (token == null || token.isEmpty) return false;
      await _storage.write(key: 'driver_token', value: token);
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await _storage.write(key: 'driver_refresh_token', value: newRefreshToken);
      }
      debugPrint('[DRIVER_RT] Refresh de sesión OK. Reintentando socket...');
      return true;
    } catch (e) {
      debugPrint('[DRIVER_RT] Refresh de sesión falló: $e');
      return false;
    }
  }

  Future<void> _stopRealtimeAndInvalidateSession() async {
    _userRequestedOffline = true;
    _availabilitySessionDesired = false;
    state = state.copyWith(
      availabilityDesired: false,
      errorCode: state.errorCode,
    );
    _cancelTripReconnectLoop();
    _cancelAvailabilityReconnectLoop();
    _lastTouchReconnect = null;
    _pendingTripCompletedTripId = null;
    await DriverMapPreferencesStore.clearMapPreferencesForCurrentSession();
    await _storage.delete(key: 'driver_token');
    await _storage.delete(key: 'driver_refresh_token');
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
    // En logout forzado debemos ejecutar limpieza total incluso si ya estaba offline.
    if (value == state.online && !state.connecting && !(forceOffline && !value)) return;
    if (value) {
      _userRequestedOffline = false;
      _availabilitySessionDesired = true;
      state = state.copyWith(
        availabilityDesired: true,
        errorCode: state.errorCode,
      );
      _cancelAvailabilityReconnectLoop();
      await _goOnline();
      return;
    }
    if (!forceOffline &&
        (state.activeTrip != null || state.tripPendingRating != null)) {
      state = state.copyWith(errorCode: 'ACTIVE_TRIP_CANT_GO_OFFLINE');
      return;
    }
    _userRequestedOffline = true;
    _availabilitySessionDesired = false;
    state = state.copyWith(
      availabilityDesired: false,
      errorCode: state.errorCode,
    );
    _cancelTripReconnectLoop();
    _cancelAvailabilityReconnectLoop();
    _lastTouchReconnect = null;
    await _goOffline(userInitiated: true, preserveTripState: false);
    if (forceOffline) {
      _pendingTripCompletedTripId = null;
      _locationPermissionCached = null;
      _locationPermissionCachedAt = null;
      _lastDriverPhotoRefreshAt = null;
      // Evita que otro conductor en el mismo dispositivo herede mini perfil / foto del anterior.
      state = state.copyWith(
        driverDisplayName: null,
        driverVehicleLabel: null,
        driverRating: null,
        driverPictureProfile: null,
        driverPictureExpiresAt: null,
        lastCompletedTripId: null,
        ignoreActiveTripRestoreTripId: null,
        ignoreActiveTripRestoreUntilMs: null,
      );
    }
  }

  Future<void> _handleUnexpectedDisconnectWhileAvailable() async {
    if (_userRequestedOffline || _disposed) return;
    await _goOffline(
      internal: true,
      preserveTripState: false,
      retainConnectingIndicator: true,
      preservePendingOffers: true,
    );
    if (_userRequestedOffline || _disposed) return;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (_userRequestedOffline || _disposed) return;
    try {
      await _goOnline();
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
    await _goOffline(
      internal: true,
      preserveTripState: true,
      preservePendingOffers: true,
    );
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

  /// Expuesto para el home: reintentar socket si el conductor dejó el switch ON
  /// y cayó la conexión (segundo plano / red), sin viaje activo.
  bool get wantsAvailabilitySessionReconnect =>
      _availabilitySessionDesired && !_userRequestedOffline && !_disposed;

  void touchReconnectIfWantedOnline() {
    if (_userRequestedOffline || _disposed) return;
    if (!_availabilitySessionDesired) return;
    if (state.activeTrip != null || state.tripPendingRating != null) return;
    if (state.online) {
      _cancelAvailabilityReconnectLoop();
      return;
    }
    _ensureAvailabilityReconnectLoop();
    if (!state.connecting) {
      unawaited(setOnline(true));
    }
  }

  void _cancelAvailabilityReconnectLoop() {
    _availabilityReconnectTimer?.cancel();
    _availabilityReconnectTimer = null;
  }

  /// Reintentos periódicos en espera de ofertas (sin viaje) tras fallos de socket.
  void _ensureAvailabilityReconnectLoop() {
    if (_userRequestedOffline || _disposed) return;
    if (!_availabilitySessionDesired) return;
    if (state.activeTrip != null || state.tripPendingRating != null) return;
    if (state.online) {
      _cancelAvailabilityReconnectLoop();
      return;
    }
    _availabilityReconnectTimer?.cancel();
    if (!state.connecting) {
      unawaited(setOnline(true));
    }
    _availabilityReconnectTimer =
        Timer.periodic(const Duration(seconds: 8), (_) async {
      if (_userRequestedOffline || _disposed) {
        _cancelAvailabilityReconnectLoop();
        return;
      }
      if (!_availabilitySessionDesired) {
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
      if (state.connecting) return;
      await setOnline(true);
    });
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

  Future<void> _performGoOnline({bool allowAuthRefreshRetry = true}) async {
    _logVerbose('setOnline(true) iniciando...');
    _cancelTripReconnectLoop();
    _cancelAvailabilityReconnectLoop();
    state = state.copyWith(
      connecting: true,
      errorCode: null,
      // Evita mostrar datos del conductor anterior durante reconexión
      // o cuando `connection:ack` llega incompleto.
      driverDisplayName: null,
      driverVehicleLabel: null,
      driverRating: null,
      driverPictureProfile: null,
      driverPictureExpiresAt: null,
    );

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
      _logVerbose('Token leído. length=${token.length}');

      await _ensureLocationServiceEnabled();
      await _ensureLocationPermissionForSocket();
      await _ensureNotificationPermissionForTripOffers();

      _logVerbose(
          'Conectando socket a ${DriverRealtimeConfig.socketUrl}${DriverRealtimeConfig.socketPath}...');

      final socket = io.io(
        DriverRealtimeConfig.socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setPath(DriverRealtimeConfig.socketPath)
            .enableForceNew()
            .disableMultiplex()
            .setExtraHeaders({
              'Authorization': 'Bearer $token',
            })
            .setAuth({'token': token})
            .build(),
      );

      final completer = Completer<void>();

      socket.onDisconnect((data) {
        _logVerbose('disconnect data=$data');
        if (_disposed) return;
        if (_userRequestedOffline) return;
        final hasTrip =
            state.activeTrip != null || state.tripPendingRating != null;
        if (hasTrip) {
          unawaited(_handleUnexpectedDisconnectWithTrip());
          return;
        }
        // Sin viaje activo: el SO suele cortar el WebSocket en segundo plano;
        // reconectar para no apagar el interruptor ni perder ofertas/FCM.
        unawaited(_handleUnexpectedDisconnectWhileAvailable());
      });

      socket.onConnect((_) {
        _logVerbose('Socket conectado correctamente.');
        if (!completer.isCompleted) completer.complete();
        // Alineación con el contrato: al estar online, el conductor debe
        // estar en disponibilidad "available" para recibir ofertas.
        _setAvailability('available');
        _startPresenceHeartbeat();
        socket.emit('driver:heartbeat', {
          'clientTs': DateTime.now().toIso8601String(),
        });
        // Reintento seguro de finalización pendiente.
        final pending = _pendingTripCompletedTripId;
        if (pending != null) {
          _logVerbose('Reintentando trip:completed pendiente tripId=$pending');
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
        _logVerbose('onConnectError recibido. data=$data');
        if (!completer.isCompleted) {
          completer.completeError(
            _RealtimeException(_socketConnectErrorToCode(data)),
          );
        }
      });
      socket.onError((data) {
        _logVerbose('onError recibido en socket. data=$data');
        if (!completer.isCompleted) {
          completer.completeError(
            _RealtimeException(_socketConnectErrorToCode(data)),
          );
        }
      });
      socket.on('driver:availability_ack', (data) {
        _logVerbose('driver:availability_ack data=$data');
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
            unawaited(_syncDriverForegroundSession());
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
            unawaited(_syncDriverForegroundSession());
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
          final currencyCode = (data['currencyCode'] ?? data['currency'])?.toString();
          final etaMinutes =
              etaMinutesRaw is num ? etaMinutesRaw.toDouble() : null;
          final etaToDestinationMinutes =
              etaDestRaw is num ? etaDestRaw.toDouble() : null;
          final distanceToPickupKm = distanceToPickupRaw is num
              ? distanceToPickupRaw.toDouble()
              : null;
          final passengerName = data['passengerName']?.toString();
          final passengerRating = _asDouble(data['passengerRating']);
          final originAddress = data['originAddress']?.toString();
          final destinationAddress = data['destinationAddress']?.toString();
          final tripDistanceRaw = data['tripDistanceKm'];
          final tripDistanceKm =
              tripDistanceRaw is num ? tripDistanceRaw.toDouble() : null;

          _logVerbose(
              'trip:offer recibido tripId=$tripId, price=$offeredPrice, eta=$etaMinutes, dist=$distanceToPickupKm');

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
            currencyCode: currencyCode,
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
          );
          _clearOfferErrorForTrip(tripId);
          unawaited(_syncDriverForegroundSession());
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
          final currencyCode = (data['currencyCode'] ?? data['currency'])?.toString();
          _logVerbose('trip:accepted raw data=$data');

          final pickupParsed = _parseLatLng(data, 'pickupLat', 'pickupLng');
          final (pickupLat, pickupLng) = (pickupParsed.$1 != null && pickupParsed.$2 != null)
              ? pickupParsed
              : _parseLatLngFromMap(data['origin']);
          final destParsed = _parseLatLng(data, 'destinationLat', 'destinationLng');
          final (destLat, destLng) = (destParsed.$1 != null && destParsed.$2 != null)
              ? destParsed
              : _parseLatLngFromMap(data['destination']);
          final passengerName = data['passengerName']?.toString();
          final passengerRating = _asDouble(data['passengerRating']);
          final originAddress = data['originAddress']?.toString();
          final destinationAddress = data['destinationAddress']?.toString();
          final tripDistanceRaw = data['tripDistanceKm'];
          final tripDistanceKm = tripDistanceRaw is num ? tripDistanceRaw.toDouble() : null;
          final etaDestRaw = data['etaToDestinationMinutes'];
          final etaToDestinationMinutes = etaDestRaw is num ? etaDestRaw.toDouble() : null;
          final rawRouteEnc = data['routeOverviewEncoded'];
          final routeOverviewEncoded = rawRouteEnc != null &&
                  rawRouteEnc.toString().trim().isNotEmpty
              ? rawRouteEnc.toString().trim()
              : null;
          _logVerbose(
              'trip:accepted recibido tripId=$tripId status=$status '
              'pickup=($pickupLat,$pickupLng) dest=($destLat,$destLng)');

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
            _clearOfferErrorForTrip(tripId);
          } else {
            state = state.copyWith(
              processingOfferTripId: null,
            );
          }
          unawaited(_syncDriverForegroundSession());
        } catch (e) {
          debugPrint('[DRIVER_RT] Error manejando trip:accepted: $e');
        }
      });

      socket.on('trip:rejected', (data) {
        try {
          if (data is! Map) return;
          final tripId = data['tripId']?.toString();
          _logVerbose('trip:rejected recibido tripId=$tripId');

          if (tripId != null) {
            final updatedOffers = state.pendingOffers
                .where((offer) => offer.tripId != tripId)
                .toList();
            state = state.copyWith(
              pendingOffers: updatedOffers,
              processingOfferTripId: null,
            );
            _clearOfferErrorForTrip(tripId);
          } else {
            state = state.copyWith(
              processingOfferTripId: null,
            );
          }
          unawaited(_syncDriverForegroundSession());
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
            processingTripAction: null,
            tripErrorMessage: message,
            tripErrorCode: normalized ?? 'TRIP_UPDATE_FAILED',
            arrivalReminderErrorCode: null,
          );
          if (targetTripId != null && targetTripId.isNotEmpty) {
            _setOfferErrorForTrip(
              tripId: targetTripId,
              code: normalized,
              message: message,
            );
          }
        } catch (e) {
          debugPrint('[DRIVER_RT] Error manejando trip:error: $e');
        }
      });

      // Algunos backends envían un solo evento trip:status con { tripId, status }.
      socket.on('trip:status', (data) {
        try {
          if (data is! Map) return;
          final tripId = _extractTripIdFromPayload(data);
          final newStatusRaw = data['status']?.toString();
          final newStatus = newStatusRaw?.trim().toLowerCase();
          final isFinal = _toBool(data['isFinal']) ||
              newStatus == 'completed' ||
              newStatus == 'cancelled' ||
              newStatus == 'expired';
          if (tripId == null || newStatus == null) return;
          debugPrint('[DRIVER_RT] trip:status tripId=$tripId status=$newStatus');
          final activeTripMatches = state.activeTrip?.tripId == tripId;
          final pendingContainsTrip =
              state.pendingOffers.any((o) => o.tripId == tripId);
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
            _clearOfferErrorForTrip(tripId);
            unawaited(_syncDriverForegroundSession());
            return;
          }

          if (!activeTripMatches) return;
          // Actualizamos estado y, si es estado final, sacamos el mapa
          // inmediatamente para evitar que quede la ruta pintada.
          if (isFinal && (newStatus == 'completed' || newStatus == 'cancelled' || newStatus == 'expired')) {
            if (newStatus == 'completed') {
              final ignoreUntilMs = DateTime.now()
                  .add(const Duration(seconds: 60))
                  .millisecondsSinceEpoch;
              state = state.copyWith(
                pendingOffers: cleanedPendingOffers,
                activeTrip: null,
                tripPendingRating: state.activeTrip!.copyWith(status: newStatus),
                lastCompletedTripId: tripId,
                processingTripAction: null,
                tripErrorMessage: null,
                ignoreActiveTripRestoreTripId: tripId,
                ignoreActiveTripRestoreUntilMs: ignoreUntilMs,
                chatMessages: const [],
              );
              _setAvailability('available');
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
              _setAvailability('available');
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
              tripPendingRating: state.activeTrip!.copyWith(status: 'completed'),
              lastCompletedTripId: tripId,
              processingTripAction: null,
              tripErrorMessage: null,
              ignoreActiveTripRestoreTripId: tripId,
              ignoreActiveTripRestoreUntilMs: ignoreUntilMs,
              chatMessages: const [],
            );
            _setAvailability('available');
          } else {
            state = state.copyWith(processingTripAction: null);
          }
          unawaited(_syncDriverForegroundSession());
        } catch (e) {
          debugPrint('[DRIVER_RT] Error manejando trip:completed: $e');
        }
      });

      socket.on('trip:cancelled', (data) {
        try {
          if (data is! Map) return;
          final tripId = _extractTripIdFromPayload(data);
          final reason = data['reason']?.toString();
          final cleanedPendingOffers = state.pendingOffers
              .where((o) => o.tripId != tripId)
              .toList(growable: false);
          debugPrint(
              '[DRIVER_RT] trip:cancelled tripId=$tripId reason=$reason');
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
            _clearOfferErrorForTrip(tripId);
            _setAvailability('available');
          } else {
            state = state.copyWith(
              pendingOffers: cleanedPendingOffers,
              processingTripAction: null,
              processingOfferTripId: state.processingOfferTripId == tripId
                  ? null
                  : state.processingOfferTripId,
            );
            if (tripId != null) {
              _clearOfferErrorForTrip(tripId);
            }
          }
          unawaited(_syncDriverForegroundSession());
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
          final id = data['id']?.toString() ??
              '${DateTime.now().millisecondsSinceEpoch}-${state.chatMessages.length}';
          final senderRole = data['senderRole']?.toString() ?? 'passenger';
          final messageKind = data['messageKind']?.toString() ?? 'text';
          final templateCode = data['templateCode']?.toString();
          final messageText = data['messageText']?.toString().trim() ?? '';
          if (messageText.isEmpty) return;
          final createdAt = DateTime.tryParse(data['createdAt']?.toString() ?? '');
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
            if (inForeground &&
                DriverNotificationService.shouldPlayForegroundChatAlert()) {
              SystemSound.play(SystemSoundType.alert);
              HapticFeedback.lightImpact();
            }
            unawaited(
              DriverNotificationService.instance.showTripChatMessageIfBackground(
                isAppInForeground: inForeground,
                tripId: tripId,
                senderRole: senderRole,
                messageText: messageText,
                notifyInForeground: true,
              ),
            );
          }
        } catch (e) {
          debugPrint('[DRIVER_RT] Error manejando trip:chat:new: $e');
        }
      });

      socket.on('trip:chat:error', (data) {
        final code = (data is Map ? data['code'] : null)?.toString() ?? 'TRIP_CHAT_ERROR';
        state = state.copyWith(tripChatErrorCode: code);
      });

      socket.on('trip:arrival_reminder:ack', (data) {
        try {
          if (data is! Map) return;
          final cooldownSecRaw = data['cooldownSec'];
          final cooldownSec = cooldownSecRaw is num ? cooldownSecRaw.toInt() : 45;
          final until = DateTime.now().add(Duration(seconds: cooldownSec)).millisecondsSinceEpoch;
          state = state.copyWith(
            arrivalReminderCooldownUntilMs: until,
            arrivalReminderErrorCode: null,
          );
        } catch (_) {}
      });

      socket.on('trip:arrival_reminder:error', (data) {
        try {
          if (data is! Map) return;
          final code = data['code']?.toString() ?? 'TRIP_ARRIVAL_REMINDER_ERROR';
          final retryAfterRaw = data['retryAfterSec'];
          final retryAfter = retryAfterRaw is num ? retryAfterRaw.toInt() : 0;
          final until = retryAfter > 0
              ? DateTime.now().add(Duration(seconds: retryAfter)).millisecondsSinceEpoch
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
          _logVerbose('connection:ack data=$data');
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
            final currencyCode = (activeTripData['currencyCode'] ?? activeTripData['currency'])?.toString();
            final pickupParsed = _parseLatLng(activeTripData, 'pickupLat', 'pickupLng');
            final (pickupLat, pickupLng) = (pickupParsed.$1 != null && pickupParsed.$2 != null)
                ? pickupParsed
                : _parseLatLngFromMap(activeTripData['origin']);
            final destParsed = _parseLatLng(activeTripData, 'destinationLat', 'destinationLng');
            final (destLat, destLng) = (destParsed.$1 != null && destParsed.$2 != null)
                ? destParsed
                : _parseLatLngFromMap(activeTripData['destination']);
            final passengerName = activeTripData['passengerName']?.toString();
            final passengerRating = _asDouble(activeTripData['passengerRating']);
            final originAddress = activeTripData['originAddress']?.toString();
            final destinationAddress = activeTripData['destinationAddress']?.toString();
            final tripDistanceRaw = activeTripData['tripDistanceKm'];
            final tripDistanceKm = tripDistanceRaw is num ? tripDistanceRaw.toDouble() : null;
            final etaDestRaw = activeTripData['etaToDestinationMinutes'];
            final etaToDestinationMinutes = etaDestRaw is num ? etaDestRaw.toDouble() : null;
            final rawRouteEncAck = activeTripData['routeOverviewEncoded'];
            final routeOverviewEncoded = rawRouteEncAck != null &&
                    rawRouteEncAck.toString().trim().isNotEmpty
                ? rawRouteEncAck.toString().trim()
                : null;
            if (tripId != null) {
              if (_shouldIgnoreRestoreTrip(tripId)) {
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
              // El ack a veces trae solo status/coords; no pisar dirección/pasajero ya mostrados.
              final mergedTrip = (existingTrip != null && existingTrip.tripId == tripId)
                  ? existingTrip.copyWith(
                      status: status,
                      estimatedPrice: estimatedPrice ?? existingTrip.estimatedPrice,
                      pickupLat: pickupLat ?? existingTrip.pickupLat,
                      pickupLng: pickupLng ?? existingTrip.pickupLng,
                      destinationLat: destLat ?? existingTrip.destinationLat,
                      destinationLng: destLng ?? existingTrip.destinationLng,
                      passengerName: passengerName ?? existingTrip.passengerName,
                      passengerRating: passengerRating ?? existingTrip.passengerRating,
                      currencyCode: currencyCode ?? existingTrip.currencyCode,
                      originAddress: originAddress ?? existingTrip.originAddress,
                      destinationAddress:
                          destinationAddress ?? existingTrip.destinationAddress,
                      tripDistanceKm: tripDistanceKm ?? existingTrip.tripDistanceKm,
                      etaToDestinationMinutes:
                          etaToDestinationMinutes ?? existingTrip.etaToDestinationMinutes,
                      routeOverviewEncoded:
                          routeOverviewEncoded ?? existingTrip.routeOverviewEncoded,
                    )
                  : parsedTrip;

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
                  tripPendingRating: mergedTrip,
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
                  activeTrip: mergedTrip,
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
      _cancelAvailabilityReconnectLoop();
      debugPrint('[DRIVER_RT] Estado online=true (GPS en segundo plano).');
      unawaited(DriverPushTokenService.instance.syncTokenIfPossible());
      unawaited(_startGpsTracking());
      unawaited(_syncDriverForegroundSession());
    } on _RealtimeException catch (e) {
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
      if (_isAuthSocketErrorCode(e.code)) {
        await _stopRealtimeAndInvalidateSession();
        state = state.copyWith(
          online: false,
          connecting: false,
          errorCode: 'AUTH',
        );
        return;
      }
      final preserveTrip = state.activeTrip != null ||
          state.tripPendingRating != null;
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
        _ensureTripReconnectLoop();
      } else if (_availabilitySessionDesired && !_userRequestedOffline) {
        _ensureAvailabilityReconnectLoop();
      }
    } catch (e, stackTrace) {
      debugPrint('[DRIVER_RT] Error inesperado al ir online: $e');
      debugPrint('[DRIVER_RT] $stackTrace');
      final preserveTrip = state.activeTrip != null ||
          state.tripPendingRating != null;
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
        _ensureTripReconnectLoop();
      } else if (_availabilitySessionDesired && !_userRequestedOffline) {
        _ensureAvailabilityReconnectLoop();
      }
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
    final socket = _socket;
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

  void sendTripChatText({
    required String tripId,
    required String text,
  }) {
    final sanitized = text.trim();
    if (sanitized.isEmpty) return;
    if (!driverTripChatPhaseActive(state.activeTrip?.status)) {
      state = state.copyWith(tripChatErrorCode: 'TRIP_CHAT_NOT_AVAILABLE');
      return;
    }
    final socket = _socket;
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

  void sendArrivalReminder () {
    final tripId = state.activeTrip?.tripId;
    if (tripId == null || tripId.isEmpty) return;
    final socket = _socket;
    if (socket == null || !socket.connected) {
      state = state.copyWith(arrivalReminderErrorCode: 'SOCKET');
      return;
    }
    socket.emit('trip:arrival_reminder', {'tripId': tripId});
  }

  Future<void> submitTripRating({
    required String tripId,
    required int stars,
    List<String> feedbackCodes = const [],
  }) async {
    if (tripId.trim().isEmpty) return;
    if (stars < 1 || stars > 5) return;
    final token = await _storage.read(key: 'driver_token');
    if (token == null || token.isEmpty) return;
    await _profileDio().post<Map<String, dynamic>>(
      '/drivers/me/trips/$tripId/rating',
      data: <String, dynamic>{
        'stars': stars,
        if (feedbackCodes.isNotEmpty) 'feedbackCodes': feedbackCodes,
      },
      options: Options(
        headers: <String, String>{'Authorization': 'Bearer $token'},
      ),
    );
  }

  Future<List<DriverRatingFeedbackItem>> fetchDriverRatingFeedbackCatalog({
    required int stars,
  }) async {
    if (stars < 1 || stars > 5) return const [];
    final token = await _storage.read(key: 'driver_token');
    if (token == null || token.isEmpty) return const [];
    final res = await _profileDio().get<Map<String, dynamic>>(
      '/drivers/me/trips/rating-feedback-catalog',
      queryParameters: <String, dynamic>{'stars': stars},
      options: Options(
        headers: <String, String>{'Authorization': 'Bearer $token'},
      ),
    );
    final body = res.data ?? const <String, dynamic>{};
    final data = body['data'];
    if (data is! Map) return const [];
    final items = data['items'];
    if (items is! List) return const [];
    return items
        .whereType<Map>()
        .map((m) => DriverRatingFeedbackItem.fromJson(Map<String, dynamic>.from(m)))
        .toList(growable: false);
  }

  /// Notificación persistente + foreground service (Android).
  ///
  /// Debe seguir activo mientras el conductor mantenga la sesión de disponibilidad
  /// (`_availabilitySessionDesired`), **incluso si el socket cayó en segundo plano**
  /// (`state.online == false` temporal). Si usáramos solo `state.online`, cada
  /// `_goOffline` por disconnect mataría el FGS y el icono desaparecería.
  /// Se detiene con offline explícito, logout o bloqueo RBAC.
  Future<void> _syncDriverForegroundSession() async {
    final err = state.errorCode;
    final rbacBlocked = err != null && err.startsWith('RBAC_');
    final availabilitySessionActive = !_disposed &&
        !_userRequestedOffline &&
        _availabilitySessionDesired &&
        !rbacBlocked;

    await DriverForegroundSession.instance.sync(
      availabilitySessionActive: availabilitySessionActive,
      pendingOfferCount: state.pendingOffers.length,
      hasActiveTrip: state.activeTrip != null,
    );
  }

  /// [preservePendingOffers]: si es true, no vacía la lista de solicitudes ni el
  /// procesamiento en curso. Usar en reconexiones automáticas (caída de socket,
  /// refresh de sesión) para que una oferta siga visible hasta aceptar/rechazar
  /// o hasta evento del backend — no al pedir offline explícito ni al invalidar sesión.
  Future<void> _goOffline({
    bool internal = false,
    bool userInitiated = false,
    bool preserveTripState = false,
    bool retainConnectingIndicator = false,
    bool preservePendingOffers = false,
  }) async {
    await _positionSub?.cancel();
    _positionSub = null;
    _lastLocationEmittedAt = null;
    _cancelPresenceHeartbeat();

    if (userInitiated) {
      await _emitAvailabilityOnBreakBeforeDisconnect();
    }

    try {
      _socket?.disconnect();
      _socket?.dispose();
    } catch (_) {}
    _socket = null;

    final preserve = preserveTripState &&
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
      processingIsAccept:
          preservePendingOffers ? state.processingIsAccept : true,
      offersErrorCodeByTripId:
          preservePendingOffers ? state.offersErrorCodeByTripId : const {},
      offersErrorMessageByTripId:
          preservePendingOffers ? state.offersErrorMessageByTripId : const {},
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

  /// GPS e inyección de `location:update` sin bloquear el paso a `online:true`
  /// (el fix del GPS ya no atrasa el interruptor ni el connection:ack).
  Future<void> _startGpsTracking() async {
    _positionSub?.cancel();
    try {
      final initialPos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).timeout(const Duration(seconds: 15));
      if (_disposed) return;
      state = state.copyWith(
        driverLat: initialPos.latitude,
        driverLng: initialPos.longitude,
        driverBearing: initialPos.heading,
      );
      if (_socket?.connected == true) {
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

    if (_disposed) return;
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((pos) {
      if (kDebugMode) {
        _logVerbose(
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
    _logVerbose('Enviando trip:arrived tripId=${trip.tripId}');
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
    _logVerbose('Enviando trip:started tripId=${trip.tripId}');
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
    if (trip.status != 'started' && trip.status != 'in_trip') {
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
      _logVerbose('Enviando trip:completed tripId=$completedTripId');
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

    // Si el socket se cayó al finalizar, reintentamos solo si el conductor
    // sigue queriendo sesión de disponibilidad (no apagó el switch ni cerró sesión).
    if (_availabilitySessionDesired &&
        !_userRequestedOffline &&
        !state.online) {
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
      );
      _setOfferErrorForTrip(
        tripId: tripId,
        code: 'NO_CONNECTION',
        message: null,
      );
      return;
    }

    _logVerbose('Enviando trip:accept tripId=$tripId');
    state = state.copyWith(
      processingOfferTripId: tripId,
      processingIsAccept: true,
    );
    _clearOfferErrorForTrip(tripId);
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
      );
      _setOfferErrorForTrip(
        tripId: tripId,
        code: 'NO_CONNECTION',
        message: null,
      );
      return;
    }

    _logVerbose('Enviando trip:reject tripId=$tripId');
    final updatedOffers = state.pendingOffers
        .where((offer) => offer.tripId != tripId)
        .toList();
    state = state.copyWith(
      pendingOffers: updatedOffers,
      processingOfferTripId: null,
      processingIsAccept: false,
    );
    _clearOfferErrorForTrip(tripId);
    _socket!.emit('trip:reject', {
      'tripId': tripId,
    });
  }

  double? _parseOfferDouble(String? s) {
    if (s == null || s.isEmpty) return null;
    return double.tryParse(s);
  }

  DriverTripOffer _tripOfferFromFcmPayload(Map<String, String> data) {
    final tripId = data['tripId']?.trim() ?? '';
    return DriverTripOffer(
      tripId: tripId,
      offeredPrice: _parseOfferDouble(data['offeredPrice']),
      currencyCode: data['currencyCode'] ?? data['currency'],
      etaMinutes: _parseOfferDouble(data['etaMinutes']),
      etaToDestinationMinutes: _parseOfferDouble(data['etaToDestinationMinutes']),
      distanceToPickupKm: _parseOfferDouble(data['distanceToPickupKm']),
      passengerName: (data['passengerName']?.trim().isNotEmpty == true)
          ? data['passengerName']!.trim()
          : null,
      passengerRating: _parseOfferDouble(data['passengerRating']),
      originAddress: data['originAddress']?.trim().isNotEmpty == true
          ? data['originAddress']
          : null,
      destinationAddress: data['destinationAddress']?.trim().isNotEmpty == true
          ? data['destinationAddress']
          : null,
      tripDistanceKm: _parseOfferDouble(data['tripDistanceKm']),
    );
  }

  /// Abrir desde notificación FCM de oferta: fusiona la oferta e intenta [setOnline].
  /// `false` = no se aplicó (offline explícito, disposed o payload inválido).
  Future<bool> onNotificationOpenedWithTripOffer(Map<String, String> data) async {
    if (_disposed) return false;
    // Offline explícito o sin sesión de disponibilidad: no reinyectar ofertas ni reconectar.
    if (_userRequestedOffline || !_availabilitySessionDesired) {
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
    state = state.copyWith(
      pendingOffers: list,
    );
    _clearOfferErrorForTrip(tripId);
    unawaited(_syncDriverForegroundSession());

    await setOnline(true);
    touchReconnectIfWantedOnline();
    return true;
  }

  /// Reaplica la notificación persistente (p. ej. al volver a primer plano).
  void resyncForegroundService() {
    unawaited(_syncDriverForegroundSession());
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelTripReconnectLoop();
    _cancelAvailabilityReconnectLoop();
    _cancelPresenceHeartbeat();
    // Evita callbacks tardíos que intenten reconectar; el estado UI se descarta con el notifier.
    _userRequestedOffline = true;
    _availabilitySessionDesired = false;
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
  final String? currencyCode;
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
    this.currencyCode,
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
  final String? currencyCode;
  final String? originAddress;
  final String? destinationAddress;
  final double? tripDistanceKm;
  final double? etaToDestinationMinutes;
  /// Polyline codificada (misma referencia que el mapa del pasajero: pickup → destino).
  final String? routeOverviewEncoded;

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
    this.currencyCode,
    this.originAddress,
    this.destinationAddress,
    this.tripDistanceKm,
    this.etaToDestinationMinutes,
    this.routeOverviewEncoded,
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
    String? currencyCode,
    String? originAddress,
    String? destinationAddress,
    double? tripDistanceKm,
    double? etaToDestinationMinutes,
    String? routeOverviewEncoded,
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
      currencyCode: currencyCode ?? this.currencyCode,
      originAddress: originAddress ?? this.originAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      tripDistanceKm: tripDistanceKm ?? this.tripDistanceKm,
      etaToDestinationMinutes: etaToDestinationMinutes ?? this.etaToDestinationMinutes,
      routeOverviewEncoded: routeOverviewEncoded ?? this.routeOverviewEncoded,
    );
  }
}

class DriverRatingFeedbackItem {
  final String code;
  final String label;
  final int minStars;
  final int maxStars;

  const DriverRatingFeedbackItem({
    required this.code,
    required this.label,
    required this.minStars,
    required this.maxStars,
  });

  factory DriverRatingFeedbackItem.fromJson(Map<String, dynamic> json) {
    final minRaw = json['minStars'];
    final maxRaw = json['maxStars'];
    return DriverRatingFeedbackItem(
      code: json['code']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      minStars: minRaw is num ? minRaw.toInt() : int.tryParse('$minRaw') ?? 1,
      maxStars: maxRaw is num ? maxRaw.toInt() : int.tryParse('$maxRaw') ?? 5,
    );
  }
}

