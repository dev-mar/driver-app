import 'package:dio/dio.dart';
import 'package:texi_driver_app/features/registration/driver_registration_models.dart';
import 'package:texi_driver_app/features/registration/driver_registration_repository.dart';

/// Evita HTTP real en tests (Dio dejaba timers pendientes).
class FakeRegistrationRepository extends DriverRegistrationRepository {
  FakeRegistrationRepository()
      : super(
          geoDio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1:0')),
          usersDio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1:0')),
        );

  @override
  Future<List<GeoCountry>> fetchCountries() async => const [
        GeoCountry(id: 1, name: 'Bolivia', isoCode: 'BO', phoneCode: '591'),
      ];
}
