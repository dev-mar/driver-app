import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/session/driver_internal_tools_gate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/ui/driver_ui_states.dart';
import '../../../core/compliance/driver_login_legal_footer.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../driver_registration_controller.dart';
import '../registration_flow_bindings.dart';
import '../registration_flow_helpers.dart';
import '../registration_flow_mode.dart';
import '../registration_step_actions.dart';
import '../registration_flow_step_metadata.dart';
import 'registration_flow_chrome.dart';
import 'registration_flow_step_router.dart';

class RegistrationFlowScaffold extends ConsumerWidget {
  const RegistrationFlowScaffold({
    super.key,
    required this.mode,
    required this.form,
    required this.actions,
    required this.showValidationErrors,
    required this.onBack,
    required this.onContinue,
  });

  final RegistrationFlowMode mode;
  final RegistrationFlowBindings form;
  final RegistrationStepActions actions;
  final bool showValidationErrors;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final flow = ref.watch(driverRegistrationFlowControllerProvider);
    final notifier = ref.read(driverRegistrationFlowControllerProvider.notifier);
    final steps = registrationFlowVisibleStepLabels(l10n, mode);
    final visIdx = registrationFlowVisibleStepIndex(flow, mode);
    final progressValue =
        steps.isEmpty ? 0.0 : (visIdx + 1).clamp(1, steps.length) / steps.length;
    final showTechnicalCatalogs =
        ref.watch(driverInternalToolsVisibleProvider).valueOrNull == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(registrationFlowScaffoldTitle(l10n, mode)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!mode.profileCompletionUx)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.driverRegStepCounter(
                            (visIdx + 1).toString(),
                            steps.length.toString(),
                          ),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          steps[visIdx.clamp(0, steps.length - 1)],
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: progressValue,
                        backgroundColor: AppColors.border.withValues(alpha: 0.45),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            AnimatedSwitcher(
              duration: AppMotion.stepSwitcher,
              switchInCurve: AppMotion.emphasized,
              switchOutCurve: AppMotion.standard,
              transitionBuilder: (child, anim) {
                return FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.08),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                );
              },
              child: flow.globalError == null
                  ? const SizedBox.shrink(key: ValueKey('no-global-error'))
                  : Padding(
                      key: ValueKey<String>(flow.globalError!),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DriverInlineError(
                        message: localizedRegistrationFlowError(flow.globalError!, l10n),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                children: [
                  if (mode.profileFieldsReadOnly) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: RegistrationStepIntroBanner(
                        message: mode.profilePhotosLocked
                            ? l10n.driverRegProfileSectionLockedBanner
                            : (mode.profileCanSavePhotos ||
                                    flow.step == 1 ||
                                    flow.step == 2 ||
                                    flow.step == 4 ||
                                    flow.step == 5
                                ? l10n.driverRegProfileSectionPhotosEditableBanner
                                : l10n.driverRegProfileSectionReadOnlyBanner),
                      ),
                    ),
                  ],
                  Expanded(
                    child: AbsorbPointer(
                      absorbing: mode.profilePhotosLocked,
                      child: AnimatedSwitcher(
                        duration: AppMotion.stepSwitcher,
                        switchInCurve: AppMotion.standard,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, anim) {
                          return FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(0, AppMotion.slideDySubtle),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: anim,
                                  curve: AppMotion.standard,
                                ),
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey<int>(flow.step),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                RegistrationFlowStepRouter(
                                  flow: flow,
                                  notifier: notifier,
                                  bindings: form,
                                  actions: actions,
                                  showValidationErrors: showValidationErrors,
                                  showTechnicalCatalogs: showTechnicalCatalogs,
                                  fieldsReadOnly: mode.profileFieldsReadOnly,
                                  photosLocked: mode.profilePhotosLocked,
                                  embedVehiclePhotos: mode.profileCompletionUx &&
                                      (flow.step == 4),
                                ),
                                if (!mode.profileCompletionUx &&
                                    !mode.addVehicleOnly &&
                                    !mode.galleryCompletionOnly &&
                                    flow.step == 3) ...[
                                  const SizedBox(height: 20),
                                  const DriverLoginLegalFooter(
                                    tone: DriverLegalNoticeTone.activate,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            RegistrationBottomBar(
              loading: flow.loading,
              step: flow.step,
              lastStepIndex: mode.addVehicleOnly || mode.galleryCompletionOnly
                  ? 5
                  : (mode.profileCompletionUx
                      ? registrationFlowStepLabels(l10n).length - 1
                      : 3),
              profileCompletionMode: mode.profileCompletionUx,
              profileReadOnly: mode.profilePhotosLocked,
              profileSavePhotos: mode.profileCompletionUx &&
                  !mode.profilePhotosLocked &&
                  (flow.step == 1 ||
                      flow.step == 2 ||
                      flow.step == 4 ||
                      flow.step == 5),
              onBack: onBack,
              onContinue: onContinue,
            ),
          ],
        ),
      ),
    );
  }
}
