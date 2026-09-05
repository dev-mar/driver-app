import 'dart:async';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/notifications/driver_fcm_navigation.dart'
    show
        driverFcmTripOfferOpenBump,
        driverTripChatOpenBump,
        takePendingTripOfferFromNotification,
        takePendingTripChatTripIdFromNotification;
import '../../core/notifications/driver_trip_chat_visibility.dart';
import '../../core/router/app_router.dart';
import '../../core/session/driver_internal_tools_gate.dart';
import '../../core/session/driver_registration_resume_gate.dart';
import '../../core/session/driver_session_expulsion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../gen_l10n/app_localizations.dart';
import '../login/driver_login_controller.dart';
import '../login/driver_realtime_controller.dart';
import '../login/driver_trip_offer.dart';
import '../session/driver_operational_profile.dart';
import 'widgets/driver_trip_chat_panel.dart';
import 'widgets/driver_credits_notice_card.dart';
import 'widgets/driver_trip_rating_sheet.dart';

/// Lifecycle, FCM, wakelock, sheets y navegación externa del home conductor.
mixin DriverHomeLifecycleMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T>, WidgetsBindingObserver, SingleTickerProviderStateMixin<T> {
  static const bool verboseUiLogs = false;

  String? lastRatedTripId;
  bool isRatingSheetOpen = false;
  bool tripChatSheetDisplayed = false;
  final LocalAuthentication localAuth = LocalAuthentication();
  DateTime? lastBackgroundAt;
  bool keepActivePromptOpen = false;
  bool? prevShowMapForEntrance;
  late AnimationController homeListEntrance;
  late Animation<double> homeListFade;
  late Animation<Offset> homeListSlide;
  bool keepScreenOnApplied = false;
  int lastHandledFcmTripOfferBump = 0;
  int lastHandledTripChatOpenBump = 0;
  bool handlingAuthSessionExpired = false;
  bool openingVehicleRegistrationForm = false;
  bool vehicleFormAutoOpenAttempted = false;
  String? activeTripCardExpansionTripId;
  bool activeTripCardExpanded = true;

  void logUiVerbose(String message) {
    if (!verboseUiLogs) return;
    debugPrint('[DriverHome] $message');
  }

  void initDriverHomeLifecycle() {
    WidgetsBinding.instance.addObserver(this);
    driverFcmTripOfferOpenBump.addListener(onFcmTripOfferOpenBump);
    driverTripChatOpenBump.addListener(onTripChatOpenBump);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onFcmTripOfferOpenBump();
      onTripChatOpenBump();
      unawaited(maybeOpenVehicleRegistrationForm());
    });
    homeListEntrance = AnimationController(
      vsync: this,
      duration: AppMotion.screenEntrance,
    );
    homeListFade = CurvedAnimation(
      parent: homeListEntrance,
      curve: AppMotion.standard,
    );
    homeListSlide = Tween<Offset>(
      begin: Offset(0, AppMotion.slideDySubtle),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: homeListEntrance, curve: AppMotion.standard),
    );
    driverSessionExpulsionHandler = (code, message) async {
      if (!mounted) return;
      handleAuthSessionExpired();
    };
  }

  /// Home primero (sesión + me-profile). Si no hay vehículo, abrir el formulario — no el resumen.
  Future<void> maybeOpenVehicleRegistrationForm() async {
    if (vehicleFormAutoOpenAttempted || !mounted) return;
    vehicleFormAutoOpenAttempted = true;
    final needed = await DriverRegistrationResumeGate.needsVehicleFormAutoOpen();
    if (!needed || !mounted) return;
    setState(() => openingVehicleRegistrationForm = true);
    DriverRegistrationResumeGate.invalidate();
    final confirmed =
        await DriverRegistrationResumeGate.needsVehicleFormAutoOpen();
    if (!mounted) return;
    if (!confirmed) {
      setState(() => openingVehicleRegistrationForm = false);
      return;
    }
    context.goNamed(
      AppRouter.register,
      extra: <String, dynamic>{'addVehicleOnly': true},
    );
  }

  Widget wrapWithVehicleFormOpeningOverlay(Widget child) {
    if (!openingVehicleRegistrationForm) return child;
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        child,
        const ModalBarrier(dismissible: false, color: Color(0xCC000000)),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Material(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 18),
                    Text(
                      l10n.driverHomeOpeningVehicleForm,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void disposeDriverHomeLifecycle() {
    driverSessionExpulsionHandler = null;
    driverFcmTripOfferOpenBump.removeListener(onFcmTripOfferOpenBump);
    driverTripChatOpenBump.removeListener(onTripChatOpenBump);
    unawaited(WakelockPlus.disable());
    homeListEntrance.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void onFcmTripOfferOpenBump() {
    final bump = driverFcmTripOfferOpenBump.value;
    if (bump <= lastHandledFcmTripOfferBump) return;
    lastHandledFcmTripOfferBump = bump;
    if (!mounted) return;
    final payload = takePendingTripOfferFromNotification();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      bool? appliedFromNotification;
      if (payload != null) {
        appliedFromNotification = await ref
            .read(driverRealtimeProvider.notifier)
            .onNotificationOpenedWithTripOffer(payload);
      }
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      final l10n = AppLocalizations.of(context);
      final isWebDispatch = payload != null &&
          DriverTripOfferSource.isAdminWebDispatch(payload['requestSource']);
      final snackText = payload == null
          ? l10n.driverFcmOpenedTripOfferHint
          : appliedFromNotification == true
          ? (isWebDispatch
                ? l10n.driverFcmOpenedTripOfferOperationsHint
                : l10n.driverFcmOpenedTripOfferHint)
          : l10n.driverFcmOpenedTripOfferOfflineHint;
      messenger.showSnackBar(
        SnackBar(content: Text(snackText), behavior: SnackBarBehavior.floating),
      );
    });
  }

  void onTripChatOpenBump() {
    final bump = driverTripChatOpenBump.value;
    if (bump <= lastHandledTripChatOpenBump) return;
    lastHandledTripChatOpenBump = bump;
    if (!mounted) return;
    final tripId = takePendingTripChatTripIdFromNotification();
    if (tripId == null || tripId.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await ref
          .read(driverRealtimeProvider.notifier)
          .syncActiveTripFromApi(force: true);
      if (!mounted) return;
      final activeTrip = ref.read(driverRealtimeProvider).activeTrip;
      if (activeTrip?.tripId != tripId) return;
      if (!driverTripChatPhaseActive(activeTrip?.status)) return;
      if (tripChatSheetDisplayed) return;
      await openTripChatSheet(tripId: tripId);
    });
  }

  bool isForegroundState() {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    return lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  void syncKeepScreenOnForDriverMode() {
    final rt = ref.read(driverRealtimeProvider);
    final shouldKeepScreenOn = rt.online && isForegroundState();
    if (shouldKeepScreenOn == keepScreenOnApplied) return;
    keepScreenOnApplied = shouldKeepScreenOn;
    if (shouldKeepScreenOn) {
      unawaited(WakelockPlus.enable());
    } else {
      unawaited(WakelockPlus.disable());
    }
  }

  void syncHomeListEntrance(bool shouldShowMap) {
    if (!shouldShowMap) {
      final animate =
          prevShowMapForEntrance == null || prevShowMapForEntrance == true;
      if (animate) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) homeListEntrance.forward(from: 0);
        });
      }
      prevShowMapForEntrance = false;
    } else {
      prevShowMapForEntrance = true;
      homeListEntrance.reset();
    }
  }

  void syncActiveTripCardExpansion(DriverActiveTrip? activeTrip) {
    if (activeTrip == null) {
      activeTripCardExpansionTripId = null;
    } else if (activeTripCardExpansionTripId != activeTrip.tripId) {
      activeTripCardExpansionTripId = activeTrip.tripId;
      activeTripCardExpanded = true;
    }
  }

  Future<void> logout(BuildContext context) async {
    await ref
        .read(driverRealtimeProvider.notifier)
        .setOnline(false, forceOffline: true);
    ref.invalidate(driverOperationalProfileProvider);
    ref.invalidate(driverInternalToolsVisibleProvider);
    ref.invalidate(driverRealtimeProvider);
    await ref.read(driverLoginControllerProvider.notifier).logout();
    if (context.mounted) context.go('/login');
  }

  void handleAuthSessionExpired() {
    if (handlingAuthSessionExpired || !mounted) return;
    handlingAuthSessionExpired = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(l10n.driverOnlineErrorSessionExpiredReLogin),
          behavior: SnackBarBehavior.floating,
        ),
      );
      unawaited(logout(context));
    });
  }

  Future<void> maybeSuggestBackgroundLocationAfterOnline(
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    if (!context.mounted) return;
    try {
      final p = await Geolocator.checkPermission();
      if (p != LocationPermission.whileInUse) return;
      if (!context.mounted) return;

      final go = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text(l10n.driverHomeBackgroundLocationTitle),
            content: Text(l10n.driverHomeBackgroundLocationBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n.driverHomeBackgroundLocationLater),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l10n.driverHomeBackgroundLocationContinue),
              ),
            ],
          );
        },
      );
      if (go != true || !context.mounted) return;
      await Geolocator.requestPermission();
    } catch (e, st) {
      logUiVerbose('background location disclosure: $e $st');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      lastBackgroundAt = DateTime.now();
      return;
    }
    if (state == AppLifecycleState.resumed) {
      syncKeepScreenOnForDriverMode();
      ref.read(driverRealtimeProvider.notifier).resyncForegroundService();
      unawaited(maybePromptKeepActiveAfterBackground());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(driverRealtimeProvider.notifier)
            .touchReconnectIfWantedOnline();
      });
      return;
    }
    syncKeepScreenOnForDriverMode();
  }

  Future<void> maybePromptKeepActiveAfterBackground() async {
    if (!mounted || keepActivePromptOpen) return;
    final l10n = AppLocalizations.of(context);
    final rt = ref.read(driverRealtimeProvider);
    if (!rt.availabilitySwitchVisualOn) return;
    if (rt.activeTrip != null || rt.tripPendingRating != null) return;
    final lastBackgroundAt = this.lastBackgroundAt;
    if (lastBackgroundAt == null) return;
    if (DateTime.now().difference(lastBackgroundAt) <
        const Duration(minutes: 15)) {
      return;
    }

    keepActivePromptOpen = true;
    var keepActive = false;
    var secondsLeft = 120;
    Timer? countdown;

    if (!mounted) {
      keepActivePromptOpen = false;
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            countdown ??= Timer.periodic(const Duration(seconds: 1), (_) {
              if (!ctx.mounted) return;
              if (secondsLeft <= 0) {
                Navigator.of(ctx).pop();
                return;
              }
              setStateDialog(() => secondsLeft -= 1);
            });
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text(l10n.driverTripBackgroundPromptTitle),
              content: Text(
                l10n.driverTripBackgroundPromptBody(secondsLeft.toString()),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    keepActive = false;
                    Navigator.of(ctx).pop();
                  },
                  child: Text(l10n.driverTripBackgroundPromptDisconnect),
                ),
                FilledButton(
                  onPressed: () {
                    keepActive = true;
                    Navigator.of(ctx).pop();
                  },
                  child: Text(l10n.driverTripBackgroundPromptKeep),
                ),
              ],
            );
          },
        );
      },
    );
    countdown?.cancel();
    keepActivePromptOpen = false;
    this.lastBackgroundAt = null;

    if (!mounted) return;
    if (!keepActive) {
      await ref.read(driverRealtimeProvider.notifier).setOnline(false);
    }
  }

  Future<void> openExternalNavigation({
    required double lat,
    required double lng,
    required String label,
  }) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.driverTripSnackbarNavigationFailed(label))),
      );
    }
  }

  void showRatingSheet(BuildContext context, DriverActiveTrip trip) {
    unawaited(_presentRatingSheet(context, trip));
  }

  Future<void> _presentRatingSheet(
    BuildContext context,
    DriverActiveTrip trip,
  ) async {
    await ref.read(driverRealtimeProvider.notifier).refreshGoOnlineGuards();
    if (!mounted || !context.mounted) return;
    final rt = ref.read(driverRealtimeProvider);
    final showCredits = rt.showDriverCreditsBlockedNotice ||
        rt.showDriverCreditsLowWarning;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DriverTripRatingSheet(
        trip: trip,
        creditsNotice: showCredits
            ? DriverCreditsNoticeCard.fromRealtime(rt, afterTrip: true)
            : null,
        loadFeedbackCatalog: (stars) => ref
            .read(driverRealtimeProvider.notifier)
            .fetchDriverRatingFeedbackCatalog(stars: stars),
        onSubmitted: (stars, feedbackCodes) {
          Navigator.of(ctx).pop();
          isRatingSheetOpen = false;
          unawaited(() async {
            final claim = await ref
                .read(driverRealtimeProvider.notifier)
                .submitTripRating(
                  tripId: trip.tripId,
                  stars: stars,
                  feedbackCodes: feedbackCodes,
                );
            if (claim && mounted && context.mounted) {
              await _offerDriverTripClaim(
                context,
                tripId: trip.tripId,
                stars: stars,
                feedbackCodes: feedbackCodes,
              );
            }
            await ref.read(driverRealtimeProvider.notifier).clearTripPendingRating();
          }());
        },
        onSkipped: () {
          Navigator.of(ctx).pop();
          isRatingSheetOpen = false;
          unawaited(
            ref.read(driverRealtimeProvider.notifier).clearTripPendingRating(),
          );
        },
      ),
    );
    if (!mounted) return;
    isRatingSheetOpen = false;
    unawaited(
      ref.read(driverRealtimeProvider.notifier).clearTripPendingRating(),
    );
  }

  Future<void> _offerDriverTripClaim(
    BuildContext context, {
    required String tripId,
    required int stars,
    List<String> feedbackCodes = const [],
  }) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final send = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.driverTripClaimAsk),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 6,
          decoration: InputDecoration(hintText: l10n.driverTripClaimHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.driverTripClaimSkip),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.driverTripClaimSend),
          ),
        ],
      ),
    );
    final text = controller.text.trim();
    controller.dispose();
    if (send != true || text.length < 10 || !context.mounted) return;
    try {
      await ref.read(driverRealtimeProvider.notifier).submitTripClaim(
            tripId: tripId,
            message: text,
            stars: stars,
            feedbackCodes: feedbackCodes,
          );
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(l10n.driverTripClaimSent)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(l10n.driverTripClaimError)),
        );
      }
    }
  }

  Future<void> openTripChatSheet({required String tripId}) async {
    if (!driverTripChatPhaseActive(
      ref.read(driverRealtimeProvider).activeTrip?.status,
    )) {
      return;
    }
    tripChatSheetDisplayed = true;
    DriverTripChatVisibility.setOpen(tripId);
    try {
      await showDriverTripChatSheet(
        context: context,
        ref: ref,
        tripId: tripId,
      );
    } finally {
      tripChatSheetDisplayed = false;
      DriverTripChatVisibility.setOpen(null);
    }
  }

  void registerTripChatPhaseListener() {
    ref.listen<DriverRealtimeState>(driverRealtimeProvider, (previous, next) {
      final prevOk = driverTripChatPhaseActive(previous?.activeTrip?.status);
      final nextOk = driverTripChatPhaseActive(next.activeTrip?.status);
      if (prevOk && !nextOk && tripChatSheetDisplayed && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context, rootNavigator: true).maybePop();
        });
      }
    });
  }
}
