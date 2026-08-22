import 'package:flutter_test/flutter_test.dart';
import 'package:texi_driver_app/features/login/driver_trip_offer.dart';

void main() {
  group('DriverTripOfferSource', () {
    test('isAdminWebDispatch solo con admin_web_dispatch', () {
      expect(
        DriverTripOfferSource.isAdminWebDispatch(
          DriverTripOfferSource.adminWebDispatch,
        ),
        isTrue,
      );
      expect(
        DriverTripOfferSource.isAdminWebDispatch(
          DriverTripOfferSource.passengerApp,
        ),
        isFalse,
      );
      expect(DriverTripOfferSource.isAdminWebDispatch(null), isFalse);
      expect(DriverTripOfferSource.isAdminWebDispatch(''), isFalse);
    });
  });

  group('driverTripOfferFromMap', () {
    test('parsea requestSource y flag admin web', () {
      final offer = driverTripOfferFromMap({
        'tripId': 'trip-42',
        'offeredPrice': '12.5',
        'requestSource': 'admin_web_dispatch',
        'dispatchMode': 'targeted_driver',
      });

      expect(offer.tripId, 'trip-42');
      expect(offer.offeredPrice, 12.5);
      expect(offer.isAdminWebDispatch, isTrue);
      expect(offer.dispatchMode, 'targeted_driver');
    });

    test('oferta pasajero sin requestSource no es admin web', () {
      final offer = driverTripOfferFromMap({
        'tripId': 'trip-99',
        'offeredPrice': 20,
      });

      expect(offer.isAdminWebDispatch, isFalse);
      expect(offer.tripExtras, isEmpty);
      expect(offer.paymentMethod, 'cash');
    });

    test('parsea tripExtras desde lista y desde JSON FCM', () {
      final fromList = driverTripOfferFromMap({
        'tripId': 't-1',
        'tripExtras': ['pet', 'over_4', 'pet', 'unknown', 'luggage'],
      });
      expect(fromList.tripExtras, ['pet', 'over_4', 'luggage']);

      final fromJson = driverTripOfferFromMap({
        'tripId': 't-2',
        'tripExtras': '["child_seat","wheelchair"]',
      });
      expect(fromJson.tripExtras, ['child_seat', 'wheelchair']);
    });

    test('parsea tripSpecials desde lista y JSON FCM', () {
      final fromList = driverTripOfferFromMap({
        'tripId': 't-3',
        'tripSpecials': ['seats_6', 'cargo', 'seats_6', 'unknown'],
      });
      expect(fromList.tripSpecials, ['seats_6', 'cargo']);

      final fromJson = driverTripOfferFromMap({
        'tripId': 't-4',
        'tripSpecials': '["roof_rack"]',
      });
      expect(fromJson.tripSpecials, ['roof_rack']);
    });
  });
}
