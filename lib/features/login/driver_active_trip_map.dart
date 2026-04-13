import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_foundation.dart';
import '../../core/network/directions_service.dart';
import '../../gen_l10n/app_localizations.dart';
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

  List<LatLng>? _routeToPickup;
  List<LatLng>? _routePickupToDest;

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
  LatLng? get _effectiveDriverForRouting =>
      _driverLatLng ?? _deviceSeedLatLng;

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
        oldWidget.trip.destinationLng != widget.trip.destinationLng) {
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
    _resolveDeviceSeedLocation();
    // El punto azul del mapa no expone coordenadas al widget; sin esto a veces no hay
    // ancla para Directions hasta que el padre inyecte driverLat/Lng.
    _routingPositionSub = Geolocator.getPositionStream(
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
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
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
      _driverLatLng != null || _pickupLatLng != null || _destinationLatLng != null;

  Future<void> _fetchRoutesAndFit() async {
    final driver = _effectiveDriverForRouting;
    final pickup = _pickupLatLng;
    final dest = _destinationLatLng;
    final status = widget.trip.status;
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
    ].join('|');

    if (_lastRouteSignature == signature) {
      _fitBounds(smoothOnly: true);
      return;
    }
    _lastRouteSignature = signature;

    if (driver == null) {
      if (mounted) {
        setState(() {
          _routeToPickup = null;
          _routePickupToDest = null;
        });
      }
      // Sin ancla aún: no fijar firma para poder recalcular en cuanto llegue GPS/stream.
      _lastRouteSignature = null;
      return;
    }

    List<LatLng>? toPickup;
    List<LatLng>? pickupToDest;

    if (pickup != null) {
      toPickup = await _directions.getRoutePoints(
        originLat: driver.latitude,
        originLng: driver.longitude,
        destinationLat: pickup.latitude,
        destinationLng: pickup.longitude,
      );
      // Fallback: si Directions falla pero tenemos ambos puntos, dibujar línea recta.
      toPickup ??= [driver, pickup];
    }

    if (dest != null) {
      final originForDest = pickup ?? driver;
      pickupToDest = await _directions.getRoutePoints(
        originLat: originForDest.latitude,
        originLng: originForDest.longitude,
        destinationLat: dest.latitude,
        destinationLng: dest.longitude,
      );
      // Fallback si falla Directions.
      pickupToDest ??= [originForDest, dest];
    }

    if (!mounted) return;

    setState(() {
      // Antes de iniciar viaje, nos importa sobre todo la ruta hacia el pickup.
      if (status == 'accepted' || status == 'arrived') {
        _routeToPickup = toPickup;
        _routePickupToDest = pickupToDest;
      } else if (status == 'started') {
        // En viaje, priorizar ruta hacia el destino, pero podemos mantener la anterior.
        _routeToPickup = toPickup;
        _routePickupToDest = pickupToDest;
      } else {
        _routeToPickup = toPickup;
        _routePickupToDest = pickupToDest;
      }
    });

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
    final minLng = from.longitude < to.longitude ? from.longitude : to.longitude;
    final maxLng = from.longitude > to.longitude ? from.longitude : to.longitude;

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
    return const CameraPosition(
      target: LatLng(-12.0464, -77.0428),
      zoom: 12,
    );
  }

  Set<Marker> _buildMarkers() {
    final l10n = AppLocalizations.of(context);
    final markers = <Marker>{};
    final driver = _driverLatLng;
    final pickup = _pickupLatLng;
    final dest = _destinationLatLng;

    if (driver != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: driver,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          flat: true,
          anchor: const Offset(0.5, 0.5),
          rotation: widget.driverBearing ?? 0,
          zIndexInt: 30,
          infoWindow: InfoWindow(title: l10n.driverMapDriverPosition),
        ),
      );
    }
    if (pickup != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: pickup,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
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
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          zIndexInt: 10,
          infoWindow: InfoWindow(title: l10n.driverMapDestinationPoint),
        ),
      );
    }
    return markers;
  }

  Set<Polyline> _buildPolylines() {
    final polylines = <Polyline>{};

    if (_routeToPickup != null && _routeToPickup!.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route_to_pickup'),
          points: _routeToPickup!,
          color: AppColors.primary,
          width: 8,
          geodesic: true,
          zIndex: 2,
        ),
      );
    }

    if (_routePickupToDest != null && _routePickupToDest!.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route_pickup_to_dest'),
          points: _routePickupToDest!,
          color: Colors.deepPurpleAccent,
          width: 8,
          geodesic: true,
          zIndex: 1,
        ),
      );
    }

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
          myLocationButtonEnabled: true,
          liteModeEnabled: false,
          markers: _buildMarkers(),
          polylines: _buildPolylines(),
          compassEnabled: false,
          buildingsEnabled: false,
          indoorViewEnabled: false,
          trafficEnabled: false,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
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
                  setState(() {
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
          top: 16,
          left: 16,
          child: SafeArea(
            bottom: false,
            child: const _MapLegendMini(),
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
  const _MapHintChip({
    super.key,
    required this.icon,
    required this.text,
  });

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

class _MapLegendMini extends StatelessWidget {
  const _MapLegendMini();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard.withValues(alpha: 0.86),
      borderRadius: BorderRadius.circular(12),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _LegendDot(color: Colors.green, label: 'Yo'),
            SizedBox(width: 8),
            _LegendDot(color: Colors.orange, label: 'Origen'),
            SizedBox(width: 8),
            _LegendDot(color: Colors.deepPurpleAccent, label: 'Destino'),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
