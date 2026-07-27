import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../core/config/driver_realtime_config.dart';

/// Factory del socket conductor (contrato estable: path, transports, auth).
io.Socket createDriverRealtimeSocket({required String token}) {
  return io.io(
    DriverRealtimeConfig.socketUrl,
    io.OptionBuilder()
        .setTransports(['websocket', 'polling'])
        .setPath(DriverRealtimeConfig.socketPath)
        .enableForceNew()
        .disableMultiplex()
        .setExtraHeaders(<String, String>{'Authorization': 'Bearer $token'})
        .setAuth(<String, dynamic>{'token': token})
        .build(),
  );
}
