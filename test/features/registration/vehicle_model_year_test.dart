import 'package:flutter_test/flutter_test.dart';
import 'package:texi_driver_app/features/registration/registration_flow_helpers.dart';

void main() {
  test('acepta cualquier año de exactamente 4 dígitos, fuera del rango de catálogo', () {
    expect(isValidVehicleModelYearText('1990'), isTrue);
    expect(isValidVehicleModelYearText('2026'), isTrue);
    expect(isValidVehicleModelYearText('1000'), isTrue);
  });

  test('rechaza años que no tengan 4 dígitos', () {
    expect(isValidVehicleModelYearText('90'), isFalse);
    expect(isValidVehicleModelYearText('199'), isFalse);
    expect(isValidVehicleModelYearText('19900'), isFalse);
    expect(isValidVehicleModelYearText(''), isFalse);
    expect(isValidVehicleModelYearText(null), isFalse);
    expect(isValidVehicleModelYearText('19a0'), isFalse);
  });
}
