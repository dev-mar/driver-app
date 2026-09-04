// GENERATED — editar con cuidado; regenerar: node tool/extract_registration_steps.mjs
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_foundation.dart';
import '../../../../core/ui/horizontal_edge_fade.dart';
import '../../../../core/utils/vehicle_type_display.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../driver_registration_controller.dart';
import '../../registration_flow_bindings.dart';
import '../../registration_flow_helpers.dart';
import '../../registration_step_actions.dart';
import '../driver_vehicle_catalog_section.dart';
import '../registration_flow_chrome.dart';
import '../registration_section_card.dart';
import '../registration_soft_info_row.dart';

class RegistrationStepVehicle extends ConsumerWidget {
  const RegistrationStepVehicle({
    super.key,
    required this.bindings,
    required this.actions,
    required this.showValidationErrors,
    required this.flow,
    required this.notifier,
    required this.showTechnicalCatalogs,
    this.fieldsReadOnly = false,
  });

  final RegistrationFlowBindings bindings;
  final RegistrationStepActions actions;
  final bool showValidationErrors;
  final DriverRegistrationFlowState flow;
  final DriverRegistrationFlowController notifier;
  final bool showTechnicalCatalogs;
  final bool fieldsReadOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

        final integratedCatalog = useIntegratedCatalogVehicleFields(flow);

