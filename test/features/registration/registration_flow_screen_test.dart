import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:texi_driver_app/features/registration/driver_registration_controller.dart';
import 'package:texi_driver_app/features/registration/driver_registration_flow_screen.dart';
import 'package:texi_driver_app/features/registration/widgets/registration_flow_chrome.dart';

import '../../support/driver_app_test_harness.dart';
import '../../support/fake_registration_repository.dart';

void main() {
  group('DriverRegistrationFlowScreen', () {
    Future<void> pumpRegistration(
      WidgetTester tester, {
      Locale locale = const Locale('es'),
    }) async {
      await tester.pumpWidget(
        wrapDriverApp(
          locale: locale,
          overrides: [
            driverRegistrationRepositoryProvider
                .overrideWithValue(FakeRegistrationRepository()),
          ],
          child: const DriverRegistrationFlowScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
    }

    testWidgets('renderiza título y progreso vía l10n (es)', (tester) async {
      await pumpRegistration(tester, locale: const Locale('es'));
      final l10n = l10nFromTester(tester, DriverRegistrationFlowScreen);

      expect(find.text(l10n.driverRegTitle), findsOneWidget);
      expect(
        find.text(l10n.driverRegStepCounter('1', '4')),
        findsOneWidget,
      );
      expect(find.byType(RegistrationBottomBar), findsOneWidget);
    });

    testWidgets('renderiza título y progreso vía l10n (en)', (tester) async {
      await pumpRegistration(tester, locale: const Locale('en'));
      final l10n = l10nFromTester(tester, DriverRegistrationFlowScreen);

      expect(find.text(l10n.driverRegTitle), findsOneWidget);
      expect(
        find.text(l10n.driverRegStepCounter('1', '4')),
        findsOneWidget,
      );
    });
  });
}
