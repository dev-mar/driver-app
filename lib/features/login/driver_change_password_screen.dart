import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/session/driver_must_change_password_gate.dart';
import '../../core/session/driver_registration_resume_gate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_foundation.dart';
import '../../core/ui/driver_ui_states.dart';
import '../../gen_l10n/app_localizations.dart';
import '../registration/registration_flow_helpers.dart';
import '../session/driver_operational_profile.dart';
import 'driver_change_password_repository.dart';
import 'driver_login_controller.dart';

/// Tras reset de soporte: el conductor entra con la temporal y crea la suya.
class DriverChangePasswordScreen extends ConsumerStatefulWidget {
  const DriverChangePasswordScreen({super.key});

  @override
  ConsumerState<DriverChangePasswordScreen> createState() =>
      _DriverChangePasswordScreenState();
}

class _DriverChangePasswordScreenState
    extends ConsumerState<DriverChangePasswordScreen> {
  final _repo = DriverChangePasswordRepository();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  InputDecoration _decoration({
    required String label,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
      counterText: '',
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
      ),
    );
  }

  String _mapError(AppLocalizations l10n, DriverChangePasswordException e) {
    return switch (e.code) {
      'DRIVER_PASSWORD_CHANGE_INVALID_CURRENT' =>
        l10n.driverChangePasswordErrorCurrent,
      'DRIVER_PASSWORD_CHANGE_SAME' => l10n.driverChangePasswordErrorSame,
      'DRIVER_PASSWORD_CHANGE_VALIDATION' =>
        l10n.driverRegValidationMin8Chars,
      _ => e.message.isNotEmpty
          ? e.message
          : l10n.driverChangePasswordErrorGeneric,
    };
  }

  Future<void> _submit(AppLocalizations l10n) async {
    final current = _currentController.text;
    final next = _newController.text;
    final confirm = _confirmController.text;
    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      setState(() => _error = l10n.driverChangePasswordErrorGeneric);
      return;
    }
    if (next.length < 8) {
      setState(() => _error = l10n.driverRegValidationMin8Chars);
      return;
    }
    if (next != confirm) {
      setState(() => _error = l10n.driverPasswordResetErrorMismatch);
      return;
    }
    if (current == next) {
      setState(() => _error = l10n.driverChangePasswordErrorSame);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _repo.changePassword(
        currentPassword: current,
        newPassword: next,
      );
      await DriverMustChangePasswordGate.setRequired(false);
      DriverRegistrationResumeGate.invalidate();
      if (!mounted) return;
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.driverChangePasswordSuccess)),
      );
      ref.invalidate(driverOperationalProfileProvider);
      try {
        if (!mounted) return;
        context.go(await DriverRegistrationResumeGate.nextPostAuthLocation());
      } catch (_) {
        if (!mounted) return;
        context.goNamed(AppRouter.home);
      }
    } on DriverChangePasswordException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _mapError(l10n, e);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = l10n.driverChangePasswordErrorGeneric;
      });
    }
  }

  Future<void> _logout() async {
    await ref.read(driverLoginControllerProvider.notifier).logout();
    if (!mounted) return;
    context.goNamed(AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.driverChangePasswordTitle),
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _loading ? null : _logout,
            child: Text(l10n.driverChangePasswordLogout),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.driverChangePasswordLead,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.95),
                    height: 1.4,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _currentController,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  maxLength: kDriverPasswordMaxLength,
                  inputFormatters: driverPasswordInputFormatters(),
                  decoration: _decoration(
                    label: l10n.driverChangePasswordCurrent,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newController,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  maxLength: kDriverPasswordMaxLength,
                  inputFormatters: driverPasswordInputFormatters(),
                  decoration: _decoration(
                    label: l10n.driverChangePasswordNew,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmController,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  maxLength: kDriverPasswordMaxLength,
                  inputFormatters: driverPasswordInputFormatters(),
                  onSubmitted: (_) => _submit(l10n),
                  decoration: _decoration(
                    label: l10n.driverChangePasswordConfirm,
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: _loading ? null : () => _submit(l10n),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(l10n.driverChangePasswordSave),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  DriverInlineError(message: _error!),
                ],
                if (_loading) ...[
                  const SizedBox(height: 20),
                  const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
