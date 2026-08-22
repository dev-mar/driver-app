import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Tono visual de la tarjeta. [accent] distingue un bloque sin romper el resto del flujo.
enum RegistrationSectionTone { standard, accent }

/// Tarjeta de sección del flujo de registro (icono, título, subtítulo opcional, cuerpo).
/// Reutilizable en cualquier paso que siga el mismo patrón visual.
class RegistrationSectionCard extends StatelessWidget {
  const RegistrationSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.subtitle,
    this.tone = RegistrationSectionTone.standard,
  });

  final String title;
  final IconData icon;
  final String? subtitle;
  final List<Widget> children;
  final RegistrationSectionTone tone;

  @override
  Widget build(BuildContext context) {
    final isAccent = tone == RegistrationSectionTone.accent;
    final fill = isAccent
        ? Color.alphaBlend(
            AppColors.primary.withValues(alpha: 0.16),
            AppColors.surfaceCard,
          )
        : AppColors.surfaceCard;
    final border = isAccent
        ? AppColors.primary.withValues(alpha: 0.48)
        : AppColors.border.withValues(alpha: 0.5);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: isAccent ? 0.24 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                height: 1.38,
              ),
            ),
          ],
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
