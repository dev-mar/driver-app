import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Degradado horizontal en bordes para listas scrollables (p. ej. pills de color).
class HorizontalEdgeFade extends StatelessWidget {
  const HorizontalEdgeFade({
    super.key,
    required this.child,
    this.edgeWidth = 18,
    this.fadeColor,
  });

  final Widget child;
  final double edgeWidth;
  final Color? fadeColor;

  @override
  Widget build(BuildContext context) {
    final base = fadeColor ?? AppColors.surfaceCard;
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              width: edgeWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    base.withValues(alpha: 0.94),
                    base.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              width: edgeWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    base.withValues(alpha: 0.94),
                    base.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
