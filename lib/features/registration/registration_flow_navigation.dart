import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/session/driver_registration_resume_gate.dart';
import '../../core/theme/app_colors.dart';
import '../../gen_l10n/app_localizations.dart';
import '../login/driver_login_controller.dart';
import '../login/driver_realtime_controller.dart';
import 'driver_registration_controller.dart';
import 'driver_registration_draft_media_store.dart';
import 'driver_registration_draft_store.dart';
import 'registration_flow_bindings.dart';
import 'registration_flow_helpers.dart';
import 'registration_flow_mode.dart';

Future<bool> _confirmRegistrationCancel({
  required BuildContext context,
  required AppLocalizations l10n,
  required bool vehicleScoped,
}) async {
  HapticFeedback.lightImpact();
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(l10n.driverRegCancelTitle),
      content: Text(
        vehicleScoped
            ? l10n.driverRegCancelBodyVehicle
            : l10n.driverRegCancelBodyUser,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.driverRegCancelKeepGoing),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n.driverRegCancelConfirm),
        ),
      ],
    ),
  );
  return result == true;
}

Future<void> _clearLocalRegistrationDrafts() async {
  await DriverRegistrationDraftStore.clear();
  await DriverRegistrationDraftMediaStore.clearAll();
  DriverRegistrationResumeGate.invalidate();
}

Future<void> handleRegistrationGoBack({
  required BuildContext context,
  required WidgetRef ref,
  required AppLocalizations l10n,
  required RegistrationFlowMode mode,
  required DriverRegistrationFlowState flow,
  required DriverRegistrationFlowController notifier,
  required RegistrationFlowBindings form,
  required Future<void> Function() persistDraft,
  void Function()? refreshUi,
}) async {
  // Solo lectura desde perfil: cerrar sin purga.
  if (mode.profileReadOnly) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRouter.profile);
    }
    return;
  }

  final vehicleScoped = mode.addVehicleOnly ||
      mode.galleryCompletionOnly ||
      flow.step >= 4;

  final confirmed = await _confirmRegistrationCancel(
    context: context,
    l10n: l10n,
    vehicleScoped: vehicleScoped && !mode.profileCompletionUx,
  );
  if (!confirmed || !context.mounted) return;

  // Completar bloque desde perfil: salir sin borrar cuenta.
  if (mode.profileCompletionUx) {
    await _clearLocalRegistrationDrafts();
    if (!context.mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRouter.profile);
    }
    return;
  }

  // Solo galería de un vehículo ya existente: no archivar el vehículo.
  if (mode.galleryCompletionOnly) {
    await _clearLocalRegistrationDrafts();
    notifier.resetFlow();
    if (!context.mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRouter.home);
    }
    return;
  }

  final repo = ref.read(driverRegistrationRepositoryProvider);
  notifier.clearError();

  if (vehicleScoped) {
    final carId = flow.carUuid?.trim();
    if (carId != null && carId.isNotEmpty) {
      try {
        await repo.archiveVehicleInProgress(carId);
      } catch (e) {
        // Best-effort: no dejar al usuario atrapado en el asistente.
        // El servidor puede fallar por carrera/estado; igual limpiamos local y vamos a home.
        final msg = e.toString().toLowerCase();
        final softIgnore = msg.contains('vehicle_asset_not_found') ||
            msg.contains('vehicle_archive_not_allowed') ||
            msg.contains('vehicle_db_error') ||
            msg.contains('sesión no disponible') ||
            msg.contains('no encontrado') ||
            msg.contains('no se pudo cancelar');
        if (!softIgnore && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizedRegistrationFlowError(e.toString(), l10n)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
    await _clearLocalRegistrationDrafts();
    notifier.resetFlow();
    if (!context.mounted) return;
    // Alta/cancel de vehículo: home + banner. No reabrir el formulario en esta sesión.
    DriverRegistrationResumeGate.skipVehicleFormThisSession();
    context.goNamed(AppRouter.home);
    return;
  }

  // Registro de cuenta (pasos 0–3): limpiar usuario pending en servidor si hay sesión.
  final hasSession = (flow.userUuid != null && flow.userUuid!.trim().isNotEmpty);
  if (hasSession) {
    try {
      await repo.abortRegistrationSession();
    } catch (e) {
      // Si aún no hay datos en servidor (o ya no es pending), seguimos con limpieza local.
      final msg = e.toString().toLowerCase();
      final softIgnore = msg.contains('reg_abort_not_found') ||
          msg.contains('reg_abort_not_allowed') ||
          msg.contains('sesión no disponible') ||
          msg.contains('reg_session_invalid') ||
          msg.contains('no hay registro pendiente');
      if (!softIgnore) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizedRegistrationFlowError(e.toString(), l10n)),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }
  }

  await _clearLocalRegistrationDrafts();
  try {
    await ref.read(driverRealtimeProvider.notifier).setOnline(false, forceOffline: true);
  } catch (_) {}
  await ref.read(driverLoginControllerProvider.notifier).logout();
  await repo.clearStoredAuthTokens();
  notifier.resetFlow();
  if (!context.mounted) return;
  context.goNamed(AppRouter.login);
}

void handleRegistrationGoBackSync({
  required BuildContext context,
  required WidgetRef ref,
  required AppLocalizations l10n,
  required RegistrationFlowMode mode,
  required DriverRegistrationFlowState flow,
  required DriverRegistrationFlowController notifier,
  required RegistrationFlowBindings form,
  required Future<void> Function() persistDraft,
  void Function()? refreshUi,
}) {
  unawaited(
    handleRegistrationGoBack(
      context: context,
      ref: ref,
      l10n: l10n,
      mode: mode,
      flow: flow,
      notifier: notifier,
      form: form,
      persistDraft: persistDraft,
      refreshUi: refreshUi,
    ),
  );
}
