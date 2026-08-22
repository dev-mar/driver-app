import 'package:flutter_test/flutter_test.dart';
import 'package:texi_driver_app/features/registration/driver_registration_models.dart';

void main() {
  VehicleCatalog catalog() {
    return VehicleCatalog(
      compatibilityMode: false,
      vehicleTypes: const [
        VehicleCatalogVehicleType(
          id: 1,
          code: 'four_wheeler',
          label: 'Auto',
        ),
      ],
      vehicleCategories: const [],
      serviceTypes: const [],
      catalogExtensionsAvailable: true,
      manufacturers: const [
        CatalogManufacturer(id: 2, code: 'TOYOTA', name: 'Toyota'),
        CatalogManufacturer(id: 8, code: 'VOLVO', name: 'Volvo'),
        CatalogManufacturer(
          id: 9,
          code: 'OTHER_NOT_LISTED_LIGHT',
          name: 'Otro (no está en la lista)',
          metadata: {'is_catalog_catch_all': true, 'catalog_categoria': 'Vehículos Livianos / SUVs / Pickups / Lujo'},
        ),
        CatalogManufacturer(id: 1, code: 'NISSAN', name: 'Nissan'),
      ],
      vehicleModels: const [
        CatalogVehicleModelEntry(
          id: 10,
          manufacturerId: 2,
          code: 'HILUX',
          name: 'Hilux',
          segmentTransportMode: 'road_vehicle',
          metadata: {'catalog_categoria': 'Vehículos Livianos / SUVs / Pickups / Lujo'},
        ),
        CatalogVehicleModelEntry(
          id: 11,
          manufacturerId: 2,
          code: 'OTHER_MODEL_NOT_LISTED',
          name: 'Otro (no está en la lista)',
          segmentTransportMode: 'road_vehicle',
          metadata: {
            'is_catalog_catch_all': true,
            'catalog_categoria': 'Vehículos Livianos / SUVs / Pickups / Lujo',
          },
        ),
        CatalogVehicleModelEntry(
          id: 12,
          manufacturerId: 9,
          code: 'OTHER_CATCH_ALL_SEDAN',
          name: 'Otro (no está en la lista) · Sedan',
          segmentTransportMode: 'road_vehicle',
          metadata: {
            'is_catalog_catch_all': true,
            'catalog_categoria': 'Vehículos Livianos / SUVs / Pickups / Lujo',
          },
        ),
        CatalogVehicleModelEntry(
          id: 13,
          manufacturerId: 8,
          code: 'XC60',
          name: 'XC60',
          segmentTransportMode: 'road_vehicle',
          metadata: {'catalog_categoria': 'Vehículos Livianos / SUVs / Pickups / Lujo'},
        ),
      ],
    );
  }

  test('detecta catch-all de fabricante y modelo', () {
    final c = catalog();
    expect(c.manufacturers.firstWhere((m) => m.id == 9).isCatchAll, isTrue);
    expect(c.manufacturers.firstWhere((m) => m.id == 2).isCatchAll, isFalse);
    expect(c.vehicleModels.firstWhere((m) => m.id == 11).isCatchAll, isTrue);
    expect(c.vehicleModels.firstWhere((m) => m.id == 10).isCatchAll, isFalse);
  });

  test('Otros queda al final de fabricantes y modelos', () {
    final c = catalog();
    final mfrs = c.manufacturersSortedCatchAllLast(
      vehicleTypeId: 1,
      transportMode: 'road_vehicle',
    );
    expect(mfrs.last.isCatchAll, isTrue);
    expect(mfrs.last.code, 'OTHER_NOT_LISTED_LIGHT');
    expect(mfrs.first.isCatchAll, isFalse);
    expect(mfrs.any((m) => m.code == 'VOLVO' && !m.isCatchAll), isTrue);
    expect(mfrs[mfrs.length - 2].code, 'VOLVO');

    final models = c.modelsSortedCatchAllLast(
      vehicleTypeId: 1,
      transportMode: 'road_vehicle',
      manufacturerId: 2,
    );
    expect(models.last.isCatchAll, isTrue);
    expect(models.first.isCatchAll, isFalse);
  });

  test('catalog_proposal serializa kind, nombres y año', () {
    const p = VehicleCatalogCustomProposal(
      kind: 'model_only',
      proposedManufacturerName: 'Toyota',
      proposedModelName: 'Custom X',
      proposedModelYear: 2018,
      selectedManufacturerId: 2,
      selectedManufacturerName: 'Toyota',
    );
    expect(p.toApiJson(), {
      'kind': 'model_only',
      'proposed_manufacturer_name': 'Toyota',
      'proposed_model_name': 'Custom X',
      'proposed_model_year': 2018,
      'selected_manufacturer_id': 2,
      'selected_manufacturer_name': 'Toyota',
    });
  });

  test('SUV sin economy hereda servicios visibles de Sedán', () {
    const sedan = VehicleCatalogCategory(
      id: 1,
      vehicleTypeId: 1,
      code: 'sedan_taxi',
      label: 'Sedán / taxi',
      serviceTypeIds: [1, 2, 3],
    );
    const suv = VehicleCatalogCategory(
      id: 2,
      vehicleTypeId: 1,
      code: 'suv',
      label: 'SUV',
      serviceTypeIds: [2, 3],
    );
    const cat = VehicleCatalog(
      compatibilityMode: false,
      vehicleTypes: [
        VehicleCatalogVehicleType(id: 1, code: 'light_motor_vehicle', label: 'Auto'),
      ],
      vehicleCategories: [sedan, suv],
      serviceTypes: [
        VehicleCatalogServiceType(id: 1, name: 'Económico', code: 'economy'),
        VehicleCatalogServiceType(id: 2, name: 'Comfort', code: 'comfort'),
        VehicleCatalogServiceType(id: 3, name: 'Exclusivo', code: 'exclusive'),
      ],
    );
    expect(
      filterServiceTypeIdsForVehicleRegistration(cat, suv.serviceTypeIds),
      [2],
    );
    expect(registrationServiceTypeIdsForCategory(cat, sedan), [1, 2]);
    expect(registrationServiceTypeIdsForCategory(cat, suv), [2]);

    const suvEmpty = VehicleCatalogCategory(
      id: 2,
      vehicleTypeId: 1,
      code: 'suv',
      label: 'SUV',
      serviceTypeIds: [3],
    );
    const catEmptyComfort = VehicleCatalog(
      compatibilityMode: false,
      vehicleTypes: [
        VehicleCatalogVehicleType(id: 1, code: 'light_motor_vehicle', label: 'Auto'),
      ],
      vehicleCategories: [sedan, suvEmpty],
      serviceTypes: [
        VehicleCatalogServiceType(id: 1, name: 'Económico', code: 'economy'),
        VehicleCatalogServiceType(id: 2, name: 'Comfort', code: 'comfort'),
        VehicleCatalogServiceType(id: 3, name: 'Exclusivo', code: 'exclusive'),
      ],
    );
    expect(registrationServiceTypeIdsForCategory(catEmptyComfort, suvEmpty), [1, 2]);
  });
}
