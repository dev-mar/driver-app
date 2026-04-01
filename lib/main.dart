import 'dart:async' show unawaited;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/config/locale_provider.dart';
import 'core/app_lifecycle/app_lifecycle_state.dart';

import 'core/notifications/driver_notification_service.dart';
import 'core/notifications/driver_fcm.dart';
import 'core/notifications/driver_fcm_navigation.dart';
import 'firebase_options.dart';
import 'gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(
    driverFirebaseMessagingBackgroundHandler,
  );
  await DriverNotificationService.instance.initialize();
  await setupDriverFirebaseMessaging();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_consumeInitialFcmMessage());
    });
  }

  /// App terminada: el usuario abre desde el icono de la notificación.
  Future<void> _consumeInitialFcmMessage() async {
    final msg = await FirebaseMessaging.instance.getInitialMessage();
    if (msg == null) return;
    handleDriverFcmNotificationOpen(msg);
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


