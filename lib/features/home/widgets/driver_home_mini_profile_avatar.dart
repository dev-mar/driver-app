import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/ui/texi_circular_avatar.dart';
import '../../login/driver_realtime_state.dart';

/// URL usable de `GET /api/v2/driver/me-profile` (`picture_profile`).
/// Si la firma ya venció, devuelve null para no pintar una imagen rota.
String? driverHomeMeProfilePictureUrl(Map<String, dynamic>? data) {
  if (data == null) return null;
  final raw = data['picture_profile']?.toString().trim() ?? '';
  if (raw.isEmpty) return null;
  final expRaw = data['profile_picture_expires_at']?.toString().trim() ?? '';
  if (expRaw.isNotEmpty) {
    final exp = DateTime.tryParse(expRaw);
    if (exp != null && DateTime.now().isAfter(exp)) return null;
  }
  return raw;
}

Widget buildDriverHomeMiniProfileAvatar(
  DriverRealtimeState realtime, {
  String? fallbackPictureUrl,
}) {
  const size = 52.0;
  final raw = _usableDriverPicture(
    primary: realtime.driverPictureProfile,
    primaryExpiresAt: realtime.driverPictureExpiresAt,
    fallback: fallbackPictureUrl,
  );
  if (raw == null) {
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

/// Foto de sesión (socket) si sigue vigente; si no, la del perfil ya cargado.
String? _usableDriverPicture({
  required String? primary,
  required DateTime? primaryExpiresAt,
  required String? fallback,
}) {
  final live = primary?.trim() ?? '';
  final expired = primaryExpiresAt != null &&
      DateTime.now().isAfter(primaryExpiresAt);
  if (live.isNotEmpty && !expired) return live;
  final backup = fallback?.trim() ?? '';
  if (backup.isNotEmpty) return backup;
  return null;
}
