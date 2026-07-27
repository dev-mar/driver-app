// GENERATED — editar con cuidado; regenerar: node tool/extract_registration_steps.mjs
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../driver_registration_controller.dart';
import '../../driver_registration_models.dart';
import '../../registration_flow_bindings.dart';
import '../../registration_flow_helpers.dart';
import '../../registration_image_helper.dart';
import '../../registration_step_actions.dart';
import '../registration_flow_chrome.dart';
import '../registration_section_card.dart';

class RegistrationStepLicense extends ConsumerWidget {
  const RegistrationStepLicense({
    super.key,
    required this.bindings,
    required this.actions,
    required this.showValidationErrors,
    required this.flow,
  });

  final RegistrationFlowBindings bindings;
  final RegistrationStepActions actions;
  final bool showValidationErrors;
  final DriverRegistrationFlowState flow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

        final licenseItems = flow.licenseCategories.isEmpty
            ? DriverLicenseCategory.legacyBoliviaFallback
            : flow.licenseCategories;
        return Theme(
          data: registrationInputTheme(context),
          child: Form(
            key: bindings.formLicense,
            autovalidateMode: showValidationErrors
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RegistrationStepIntroBanner(message: l10n.driverRegIntroLicense),
                const SizedBox(height: 14),
                RegistrationSectionCard(
                  title: l10n.driverRegSectionCategoryValidity,
                  icon: Icons.category_outlined,
                  subtitle: l10n.driverRegSubtitleCategoryValidity,
                  children: [
                    DropdownButtonFormField<DriverLicenseCategory>(
                      key: ValueKey<String>(
                        'lic-cat-${licenseItems.map((e) => e.id).join('-')}-${bindings.licenseCategory?.id ?? 0}',
                      ),
                      initialValue: bindings.licenseCategory,
                      decoration: InputDecoration(
                        labelText: l10n.driverRegFieldCategory,
                        hintText: l10n.driverRegHintCategoryExample,
                      ),
                      items: licenseItems
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        bindings.licenseCategory = v;
                        actions.onFormChanged();
                        unawaited(actions.persistDraft());
                      },
                      validator: (v) => v == null ? l10n.driverRegValidationChooseCategory : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: bindings.licenseExpireCtrl,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: l10n.driverRegFieldExpiry,
                        hintText: l10n.driverRegHintLicenseExpiryDate,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.event_rounded),
                          onPressed: () =>
                              actions.pickDateToField(bindings.licenseExpireCtrl, future: true),
                        ),
                      ),
                      onTap: () => actions.pickDateToField(bindings.licenseExpireCtrl, future: true),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? l10n.driverRegValidationIndicateExpiryDate : null,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                RegistrationSectionCard(
                  title: l10n.driverRegSectionLicenseFrontBack,
                  icon: Icons.chrome_reader_mode_outlined,
                  subtitle: l10n.driverRegSubtitleOneImagePerSide,
                  children: [
                    RegistrationCarnetUploadTile(
                      kind: RegistrationCarnetSlotKind.licenseFront,
                      isSet: bindings.licFrontB64 != null,
                      onTap: () async {
                        final b64 = await pickImageAsBase64(context);
                        actions.applyPickedImage(b64, (v) => bindings.licFrontB64 = v);
                      },
                      onLongPress: () async {
                        final b64 = await pickImageAsBase64PickerPrefiltered(context);
                        actions.applyPickedImage(b64, (v) => bindings.licFrontB64 = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    RegistrationCarnetUploadTile(
                      kind: RegistrationCarnetSlotKind.licenseBack,
                      isSet: bindings.licBackB64 != null,
                      onTap: () async {
                        final b64 = await pickImageAsBase64(context);
                        actions.applyPickedImage(b64, (v) => bindings.licBackB64 = v);
                      },
                      onLongPress: () async {
                        final b64 = await pickImageAsBase64PickerPrefiltered(context);
                        actions.applyPickedImage(b64, (v) => bindings.licBackB64 = v);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l10n.driverRegImageLongPressLightHint,
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.35,
                          color: AppColors.textSecondary.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
  }

}
