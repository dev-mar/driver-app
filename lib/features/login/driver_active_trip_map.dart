import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/session/driver_map_preferences_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_foundation.dart';
import '../../core/network/directions_service.dart';
import '../../gen_l10n/app_localizations.dart';
import 'driver_trip_marker.dart';
import 'driver_realtime_controller.dart';

/// Vista tipo InDriver/Lyft: mapa a pantalla completa con conductor, origen, destino y ruta.
/// Se muestra cuando hay [activeTrip]; el [bottomCard] es la tarjeta de acciones.
class DriverActiveTripMapView extends StatefulWidget {
  const DriverActiveTripMapView({
    super.key,
    required this.driverLat,
    required this.driverLng,
    this.driverBearing,
    required this.trip,
    required this.bottomCard,
  });

  final double? driverLat;
  final double? driverLng;
  final double? driverBearing;
  final DriverActiveTrip trip;
  final Widget bottomCard;

  @override
  State<DriverActiveTripMapView> createState() =>
      _DriverActiveTripMapViewState();
}

class _DriverActiveTripMapViewState extends State<DriverActiveTripMapView> {
  static const bool _routeDebugEnabled = false;
  final DirectionsService _directions = DirectionsService();
  GoogleMapController? _mapController;
  LatLng? _deviceSeedLatLng;
  StreamSubscription<Position>? _routingPositionSub;
  bool _mapReady = false;
  bool _followNavigationCamera = true;
  Timer? _routeFetchDebounce;
  String? _lastRouteSignature;
  DateTime? _lastFitAt;
  bool _showFollowHint = true;
  bool _lightweightMapMode = true;
  bool _showTollReferences = false;
  bool _showSignalReferences = false;
  double _referenceConfidenceThreshold = 0.85;
  Timer? _prefsPersistDebounce;
  String _prefsNamespace = 'global';

  List<LatLng>? _routeToPickup;
  List<LatLng>? _routePickupToDest;
  List<RouteReferencePoint> _routeReferences = const [];
  BitmapDescriptor? _pickupOnTripIcon;
  BitmapDescriptor? _destinationOnTripIcon;
  BitmapDescriptor? _tollReferenceIcon;
  BitmapDescriptor? _signalReferenceIcon;
  BitmapDescriptor? _landmarkReferenceIcon;

  /// Alineado con el mapa nocturno del pasajero durante el viaje.
  static const String _nightMapStyle = '''
[
  { "elementType": "geometry", "stylers": [{ "color": "#111111" }] },
  { "elementType": "labels.text.fill", "stylers": [{ "color": "#8A8A8A" }] },
  { "elementType": "labels.text.stroke", "stylers": [{ "color": "#111111" }] },
  { "featureType": "poi", "stylers": [{ "visibility": "off" }] },
  { "featureType": "transit", "stylers": [{ "visibility": "off" }] },
  { "featureType": "administrative.land_parcel", "stylers": [{ "visibility": "off" }] },
  { "featureType": "road", "elementType": "labels.icon", "stylers": [{ "visibility": "off" }] },
  { "featureType": "road", "elementType": "geometry", "stylers": [{ "color": "#232323" }] },
  { "featureType": "water", "elementType": "geometry", "stylers": [{ "color": "#0C1B2A" }] }
]
''';

  static const List<double> _referenceConfidenceLevels = [0.75, 0.85, 0.92];
  static const String _prefMapModeLightweight = 'driver.map.lightweight_mode';
  static const String _prefShowTolls = 'driver.map.show_toll_refs';
  static const String _prefShowSignals = 'driver.map.show_signal_refs';
  static const String _prefReferenceConfidence =
      'driver.map.reference_confidence';
  static const int _maxVisibleReferenceMarkers = 20;

  LatLng? get _driverLatLng {
    if (widget.driverLat != null && widget.driverLng != null) {
      return LatLng(widget.driverLat!, widget.driverLng!);
    }
    return null;
  }

  LatLng? get _pickupLatLng {
    final t = widget.trip;
    if (t.pickupLat != null && t.pickupLng != null) {
      return LatLng(t.pickupLat!, t.pickupLng!);
    }
    return null;
  }

  LatLng? get _destinationLatLng {
    final t = widget.trip;
    if (t.destinationLat != null && t.destinationLng != null) {
      return LatLng(t.destinationLat!, t.destinationLng!);
    }
    return null;
  }

