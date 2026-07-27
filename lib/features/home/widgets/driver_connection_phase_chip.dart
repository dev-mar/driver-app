import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

Widget driverConnectionPhaseChip({
  required IconData icon,
  required String label,
  required bool active,
}) {
  final bg = active
      ? AppColors.primary.withValues(alpha: 0.18)
      : AppColors.surfaceCard.withValues(alpha: 0.72);
  final fg = active ? AppColors.primary : AppColors.textSecondary;
  return AnimatedContainer(
    duration: const Duration(milliseconds: 220),
    curve: Curves.easeOutCubic,
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: active
            ? AppColors.primary.withValues(alpha: 0.45)
            : AppColors.border.withValues(alpha: 0.5),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: fg),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.8,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ],
    ),
  );
}
