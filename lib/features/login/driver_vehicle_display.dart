/// Etiquetas de vehículo visibles al conductor (ignora placeholders «—» del backend v2).
String? normalizeDriverVehicleLabel(String? raw) {
  final s = raw?.trim();
  if (s == null || s.isEmpty || s == '—' || s == '-') return null;
  return s;
}

/// Texto tipo «Toyota Corolla · ABC-123» desde `connection:ack.profile.vehicle`.
String? buildDriverVehicleLabelFromAckMap(Map<String, dynamic> vehicle) {
  final carModel = normalizeDriverVehicleLabel(vehicle['carModel']?.toString());
  final brand = normalizeDriverVehicleLabel(vehicle['brand']?.toString());
  final model = normalizeDriverVehicleLabel(vehicle['model']?.toString());
  final plate = normalizeDriverVehicleLabel(
    vehicle['licensePlate']?.toString() ??
        vehicle['license_plate']?.toString(),
  );
  final modelLine = carModel ??
      [brand, model].whereType<String>().join(' ').trim();
  if (modelLine.isNotEmpty && plate != null) {
    return '$modelLine · $plate';
  }
  if (modelLine.isNotEmpty) return modelLine;
  return plate;
}

/// Fallback desde `connection:ack.profile.fleetVehicles[0]`.
String? buildDriverVehicleLabelFromFleetList(dynamic fleetRaw) {
  if (fleetRaw is! List || fleetRaw.isEmpty) return null;
  final first = fleetRaw.first;
  if (first is! Map) return null;
  return buildDriverVehicleLabelFromAckMap(Map<String, dynamic>.from(first));
}
