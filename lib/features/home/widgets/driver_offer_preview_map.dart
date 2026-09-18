import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/network/directions_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_trip_marker.dart';
import '../../login/driver_trip_offer.dart';

/// Mapa de previsualización: no navega, no cambia disponibilidad ni acepta el viaje.
class DriverOfferPreviewMap extends StatefulWidget {
  const DriverOfferPreviewMap({
    super.key,
    required this.offer,
    this.bottomPadding = 280,
  });

  final DriverTripOffer offer;
  final double bottomPadding;

  @override
  State<DriverOfferPreviewMap> createState() => _DriverOfferPreviewMapState();
}

class _DriverOfferPreviewMapState extends State<DriverOfferPreviewMap> {
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

  static const Color _pickupFill = Color(0xFF00BFA5);
  static const Color _routeStroke = Color(0xFF5EEAD4);

  final DirectionsService _directions = DirectionsService();
  GoogleMapController? _mapController;
  BitmapDescriptor? _pickupIcon;
  BitmapDescriptor? _destIcon;
  List<LatLng> _polyline = const [];

  LatLng? get _pickup {
    final o = widget.offer;
    if (o.pickupLat == null || o.pickupLng == null) return null;
    return LatLng(o.pickupLat!, o.pickupLng!);
  }

  LatLng? get _dest {
    final o = widget.offer;
    if (o.destinationLat == null || o.destinationLng == null) return null;
    return LatLng(o.destinationLat!, o.destinationLng!);
  }

  @override
  void initState() {
    super.initState();
    _loadIcons();
    _loadRoute();
  }

  @override
  void didUpdateWidget(covariant DriverOfferPreviewMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offer.tripId != widget.offer.tripId ||
        oldWidget.offer.pickupLat != widget.offer.pickupLat ||
        oldWidget.offer.destinationLat != widget.offer.destinationLat ||
        oldWidget.offer.routeOverviewEncoded !=
            widget.offer.routeOverviewEncoded) {
      _loadRoute();
    }
  }

  Future<void> _loadIcons() async {
    final pickup = await buildDriverWaypointMapPinIcon(
      fill: _pickupFill,
      style: DriverWaypointPinStyle.pickupPerson,
    );
    final dest = await buildDriverWaypointMapPinIcon(
      fill: AppColors.primary,
      style: DriverWaypointPinStyle.destinationX,
    );
    if (!mounted) return;
    setState(() {
      _pickupIcon = pickup;
      _destIcon = dest;
    });
  }

  Future<void> _loadRoute() async {
    final pickup = _pickup;
    final dest = _dest;
    if (pickup == null || dest == null) {
      if (mounted) setState(() => _polyline = const []);
      return;
    }

    final encoded = widget.offer.routeOverviewEncoded?.trim();
    if (encoded != null && encoded.isNotEmpty) {
      final decoded = decodePolyline(encoded);
      if (decoded.length >= 2) {
        if (mounted) {
          setState(() => _polyline = decoded);
          _fitBounds();
        }
        return;
      }
    }

    final snapshot = await _directions.getRouteSnapshot(
      originLat: pickup.latitude,
      originLng: pickup.longitude,
      destinationLat: dest.latitude,
      destinationLng: dest.longitude,
    );
    if (!mounted) return;
    final points = snapshot?.polyline;
    setState(() {
      _polyline = (points != null && points.length >= 2)
          ? points
          : <LatLng>[pickup, dest];
    });
    _fitBounds();
  }

  CameraPosition _initialCamera() {
    final pickup = _pickup;
    final dest = _dest;
    if (pickup != null) {
      return CameraPosition(target: pickup, zoom: 14);
    }
    if (dest != null) {
      return CameraPosition(target: dest, zoom: 14);
    }
    return const CameraPosition(target: LatLng(-17.3895, -66.1568), zoom: 12);
  }

  Future<void> _fitBounds() async {
    final controller = _mapController;
    final pickup = _pickup;
    final dest = _dest;
    if (controller == null || pickup == null || dest == null) return;
    final points = _polyline.isNotEmpty ? _polyline : <LatLng>[pickup, dest];
    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;
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
    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 72),
      );
    } catch (_) {
      await controller.moveCamera(CameraUpdate.newLatLngBounds(bounds, 72));
    }
  }

  Set<Marker> _markers(AppLocalizations l10n) {
    final markers = <Marker>{};
    final pickup = _pickup;
    final dest = _dest;
    if (pickup != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('preview_pickup'),
          position: pickup,
          icon:
              _pickupIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          anchor: const Offset(0.5, kDriverWaypointPinTipAnchorY),
          infoWindow: InfoWindow(
            title: widget.offer.originAddress ?? l10n.tripOrigin,
          ),
        ),
      );
    }
    if (dest != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('preview_dest'),
          position: dest,
          icon:
              _destIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          anchor: const Offset(0.5, kDriverWaypointPinTipAnchorY),
          infoWindow: InfoWindow(
            title: widget.offer.destinationAddress ?? l10n.tripDestination,
          ),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!widget.offer.hasPreviewMapCoords) {
      return ColoredBox(
        color: AppColors.background,
        child: Center(
          child: Icon(
            Icons.map_outlined,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: _initialCamera(),
      onMapCreated: (controller) {
        _mapController = controller;
        _fitBounds();
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      liteModeEnabled: false,
      compassEnabled: false,
      buildingsEnabled: false,
      indoorViewEnabled: false,
      trafficEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      style: _nightMapStyle,
      padding: EdgeInsets.only(bottom: widget.bottomPadding, top: 72),
      markers: _markers(l10n),
      polylines: {
        if (_polyline.length >= 2)
          Polyline(
            polylineId: const PolylineId('preview_route'),
            points: _polyline,
            color: _routeStroke,
            width: 5,
          ),
      },
    );
  }
}
