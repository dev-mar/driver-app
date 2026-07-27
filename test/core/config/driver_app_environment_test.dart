import 'package:flutter_test/flutter_test.dart';
import 'package:texi_driver_app/core/config/driver_app_environment.dart';

void main() {
  test('dev default backend apunta a api.dev cuando no hay override', () {
    // En `flutter test`, kDebugMode == true → entorno dev.
    expect(DriverAppEnvironment.isDev, isTrue);
    expect(
      DriverAppEnvironment.backendBaseUrl,
      DriverAppEnvironment.devBackendDefault,
    );
  });

  test('showsInternalToolsByDefault true en dev sin dart-define', () {
    expect(DriverAppEnvironment.showsInternalToolsByDefault, isTrue);
  });

  test('registrationAllowGallery false en dev sin dart-define explícito', () {
    expect(DriverAppEnvironment.registrationAllowGallery, isFalse);
  });
}