  /// GPS del stream del realtime puede ir unos instantes detrás del punto azul del mapa;
  /// para Directions usamos semilla del dispositivo como respaldo y no dejamos de dibujar la polyline.
  LatLng? get _effectiveDriverForRouting => _driverLatLng ?? _deviceSeedLatLng;

  @override
  void didUpdateWidget(DriverActiveTripMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final movedEnough = _positionMovedEnough(
      oldWidget.driverLat,
      oldWidget.driverLng,
      widget.driverLat,
      widget.driverLng,
    );
    if (movedEnough ||
        oldWidget.trip.status != widget.trip.status ||
        oldWidget.trip.tripId != widget.trip.tripId ||
        oldWidget.trip.pickupLat != widget.trip.pickupLat ||
        oldWidget.trip.pickupLng != widget.trip.pickupLng ||
        oldWidget.trip.destinationLat != widget.trip.destinationLat ||
        oldWidget.trip.destinationLng != widget.trip.destinationLng ||
        oldWidget.trip.routeOverviewEncoded !=
            widget.trip.routeOverviewEncoded) {
      _scheduleRouteRefresh();
    } else if (oldWidget.driverBearing != widget.driverBearing &&
        _mapReady &&
        _mapController != null) {
      // Solo rotación/ubicación fina: no recalcular rutas, solo reajuste suave ocasional.
      _fitBounds(smoothOnly: true);
    }
  }

