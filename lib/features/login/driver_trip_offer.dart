/// Origen de la oferta (`trip:offer` / FCM). Aditivo; ausente = flujo app pasajero.
abstract final class DriverTripOfferSource {
  static const String adminWebDispatch = 'admin_web_dispatch';
  static const String passengerApp = 'passenger_app';

  static bool isAdminWebDispatch(String? requestSource) {
    return requestSource == adminWebDispatch;
  }
}

double? _parseOfferDouble(dynamic raw) {
  if (raw == null) return null;
  if (raw is num) return raw.toDouble();
  if (raw is String && raw.isNotEmpty) return double.tryParse(raw);
  return null;
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Modelo de la oferta de viaje (trip:offer) recibida por el conductor.
class DriverTripOffer {
  final String tripId;
  final double? offeredPrice;
  final double? etaMinutes;
  final double? etaToDestinationMinutes;
  final double? distanceToPickupKm;
  final String? passengerName;
  final double? passengerRating;
  final String? currencyCode;
  final String? originAddress;
  final String? destinationAddress;
  final double? tripDistanceKm;

  /// `admin_web_dispatch` | `passenger_app` (u omitido).
  final String? requestSource;

  /// `targeted_driver` | `broadcast_match`.
  final String? dispatchMode;

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
    this.requestSource,
    this.dispatchMode,
  });

  bool get isAdminWebDispatch =>
      DriverTripOfferSource.isAdminWebDispatch(requestSource);
}

/// Construye [DriverTripOffer] desde payload socket o FCM (camelCase backend).
DriverTripOffer driverTripOfferFromMap(Map<dynamic, dynamic> data) {
  final tripId = data['tripId']?.toString().trim() ?? '';
  final passengerNameRaw = data['passengerName']?.toString().trim();
  return DriverTripOffer(
    tripId: tripId,
    offeredPrice: _parseOfferDouble(data['offeredPrice']),
    currencyCode: (data['currencyCode'] ?? data['currency'])?.toString(),
    etaMinutes: _parseOfferDouble(data['etaMinutes']),
    etaToDestinationMinutes: _parseOfferDouble(data['etaToDestinationMinutes']),
    distanceToPickupKm: _parseOfferDouble(data['distanceToPickupKm']),
    passengerName:
        passengerNameRaw != null && passengerNameRaw.isNotEmpty
            ? passengerNameRaw
            : null,
    passengerRating: _asDouble(data['passengerRating']),
    originAddress: data['originAddress']?.toString().trim().isNotEmpty == true
        ? data['originAddress']?.toString()
        : null,
    destinationAddress:
        data['destinationAddress']?.toString().trim().isNotEmpty == true
            ? data['destinationAddress']?.toString()
            : null,
    tripDistanceKm: _parseOfferDouble(data['tripDistanceKm']),
    requestSource: data['requestSource']?.toString(),
    dispatchMode: data['dispatchMode']?.toString(),
  );
}
