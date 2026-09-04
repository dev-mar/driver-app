import 'package:flutter_test/flutter_test.dart';
import 'package:texi_driver_app/features/home/widgets/driver_pickup_wait.dart';
import 'package:texi_driver_app/features/login/driver_realtime_state.dart';

void main() {
  final arrived = DateTime.utc(2026, 9, 4, 12);
  final spec = DriverPickupWaitSpec(
    arrivedAt: arrived,
    waitSec: 300,
    waitGraceSec: 120,
  );

  group('computeDriverPickupWait', () {
    test('waiting / grace / eligible con arrivedAt servidor', () {
      expect(
        computeDriverPickupWait(
          spec,
          now: arrived.add(const Duration(seconds: 60)),
        ).phase,
        DriverPickupWaitPhase.waiting,
      );
      expect(
        computeDriverPickupWait(
          spec,
          now: arrived.add(const Duration(seconds: 310)),
        ).phase,
        DriverPickupWaitPhase.grace,
      );
      expect(
        computeDriverPickupWait(
          spec,
          now: arrived.add(const Duration(seconds: 421)),
        ).phase,
        DriverPickupWaitPhase.eligible,
      );
    });
  });

  group('applyPickupWaitFromPayload', () {
    test('no inventa reloj si falta arrivedAt', () {
      const trip = DriverActiveTrip(tripId: 't1', status: 'arrived');
      final merged = applyPickupWaitFromPayload(trip, {
        'waitSec': 300,
        'waitGraceSec': 120,
      });
      expect(merged.arrivedAt, isNull);
      expect(pickupWaitSpecOf(merged), isNull);
    });

    test('hidrata arrivedAt y duraciones aditivas', () {
      const trip = DriverActiveTrip(tripId: 't1', status: 'arrived');
      final merged = applyPickupWaitFromPayload(trip, {
        'arrivedAt': arrived.toIso8601String(),
        'waitSec': 300,
        'waitGraceSec': 120,
      });
      expect(merged.arrivedAt, isNotNull);
      expect(pickupWaitSpecOf(merged), isNotNull);
    });
  });
}
