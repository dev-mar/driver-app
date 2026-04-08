import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_foundation.dart';
import '../../core/theme/app_motion.dart';
import '../../core/ui/driver_ui_states.dart';
import '../../core/ui/texi_circular_avatar.dart';
import '../../core/router/app_router.dart';
import '../../core/session/driver_internal_tools_gate.dart';
import '../../core/notifications/driver_fcm_navigation.dart';
import '../../core/config/locale_provider.dart';
import '../../gen_l10n/app_localizations.dart';
import '../session/driver_operational_profile.dart';
import 'driver_realtime_controller.dart';
import 'driver_active_trip_map.dart';
import 'driver_login_controller.dart';
import 'driver_online_auth_sheet.dart';

/// Errores al activar el switch "en línea" por permisos / GPS / notificaciones:
/// mostramos un hint breve solo en este contexto, no en otras pantallas.
const _kDriverOnlinePermissionHintCodes = <String>{
  'NO_GPS',
  'GPS_SERVICE_OFF',
  'NO_NOTIFICATIONS',
};

Widget _buildMiniProfileAvatar(DriverRealtimeState realtime) {
  const size = 52.0;
  final raw = realtime.driverPictureProfile?.trim() ?? '';
  if (raw.isEmpty) {
    return TexiCircularAvatar(
      diameter: size,
      child: Icon(
        Icons.directions_car_filled_rounded,
        color: AppColors.primary.withValues(alpha: 0.9),
        size: 28,
      ),
    );
  }

  // Si la firma ya expiró, evitamos renderizar una URL rota.
  final exp = realtime.driverPictureExpiresAt;
  if (exp != null && DateTime.now().isAfter(exp)) {
    return TexiCircularAvatar(
      diameter: size,
      child: Icon(
        Icons.directions_car_filled_rounded,
        color: AppColors.primary.withValues(alpha: 0.9),
        size: 28,
      ),
    );
  }

  Widget image;
  if (raw.startsWith('data:') && raw.contains('base64,')) {
    try {
      final i = raw.indexOf('base64,');
      final bytes = base64Decode(raw.substring(i + 7));
      image = Image.memory(bytes, width: size, height: size, fit: BoxFit.cover);
    } catch (_) {
      image = Icon(
        Icons.directions_car_filled_rounded,
        color: AppColors.primary.withValues(alpha: 0.9),
        size: 28,
      );
    }
  } else {
    image = Image.network(
      raw,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, error, stackTrace) => Icon(
        Icons.directions_car_filled_rounded,
        color: AppColors.primary.withValues(alpha: 0.9),
        size: 28,
      ),
    );
  }

  return TexiCircularAvatar(
    diameter: size,
    child: ClipOval(child: image),
  );
}

/// Home del conductor:
/// - Estado conectado / desconectado (switch grande).
/// - Resumen de sesiones y próximas solicitudes (placeholder).
class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {

  String? _lastRatedTripId;
  bool _isRatingSheetOpen = false;
  final LocalAuthentication _localAuth = LocalAuthentication();
  DateTime? _lastBackgroundAt;
  bool _keepActivePromptOpen = false;

  /// `true` = mapa visible; `false` = lista; `null` = primer frame.
  bool? _prevShowMapForEntrance;
  late final AnimationController _homeListEntrance;
  late final Animation<double> _homeListFade;
  late final Animation<Offset> _homeListSlide;
  bool _keepScreenOnApplied = false;
  int _lastHandledFcmTripOfferBump = 0;
  bool _handlingAuthSessionExpired = false;

  /// La tarjeta de viaje en mapa: el estado no depende de ticks de GPS ni rebuilds del mapa.
  String? _activeTripCardExpansionTripId;
  bool _activeTripCardExpanded = true;

