import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Fila informativa discreta (icono + texto) para avisos no bloqueantes en registro.
class RegistrationSoftInfoRow extends StatelessWidget {
  const RegistrationSoftInfoRow({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 18,
          color: AppColors.textSecondary.withValues(alpha: 0.9),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
