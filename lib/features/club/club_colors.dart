import 'package:flutter/material.dart';

/// Paleta exclusiva del hub Club (no sustituye [AppColors] del resto de la app).
abstract final class ClubColors {
  ClubColors._();

  static const Color canvas = Color(0xFF07060C);
  static const Color card = Color(0xFF141225);
  static const Color cardHi = Color(0xFF1C1833);
  static const Color border = Color(0xFF3A3460);
  static const Color violet = Color(0xFF9B8CFF);
  static const Color violetDeep = Color(0xFF6C5CE7);
  static const Color teal = Color(0xFF3DDC97);
  static const Color gold = Color(0xFFF5C542);
  static const Color coral = Color(0xFFFF7A6E);
  static const Color sky = Color(0xFF5EC8F0);
  static const Color text = Color(0xFFF4F2FF);
  static const Color muted = Color(0xFFB7B3CC);

  static Color fromHex(String? raw, {Color fallback = violet}) {
    final s = (raw ?? '').trim().replaceFirst('#', '');
    if (s.length != 6) return fallback;
    final v = int.tryParse(s, radix: 16);
    if (v == null) return fallback;
    return Color(0xFF000000 | v);
  }
}
