int? _parsePositiveInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  return int.tryParse(s);
}

Map<String, dynamic>? _jsonObject(dynamic e) {
  if (e is Map<String, dynamic>) return e;
  if (e is Map) return Map<String, dynamic>.from(e);
  return null;
}

Map<String, dynamic>? _metadataMap(dynamic v) {
  final m = _jsonObject(v);
  if (m != null) return m;
  return null;
}

List<T> _parseCatalogList<T>(
  dynamic raw,
  T? Function(Map<String, dynamic>) parse,
) {
  final out = <T>[];
  if (raw is! List) return out;
  for (final e in raw) {
    final m = _jsonObject(e);
    if (m == null) continue;
    final v = parse(m);
    if (v != null) out.add(v);
  }
  return out;
}

class GeoCountry {
  const GeoCountry({
    required this.id,
    required this.name,
    required this.isoCode,
    required this.phoneCode,
  });

  final int id;
  final String name;
  final String isoCode;
  final String phoneCode;

  static GeoCountry? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name']?.toString();
    if (id is! int || name == null || name.isEmpty) return null;
    return GeoCountry(
      id: id,
      name: name,
      isoCode: json['iso_code']?.toString() ?? '',
      phoneCode: json['phone_code']?.toString() ?? '',
    );
  }
}

class GeoLocality {
  const GeoLocality({required this.id, required this.name});

  final int id;
  final String name;

  static GeoLocality? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name']?.toString();
    if (id is! int || name == null || name.isEmpty) return null;
    return GeoLocality(id: id, name: name);
  }
}

class GeoDepartment {
  const GeoDepartment({required this.name, required this.localities});

  final String name;
  final List<GeoLocality> localities;

  static GeoDepartment? fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString();
    if (name == null || name.isEmpty) return null;
    final raw = json['localities'];
    final list = <GeoLocality>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          final loc = GeoLocality.fromJson(e);
          if (loc != null) list.add(loc);
        }
      }
    }
    list.sort((a, b) => a.name.compareTo(b.name));
    return GeoDepartment(name: name, localities: list);
  }
}

/// Categorías de licencia (`document_type` en paso licencia). Origen: `GET /api/v2/geo/license-categories`.
class DriverLicenseCategory {
  const DriverLicenseCategory({
    required this.id,
    required this.label,
    this.code = '',
    this.isForeign = false,
  });

  /// Mismo valor que `document_type` en `POST .../document-info` (≠ 1).
  final int id;
  final String label;
  final String code;
  final bool isForeign;

  static DriverLicenseCategory? fromApiJson(Map<String, dynamic> json) {
    final idRaw = json['document_type_id'] ?? json['id'];
    final label = json['label']?.toString();
    if (idRaw is! num || label == null || label.isEmpty) return null;
    return DriverLicenseCategory(
      id: idRaw.toInt(),
      label: label,
      code: json['code']?.toString() ?? '',
      isForeign: json['is_foreign'] == true,
    );
  }

