import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../registration_device_email.dart';
import '../registration_flow_helpers.dart';

/// Correo obligatorio: Autofill del dispositivo + escritura manual.
class RegistrationEmailField extends StatefulWidget {
  const RegistrationEmailField({
    super.key,
    required this.controller,
    required this.l10n,
    required this.onChanged,
  });

  final TextEditingController controller;
  final AppLocalizations l10n;
  final VoidCallback onChanged;

  @override
  State<RegistrationEmailField> createState() => _RegistrationEmailFieldState();
}

class _RegistrationEmailFieldState extends State<RegistrationEmailField> {
  final _focus = FocusNode();
  bool _picking = false;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  Future<void> _pickFromDevice() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final picked = await pickDeviceAccountEmail();
      if (!mounted) return;
      if (picked != null) {
        widget.controller.text = picked;
        widget.controller.selection =
            TextSelection.collapsed(offset: picked.length);
        widget.onChanged();
        return;
      }
      _focus.requestFocus();
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return TextFormField(
      controller: widget.controller,
      focusNode: _focus,
      decoration: InputDecoration(
        labelText: l10n.driverRegFieldEmail,
        suffixIconConstraints: const BoxConstraints(minWidth: 72, minHeight: 48),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            tooltip: l10n.driverRegEmailPickFromDevice,
            onPressed: _picking ? null : () => unawaited(_pickFromDevice()),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              foregroundColor: AppColors.primary,
              minimumSize: const Size(44, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: _picking
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.alternate_email_rounded, size: 16),
                      Icon(Icons.arrow_drop_down_rounded, size: 26),
                    ],
                  ),
          ),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      enableSuggestions: true,
      textCapitalization: TextCapitalization.none,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
      ],
      validator: (v) {
        final raw = (v ?? '').trim();
        if (raw.isEmpty) return l10n.driverRegValidationRequired;
        if (!isValidRegistrationEmail(raw)) {
          return l10n.driverRegValidationEmailInvalid;
        }
        return null;
      },
      onChanged: (_) => widget.onChanged(),
    );
  }
}
