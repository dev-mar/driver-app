import 'package:flutter/material.dart';

/// Recojo vs destino: el fallback visual sigue el rail de la card.
enum DriverTripPlaceKind { pickup, destination }

/// Icono de lugar a partir de la dirección (aeropuerto, casa, hospital, etc.).
///
/// Si no hay pista clara, recojo usa pin y destino usa bandera.
IconData resolveDriverTripPlaceIcon(
  String? address, {
  required DriverTripPlaceKind kind,
}) {
  final text = (address ?? '').toLowerCase().trim();
  if (text.isEmpty) {
    return kind == DriverTripPlaceKind.pickup
        ? Icons.place_rounded
        : Icons.flag_rounded;
  }

  if (_matches(text, const [
    'aeropuerto',
    'airport',
    'viru viru',
    'wilstermann',
    'alcantarí',
    'alcantari',
  ])) {
    return Icons.flight_takeoff_rounded;
  }
  if (_matches(text, const ['terminal', 'flota', 'bus station'])) {
    return Icons.directions_bus_rounded;
  }
  if (_matches(text, const [
    'hospital',
    'clínica',
    'clinica',
    'centro de salud',
  ])) {
    return Icons.local_hospital_rounded;
  }
  if (_matches(text, const ['farmacia', 'pharmacy'])) {
    return Icons.local_pharmacy_rounded;
  }
  if (_matches(text, const [
    'universidad',
    'colegio',
    'escuela',
    'utepsa',
    'univalle',
    'school',
  ])) {
    return Icons.school_rounded;
  }
  if (_matches(text, const [
    'supermercado',
    'mercado',
    'shopping',
    'mall',
    'icnorte',
    'ventura',
    'hypermaxi',
  ])) {
    return Icons.storefront_rounded;
  }
  if (_matches(text, const ['hotel', 'hostal', 'hostel'])) {
    return Icons.hotel_rounded;
  }
  if (_matches(text, const ['casa', 'domicilio', 'residencia', 'home'])) {
    return Icons.home_rounded;
  }
  if (_matches(text, const [
    'trabajo',
    'oficina',
    'edificio',
    'office',
    'work',
  ])) {
    return Icons.work_rounded;
  }
  if (_matches(text, const ['plaza', 'parque', 'park'])) {
    return Icons.park_rounded;
  }
  if (_matches(text, const ['iglesia', 'catedral', 'templo', 'church'])) {
    return Icons.church_rounded;
  }
  if (_matches(text, const ['banco', 'cooperativa', 'bank'])) {
    return Icons.account_balance_rounded;
  }
  if (_matches(text, const ['gasolinera', 'surtidor', 'estación de servicio'])) {
    return Icons.local_gas_station_rounded;
  }
  if (_matches(text, const ['restaurante', 'restaurant', 'cafetería', 'cafe'])) {
    return Icons.restaurant_rounded;
  }
  if (_matches(text, const ['estadio', 'stadium'])) {
    return Icons.stadium_rounded;
  }

  return kind == DriverTripPlaceKind.pickup
      ? Icons.place_rounded
      : Icons.flag_rounded;
}

bool _matches(String text, List<String> keywords) {
  for (final keyword in keywords) {
    if (text.contains(keyword)) return true;
  }
  return false;
}
