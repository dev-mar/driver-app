import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_foundation.dart';

enum DriverInlineNoticeTone { error, warning, info, success }

class DriverInlineNotice extends StatelessWidget {
  const DriverInlineNotice({
    super.key,
    required this.message,
    required this.tone,
    this.icon,
  });

  final String message;
  final DriverInlineNoticeTone tone;
  final IconData? icon;

  // Ámbar/naranja para warnings — distinto del rojo de error.
  static const Color _amber = Color(0xFFFFA726);

  Color _bg() {
    switch (tone) {
      case DriverInlineNoticeTone.error:
        return AppColors.error.withValues(alpha: 0.12);
      case DriverInlineNoticeTone.warning:
        return _amber.withValues(alpha: 0.13);
      case DriverInlineNoticeTone.info:
        return AppColors.primary.withValues(alpha: 0.1);
      case DriverInlineNoticeTone.success:
        return AppColors.success.withValues(alpha: 0.12);
    }
  }

  Color _fg() {
    switch (tone) {
      case DriverInlineNoticeTone.error:
        return AppColors.error;
      case DriverInlineNoticeTone.warning:
        return _amber;
      case DriverInlineNoticeTone.info:
        return AppColors.primary;
      case DriverInlineNoticeTone.success:
        return AppColors.success;
    }
  }

  IconData _defaultIcon() {
    switch (tone) {
      case DriverInlineNoticeTone.error:
        return Icons.error_outline_rounded;
      case DriverInlineNoticeTone.warning:
        return Icons.warning_amber_rounded;
      case DriverInlineNoticeTone.info:
        return Icons.info_outline_rounded;
      case DriverInlineNoticeTone.success:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = _fg();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppFoundation.spacingMd,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: _bg(),
        borderRadius: BorderRadius.circular(AppFoundation.radiusSm),
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? _defaultIcon(), size: 18, color: fg),
          const SizedBox(width: AppFoundation.spacingSm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: fg,
                fontSize: 12.5,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DriverInlineError extends StatelessWidget {
  const DriverInlineError({
    super.key,
    required this.message,
    this.icon = Icons.error_outline_rounded,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DriverInlineNotice(
      message: message,
      tone: DriverInlineNoticeTone.error,
      icon: icon,
    );
  }
}

class DriverInlineInfo extends StatelessWidget {
  const DriverInlineInfo({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DriverInlineNotice(
      message: message,
      tone: DriverInlineNoticeTone.info,
      icon: icon,
    );
  }
}

/// Widget animado para alertas de gate online en el home.
///
/// — Clasifica el tono según [errorCode]: errores técnicos reales → [DriverInlineNoticeTone.error];
///   restricciones de cuenta/registro/permisos → [DriverInlineNoticeTone.warning];
///   informativos → [DriverInlineNoticeTone.info].
/// — Entra con fade + slide suave; sale con fade. El mensaje no parpadea al
///   reconstruir si no cambia.
class DriverAnimatedGateNotice extends StatefulWidget {
  const DriverAnimatedGateNotice({
    super.key,
    required this.message,
    required this.errorCode,
  });

  final String message;
  final String? errorCode;

  /// Tono según la naturaleza del error — warning para restricciones de cuenta/
  /// registro/permisos, error para problemas técnicos, info para reconexión.
  static DriverInlineNoticeTone toneForCode(String? code) {
    switch (code) {
      // Técnicos / sesión
      case 'AUTH':
      case 'DRIVER_ACCOUNT_BLOCKED':
      case 'RBAC_FORBIDDEN':
      case 'RBAC_NO_IDENTITY':
      case 'RBAC_NO_AUTH':
      case 'RBAC_RESOLVE':
      case 'RBAC_ERROR':
      case 'RBAC_CONFIG':
      case 'UNKNOWN':
        return DriverInlineNoticeTone.error;
      // Informativos / transitorios
      case 'SOCKET_RECONNECTING':
      case 'SOCKET':
        return DriverInlineNoticeTone.info;
      // Todo lo demás: restricciones de cuenta, registro, permisos → warning
      default:
        return DriverInlineNoticeTone.warning;
    }
  }

  static IconData iconForCode(String? code) {
    switch (code) {
      case 'NO_GPS':
      case 'GPS_SERVICE_OFF':
        return Icons.location_off_rounded;
      case 'NO_NOTIFICATIONS':
        return Icons.notifications_off_outlined;
      case 'NO_INTERNET':
        return Icons.wifi_off_rounded;
      case 'DRIVER_VEHICLE_REQUIRED':
      case 'DRIVER_VEHICLE_SELECTION_REQUIRED':
      case 'DRIVER_VEHICLE_IN_USE':
        return Icons.directions_car_outlined;
      case 'DRIVER_REGISTRATION_INCOMPLETE':
      case 'DRIVER_REGISTRATION_NOT_VERIFIED':
      case 'DRIVER_ACCOUNT_NOT_ACTIVE':
        return Icons.assignment_late_outlined;
      case 'DRIVER_CREDITS_BELOW_MIN':
        return Icons.account_balance_wallet_outlined;
      case 'SOCKET_RECONNECTING':
      case 'SOCKET':
        return Icons.sync_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  State<DriverAnimatedGateNotice> createState() =>
      _DriverAnimatedGateNoticeState();
}

class _DriverAnimatedGateNoticeState extends State<DriverAnimatedGateNotice>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tone = DriverAnimatedGateNotice.toneForCode(widget.errorCode);
    final icon = DriverAnimatedGateNotice.iconForCode(widget.errorCode);
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: DriverInlineNotice(
          message: widget.message,
          tone: tone,
          icon: icon,
        ),
      ),
    );
  }
}

class DriverEmptyStateCard extends StatelessWidget {
  const DriverEmptyStateCard({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppFoundation.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 22),
              const SizedBox(height: AppFoundation.spacingSm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

