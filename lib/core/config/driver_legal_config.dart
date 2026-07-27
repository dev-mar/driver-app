import 'package:flutter/material.dart';

/// URLs legales (Play Store: privacidad accesible desde la app).
///
/// Override prod/dev con `--dart-define`:
/// - `TEXI_PRIVACY_POLICY_URL`
/// - `TEXI_TERMS_URL`
/// - `TEXI_ACCOUNT_DELETION_URL`
class DriverLegalConfig {
  DriverLegalConfig._();

  static const String _privacyUrlRaw = String.fromEnvironment(
    'TEXI_PRIVACY_POLICY_URL',
    defaultValue: '',
  );
  static const String _termsUrlRaw = String.fromEnvironment(
    'TEXI_TERMS_URL',
    defaultValue: '',
  );
  static const String _accountDeletionUrlRaw = String.fromEnvironment(
    'TEXI_ACCOUNT_DELETION_URL',
    defaultValue: '',
  );

  static const String _privacyEsDefault =
      'https://www.taxitexi.com/es/privacy/driver';
  static const String _privacyEnDefault =
      'https://www.taxitexi.com/en/privacy/driver';
  static const String _termsEsDefault =
      'https://www.taxitexi.com/es/terms/driver';
  static const String _termsEnDefault =
      'https://www.taxitexi.com/en/terms/driver';
  static const String _accountDeletionEsDefault =
      'https://www.taxitexi.com/es/account-deletion/driver';
  static const String _accountDeletionEnDefault =
      'https://www.taxitexi.com/en/account-deletion/driver';

  static String privacyPolicyUrl(Locale locale) {
    final override = _privacyUrlRaw.trim();
    if (override.isNotEmpty) return override;
    return _isSpanish(locale) ? _privacyEsDefault : _privacyEnDefault;
  }

  static String termsUrl(Locale locale) {
    final override = _termsUrlRaw.trim();
    if (override.isNotEmpty) return override;
    return _isSpanish(locale) ? _termsEsDefault : _termsEnDefault;
  }

  /// Solicitud de eliminación de cuenta (Google Play User Data policy).
  static String accountDeletionUrl(Locale locale) {
    final override = _accountDeletionUrlRaw.trim();
    if (override.isNotEmpty) return override;
    return _isSpanish(locale)
        ? _accountDeletionEsDefault
        : _accountDeletionEnDefault;
  }

  static bool _isSpanish(Locale locale) {
    return locale.languageCode.toLowerCase().startsWith('es');
  }
}
