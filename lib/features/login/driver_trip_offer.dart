import 'dart:convert';

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

  /// `cash` | `qr`. Ausente = efectivo.
  final String paymentMethod;

  /// Preferencias informativas. Ausente = ninguno.
  final List<String> tripExtras;

  /// Requerimientos especiales (con recargo). Ausente = ninguno.
  final List<String> tripSpecials;

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
    this.paymentMethod = 'cash',
    this.tripExtras = const [],
    this.tripSpecials = const [],
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
    paymentMethod: normalizeDriverTripPaymentMethod(
      data['paymentMethod'] ?? data['payment_method'],
    ),
    tripExtras: parseDriverTripExtras(
      data['tripExtras'] ?? data['passenger_extras'] ?? data['extras'],
    ),
    tripSpecials: parseDriverTripSpecials(
      data['tripSpecials'] ?? data['passenger_specials'] ?? data['specials'],
    ),
  );
}

String normalizeDriverTripPaymentMethod(dynamic raw) {
  final v = raw?.toString().trim().toLowerCase() ?? '';
  return v == 'qr' ? 'qr' : 'cash';
}

String normalizeDriverTripExtraCode(dynamic raw) {
  final v = raw?.toString().trim().toLowerCase().replaceAll('-', '_') ?? '';
  if (v == 'childseat') return 'child_seat';
  if (v == 'over4' || v == 'extra_passengers') return 'over_4';
  if (v == 'pets') return 'pet';
  if (v == 'bags' || v == 'maletas') return 'luggage';
  if (v == 'air_conditioning') return 'ac';
  const allowed = {
    'pet',
    'child_seat',
    'wheelchair',
    'over_4',
    'luggage',
    'ac',
  };
  return allowed.contains(v) ? v : '';
}

String normalizeDriverTripSpecialCode(dynamic raw) {
  final v = raw?.toString().trim().toLowerCase().replaceAll('-', '_') ?? '';
  if (v == 'seats6' || v == 'six_seats') return 'seats_6';
  if (v == 'roofrack' || v == 'parrilla') return 'roof_rack';
  if (v == 'merchandise') return 'cargo';
  const allowed = {'seats_6', 'roof_rack', 'cargo'};
  return allowed.contains(v) ? v : '';
}

/// Parsea `tripExtras` desde socket (lista) o FCM (JSON string). Ausente = [].
List<String> parseDriverTripExtras(dynamic raw) {
  return _parseDriverAddonList(raw, normalizeDriverTripExtraCode);
}

/// Parsea `tripSpecials` desde socket (lista) o FCM (JSON string). Ausente = [].
List<String> parseDriverTripSpecials(dynamic raw) {
  return _parseDriverAddonList(raw, normalizeDriverTripSpecialCode);
}

List<String> _parseDriverAddonList(
  dynamic raw,
  String Function(dynamic) normalize,
) {
  if (raw == null) return const [];
  dynamic value = raw;
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return const [];
    if (trimmed.startsWith('[')) {
      try {
        value = jsonDecode(trimmed);
      } catch (_) {
        return const [];
      }
    } else {
      final mapped = normalize(trimmed);
      return mapped.isEmpty ? const [] : [mapped];
    }
  }
  if (value is! List) return const [];
  final out = <String>[];
  for (final item in value) {
    final mapped = normalize(item);
    if (mapped.isNotEmpty && !out.contains(mapped)) out.add(mapped);
  }
  return out;
}
