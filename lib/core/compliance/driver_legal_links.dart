import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/driver_legal_config.dart';

Future<bool> openDriverExternalUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<bool> openDriverPrivacyPolicy(BuildContext context) {
  final locale = Localizations.localeOf(context);
  return openDriverExternalUrl(DriverLegalConfig.privacyPolicyUrl(locale));
}

Future<bool> openDriverTerms(BuildContext context) {
  final locale = Localizations.localeOf(context);
  return openDriverExternalUrl(DriverLegalConfig.termsUrl(locale));
}

Future<bool> openDriverAccountDeletionInfo(BuildContext context) {
  final locale = Localizations.localeOf(context);
  return openDriverExternalUrl(DriverLegalConfig.accountDeletionUrl(locale));
}
