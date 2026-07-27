import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../gen_l10n/app_localizations.dart';
import '../notifications/driver_notification_service.dart';

/// Divulgaciones prominentes antes de solicitar permisos sensibles (Google Play).
Future<bool> driverEnsurePlayDisclosuresBeforeOnline(
  BuildContext context,
  AppLocalizations l10n,
) async {
  if (!context.mounted) return false;

  if (Platform.isAndroid || defaultTargetPlatform == TargetPlatform.iOS) {
    final notifOk = await _ensureNotificationDisclosure(context, l10n);
    if (!notifOk || !context.mounted) return false;
  }

  if (!kIsWeb &&
      (Platform.isAndroid || defaultTargetPlatform == TargetPlatform.iOS)) {
    final locOk = await _ensureForegroundLocationDisclosure(context, l10n);
    if (!locOk || !context.mounted) return false;
  }

  return true;
}

Future<bool> _ensureNotificationDisclosure(
  BuildContext context,
  AppLocalizations l10n,
) async {
  if (!Platform.isAndroid && defaultTargetPlatform != TargetPlatform.iOS) {
    return true;
  }

  final fcmSettings = await FirebaseMessaging.instance.getNotificationSettings();
  if (_notificationAuthorized(fcmSettings)) {
    return true;
  }

  if (!context.mounted) return false;
  final proceed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        title: Text(l10n.driverPlayNotificationDisclosureTitle),
        content: Text(l10n.driverPlayNotificationDisclosureBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.driverPlayDisclosureContinue),
          ),
        ],
      );
    },
  );
  if (proceed != true) return false;

  await DriverNotificationService.instance
      .requestAndroidPostNotificationsPermission();
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  } else {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  // Divulgación cumplida; si el usuario deniega en el diálogo del SO, setOnline mostrará el error.
  return true;
}

Future<bool> _ensureForegroundLocationDisclosure(
  BuildContext context,
  AppLocalizations l10n,
) async {
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always) {
    return true;
  }
  if (permission == LocationPermission.deniedForever) {
    return false;
  }

  if (!context.mounted) return false;
  final proceed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        title: Text(l10n.driverPlayLocationDisclosureTitle),
        content: Text(l10n.driverPlayLocationDisclosureBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.driverPlayDisclosureContinue),
          ),
        ],
      );
    },
  );
  if (proceed != true) return false;

  await Geolocator.requestPermission();
  return true;
}

bool _notificationAuthorized(NotificationSettings settings) {
  final s = settings.authorizationStatus;
  return s == AuthorizationStatus.authorized ||
      s == AuthorizationStatus.provisional;
}
