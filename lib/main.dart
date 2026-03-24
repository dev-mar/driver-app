import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/config/locale_provider.dart';
import 'core/app_lifecycle/app_lifecycle_state.dart';
import 'core/notifications/driver_notification_service.dart';
import 'gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DriverNotificationService.instance.initialize();
  runApp(const ProviderScope(child: TexiDriverApp()));
}

class TexiDriverApp extends ConsumerStatefulWidget {
  const TexiDriverApp({super.key});

  @override
  ConsumerState<TexiDriverApp> createState() => _TexiDriverAppState();
}

class _TexiDriverAppState extends ConsumerState<TexiDriverApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    DriverAppVisibility.isInForeground.value = state == AppLifecycleState.resumed;
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx).driverAppTitle,
      theme: AppTheme.dark,
      routerConfig: AppRouter.router,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
    );
  }
}


