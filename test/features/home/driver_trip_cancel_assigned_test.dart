import 'package:flutter_test/flutter_test.dart';
import 'package:texi_driver_app/features/home/widgets/driver_trip_cancel_reason.dart';

void main() {
  test('conductor cancela assigned en accepted/arrived/started/in_trip', () {
    expect(driverTripCanCancelAssigned('accepted'), isTrue);
    expect(driverTripCanCancelAssigned('arrived'), isTrue);
    expect(driverTripCanCancelAssigned('started'), isTrue);
    expect(driverTripCanCancelAssigned('in_trip'), isTrue);
    expect(driverTripCanCancelAssigned('offered'), isFalse);
    expect(driverTripCanCancelAssigned(null), isFalse);
  });
}
