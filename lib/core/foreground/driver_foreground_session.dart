import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter/widgets.dart';

import '../../gen_l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Foreground service (solo Android) mientras el conductor está **online**:
/// notificación persistente tipo Uber/Bolt y prioridad de proceso, alineado con
/// GPS + socket ya existentes. No sustituye FCM.
class DriverForegroundSession {
  DriverForegroundSession._();
  static final DriverForegroundSession instance = DriverForegroundSession._();

  static const int _serviceId = 87101;

  /// Icono + fondo amarillo Texi (meta-data en AndroidManifest).
  static const NotificationIcon _notificationIcon = NotificationIcon(
    metaDataName: 'com.taxitexi.texi_driver_app.service.FG_NOTIFICATION_ICON',
    backgroundColor: AppColors.primary,
  );

  bool _initialized = false;
  bool _startingOrRunning = false;

  AppLocalizations _l10nForCurrentLocale() {
    final raw = WidgetsBinding.instance.platformDispatcher.locale;
    final code = raw.languageCode.toLowerCase();
    final Locale loc =
        (code == 'en' || code == 'es') ? raw : const Locale('es');
    return lookupAppLocalizations(loc);
  }

  String _notificationBody({
    required AppLocalizations l10n,
    required int pendingOfferCount,
    required bool hasActiveTrip,
  }) {
    if (hasActiveTrip) {
      return l10n.driverForegroundNotifyBodyTrip;
    }
    if (pendingOfferCount > 0) {
      return l10n.driverForegroundNotifyBodyOffers(pendingOfferCount);
    }
    return l10n.driverForegroundNotifyBodySearching;
  }

  /// Idempotente: puede llamarse desde [main] y/o antes del primer [sync].
  Future<void> ensureInitializedAndroid() async {
    if (!Platform.isAndroid || _initialized) return;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'texi_driver_availability',
        channelName: 'Texi · Conductor en línea',
        channelDescription:
            'Servicio activo mientras estás disponible para recibir viajes.',
        channelImportance: NotificationChannelImportance.DEFAULT,
        priority: NotificationPriority.DEFAULT,
        enableVibration: false,
        playSound: false,
        showBadge: true,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: true,
        allowAutoRestart: false,
        stopWithTask: true,
      ),
    );
    _initialized = true;
    debugPrint('[DriverForeground] init Android OK.');
  }

  /// Arranca, actualiza o detiene el foreground service.
  ///
  /// [availabilitySessionActive]: el conductor sigue queriendo estar disponible
  /// (switch ON), **aunque el socket esté reconectando** tras segundo plano.
  /// No confundir con `state.online` del socket.
  Future<void> sync({
    required bool availabilitySessionActive,
    required int pendingOfferCount,
    required bool hasActiveTrip,
  }) async {
    if (!Platform.isAndroid) return;
    await ensureInitializedAndroid();

    final l10n = _l10nForCurrentLocale();
    final title = l10n.driverForegroundNotifyTitle;
    final body = _notificationBody(
      l10n: l10n,
      pendingOfferCount: pendingOfferCount,
      hasActiveTrip: hasActiveTrip,
    );

    if (!availabilitySessionActive) {
      await _stopIfRunning();
      return;
    }

    try {
      final running = await FlutterForegroundTask.isRunningService;
      if (!running) {
        if (_startingOrRunning) return;
        _startingOrRunning = true;
        final result = await FlutterForegroundTask.startService(
          serviceId: _serviceId,
          serviceTypes: const [ForegroundServiceTypes.location],
          notificationTitle: title,
          notificationText: body,
          notificationIcon: _notificationIcon,
          callback: _driverForegroundEntryPoint,
        );
        _startingOrRunning = false;
        if (result is ServiceRequestFailure) {
          debugPrint('[DriverForeground] startService failed: ${result.error}');
        }
        return;
      }

      final updateResult = await FlutterForegroundTask.updateService(
        notificationTitle: title,
        notificationText: body,
        notificationIcon: _notificationIcon,
      );
      if (updateResult is ServiceRequestFailure) {
        debugPrint('[DriverForeground] updateService failed: ${updateResult.error}');
      }
    } catch (e, st) {
      _startingOrRunning = false;
      debugPrint('[DriverForeground] sync error: $e $st');
    }
  }

  Future<void> _stopIfRunning() async {
    try {
      if (!await FlutterForegroundTask.isRunningService) return;
      final result = await FlutterForegroundTask.stopService();
      if (result is ServiceRequestFailure) {
        debugPrint('[DriverForeground] stopService failed: ${result.error}');
      }
    } catch (e, st) {
      debugPrint('[DriverForeground] stop: $e $st');
    }
  }
}

@pragma('vm:entry-point')
void _driverForegroundEntryPoint() {
  FlutterForegroundTask.setTaskHandler(_DriverForegroundTaskHandler());
}

/// Mantiene el servicio en primer plano; el trabajo real (socket, GPS) sigue en el isolate principal.
class _DriverForegroundTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}