  void _onFcmTripOfferOpenBump() {
    final bump = driverFcmTripOfferOpenBump.value;
    if (bump <= _lastHandledFcmTripOfferBump) return;
    _lastHandledFcmTripOfferBump = bump;
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).driverFcmOpenedTripOfferHint),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    driverFcmTripOfferOpenBump.addListener(_onFcmTripOfferOpenBump);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onFcmTripOfferOpenBump();
    });
    _homeListEntrance = AnimationController(
      vsync: this,
      duration: AppMotion.screenEntrance,
    );
    _homeListFade = CurvedAnimation(
      parent: _homeListEntrance,
      curve: AppMotion.standard,
    );
    _homeListSlide = Tween<Offset>(
      begin: Offset(0, AppMotion.slideDySubtle),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _homeListEntrance, curve: AppMotion.standard));
  }

  @override
  void dispose() {
    driverFcmTripOfferOpenBump.removeListener(_onFcmTripOfferOpenBump);
    unawaited(WakelockPlus.disable());
    _homeListEntrance.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool _isForegroundState() {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    return lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  void _syncKeepScreenOnForDriverMode() {
    final rt = ref.read(driverRealtimeProvider);
    final shouldKeepScreenOn = rt.online && _isForegroundState();
    if (shouldKeepScreenOn == _keepScreenOnApplied) return;
    _keepScreenOnApplied = shouldKeepScreenOn;
    if (shouldKeepScreenOn) {
      unawaited(WakelockPlus.enable());
    } else {
      unawaited(WakelockPlus.disable());
    }
  }

  void _syncHomeListEntrance(bool shouldShowMap) {
    if (!shouldShowMap) {
      final animate = _prevShowMapForEntrance == null || _prevShowMapForEntrance == true;
      if (animate) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _homeListEntrance.forward(from: 0);
        });
      }
      _prevShowMapForEntrance = false;
    } else {
      _prevShowMapForEntrance = true;
      _homeListEntrance.reset();
    }
  }

  Future<void> _logout(BuildContext context) async {
    await ref
        .read(driverRealtimeProvider.notifier)
        .setOnline(false, forceOffline: true);
    ref.invalidate(driverOperationalProfileProvider);
    ref.invalidate(driverInternalToolsVisibleProvider);
    // Nueva sesión = controlador nuevo; si no, el estado realtime (perfil, ofertas) del conductor anterior persiste en memoria.
    ref.invalidate(driverRealtimeProvider);
    await ref.read(driverLoginControllerProvider.notifier).logout();
    if (context.mounted) context.go('/login');
  }

  void _handleAuthSessionExpired() {
    if (_handlingAuthSessionExpired || !mounted) return;
    _handlingAuthSessionExpired = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        SnackBar(
          content: Text(l10n.driverOnlineErrorSessionExpiredReLogin),
          behavior: SnackBarBehavior.floating,
        ),
      );
      unawaited(_logout(context));
    });
  }

  /// Impide pasar a online si el perfil indica registro de vehículo pendiente.
  Future<bool> _vehicleGateAllowsOnline() async {
    final l10n = AppLocalizations.of(context);
    try {
      final p = await ref.read(driverOperationalProfileProvider.future);
      if (!p.needsVehicleRegistration) return true;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.driverHomeCannotGoOnlineWithoutVehicle),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    } catch (_) {
      return true;
    }
  }

  Future<bool> _authenticateBeforeGoingOnline(BuildContext context) async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDriverOnlineAuthPrompt(context, l10n);
    if (!confirmed) return false;

    HapticFeedback.lightImpact();

    final reasonBiometric = l10n.driverOnlineAuthReasonBiometric;
    final reasonDeviceCredential = l10n.driverOnlineAuthReasonDeviceCredential;
    final authErrorText = l10n.driverOnlineAuthVerifyFailed;

    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      if (!supported) return false;

      final available = canCheckBiometrics
          ? await _localAuth.getAvailableBiometrics()
          : const <BiometricType>[];

      // Prioridad 1: biometría (huella/face) si está configurada.
      if (available.isNotEmpty) {
        final ok = await _localAuth.authenticate(
          localizedReason: reasonBiometric,
          biometricOnly: true,
          sensitiveTransaction: true,
          persistAcrossBackgrounding: true,
        );
        if (ok) HapticFeedback.mediumImpact();
        return ok;
      }

      // Prioridad 2: credencial del dispositivo (PIN/patrón/clave).
      final ok = await _localAuth.authenticate(
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
              const Icon(Icons.shield_outlined, color: AppColors.textPrimary, size: 22),
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

  /// Divulgación previa (Google Play / App Store) antes de escalar de
  /// "solo en uso" a ubicación en segundo plano ("siempre" / Always).
  Future<void> _maybeSuggestBackgroundLocationAfterOnline(
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

      final title = l10n.driverHomeBackgroundLocationTitle;
      final body = l10n.driverHomeBackgroundLocationBody;
      final later = l10n.driverHomeBackgroundLocationLater;
      final cont = l10n.driverHomeBackgroundLocationContinue;

      final go = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(later),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(cont),
              ),
            ],
          );
        },
      );
      if (go != true || !context.mounted) return;
      await Geolocator.requestPermission();
    } catch (e, st) {
      debugPrint('[DriverHome] background location disclosure: $e $st');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _lastBackgroundAt = DateTime.now();
      return;
    }
    if (state == AppLifecycleState.resumed) {
      _syncKeepScreenOnForDriverMode();
      unawaited(_maybePromptKeepActiveAfterBackground());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(driverRealtimeProvider.notifier).touchReconnectIfWantedOnline();
      });
      return;
    }
    _syncKeepScreenOnForDriverMode();
  }

  Future<void> _maybePromptKeepActiveAfterBackground() async {
    if (!mounted || _keepActivePromptOpen) return;
    final l10n = AppLocalizations.of(context);
    final rt = ref.read(driverRealtimeProvider);
    if (!rt.online) return;
    if (rt.activeTrip != null || rt.tripPendingRating != null) return;
    final lastBackgroundAt = _lastBackgroundAt;
    if (lastBackgroundAt == null) return;
    final elapsed = DateTime.now().difference(lastBackgroundAt);
    if (elapsed < const Duration(minutes: 15)) return;

    _keepActivePromptOpen = true;
    bool keepActive = false;
    int secondsLeft = 120;
    Timer? countdown;

    if (!mounted) {
      _keepActivePromptOpen = false;
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
              setStateDialog(() {
                secondsLeft -= 1;
              });
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
    _keepActivePromptOpen = false;
    _lastBackgroundAt = null;

    if (!mounted) return;
    if (!keepActive) {
      await ref.read(driverRealtimeProvider.notifier).setOnline(false);
    }
  }

  Future<void> _openNavigation({
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
        SnackBar(
          content: Text(l10n.driverTripSnackbarNavigationFailed(label)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final realtime = ref.watch(driverRealtimeProvider);
    final online = realtime.online;
    final connecting = realtime.connecting;
    final switchVisualOn = realtime.availabilitySwitchVisualOn;
    final pendingOffers = realtime.pendingOffers;
    final activeTrip = realtime.activeTrip;
    final tripPendingRating = realtime.tripPendingRating;
    final ignoreActiveTripRestoreTripId =
        realtime.ignoreActiveTripRestoreTripId;
    final ignoreActiveTripRestoreUntilMs =
        realtime.ignoreActiveTripRestoreUntilMs;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    // Si estamos en fase de calificación (`tripPendingRating`) o dentro de la
    // ventana de "ignore" post-calificación, forzamos que no se muestre el
    // mapa aunque el backend restaure accidentalmente un `activeTrip` tardío.
    final bool shouldIgnoreActiveTripRestore = ignoreActiveTripRestoreTripId !=
            null &&
        ignoreActiveTripRestoreUntilMs != null &&
        nowMs <= ignoreActiveTripRestoreUntilMs &&
        activeTrip?.tripId == ignoreActiveTripRestoreTripId;

    final bool shouldShowMap = activeTrip != null &&
        (tripPendingRating == null ||
            tripPendingRating.tripId != activeTrip.tripId) &&
        !shouldIgnoreActiveTripRestore;

    if (activeTrip == null) {
      _activeTripCardExpansionTripId = null;
    } else if (_activeTripCardExpansionTripId != activeTrip.tripId) {
      _activeTripCardExpansionTripId = activeTrip.tripId;
      _activeTripCardExpanded = true;
    }

    _syncHomeListEntrance(shouldShowMap);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncKeepScreenOnForDriverMode();
    });

    // Si el socket/ciclo cayó mientras calificas, reintentamos activar "online"
    // automáticamente para que el switch quede activo sin intervención manual.
    final bool shouldAttemptAutoReconnect = activeTrip != null ||
        tripPendingRating != null ||
        shouldIgnoreActiveTripRestore;

    final blockOnlineForTrips = ref
        .watch(driverOperationalProfileProvider)
        .maybeWhen(data: (p) => p.needsVehicleRegistration, orElse: () => false);

    if (shouldAttemptAutoReconnect &&
        !online &&
        !connecting &&
        !blockOnlineForTrips) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(driverRealtimeProvider.notifier).touchReconnectIfHasActiveWork();
      });
    }

    final wantsAvailReconnect =
        ref.read(driverRealtimeProvider.notifier).wantsAvailabilitySessionReconnect;
    if (wantsAvailReconnect &&
        !online &&
        !connecting &&
        !blockOnlineForTrips &&
        activeTrip == null &&
        tripPendingRating == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(driverRealtimeProvider.notifier).touchReconnectIfWantedOnline();
      });
    }

    // Cuando el viaje llega a `completed`, el controlador guarda el trip en
    // `tripPendingRating` y limpia el mapa. Aquí abrimos la hoja encima
    // de la pantalla de solicitudes.
    if (tripPendingRating != null &&
        tripPendingRating.tripId != _lastRatedTripId &&
        !_isRatingSheetOpen) {
      _lastRatedTripId = tripPendingRating.tripId;
      _isRatingSheetOpen = true;
      final tripToRate = tripPendingRating;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showRatingSheet(context, tripToRate);
      });
    }

    String? errorMessage;
    switch (realtime.errorCode) {
      case 'AUTH':
        errorMessage = l10n.driverOnlineErrorSessionExpiredReLogin;
        _handleAuthSessionExpired();
        break;
      case 'NO_INTERNET':
        errorMessage = l10n.driverOnlineErrorNoInternet;
        break;
      case 'NO_GPS':
        errorMessage = l10n.driverOnlineErrorNoGps;
        break;
      case 'GPS_SERVICE_OFF':
        errorMessage = l10n.driverOnlineErrorGpsServiceOff;
        break;
      case 'NO_NOTIFICATIONS':
        errorMessage = l10n.driverOnlineErrorNoNotifications;
        break;
      case 'NO_TOKEN':
        errorMessage = l10n.driverOnlineErrorNoToken;
        break;
      case 'SOCKET':
        errorMessage = l10n.driverOnlineErrorSocket;
        break;
      case 'DRIVER_VEHICLE_REQUIRED':
        errorMessage = l10n.driverOnlineErrorVehicleRequired;
        break;
      case 'UNKNOWN':
        errorMessage = l10n.driverOnlineErrorUnknown;
        break;
      case 'ACTIVE_TRIP_CANT_GO_OFFLINE':
        errorMessage = l10n.driverOnlineErrorActiveTripCantGoOffline;
        break;
      case 'SOCKET_RECONNECTING':
        errorMessage = l10n.driverOnlineErrorReconnecting;
        break;
      case 'RBAC_FORBIDDEN':
        errorMessage = l10n.driverOnlineErrorRbacForbidden;
        break;
      case 'RBAC_NO_IDENTITY':
      case 'RBAC_NO_AUTH':
        errorMessage = l10n.driverOnlineErrorRbacSession;
        break;
      case 'RBAC_RESOLVE':
      case 'RBAC_ERROR':
      case 'RBAC_CONFIG':
        errorMessage = l10n.driverOnlineErrorRbacTechnical;
        break;
    }
    final String? tripErrorMessage = switch (realtime.tripErrorCode) {
      'TRIP_UPDATE_FAILED' => l10n.driverTripErrorGeneric,
      _ => realtime.tripErrorMessage,
    };
    final bool isRestoring = !online && switchVisualOn;
    final String connectionLabel = connecting
        ? l10n.driverHomeMiniConnecting
        : online
            ? l10n.driverHomeMiniStatusOnline
            : isRestoring
                ? l10n.driverHomeMiniStatusRestoringConnection
                : l10n.driverHomeMiniStatusOffline;
    final IconData connectionIcon = connecting
        ? Icons.sync_rounded
        : online
            ? Icons.verified_rounded
            : isRestoring
                ? Icons.autorenew_rounded
                : Icons.pause_circle_outline_rounded;
    final Color connectionColor = connecting
        ? AppColors.primary
        : online
            ? AppColors.success
            : isRestoring
                ? AppColors.primary
                : AppColors.textSecondary;

    final showInternalTools =
        ref.watch(driverInternalToolsVisibleProvider).valueOrNull == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          shouldShowMap ? l10n.driverTripInProgressTitle : l10n.driverHomeTitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language_rounded),
            onPressed: () => _showLanguageMenu(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'profile') context.goNamed(AppRouter.profile);
              if (value == 'registered_images') {
                context.pushNamed(AppRouter.registeredImages);
              }
              if (value == 'add_vehicle') {
                context.pushNamed(
                  AppRouter.register,
                  extra: {'addVehicleOnly': true},
                );
              }
              if (value == 'logout') _logout(context);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Text(l10n.driverProfileMenu),
              ),
              PopupMenuItem(
                value: 'add_vehicle',
                child: Text(l10n.driverHomeMenuAddVehicle),
              ),
              if (showInternalTools)
                const PopupMenuItem(
                  value: 'registered_images',
                  child: Text('Imágenes registradas'),
                ),
              PopupMenuItem(value: 'logout', child: Text(l10n.driverLogout)),
            ],
          ),
        ],
      ),
      body: shouldShowMap
          ? DriverActiveTripMapView(
              driverLat: realtime.driverLat,
              driverLng: realtime.driverLng,
              trip: activeTrip,
              bottomCard: _RetractableTripCard(
                trip: activeTrip,
                expanded: _activeTripCardExpanded,
                onExpandedChanged: (v) => setState(() => _activeTripCardExpanded = v),
                processingAction: realtime.processingTripAction,
                errorMessage: tripErrorMessage,
                onMarkArrived: () => ref
                    .read(driverRealtimeProvider.notifier)
                    .markArrived(),
                onStartTrip: () => ref
                    .read(driverRealtimeProvider.notifier)
                    .startTrip(),
                onCompleteTrip: () => ref
                    .read(driverRealtimeProvider.notifier)
                    .completeTrip(),
                onNavigateToPickup: () {
                  if (activeTrip.pickupLat == null || activeTrip.pickupLng == null) return;
                  unawaited(
                    _openNavigation(
                      lat: activeTrip.pickupLat!,
                      lng: activeTrip.pickupLng!,
                      label: 'origen',
                    ),
                  );
                },
                onNavigateToDestination: () {
                  if (activeTrip.destinationLat == null ||
                      activeTrip.destinationLng == null) {
                    return;
                  }
                  unawaited(
                    _openNavigation(
                      lat: activeTrip.destinationLat!,
                      lng: activeTrip.destinationLng!,
                      label: 'destino',
                    ),
                  );
                },
                onReactivate: () {
                  unawaited(() async {
                    final notifier =
                        ref.read(driverRealtimeProvider.notifier);
                    notifier.clearActiveTrip();
                    if (!await _vehicleGateAllowsOnline()) return;
                    await notifier.setOnline(true);
                  }());
                },
              ),
            )
          : FadeTransition(
              opacity: _homeListFade,
              child: SlideTransition(
                position: _homeListSlide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
            if (blockOnlineForTrips) ...[
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
                          Icon(Icons.directions_car_outlined,
                              color: AppColors.primary, size: 22),
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
                          context.goNamed(AppRouter.register, extra: true);
                        },
                        child: Text(l10n.driverHomeVehicleRegistrationCta),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            // Mini perfil: nombre, vehículo y valoración desde connection:ack + estado
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
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
                  _buildMiniProfileAvatar(realtime),
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
                                child: Icon(connectionIcon, size: 14, color: connectionColor),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  connectionLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary.withValues(alpha: 0.97),
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
                              _connectionPhaseChip(
                                icon: Icons.sync_rounded,
                                label: l10n.driverHomeMiniConnecting,
                                active: connecting,
                              ),
                              _connectionPhaseChip(
                                icon: Icons.autorenew_rounded,
                                label: l10n.driverHomeMiniStatusRestoringConnection,
                                active: isRestoring,
                              ),
                              _connectionPhaseChip(
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
                            : (value) async {
                                if (value && !online) {
                                  if (!await _vehicleGateAllowsOnline()) return;
                                  if (!context.mounted) return;
                                  final rtNow = ref.read(driverRealtimeProvider);
                                  final skipLocalAuth = rtNow.activeTrip != null ||
                                      rtNow.tripPendingRating != null;
                                  if (!skipLocalAuth) {
                                    final ok =
                                        await _authenticateBeforeGoingOnline(
                                      context,
                                    );
                                    if (!ok) return;
                                  }
                                }
                                if (!context.mounted) return;
                                await ref
                                    .read(driverRealtimeProvider.notifier)
                                    .setOnline(value);
                                if (value && context.mounted) {
                                  final s = ref.read(driverRealtimeProvider);
                                  if (s.online &&
                                      (s.errorCode == null || s.errorCode!.isEmpty)) {
                                    unawaited(
                                      _maybeSuggestBackgroundLocationAfterOnline(
                                        context,
                                      ),
                                    );
                                  }
                                }
                              },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              DriverInlineError(
                message: errorMessage,
              ),
              if (realtime.errorCode != null &&
                  _kDriverOnlinePermissionHintCodes
                      .contains(realtime.errorCode)) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                  child: Text(
                    l10n.driverHomeOnlineRequirementsHint,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.textSecondary.withValues(alpha: 0.88),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 20),
            if (pendingOffers.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(AppFoundation.radiusSm),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: const Color(0xFF9FB2CB),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.driverHomeRequestsTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.7),
                      ),
                    ),
                    child: Text(
                      '${pendingOffers.length}',
                      style: TextStyle(
                        color: AppColors.textPrimary.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: pendingOffers.length,
                  separatorBuilder: (context, _) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final offer = pendingOffers[index];
                    String? offerErrorMessage = realtime.offersErrorMessage;
                    switch (realtime.offersErrorCode) {
                      case 'NO_CONNECTION':
                        offerErrorMessage = l10n.driverOfferErrorNoConnection;
                        break;
                      case 'OFFER_EXPIRED':
                        offerErrorMessage = l10n.driverOfferErrorExpired;
                        break;
                      case 'TRIP_ALREADY_PROCESSED':
                      case 'TRIP_NOT_AVAILABLE':
                      case 'TRIP_TAKEN':
                      case 'OFFER_ALREADY_TAKEN':
                        offerErrorMessage = l10n.driverOfferErrorTaken;
                        break;
                      case 'RBAC_FORBIDDEN':
                        offerErrorMessage = l10n.driverOnlineErrorRbacForbidden;
                        break;
                      case 'RBAC_NO_IDENTITY':
                      case 'RBAC_NO_AUTH':
                        offerErrorMessage = l10n.driverOnlineErrorRbacSession;
                        break;
                      case 'RBAC_RESOLVE':
                      case 'RBAC_ERROR':
                      case 'RBAC_CONFIG':
                        offerErrorMessage = l10n.driverOnlineErrorRbacTechnical;
                        break;
                    }
                    return _TripOfferCard(
                      l10n: l10n,
                      offer: offer,
                      isProcessing:
                          realtime.processingOfferTripId == offer.tripId,
                      isProcessingAccept:
                          realtime.processingOfferTripId == offer.tripId &&
                              realtime.processingIsAccept,
                      errorMessage: offerErrorMessage,
                      onAccept: () => ref
                          .read(driverRealtimeProvider.notifier)
                          .acceptOffer(offer.tripId),
                      onReject: () => ref
                          .read(driverRealtimeProvider.notifier)
                          .rejectOffer(offer.tripId),
                    );
                  },
                ),
              ),
            ] else ...[
              Text(
                l10n.driverHomeRequestsTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: DriverEmptyStateCard(
                  message: l10n.driverHomeRequestsEmpty,
                  icon: Icons.hourglass_empty_rounded,
                ),
              ),
            ],
          ],
                  ),
                ),
              ),
            ),
    );
  }

  void _showRatingSheet(BuildContext context, DriverActiveTrip trip) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _RatingSheetContent(
        trip: trip,
        onSubmitted: () {
          Navigator.of(ctx).pop();
          _isRatingSheetOpen = false;
          ref.read(driverRealtimeProvider.notifier).clearTripPendingRating();
        },
        onSkipped: () {
          Navigator.of(ctx).pop();
          _isRatingSheetOpen = false;
          ref.read(driverRealtimeProvider.notifier).clearTripPendingRating();
        },
      ),
    ).then((_) {
      if (!mounted) return;
      _isRatingSheetOpen = false;
      ref.read(driverRealtimeProvider.notifier).clearTripPendingRating();
    });
  }

  void _showLanguageMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.settingsLanguage,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.translate),
              title: Text(l10n.languageSpanish),
              onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('es');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.translate),
              title: Text(l10n.languageEnglish),
              onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('en');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _connectionPhaseChip({
  required IconData icon,
  required String label,
  required bool active,
}) {
  final bg = active
      ? AppColors.primary.withValues(alpha: 0.18)
      : AppColors.surfaceCard.withValues(alpha: 0.72);
  final fg = active ? AppColors.primary : AppColors.textSecondary;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: active
            ? AppColors.primary.withValues(alpha: 0.45)
            : AppColors.border.withValues(alpha: 0.5),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: fg),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ],
    ),
  );
}

