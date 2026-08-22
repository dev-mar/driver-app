import 'package:flutter/material.dart';

import '../../../core/theme/app_foundation.dart';
import '../club_colors.dart';

class ClubSectionCard extends StatelessWidget {
  const ClubSectionCard({
    super.key,
    required this.child,
    this.accent = ClubColors.violet,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final Color accent;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppFoundation.spacingLg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ClubColors.cardHi,
            ClubColors.card,
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
        child: body,
      ),
    );
  }
}