  /// Respaldo si el backend aún no tiene catálogo (Bolivia legacy).
  static const List<DriverLicenseCategory> legacyBoliviaFallback = [
    DriverLicenseCategory(id: 2, label: 'A', code: 'A'),
    DriverLicenseCategory(id: 3, label: 'B', code: 'B'),
    DriverLicenseCategory(id: 4, label: 'C', code: 'C'),
    DriverLicenseCategory(id: 7, label: 'M', code: 'M'),
    DriverLicenseCategory(id: 8, label: 'Licencia extranjera / internacional', code: 'INTERNATIONAL', isForeign: true),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverLicenseCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Ítem de `service_types` en `GET /api/v2/vehicles/catalog` (códigos fleet).
class VehicleCatalogServiceType {
  const VehicleCatalogServiceType({
    required this.id,
    required this.name,
    this.code,
  });

  final int id;
  final String name;
  final String? code;

  static VehicleCatalogServiceType? fromJson(Map<String, dynamic> json) {
    final id = _parsePositiveInt(json['id']);
    if (id == null) return null;
    var name = (json['name'] ?? json['label'])?.toString().trim() ?? '';
    if (name.isEmpty) name = 'ID $id';
    final codeRaw = json['code']?.toString().trim();
    return VehicleCatalogServiceType(
      id: id,
      name: name,
      code: (codeRaw != null && codeRaw.isNotEmpty) ? codeRaw : null,
    );
  }
}

/// Ítem de `vehicle_types` en el catálogo de vehículo.
class VehicleCatalogVehicleType {
  const VehicleCatalogVehicleType({
    required this.id,
    required this.code,
    required this.label,
    this.description,
  });

  final int id;
  final String code;
  final String label;
  final String? description;

  static VehicleCatalogVehicleType? fromJson(Map<String, dynamic> json) {
    final id = _parsePositiveInt(json['id']);
    final label = json['label']?.toString().trim();
    if (id == null || label == null || label.isEmpty) return null;
    return VehicleCatalogVehicleType(
      id: id,
      code: json['code']?.toString() ?? '',
      label: label,
      description: json['description']?.toString(),
    );
  }
}

/// Ítem de `vehicle_categories` (incluye `service_type_ids` agregados por el backend).
class VehicleCatalogCategory {
  const VehicleCatalogCategory({
    required this.id,
    required this.vehicleTypeId,
    required this.code,
    required this.label,
    required this.serviceTypeIds,
    this.description,
  });

  final int id;
  final int vehicleTypeId;
  final String code;
  final String label;
  final String? description;
  final List<int> serviceTypeIds;

  static VehicleCatalogCategory? fromJson(Map<String, dynamic> json) {
    final id = _parsePositiveInt(json['id']);
    final vtid = _parsePositiveInt(
      json['vehicle_type_id'] ?? json['vehicleTypeId'],
    );
    final label = json['label']?.toString().trim();
    if (id == null || vtid == null || label == null || label.isEmpty) {
      return null;
    }
    final rawSt = json['service_type_ids'] ?? json['serviceTypeIds'];
    final ids = <int>[];
    if (rawSt is List) {
      for (final e in rawSt) {
        final n = _parsePositiveInt(e);
        if (n != null) ids.add(n);
      }
    }
    return VehicleCatalogCategory(
      id: id,
      vehicleTypeId: vtid,
      code: json['code']?.toString() ?? '',
      label: label,
      description: json['description']?.toString(),
      serviceTypeIds: ids,
    );
  }
}

/// Segmento de modelo (p. ej. SEDAN, MOTO_STD) con `transport_mode` road_vehicle | motorcycle.
class CatalogModelSegmentType {
  const CatalogModelSegmentType({
    required this.id,
    required this.code,
    required this.label,
    this.description,
    required this.transportMode,
    this.sortOrder,
  });

  final int id;
  final String code;
  final String label;
  final String? description;
  final String transportMode;
  final int? sortOrder;

  static CatalogModelSegmentType? fromJson(Map<String, dynamic> json) {
    final id = _parsePositiveInt(json['id']);
    final label = json['label']?.toString().trim();
    if (id == null || label == null || label.isEmpty) return null;
    return CatalogModelSegmentType(
      id: id,
      code: json['code']?.toString() ?? '',
      label: label,
      description: json['description']?.toString(),
      transportMode:
          json['transport_mode']?.toString() ?? json['transportMode']?.toString() ?? 'road_vehicle',
      sortOrder: _parsePositiveInt(json['sort_order'] ?? json['sortOrder']),
    );
  }
}

class CatalogManufacturer {
  const CatalogManufacturer({
    required this.id,
    required this.code,
    required this.name,
    this.metadata = const {},
  });

  final int id;
  final String code;
  final String name;
  final Map<String, dynamic> metadata;

  static CatalogManufacturer? fromJson(Map<String, dynamic> json) {
    final id = _parsePositiveInt(json['id']);
    final name = json['name']?.toString().trim();
    if (id == null || name == null || name.isEmpty) return null;
    return CatalogManufacturer(
      id: id,
      code: json['code']?.toString() ?? '',
      name: name,
      metadata: _metadataMap(json['metadata']) ?? const {},
    );
  }
}

class CatalogVehicleModelEntry {
  const CatalogVehicleModelEntry({
    required this.id,
    required this.manufacturerId,
    required this.code,
    required this.name,
    this.modelYearStart,
    this.modelYearEnd,
    this.metadata = const {},
    this.segmentTypeId,
    this.segmentCode,
    this.segmentTransportMode,
  });

  final int id;
  final int manufacturerId;
  final String code;
  final String name;
  final int? modelYearStart;
  final int? modelYearEnd;
  final Map<String, dynamic> metadata;
  final int? segmentTypeId;
  final String? segmentCode;
  final String? segmentTransportMode;

  static CatalogVehicleModelEntry? fromJson(Map<String, dynamic> json) {
    final id = _parsePositiveInt(json['id']);
    final manufacturerId = _parsePositiveInt(
      json['manufacturer_id'] ?? json['manufacturerId'],
    );
    final name = json['name']?.toString().trim();
    if (id == null || manufacturerId == null || name == null || name.isEmpty) {
      return null;
    }
    return CatalogVehicleModelEntry(
      id: id,
      manufacturerId: manufacturerId,
      code: json['code']?.toString() ?? '',
      name: name,
      modelYearStart: _parsePositiveInt(json['model_year_start'] ?? json['modelYearStart']),
      modelYearEnd: _parsePositiveInt(json['model_year_end'] ?? json['modelYearEnd']),
      metadata: _metadataMap(json['metadata']) ?? const {},
      segmentTypeId: _parsePositiveInt(json['segment_type_id'] ?? json['segmentTypeId']),
      segmentCode: json['segment_code']?.toString() ?? json['segmentCode']?.toString(),
      segmentTransportMode: json['segment_transport_mode']?.toString() ??
          json['segmentTransportMode']?.toString(),
    );
  }
}

class CatalogEmissionNorm {
  const CatalogEmissionNorm({
    required this.id,
    required this.code,
    required this.label,
    required this.region,
    this.description,
    required this.standardFamily,
  });

  final int id;
  final String code;
  final String label;
  final String region;
  final String? description;
  final String standardFamily;

  static CatalogEmissionNorm? fromJson(Map<String, dynamic> json) {
    final id = _parsePositiveInt(json['id']);
    final label = json['label']?.toString().trim();
    if (id == null || label == null || label.isEmpty) return null;
    return CatalogEmissionNorm(
      id: id,
      code: json['code']?.toString() ?? '',
      label: label,
      region: json['region']?.toString() ?? '',
      description: json['description']?.toString(),
      standardFamily:
          json['standard_family']?.toString() ?? json['standardFamily']?.toString() ?? '',
    );
  }
}

class CatalogAxleConfiguration {
  const CatalogAxleConfiguration({
    required this.id,
    required this.code,
    required this.label,
    required this.axleCount,
    this.metadata = const {},
  });

  final int id;
  final String code;
  final String label;
  final int axleCount;
  final Map<String, dynamic> metadata;

  static CatalogAxleConfiguration? fromJson(Map<String, dynamic> json) {
    final id = _parsePositiveInt(json['id']);
    final label = json['label']?.toString().trim();
    final ax = _parsePositiveInt(json['axle_count'] ?? json['axleCount']);
    if (id == null || label == null || label.isEmpty || ax == null) return null;
    return CatalogAxleConfiguration(
      id: id,
      code: json['code']?.toString() ?? '',
      label: label,
      axleCount: ax,
      metadata: _metadataMap(json['metadata']) ?? const {},
    );
  }
}

class CatalogBodyType {
  const CatalogBodyType({
    required this.id,
    required this.code,
    required this.label,
    this.description,
    this.category,
  });

  final int id;
  final String code;
  final String label;
  final String? description;
  final String? category;

  static CatalogBodyType? fromJson(Map<String, dynamic> json) {
    final id = _parsePositiveInt(json['id']);
    final label = json['label']?.toString().trim();
    if (id == null || label == null || label.isEmpty) return null;
    return CatalogBodyType(
      id: id,
      code: json['code']?.toString() ?? '',
      label: label,
      description: json['description']?.toString(),
      category: json['category']?.toString(),
    );
  }
}

class CatalogMeasurementUnit {
  const CatalogMeasurementUnit({
    required this.id,
    required this.unitType,
    required this.code,
    required this.label,
    required this.symbol,
    required this.isMetric,
    required this.isCanonical,
  });

  final int id;
  final String unitType;
  final String code;
  final String label;
  final String symbol;
  final bool isMetric;
  final bool isCanonical;

  static CatalogMeasurementUnit? fromJson(Map<String, dynamic> json) {
    final id = _parsePositiveInt(json['id']);
    final label = json['label']?.toString().trim();
    if (id == null || label == null || label.isEmpty) return null;
    return CatalogMeasurementUnit(
      id: id,
      unitType: json['unit_type']?.toString() ?? json['unitType']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      label: label,
      symbol: json['symbol']?.toString() ?? '',
      isMetric: json['is_metric'] == true || json['isMetric'] == true,
      isCanonical: json['is_canonical'] == true || json['isCanonical'] == true,
    );
  }
}

class CatalogUnitConversion {
  const CatalogUnitConversion({
    required this.fromUnitId,
    required this.toUnitId,
    required this.multiplier,
    required this.offsetValue,
    this.fromCode,
    this.toCode,
  });

  final int fromUnitId;
  final int toUnitId;
  final double multiplier;
  final double offsetValue;
  final String? fromCode;
  final String? toCode;

  static CatalogUnitConversion? fromJson(Map<String, dynamic> json) {
    final fromId = _parsePositiveInt(json['from_unit_id'] ?? json['fromUnitId']);
    final toId = _parsePositiveInt(json['to_unit_id'] ?? json['toUnitId']);
    if (fromId == null || toId == null) return null;
    final multRaw = json['multiplier'];
    final mult = multRaw is num ? multRaw.toDouble() : double.tryParse('$multRaw') ?? 1.0;
    final offRaw = json['offset_value'] ?? json['offsetValue'] ?? 0;
    final off = offRaw is num ? offRaw.toDouble() : double.tryParse('$offRaw') ?? 0.0;
    return CatalogUnitConversion(
      fromUnitId: fromId,
      toUnitId: toId,
      multiplier: mult,
      offsetValue: off,
      fromCode: json['from_code']?.toString() ?? json['fromCode']?.toString(),
      toCode: json['to_code']?.toString() ?? json['toCode']?.toString(),
    );
  }
}

/// Catálogo de registro de vehículo desde `GET /api/v2/vehicles/catalog`.
class VehicleCatalog {
  const VehicleCatalog({
    required this.compatibilityMode,
    required this.vehicleTypes,
    required this.vehicleCategories,
    required this.serviceTypes,
    this.catalogExtensionsAvailable = false,
    this.catalogExtensionsSource,
    this.modelSegmentTypes = const [],
    this.manufacturers = const [],
    this.vehicleModels = const [],
    this.emissionNorms = const [],
    this.axleConfigurations = const [],
    this.bodyTypes = const [],
    this.measurementUnits = const [],
    this.measurementUnitConversions = const [],
  });

  final bool compatibilityMode;
  final List<VehicleCatalogVehicleType> vehicleTypes;
  final List<VehicleCatalogCategory> vehicleCategories;
  final List<VehicleCatalogServiceType> serviceTypes;
  final bool catalogExtensionsAvailable;
  final String? catalogExtensionsSource;
  final List<CatalogModelSegmentType> modelSegmentTypes;
  final List<CatalogManufacturer> manufacturers;
  final List<CatalogVehicleModelEntry> vehicleModels;
  final List<CatalogEmissionNorm> emissionNorms;
  final List<CatalogAxleConfiguration> axleConfigurations;
  final List<CatalogBodyType> bodyTypes;
  final List<CatalogMeasurementUnit> measurementUnits;
  final List<CatalogUnitConversion> measurementUnitConversions;

  /// Modelos filtrados por modo de transporte del catálogo extendido.
  List<CatalogVehicleModelEntry> modelsForTransportMode(String mode) {
    final m = mode.toLowerCase();
    return vehicleModels
        .where((e) => (e.segmentTransportMode ?? '').toLowerCase() == m)
        .toList(growable: false);
  }

  List<CatalogManufacturer> manufacturersForTransportMode(String mode) {
    final modelIds = modelsForTransportMode(mode).map((e) => e.manufacturerId).toSet();
    return manufacturers.where((x) => modelIds.contains(x.id)).toList(growable: false);
  }

  List<VehicleCatalogCategory> categoriesForType(int vehicleTypeId) {
    return vehicleCategories
        .where((c) => c.vehicleTypeId == vehicleTypeId)
        .toList(growable: false);
  }

  VehicleCatalogCategory? categoryById(int? id) {
    if (id == null) return null;
    for (final c in vehicleCategories) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Código fleet para `enabled_service_codes` en `POST /api/v2/vehicles`.
  String? serviceTypeCodeFor(int serviceTypeId) {
    for (final s in serviceTypes) {
      if (s.id == serviceTypeId) {
        final c = s.code;
        if (c != null && c.isNotEmpty) return c;
        return null;
      }
    }
    return null;
  }

  static VehicleCatalog? fromJson(Map<String, dynamic> json) {
    final compat =
        json['compatibility_mode'] == true || json['compatibilityMode'] == true;
    final stList = json['service_types'] ?? json['serviceTypes'];
    final serviceTypes = <VehicleCatalogServiceType>[];
    if (stList is List) {
      for (final e in stList) {
        final m = _jsonObject(e);
        if (m == null) continue;
        final s = VehicleCatalogServiceType.fromJson(m);
        if (s != null) serviceTypes.add(s);
      }
    }
    final tstList =
        json['transport_service_types'] ?? json['transportServiceTypes'];
    if (serviceTypes.isEmpty && tstList is List) {
      for (final e in tstList) {
        final m = _jsonObject(e);
        if (m == null) continue;
        final s = VehicleCatalogServiceType.fromJson(m);
        if (s != null) serviceTypes.add(s);
      }
    }
    final vtList = json['vehicle_types'] ?? json['vehicleTypes'];
    final vehicleTypes = <VehicleCatalogVehicleType>[];
    if (vtList is List) {
      for (final e in vtList) {
        final m = _jsonObject(e);
        if (m == null) continue;
        final v = VehicleCatalogVehicleType.fromJson(m);
        if (v != null) vehicleTypes.add(v);
      }
    }
    final vcList =
        json['vehicle_categories'] ?? json['vehicleCategories'];
    final vehicleCategories = <VehicleCatalogCategory>[];
    if (vcList is List) {
      for (final e in vcList) {
        final m = _jsonObject(e);
        if (m == null) continue;
        final c = VehicleCatalogCategory.fromJson(m);
        if (c != null) vehicleCategories.add(c);
      }
    }

    final extAvail = json['catalog_extensions_available'] == true ||
        json['catalogExtensionsAvailable'] == true;
    final extSource = json['catalog_extensions_source']?.toString() ??
        json['catalogExtensionsSource']?.toString() ??
        json['catalog_source']?.toString() ??
        json['catalogSource']?.toString();

    final modelSegmentTypes = _parseCatalogList(
      json['model_segment_types'] ?? json['modelSegmentTypes'],
      CatalogModelSegmentType.fromJson,
    );
    final manufacturers = _parseCatalogList(
      json['manufacturers'],
      CatalogManufacturer.fromJson,
    );
    final vehicleModels = _parseCatalogList(
      json['vehicle_models'] ?? json['vehicleModels'],
      CatalogVehicleModelEntry.fromJson,
    );
    final emissionNorms = _parseCatalogList(
      json['emission_norms'] ?? json['emissionNorms'],
      CatalogEmissionNorm.fromJson,
    );
    final axleConfigurations = _parseCatalogList(
      json['axle_configurations'] ?? json['axleConfigurations'],
      CatalogAxleConfiguration.fromJson,
    );
    final bodyTypes = _parseCatalogList(
      json['body_types'] ?? json['bodyTypes'],
      CatalogBodyType.fromJson,
    );
    final measurementUnits = _parseCatalogList(
      json['measurement_units'] ?? json['measurementUnits'],
      CatalogMeasurementUnit.fromJson,
    );
    final measurementUnitConversions = _parseCatalogList(
      json['measurement_unit_conversions'] ?? json['measurementUnitConversions'],
      CatalogUnitConversion.fromJson,
    );

    final extensionsInferred =
        manufacturers.isNotEmpty && vehicleModels.isNotEmpty;
    return VehicleCatalog(
      compatibilityMode: compat,
      vehicleTypes: vehicleTypes,
      vehicleCategories: vehicleCategories,
      serviceTypes: serviceTypes,
      catalogExtensionsAvailable: extAvail || extensionsInferred,
      catalogExtensionsSource: extSource,
      modelSegmentTypes: modelSegmentTypes,
      manufacturers: manufacturers,
      vehicleModels: vehicleModels,
      emissionNorms: emissionNorms,
      axleConfigurations: axleConfigurations,
      bodyTypes: bodyTypes,
      measurementUnits: measurementUnits,
      measurementUnitConversions: measurementUnitConversions,
    );
  }
}

/// Estado de reanudación: `GET /api/v2/driver/registration` (data incluye campos v1 + `schema_version`).
class DriverRegistrationStatusDto {
  const DriverRegistrationStatusDto({
    required this.uuid,
    required this.suggestedClientStep,
    required this.phase,
    required this.userStatus,
    required this.hasVehicle,
  });

  final String uuid;
  final int suggestedClientStep;
  final String phase;
  final String userStatus;
  final bool hasVehicle;

  factory DriverRegistrationStatusDto.fromJson(Map<String, dynamic> json) {
    final uuid = json['uuid']?.toString() ?? json['registration_session_id']?.toString() ?? '';
    final step = _parsePositiveInt(json['suggested_client_step']) ?? 1;
    return DriverRegistrationStatusDto(
      uuid: uuid,
      suggestedClientStep: step < 1
          ? 1
          : (step > 5 ? 5 : step),
      phase: json['phase']?.toString() ?? '',
      userStatus: json['user_status']?.toString() ?? '',
      hasVehicle: json['has_vehicle'] == true,
    );
  }
}
