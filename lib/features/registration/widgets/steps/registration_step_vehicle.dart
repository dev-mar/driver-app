// GENERATED — editar con cuidado; regenerar: node tool/extract_registration_steps.mjs
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_foundation.dart';
import '../../../../core/ui/horizontal_edge_fade.dart';
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
  });

  final RegistrationFlowBindings bindings;
  final RegistrationStepActions actions;
  final bool showValidationErrors;
  final DriverRegistrationFlowState flow;
  final DriverRegistrationFlowController notifier;
  final bool showTechnicalCatalogs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

        final integratedCatalog = useIntegratedCatalogVehicleFields(flow);

        return Theme(
          data: registrationInputTheme(context),
          child: Form(
            key: bindings.formVehicle,
            autovalidateMode: showValidationErrors
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
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
                  showTechnicalCatalogs: showTechnicalCatalogs,
                  onReloadCatalog: notifier.loadVehicleCatalog,
                  onSelectVehicleType: notifier.selectVehicleCatalogType,
                  onSelectVehicleCategory: notifier.selectVehicleCatalogCategory,
                  onToggleEnabledServiceType: notifier.toggleVehicleCatalogServiceType,
                  onSelectCompatServiceType: notifier.selectCompatVehicleServiceType,
                  onSetCatalogTransportMode: notifier.setCatalogTransportMode,
                  onSetCatalogManufacturer: notifier.setCatalogManufacturerId,
                  onSetCatalogVehicleModel: notifier.setCatalogVehicleModelId,
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
                          ),
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
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: bindings.vehicleYearCtrl,
                        decoration: InputDecoration(labelText: l10n.driverRegFieldYear),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: bindings.vehicleColorCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.driverRegFieldColor,
                          hintText: l10n.driverRegHintTypeOrPickColor,
                        ),
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
                const SizedBox(height: AppFoundation.spacingLg),
                RegistrationSectionCard(
                  title: l10n.driverRegSectionPlateVin,
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
                      inputFormatters: [RegistrationUpperCasePlateFormatter()],
                      decoration: InputDecoration(
                        labelText: l10n.driverRegFieldPlate,
                        hintText: l10n.driverRegHintPlateExample,
                        helperText: l10n.driverRegHelperUppercaseSaved,
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                    ),
                    const SizedBox(height: AppFoundation.spacingMd),
                    TextFormField(
                      controller: bindings.vehicleVinCtrl,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [RegistrationUpperCasePlateFormatter()],
                      decoration: InputDecoration(
                        labelText: l10n.driverRegFieldVinChassis,
                        hintText: l10n.driverRegHintVin17Chars,
                        helperText: l10n.driverRegHelperVehicleDocumentReference,
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                    ),
                  ],
                ),
                const SizedBox(height: AppFoundation.spacingLg),
                RegistrationSectionCard(
                  title: l10n.driverRegSectionInsuranceOwnership,
                  icon: Icons.description_outlined,
                  subtitle: l10n.driverRegSubtitleInsuranceOwnership,
                  children: [
                    TextFormField(
                      controller: bindings.vehicleInsuranceCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.driverRegFieldInsurancePolicyNumber,
                        hintText: l10n.driverRegHintAsPolicy,
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: bindings.vehicleTitleCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.driverRegFieldTitleDocData,
                        hintText: l10n.driverRegHintReferenceFromDocument,
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
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
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (v) =>
            v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
      ),
      const SizedBox(height: 10),
      TextFormField(
        controller: bindings.vehicleColorCtrl,
        decoration: InputDecoration(
          labelText: l10n.driverRegFieldColor,
          hintText: l10n.driverRegHintTypeOrPickColor,
        ),
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
