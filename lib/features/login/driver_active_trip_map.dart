import 'package:flutter/material.dart';
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
    required this.trip,
    required this.bottomCard,
  });

  final double? driverLat;
  final double? driverLng;
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

  List<LatLng>? _routeToPickup;
  List<LatLng>? _routePickupToDest;
  bool _loadingRoute = false;

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

  @override
  void didUpdateWidget(DriverActiveTripMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.driverLat != widget.driverLat ||
        oldWidget.driverLng != widget.driverLng ||
        oldWidget.trip.status != widget.trip.status ||
        oldWidget.trip.tripId != widget.trip.tripId) {
      _fetchRoutesAndFit();
    }
  }

  @override
  void initState() {
    super.initState();
    _resolveDeviceSeedLocation();
    _fetchRoutesAndFit();
  }

  Future<void> _resolveDeviceSeedLocation() async {
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && mounted) {
        setState(() {
          _deviceSeedLatLng = LatLng(last.latitude, last.longitude);
        });
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
    final driver = _driverLatLng;
    final pickup = _pickupLatLng;
    final dest = _destinationLatLng;
    final status = widget.trip.status;

    if (driver == null) {
      setState(() {
        _routeToPickup = null;
        _routePickupToDest = null;
      });
      return;
    }

    setState(() => _loadingRoute = true);

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
      _loadingRoute = false;
    });

    _fitBounds();
  }

  void _fitBounds() {
    final controller = _mapController;
    if (controller == null) return;

    final points = <LatLng>[];
    final driver = _driverLatLng;
    final pickup = _pickupLatLng;
    final dest = _destinationLatLng;

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

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 72),
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
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: l10n.driverMapDriverPosition),
        ),
      );
    }
    if (pickup != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: pickup,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure),
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
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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
          width: 5,
        ),
      );
    }

    if (_routePickupToDest != null && _routePickupToDest!.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route_pickup_to_dest'),
          points: _routePickupToDest!,
          color: Colors.cyanAccent,
          width: 5,
        ),
      );
    }

    return polylines;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _initialCameraPosition(),
          onMapCreated: (controller) {
            _mapController = controller;
            _fitBounds();
            if (!_hasTripAnchors && _deviceSeedLatLng != null) {
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: _deviceSeedLatLng!, zoom: 15),
                ),
              );
            }
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: _buildMarkers(),
          polylines: _buildPolylines(),
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
        ),
        if (_loadingRoute)
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Material(
                color: AppColors.surfaceCard.withValues(alpha: 0.95),
                elevation: 8,
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppFoundation.radiusSm),
                ),
                shadowColor: Colors.black.withValues(alpha: 0.28),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    l10n.driverMapCalculatingRoute,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
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
