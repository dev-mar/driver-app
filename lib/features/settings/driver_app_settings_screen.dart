import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/locale_provider.dart';
import 'widgets/driver_settings_legal_section.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_foundation.dart';
import '../../core/ui/driver_language_picker_sheet.dart';
import '../../gen_l10n/app_localizations.dart';

/// Ajustes generales de la app (idioma y futuras opciones).
class DriverAppSettingsScreen extends ConsumerWidget {
  const DriverAppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final chosen = ref.watch(localeProvider);
    final effective = chosen ?? Localizations.localeOf(context);
    final langLabel =
        effective.languageCode.toLowerCase().startsWith('es') ? l10n.languageSpanish : l10n.languageEnglish;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.driverSettingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppFoundation.spacingMd,
          vertical: AppFoundation.spacingSm,
        ),
        children: [
          Card(
            color: AppColors.surfaceCard,
            child: ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text(l10n.settingsLanguage),
              subtitle: Text(langLabel),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => showDriverLanguagePickerSheet(context, ref),
            ),
          ),
          const DriverSettingsLegalSection(),
        ],
      ),
    );
  }
}
