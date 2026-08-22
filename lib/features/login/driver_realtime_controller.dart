import 'dart:async';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../core/app_lifecycle/app_lifecycle_state.dart';
import '../../core/config/driver_realtime_config.dart';
import '../../core/notifications/driver_push_token_service.dart';
import '../../core/notifications/driver_trip_chat_visibility.dart';
import '../../core/notifications/driver_notification_service.dart';
import '../../core/foreground/driver_foreground_session.dart';
import '../../core/session/driver_map_preferences_store.dart';
import '../../core/session/driver_must_change_password_gate.dart';
import '../../core/session/driver_session_expulsion.dart';
import '../../core/storage/driver_secure_storage.dart';
import 'driver_realtime_exception.dart';
import 'driver_realtime_parsers.dart';
import 'driver_realtime_socket_connector.dart';
import 'driver_realtime_state.dart';
import 'driver_trip_offer.dart';
import 'driver_vehicle_display.dart';
import 'driver_trip_rest_service.dart';

export 'driver_realtime_state.dart';

part 'driver_realtime_controller.location.dart';
part 'driver_realtime_controller.reconnect.dart';
part 'driver_realtime_controller.session.dart';
part 'driver_realtime_controller.trips.dart';
part 'driver_realtime_controller.socket.dart';

final driverRealtimeProvider =
    StateNotifierProvider<DriverRealtimeController, DriverRealtimeState>(
      (ref) => DriverRealtimeController(),
    );

class DriverRealtimeController extends StateNotifier<DriverRealtimeState>
    with
        _DriverRealtimeLocationMixin,
        _DriverRealtimeReconnectMixin,
        _DriverRealtimeSocketMixin,
        _DriverRealtimeSessionMixin,
        _DriverRealtimeTripsMixin {
  DriverRealtimeController({DriverTripRestService? tripRest})
      : _tripRest = tripRest ?? DriverTripRestService(),
        super(DriverRealtimeState.initial);
  static const bool _verboseRealtimeLogs = false;

  final DriverTripRestService _tripRest;

  io.Socket? _socket;
  Future<void>? _goOnlineRun;
  StreamSubscription<Position>? _positionSub;
  Timer? _tripReconnectTimer;
  Timer? _availabilityReconnectTimer;
  Timer? _presenceHeartbeatTimer;
  final Random _reconnectJitterRandom = Random();
  int _availabilityReconnectAttempts = 0;
  int _tripReconnectAttempts = 0;
  final Set<String> _tripRatingInFlight = <String>{};
  final Map<int, Future<List<DriverRatingFeedbackItem>>>
  _ratingCatalogInFlight = <int, Future<List<DriverRatingFeedbackItem>>>{};
  DateTime? _lastTouchReconnect;
  bool _disposed = false;

  /// `true` tras apagar el switch o logout: no auto-reconectar por `onDisconnect`.
  bool _userRequestedOffline = false;
  bool _suppressNextDisconnectHandling = false;

  /// `true` mientras el conductor quiere estar disponible (switch ON en esta sesión).
  bool _availabilitySessionDesired = false;

  /// Si el conductor intenta finalizar viaje sin socket conectado (por red
  /// caída o background), guardamos el tripId para reintentarlo en
  /// cuanto se restablezca la conexión.
  String? _pendingTripCompletedTripId;
  bool _isRefreshingDriverPhoto = false;
  DateTime? _lastDriverPhotoRefreshAt;

  /// Última vez que el servidor recibió `location:update` (anti saturación).
  DateTime? _lastLocationEmittedAt;
  static const _locationEmitMinInterval = Duration(milliseconds: 2800);
  static const int _availabilityReconnectBaseMs = 900;
  static const int _tripReconnectBaseMs = 700;
  static const int _reconnectMaxDelayMs = 12000;

  /// Evita `checkPermission` repetido en reconexiones seguidas.
  DateTime? _locationPermissionCachedAt;
  LocationPermission? _locationPermissionCached;

  void _logVerbose(String message) {
    if (!_verboseRealtimeLogs) return;
    debugPrint('[DRIVER_RT] $message');
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelTripReconnectLoop();
    _cancelAvailabilityReconnectLoop();
    _cancelPresenceHeartbeat();
    _userRequestedOffline = true;
    _availabilitySessionDesired = false;
    unawaited(_goOffline(internal: true, preserveTripState: false));
    unawaited(
      DriverForegroundSession.instance.sync(
        availabilitySessionActive: false,
        pendingOfferCount: 0,
        hasActiveTrip: false,
      ),
    );
    super.dispose();
  }
}
