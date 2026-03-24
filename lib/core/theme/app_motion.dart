import 'package:flutter/material.dart';

/// Duraciones y curvas unificadas para sensación “premium” (fluido, sin exagerar).
abstract final class AppMotion {
  AppMotion._();

  /// Hojas modales, diálogos ligeros.
  static const Duration sheetEntrance = Duration(milliseconds: 600);

  /// Primera aparición de pantallas (login, home lista).
  static const Duration screenEntrance = Duration(milliseconds: 700);

  /// Cambio de paso en flujos largos (p. ej. registro).
  static const Duration stepSwitcher = Duration(milliseconds: 380);

  /// Tarjetas / filas escalonadas (perfil, listas).
  static const Duration staggerItem = Duration(milliseconds: 42);

  /// Slide vertical sutil (fracción de altura vía Offset.dy).
  static const double slideDySubtle = 0.045;

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve iconPop = Curves.easeOutBack;
}
