import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Expandido/colapsado de la tarjeta de viaje activo (independiente de
/// actualizaciones de GPS que reconstruyen el mapa).
final tripCardExpandedProvider = StateProvider.family<bool, String>(
  (ref, tripId) => true,
);