  @override
  void initState() {
    super.initState();
    _bootstrapMapPreferences();
    _loadTripMarkerIcons();
    _resolveDeviceSeedLocation();
    // El punto azul del mapa no expone coordenadas al widget; sin esto a veces no hay
    // ancla para Directions hasta que el padre inyecte driverLat/Lng.
    _routingPositionSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 12,
          ),
        ).listen(
          (pos) {
            if (!mounted) return;
            setState(() {
              _deviceSeedLatLng = LatLng(pos.latitude, pos.longitude);
            });
            _scheduleRouteRefresh();
          },
          onError: (Object e) {
            if (kDebugMode) {
              debugPrint('[DriverActiveTripMap] routing position stream: $e');
            }
          },
        );
    _scheduleRouteRefresh(immediate: true);
    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _showFollowHint = false);
    });
  }

  @override
  void dispose() {
    _routingPositionSub?.cancel();
    _routeFetchDebounce?.cancel();
    _prefsPersistDebounce?.cancel();
    super.dispose();
  }

  bool _positionMovedEnough(
    double? oldLat,
    double? oldLng,
    double? newLat,
    double? newLng,
  ) {
    if (oldLat == null || oldLng == null || newLat == null || newLng == null) {
      return oldLat != newLat || oldLng != newLng;
    }
    const minDelta = 0.00018; // ~20m
    final dLat = (newLat - oldLat).abs();
    final dLng = (newLng - oldLng).abs();
    return dLat > minDelta || dLng > minDelta;
  }

  void _scheduleRouteRefresh({bool immediate = false}) {
    _routeFetchDebounce?.cancel();
    if (immediate) {
      _fetchRoutesAndFit();
      return;
    }
    _routeFetchDebounce = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      _fetchRoutesAndFit();
    });
  }

  Future<void> _restoreMapPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _lightweightMapMode = true;
        // Temporalmente oculto por versión: indicadores no visibles y desactivados.
        _showTollReferences = false;
        _showSignalReferences = false;
        final confidence =
            prefs.getDouble(_prefsKey(_prefReferenceConfidence)) ??
            _referenceConfidenceThreshold;
        _referenceConfidenceThreshold = _normalizeConfidence(confidence);
        _followNavigationCamera = true;
      });
    } catch (_) {
      // Si falla storage local, mantenemos defaults en memoria.
    }
  }

  Future<void> _persistMapPreferences({bool immediate = false}) async {
    _prefsPersistDebounce?.cancel();
    if (!immediate) {
      _prefsPersistDebounce = Timer(const Duration(milliseconds: 220), () {
        _persistMapPreferences(immediate: true);
      });
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        _prefsKey(_prefMapModeLightweight),
        _lightweightMapMode,
      );
      await prefs.setBool(_prefsKey(_prefShowTolls), _showTollReferences);
      await prefs.setBool(_prefsKey(_prefShowSignals), _showSignalReferences);
      await prefs.setDouble(
        _prefsKey(_prefReferenceConfidence),
        _referenceConfidenceThreshold,
      );
    } catch (_) {
      // Persistencia best-effort: no bloquea UX de navegación.
    }
  }

  Future<void> _bootstrapMapPreferences() async {
    await _resolvePreferencesNamespace();
    await _restoreMapPreferences();
  }

  String _prefsKey(String baseKey) =>
      DriverMapPreferencesStore.keyFor(baseKey, _prefsNamespace);

  Future<void> _resolvePreferencesNamespace() async {
    _prefsNamespace =
        await DriverMapPreferencesStore.resolveNamespaceFromCurrentSession();
  }

  double _normalizeConfidence(double value) {
    for (final allowed in _referenceConfidenceLevels) {
      if ((allowed - value).abs() < 0.01) return allowed;
    }
    return _referenceConfidenceLevels[1];
  }

  void _updateMapPreferences(VoidCallback updater) {
    if (!mounted) return;
    setState(updater);
    _persistMapPreferences();
  }

  Future<void> _resolveDeviceSeedLocation() async {
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && mounted) {
        setState(() {
          _deviceSeedLatLng = LatLng(last.latitude, last.longitude);
        });
        _scheduleRouteRefresh();
        if (_mapController != null && !_hasTripAnchors) {
          await _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _deviceSeedLatLng!, zoom: 15),
            ),
          );
        }
        return;
      }
      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(const Duration(seconds: 6));
      if (!mounted) return;
      setState(() {
        _deviceSeedLatLng = LatLng(current.latitude, current.longitude);
      });
      _scheduleRouteRefresh();
      if (_mapController != null && !_hasTripAnchors) {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _deviceSeedLatLng!, zoom: 15),
          ),
        );
      }
    } catch (_) {
      // Si falla GPS inicial, mantenemos fallback existente sin romper el mapa.
    }
  }

  bool get _hasTripAnchors =>
      _driverLatLng != null ||
      _pickupLatLng != null ||
      _destinationLatLng != null;

  String _coordLabel(LatLng? p) => p == null
      ? 'null'
      : '${p.latitude.toStringAsFixed(5)},${p.longitude.toStringAsFixed(5)}';

  void _routeDebug(String message) {
    if (!_routeDebugEnabled) return;
    debugPrint('[ROUTE_DEBUG] $message');
  }

  Future<RouteSnapshot?> _safeRouteSnapshot({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    required String tag,
  }) async {
    try {
      return await _directions
          .getRouteSnapshot(
            originLat: originLat,
            originLng: originLng,
            destinationLat: destinationLat,
            destinationLng: destinationLng,
          )
          .timeout(const Duration(seconds: 4), onTimeout: () => null);
    } catch (e) {
      _routeDebug('fetch:$tag error=$e');
      return null;
    }
  }

  Future<void> _loadTripMarkerIcons() async {
    try {
      final pickupIcon = await buildDriverWaypointMapPinIcon(
        logicalSize: 54,
        fill: const Color(0xFFFFC107),
      );
      final destinationIcon = await buildDriverWaypointMapPinIcon(
        logicalSize: 54,
        fill: const Color(0xFFE53935),
      );
      final tollIcon = await buildDriverRouteReferenceIcon(
        icon: Icons.toll_rounded,
        background: const Color(0xFF1976D2),
      );
      final signalIcon = await buildDriverRouteReferenceIcon(
        icon: Icons.traffic_rounded,
        background: const Color(0xFF00897B),
      );
      final landmarkIcon = await buildDriverRouteReferenceIcon(
        icon: Icons.place_rounded,
        background: const Color(0xFF5E35B1),
      );
      if (!mounted) return;
      setState(() {
        _pickupOnTripIcon = pickupIcon;
        _destinationOnTripIcon = destinationIcon;
        _tollReferenceIcon = tollIcon;
        _signalReferenceIcon = signalIcon;
        _landmarkReferenceIcon = landmarkIcon;
      });
    } catch (e) {
      _routeDebug('markers:icon-load error=$e');
    }
  }

  Future<void> _fetchRoutesAndFit() async {
    final driver = _effectiveDriverForRouting;
    final pickup = _pickupLatLng;
    final dest = _destinationLatLng;
    final status = widget.trip.status;
    final encoded = widget.trip.routeOverviewEncoded?.trim() ?? '';
    _routeDebug(
      'fetch:start tripId=${widget.trip.tripId} status=$status '
      'driver=${_coordLabel(driver)} pickup=${_coordLabel(pickup)} dest=${_coordLabel(dest)} '
      'encodedLen=${encoded.length} encodedHash=${encoded.hashCode}',
    );
    final signature = [
      widget.trip.tripId,
      status,
      widget.driverLat?.toStringAsFixed(5),
      widget.driverLng?.toStringAsFixed(5),
      _deviceSeedLatLng?.latitude.toStringAsFixed(5),
      _deviceSeedLatLng?.longitude.toStringAsFixed(5),
      driver?.latitude.toStringAsFixed(5),
      driver?.longitude.toStringAsFixed(5),
      pickup?.latitude.toStringAsFixed(5),
      pickup?.longitude.toStringAsFixed(5),
      dest?.latitude.toStringAsFixed(5),
      dest?.longitude.toStringAsFixed(5),
      encoded,
    ].join('|');

    if (_lastRouteSignature == signature) {
      _routeDebug('fetch:skip same-signature');
      _fitBounds(smoothOnly: true);
      return;
    }
    _lastRouteSignature = signature;

    List<LatLng>? toPickup;
    List<LatLng>? pickupToDest = _routePickupToDest;
    final references = <RouteReferencePoint>[];

    if (dest != null) {
      final originForDest = pickup ?? driver;
      if (encoded.isNotEmpty) {
        try {
          final decoded = decodePolyline(encoded);
          _routeDebug('fetch:encoded decode points=${decoded.length}');
          if (decoded.length >= 2) {
            pickupToDest = decoded;
          }
        } catch (e) {
          _routeDebug('fetch:encoded decode error=$e');
          // Polyline inválida: seguir con Directions como antes.
        }
      } else {
        _routeDebug('fetch:encoded missing -> fallback directions');
      }
      if (pickupToDest == null && originForDest != null) {
        final toDestinationSnapshot = await _safeRouteSnapshot(
          originLat: originForDest.latitude,
          originLng: originForDest.longitude,
          destinationLat: dest.latitude,
          destinationLng: dest.longitude,
          tag: 'origin->dest',
        );
        pickupToDest = toDestinationSnapshot?.polyline;
        _routeDebug(
          'fetch:origin->dest fallback points=${pickupToDest?.length ?? 0} '
          'refs=${toDestinationSnapshot?.references.length ?? 0}',
        );
        if (toDestinationSnapshot != null) {
          references.addAll(toDestinationSnapshot.references);
        }
      } else if (pickupToDest == null) {
        _routeDebug('fetch:origin->dest skipped missing originForDest');
      }
    } else {
      _routeDebug('fetch:dest missing');
    }

    if (pickup != null && driver != null) {
      final toPickupSnapshot = await _safeRouteSnapshot(
        originLat: driver.latitude,
        originLng: driver.longitude,
        destinationLat: pickup.latitude,
        destinationLng: pickup.longitude,
        tag: 'driver->pickup',
      );
      toPickup = toPickupSnapshot?.polyline;
      _routeDebug(
        'fetch:driver->pickup points=${toPickup?.length ?? 0} '
        'refs=${toPickupSnapshot?.references.length ?? 0}',
      );
      if (toPickupSnapshot != null) {
        references.addAll(toPickupSnapshot.references);
      }
      if (toPickup == null) {
        // Fallback resiliente cuando Directions no esta disponible (p.ej. key faltante).
        toPickup = <LatLng>[driver, pickup];
        _routeDebug('fetch:driver->pickup fallback straight-line points=2');
      }
    } else {
      _routeDebug(
        'fetch:driver->pickup skipped driver=${driver != null} pickup=${pickup != null}',
      );
    }

    if (!mounted) return;

    setState(() {
      _routeToPickup = toPickup;
      _routePickupToDest = pickupToDest;
      _routeReferences = _dedupeReferencePoints(references);
    });
    _routeDebug(
      'fetch:end routeToPickup=${_routeToPickup?.length ?? 0} '
      'routeToDest=${_routePickupToDest?.length ?? 0} refs=${_routeReferences.length}',
    );

    _fitBounds();
  }

  void _fitBounds({bool smoothOnly = false}) {
    final controller = _mapController;
    if (controller == null) return;
    if (!_followNavigationCamera) return;
    final status = widget.trip.status;
    final driver = _effectiveDriverForRouting;
    final pickup = _pickupLatLng;
    final dest = _destinationLatLng;

    // Modo navegación pro: prioriza conductor + objetivo inmediato.
    if ((status == 'accepted' || status == 'arrived') &&
        driver != null &&
        pickup != null) {
      _fitForNavigationFocus(
        controller: controller,
        from: driver,
        to: pickup,
        smoothOnly: smoothOnly,
      );
      return;
    }
    if ((status == 'started' || status == 'in_trip') &&
        driver != null &&
        dest != null) {
      _fitForNavigationFocus(
        controller: controller,
        from: driver,
        to: dest,
        smoothOnly: smoothOnly,
      );
      return;
    }

    final points = <LatLng>[];

    if (driver != null) points.add(driver);
    if (pickup != null) points.add(pickup);
    if (dest != null) points.add(dest);
    if (_routeToPickup != null) points.addAll(_routeToPickup!);
    if (_routePickupToDest != null) points.addAll(_routePickupToDest!);

    if (points.length < 2) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    final now = DateTime.now();
    if (_lastFitAt != null &&
        now.difference(_lastFitAt!) < const Duration(milliseconds: 700)) {
      return;
    }
    _lastFitAt = now;
    if (smoothOnly) {
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 64));
    } else {
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 72));
    }
  }

  void _fitForNavigationFocus({
    required GoogleMapController controller,
    required LatLng from,
    required LatLng to,
    required bool smoothOnly,
  }) {
    final now = DateTime.now();
    if (_lastFitAt != null &&
        now.difference(_lastFitAt!) < const Duration(milliseconds: 700)) {
      return;
    }
    _lastFitAt = now;

    final minLat = from.latitude < to.latitude ? from.latitude : to.latitude;
    final maxLat = from.latitude > to.latitude ? from.latitude : to.latitude;
    final minLng = from.longitude < to.longitude
        ? from.longitude
        : to.longitude;
    final maxLng = from.longitude > to.longitude
        ? from.longitude
        : to.longitude;

    final latSpan = (maxLat - minLat).abs();
    final lngSpan = (maxLng - minLng).abs();
    // Si ambos puntos están muy cerca, evita zoom extremo.
    if (latSpan < 0.00035 && lngSpan < 0.00035) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: from, zoom: smoothOnly ? 16.2 : 16.0),
        ),
      );
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, smoothOnly ? 86 : 92),
    );
  }

  CameraPosition _initialCameraPosition() {
    final driver = _driverLatLng;
    final pickup = _pickupLatLng;
    final dest = _destinationLatLng;

    if (driver != null) {
      return CameraPosition(target: driver, zoom: 15);
    }
    if (pickup != null) {
      return CameraPosition(target: pickup, zoom: 15);
    }
    if (dest != null) {
      return CameraPosition(target: dest, zoom: 15);
    }
    if (_deviceSeedLatLng != null) {
      return CameraPosition(target: _deviceSeedLatLng!, zoom: 15);
    }
    return const CameraPosition(target: LatLng(-12.0464, -77.0428), zoom: 12);
  }

  Set<Marker> _buildMarkers() {
    final l10n = AppLocalizations.of(context);
    final markers = <Marker>{};
    final pickup = _pickupLatLng;
    final dest = _destinationLatLng;

    if (pickup != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: pickup,
          icon:
              _pickupOnTripIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          zIndexInt: 20,
          infoWindow: InfoWindow(title: l10n.driverMapPickupPoint),
        ),
      );
    }
    if (dest != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: dest,
          icon:
              _destinationOnTripIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          zIndexInt: 10,
          infoWindow: InfoWindow(title: l10n.driverMapDestinationPoint),
        ),
      );
    }
    for (final ref in _visibleRouteReferences) {
      final icon = switch (ref.type) {
        RouteReferenceType.toll =>
          _tollReferenceIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        RouteReferenceType.trafficSignal =>
          _signalReferenceIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        RouteReferenceType.landmark =>
          _landmarkReferenceIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      };
      markers.add(
        Marker(
          markerId: MarkerId(
            'ref_${ref.type.name}_${ref.position.latitude.toStringAsFixed(5)}_${ref.position.longitude.toStringAsFixed(5)}',
          ),
          position: ref.position,
          icon: icon,
          alpha: 0.9,
          zIndexInt: 5,
          infoWindow: InfoWindow(title: ref.title, snippet: ref.snippet),
        ),
      );
    }
    return markers;
  }

  List<RouteReferencePoint> _dedupeReferencePoints(
    List<RouteReferencePoint> refs,
  ) {
    final map = <String, RouteReferencePoint>{};
    for (final item in refs) {
      final key =
          '${item.type.name}:${item.position.latitude.toStringAsFixed(4)}:${item.position.longitude.toStringAsFixed(4)}';
      final current = map[key];
      if (current == null || item.confidence > current.confidence) {
        map[key] = item;
      }
    }
    return map.values.toList(growable: false);
  }

  List<RouteReferencePoint> get _visibleRouteReferences {
    if (!_showTollReferences && !_showSignalReferences) {
      return const [];
    }
    final filtered = _routeReferences
        .where((ref) {
          if (ref.confidence < _referenceConfidenceThreshold) return false;
          if (ref.type == RouteReferenceType.toll) return _showTollReferences;
          if (ref.type == RouteReferenceType.trafficSignal) {
            return _showSignalReferences;
          }
          return true;
        })
        .toList(growable: false);
    filtered.sort((a, b) => b.confidence.compareTo(a.confidence));
    if (filtered.length <= _maxVisibleReferenceMarkers) return filtered;
    return filtered.sublist(0, _maxVisibleReferenceMarkers);
  }

  Set<Polyline> _buildPolylines() {
    final polylines = <Polyline>{};
    final routeToPickup =
        (_routeToPickup != null && _routeToPickup!.length >= 2)
        ? _routeToPickup!
        : null;
    final routeToDestination =
        (_routePickupToDest != null && _routePickupToDest!.length >= 2)
        ? _routePickupToDest!
        : null;

    if (routeToPickup != null && routeToPickup.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route_to_pickup'),
          points: routeToPickup,
          color: const Color(0xFFFFC966),
          width: 7,
          geodesic: true,
          zIndex: 2,
        ),
      );
    }

    if (routeToDestination != null && routeToDestination.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route_pickup_to_dest'),
          points: routeToDestination,
          color: const Color(0xFF7EB6FF),
          width: 7,
          geodesic: true,
          zIndex: 1,
        ),
      );
    }
    _routeDebug(
      'render:polylines count=${polylines.length} '
      'toPickup=${routeToPickup?.length ?? 0} toDest=${routeToDestination?.length ?? 0}',
    );
    return polylines;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _initialCameraPosition(),
          onMapCreated: (controller) {
            _mapController = controller;
            _mapReady = true;
            _fitBounds();
            if (!_hasTripAnchors && _deviceSeedLatLng != null) {
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: _deviceSeedLatLng!, zoom: 15),
                ),
              );
            }
            _scheduleRouteRefresh(immediate: true);
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          liteModeEnabled: false,
          markers: _buildMarkers(),
          polylines: _buildPolylines(),
          compassEnabled: false,
          buildingsEnabled: false,
          indoorViewEnabled: false,
          trafficEnabled: !_lightweightMapMode,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          style: _nightMapStyle,
        ),
        Positioned(
          top: 16,
          right: 16,
          child: SafeArea(
            bottom: false,
            child: Material(
              color: AppColors.surfaceCard.withValues(alpha: 0.94),
              shape: const CircleBorder(),
              elevation: 10,
              shadowColor: Colors.black.withValues(alpha: 0.28),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  HapticFeedback.selectionClick();
                  _updateMapPreferences(() {
                    _followNavigationCamera = !_followNavigationCamera;
                    _showFollowHint = true;
                  });
                  if (_followNavigationCamera) {
                    _fitBounds();
                  }
                  Future<void>.delayed(const Duration(seconds: 2), () {
                    if (!mounted) return;
                    setState(() => _showFollowHint = false);
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(11),
                  child: Icon(
                    _followNavigationCamera
                        ? Icons.gps_fixed_rounded
                        : Icons.gps_not_fixed_rounded,
                    size: 22,
                    color: _followNavigationCamera
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 66,
          child: SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _showFollowHint
                  ? _MapHintChip(
                      key: ValueKey<bool>(_followNavigationCamera),
                      icon: _followNavigationCamera
                          ? Icons.gps_fixed_rounded
                          : Icons.gps_not_fixed_rounded,
                      text: _followNavigationCamera
                          ? 'Seguimiento activo'
                          : 'Seguimiento desactivado',
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Material(
            elevation: 22,
            shadowColor: Colors.black.withValues(alpha: 0.35),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppFoundation.radiusXl),
            ),
            color: AppColors.surfaceCard.withValues(alpha: 0.98),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: widget.bottomCard,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapHintChip extends StatelessWidget {
  const _MapHintChip({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard.withValues(alpha: 0.92),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
