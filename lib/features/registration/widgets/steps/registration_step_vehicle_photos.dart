// GENERATED — editar con cuidado; regenerar: node tool/extract_registration_steps.mjs
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../gen_l10n/app_localizations.dart';
import '../../registration_flow_bindings.dart';
import '../../registration_image_helper.dart';
import '../../registration_step_actions.dart';
import '../registration_flow_chrome.dart';
import '../registration_section_card.dart';

class RegistrationStepVehiclePhotos extends ConsumerWidget {
  const RegistrationStepVehiclePhotos({
    super.key,
    required this.bindings,
    required this.actions,
    required this.showValidationErrors,
    this.photosLocked = false,
    this.showIntro = true,
  });

  final RegistrationFlowBindings bindings;
  final RegistrationStepActions actions;
  final bool showValidationErrors;
  final bool photosLocked;
  final bool showIntro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showIntro) ...[
              RegistrationStepIntroBanner(message: l10n.driverRegIntroVehiclePhotos),
              const SizedBox(height: 14),
            ],
            RegistrationSectionCard(
              title: l10n.driverRegSectionVehicleViews,
              icon: Icons.grid_view_rounded,
              subtitle: l10n.driverRegSubtitleVehicleViews,
              children: [
                LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    final small = w < 400;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: small ? 2 : 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: small ? 0.85 : 0.75,
                      children: [
                        RegistrationCarAngleCard(
                          title: l10n.driverRegPhotoFrontTitle,
                          hint: l10n.driverRegPhotoFrontHint,
                          icon: Icons.directions_car_filled_rounded,
                          isDone: bindings.carFrontB64 != null ||
                              (bindings.carFrontPreviewUrl != null &&
                                  bindings.carFrontPreviewUrl!.isNotEmpty),
                          previewBase64: bindings.carFrontB64,
                          previewUrl: bindings.carFrontB64 == null
                              ? bindings.carFrontPreviewUrl
                              : null,
                          enabled: !photosLocked,
                          onTap: () async {
                            final b64 = await pickImageAsBase64(
                              context,
                              kind: DriverRegistrationImageKind.vehicleAngle,
                            );
                            actions.applyPickedImage(b64, (v) => bindings.carFrontB64 = v);
                          },
                        ),
                        RegistrationCarAngleCard(
                          title: l10n.driverRegPhotoRearTitle,
                          hint: l10n.driverRegPhotoRearHint,
                          icon: Icons.directions_car_rounded,
                          isDone: bindings.carBackB64 != null ||
                              (bindings.carBackPreviewUrl != null &&
                                  bindings.carBackPreviewUrl!.isNotEmpty),
                          previewBase64: bindings.carBackB64,
                          previewUrl: bindings.carBackB64 == null
                              ? bindings.carBackPreviewUrl
                              : null,
                          enabled: !photosLocked,
                          onTap: () async {
                            final b64 = await pickImageAsBase64(
                              context,
                              kind: DriverRegistrationImageKind.vehicleAngle,
                            );
                            actions.applyPickedImage(b64, (v) => bindings.carBackB64 = v);
                          },
                        ),
                        RegistrationCarAngleCard(
                          title: l10n.driverRegPhotoLeftTitle,
                          hint: l10n.driverRegPhotoLeftHint,
                          icon: Icons.arrow_back_rounded,
                          isDone: bindings.carLeftB64 != null ||
                              (bindings.carLeftPreviewUrl != null &&
                                  bindings.carLeftPreviewUrl!.isNotEmpty),
                          previewBase64: bindings.carLeftB64,
                          previewUrl: bindings.carLeftB64 == null
                              ? bindings.carLeftPreviewUrl
                              : null,
                          enabled: !photosLocked,
                          onTap: () async {
                            final b64 = await pickImageAsBase64(
                              context,
                              kind: DriverRegistrationImageKind.vehicleAngle,
                            );
                            actions.applyPickedImage(b64, (v) => bindings.carLeftB64 = v);
                          },
                        ),
                        RegistrationCarAngleCard(
                          title: l10n.driverRegPhotoRightTitle,
                          hint: l10n.driverRegPhotoRightHint,
                          icon: Icons.arrow_forward_rounded,
                          isDone: bindings.carRightB64 != null ||
                              (bindings.carRightPreviewUrl != null &&
                                  bindings.carRightPreviewUrl!.isNotEmpty),
                          previewBase64: bindings.carRightB64,
                          previewUrl: bindings.carRightB64 == null
                              ? bindings.carRightPreviewUrl
                              : null,
                          enabled: !photosLocked,
                          onTap: () async {
                            final b64 = await pickImageAsBase64(
                              context,
                              kind: DriverRegistrationImageKind.vehicleAngle,
                            );
                            actions.applyPickedImage(b64, (v) => bindings.carRightB64 = v);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        );
  }

}