/// Contenido del sheet de calificación (premium): pasajero + estrellas.
class _RatingSheetContent extends StatefulWidget {
  final VoidCallback onSubmitted;
  final VoidCallback onSkipped;
  final DriverActiveTrip? trip;

  const _RatingSheetContent({
    required this.onSubmitted,
    required this.onSkipped,
    this.trip,
  });

  @override
  State<_RatingSheetContent> createState() => _RatingSheetContentState();
}

class _RatingSheetContentState extends State<_RatingSheetContent>
    with SingleTickerProviderStateMixin {
  int _rating = 0;
  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: AppMotion.sheetEntrance,
    );
    _fade = CurvedAnimation(parent: _entrance, curve: AppMotion.standard);
    _slide = Tween<Offset>(
      begin: Offset(0, AppMotion.slideDySubtle),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrance, curve: AppMotion.standard));
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trip = widget.trip;
    final passengerName = (trip?.passengerName ?? '').isNotEmpty
        ? trip!.passengerName!
        : l10n.driverTripRatingPassengerDefault;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.55),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 28,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.border.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary.withValues(alpha: 0.75),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: AppColors.onPrimary,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.driverTripRatingHeaderTitle,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.driverTripRatingTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.driverTripRatingSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: AppColors.textSecondary.withValues(alpha: 0.96),
                          ),
                        ),
                        if (trip != null) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: AppColors.background,
                              border: Border.all(
                                color: AppColors.border.withValues(alpha: 0.65),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor:
                                      AppColors.primary.withValues(alpha: 0.2),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        passengerName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (trip.passengerRating != null) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star_rounded,
                                              size: 18,
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.95),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              trip.passengerRating!
                                                  .toStringAsFixed(1),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Text(
                          l10n.driverTripRatingYourRating,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final filled = _rating >= index + 1;
                            return IconButton(
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _rating = index + 1;
                                });
                              },
                              icon: Icon(
                                filled
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 38,
                                color: filled
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _rating == 0
                              ? null
                              : () {
                                  HapticFeedback.lightImpact();
                                  widget.onSubmitted();
                                },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            l10n.driverTripRatingSubmit,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            widget.onSkipped();
                          },
                          child: Text(
                            l10n.driverTripRatingSkip,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Panel inferior retraíble: colapsado muestra barra con estado y precio; expandido muestra detalle del viaje.
class _RetractableTripCard extends StatelessWidget {
  final DriverActiveTrip trip;
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
  final String? processingAction;
  final String? errorMessage;
  final VoidCallback onMarkArrived;
  final VoidCallback onStartTrip;
  final VoidCallback onCompleteTrip;
  final VoidCallback onNavigateToPickup;
  final VoidCallback onNavigateToDestination;
  final VoidCallback onReactivate;

  const _RetractableTripCard({
    required this.trip,
    required this.expanded,
    required this.onExpandedChanged,
    required this.processingAction,
    required this.errorMessage,
    required this.onMarkArrived,
    required this.onStartTrip,
    required this.onCompleteTrip,
    required this.onNavigateToPickup,
    required this.onNavigateToDestination,
    required this.onReactivate,
  });

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'accepted':
        return l10n.driverTripStatusAccepted;
      case 'arrived':
        return l10n.driverTripStatusArrived;
      case 'started':
      case 'in_trip':
        return l10n.driverTripStatusStarted;
      case 'completed':
        return l10n.driverTripStatusCompleted;
      case 'cancelled':
        return l10n.driverTripStatusCancelled;
      default:
        return l10n.driverTripStatusInProgress;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Un solo árbol con Column + AnimatedSize evita clipping/erratas de altura
    // al alternar expandido/colapsado (antes solo quedaban visibles los botones inferiores).
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (expanded) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onExpandedChanged(false),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _ActiveTripCard(
              trip: trip,
              processingAction: processingAction,
              errorMessage: errorMessage,
              onMarkArrived: onMarkArrived,
              onStartTrip: onStartTrip,
              onCompleteTrip: onCompleteTrip,
              onNavigateToPickup: onNavigateToPickup,
              onNavigateToDestination: onNavigateToDestination,
              onReactivate: onReactivate,
            ),
          ] else
            Material(
              color: AppColors.surfaceCard.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
              child: InkWell(
                onTap: () => onExpandedChanged(true),
                borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.directions_car_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _statusLabel(l10n, trip.status),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            if (trip.estimatedPrice != null)
                              Text(
                                '\$${trip.estimatedPrice!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: AppColors.textSecondary,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Botones de apertura de navegación externa con pulso suave y copy que clarifica el gesto.
class _AssistedTripNavButtons extends StatefulWidget {
  const _AssistedTripNavButtons({
    required this.showPickup,
    required this.showDestination,
    required this.l10n,
    required this.onNavigateToPickup,
    required this.onNavigateToDestination,
  });

  final bool showPickup;
  final bool showDestination;
  final AppLocalizations l10n;
  final VoidCallback onNavigateToPickup;
  final VoidCallback onNavigateToDestination;

  @override
  State<_AssistedTripNavButtons> createState() => _AssistedTripNavButtonsState();
}

class _AssistedTripNavButtonsState extends State<_AssistedTripNavButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _t = CurvedAnimation(parent: _pulse, curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.maps_ugc_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.l10n.driverTripNavAssistedTitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.l10n.driverTripNavAssistedSubtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.25,
                      color:
                          AppColors.textSecondary.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (widget.showPickup) ...[
              Expanded(
                child: AnimatedBuilder(
                  animation: _t,
                  builder: (context, child) {
                    return _assistedNavPill(
                      context,
                      glow: 0.28 + 0.55 * _t.value,
                      iconScale: 1.0 + 0.09 * _t.value,
                      isPickup: true,
                      title: widget.l10n.driverTripNavigatePickup,
                      subtitle: widget.l10n.tripOrigin,
                      icon: Icons.near_me_rounded,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onNavigateToPickup();
                      },
                    );
                  },
                ),
              ),
            ],
            if (widget.showPickup && widget.showDestination)
              const SizedBox(width: 10),
            if (widget.showDestination) ...[
              Expanded(
                child: AnimatedBuilder(
                  animation: _t,
                  builder: (context, child) {
                    return _assistedNavPill(
                      context,
                      glow: 0.22 + 0.5 * (1 - _t.value),
                      iconScale: 1.0 + 0.09 * (1 - _t.value),
                      isPickup: false,
                      title: widget.l10n.driverTripNavigateDestination,
                      subtitle: widget.l10n.tripDestination,
                      icon: Icons.turn_right_rounded,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onNavigateToDestination();
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _assistedNavPill(
    BuildContext context, {
    required double glow,
    required double iconScale,
    required bool isPickup,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final borderColor =
        AppColors.primary.withValues(alpha: isPickup ? glow * 0.55 : glow * 0.7);
    final bg = isPickup
        ? AppColors.primary.withValues(alpha: 0.12 + 0.06 * glow)
        : AppColors.primary.withValues(alpha: 0.88 + 0.06 * glow);
    final fg = isPickup ? AppColors.textPrimary : AppColors.onPrimary;
    final subFg = isPickup
        ? AppColors.textSecondary.withValues(alpha: 0.9)
        : AppColors.onPrimary.withValues(alpha: 0.88);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: isPickup ? 1.25 : 1.15,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isPickup ? 0.08 : 0.2),
                blurRadius: 10 + 6 * glow,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            child: Row(
              children: [
                Transform.scale(
                  scale: iconScale,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isPickup
                              ? AppColors.primary
                              : AppColors.onPrimary)
                          .withValues(alpha: isPickup ? 0.18 : 0.22),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: isPickup ? AppColors.primary : AppColors.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: fg,
                                height: 1.15,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 16,
                            color: subFg,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: subFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveTripCard extends StatelessWidget {
  final DriverActiveTrip trip;
  final String? processingAction;
  final String? errorMessage;
  final VoidCallback onMarkArrived;
  final VoidCallback onStartTrip;
  final VoidCallback onCompleteTrip;
  final VoidCallback onNavigateToPickup;
  final VoidCallback onNavigateToDestination;
  final VoidCallback onReactivate;

  const _ActiveTripCard({
    required this.trip,
    required this.processingAction,
    required this.errorMessage,
    required this.onMarkArrived,
    required this.onStartTrip,
    required this.onCompleteTrip,
    required this.onNavigateToPickup,
    required this.onNavigateToDestination,
    required this.onReactivate,
  });

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'accepted':
        return l10n.driverTripStatusAccepted;
      case 'arrived':
        return l10n.driverTripStatusArrived;
      case 'started':
      case 'in_trip':
        return l10n.driverTripStatusStarted;
      case 'completed':
        return l10n.driverTripStatusCompleted;
      case 'cancelled':
        return l10n.driverTripStatusCancelled;
      default:
        return l10n.driverTripStatusInProgress;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isProcessing = processingAction != null;
    final canAct = !isProcessing &&
        trip.status != 'completed' &&
        trip.status != 'cancelled';
    final hasPassenger = trip.passengerName != null && trip.passengerName!.isNotEmpty;
    final hasPickupCoords = trip.pickupLat != null && trip.pickupLng != null;
    final hasDestCoords = trip.destinationLat != null && trip.destinationLng != null;
    final hasOriginLine = (trip.originAddress != null && trip.originAddress!.isNotEmpty) ||
        hasPickupCoords;
    final hasDestLine = (trip.destinationAddress != null && trip.destinationAddress!.isNotEmpty) ||
        hasDestCoords;
    final hasMetrics =
        trip.tripDistanceKm != null || trip.etaToDestinationMinutes != null;
    final hasRouteDetail = hasPassenger || hasMetrics || hasOriginLine || hasDestLine;

    Widget section({
      required Widget child,
      EdgeInsetsGeometry padding = const EdgeInsets.all(12),
    }) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppFoundation.radiusSm),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.55),
          ),
        ),
        child: child,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.65),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          section(
            child: Row(
              children: [
                Icon(
                  Icons.directions_car_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusLabel(l10n, trip.status),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      if (trip.estimatedPrice != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          l10n.driverTripEstimatedPrice(
                            '\$${trip.estimatedPrice!.toStringAsFixed(2)}',
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (hasRouteDetail) ...[
            const SizedBox(height: 10),
            section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (hasPassenger)
                    Row(
                      children: [
                        Icon(Icons.person_rounded, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trip.passengerName!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        if (trip.passengerRating != null) ...[
                          Icon(Icons.star_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 2),
                          Text(
                            trip.passengerRating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  if (hasPassenger && (hasOriginLine || hasDestLine || hasMetrics))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
                    ),
                  if (trip.originAddress != null && trip.originAddress!.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.place_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trip.originAddress!,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  else if (hasPickupCoords)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.place_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${l10n.driverMapPickupPoint}: ${trip.pickupLat!.toStringAsFixed(5)}, ${trip.pickupLng!.toStringAsFixed(5)}',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (hasOriginLine && hasDestLine) const SizedBox(height: 6),
                  if (trip.destinationAddress != null && trip.destinationAddress!.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.flag_rounded, size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trip.destinationAddress!,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  else if (hasDestCoords)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.flag_rounded, size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${l10n.driverMapDestinationPoint}: ${trip.destinationLat!.toStringAsFixed(5)}, ${trip.destinationLng!.toStringAsFixed(5)}',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if ((hasOriginLine || hasDestLine) && hasMetrics)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
                    ),
                  if (hasMetrics)
                    Row(
                      children: [
                        if (trip.tripDistanceKm != null) ...[
                          Icon(Icons.straighten_rounded, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${trip.tripDistanceKm!.toStringAsFixed(1)} km',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                        if (trip.tripDistanceKm != null &&
                            trip.etaToDestinationMinutes != null)
                          const SizedBox(width: 14),
                        if (trip.etaToDestinationMinutes != null) ...[
                          Icon(Icons.schedule_rounded, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '~${trip.etaToDestinationMinutes!.round()} min',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ],
          if ((trip.pickupLat != null && trip.pickupLng != null) ||
              (trip.destinationLat != null && trip.destinationLng != null)) ...[
            const SizedBox(height: 10),
            section(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: _AssistedTripNavButtons(
                showPickup:
                    trip.pickupLat != null && trip.pickupLng != null,
                showDestination: trip.destinationLat != null &&
                    trip.destinationLng != null,
                l10n: l10n,
                onNavigateToPickup: onNavigateToPickup,
                onNavigateToDestination: onNavigateToDestination,
              ),
            ),
          ],
          if (errorMessage != null && errorMessage!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ],
          if (trip.status == 'accepted' && canAct) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: processingAction == 'arrived' ? null : onMarkArrived,
                icon: processingAction == 'arrived'
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.location_on_rounded, size: 20),
                label: Text(l10n.driverTripArrivedButton),
              ),
            ),
          ],
          if (trip.status == 'arrived' && canAct) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: processingAction == 'started' ? null : onStartTrip,
                icon: processingAction == 'started'
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.play_arrow_rounded, size: 24),
                label: Text(l10n.driverTripStartButton),
              ),
            ),
          ],
          if ((trip.status == 'started' || trip.status == 'in_trip') &&
              canAct) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    processingAction == 'completed' ? null : onCompleteTrip,
                icon: processingAction == 'completed'
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.check_circle_rounded, size: 22),
                label: Text(l10n.driverTripCompleteButton),
              ),
            ),
          ],
          if (trip.status == 'completed') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onReactivate,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l10n.driverTripReactivate,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TripOfferCard extends StatelessWidget {
  final AppLocalizations l10n;
  final DriverTripOffer offer;
  final bool isProcessing;
  final bool isProcessingAccept;
  final String? errorMessage;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _TripOfferCard({
    required this.l10n,
    required this.offer,
    required this.isProcessing,
    required this.isProcessingAccept,
    required this.errorMessage,
    required this.onAccept,
    required this.onReject,
  });

  static String _formatPrice(double? value) {
    if (value == null) return '—';
    if (value.truncateToDouble() == value) return '\$${value.toInt()}';
    return '\$${value.toStringAsFixed(2)}';
  }

  static String _formatDistance(double? km) {
    if (km == null) return '—';
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  static String _formatDurationWithUnit(
    BuildContext context,
    double? minutes,
  ) {
    if (minutes == null) return '—';
    final m = minutes.round();
    if (m <= 0) return '<1 min';
    if (m < 60) return '$m min';
    final h = m ~/ 60;
    final rem = m % 60;
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'es') {
      if (rem == 0) return '$h h';
      return '$h h ${rem.toString().padLeft(2, '0')} min';
    }
    if (rem == 0) return '$h h';
    return '$h h ${rem.toString().padLeft(2, '0')} min';
  }

  @override
  Widget build(BuildContext context) {
    final hasPrice = offer.offeredPrice != null;
    final hasRouteEta = offer.etaToDestinationMinutes != null;
    final hasTripKm = offer.tripDistanceKm != null;
    final hasPassenger = (offer.passengerName ?? '').isNotEmpty;
    final hasRating = offer.passengerRating != null;
    final showChips = hasRouteEta || hasTripKm;

    final originText = (offer.originAddress ?? '').isNotEmpty
        ? offer.originAddress!
        : l10n.tripOrigin;
    final destText = (offer.destinationAddress ?? '').isNotEmpty
        ? offer.destinationAddress!
        : l10n.tripDestination;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.7),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.45),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            hasPrice
                                ? _formatPrice(offer.offeredPrice)
                                : l10n.driverTripOfferPriceTbd,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            l10n.driverTripOfferBadgeNew,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF9FB2CB),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (showChips) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (hasRouteEta)
                            _OfferMetricChip(
                              icon: Icons.schedule_rounded,
                              label: _formatDurationWithUnit(
                                context,
                                offer.etaToDestinationMinutes,
                              ),
                              large: true,
                            ),
                          if (hasTripKm)
                            _OfferMetricChip(
                              icon: Icons.route_rounded,
                              label: _formatDistance(offer.tripDistanceKm),
                              large: true,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _OriginRow(
                      originText: originText,
                      distanceToPickupKm: offer.distanceToPickupKm,
                    ),
                    const SizedBox(height: 6),
                    _CompactAddressLine(
                      icon: Icons.flag_rounded,
                      text: destText,
                      iconColor: AppColors.primary,
                    ),
                    const SizedBox(height: 10),
                    if (hasPassenger || hasRating) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.38),
                          borderRadius: BorderRadius.circular(AppFoundation.radiusSm),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.55),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_rounded,
                              size: 18,
                              color: AppColors.primary.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                offer.passengerName ??
                                    l10n.driverTripRatingPassengerDefault,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasRating) ...[
                              Icon(Icons.star_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                offer.passengerRating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(fontSize: 11, color: AppColors.error),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isProcessing ? null : onReject,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: (isProcessing && !isProcessingAccept)
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.error,
                                    ),
                                  )
                                : Text(
                                    l10n.driverTripReject,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: isProcessing ? null : onAccept,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isProcessing && isProcessingAccept
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.onPrimary,
                                    ),
                                  )
                                : Text(
                                    l10n.driverTripAccept,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip de métrica (ETA, distancia) en solicitudes de viaje.
class _OfferMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool large;

  const _OfferMetricChip({
    required this.icon,
    required this.label,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: large ? 17 : 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: large ? 13.5 : 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _OriginRow extends StatelessWidget {
  final String originText;
  final double? distanceToPickupKm;

  const _OriginRow({
    required this.originText,
    required this.distanceToPickupKm,
  });

  @override
  Widget build(BuildContext context) {
    final distanceText = _TripOfferCard._formatDistance(distanceToPickupKm);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.place_rounded,
          size: 16,
          color: const Color(0xFF00BFA5),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            originText,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (distanceToPickupKm != null) ...[
          const SizedBox(width: 10),
          Text(
            distanceText,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _CompactAddressLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const _CompactAddressLine({
    required this.icon,
    required this.text,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

