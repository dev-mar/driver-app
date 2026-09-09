import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_foundation.dart';
import '../../core/theme/app_motion.dart';
import '../../core/ui/driver_secondary_scaffold.dart';
import '../../core/utils/money_formatter.dart';
import '../../gen_l10n/app_localizations.dart';
import 'driver_company_payout_models.dart';
import 'driver_company_payout_repository.dart';
import 'driver_topup_receipt_picker.dart';

/// Por cobrar TEXIAPP: saldo cobrable, ticket de cobro con QR e historial.
class DriverCompanyPayoutScreen extends StatefulWidget {
  const DriverCompanyPayoutScreen({super.key});

  @override
  State<DriverCompanyPayoutScreen> createState() =>
      _DriverCompanyPayoutScreenState();
}

class _DriverCompanyPayoutScreenState extends State<DriverCompanyPayoutScreen> {
  final _repo = DriverCompanyPayoutRepository();
  DriverCompanyPayoutSnapshot? _data;
  bool _loading = true;
  bool _busy = false;
  String? _error;
  String? _qrB64;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final snap = await _repo.fetchSnapshot();
    if (!mounted) return;
    setState(() {
      _data = snap;
      _loading = false;
      if (snap == null) _error = 'load';
    });
  }

  String _tripShort(String id) {
    final clean = id.replaceAll('-', '');
    if (clean.length < 8) return id;
    return clean.substring(0, 8).toUpperCase();
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    final local = d.toLocal();
    return DateFormat('dd/MM/yyyy · HH:mm').format(local);
  }

  String _sourceLabel(AppLocalizations l10n, String source) {
    if (source == 'passenger_referral_support') {
      return l10n.driverPayoutSourceReferral;
    }
    return l10n.driverPayoutSourceCampaign;
  }

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'in_review':
        return l10n.driverPayoutStatusReview;
      case 'approved':
        return l10n.driverPayoutStatusApproved;
      case 'rejected':
        return l10n.driverPayoutStatusRejected;
      case 'paid':
        return l10n.driverPayoutStatusPaid;
      default:
        return status;
    }
  }

  String _rejectLabel(AppLocalizations l10n, String? code) {
    switch (code) {
      case 'holder_mismatch':
        return l10n.driverPayoutRejectHolder;
      case 'amount_mismatch':
        return l10n.driverPayoutRejectAmount;
      case 'qr_unreadable':
        return l10n.driverPayoutRejectQr;
      case 'other':
        return l10n.driverPayoutRejectOther;
      default:
        return l10n.driverPayoutRejectOther;
    }
  }

  Future<void> _pickQr() async {
    HapticFeedback.lightImpact();
    final picked = await pickDriverTopupReceiptFromDevice(context);
    if (!mounted) return;
    if (!picked.ok) {
      if (picked.error == DriverTopupReceiptPickError.canceled) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).driverPayoutQrPickFailed)),
      );
      return;
    }
    setState(() => _qrB64 = picked.base64Jpeg);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final qr = _qrB64;
    final data = _data;
    if (qr == null || data == null || !data.canSubmit) return;
    setState(() => _busy = true);
    try {
      final key = await _repo.uploadQrBase64(qr);
      if (!mounted) return;
      if (key == null || key.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.driverPayoutUploadFailed)),
        );
        return;
      }
      await _repo.submitRequest(qrStorageKey: key);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() => _qrB64 = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.driverPayoutSubmitted)),
      );
      await _reload();
    } on DriverCompanyPayoutException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.driverPayoutSubmitFailed)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DriverSecondaryScaffold(
      title: l10n.driverPayoutTitle,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceCard,
              onRefresh: _reload,
              child: _error != null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppFoundation.spacingXl),
                      children: [
                        const SizedBox(height: 80),
                        Text(
                          l10n.driverPayoutLoadError,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: _reload,
                            child: Text(l10n.driverTopupHistoryRetry),
                          ),
                        ),
                      ],
                    )
                  : _buildBody(l10n),
            ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    final data = _data!;
    final heroAmount = data.openRequest?.amount ?? data.collectibleTotal;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: AppMotion.screenEntrance,
          curve: AppMotion.standard,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * 12),
              child: child,
            ),
          ),
          child: _HeroBalance(
            amount: formatMoney(heroAmount, currencyCode: data.currencyCode),
            hint: data.openRequest != null
                ? l10n.driverPayoutHeroLocked
                : l10n.driverPayoutHeroHint,
          ),
        ),
        const SizedBox(height: 16),
        if (data.openRequest != null) ...[
          _TicketCard(
            title: l10n.driverPayoutOpenTicket,
            status: _statusLabel(l10n, data.openRequest!.status),
            statusTone: data.openRequest!.status == 'approved' ? 'ok' : 'wait',
            amount: formatMoney(data.openRequest!.amount, currencyCode: data.currencyCode),
            date: _fmtDate(data.openRequest!.createdAt),
            body: data.openRequest!.status == 'approved'
                ? l10n.driverPayoutOpenApprovedHint
                : l10n.driverPayoutOpenReviewHint,
          ),
          const SizedBox(height: 16),
        ],
        if (data.canSubmit) ...[
          _SectionLabel(l10n.driverPayoutBreakdownTitle),
          const SizedBox(height: 8),
          _BreakdownCard(
            items: data.items,
            totalLabel: l10n.driverPayoutTotal,
            total: formatMoney(data.collectibleTotal, currencyCode: data.currencyCode),
            sourceOf: (s) => _sourceLabel(l10n, s),
            tripOf: _tripShort,
            dateOf: _fmtDate,
          ),
          const SizedBox(height: 16),
          _QrCollectCard(
            picked: _qrB64 != null,
            busy: _busy,
            title: l10n.driverPayoutQrTitle,
            hint: l10n.driverPayoutQrHint,
            pickLabel: _qrB64 == null
                ? l10n.driverPayoutQrPick
                : l10n.driverPayoutQrPicked,
            submitLabel: l10n.driverPayoutSubmit,
            onPick: _busy ? null : _pickQr,
            onSubmit: (_qrB64 != null && !_busy) ? _submit : null,
          ),
          const SizedBox(height: 24),
        ] else if (data.openRequest == null) ...[
          _EmptyCollect(l10n.driverPayoutEmpty),
          const SizedBox(height: 24),
        ],
        if (data.openRequest != null && data.openRequest!.items.isNotEmpty) ...[
          _SectionLabel(l10n.driverPayoutTicketItems),
          const SizedBox(height: 8),
          _BreakdownCard(
            items: data.openRequest!.items,
            totalLabel: l10n.driverPayoutTotal,
            total: formatMoney(data.openRequest!.amount, currencyCode: data.currencyCode),
            sourceOf: (s) => _sourceLabel(l10n, s),
            tripOf: _tripShort,
            dateOf: _fmtDate,
            muted: true,
          ),
          const SizedBox(height: 24),
        ],
        _SectionLabel(l10n.driverPayoutHistoryTitle),
        const SizedBox(height: 8),
        if (data.history.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              l10n.driverPayoutHistoryEmpty,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          )
        else
          ...data.history.map((h) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HistoryRow(
                status: _statusLabel(l10n, h.status),
                paid: h.isPaid,
                rejected: h.isRejected,
                amount: formatMoney(h.amount, currencyCode: h.currencyCode),
                date: _fmtDate(h.paidAt ?? h.reviewedAt ?? h.createdAt),
                reject: h.isRejected
                    ? [
                        _rejectLabel(l10n, h.rejectReasonCode),
                        if ((h.rejectNote ?? '').trim().isNotEmpty) h.rejectNote!.trim(),
                      ].join(' · ')
                    : null,
              ),
            );
          }),
      ],
    );
  }
}

