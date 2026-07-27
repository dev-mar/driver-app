import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/compliance/driver_play_permission_disclosures.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/ui/driver_ui_states.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_online_auth_sheet.dart';
import '../../login/driver_realtime_controller.dart';
import '../../session/driver_operational_profile.dart';
import 'driver_connection_phase_chip.dart';
import 'driver_home_mini_profile_avatar.dart';

/// Errores de permisos/GPS al activar online: hint contextual en home.
const kDriverOnlinePermissionHintCodes = <String>{
  'NO_GPS',
  'GPS_SERVICE_OFF',
  'NO_NOTIFICATIONS',
};

bool driverIsProminentOnlineGateError(String? code) {
  return code == 'DRIVER_VEHICLE_REQUIRED' ||
      code == 'DRIVER_CREDITS_BELOW_MIN' ||
      code == 'DRIVER_GO_ONLINE_BLOCKED' ||
      code == 'DRIVER_ACCOUNT_BLOCKED';
}

/// Menú overflow del AppBar (perfil, historial, créditos, logout).
class DriverHomeAppBarMenu extends ConsumerWidget {
  const DriverHomeAppBarMenu({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (value) {
        switch (value) {
          case 'settings':
            context.pushNamed(AppRouter.settings);
          case 'profile':
            context.goNamed(AppRouter.profile);
          case 'add_vehicle':
            context.pushNamed(AppRouter.myVehicles);
          case 'trip_history':
            context.pushNamed(AppRouter.tripHistory);
          case 'earnings_credits':
            context.pushNamed(AppRouter.earningsCredits);
          case 'logout':
            onLogout();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'settings',
          child: Text(l10n.driverSettingsTitle),
        ),
        PopupMenuItem(
          value: 'profile',
          child: Text(l10n.driverProfileMenu),
        ),
        PopupMenuItem(
          value: 'trip_history',
          child: Text(l10n.driverTripHistoryMenu),
        ),
        PopupMenuItem(
          value: 'earnings_credits',
          child: Text(l10n.driverEarningsCreditsMenu),
        ),
        PopupMenuItem(
          value: 'add_vehicle',
          child: Text(l10n.driverHomeMenuAddVehicle),
        ),
        PopupMenuItem(value: 'logout', child: Text(l10n.driverLogout)),
      ],
    );
  }
}

Future<void> showDriverVehicleRequiredForOnlineDialog(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        icon: Icon(
          Icons.directions_car_filled_rounded,
          color: AppColors.primary,
          size: 28,
        ),
        title: Text(l10n.driverHomeVehicleRequiredDialogTitle),
        content: Text(l10n.driverHomeCannotGoOnlineWithoutVehicle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (!context.mounted) return;
              ref.invalidate(driverOperationalProfileProvider);
              context.pushNamed(AppRouter.myVehicles);
            },
            child: Text(l10n.driverHomeMenuAddVehicle),
          ),
        ],
      );
    },
  );
}

Future<void> showDriverCreditsRequiredForOnlineDialog(
  BuildContext context,
  AppLocalizations l10n,
  DriverRealtimeState rt,
) async {
  final minRequired = rt.minCreditsToGoOnline.toStringAsFixed(0);
  final balance = rt.driverCreditsBalance.toStringAsFixed(2);
  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        icon: Icon(
          Icons.account_balance_wallet_rounded,
          color: AppColors.primary,
          size: 28,
        ),
        title: Text(l10n.driverAppCreditsTitle),
        content: Text(
          l10n.driverOnlineErrorCreditsBelowMin(minRequired, balance),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (!context.mounted) return;
              context.pushNamed(AppRouter.earningsCredits);
            },
            child: Text(l10n.driverEarningsCreditsMenu),
          ),
        ],
      );
    },
  );
}

