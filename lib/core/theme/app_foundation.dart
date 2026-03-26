import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tokens base para mantener consistencia visual en toda la app.
abstract final class AppFoundation {
  AppFoundation._();

  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 24;

  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 12;
  static const double spacingLg = 16;
  static const double spacingXl = 20;
  static const double spacing2xl = 24;
}

abstract final class AppShadows {
  AppShadows._();

  static List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  /// Resplandor primario muy suave + penumbra difusa para avatares circulares
  /// (mini perfil en home, foto del conductor en perfil).
  static List<BoxShadow> get circularAvatarAmbient => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.045),
          blurRadius: 28,
          spreadRadius: 1,
          offset: const Offset(0, 5),
        ),
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.022),
          blurRadius: 46,
          spreadRadius: -8,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.048),
          blurRadius: 38,
          spreadRadius: -6,
          offset: const Offset(0, 11),
        ),
      ];
}

