import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_foundation.dart';
import '../../core/ui/driver_ui_states.dart';
import '../../gen_l10n/app_localizations.dart';
import '../registration/registration_flow_helpers.dart';
import '../registration/registration_passenger_upgrade_otp_dialog.dart';
import 'driver_password_reset_repository.dart';

enum _ResetPhase { choose, emailCapture, emailCode, newPassword }

class DriverPasswordResetScreen extends StatefulWidget {
  const DriverPasswordResetScreen({
    super.key,
    this.initialCountryCode = '+591',
    this.initialPhoneLocal = '',
  });

  final String initialCountryCode;
  final String initialPhoneLocal;

  @override
  State<DriverPasswordResetScreen> createState() =>
      _DriverPasswordResetScreenState();
}

class _DriverPasswordResetScreenState extends State<DriverPasswordResetScreen> {
  final _repo = DriverPasswordResetRepository();
  final _countryCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();

  _ResetPhase _phase = _ResetPhase.choose;
  String _channel = 'whatsapp_inbound';
  String? _error;
  String? _emailMasked;
  bool _loading = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _countryCodeController.text = widget.initialCountryCode.trim().isEmpty
        ? '+591'
        : widget.initialCountryCode.trim();
    _phoneController.text = widget.initialPhoneLocal;
  }

  @override
  void dispose() {
    _countryCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();
    super.dispose();
  }

  String get _fullPhone {
    final cc = _countryCodeController.text.replaceAll(RegExp(r'[^\d+]'), '');
    final local = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    return '$cc$local';
  }

  InputDecoration _decoration({
    required String label,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      counterText: '',
      filled: true,
      fillColor: AppColors.inputFill.withValues(alpha: 0.92),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
        borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.55)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
        borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.85),
          width: 1.4,
        ),
      ),
    );
  }

  String _mapError(AppLocalizations l10n, DriverPasswordResetException e) {
    return switch (e.code) {
      'DRIVER_PASSWORD_RESET_NOT_FOUND' => l10n.driverPasswordResetErrorNotFound,
      'DRIVER_PASSWORD_RESET_EMAIL_REQUIRED' =>
        l10n.driverPasswordResetErrorEmailRequired,
      'DRIVER_PASSWORD_RESET_OTP_INVALID' =>
        l10n.driverPasswordResetErrorOtpInvalid,
      'DRIVER_PASSWORD_RESET_NOT_VERIFIED' =>
        l10n.driverPasswordResetErrorNotVerified,
      'DRIVER_PASSWORD_RESET_RATE_LIMIT' =>
        l10n.driverPasswordResetErrorRateLimit,
      'PASS_AUTH_WA_NOT_CONFIGURED' => l10n.driverPasswordResetErrorWaUnavailable,
      'ACCOUNT_DELETION_PENDING' => l10n.driverLoginAccountDeletionPendingTitle,
      'DRIVER_PASSWORD_RESET_EMAIL_CONFLICT' =>
        l10n.driverPasswordResetErrorEmailConflict,
      _ => e.message,
    };
  }

  Future<void> _startWhatsApp(AppLocalizations l10n) async {
    if (!isValidBoliviaLocalMobile(_phoneController.text)) {
      setState(() => _error = l10n.driverRegValidationBoliviaPhoneInvalid);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _channel = 'whatsapp_inbound';
    });
    try {
      final challenge = await _repo.start(
        phoneE164: _fullPhone,
        channel: 'whatsapp_inbound',
      );
      if (!mounted) return;
      setState(() => _loading = false);
      final result = await showPassengerUpgradeWhatsAppInboundDialog(
        context: context,
        l10n: l10n,
        waDeepLink: challenge.waDeepLink,
        title: l10n.driverPasswordResetWaTitle,
        body: l10n.driverPasswordResetWaBody,
        waiting: l10n.driverPasswordResetWaWaiting,
        openWhatsAppLabel: l10n.driverRegPassengerUpgradeOpenWhatsApp,
        pollStatus: () => _repo.getChallengeStatus(
          phoneE164: _fullPhone,
          challengeId: challenge.challengeId ?? '',
        ),
      );
      if (!mounted) return;
      if (result == PassengerUpgradeInboundResult.verified) {
        setState(() => _phase = _ResetPhase.newPassword);
        return;
      }
      if (result == PassengerUpgradeInboundResult.expired) {
        setState(() => _error = l10n.driverPasswordResetErrorExpired);
      }
    } on DriverPasswordResetException catch (e) {
      if (!mounted) return;
      if (e.code == 'PASS_AUTH_WA_NOT_CONFIGURED') {
        setState(() {
          _loading = false;
          _channel = 'email';
          _error = _mapError(l10n, e);
        });
        return;
      }
      setState(() {
        _loading = false;
        _error = _mapError(l10n, e);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = l10n.commonError;
      });
    }
  }

  Future<void> _startEmail(AppLocalizations l10n, {String? email}) async {
    if (!isValidBoliviaLocalMobile(_phoneController.text)) {
      setState(() => _error = l10n.driverRegValidationBoliviaPhoneInvalid);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _channel = 'email';
    });
    try {
      final challenge = await _repo.start(
        phoneE164: _fullPhone,
        channel: 'email',
        email: email,
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _emailMasked = challenge.emailMasked;
        _phase = _ResetPhase.emailCode;
      });
    } on DriverPasswordResetException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (e.code == 'DRIVER_PASSWORD_RESET_EMAIL_REQUIRED') {
        setState(() => _phase = _ResetPhase.emailCapture);
        return;
      }
      setState(() => _error = _mapError(l10n, e));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = l10n.commonError;
      });
    }
  }

  Future<void> _submitNewPassword(AppLocalizations l10n) async {
    final pwd = _passwordController.text;
    final pwd2 = _password2Controller.text;
    if (pwd.length < 8) {
      setState(() => _error = l10n.driverRegValidationMin8Chars);
      return;
    }
    if (pwd != pwd2) {
      setState(() => _error = l10n.driverPasswordResetErrorMismatch);
      return;
    }
    if (_channel == 'email' && _codeController.text.trim().length < 4) {
      setState(() => _error = l10n.driverPasswordResetErrorOtpInvalid);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _repo.complete(
        phoneE164: _fullPhone,
        channel: _channel,
        newPassword: pwd,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        emailCode: _channel == 'email' ? _codeController.text.trim() : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.driverPasswordResetSuccess)),
      );
      context.goNamed(AppRouter.login);
    } on DriverPasswordResetException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _mapError(l10n, e);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = l10n.commonError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.driverPasswordResetTitle),
        backgroundColor: AppColors.background,
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
                  switch (_phase) {
                    _ResetPhase.choose => l10n.driverPasswordResetLead,
                    _ResetPhase.emailCapture =>
                      l10n.driverPasswordResetEmailMissingBody,
                    _ResetPhase.emailCode => l10n.driverPasswordResetEmailCodeBody(
                        _emailMasked ?? l10n.driverPasswordResetEmailFallback,
                      ),
                    _ResetPhase.newPassword => l10n.driverPasswordResetNewPasswordBody,
                  },
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.95),
                    height: 1.4,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                if (_phase == _ResetPhase.choose) ...[
                  Row(
                    children: [
                      SizedBox(
                        width: 88,
                        child: TextField(
                          controller: _countryCodeController,
                          readOnly: true,
                          decoration: _decoration(label: l10n.loginCode),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: AppFoundation.spacingMd),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          decoration: _decoration(
                            label: l10n.loginPhone,
                            hint: l10n.driverLoginPhoneHint,
                          ),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            const BoliviaLocalPhoneInputFormatter(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: _loading ? null : () => _startWhatsApp(l10n),
                    icon: const Icon(Icons.chat_rounded),
                    label: Text(l10n.driverPasswordResetWhatsAppCta),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : () => _startEmail(l10n),
                    icon: const Icon(Icons.email_outlined),
                    label: Text(l10n.driverPasswordResetEmailCta),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      foregroundColor: AppColors.textPrimary,
                    ),
                  ),
                ],
                if (_phase == _ResetPhase.emailCapture) ...[
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    maxLength: kDriverEmailMaxLength,
                    inputFormatters: driverEmailInputFormatters(),
                    decoration: _decoration(
                      label: l10n.driverPasswordResetEmailLabel,
                    ).copyWith(counterText: ''),
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _loading
                        ? null
                        : () => _startEmail(
                              l10n,
                              email: _emailController.text.trim(),
                            ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(l10n.driverPasswordResetSendCode),
                  ),
                ],
                if (_phase == _ResetPhase.emailCode) ...[
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _decoration(
                      label: l10n.driverPasswordResetCodeLabel,
                    ).copyWith(counterText: ''),
                  ),
                  const SizedBox(height: 16),
                  _passwordFields(l10n),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _loading ? null : () => _submitNewPassword(l10n),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(l10n.driverPasswordResetSave),
                  ),
                ],
                if (_phase == _ResetPhase.newPassword) ...[
                  _passwordFields(l10n),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _loading ? null : () => _submitNewPassword(l10n),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(l10n.driverPasswordResetSave),
                  ),
                ],
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

  Widget _passwordFields(AppLocalizations l10n) {
    return Column(
      children: [
        TextField(
          controller: _passwordController,
          obscureText: _obscure,
          maxLength: kDriverPasswordMaxLength,
          inputFormatters: driverPasswordInputFormatters(),
          decoration: _decoration(
            label: l10n.driverPasswordResetNewPassword,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _password2Controller,
          obscureText: _obscure,
          maxLength: kDriverPasswordMaxLength,
          inputFormatters: driverPasswordInputFormatters(),
          decoration: _decoration(label: l10n.driverPasswordResetConfirmPassword),
        ),
      ],
    );
  }
}
