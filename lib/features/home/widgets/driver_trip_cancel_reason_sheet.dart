import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../gen_l10n/app_localizations.dart';
import 'driver_trip_cancel_reason.dart';

Future<DriverTripCancelReasonChoice?> showDriverTripCancelReasonSheet({
  required BuildContext context,
  required Future<List<DriverTripCancelReasonItem>> Function() loadReasons,
  required bool connected,
}) {
  return showModalBottomSheet<DriverTripCancelReasonChoice>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppFoundation.radiusXl),
      ),
    ),
    builder: (ctx) => _DriverTripCancelReasonSheet(
      loadReasons: loadReasons,
      connected: connected,
    ),
  );
}

class _DriverTripCancelReasonSheet extends StatefulWidget {
  const _DriverTripCancelReasonSheet({
    required this.loadReasons,
    required this.connected,
  });

  final Future<List<DriverTripCancelReasonItem>> Function() loadReasons;
  final bool connected;

  @override
  State<_DriverTripCancelReasonSheet> createState() =>
      _DriverTripCancelReasonSheetState();
}

class _DriverTripCancelReasonSheetState
    extends State<_DriverTripCancelReasonSheet> {
  bool _loading = true;
  String? _loadError;
  List<DriverTripCancelReasonItem> _items = const [];
  String? _selectedCode;
  final _noteCtrl = TextEditingController();
  bool _confirmStep = false;

  DriverTripCancelReasonItem? get _selected {
    final code = _selectedCode;
    if (code == null) return null;
    for (final item in _items) {
      if (item.code == code) return item;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final items = await widget.loadReasons();
      if (!mounted) return;
      setState(() {
        _items = items
            .where((e) => e.code.isNotEmpty && e.label.isNotEmpty)
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'load';
      });
    }
  }

  bool get _noteOk {
    final item = _selected;
    if (item == null) return false;
    if (!item.requiresNote) return true;
    return _noteCtrl.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppFoundation.spacingLg,
        AppFoundation.spacingMd,
        AppFoundation.spacingLg,
        AppFoundation.spacingXl + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppFoundation.spacingMd),
          Text(
            _confirmStep
                ? l10n.driverTripCancelConfirmTitle
                : l10n.driverTripCancelChooseReason,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppFoundation.spacingSm),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_loadError != null)
            Column(
              children: [
                Text(l10n.driverTripCancelReasonsLoadError),
                const SizedBox(height: AppFoundation.spacingSm),
                OutlinedButton(
                  onPressed: _load,
                  child: Text(l10n.driverTripCancelRetry),
                ),
              ],
            )
          else if (_items.isEmpty)
            Text(l10n.driverTripCancelReasonsEmpty)
          else if (!_confirmStep) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final item in _items)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        _selectedCode == item.code
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: AppColors.primary,
                      ),
                      title: Text(item.label),
                      onTap: () => setState(() => _selectedCode = item.code),
                    ),
                ],
              ),
            ),
            if (_selected?.requiresNote == true) ...[
              const SizedBox(height: AppFoundation.spacingSm),
              TextField(
                controller: _noteCtrl,
                maxLength: 400,
                maxLines: 3,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l10n.driverTripCancelNoteHint,
                ),
              ),
            ],
            const SizedBox(height: AppFoundation.spacingMd),
            FilledButton(
              onPressed: _selectedCode != null && _noteOk
                  ? () {
                      HapticFeedback.lightImpact();
                      setState(() => _confirmStep = true);
                    }
                  : null,
              child: Text(l10n.driverTripCancelContinue),
            ),
          ] else ...[
            Text(
              _selected?.confirmText.isNotEmpty == true
                  ? _selected!.confirmText
                  : l10n.driverTripCancelConfirmFallback,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            if (!widget.connected) ...[
              const SizedBox(height: AppFoundation.spacingSm),
              Text(
                l10n.driverTripCancelNeedConnection,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
            const SizedBox(height: AppFoundation.spacingMd),
            FilledButton(
              onPressed: widget.connected && _selected != null
                  ? () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop(
                        DriverTripCancelReasonChoice(
                          code: _selected!.code,
                          note: _noteCtrl.text.trim().isEmpty
                              ? null
                              : _noteCtrl.text.trim(),
                        ),
                      );
                    }
                  : null,
              child: Text(l10n.driverTripCancelConfirm),
            ),
            TextButton(
              onPressed: () => setState(() => _confirmStep = false),
              child: Text(l10n.driverTripCancelBack),
            ),
          ],
        ],
      ),
    );
  }
}
