import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:texi_driver_app/features/registration/driver_registration_controller.dart';
import 'package:texi_driver_app/features/registration/driver_registration_flow_screen.dart';
import 'package:texi_driver_app/features/registration/driver_registration_models.dart';
import 'package:texi_driver_app/features/registration/driver_registration_repository.dart';

/// Evita HTTP real en tests (Dio dejaba timers pendientes).
class _FakeRegistrationRepository extends DriverRegistrationRepository {
  _FakeRegistrationRepository()
      : super(
          geoDio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1:0')),
          usersDio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1:0')),
        );

  @override
  Future<List<GeoCountry>> fetchCountries() async => const [
        GeoCountry(id: 1, name: 'Bolivia', isoCode: 'BO', phoneCode: '591'),
      ];
}

void main() {
  testWidgets('Registro conductor renderiza correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          driverRegistrationRepositoryProvider
              .overrideWithValue(_FakeRegistrationRepository()),
        ],
        child: const MaterialApp(
          home: DriverRegistrationFlowScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Registro de conductor'), findsOneWidget);
    expect(find.text('Paso 1 de 6'), findsOneWidget);
  });
}
