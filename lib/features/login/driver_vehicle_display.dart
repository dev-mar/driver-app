/// Etiquetas de vehículo visibles al conductor (ignora placeholders «—» del backend v2).
String? normalizeDriverVehicleLabel(String? raw) {
  final s = raw?.trim();
  if (s == null || s.isEmpty || s == '—' || s == '-') return null;
  return s;
}

/// Marca / modelo / placa por separado para el mini perfil del home.
class DriverVehicleParts {
  const DriverVehicleParts({this.brand, this.model, this.plate});

  final String? brand;
  final String? model;
  final String? plate;

  bool get hasAny =>
      (brand != null && brand!.isNotEmpty) ||
      (model != null && model!.isNotEmpty) ||
      (plate != null && plate!.isNotEmpty);
}

/// Recorta el modelo a [maxChars] y añade `...` si es más largo.
String truncateDriverVehicleModel(String? raw, {int maxChars = 10}) {
  final s = raw?.trim() ?? '';
  if (s.isEmpty) return '';
  if (s.length <= maxChars) return s;
  return '${s.substring(0, maxChars)}...';
}

DriverVehicleParts? buildDriverVehiclePartsFromAckMap(
  Map<String, dynamic> vehicle,
) {
  final brand = normalizeDriverVehicleLabel(vehicle['brand']?.toString());
  final model = normalizeDriverVehicleLabel(vehicle['model']?.toString());
  final carModel = normalizeDriverVehicleLabel(vehicle['carModel']?.toString());
  final plate = normalizeDriverVehicleLabel(
    vehicle['licensePlate']?.toString() ?? vehicle['license_plate']?.toString(),
  );
  String? resolvedBrand = brand;
  String? resolvedModel = model;
  if ((resolvedBrand == null || resolvedBrand.isEmpty) &&
      (resolvedModel == null || resolvedModel.isEmpty) &&
      carModel != null) {
    final split = _splitModelLine(carModel);
    resolvedBrand = split.$1;
    resolvedModel = split.$2;
  } else if ((resolvedModel == null || resolvedModel.isEmpty) &&
      carModel != null) {
    resolvedModel = carModel;
  }
  final parts = DriverVehicleParts(
    brand: resolvedBrand,
    model: resolvedModel,
    plate: plate,
  );
  return parts.hasAny ? parts : null;
}

DriverVehicleParts? buildDriverVehiclePartsFromFleetList(dynamic fleetRaw) {
  if (fleetRaw is! List || fleetRaw.isEmpty) return null;
  final first = fleetRaw.first;
  if (first is! Map) return null;
  return buildDriverVehiclePartsFromAckMap(Map<String, dynamic>.from(first));
}

DriverVehicleParts? parseDriverVehiclePartsFromLabel(String? label) {
  final raw = normalizeDriverVehicleLabel(label);
  if (raw == null) return null;
  final chunks = raw.split(' · ');
  if (chunks.length >= 2) {
    final plate = normalizeDriverVehicleLabel(chunks.last);
    final modelLine = chunks.sublist(0, chunks.length - 1).join(' · ').trim();
    final split = _splitModelLine(modelLine);
    return DriverVehicleParts(brand: split.$1, model: split.$2, plate: plate);
  }
  if (_looksLikePlate(raw)) {
    return DriverVehicleParts(plate: raw);
  }
  final split = _splitModelLine(raw);
  return DriverVehicleParts(brand: split.$1, model: split.$2);
}

(String?, String?) _splitModelLine(String line) {
  final bits = line.trim().split(RegExp(r'\s+'));
  if (bits.isEmpty) return (null, null);
  if (bits.length == 1) return (null, bits.first);
  return (bits.first, bits.sublist(1).join(' '));
}

bool _looksLikePlate(String raw) {
  final compact = raw.replaceAll(RegExp(r'[\s-]'), '');
  return compact.length <= 8 && RegExp(r'^[A-Za-z0-9]+$').hasMatch(compact);
}

/// Texto tipo «Toyota Corolla · ABC-123» desde `connection:ack.profile.vehicle`.
String? buildDriverVehicleLabelFromAckMap(Map<String, dynamic> vehicle) {
  final parts = buildDriverVehiclePartsFromAckMap(vehicle);
  if (parts == null) return null;
  final modelLine = [
    parts.brand,
    parts.model,
  ].whereType<String>().where((s) => s.isNotEmpty).join(' ').trim();
  if (modelLine.isNotEmpty && parts.plate != null) {
    return '$modelLine · ${parts.plate}';
  }
  if (modelLine.isNotEmpty) return modelLine;
  return parts.plate;
}

/// Fallback desde `connection:ack.profile.fleetVehicles[0]`.
String? buildDriverVehicleLabelFromFleetList(dynamic fleetRaw) {
  if (fleetRaw is! List || fleetRaw.isEmpty) return null;
  final first = fleetRaw.first;
  if (first is! Map) return null;
  return buildDriverVehicleLabelFromAckMap(Map<String, dynamic>.from(first));
}
