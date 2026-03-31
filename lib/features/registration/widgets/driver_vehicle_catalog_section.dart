import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/service_type_display.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../driver_registration_models.dart';
import 'registration_section_card.dart';
import 'registration_soft_info_row.dart';

/// Resuelve el nombre mostrado de un `service_type` del catálogo (fallback localizado).
String vehicleCatalogServiceTypeLabel(
  VehicleCatalog catalog,
  int serviceTypeId,
  AppLocalizations l10n,
) {
  for (final s in catalog.serviceTypes) {
    if (s.id == serviceTypeId) {
      return displayServiceTypeName(s.name, l10n);
    }
  }
  return '${l10n.driverRegServiceTypeFallbackPrefix}$serviceTypeId';
}

/// Sección de UI para clasificación de vehículo según [GET /api/v2/vehicles/catalog].
class DriverVehicleCatalogSection extends StatelessWidget {
  const DriverVehicleCatalogSection({
    super.key,
    required this.l10n,
    required this.loading,
    this.errorMessage,
    this.catalog,
    required this.selectedVehicleTypeId,
    required this.selectedVehicleCategoryId,
    required this.selectedEnabledServiceTypeIds,
    required this.compatSelectedServiceTypeId,
    this.catalogTransportMode,
    this.catalogManufacturerId,
    this.catalogVehicleModelId,
    required this.onReloadCatalog,
    required this.onSelectVehicleType,
    required this.onSelectVehicleCategory,
    required this.onToggleEnabledServiceType,
    required this.onSelectCompatServiceType,
    required this.onSetCatalogTransportMode,
    required this.onSetCatalogManufacturer,
    required this.onSetCatalogVehicleModel,
    this.onPickCatalogModel,
  });

  final AppLocalizations l10n;
  final bool loading;
  final String? errorMessage;
  final VehicleCatalog? catalog;

  final int? selectedVehicleTypeId;
  final int? selectedVehicleCategoryId;
  final List<int> selectedEnabledServiceTypeIds;
  final int? compatSelectedServiceTypeId;

  final String? catalogTransportMode;
  final int? catalogManufacturerId;
  final int? catalogVehicleModelId;

  final Future<void> Function() onReloadCatalog;
  final void Function(int typeId) onSelectVehicleType;
  final void Function(int categoryId) onSelectVehicleCategory;
  final void Function(int serviceTypeId) onToggleEnabledServiceType;
  final void Function(int serviceTypeId) onSelectCompatServiceType;

  final void Function(String mode) onSetCatalogTransportMode;
  final void Function(int? manufacturerId) onSetCatalogManufacturer;
  final void Function(int? modelId) onSetCatalogVehicleModel;
  final void Function(CatalogVehicleModelEntry model, String manufacturerName)?
      onPickCatalogModel;

