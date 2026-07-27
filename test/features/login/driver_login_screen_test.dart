import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:texi_driver_app/core/theme/app_motion.dart';
import 'package:texi_driver_app/features/login/driver_login_screen.dart';

import '../../support/driver_app_test_harness.dart';

void main() {
  group('DriverLoginScreen', () {
    Future<void> pumpLogin(
      WidgetTester tester, {
      Locale locale = const Locale('es'),
    }) async {
      await tester.pumpWidget(
        wrapDriverApp(
          locale: locale,
          child: const DriverLoginScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(AppMotion.screenEntrance);
    }

    testWidgets('renderiza campos principales vía l10n (es)', (tester) async {
      await pumpLogin(tester);
      final l10n = l10nFromTester(tester, DriverLoginScreen);

      expect(find.text(l10n.driverLoginWelcome), findsOneWidget);
      expect(find.text(l10n.driverLoginButton), findsOneWidget);
      expect(find.text(l10n.driverLoginRegisterCta), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('renderiza campos principales vía l10n (en)', (tester) async {
      await pumpLogin(tester, locale: const Locale('en'));
      final l10n = l10nFromTester(tester, DriverLoginScreen);

      expect(find.text(l10n.driverLoginWelcome), findsOneWidget);
      expect(find.text(l10n.driverLoginButton), findsOneWidget);
    });
  });
}
