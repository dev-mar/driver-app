import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/locale_provider.dart';
import '../theme/app_colors.dart';
import '../../gen_l10n/app_localizations.dart';

/// Selector de idioma (es/en) reutilizable desde Configuración u otros puntos.
void showDriverLanguagePickerSheet(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.settingsLanguage,
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.translate),
            title: Text(l10n.languageSpanish),
            onTap: () {
              ref.read(localeProvider.notifier).state = const Locale('es');
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            leading: const Icon(Icons.translate),
            title: Text(l10n.languageEnglish),
            onTap: () {
              ref.read(localeProvider.notifier).state = const Locale('en');
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    ),
  );
}
