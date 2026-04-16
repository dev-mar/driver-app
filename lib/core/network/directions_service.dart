import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../config/driver_app_config.dart';
import 'request_policy_cache.dart';

enum RouteReferenceType { toll, trafficSignal, landmark }

class RouteReferencePoint {
  const RouteReferencePoint({
    required this.position,
    required this.type,
    required this.title,
    required this.confidence,
    this.snippet,
  });

  final LatLng position;
  final RouteReferenceType type;
  final String title;
  final double confidence;
  final String? snippet;
}

class RouteSnapshot {
  const RouteSnapshot({
    required this.polyline,
    required this.references,
  });

  final List<LatLng> polyline;
  final List<RouteReferencePoint> references;
}

List<LatLng> decodePolyline(String encoded) {
  final list = <LatLng>[];
  int index = 0;
  int lat = 0;
  int lng = 0;

  while (index < encoded.length) {
    int b;
    int shift = 0;
    int result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lng += dlng;

    list.add(LatLng(lat / 1e5, lng / 1e5));
  }
  return list;
}

class DirectionsService {
  DirectionsService() : _dio = Dio();

  final Dio _dio;
  static const _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';
  static final RequestPolicyCache<RouteSnapshot?> _cache =
      RequestPolicyCache<RouteSnapshot?>(
        defaultTtl: const Duration(seconds: 20),
      );
  static bool _missingKeyLogged = false;

  Future<List<LatLng>?> getRoutePoints({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    final snapshot = await getRouteSnapshot(
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
    );
    return snapshot?.polyline;
  }

  Future<RouteSnapshot?> getRouteSnapshot({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    final key =
        'd:${originLat.toStringAsFixed(4)},${originLng.toStringAsFixed(4)}'
        '>${destinationLat.toStringAsFixed(4)},${destinationLng.toStringAsFixed(4)}';
    return _cache.run(
      key: key,
      fetcher: () async {
        final apiKey = DriverAppConfig.googleMapsApiKeyOrNull;
        if (apiKey == null || apiKey.isEmpty) {
          if (!_missingKeyLogged) {
            debugPrint(
              '[Directions] GOOGLE_MAPS_API_KEY no configurada. '
              'Se omite consulta remota y se usa fallback local.',
            );
            _missingKeyLogged = true;
          }
          return null;
        }
        final origin = '$originLat,$originLng';
        final destination = '$destinationLat,$destinationLng';
        final url =
            '$_baseUrl?origin=$origin&destination=$destination&mode=driving&key=$apiKey';
        try {
          final response = await _dio.get<Map<String, dynamic>>(url);
          final data = response.data;
          if (data == null) {
            debugPrint('[Directions] Respuesta vacía desde Directions API.');
            return null;
          }
          final status = data['status'] as String?;
          if (status != 'OK') {
            debugPrint(
              '[Directions] Error status=$status, data=${data['error_message'] ?? ''}',
            );
            return null;
          }
          final routes = data['routes'] as List<dynamic>?;
          if (routes == null || routes.isEmpty) return null;
          final route = routes.first as Map<String, dynamic>;
          final overview = route['overview_polyline'] as Map<String, dynamic>?;
          final encoded = overview?['points'] as String?;
          if (encoded == null || encoded.isEmpty) return null;
          final points = decodePolyline(encoded);
          final references = _extractReferencePoints(route);
          return RouteSnapshot(polyline: points, references: references);
        } catch (e) {
          debugPrint('[Directions] Excepción al llamar a Directions API: $e');
          return null;
        }
      },
    );
  }

  List<RouteReferencePoint> _extractReferencePoints(Map<String, dynamic> route) {
    final references = <RouteReferencePoint>[];
    final legs = route['legs'] as List<dynamic>? ?? const [];
    for (final legItem in legs) {
      if (legItem is! Map<String, dynamic>) continue;
      final steps = legItem['steps'] as List<dynamic>? ?? const [];
      for (final stepItem in steps) {
        if (stepItem is! Map<String, dynamic>) continue;
        final startLocation =
            stepItem['start_location'] as Map<String, dynamic>? ?? const {};
        final lat = (startLocation['lat'] as num?)?.toDouble();
        final lng = (startLocation['lng'] as num?)?.toDouble();
        if (lat == null || lng == null) continue;

        final htmlInstructions =
            (stepItem['html_instructions'] as String? ?? '').toLowerCase();
        final maneuver = (stepItem['maneuver'] as String? ?? '').toLowerCase();

        if (_containsTollSignals(htmlInstructions)) {
          references.add(
            RouteReferencePoint(
              position: LatLng(lat, lng),
              type: RouteReferenceType.toll,
              title: 'Peaje en ruta',
              confidence: 0.95,
              snippet: 'Ajusta velocidad y carril con antelacion.',
            ),
          );
          continue;
        }

        if (_containsTrafficSignalSignals(htmlInstructions, maneuver)) {
          references.add(
            RouteReferencePoint(
              position: LatLng(lat, lng),
              type: RouteReferenceType.trafficSignal,
              title: 'Interseccion relevante',
              confidence: _trafficSignalConfidence(
                htmlInstructions: htmlInstructions,
                maneuver: maneuver,
              ),
              snippet: 'Mantente atento a semaforos y prioridad.',
            ),
          );
        }
      }
    }
    return references;
  }

  bool _containsTollSignals(String text) {
    return text.contains('toll') ||
        text.contains('peaje') ||
        text.contains('cuota');
  }

  bool _containsTrafficSignalSignals(String text, String maneuver) {
    return text.contains('traffic light') ||
        text.contains('semaforo') ||
        text.contains('intersection') ||
        maneuver.contains('roundabout');
  }

  double _trafficSignalConfidence({
    required String htmlInstructions,
    required String maneuver,
  }) {
    if (htmlInstructions.contains('traffic light') ||
        htmlInstructions.contains('semaforo')) {
      return 0.9;
    }
    if (maneuver.contains('roundabout')) {
      return 0.82;
    }
    if (htmlInstructions.contains('intersection')) {
      return 0.75;
    }
    return 0.65;
  }
}