  @override
  Widget build(BuildContext context) {
    final cat = catalog;
    final categoriesForType = selectedVehicleTypeId != null && cat != null
        ? cat.categoriesForType(selectedVehicleTypeId!)
        : <VehicleCatalogCategory>[];
    final category = cat?.categoryById(selectedVehicleCategoryId);
    final allowedServiceIds = category?.serviceTypeIds ?? const <int>[];

    final mode = (catalogTransportMode ?? 'road_vehicle').toLowerCase();
    final showExtended =
        cat != null && !loading && errorMessage == null && cat.catalogExtensionsAvailable;
    final fallbackSource = (cat?.catalogExtensionsSource ?? '').toLowerCase() == 'fallback';

    return RegistrationSectionCard(
      title: l10n.driverRegSectionVehicleClassification,
      icon: Icons.category_outlined,
      children: [
        if (fallbackSource && cat != null && !loading && errorMessage == null) ...[
          Material(
            color: AppColors.surface.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.driverRegCatalogFallbackBanner,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (errorMessage != null) ...[
          Text(
            errorMessage!,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => onReloadCatalog(),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.driverRegCatalogRetry),
          ),
        ] else if (cat == null) ...[
          OutlinedButton.icon(
            onPressed: () => onReloadCatalog(),
            icon: const Icon(Icons.download_rounded),
            label: Text(l10n.driverRegCatalogLoad),
          ),
        ] else if (cat.compatibilityMode) ...[
          if (cat.serviceTypes.isEmpty) ...[
            RegistrationSoftInfoRow(
              text: l10n.driverRegCatalogCompatEmptyUsesDefault,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => onReloadCatalog(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.driverRegCatalogRetry),
            ),
          ] else
            DropdownButtonFormField<int>(
              key: ValueKey<int>(cat.serviceTypes.length),
              initialValue: cat.serviceTypes
                      .any((s) => s.id == compatSelectedServiceTypeId)
                  ? compatSelectedServiceTypeId
                  : cat.serviceTypes.first.id,
              decoration: InputDecoration(
                labelText: l10n.driverRegFieldServiceType,
              ),
              items: cat.serviceTypes
                  .map(
                    (s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(displayServiceTypeName(s.name, l10n)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) onSelectCompatServiceType(v);
              },
            ),
        ] else ...[
          if (showExtended) ...[
            Text(
              l10n.driverRegCatalogTransportStepTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment<String>(
                  value: 'road_vehicle',
                  label: Text(l10n.driverRegCatalogTransportCar),
                  icon: const Icon(Icons.directions_car_outlined, size: 18),
                ),
                ButtonSegment<String>(
                  value: 'motorcycle',
                  label: Text(l10n.driverRegCatalogTransportMoto),
                  icon: const Icon(Icons.two_wheeler_outlined, size: 18),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (s) {
                if (s.isEmpty) return;
                onSetCatalogTransportMode(s.first);
              },
            ),
            const SizedBox(height: 12),
            if (categoriesForType.isEmpty)
              RegistrationSoftInfoRow(text: l10n.driverRegVehicleTypeNoCategories)
            else if (categoriesForType.length > 1)
              DropdownButtonFormField<int>(
                key: ValueKey<String>(
                  'vc-${selectedVehicleTypeId ?? 0}-${categoriesForType.length}',
                ),
                initialValue: categoriesForType
                        .any((c) => c.id == selectedVehicleCategoryId)
                    ? selectedVehicleCategoryId
                    : categoriesForType.first.id,
                decoration: InputDecoration(
                  labelText: l10n.driverRegFieldVehicleCategory,
                ),
                items: categoriesForType
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.label),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onSelectVehicleCategory(v);
                },
              ),
          ] else ...[
            DropdownButtonFormField<int>(
              key: ValueKey<int?>(selectedVehicleTypeId),
              initialValue: selectedVehicleTypeId,
              decoration: InputDecoration(
                labelText: l10n.driverRegFieldVehicleType,
              ),
              items: cat.vehicleTypes
                  .map(
                    (t) => DropdownMenuItem(
                      value: t.id,
                      child: Text(t.label),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) onSelectVehicleType(v);
              },
            ),
            const SizedBox(height: 10),
            if (categoriesForType.isEmpty)
              RegistrationSoftInfoRow(text: l10n.driverRegVehicleTypeNoCategories)
            else
              DropdownButtonFormField<int>(
                key: ValueKey<String>(
                  'vc-${selectedVehicleTypeId ?? 0}-${categoriesForType.length}',
                ),
                initialValue: categoriesForType
                        .any((c) => c.id == selectedVehicleCategoryId)
                    ? selectedVehicleCategoryId
                    : categoriesForType.first.id,
                decoration: InputDecoration(
                  labelText: l10n.driverRegFieldVehicleCategory,
                ),
                items: categoriesForType
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.label),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onSelectVehicleCategory(v);
                },
              ),
          ],
          if (allowedServiceIds.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n.driverRegFieldServiceTypes,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final sid in allowedServiceIds)
                  FilterChip(
                    label: Text(
                      _vehicleCatalogServiceTypeLabel(cat, sid, l10n),
                      style: const TextStyle(fontSize: 13),
                    ),
                    selected: selectedEnabledServiceTypeIds.contains(sid),
                    onSelected: (_) => onToggleEnabledServiceType(sid),
                    selectedColor:
                        AppColors.primary.withValues(alpha: 0.22),
                    checkmarkColor: AppColors.onPrimary,
                    labelStyle:
                        const TextStyle(color: AppColors.textPrimary),
                  ),
              ],
            ),
          ] else if (selectedVehicleCategoryId != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: RegistrationSoftInfoRow(
                text: l10n.driverRegCategoryNoServices,
              ),
            ),
        ],
        if (showExtended) ...[
          const SizedBox(height: 20),
          Text(
            l10n.driverRegCatalogBrandModelTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          if (cat.catalogExtensionsSource == 'fallback')
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RegistrationSoftInfoRow(
                text: l10n.driverRegCatalogSourceFallback,
              ),
            )
          else if (cat.catalogExtensionsSource == 'database')
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                l10n.driverRegCatalogSourceDatabase,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                ),
              ),
            ),
          const SizedBox(height: 12),
          ..._brandModelFields(cat, mode),
          if (cat.emissionNorms.isNotEmpty ||
              cat.axleConfigurations.isNotEmpty ||
              cat.bodyTypes.isNotEmpty ||
              cat.measurementUnits.isNotEmpty) ...[
            const SizedBox(height: 8),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                l10n.driverRegCatalogTechnicalTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              children: [
                if (cat.emissionNorms.isNotEmpty)
                  _techBlock(
                    l10n.driverRegCatalogEmissionNorms,
                    cat.emissionNorms
                        .map((e) => '${e.code}: ${e.label} (${e.region})')
                        .join('\n'),
                  ),
                if (cat.axleConfigurations.isNotEmpty)
                  _techBlock(
                    l10n.driverRegCatalogAxles,
                    cat.axleConfigurations
                        .map((e) => '${e.code} — ${e.label}')
                        .join('\n'),
                  ),
                if (cat.bodyTypes.isNotEmpty)
                  _techBlock(
                    l10n.driverRegCatalogBodyTypes,
                    cat.bodyTypes
                        .map((e) => '${e.code}: ${e.label}')
                        .join('\n'),
                  ),
                if (cat.measurementUnits.isNotEmpty ||
                    cat.measurementUnitConversions.isNotEmpty)
                  _techBlock(
                    l10n.driverRegCatalogUnits,
                    [
                      ...cat.measurementUnits.map(
                        (u) =>
                            '${u.code} (${u.unitType}) ${u.symbol}${u.isCanonical ? ' *' : ''}',
                      ),
                      if (cat.measurementUnitConversions.isNotEmpty) '',
                      ...cat.measurementUnitConversions.map(
                        (c) =>
                            '1 ${c.fromCode ?? '?'} → ${c.multiplier} ${c.toCode ?? '?'}',
                      ),
                    ].where((s) => s.isNotEmpty).join('\n'),
                  ),
              ],
            ),
          ],
        ],
      ],
    );
  }

  String _vehicleCatalogServiceTypeLabel(
    VehicleCatalog catalog,
    int serviceTypeId,
    AppLocalizations l10n,
  ) =>
      vehicleCatalogServiceTypeLabel(catalog, serviceTypeId, l10n);

  List<Widget> _brandModelFields(VehicleCatalog cat, String mode) {
    final mfrs = List<CatalogManufacturer>.from(
      cat.manufacturersForTransportMode(mode),
    )..sort((a, b) => a.name.compareTo(b.name));

    final models = cat.vehicleModels
        .where(
          (e) =>
              e.manufacturerId == catalogManufacturerId &&
              (e.segmentTransportMode ?? '').toLowerCase() == mode,
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return [
      DropdownButtonFormField<int>(
        key: ValueKey<String>('mfr-$mode-${mfrs.length}'),
        initialValue:
            mfrs.any((m) => m.id == catalogManufacturerId) && catalogManufacturerId != null
                ? catalogManufacturerId
                : null,
        decoration: InputDecoration(
          labelText: l10n.driverRegCatalogPickBrand,
        ),
        items: mfrs
            .map(
              (m) => DropdownMenuItem(
                value: m.id,
                child: Text(m.name),
              ),
            )
            .toList(),
        onChanged: (v) => onSetCatalogManufacturer(v),
      ),
      const SizedBox(height: 10),
      DropdownButtonFormField<int>(
        key: ValueKey<String>(
          'mdl-$mode-${catalogManufacturerId ?? 0}-${models.length}',
        ),
        initialValue: catalogManufacturerId == null
            ? null
            : (models.any((m) => m.id == catalogVehicleModelId)
                ? catalogVehicleModelId
                : null),
        decoration: InputDecoration(
          labelText: catalogManufacturerId == null
              ? l10n.driverRegCatalogPickBrandFirst
              : l10n.driverRegCatalogPickModel,
        ),
        items: models
            .map(
              (m) => DropdownMenuItem(
                value: m.id,
                child: Text(m.name),
              ),
            )
            .toList(),
        onChanged: catalogManufacturerId == null
            ? null
            : (v) {
                onSetCatalogVehicleModel(v);
                if (v == null || onPickCatalogModel == null) return;
                CatalogVehicleModelEntry? entry;
                for (final e in models) {
                  if (e.id == v) {
                    entry = e;
                    break;
                  }
                }
                if (entry == null) return;
                String mname = '';
                for (final m in mfrs) {
                  if (m.id == entry.manufacturerId) {
                    mname = m.name;
                    break;
                  }
                }
                onPickCatalogModel!(entry, mname);
              },
      ),
    ];
  }

  Widget _techBlock(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              body,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: AppColors.textSecondary.withValues(alpha: 0.95),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
