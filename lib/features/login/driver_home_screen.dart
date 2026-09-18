import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../gen_l10n/app_localizations.dart';
import '../../core/version/driver_app_version_gate.dart';
import '../home/driver_home_build_effects.dart';
import '../home/driver_home_lifecycle_mixin.dart';
import '../home/driver_home_online_errors.dart';
import '../home/driver_home_view_state.dart';
import '../home/widgets/driver_home_body.dart';
import '../home/widgets/driver_home_menu.dart';
import '../home/widgets/driver_offer_preview_view.dart';
import '../session/driver_operational_profile.dart';
import 'driver_realtime_controller.dart';
import 'driver_trip_offer.dart';

/// Orquestador del home conductor: wiring entre realtime, mapa y lista de ofertas.
class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen>
    with
        WidgetsBindingObserver,
        SingleTickerProviderStateMixin,
        DriverHomeLifecycleMixin {
  @override
  void initState() {
    super.initState();
    initDriverHomeLifecycle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(DriverAppVersionGate.runStartupCheck(context));
    });
  }

  @override
  void dispose() {
    disposeDriverHomeLifecycle();
    super.dispose();
  }

  Future<void> _reactivateAfterCompletedTrip() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(driverRealtimeProvider.notifier);
    notifier.clearActiveTrip();
    if (!mounted) return;
    if (!await driverPreOnlineGatesAllowOnline(
      context: context,
      ref: ref,
      l10n: l10n,
    )) {
      return;
    }
    if (!mounted) return;
    await notifier.setOnline(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final realtime = ref.watch(driverRealtimeProvider);

    registerTripChatPhaseListener();

    final blockOnlineForTrips = ref
        .watch(driverOperationalProfileProvider)
        .maybeWhen(
          data: (p) => p.needsVehicleRegistration,
          orElse: () => false,
        );

    final view = DriverHomeViewState.compute(
      realtime: realtime,
      wantsAvailReconnectFromNotifier: ref
          .read(driverRealtimeProvider.notifier)
          .wantsAvailabilitySessionReconnect,
    );

    syncActiveTripCardExpansion(realtime.activeTrip);
    syncHomeListEntrance(view.shouldShowMap);

    final errorMessage = driverHomeOnlineErrorMessage(
      l10n: l10n,
      realtime: realtime,
      onAuthSessionExpired: handleAuthSessionExpired,
    );
    final showProminentGateError =
        errorMessage != null &&
        driverIsProminentOnlineGateError(realtime.errorCode);
    final tripErrorMessage = driverHomeTripActionErrorMessage(
      l10n: l10n,
      realtime: realtime,
    );

    runDriverHomeBuildEffects(
      context: context,
      ref: ref,
      view: view,
      realtime: realtime,
      blockOnlineForTrips: blockOnlineForTrips,
      mounted: mounted,
      syncKeepScreenOn: syncKeepScreenOnForDriverMode,
      showRatingSheet: showRatingSheet,
      lastRatedTripId: lastRatedTripId,
      isRatingSheetOpen: isRatingSheetOpen,
      setLastRatedTripId: (id) => lastRatedTripId = id,
      setRatingSheetOpen: (open) => isRatingSheetOpen = open,
    );

    final activeTrip = realtime.activeTrip;

    if (activeTrip != null && previewOfferTripId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        closeOfferPreview();
      });
    }

    if (activeTrip == null || !view.shouldShowMap) {
      DriverTripOffer? previewOffer;
      final previewId = previewOfferTripId;
      if (previewId != null) {
        for (final offer in realtime.pendingOffers) {
          if (offer.tripId == previewId) {
            previewOffer = offer;
            break;
          }
        }
        if (previewOffer == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            closeOfferPreview();
          });
        }
      }

      return wrapWithVehicleFormOpeningOverlay(
        PopScope(
          canPop: previewOffer == null,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) closeOfferPreview();
          },
          child: Scaffold(
            appBar: AppBar(
              leading: previewOffer != null
                  ? IconButton(
                      tooltip: l10n.driverTripOfferPreviewBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: closeOfferPreview,
                    )
                  : null,
              title: Text(
                previewOffer != null
                    ? l10n.driverTripOfferDetailTitle
                    : l10n.driverHomeTitle,
              ),
              actions: [
                DriverHomeAppBarMenu(onLogout: () => logout(context)),
              ],
            ),
            body: previewOffer != null
                ? DriverOfferPreviewView(
                    offer: previewOffer,
                    isProcessing:
                        realtime.processingOfferTripId == previewOffer.tripId,
                    isProcessingAccept:
                        realtime.processingOfferTripId ==
                            previewOffer.tripId &&
                        realtime.processingIsAccept,
                    errorMessage: driverHomeOfferErrorMessage(
                      l10n: l10n,
                      perOfferCode: realtime
                          .offersErrorCodeByTripId[previewOffer.tripId],
                      fallbackMessage: realtime
                          .offersErrorMessageByTripId[previewOffer.tripId],
                    ),
                    onBack: closeOfferPreview,
                    onAccept: () => ref
                        .read(driverRealtimeProvider.notifier)
                        .acceptOffer(previewOffer!.tripId),
                  )
                : DriverHomeRequestsPanel(
                    localAuth: localAuth,
                    listFade: homeListFade,
                    listSlide: homeListSlide,
                    errorMessage: errorMessage,
                    showProminentGateError: showProminentGateError,
                    blockOnlineForTrips: blockOnlineForTrips,
                    onAfterOnlineEnabled:
                        maybeSuggestBackgroundLocationAfterOnline,
                    onPreviewOffer: openOfferPreview,
                  ),
          ),
        ),
      );
    }

    return wrapWithVehicleFormOpeningOverlay(
      Scaffold(
        appBar: AppBar(
          title: Text(l10n.driverTripInProgressTitle),
          actions: [DriverHomeAppBarMenu(onLogout: () => logout(context))],
        ),
        body: DriverHomeActiveTripView(
          trip: activeTrip,
          expanded: activeTripCardExpanded,
          onExpandedChanged: (v) => setState(() => activeTripCardExpanded = v),
          tripErrorMessage: tripErrorMessage,
          onOpenNavigation: openExternalNavigation,
          onReactivate: () => unawaited(_reactivateAfterCompletedTrip()),
          onOpenChat: () => openTripChatSheet(tripId: activeTrip.tripId),
        ),
      ),
    );
  }
}
