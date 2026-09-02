// GENERATED — editar con cuidado; regenerar: node tool/extract_registration_steps.mjs
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_foundation.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../registration_flow_bindings.dart';
import '../../registration_flow_helpers.dart';
import '../../registration_image_helper.dart';
import '../../registration_step_actions.dart';
import '../registration_flow_chrome.dart';
import '../registration_section_card.dart';

class RegistrationStepIdentity extends ConsumerWidget {
  const RegistrationStepIdentity({
    super.key,
    required this.bindings,
    required this.actions,
    required this.showValidationErrors,
    this.fieldsReadOnly = false,
    this.photosLocked = false,
  });

  final RegistrationFlowBindings bindings;
  final RegistrationStepActions actions;
  final bool showValidationErrors;
  final bool fieldsReadOnly;
  final bool photosLocked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

        return Theme(
          data: registrationInputTheme(context),
          child: Form(
            key: bindings.formId,
            autovalidateMode: showValidationErrors
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RegistrationStepIntroBanner(message: l10n.driverRegIntroIdentity),
                const SizedBox(height: 14),
                RegistrationSectionCard(
                  title: l10n.driverRegSectionIdentityDocument,
                  icon: Icons.perm_identity_rounded,
                  subtitle: l10n.driverRegSubtitleIdentityDocument,
                  children: [
                    TextFormField(
                      controller: bindings.docNumberCtrl,
                      enabled: !fieldsReadOnly,
                      decoration: InputDecoration(
                        labelText: l10n.driverRegFieldDocumentNumber,
                        counterText: '',
                      ),
                      keyboardType: TextInputType.text,
                      maxLength: kDriverDocumentNumberMaxLength,
                      inputFormatters: driverDocumentNumberInputFormatters(),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                    ),
                    const SizedBox(height: AppFoundation.spacingMd),
                    TextFormField(
                      controller: bindings.docExpireCtrl,
                      readOnly: true,
                      enabled: !fieldsReadOnly,
                      decoration: InputDecoration(
                        labelText: l10n.driverRegFieldDocumentExpiry,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.event_rounded),
                          onPressed: fieldsReadOnly
                              ? null
                              : () => actions.pickDateToField(bindings.docExpireCtrl, future: true),
                        ),
                      ),
                      onTap: fieldsReadOnly
                          ? null
                          : () => actions.pickDateToField(bindings.docExpireCtrl, future: true),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                RegistrationSectionCard(
                  title: l10n.driverRegSectionFrontBack,
                  icon: Icons.chrome_reader_mode_outlined,
                  subtitle: l10n.driverRegSubtitleOneImagePerSide,
                  children: [
                    RegistrationCarnetUploadTile(
                      kind: RegistrationCarnetSlotKind.idFront,
                      isSet: bindings.idFrontB64 != null ||
                          (bindings.idFrontPreviewUrl != null &&
                              bindings.idFrontPreviewUrl!.isNotEmpty),
                      previewUrl: bindings.idFrontB64 == null
                          ? bindings.idFrontPreviewUrl
                          : null,
                      enabled: !photosLocked,
                      onTap: () async {
                        final b64 = await pickImageAsBase64(context);
                        actions.applyPickedImage(b64, (v) => bindings.idFrontB64 = v);
                      },
                      onLongPress: () async {
                        final b64 = await pickImageAsBase64PickerPrefiltered(context);
                        actions.applyPickedImage(b64, (v) => bindings.idFrontB64 = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    RegistrationCarnetUploadTile(
                      kind: RegistrationCarnetSlotKind.idBack,
                      isSet: bindings.idBackB64 != null ||
                          (bindings.idBackPreviewUrl != null &&
                              bindings.idBackPreviewUrl!.isNotEmpty),
                      previewUrl: bindings.idBackB64 == null
                          ? bindings.idBackPreviewUrl
                          : null,
                      enabled: !photosLocked,
                      onTap: () async {
                        final b64 = await pickImageAsBase64(context);
                        actions.applyPickedImage(b64, (v) => bindings.idBackB64 = v);
                      },
                      onLongPress: () async {
                        final b64 = await pickImageAsBase64PickerPrefiltered(context);
                        actions.applyPickedImage(b64, (v) => bindings.idBackB64 = v);
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
                const SizedBox(height: 14),
                RegistrationSectionCard(
                  title: l10n.driverRegSectionProfilePhoto,
                  icon: Icons.face_retouching_natural,
                  subtitle: l10n.driverRegSubtitleProfilePhoto,
                  children: [
                    RegistrationProfilePhotoCircleSlot(
                      base64Image: bindings.faceB64,
                      previewUrl: bindings.faceB64 == null
                          ? bindings.facePreviewUrl
                          : null,
                      enabled: !photosLocked,
                      onTap: () async {
                        final b64 = await pickImageAsBase64(
                          context,
                          kind: DriverRegistrationImageKind.facePortrait,
                        );
                        actions.applyPickedImage(b64, (v) => bindings.faceB64 = v);
                      },
                      onLongPress: () async {
                        final b64 = await pickImageAsBase64PickerPrefiltered(
                          context,
                          kind: DriverRegistrationImageKind.facePortrait,
                        );
                        actions.applyPickedImage(b64, (v) => bindings.faceB64 = v);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l10n.driverRegImageLongPressLightHint,
                        textAlign: TextAlign.center,
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
