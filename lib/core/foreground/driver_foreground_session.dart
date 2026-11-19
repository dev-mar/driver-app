import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter/widgets.dart';

import '../../gen_l10n/app_localizations.dart';
import '../config/driver_backend_config.dart';
import '../network/driver_api_client.dart';
import '../storage/driver_secure_storage.dart';
import '../theme/app_colors.dart';

/// Foreground service (solo Android) mientras el conductor está **online**:
/// notificación persistente y prioridad de proceso. Si no hay viaje activo,
/// el isolate del servicio refresca `last_ping` por HTTP. El socket, el GPS
/// y el viaje activo siguen en el isolate principal. No sustituye FCM.
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
  String? _lastNotificationBody;
  bool? _lastAvailabilitySessionActive;
  bool _presenceLoopEnabled = false;
  DateTime? _lastPresenceRefreshAt;

  AppLocalizations _l10nForCurrentLocale() {
    final raw = WidgetsBinding.instance.platformDispatcher.locale;
    final code = raw.languageCode.toLowerCase();
    final Locale loc = (code == 'en' || code == 'es')
        ? raw
        : const Locale('es');
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
        eventAction: ForegroundTaskEventAction.repeat(20000),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: true,
        allowAutoRestart: false,
        stopWithTask: false,
      ),
    );
    FlutterForegroundTask.addTaskDataCallback(_onTaskData);
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

    final presenceEnabled = availabilitySessionActive && !hasActiveTrip;

    if (!availabilitySessionActive) {
      _presenceLoopEnabled = false;
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
        } else {
          _lastAvailabilitySessionActive = availabilitySessionActive;
          _lastNotificationBody = body;
          await _sendPresenceConfig(enabled: presenceEnabled);
        }
        return;
      }

      if (_lastAvailabilitySessionActive == availabilitySessionActive &&
          _lastNotificationBody == body) {
        if (_presenceLoopEnabled != presenceEnabled) {
          await _sendPresenceConfig(enabled: presenceEnabled);
        }
        return;
      }

      final updateResult = await FlutterForegroundTask.updateService(
        notificationTitle: title,
        notificationText: body,
        notificationIcon: _notificationIcon,
      );
      if (updateResult is ServiceRequestFailure) {
        debugPrint(
          '[DriverForeground] updateService failed: ${updateResult.error}',
        );
      } else {
        _lastAvailabilitySessionActive = availabilitySessionActive;
        _lastNotificationBody = body;
        await _sendPresenceConfig(enabled: presenceEnabled);
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
      } else {
        _lastAvailabilitySessionActive = false;
        _lastNotificationBody = null;
        _presenceLoopEnabled = false;
      }
    } catch (e, st) {
      debugPrint('[DriverForeground] stop: $e $st');
    }
  }

  /// El servicio pide token nuevo tras un 401. No cierra la sesión.
  static void _onTaskData(Object data) {
    if (data is! Map || data['type'] != 'presence_unauthorized') return;
    unawaited(instance._refreshPresenceToken());
  }

  Future<void> _refreshPresenceToken() async {
    if (!_presenceLoopEnabled) return;
    final now = DateTime.now();
    final last = _lastPresenceRefreshAt;
    if (last != null && now.difference(last) < const Duration(seconds: 45)) {
      return;
    }
    _lastPresenceRefreshAt = now;
    final ok = await DriverApiClient().tryRefreshSession();
    if (!ok || !_presenceLoopEnabled) return;
    await _sendPresenceConfig(enabled: true);
  }

  /// Solo mientras espera solicitudes. Con viaje activo el isolate no late.
  Future<void> _sendPresenceConfig({required bool enabled}) async {
    if (!Platform.isAndroid) return;
    if (!await FlutterForegroundTask.isRunningService) return;
    String? token;
    if (enabled) {
      token = await DriverSecureStorage.read(DriverApiClient.tokenStorageKey);
      if (token == null || token.isEmpty) enabled = false;
    }
    _presenceLoopEnabled = enabled;
    FlutterForegroundTask.sendDataToTask(<String, Object?>{
      'type': 'presence',
      'enabled': enabled,
      'baseUrl': DriverBackendConfig.baseUrl,
      'token': enabled ? token : null,
    });
  }
}

@pragma('vm:entry-point')
void _driverForegroundEntryPoint() {
  FlutterForegroundTask.setTaskHandler(_DriverForegroundTaskHandler());
}

/// Latido HTTP de solicitudes. El socket y el viaje activo siguen en el isolate principal.
class _DriverForegroundTaskHandler extends TaskHandler {
  bool _enabled = false;
  String? _baseUrl;
  String? _token;
  bool _inFlight = false;
  DateTime? _unauthorizedAt;
  HttpClient? _client;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onReceiveData(Object data) {
    if (data is! Map || data['type'] != 'presence') return;
    final enabled = data['enabled'] == true;
    final base = data['baseUrl']?.toString().trim() ?? '';
    final token = data['token']?.toString() ?? '';
    if (!enabled || base.isEmpty || token.isEmpty || token.length > 8192) {
      _enabled = false;
      if (!enabled) _token = null;
      return;
    }
    _baseUrl = base;
    _token = token;
    _enabled = true;
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    if (!_enabled || _inFlight) return;
    unawaited(_postPresenceHeartbeat());
  }

  Future<void> _postPresenceHeartbeat() async {
    final token = _token;
    final base = _baseUrl;
    if (!_enabled || token == null || base == null) return;
    final uri = Uri.tryParse('$base/drivers/me/presence/heartbeat');
    if (uri == null || !uri.hasScheme) return;
    _inFlight = true;
    final client = _client ??= HttpClient();
    try {
      final req = await client.postUrl(uri).timeout(const Duration(seconds: 8));
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      req.headers.contentType = ContentType.json;
      final body = utf8.encode('{}');
      req.contentLength = body.length;
      req.add(body);
      final res = await req.close().timeout(const Duration(seconds: 8));
      await res.drain<void>();
      if (res.statusCode == 401) {
        _signalUnauthorized();
      }
    } catch (_) {
      // El siguiente ciclo reintenta. No se registra el token.
    } finally {
      _inFlight = false;
    }
  }

  void _signalUnauthorized() {
    _enabled = false;
    final now = DateTime.now();
    final last = _unauthorizedAt;
    if (last != null && now.difference(last) < const Duration(seconds: 30)) {
      return;
    }
    _unauthorizedAt = now;
    FlutterForegroundTask.sendDataToMain(<String, String>{
      'type': 'presence_unauthorized',
    });
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    _enabled = false;
    _token = null;
    _client?.close(force: true);
    _client = null;
  }
}
