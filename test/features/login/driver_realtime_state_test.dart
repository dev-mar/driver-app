import 'package:flutter_test/flutter_test.dart';
import 'package:texi_driver_app/features/login/driver_realtime_state.dart';
import 'package:texi_driver_app/features/login/driver_trip_offer.dart';

void main() {
  group('DriverRealtimeState transiciones oferta → activo', () {
    test('oferta pendiente sin viaje activo', () {
      final offer = const DriverTripOffer(tripId: 't1');
      final state = DriverRealtimeState.initial.copyWith(
        pendingOffers: [offer],
      );

      expect(state.pendingOffers, hasLength(1));
      expect(state.activeTrip, isNull);
      expect(state.availabilitySwitchVisualOn, isFalse);
    });

    test('aceptar limpia pendientes y fija viaje activo', () {
      final offer = const DriverTripOffer(tripId: 't1');
      final withOffer = DriverRealtimeState.initial.copyWith(
        pendingOffers: [offer],
        online: true,
      );
      final processing = withOffer.copyWith(
        processingOfferTripId: 't1',
        processingIsAccept: true,
      );
      final active = processing.copyWith(
        processingOfferTripId: null,
        pendingOffers: const [],
        activeTrip: const DriverActiveTrip(tripId: 't1', status: 'accepted'),
      );

      expect(active.activeTrip?.tripId, 't1');
      expect(active.activeTrip?.status, 'accepted');
      expect(active.pendingOffers, isEmpty);
      expect(active.availabilitySwitchVisualOn, isTrue);
    });

    test('completar mueve a tripPendingRating y libera activeTrip', () {
      final started = DriverRealtimeState.initial.copyWith(
        online: true,
        activeTrip: const DriverActiveTrip(tripId: 't1', status: 'started'),
      );
      final rated = started.copyWith(
        activeTrip: null,
        tripPendingRating: const DriverActiveTrip(tripId: 't1', status: 'completed'),
        lastCompletedTripId: 't1',
      );

      expect(rated.activeTrip, isNull);
      expect(rated.tripPendingRating?.status, 'completed');
      expect(rated.availabilitySwitchVisualOn, isTrue);
    });
  });

  group('DriverRealtimeStateAvailabilityUi', () {
    test('créditos bajo mínimo apaga switch sin viaje activo', () {
      final state = DriverRealtimeState.initial.copyWith(
        insufficientCreditsToGoOnline: true,
        errorCode: 'DRIVER_CREDITS_BELOW_MIN',
        creditsOnlineGateEnabled: true,
        minCreditsToGoOnline: 10,
        driverCreditsBalance: 5,
      );

      expect(state.availabilitySwitchVisualOn, isFalse);
      expect(state.showDriverCreditsBlockedNotice, isTrue);
      expect(state.showDriverCreditsLowWarning, isFalse);
    });

    test('banda 1.25x muestra prealerta y no bloqueo', () {
      final state = DriverRealtimeState.initial.copyWith(
        creditsOnlineGateEnabled: true,
        minCreditsToGoOnline: 10,
        driverCreditsBalance: 12,
      );

      expect(state.showDriverCreditsLowWarning, isTrue);
      expect(state.showDriverCreditsBlockedNotice, isFalse);
    });

    test('créditos bloqueados no avisan durante viaje activo', () {
      final state = DriverRealtimeState.initial.copyWith(
        insufficientCreditsToGoOnline: true,
        creditsOnlineGateEnabled: true,
        minCreditsToGoOnline: 10,
        driverCreditsBalance: 2,
        activeTrip: const DriverActiveTrip(tripId: 't1', status: 'started'),
      );

      expect(state.showDriverCreditsBlockedNotice, isFalse);
      expect(state.availabilitySwitchVisualOn, isTrue);
    });

    test('reconexión mantiene switch visual ON con availabilityDesired', () {
      final state = DriverRealtimeState.initial.copyWith(
        online: false,
        connecting: true,
        availabilityDesired: true,
      );

      expect(state.availabilitySwitchVisualOn, isTrue);
    });
  });

  group('driverTripChatPhaseActive', () {
    test('solo accepted y arrived permiten chat', () {
      expect(driverTripChatPhaseActive('accepted'), isTrue);
      expect(driverTripChatPhaseActive('arrived'), isTrue);
      expect(driverTripChatPhaseActive('started'), isFalse);
      expect(driverTripChatPhaseActive(null), isFalse);
    });
  });
}