        return IgnorePointer(
          ignoring: fieldsReadOnly,
          child: Theme(
          data: registrationInputTheme(context),
          child: Form(
            key: bindings.formVehicle,
            autovalidateMode: showValidationErrors
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: fieldsReadOnly
                ? _vehicleReadonlyDetails(context, l10n)
                : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RegistrationStepIntroBanner(message: l10n.driverRegIntroVehicle),
                const SizedBox(height: 14),
                DriverVehicleCatalogSection(
                  l10n: l10n,
                  loading: flow.vehicleCatalogLoading,
                  errorMessage: flow.vehicleCatalogError,
                  catalog: flow.vehicleCatalog,
                  selectedVehicleTypeId: flow.selectedVehicleTypeId,
                  selectedVehicleCategoryId: flow.selectedVehicleCategoryId,
                  selectedEnabledServiceTypeIds: flow.selectedEnabledServiceTypeIds,
                  compatSelectedServiceTypeId: flow.compatSelectedServiceTypeId,
                  catalogTransportMode: flow.catalogTransportMode,
                  catalogManufacturerId: flow.catalogManufacturerId,
                  catalogVehicleModelId: flow.catalogVehicleModelId,
                  catalogCustomProposal: flow.catalogCustomProposal,
                  showTechnicalCatalogs: showTechnicalCatalogs,
                  onReloadCatalog: notifier.loadVehicleCatalog,
                  onSelectVehicleType: notifier.selectVehicleCatalogType,
                  onSelectVehicleCategory: notifier.selectVehicleCatalogCategory,
                  onToggleEnabledServiceType: notifier.toggleVehicleCatalogServiceType,
                  onSelectCompatServiceType: notifier.selectCompatVehicleServiceType,
                  onSetCatalogTransportMode: notifier.setCatalogTransportMode,
                  onSetCatalogManufacturer: notifier.setCatalogManufacturerId,
                  onSetCatalogVehicleModel: notifier.setCatalogVehicleModelId,
                  onCatalogCustomProposal: notifier.setCatalogCustomProposal,
                  onApplyCatalogCustomSelection: notifier.applyCatalogCustomSelection,
                  existingYearText: bindings.vehicleYearCtrl.text,
                  onResolvedCustomVehicleSpec: ({
                    required String brand,
                    required String model,
                    required String year,
                  }) {
                    bindings.vehicleBrandCtrl.text =
                        clampDriverText(brand, kDriverVehicleBrandMaxLength);
                    bindings.vehicleModelCtrl.text =
                        clampDriverText(model, kDriverVehicleModelMaxLength);
                    bindings.vehicleYearCtrl.text = year;
                    actions.onFormChanged();
                    unawaited(actions.persistDraft());
                  },
                  onPickCatalogModel: (entry, manufacturerName) {
                    onPickCatalogModel(manufacturerName, entry);
                  },
                  afterCatalogBrandModelFields: integratedCatalog
                      ? _vehicleCatalogAfterBrandModelFields(l10n, flow)
                      : const [],
                ),
                if (!integratedCatalog) ...[
                  const SizedBox(height: 14),
                  RegistrationSectionCard(
                    title: l10n.driverRegSectionVehicleData,
                    icon: Icons.directions_car_filled_rounded,
                    children: [
                      if (flow.catalogVehicleModelId == null) ...[
                        TextFormField(
                          controller: bindings.vehicleBrandCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.driverRegFieldBrand,
                            hintText: l10n.driverRegHintBrandExample,
                            counterText: '',
                          ),
                          maxLength: kDriverVehicleBrandMaxLength,
                          inputFormatters: driverVehicleBrandInputFormatters(),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                        ),
                        const SizedBox(height: 10),
                      ],
                      TextFormField(
                        controller: bindings.vehicleModelCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.driverRegFieldModel,
                          hintText: l10n.driverRegHintModelExample,
                          counterText: '',
                        ),
                        maxLength: kDriverVehicleModelMaxLength,
                        inputFormatters: driverVehicleModelInputFormatters(),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: bindings.vehicleYearCtrl,
                        decoration: InputDecoration(labelText: l10n.driverRegFieldYear),
                        keyboardType: TextInputType.number,
                        inputFormatters: vehicleYearInputFormatters,
                        validator: (v) => validateVehicleModelYear(v, l10n),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: bindings.vehicleColorCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.driverRegFieldColor,
                          hintText: l10n.driverRegHintTypeOrPickColor,
                          counterText: '',
                        ),
                        maxLength: kDriverVehicleColorMaxLength,
                        inputFormatters: driverVehicleColorInputFormatters(),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                      ),
                      const SizedBox(height: AppFoundation.spacingSm),
                      SizedBox(
                        height: 38,
                        child: HorizontalEdgeFade(
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: registrationCarColorSuggestions.length,
                            separatorBuilder: (_, _) => const SizedBox(width: AppFoundation.spacingSm),
                            itemBuilder: (context, index) {
                              final c = registrationCarColorSuggestions[index];
                              return RegistrationColorChoicePill(
                                label: localizedRegistrationColor(context, c),
                                color: registrationColorFromName(c),
                                selected: bindings.vehicleColorCtrl.text.trim() == c,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  bindings.vehicleColorCtrl.text = c;
                                  actions.onFormChanged();
                                  unawaited(actions.persistDraft());
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (kDriverRegShowSixSeatsToggle &&
                    flow.canDeclareSixPassengerSeats) ...[
                  const SizedBox(height: AppFoundation.spacingLg),
                  RegistrationSectionCard(
                    title: l10n.driverRegFieldSixSeats,
                    icon: Icons.event_seat_rounded,
                    children: [
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: flow.supportsSixPassengers,
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          notifier.setSupportsSixPassengers(v);
                          actions.onFormChanged();
                          unawaited(actions.persistDraft());
                        },
                        title: Text(
                          l10n.driverRegFieldSixSeats,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
                        ),
                        subtitle: Text(
                          l10n.driverRegHintSixSeats,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.35,
                            color: AppColors.textSecondary.withValues(alpha: 0.95),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppFoundation.spacingLg),
                RegistrationSectionCard(
                  title: l10n.driverRegSectionPlateOnly,
                  icon: Icons.pin_outlined,
                  subtitle: l10n.driverRegSubtitlePlateUppercase,
                  children: [
                    RegistrationSoftInfoRow(
                      text: l10n.driverRegHelperVehicleDocumentReference,
                    ),
                    const SizedBox(height: AppFoundation.spacingMd),
                    TextFormField(
                      controller: bindings.vehiclePlateCtrl,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: kDriverPlateMaxLength,
                      inputFormatters: driverPlateInputFormatters(),
                      decoration: InputDecoration(
                        labelText: l10n.driverRegFieldPlate,
                        hintText: l10n.driverRegHintPlateExample,
                        helperText: l10n.driverRegHelperUppercaseSaved,
                        counterText: '',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                    ),
                  ],
                ),
                // Póliza y título: no se piden en app; submitVehicle envía '—'.
              ],
            ),
          ),
        ),
        );
  }

  Widget _vehicleReadonlyDetails(BuildContext context, AppLocalizations l10n) {
    final cat = flow.vehicleCatalog;
    String dash(String? v) {
      final t = (v ?? '').trim();
      return t.isEmpty ? '—' : t;
    }

    String? typeLabel;
    String? categoryLabel;
    if (cat != null) {
      for (final t in cat.vehicleTypes) {
        if (t.id == flow.selectedVehicleTypeId) {
          typeLabel = displayVehicleTypeLabel(
            code: t.code,
            fallbackLabel: t.label,
            l10n: l10n,
          );
          break;
        }
      }
      for (final c in cat.vehicleCategories) {
        if (c.id == flow.selectedVehicleCategoryId) {
          categoryLabel = c.label;
          break;
        }
      }
    }
    final serviceBits = <String>[];
    if (cat != null) {
      for (final id in flow.selectedEnabledServiceTypeIds) {
        serviceBits.add(vehicleCatalogServiceTypeLabel(cat, id, l10n));
      }
    }
    final colorRaw = bindings.vehicleColorCtrl.text.trim();
    final colorLabel = colorRaw.isEmpty
        ? '—'
        : localizedRegistrationColor(context, colorRaw);
    final rows = <({String label, String value})>[
      (label: l10n.driverRegFieldBrand, value: dash(bindings.vehicleBrandCtrl.text)),
      (label: l10n.driverRegFieldModel, value: dash(bindings.vehicleModelCtrl.text)),
      (label: l10n.driverRegFieldYear, value: dash(bindings.vehicleYearCtrl.text)),
      (label: l10n.driverRegFieldColor, value: colorLabel),
      (label: l10n.driverRegFieldPlate, value: dash(bindings.vehiclePlateCtrl.text)),
      if (typeLabel != null && typeLabel.trim().isNotEmpty)
        (label: l10n.driverRegFieldVehicleType, value: typeLabel.trim()),
      if (categoryLabel != null && categoryLabel.trim().isNotEmpty)
        (label: l10n.driverRegFieldVehicleCategory, value: categoryLabel.trim()),
      if (serviceBits.isNotEmpty)
        (label: l10n.driverRegFieldServiceTypes, value: serviceBits.join(' · ')),
    ];

    return RegistrationSectionCard(
      title: l10n.driverRegSectionVehicleData,
      icon: Icons.directions_car_filled_rounded,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0)
            Divider(
              height: 18,
              color: AppColors.border.withValues(alpha: 0.45),
            ),
          _VehicleReadonlyDetailRow(label: rows[i].label, value: rows[i].value),
        ],
      ],
    );
  }

  List<Widget> _vehicleCatalogAfterBrandModelFields(
    AppLocalizations l10n,
    DriverRegistrationFlowState flow,
  ) {
    return [
      const SizedBox(height: 14),
      TextFormField(
        controller: bindings.vehicleYearCtrl,
        decoration: InputDecoration(labelText: l10n.driverRegFieldYear),
        keyboardType: TextInputType.number,
        inputFormatters: vehicleYearInputFormatters,
        validator: (v) => validateVehicleModelYear(v, l10n),
      ),
      const SizedBox(height: 10),
      TextFormField(
        controller: bindings.vehicleColorCtrl,
        decoration: InputDecoration(
          labelText: l10n.driverRegFieldColor,
          hintText: l10n.driverRegHintTypeOrPickColor,
          counterText: '',
        ),
        maxLength: kDriverVehicleColorMaxLength,
        inputFormatters: driverVehicleColorInputFormatters(),
        validator: (v) =>
            v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
      ),
      const SizedBox(height: AppFoundation.spacingSm),
      SizedBox(
        height: 38,
        child: HorizontalEdgeFade(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: registrationCarColorSuggestions.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppFoundation.spacingSm),
            itemBuilder: (context, index) {
              final c = registrationCarColorSuggestions[index];
              return RegistrationColorChoicePill(
                label: localizedRegistrationColor(context, c),
                color: registrationColorFromName(c),
                selected: bindings.vehicleColorCtrl.text.trim() == c,
                onTap: () {
                  HapticFeedback.selectionClick();
                  bindings.vehicleColorCtrl.text = c;
                  actions.onFormChanged();
                  unawaited(actions.persistDraft());
                },
              );
            },
          ),
        ),
      ),
    ];
  }

  void onPickCatalogModel(String manufacturerName, dynamic entry) {
    bindings.vehicleBrandCtrl.text = manufacturerName;
    bindings.vehicleModelCtrl.text = entry.name as String;
    final y = entry.modelYearEnd ?? entry.modelYearStart;
    if (y != null) bindings.vehicleYearCtrl.text = '$y';
    actions.onFormChanged();
  }

}

class _VehicleReadonlyDetailRow extends StatelessWidget {
  const _VehicleReadonlyDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 108,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}