class _HeroBalance extends StatelessWidget {
  const _HeroBalance({required this.amount, required this.hint});

  final String amount;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppFoundation.radiusXl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1810), Color(0xFF0C0C0C)],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
        boxShadow: AppShadows.soft,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).driverPayoutHeroLabel.toUpperCase(),
              style: TextStyle(
                color: AppColors.primary.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              amount,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 36,
                fontWeight: FontWeight.w800,
                height: 1.05,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              hint,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.title,
    required this.status,
    required this.statusTone,
    required this.amount,
    required this.date,
    required this.body,
  });

  final String title;
  final String status;
  final String statusTone;
  final String amount;
  final String date;
  final String body;

  @override
  Widget build(BuildContext context) {
    final tone = statusTone == 'ok' ? AppColors.success : AppColors.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
        border: Border.all(color: tone.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.confirmation_number_outlined, color: tone, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: tone,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              amount,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(date, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 10),
            Text(
              body,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.items,
    required this.totalLabel,
    required this.total,
    required this.sourceOf,
    required this.tripOf,
    required this.dateOf,
    this.muted = false,
  });

  final List<DriverCompanyPayoutItem> items;
  final String totalLabel;
  final String total;
  final String Function(String) sourceOf;
  final String Function(String) tripOf;
  final String Function(DateTime?) dateOf;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Column(
          children: [
            ...items.map((it) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppLocalizations.of(context).driverPayoutTrip} ${tripOf(it.tripId)}',
                            style: TextStyle(
                              color: muted
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${sourceOf(it.source)} · ${dateOf(it.createdAt)}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatMoney(it.amount),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(color: AppColors.border, height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    totalLabel,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  total,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QrCollectCard extends StatelessWidget {
  const _QrCollectCard({
    required this.picked,
    required this.busy,
    required this.title,
    required this.hint,
    required this.pickLabel,
    required this.submitLabel,
    required this.onPick,
    required this.onSubmit,
  });

  final bool picked;
  final bool busy;
  final String title;
  final String hint;
  final String pickLabel;
  final String submitLabel;
  final VoidCallback? onPick;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hint,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: onPick,
                icon: Icon(
                  picked ? Icons.check_circle_outline : Icons.qr_code_2_rounded,
                  color: AppColors.primary,
                ),
                label: Text(
                  pickLabel,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  disabledBackgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                      )
                    : Text(
                        submitLabel,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCollect extends StatelessWidget {
  const _EmptyCollect(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 22),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.status,
    required this.paid,
    required this.rejected,
    required this.amount,
    required this.date,
    this.reject,
  });

  final String status;
  final bool paid;
  final bool rejected;
  final String amount;
  final String date;
  final String? reject;

  @override
  Widget build(BuildContext context) {
    final tone = paid ? AppColors.success : AppColors.error;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  paid ? Icons.check_circle_outline : Icons.highlight_off_rounded,
                  size: 18,
                  color: tone,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status,
                    style: TextStyle(color: tone, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(date, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            if (reject != null && reject!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                reject!,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.35),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
