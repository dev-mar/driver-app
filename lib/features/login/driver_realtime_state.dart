import 'driver_trip_offer.dart';

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

  /// Admin/política: no puede pasar a `available` desde la app para recibir ofertas.
  final bool goOnlineBlocked;

  /// Motivo opcional (mensaje servidor / connection:ack).
  final String? goOnlineBlockReason;
  final bool accountBlocked;
  final String? accountBlockReason;
  final bool insufficientCreditsToGoOnline;
  final double minCreditsToGoOnline;
  final double driverCreditsBalance;

  /// `null` hasta el primer `connection:ack` con perfil; `false` si el servidor indica sin vehículo.
  final bool? hasVehicleRegistered;

  /// Política país: gate de saldo mínimo para online (solo aplica prealerta cuando es true).
  final bool creditsOnlineGateEnabled;

  /// Valor interno para [copyWith] y poder asignar `null` en campos opcionales.
  static const Object copyWithUnset = Object();

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
    this.goOnlineBlocked = false,
    this.goOnlineBlockReason,
    this.accountBlocked = false,
    this.accountBlockReason,
    this.insufficientCreditsToGoOnline = false,
    this.minCreditsToGoOnline = 0,
    this.driverCreditsBalance = 0,
    this.hasVehicleRegistered,
    this.creditsOnlineGateEnabled = false,
  });

  DriverRealtimeState copyWith({
    bool? online,
    bool? connecting,
    bool? availabilityDesired,
    String? errorCode,
    List<DriverTripOffer>? pendingOffers,
    Object? processingOfferTripId = copyWithUnset,
    bool? processingIsAccept,
    Map<String, String>? offersErrorCodeByTripId,
    Map<String, String>? offersErrorMessageByTripId,
    Object? activeTrip = copyWithUnset,
    Object? tripPendingRating = copyWithUnset,
    Object? ignoreActiveTripRestoreTripId = copyWithUnset,
    Object? ignoreActiveTripRestoreUntilMs = copyWithUnset,
    Object? lastCompletedTripId = copyWithUnset,
    Object? processingTripAction = copyWithUnset,
    String? tripErrorMessage,
    String? tripErrorCode,
    Object? arrivalReminderCooldownUntilMs = copyWithUnset,
    String? arrivalReminderErrorCode,
    Object? driverLat = copyWithUnset,
    Object? driverLng = copyWithUnset,
    Object? driverBearing = copyWithUnset,
    Object? driverDisplayName = copyWithUnset,
    Object? driverVehicleLabel = copyWithUnset,
    Object? driverRating = copyWithUnset,
    Object? driverPictureProfile = copyWithUnset,
    Object? driverPictureExpiresAt = copyWithUnset,
    List<DriverTripChatMessage>? chatMessages,
    String? tripChatErrorCode,
    bool? goOnlineBlocked,
    Object? goOnlineBlockReason = copyWithUnset,
    bool? accountBlocked,
    Object? accountBlockReason = copyWithUnset,
    bool? insufficientCreditsToGoOnline,
    double? minCreditsToGoOnline,
    double? driverCreditsBalance,
    Object? hasVehicleRegistered = copyWithUnset,
    bool? creditsOnlineGateEnabled,
  }) {
    return DriverRealtimeState(
      online: online ?? this.online,
      connecting: connecting ?? this.connecting,
      availabilityDesired: availabilityDesired ?? this.availabilityDesired,
      errorCode: errorCode,
      pendingOffers: pendingOffers ?? this.pendingOffers,
      processingOfferTripId: identical(processingOfferTripId, copyWithUnset)
          ? this.processingOfferTripId
          : processingOfferTripId as String?,
      processingIsAccept: processingIsAccept ?? this.processingIsAccept,
      offersErrorCodeByTripId:
          offersErrorCodeByTripId ?? this.offersErrorCodeByTripId,
      offersErrorMessageByTripId:
          offersErrorMessageByTripId ?? this.offersErrorMessageByTripId,
      activeTrip: identical(activeTrip, copyWithUnset)
          ? this.activeTrip
          : activeTrip as DriverActiveTrip?,
      tripPendingRating: identical(tripPendingRating, copyWithUnset)
          ? this.tripPendingRating
          : tripPendingRating as DriverActiveTrip?,
      ignoreActiveTripRestoreTripId:
          identical(ignoreActiveTripRestoreTripId, copyWithUnset)
          ? this.ignoreActiveTripRestoreTripId
          : ignoreActiveTripRestoreTripId as String?,
      ignoreActiveTripRestoreUntilMs:
          identical(ignoreActiveTripRestoreUntilMs, copyWithUnset)
          ? this.ignoreActiveTripRestoreUntilMs
          : ignoreActiveTripRestoreUntilMs as int?,
      lastCompletedTripId: identical(lastCompletedTripId, copyWithUnset)
          ? this.lastCompletedTripId
          : lastCompletedTripId as String?,
      processingTripAction: identical(processingTripAction, copyWithUnset)
          ? this.processingTripAction
          : processingTripAction as String?,
      tripErrorMessage: tripErrorMessage,
      tripErrorCode: tripErrorCode,
      arrivalReminderCooldownUntilMs:
          identical(arrivalReminderCooldownUntilMs, copyWithUnset)
          ? this.arrivalReminderCooldownUntilMs
          : arrivalReminderCooldownUntilMs as int?,
      arrivalReminderErrorCode: arrivalReminderErrorCode,
      driverLat: identical(driverLat, copyWithUnset)
          ? this.driverLat
          : driverLat as double?,
      driverLng: identical(driverLng, copyWithUnset)
          ? this.driverLng
          : driverLng as double?,
      driverBearing: identical(driverBearing, copyWithUnset)
          ? this.driverBearing
          : driverBearing as double?,
      driverDisplayName: identical(driverDisplayName, copyWithUnset)
          ? this.driverDisplayName
          : driverDisplayName as String?,
      driverVehicleLabel: identical(driverVehicleLabel, copyWithUnset)
          ? this.driverVehicleLabel
          : driverVehicleLabel as String?,
      driverRating: identical(driverRating, copyWithUnset)
          ? this.driverRating
          : driverRating as double?,
      driverPictureProfile: identical(driverPictureProfile, copyWithUnset)
          ? this.driverPictureProfile
          : driverPictureProfile as String?,
      driverPictureExpiresAt: identical(driverPictureExpiresAt, copyWithUnset)
          ? this.driverPictureExpiresAt
          : driverPictureExpiresAt as DateTime?,
      chatMessages: chatMessages ?? this.chatMessages,
      tripChatErrorCode: tripChatErrorCode,
      goOnlineBlocked: goOnlineBlocked ?? this.goOnlineBlocked,
      goOnlineBlockReason: identical(goOnlineBlockReason, copyWithUnset)
          ? this.goOnlineBlockReason
          : goOnlineBlockReason as String?,
      accountBlocked: accountBlocked ?? this.accountBlocked,
      accountBlockReason: identical(accountBlockReason, copyWithUnset)
          ? this.accountBlockReason
          : accountBlockReason as String?,
      insufficientCreditsToGoOnline:
          insufficientCreditsToGoOnline ?? this.insufficientCreditsToGoOnline,
      minCreditsToGoOnline: minCreditsToGoOnline ?? this.minCreditsToGoOnline,
      driverCreditsBalance: driverCreditsBalance ?? this.driverCreditsBalance,
      hasVehicleRegistered: identical(hasVehicleRegistered, copyWithUnset)
          ? this.hasVehicleRegistered
          : hasVehicleRegistered as bool?,
      creditsOnlineGateEnabled:
          creditsOnlineGateEnabled ?? this.creditsOnlineGateEnabled,
    );
  }

  static const initial = DriverRealtimeState(
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
    goOnlineBlocked: false,
    goOnlineBlockReason: null,
    accountBlocked: false,
    accountBlockReason: null,
    insufficientCreditsToGoOnline: false,
    minCreditsToGoOnline: 0,
    driverCreditsBalance: 0,
    hasVehicleRegistered: null,
    creditsOnlineGateEnabled: false,
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
  /// Banda por encima del mínimo: avisar antes de que el saldo cruce el umbral y el servidor pase a offline.
  static const double creditsLowWarningRatio = 1.25;

  bool get showDriverCreditsLowWarning {
    if (hasVehicleRegistered == false) return false;
    if (creditsOnlineGateEnabled != true) return false;
    if (insufficientCreditsToGoOnline) return false;
    final min = minCreditsToGoOnline;
    if (min <= 0) return false;
    final bal = driverCreditsBalance;
    if (bal <= min) return false;
    return bal <= min * creditsLowWarningRatio;
  }

  bool get availabilitySwitchVisualOn {
    if ((hasVehicleRegistered == false ||
            errorCode == 'DRIVER_VEHICLE_REQUIRED' ||
            goOnlineBlocked ||
            errorCode == 'DRIVER_GO_ONLINE_BLOCKED' ||
            accountBlocked ||
            errorCode == 'DRIVER_ACCOUNT_BLOCKED' ||
            insufficientCreditsToGoOnline ||
            errorCode == 'DRIVER_CREDITS_BELOW_MIN') &&
        activeTrip == null &&
        tripPendingRating == null) {
      return false;
    }
    if (online) return true;
    if (connecting) return true;
    if (activeTrip != null || tripPendingRating != null) return true;
    return availabilityDesired;
  }
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

  /// `cash` | `qr`. Ausente = efectivo.
  final String paymentMethod;

  /// Códigos informativos. Ausente = ninguno.
  final List<String> tripExtras;

  /// Requerimientos especiales. Ausente = ninguno.
  final List<String> tripSpecials;

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
    this.paymentMethod = 'cash',
    this.tripExtras = const [],
    this.tripSpecials = const [],
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
    String? paymentMethod,
    List<String>? tripExtras,
    List<String>? tripSpecials,
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
      etaToDestinationMinutes:
          etaToDestinationMinutes ?? this.etaToDestinationMinutes,
      routeOverviewEncoded: routeOverviewEncoded ?? this.routeOverviewEncoded,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      tripExtras: tripExtras ?? this.tripExtras,
      tripSpecials: tripSpecials ?? this.tripSpecials,
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
