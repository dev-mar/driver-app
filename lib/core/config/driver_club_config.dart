import 'package:flutter/material.dart';

/// Landing pública del Club (copy largo / cómo optar).
/// Override: `--dart-define=TEXI_DRIVER_CLUB_LANDING_URL=https://…/es/drivers/`
class DriverClubConfig {
  DriverClubConfig._();

  static const String _landingUrlRaw = String.fromEnvironment(
    'TEXI_DRIVER_CLUB_LANDING_URL',
    defaultValue: '',
  );

  static const String _esDefault = 'https://www.taxitexi.com/es/drivers/';
  static const String _enDefault = 'https://www.taxitexi.com/en/drivers/';

  static const String hubAnchor = 'driver-club';
  static const String inviteAnchor = 'driver-club-invite';
  static const String walletAnchor = 'driver-club-wallet';
  static const String adsAnchor = 'driver-club-ads';
  static const String levelsAnchor = 'driver-club-levels';

  static String landingBaseUrl(Locale locale) {
    final override = _landingUrlRaw.trim();
    if (override.isNotEmpty) {
      return override.endsWith('/') ? override : '$override/';
    }
    return _isSpanish(locale) ? _esDefault : _enDefault;
  }

  static String sectionUrl(Locale locale, [String anchor = hubAnchor]) {
    final base = landingBaseUrl(locale);
    final topic = switch (anchor) {
      inviteAnchor => 'club/invite/',
      walletAnchor => 'club/wallet/',
      adsAnchor => 'club/ads/',
      levelsAnchor => 'club/levels/',
      _ => 'club/',
    };
    return '$base$topic';
  }

  static bool _isSpanish(Locale locale) {
    return locale.languageCode.toLowerCase().startsWith('es');
  }
}
