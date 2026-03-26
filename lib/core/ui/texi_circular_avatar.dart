import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_foundation.dart';

/// Avatar circular con borde y [AppShadows.circularAvatarAmbient].
/// Unifica mini perfil (home) y foto del conductor (perfil).
class TexiCircularAvatar extends StatelessWidget {
  const TexiCircularAvatar({
    super.key,
    required this.diameter,
    required this.child,
    this.backgroundColor = AppColors.surface,
    this.borderColor = AppColors.border,
    this.borderOpacity = 0.8,
    this.borderWidth = 1.0,
  });

  /// Marco doble (anillo exterior + reborde interior) para foto redonda.
  factory TexiCircularAvatar.profileRing({
    Key? key,
    required double innerDiameter,
    required Widget image,
    double outerRing = 3,
    double innerRing = 2,
    Color frameBackground = AppColors.surfaceCard,
    Color innerHold = AppColors.surface,
  }) {
    return TexiCircularAvatar(
      key: key,
      diameter: innerDiameter + 2 * outerRing,
      backgroundColor: frameBackground,
      child: Padding(
        padding: EdgeInsets.all(outerRing),
        child: ClipOval(
          child: Container(
            color: innerHold,
            padding: EdgeInsets.all(innerRing),
            child: ClipOval(child: image),
          ),
        ),
      ),
    );
  }

  final double diameter;
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderOpacity;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: Border.all(
          color: borderColor.withValues(alpha: borderOpacity),
          width: borderWidth,
        ),
        boxShadow: AppShadows.circularAvatarAmbient,
      ),
      child: child,
    );
  }
}
