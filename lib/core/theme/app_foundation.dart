import 'package:flutter/material.dart';

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
}

