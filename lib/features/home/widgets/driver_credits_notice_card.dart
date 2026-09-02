import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_realtime_state.dart';

enum DriverCreditsNoticeVariant { warning, blocked }

/// Aviso compacto de créditos (home y post-viaje). Copy corto + CTA recargar.
class DriverCreditsNoticeCard extends StatelessWidget {
  const DriverCreditsNoticeCard({
    super.key,
    required this.variant,
    required this.balanceLabel,
    required this.minLabel,
    this.afterTrip = false,
    this.onCta,
  });

  factory DriverCreditsNoticeCard.fromRealtime(
    DriverRealtimeState realtime, {
    bool afterTrip = false,
    VoidCallback? onCta,
  }) {
    final blocked = realtime.showDriverCreditsBlockedNotice ||
        (afterTrip && realtime.insufficientCreditsToGoOnline);
    return DriverCreditsNoticeCard(
      variant: blocked
          ? DriverCreditsNoticeVariant.blocked
          : DriverCreditsNoticeVariant.warning,
      balanceLabel: formatMoney(realtime.driverCreditsBalance),
      minLabel: formatMoney(
        realtime.minCreditsToGoOnline,
        decimals: realtime.minCreditsToGoOnline % 1 == 0 ? 0 : 2,
      ),
      afterTrip: afterTrip,
      onCta: onCta,
    );
  }

  final DriverCreditsNoticeVariant variant;
  final String balanceLabel;
  final String minLabel;
  final bool afterTrip;
  final VoidCallback? onCta;

  bool get _isBlocked => variant == DriverCreditsNoticeVariant.blocked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = _isBlocked ? const Color(0xFFFF6B6B) : AppColors.primary;
    final title = afterTrip
        ? (_isBlocked
            ? l10n.driverCreditsNoticeAfterTripBlockedTitle
            : l10n.driverCreditsNoticeAfterTripWarningTitle)
        : (_isBlocked
            ? l10n.driverCreditsNoticeBlockedTitle
            : l10n.driverCreditsNoticeWarningTitle);
    final body = afterTrip
        ? (_isBlocked
            ? l10n.driverCreditsNoticeAfterTripBlockedBody(minLabel)
            : l10n.driverCreditsNoticeAfterTripWarningBody)
        : (_isBlocked
            ? l10n.driverCreditsNoticeBlockedBody
            : l10n.driverCreditsNoticeWarningBody(minLabel));

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
          border: Border.all(color: accent.withValues(alpha: 0.48), width: 1),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.22),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent.withValues(alpha: _isBlocked ? 0.22 : 0.16),
                        AppColors.surfaceCard,
                        AppColors.background.withValues(alpha: 0.92),
                      ],
                      stops: const [0.0, 0.46, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 4, color: accent),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: 0.2),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.55),
                            ),
                          ),
                          child: Icon(
                            _isBlocked
                                ? Icons.account_balance_wallet_rounded
                                : Icons.bolt_rounded,
                            color: accent,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              height: 1.2,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      balanceLabel,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                        height: 1.05,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.98),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        if (onCta != null) {
                          onCta!();
                          return;
                        }
                        context.pushNamed(AppRouter.creditsTopup);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(48, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppFoundation.radiusMd,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.driverCreditsNoticeCta,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
