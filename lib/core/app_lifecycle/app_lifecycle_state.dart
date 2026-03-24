import 'package:flutter/foundation.dart';

/// Estado de visibilidad de la app para decidir cuándo mostrar notificaciones.
/// Solo se muestra notificación de oferta de viaje cuando la app NO está en primer plano,
/// cumpliendo con las políticas de Google Play (no molestar al usuario con notificaciones
/// cuando ya está usando la app).
class DriverAppVisibility {
  DriverAppVisibility._();
  static final DriverAppVisibility instance = DriverAppVisibility._();

  /// true = app visible (resumed); false = en segundo plano (paused, hidden, detached).
  static final ValueNotifier<bool> isInForeground = ValueNotifier(true);
}
