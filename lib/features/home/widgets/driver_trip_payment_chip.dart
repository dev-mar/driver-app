import 'package:flutter/material.dart';

import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_trip_offer.dart';

/// Chip discreto de forma de pago (efectivo vs QR) en oferta y viaje activo.
class DriverTripPaymentChip extends StatelessWidget {
  const DriverTripPaymentChip({
    super.key,
    required this.l10n,
    required this.paymentMethod,
  });

  final AppLocalizations l10n;
  final String paymentMethod;

  static const Color _cash = Color(0xFF34D399);
  static const Color _qr = Color(0xFF38BDF8);

  @override
  Widget build(BuildContext context) {
    final isQr = normalizeDriverTripPaymentMethod(paymentMethod) == 'qr';
    final color = isQr ? _qr : _cash;
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
