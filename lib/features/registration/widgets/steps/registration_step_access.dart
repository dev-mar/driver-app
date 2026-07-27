// GENERATED — editar con cuidado; regenerar: node tool/extract_registration_steps.mjs
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../gen_l10n/app_localizations.dart';
import '../../driver_registration_controller.dart';
import '../../registration_flow_bindings.dart';
import '../../registration_flow_helpers.dart';
import '../../registration_step_actions.dart';
import '../registration_flow_chrome.dart';
import '../registration_section_card.dart';

class RegistrationStepAccess extends ConsumerWidget {
  const RegistrationStepAccess({
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

        final phone = composeRegistrationFullPhone(bindings, flow);
        final fullName = [
          bindings.firstNameCtrl.text.trim(),
          bindings.lastNameCtrl.text.trim(),
        ].where((s) => s.isNotEmpty).join(' ').trim();
        final location = formatRegistrationServiceLocation(flow);
        final email = bindings.emailCtrl.text.trim();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RegistrationStepHeroCard(
              icon: Icons.verified_user_outlined,
              title: l10n.driverRegSectionActivateAccount,
              subtitle: l10n.driverRegSubtitleReviewBeforeContinue,
            ),
            const SizedBox(height: 14),
            RegistrationSectionCard(
              title: l10n.driverRegSectionYourSummary,
              icon: Icons.fact_check_outlined,
              subtitle: l10n.driverRegSubtitleProfileWorkZone,
              children: [
                RegistrationInfoTileRow(
                  icon: Icons.badge_outlined,
                  label: l10n.driverRegFieldFullName,
                  value: fullName.isEmpty ? '—' : fullName,
                ),
                const SizedBox(height: 12),
                RegistrationInfoTileRow(
                  icon: Icons.phone_android_rounded,
                  label: l10n.driverProfileFieldPhone,
                  value: phone.isEmpty ? '—' : phone,
                ),
                const SizedBox(height: 12),
                RegistrationInfoTileRow(
                  icon: Icons.place_outlined,
                  label: l10n.driverRegFieldServiceArea,
                  value: location,
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  RegistrationInfoTileRow(
                    icon: Icons.mail_outline_rounded,
                    label: l10n.driverProfileFieldEmail,
                    value: email,
                  ),
                ],
                const SizedBox(height: 14),
                RegistrationSoftStatusChip(
                  icon: Icons.check_circle_outline_rounded,
                  text: l10n.driverRegIdentityLicenseRegistered,
                ),
              ],
            ),
          ],
        );
  }

}
