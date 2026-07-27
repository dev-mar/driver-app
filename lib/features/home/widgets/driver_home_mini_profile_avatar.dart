import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/texi_circular_avatar.dart';
import '../../login/driver_realtime_state.dart';

Widget buildDriverHomeMiniProfileAvatar(DriverRealtimeState realtime) {
  const size = 52.0;
  final raw = realtime.driverPictureProfile?.trim() ?? '';
  if (raw.isEmpty) {
    return TexiCircularAvatar(
      diameter: size,
      child: Icon(
        Icons.directions_car_filled_rounded,
        color: AppColors.primary.withValues(alpha: 0.9),
        size: 28,
      ),
    );
  }

  // Si la firma ya expiró, evitamos renderizar una URL rota.
  final exp = realtime.driverPictureExpiresAt;
  if (exp != null && DateTime.now().isAfter(exp)) {
    return TexiCircularAvatar(
      diameter: size,
      child: Icon(
        Icons.directions_car_filled_rounded,
        color: AppColors.primary.withValues(alpha: 0.9),
        size: 28,
      ),
    );
  }

  Widget image;
  if (raw.startsWith('data:') && raw.contains('base64,')) {
    try {
      final i = raw.indexOf('base64,');
      final bytes = base64Decode(raw.substring(i + 7));
      image = Image.memory(bytes, width: size, height: size, fit: BoxFit.cover);
    } catch (_) {
      image = Icon(
        Icons.directions_car_filled_rounded,
        color: AppColors.primary.withValues(alpha: 0.9),
        size: 28,
      );
    }
  } else {
    image = Image.network(
      raw,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, error, stackTrace) => Icon(
        Icons.directions_car_filled_rounded,
        color: AppColors.primary.withValues(alpha: 0.9),
        size: 28,
      ),
    );
  }

  return TexiCircularAvatar(
    diameter: size,
    child: ClipOval(child: image),
  );
}
