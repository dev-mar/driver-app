import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_trip_offer.dart';

const Color kDriverTripPaymentCash = Color(0xFF34D399);
const Color kDriverTripPaymentQr = Color(0xFF38BDF8);

/// Chip discreto de forma de pago (efectivo vs QR) en viaje activo.
class DriverTripPaymentChip extends StatelessWidget {
  const DriverTripPaymentChip({
    super.key,
    required this.l10n,
    required this.paymentMethod,
  });

  final AppLocalizations l10n;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    final isQr = normalizeDriverTripPaymentMethod(paymentMethod) == 'qr';
    final color = isQr ? kDriverTripPaymentQr : kDriverTripPaymentCash;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isQr ? Icons.qr_code_2_rounded : Icons.payments_rounded,
            size: 13,
            color: color.withValues(alpha: 0.95),
          ),
          const SizedBox(width: 4),
          Text(
            isQr ? l10n.driverTripPaymentQr : l10n.driverTripPaymentCash,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bloque de forma de pago al mismo peso visual que «TEXIAPP cubre».
class DriverTripPaymentTile extends StatelessWidget {
  const DriverTripPaymentTile({
    super.key,
    required this.l10n,
    required this.paymentMethod,
    this.compact = false,
  });

  final AppLocalizations l10n;
  final String paymentMethod;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isQr = normalizeDriverTripPaymentMethod(paymentMethod) == 'qr';
    final color = isQr ? kDriverTripPaymentQr : kDriverTripPaymentCash;
    final value = isQr ? l10n.driverTripPaymentQr : l10n.driverTripPaymentCash;
    final icon = isQr ? Icons.qr_code_2_rounded : Icons.payments_rounded;

    return Semantics(
      container: true,
      label: '${l10n.driverTripPaymentMethodLabel}: $value',
      child: ExcludeSemantics(
        child: Container(
          width: compact ? null : double.infinity,
          padding: EdgeInsets.fromLTRB(
            compact ? 10 : 12,
            compact ? 7 : 10,
            compact ? 10 : 12,
            compact ? 7 : 10,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppFoundation.radiusSm),
            border: Border.all(color: color.withValues(alpha: 0.55), width: 1.4),
          ),
          child: Row(
            children: [
              Icon(icon, size: compact ? 18 : 20, color: color),
              SizedBox(width: compact ? 8 : 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.driverTripPaymentMethodLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 11 : 12,
                        fontWeight: FontWeight.w800,
                        color: color,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: compact ? 2 : 3),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 15 : 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.1,
                        letterSpacing: -0.3,
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