/// Puertas UX antes de pasar a online (vehículo + créditos vigentes).
Future<bool> driverPreOnlineGatesAllowOnline({
  required BuildContext context,
  required WidgetRef ref,
  required AppLocalizations l10n,
}) async {
  try {
    var rt = ref.read(driverRealtimeProvider);
    if (rt.hasVehicleRegistered == false) {
      await showDriverVehicleRequiredForOnlineDialog(context, ref, l10n);
      return false;
    }
    final p = await ref.read(driverOperationalProfileProvider.future);
    if (p.needsVehicleRegistration) {
      if (!context.mounted) return false;
      await showDriverVehicleRequiredForOnlineDialog(context, ref, l10n);
      return false;
    }

    final notifier = ref.read(driverRealtimeProvider.notifier);
    await notifier.refreshGoOnlineGuards();
    rt = ref.read(driverRealtimeProvider);
    if (rt.insufficientCreditsToGoOnline) {
      if (!context.mounted) return false;
      await showDriverCreditsRequiredForOnlineDialog(context, l10n, rt);
      return false;
    }

    if (!context.mounted) return false;

    if (!await driverEnsurePlayDisclosuresBeforeOnline(context, l10n)) {
      return false;
    }

    return true;
  } catch (_) {
    return true;
  }
}

/// Biometría o credencial del dispositivo antes de activar disponibilidad.
Future<bool> driverAuthenticateBeforeGoingOnline({
  required BuildContext context,
  required AppLocalizations l10n,
  required LocalAuthentication localAuth,
}) async {
  final confirmed = await showDriverOnlineAuthPrompt(context, l10n);
  if (!confirmed) return false;

  HapticFeedback.lightImpact();

  final reasonBiometric = l10n.driverOnlineAuthReasonBiometric;
  final reasonDeviceCredential = l10n.driverOnlineAuthReasonDeviceCredential;
  final authErrorText = l10n.driverOnlineAuthVerifyFailed;

  try {
    final canCheckBiometrics = await localAuth.canCheckBiometrics;
    final supported = await localAuth.isDeviceSupported();
    if (!supported) return false;

    final available = canCheckBiometrics
        ? await localAuth.getAvailableBiometrics()
        : const <BiometricType>[];

    if (available.isNotEmpty) {
      final ok = await localAuth.authenticate(
        localizedReason: reasonBiometric,
        biometricOnly: true,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );
      if (ok) HapticFeedback.mediumImpact();
      return ok;
    }

    final ok = await localAuth.authenticate(
      localizedReason: reasonDeviceCredential,
      biometricOnly: false,
      sensitiveTransaction: true,
      persistAcrossBackgrounding: true,
    );
    if (ok) HapticFeedback.mediumImpact();
    return ok;
  } catch (_) {
    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.shield_outlined,
              color: AppColors.textPrimary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(authErrorText)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: AppColors.error.withValues(alpha: 0.95),
      ),
    );
    return false;
  }
}

/// Banner cuando el perfil operativo exige registro de vehículo.
class DriverHomeVehicleRegistrationBanner extends ConsumerWidget {
  const DriverHomeVehicleRegistrationBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: AppColors.primary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.driverHomeVehicleRegistrationBanner,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.25,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(driverOperationalProfileProvider);
                    context.pushNamed(
                      AppRouter.register,
                      extra: <String, dynamic>{'addVehicleOnly': true},
                    );
                  },
                  child: Text(l10n.driverHomeVehicleRegistrationCta),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

/// Tarjeta mini-perfil + switch de disponibilidad online.
class DriverHomeOnlineAvailabilityPanel extends ConsumerWidget {
  const DriverHomeOnlineAvailabilityPanel({
    super.key,
    required this.localAuth,
    required this.onAfterOnlineEnabled,
  });

  final LocalAuthentication localAuth;
  final Future<void> Function(BuildContext context) onAfterOnlineEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final realtime = ref.watch(driverRealtimeProvider);
    final online = realtime.online;
    final connecting = realtime.connecting;
    final switchVisualOn = realtime.availabilitySwitchVisualOn;
    final isRestoring = !online && switchVisualOn;

