import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../gen_l10n/app_localizations.dart';

Future<String?> showPassengerUpgradeOtpDialog({
  required BuildContext context,
  required AppLocalizations l10n,
}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        title: Text(l10n.driverRegPassengerUpgradeTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.driverRegPassengerUpgradeBodyCode),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              maxLength: 8,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.driverRegPassengerUpgradeCodeHint,
                counterText: '',
              ),
              onSubmitted: (value) {
                final code = value.trim();
                if (code.length >= 4) Navigator.of(ctx).pop(code);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () {
              final code = controller.text.trim();
              if (code.length < 4) return;
              Navigator.of(ctx).pop(code);
            },
            child: Text(l10n.driverRegPassengerUpgradeConfirm),
          ),
        ],
      );
    },
  ).whenComplete(controller.dispose);
}

enum PassengerUpgradeInboundResult { verified, cancelled, expired }

Future<PassengerUpgradeInboundResult?> showPassengerUpgradeWhatsAppInboundDialog({
  required BuildContext context,
  required AppLocalizations l10n,
  required String? waDeepLink,
  required Future<String?> Function() pollStatus,
  String? title,
  String? body,
  String? waiting,
  String? openWhatsAppLabel,
}) {
  return showDialog<PassengerUpgradeInboundResult>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return _PassengerUpgradeInboundDialog(
        l10n: l10n,
        waDeepLink: waDeepLink,
        pollStatus: pollStatus,
        title: title,
        body: body,
        waiting: waiting,
        openWhatsAppLabel: openWhatsAppLabel,
      );
    },
  );
}

class _PassengerUpgradeInboundDialog extends StatefulWidget {
  const _PassengerUpgradeInboundDialog({
    required this.l10n,
    required this.waDeepLink,
    required this.pollStatus,
    this.title,
    this.body,
    this.waiting,
    this.openWhatsAppLabel,
  });

  final AppLocalizations l10n;
  final String? waDeepLink;
  final Future<String?> Function() pollStatus;
  final String? title;
  final String? body;
  final String? waiting;
  final String? openWhatsAppLabel;

  @override
  State<_PassengerUpgradeInboundDialog> createState() =>
      _PassengerUpgradeInboundDialogState();
}

class _PassengerUpgradeInboundDialogState
    extends State<_PassengerUpgradeInboundDialog>
    with WidgetsBindingObserver {
  Timer? _pollTimer;
  bool _opening = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_openWhatsApp());
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_poll());
    }
  }

  Future<void> _openWhatsApp() async {
    final link = widget.waDeepLink?.trim();
    if (link == null || link.isEmpty) return;
    final uri = Uri.tryParse(link);
    if (uri == null) return;
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await HapticFeedback.lightImpact();
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // El usuario puede reintentar con el botón.
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _poll() async {
    if (!mounted || _done) return;
    final status = await widget.pollStatus();
    if (!mounted || _done) return;
    if (status == 'verified') {
      _done = true;
      _pollTimer?.cancel();
      Navigator.of(context).pop(PassengerUpgradeInboundResult.verified);
      return;
    }
    if (status == 'expired') {
      _done = true;
      _pollTimer?.cancel();
      Navigator.of(context).pop(PassengerUpgradeInboundResult.expired);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(widget.title ?? l10n.driverRegPassengerUpgradeTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.body ?? l10n.driverRegPassengerUpgradeBody),
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(widget.waiting ?? l10n.driverRegPassengerUpgradeWaiting),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _done = true;
            Navigator.of(context).pop(PassengerUpgradeInboundResult.cancelled);
          },
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _opening ? null : () => unawaited(_openWhatsApp()),
          child: Text(
            widget.openWhatsAppLabel ?? l10n.driverRegPassengerUpgradeOpenWhatsApp,
          ),
        ),
      ],
    );
  }
}
