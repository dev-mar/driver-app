import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_foundation.dart';
import '../../core/ui/driver_secondary_scaffold.dart';
import '../../core/utils/money_formatter.dart';
import '../../gen_l10n/app_localizations.dart';
import 'driver_credits_topup_models.dart';
import 'driver_credits_topup_repository.dart';
import 'driver_topup_qr_export.dart';
import 'driver_topup_receipt_picker.dart';

/// Pantalla independiente de recargas: paquetes QR, comprobante e historial.
class DriverCreditsTopupScreen extends StatefulWidget {
  const DriverCreditsTopupScreen({super.key});

  @override
  State<DriverCreditsTopupScreen> createState() =>
      _DriverCreditsTopupScreenState();
}

class _DriverCreditsTopupScreenState extends State<DriverCreditsTopupScreen> {
  final _repo = DriverCreditsTopupRepository();
  final _originAccountCtrl = TextEditingController();
  final _transactionRefCtrl = TextEditingController();
  DriverTopupCatalog? _catalog;
  bool _loading = true;
  bool _busy = false;
  bool _qrBusy = false;
  String? _selectedPackageId;
  String? _receiptB64;
  String? _error;

  @override
  void initState() {
    super.initState();
    _originAccountCtrl.addListener(_onTransferChanged);
    _transactionRefCtrl.addListener(_onTransferChanged);
    _reload();
  }

  @override
  void dispose() {
    _originAccountCtrl.removeListener(_onTransferChanged);
    _transactionRefCtrl.removeListener(_onTransferChanged);
    _originAccountCtrl.dispose();
    _transactionRefCtrl.dispose();
    super.dispose();
  }

  void _onTransferChanged() {
    if (!mounted) return;
    final typingTransfer = _originAccountCtrl.text.trim().isNotEmpty ||
        _transactionRefCtrl.text.trim().isNotEmpty;
    if (typingTransfer && _receiptB64 != null) {
      setState(() => _receiptB64 = null);
      return;
    }
    setState(() {});
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cat = await _repo.fetchCatalog();
      if (!mounted) return;
      setState(() {
        _catalog = cat;
        _loading = false;
        if (cat != null &&
            cat.packages.isNotEmpty &&
            (_selectedPackageId == null ||
                !cat.packages.any((p) => p.id == _selectedPackageId))) {
          _selectedPackageId = cat.packages.first.id;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _catalog = null;
      });
    }
  }

