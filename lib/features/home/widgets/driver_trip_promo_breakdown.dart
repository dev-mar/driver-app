import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../gen_l10n/app_localizations.dart';

/// Desglose pasajero / TEXIAPP en oferta y viaje activo.
///
/// TEXIAPP cubre va a propósito más grande: el conductor debe ver de un
/// vistazo que la empresa cubre parte del viaje.
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

  static const Color _passengerTint = Color(0xFF34D399);

  @override
  Widget build(BuildContext context) {
    final cashAmount = formatTripMoney(
      cashDuePassenger,
      currencyCode: currencyCode,
    );
    final companyAmount = formatTripMoney(
      companyGuaranteeToDriver,
      currencyCode: currencyCode,
    );
    final companyLabel = l10n.driverTripPromoCompanyCoversLabel;
    final companyFull = isReferralSupport
        ? l10n.driverTripSupportCompanyPays(companyAmount)
        : l10n.driverTripPromoCompanyPays(companyAmount);

    return Semantics(
      container: true,
      label:
          '${l10n.driverTripPromoCashDue(cashAmount)}. $companyFull',
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 9,
              child: _BreakdownTile(
                icon: Icons.payments_rounded,
                caption: l10n.driverTripPromoPassengerPaysLabel,
                amount: cashAmount,
                amountSize: emphasizeCompanyLine ? 16 : 15,
                captionColor: AppColors.textSecondary,
                amountColor: AppColors.textPrimary,
                iconColor: _passengerTint,
                background: _passengerTint.withValues(alpha: 0.10),
                border: _passengerTint.withValues(alpha: 0.32),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 11,
              child: _BreakdownTile(
                icon: Icons.account_balance_rounded,
                caption: companyLabel,
                amount: companyAmount,
                amountSize: emphasizeCompanyLine ? 22 : 20,
                captionColor: AppColors.primary,
                amountColor: AppColors.primary,
                iconColor: AppColors.primary,
                background: AppColors.primary.withValues(alpha: 0.16),
                border: AppColors.primary.withValues(alpha: 0.55),
                emphasized: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownTile extends StatelessWidget {
  const _BreakdownTile({
    required this.icon,
    required this.caption,
    required this.amount,
    required this.amountSize,
    required this.captionColor,
    required this.amountColor,
    required this.iconColor,
    required this.background,
    required this.border,
    this.emphasized = false,
  });

  final IconData icon;
  final String caption;
  final String amount;
  final double amountSize;
  final Color captionColor;
  final Color amountColor;
  final Color iconColor;
  final Color background;
  final Color border;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          10,
          emphasized ? 10 : 8,
          10,
          emphasized ? 10 : 8,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppFoundation.radiusSm),
          border: Border.all(color: border, width: emphasized ? 1.4 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: emphasized ? 15 : 13, color: iconColor),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: emphasized ? 12 : 11,
                      fontWeight: FontWeight.w800,
                      color: captionColor,
                      height: 1.1,
                      letterSpacing: emphasized ? -0.1 : 0,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: emphasized ? 4 : 3),
            Text(
              amount,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: amountSize,
                fontWeight: FontWeight.w800,
                color: amountColor,
                height: 1.1,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