    final connectionLabel = connecting
        ? l10n.driverHomeMiniConnecting
        : online
        ? l10n.driverHomeMiniStatusOnline
        : isRestoring
        ? l10n.driverHomeMiniStatusRestoringConnection
        : l10n.driverHomeMiniStatusOffline;
    final connectionIcon = connecting
        ? Icons.sync_rounded
        : online
        ? Icons.verified_rounded
        : isRestoring
        ? Icons.autorenew_rounded
        : Icons.pause_circle_outline_rounded;
    final connectionColor = connecting
        ? AppColors.primary
        : online
        ? AppColors.success
        : isRestoring
        ? AppColors.primary
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDriverHomeMiniProfileAvatar(realtime),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (realtime.driverDisplayName != null &&
                          realtime.driverDisplayName!.trim().isNotEmpty)
                      ? realtime.driverDisplayName!.trim()
                      : l10n.driverProfileDefaultName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.35,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  (realtime.driverVehicleLabel != null &&
                          realtime.driverVehicleLabel!.trim().isNotEmpty)
                      ? realtime.driverVehicleLabel!.trim()
                      : l10n.driverHomeMiniVehicleEmpty,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: AppColors.textSecondary.withValues(alpha: 0.96),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (realtime.driverRating != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 17,
                        color: AppColors.primary.withValues(alpha: 0.95),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.driverHomeMiniRating(
                          realtime.driverRating!.toStringAsFixed(1),
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: AppMotion.stepSwitcher,
                  switchInCurve: AppMotion.emphasized,
                  switchOutCurve: AppMotion.standard,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.16),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Row(
                    key: ValueKey<String>('conn-$connectionLabel'),
                    children: [
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 900),
                        tween: Tween<double>(begin: 0.88, end: 1),
                        builder: (context, value, child) =>
                            Transform.scale(scale: value, child: child),
                        child: Icon(
                          connectionIcon,
                          size: 14,
                          color: connectionColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          connectionLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.97,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (connecting || isRestoring) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: const LinearProgressIndicator(minHeight: 3),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      driverConnectionPhaseChip(
                        icon: Icons.sync_rounded,
                        label: l10n.driverHomeMiniConnecting,
                        active: connecting,
                      ),
                      driverConnectionPhaseChip(
                        icon: Icons.autorenew_rounded,
                        label: l10n.driverHomeMiniStatusRestoringConnection,
                        active: isRestoring,
                      ),
                      driverConnectionPhaseChip(
                        icon: Icons.verified_rounded,
                        label: l10n.driverHomeMiniStatusOnline,
                        active: online,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Switch.adaptive(
                value: switchVisualOn,
                activeThumbColor: AppColors.onPrimary,
                activeTrackColor: AppColors.primary,
                onChanged: connecting
                    ? null
                    : (value) => _handleOnlineSwitch(
                        context: context,
                        ref: ref,
                        l10n: l10n,
                        value: value,
                        online: online,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleOnlineSwitch({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
    required bool value,
    required bool online,
  }) async {
    if (value && !online) {
      if (!await driverPreOnlineGatesAllowOnline(
        context: context,
        ref: ref,
        l10n: l10n,
      )) {
        return;
      }
      if (!context.mounted) return;
      final rtNow = ref.read(driverRealtimeProvider);
      final skipLocalAuth =
          rtNow.activeTrip != null || rtNow.tripPendingRating != null;
      if (!skipLocalAuth) {
        final ok = await driverAuthenticateBeforeGoingOnline(
          context: context,
          l10n: l10n,
          localAuth: localAuth,
        );
        if (!ok) return;
      }
    }
    if (!context.mounted) return;
    await ref.read(driverRealtimeProvider.notifier).setOnline(value);
    if (value && context.mounted) {
      final s = ref.read(driverRealtimeProvider);
      if (s.online && (s.errorCode == null || s.errorCode!.isEmpty)) {
        await onAfterOnlineEnabled(context);
      }
    }
  }
}

/// Errores inline de permisos/GPS bajo el panel de disponibilidad.
class DriverHomeOnlinePermissionErrorSection extends StatelessWidget {
  const DriverHomeOnlinePermissionErrorSection({
    super.key,
    required this.errorMessage,
    required this.errorCode,
    required this.l10n,
  });

  final String errorMessage;
  final String? errorCode;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        DriverInlineError(message: errorMessage),
        if (errorCode != null &&
            kDriverOnlinePermissionHintCodes.contains(errorCode)) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
            child: DriverInlineInfo(
              message: l10n.driverHomeOnlineRequirementsHint,
            ),
          ),
          if (errorCode == 'GPS_SERVICE_OFF') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                },
                icon: const Icon(Icons.location_searching_rounded),
                label: Text(l10n.driverHomeOpenSystemLocationSettings),
              ),
            ),
          ],
          if (errorCode == 'NO_GPS') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await Geolocator.openAppSettings();
                },
                icon: const Icon(Icons.app_settings_alt_outlined),
                label: Text(l10n.driverHomeOpenAppPermissionSettings),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
