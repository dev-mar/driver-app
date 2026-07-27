/// Utilidades de parseo compartidas entre socket bindings y controller.
(double?, double?) parseDriverLatLng(
  dynamic map,
  String latKey,
  String lngKey,
) {
  if (map is! Map) return (null, null);
  final lat = map[latKey];
  final lng = map[lngKey];
  if (lat is num && lng is num) return (lat.toDouble(), lng.toDouble());
  return (null, null);
}

(double?, double?) parseDriverLatLngFromMap(dynamic object) {
  if (object is! Map) return (null, null);
  final m = Map<String, dynamic>.from(object);
  final lat = m['lat'] ?? m['latitude'];
  final lng = m['lng'] ?? m['longitude'];
  if (lat is num && lng is num) return (lat.toDouble(), lng.toDouble());
  return (null, null);
}

double? parseDriverDouble(dynamic raw) {
  if (raw is num) return raw.toDouble();
  if (raw is String) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    return double.tryParse(value);
  }
  return null;
}

String socketConnectErrorToCode(dynamic data) {
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

String? extractTripIdFromPayload(Map<dynamic, dynamic> data) {
  const directKeys = <String>[
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
    final raw =
        nestedTrip['tripId']?.toString().trim() ??
        nestedTrip['id']?.toString().trim();
    if (raw != null && raw.isNotEmpty) {
      return raw;
    }
  }
  return null;
}

bool parseDriverBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final s = value.trim().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
  }
  return false;
}
