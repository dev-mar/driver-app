import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../gen_l10n/app_localizations.dart';

/// Desglose pasajero / TEXIAPP en oferta y viaje activo.
class DriverTripPromoBreakdown extends StatelessWidget {
  const DriverTripPromoBreakdown({
    super.key,
    required this.l10n,
    required this.cashDuePassenger,
    required this.companyGuaranteeToDriver,
    this.currencyCode,
    this.isReferralSupport = false,
    this.emphasizeCompanyLine = false,
  });

  final AppLocalizations l10n;
  final double? cashDuePassenger;
  final double? companyGuaranteeToDriver;
  final String? currencyCode;
  final bool isReferralSupport;
  final bool emphasizeCompanyLine;

  @override
  Widget build(BuildContext context) {
    final companyAmount = formatTripMoney(
      companyGuaranteeToDriver,
      currencyCode: currencyCode,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.driverTripPromoCashDue(
            formatTripMoney(cashDuePassenger, currencyCode: currencyCode),
          ),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          isReferralSupport
              ? l10n.driverTripSupportCompanyPays(companyAmount)
              : l10n.driverTripPromoCompanyPays(companyAmount),
          style: TextStyle(
            fontSize: emphasizeCompanyLine ? 17 : 16,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            height: 1.15,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