  DriverTopupPackage? get _selected {
    final id = _selectedPackageId;
    if (id == null) return null;
    final list = _catalog?.packages ?? const [];
    for (final p in list) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> _shareQr(DriverTopupPackage pkg) async {
    if (_qrBusy) return;
    HapticFeedback.lightImpact();
    setState(() => _qrBusy = true);
    try {
      final file = await downloadDriverTopupQrFile(pkg);
      await shareDriverTopupQrFile(file, pkg);
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.driverTopupShareFailed)),
      );
    } finally {
      if (mounted) setState(() => _qrBusy = false);
    }
  }

  Future<void> _saveQr(DriverTopupPackage pkg) async {
    if (_qrBusy) return;
    HapticFeedback.lightImpact();
    setState(() => _qrBusy = true);
    final l10n = AppLocalizations.of(context);
    try {
      final file = await downloadDriverTopupQrFile(pkg);
      final result = await saveDriverTopupQrToGallery(file);
      if (!mounted) return;
      if (result == DriverTopupQrSaveResult.permissionDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.driverTopupSavePermissionDenied)),
        );
        return;
      }
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.driverTopupSaveOk)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.driverTopupSaveFailed)),
      );
    } finally {
      if (mounted) setState(() => _qrBusy = false);
    }
  }

  bool get _transferValid {
    final origin = _originAccountCtrl.text.trim();
    final tx = _transactionRefCtrl.text.trim();
    return origin.length >= kDriverTopupTransferFieldMinLength &&
        tx.length >= kDriverTopupTransferFieldMinLength;
  }

  bool get _hasEvidence =>
      (_receiptB64 != null && _receiptB64!.isNotEmpty) || _transferValid;

  Future<void> _pickReceipt() async {
    final result = await pickDriverTopupReceiptFromDevice(context);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (result.ok) {
      _originAccountCtrl.removeListener(_onTransferChanged);
      _transactionRefCtrl.removeListener(_onTransferChanged);
      _originAccountCtrl.clear();
      _transactionRefCtrl.clear();
      _originAccountCtrl.addListener(_onTransferChanged);
      _transactionRefCtrl.addListener(_onTransferChanged);
      setState(() => _receiptB64 = result.base64Jpeg);
      return;
    }
    if (result.error == DriverTopupReceiptPickError.canceled) return;
    final msg = switch (result.error) {
      DriverTopupReceiptPickError.tooLarge => l10n.driverTopupReceiptTooLarge,
      DriverTopupReceiptPickError.invalidType => l10n.driverTopupReceiptInvalidType,
      DriverTopupReceiptPickError.compressFailed =>
        l10n.driverTopupReceiptCompressFailed,
      _ => l10n.driverTopupReceiptInvalidType,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    final cat = _catalog;
    final pkg = _selected;
    if (cat == null || pkg == null) return;
    if (!_hasEvidence) {
      setState(() => _error = AppLocalizations.of(context).driverTopupNeedEvidence);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final useTransfer = _transferValid;
      String? key;
      if (!useTransfer) {
        final b64 = _receiptB64;
        if (b64 != null && b64.isNotEmpty) {
          key = await _repo.uploadReceiptBase64(b64);
          if (!mounted) return;
          if (key == null || key.isEmpty) {
            throw DriverTopupException(
              'DRIVER_TOPUP_UPLOAD',
              AppLocalizations.of(context).driverTopupUploadFailed,
            );
          }
        }
      }
      await _repo.submitTicket(
        packageId: pkg.id,
        receiptStorageKey: useTransfer ? null : key,
        originAccount: useTransfer ? _originAccountCtrl.text.trim() : null,
        transactionRef: useTransfer ? _transactionRefCtrl.text.trim() : null,
      );
      if (!mounted) return;
      setState(() {
        _receiptB64 = null;
        _originAccountCtrl.clear();
        _transactionRefCtrl.clear();
        _busy = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).driverTopupSubmitted)),
      );
      await _reload();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e is DriverTopupException
            ? e.message
            : AppLocalizations.of(context).driverTopupSubmitFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DriverSecondaryScaffold(
      title: l10n.driverTopupScreenTitle,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppFoundation.spacingLg,
                  8,
                  AppFoundation.spacingLg,
                  32,
                ),
                children: [
                  ..._buildBody(l10n),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildBody(AppLocalizations l10n) {
    final cat = _catalog;
    if (cat == null) {
      return [
        _EmptyStateCard(
          title: l10n.driverTopupUnavailableTitle,
          body: l10n.driverTopupUnavailableBody,
          action: l10n.driverTopupHistoryRetry,
          onAction: _reload,
        ),
      ];
    }
    final canShowPackages = cat.enabled && cat.packages.isNotEmpty;
    final pkg = _selected;
    final pending = cat.pendingTicket != null || cat.blockReason == 'pending';
    final blocked = !cat.canSubmit;
    return [
      Text(
        cat.helpText?.trim().isNotEmpty == true
            ? cat.helpText!
            : l10n.driverTopupSectionHint,
        style: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.95),
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.4,
        ),
      ),
      const SizedBox(height: AppFoundation.spacingXl),
      if (!canShowPackages)
        _EmptyStateCard(
          title: l10n.driverTopupUnavailableTitle,
          body: l10n.driverTopupUnavailableBody,
        )
      else ...[
        _StepCard(
          step: '1',
          title: l10n.driverTopupStepAmount,
          child: Column(
            children: [
              for (var i = 0; i < cat.packages.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _AmountTile(
                  package: cat.packages[i],
                  selected: cat.packages[i].id == _selectedPackageId,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedPackageId = cat.packages[i].id);
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppFoundation.spacingLg),
        if (pkg != null)
          _StepCard(
            step: '2',
            title: l10n.driverTopupStepPay,
            child: Column(
              children: [
                if (pkg.qrImageUrl != null && pkg.qrImageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
                    child: Image.network(
                      pkg.qrImageUrl!,
                      height: 240,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.qr_code_2_rounded,
                        color: AppColors.primary,
                        size: 88,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.qr_code_2_rounded,
                    color: AppColors.primary,
                    size: 88,
                  ),
                const SizedBox(height: 12),
                Text(
                  formatMoney(pkg.amount, decimals: pkg.amount % 1 == 0 ? 0 : 2),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    letterSpacing: -0.6,
                  ),
                ),
                if ((pkg.instructions ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    pkg.instructions!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _qrBusy ? null : () => _saveQr(pkg),
                        icon: const Icon(Icons.save_alt_rounded),
                        label: Text(l10n.driverTopupSaveQr),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          minimumSize: const Size(48, 52),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.55),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppFoundation.radiusMd),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _qrBusy ? null : () => _shareQr(pkg),
                        icon: const Icon(Icons.ios_share_rounded),
                        label: Text(l10n.driverTopupShareQr),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          minimumSize: const Size(48, 52),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.55),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppFoundation.radiusMd),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: AppFoundation.spacingLg),
        if (pending)
          _PendingBanner(l10n: l10n)
        else
          _StepCard(
            step: '3',
            title: l10n.driverTopupStepProof,
            subtitle: cat.blockReason == 'daily_limit'
                ? l10n.driverTopupDailyLimitHint(cat.maxSubmitsPerDay)
                : l10n.driverTopupReceiptHint,
            child: blocked
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        onPressed: _busy ? null : _pickReceipt,
                        icon: Icon(
                          _receiptB64 == null
                              ? Icons.photo_library_outlined
                              : Icons.check_circle_rounded,
                        ),
                        label: Text(
                          _receiptB64 == null
                              ? l10n.driverTopupPickReceipt
                              : l10n.driverTopupReceiptPicked,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: _receiptB64 != null
                              ? AppColors.primary
                              : AppColors.surface,
                          foregroundColor: _receiptB64 != null
                              ? AppColors.onPrimary
                              : AppColors.textPrimary,
                          minimumSize: const Size(48, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppFoundation.radiusMd),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(child: Divider(height: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              l10n.driverTopupOrDivider,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(height: 1)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: _receiptB64 != null ? 0.55 : 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(
                              AppFoundation.radiusMd,
                            ),
                            border: Border.all(
                              width: _transferValid ? 1.6 : 1,
                              color: _transferValid
                                  ? AppColors.primary.withValues(alpha: 0.55)
                                  : AppColors.border.withValues(alpha: 0.85),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  l10n.driverTopupTransferTitle,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _originAccountCtrl,
                                  enabled: !_busy,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  maxLength: kDriverTopupOriginAccountMaxLength,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.inputFill,
                                    labelText:
                                        l10n.driverTopupOriginAccountLabel,
                                    hintText: l10n.driverTopupOriginAccountHint,
                                    prefixIcon: const Icon(
                                      Icons.smartphone_rounded,
                                    ),
                                    counterText: '',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppFoundation.radiusMd,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _transactionRefCtrl,
                                  enabled: !_busy,
                                  minLines: 3,
                                  maxLines: 5,
                                  textInputAction: TextInputAction.newline,
                                  maxLength:
                                      kDriverTopupTransactionRefMaxLength,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.inputFill,
                                    alignLabelWithHint: true,
                                    labelText:
                                        l10n.driverTopupTransactionRefLabel,
                                    hintText:
                                        l10n.driverTopupTransactionRefHint,
                                    counterText: '',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppFoundation.radiusMd,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed:
                            (_busy || !_hasEvidence || pkg == null) ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          minimumSize: const Size(48, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppFoundation.radiusMd),
                          ),
                        ),
                        child: _busy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                l10n.driverTopupSubmit,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ],
                  ),
          ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: const TextStyle(color: AppColors.error)),
        ],
      ],
      const SizedBox(height: AppFoundation.spacing2xl),
      Text(
        l10n.driverTopupHistoryTitle,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
        ),
      ),
      const SizedBox(height: 10),
      if (cat.tickets.isEmpty)
        Text(
          l10n.driverTopupHistoryEmpty,
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.9),
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        )
      else
        ...cat.tickets.map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _HistoryRow(ticket: t),
          ),
        ),
    ];
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String step;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  step,
                  style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.95),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({
    required this.package,
    required this.selected,
    required this.onTap,
  });

  final DriverTopupPackage package;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.18)
          : AppColors.surface,
      borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.border.withValues(alpha: 0.45),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  package.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                formatMoney(
                  package.amount,
                  decimals: package.amount % 1 == 0 ? 0 : 2,
                ),
                style: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingBanner extends StatelessWidget {
  const _PendingBanner({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.hourglass_top_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.driverTopupPendingTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.driverTopupPendingHint,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.95),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.ticket});

  final DriverTopupTicket ticket;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = ticket.status == 'credited'
        ? AppColors.success
        : ticket.status == 'rejected'
            ? AppColors.error
            : AppColors.primary;
    final label = ticket.status == 'credited'
        ? l10n.driverTopupStatusCredited
        : ticket.status == 'rejected'
            ? l10n.driverTopupStatusRejected
            : l10n.driverTopupStatusPending;
    final when = ticket.createdAt;
    final locale = Localizations.localeOf(context).toString();
    final dateText = when == null
        ? '—'
        : DateFormat.yMMMd(locale).add_jm().format(when.toLocal());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateText,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatMoney(
                    ticket.declaredAmount,
                    decimals: ticket.declaredAmount % 1 == 0 ? 0 : 2,
                  ),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.title,
    required this.body,
    this.action,
    this.onAction,
  });

  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
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
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.95),
              height: 1.35,
            ),
          ),
          if (action != null && onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(action!)),
          ],
        ],
      ),
    );
  }
}
