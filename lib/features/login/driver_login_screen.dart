import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_foundation.dart';
import '../../core/theme/app_motion.dart';
import '../../core/router/app_router.dart';
import '../../core/session/driver_internal_tools_gate.dart';
import '../../core/session/driver_must_change_password_gate.dart';
import '../../core/version/driver_app_version_gate.dart';
import '../../core/ui/driver_ui_states.dart';
import '../../gen_l10n/app_localizations.dart';
import '../session/driver_operational_profile.dart';
import '../../core/compliance/driver_login_legal_footer.dart';
import '../settings/widgets/driver_settings_legal_section.dart';
import 'driver_login_controller.dart';
import 'driver_realtime_controller.dart';

/// Pantalla de login para conductores: teléfono (+591) y contraseña.
class DriverLoginScreen extends ConsumerStatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  ConsumerState<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends ConsumerState<DriverLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _countryCodeController = TextEditingController(text: '+591');
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showValidationErrors = false;
  int _loadingTick = 0;
  Timer? _loadingTimer;
  String? _errorMessage;

  late final AnimationController _entrance;
  late final Animation<double> _entranceFade;
  late final Animation<Offset> _entranceSlide;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: AppMotion.screenEntrance,
    );
    _entranceFade = CurvedAnimation(
      parent: _entrance,
      curve: AppMotion.standard,
    );
    _entranceSlide = Tween<Offset>(
      begin: Offset(0, AppMotion.slideDySubtle + 0.02),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrance, curve: AppMotion.standard));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _entrance.forward();
      unawaited(DriverAppVersionGate.runStartupCheck(context));
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _loadingTimer?.cancel();
    _countryCodeController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    final l10n = AppLocalizations.of(context);

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() => _showValidationErrors = true);
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
      _loadingTick = 0;
    });
    _loadingTimer?.cancel();
    _loadingTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted || !_isLoading) return;
      setState(() => _loadingTick++);
    });

    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final countryCode = _countryCodeController.text.trim();

    final fullPhone =
        countryCode.replaceAll(RegExp(r'[^\d+]'), '') + phone.replaceAll(RegExp(r'[^\d]'), '');

    final success = await ref.read(driverLoginControllerProvider.notifier).login(
          fullPhone: fullPhone,
          password: password,
        );

    if (!mounted) return;
    _loadingTimer?.cancel();

    if (success) {
      ref.invalidate(driverOperationalProfileProvider);
      ref.invalidate(driverInternalToolsVisibleProvider);
      ref.invalidate(driverRealtimeProvider);
      if (await DriverMustChangePasswordGate.needsChange()) {
        if (!mounted) return;
        context.goNamed(AppRouter.changePassword);
        return;
      }
      try {
        final profile = await ref.read(driverOperationalProfileProvider.future);
        if (profile.shouldForceRegistrationWizard) {
          if (!mounted) return;
          context.go('/register?resumeAfterLogin=1');
          return;
        }
      } catch (_) {
        // Sin perfil operativo: home y el usuario reintenta.
      }
      if (!mounted) return;
      context.goNamed(AppRouter.home);
    } else {
      setState(() {
        _isLoading = false;
        _loadingTick = 0;
        final loginState = ref.read(driverLoginControllerProvider);
        if (loginState.errorCode == 'ACCOUNT_DELETION_PENDING') {
          _errorMessage = null;
        } else {
          _errorMessage = switch (loginState.errorCode) {
            'NETWORK_TIMEOUT' => l10n.driverLoginErrorNetwork,
            'NETWORK_CONNECTION' => l10n.driverLoginErrorConnection,
            'NETWORK_REQUEST_FAILED' => l10n.driverLoginErrorNetwork,
            'CLIENT_INVALID_RESPONSE' => l10n.driverLoginErrorInvalidResponse,
            'CLIENT_EMPTY_DATA' => l10n.driverLoginErrorInvalidResponse,
            'CLIENT_TOKEN_MISSING' => l10n.driverLoginErrorTokenMissing,
            'CLIENT_UNEXPECTED' => l10n.driverLoginErrorUnexpected,
            'AUTH_ACCOUNT_BLOCKED' => l10n.driverLoginErrorAccountBlocked,
            'SESSION_SUPERSEDED' => l10n.driverLoginErrorSessionSuperseded,
            'TRIP_OPERATIONAL_LOCK' => l10n.driverLoginErrorTripOperationalLock,
            'DEVICE_BOUND_TO_OTHER' => l10n.driverLoginErrorDeviceBound,
            _ => loginState.errorMessage ?? l10n.driverLoginErrorGeneric,
          };
        }
      });
      if (!mounted) return;
      final loginState = ref.read(driverLoginControllerProvider);
      if (loginState.errorCode == 'ACCOUNT_DELETION_PENDING') {
        await _showAccountDeletionPendingDialog(
          fullPhone: fullPhone,
          password: password,
          accountDeletion: loginState.accountDeletion,
        );
      }
    }
  }

  Future<void> _showAccountDeletionPendingDialog({
    required String fullPhone,
    required String password,
    Map<String, dynamic>? accountDeletion,
  }) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final effectiveRaw = accountDeletion?['deletion_effective_at']?.toString();
    final effectiveDate = formatDriverAccountDeletionDate(context, effectiveRaw) ??
        l10n.driverLoginAccountDeletionPendingDateFallback;

    final recover = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          icon: Icon(Icons.schedule_send_outlined, color: AppColors.primary),
          title: Text(l10n.driverLoginAccountDeletionPendingTitle),
          content: Text(l10n.driverLoginAccountDeletionPendingBody(effectiveDate)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.driverLoginAccountDeletionDismiss),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.driverLoginAccountDeletionRecover),
            ),
          ],
        );
      },
    );

    if (recover != true || !mounted) return;

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final recovered = await ref
        .read(driverLoginControllerProvider.notifier)
        .recoverAccountFromPendingDeletion(
          fullPhone: fullPhone,
          password: password,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (recovered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.driverLoginAccountDeletionRecoverSuccess)),
      );
      ref.invalidate(driverOperationalProfileProvider);
      ref.invalidate(driverInternalToolsVisibleProvider);
      ref.invalidate(driverRealtimeProvider);
      context.goNamed(AppRouter.home);
      return;
    }

    final loginState = ref.read(driverLoginControllerProvider);
    setState(() {
      _errorMessage = loginState.errorMessage ?? l10n.driverLoginErrorGeneric;
    });
  }

  InputDecoration _fieldDecoration({
    required String label,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
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
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.85), width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loadingMessage = switch (_loadingTick % 3) {
      0 => '${l10n.commonLoading}...',
      1 => 'Validando credenciales...',
      _ => 'Conectando tu perfil...'
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.loginBackground,
            fit: BoxFit.cover,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.28),
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.88),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: FadeTransition(
                  opacity: _entranceFade,
                  child: SlideTransition(
                    position: _entranceSlide,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: _showValidationErrors
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12),
                            Center(
                              child: Image.asset(
                                AppAssets.authLogo,
                                width: 88,
                                height: 88,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              l10n.driverLoginWelcome,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textPrimary.withValues(alpha: 0.95),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Center(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(
                                    l10n.driverLoginRegisterBannerTitle,
                                    style: TextStyle(
                                      color: AppColors.textSecondary.withValues(alpha: 0.95),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => context.goNamed(AppRouter.register),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 10,
                                      ),
                                      minimumSize: const Size(48, 48),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      l10n.driverLoginRegisterCta,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                        decorationThickness: 1.1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.driverLoginSubtitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary.withValues(alpha: 0.95),
                                    height: 1.4,
                                    fontSize: 13.5,
                                  ),
                            ),
                            const SizedBox(height: 22),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppFoundation.radiusXl),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceCard.withValues(alpha: 0.78),
                                    borderRadius:
                                        BorderRadius.circular(AppFoundation.radiusXl),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 88,
                                              child: TextFormField(
                                                controller: _countryCodeController,
                                                decoration: _fieldDecoration(
                                                  label: l10n.loginCode,
                                                  hint: l10n.driverLoginCountryCodeHint,
                                                ),
                                                keyboardType: TextInputType.phone,
                                                readOnly: true,
                                              ),
                                            ),
                                            const SizedBox(width: AppFoundation.spacingMd),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _phoneController,
                                                decoration: _fieldDecoration(
                                                  label: l10n.loginPhone,
                                                  hint: l10n.driverLoginPhoneHint,
                                                ),
                                                keyboardType: TextInputType.phone,
                                                autofillHints: const [
                                                  AutofillHints.telephoneNumber
                                                ],
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.digitsOnly
                                                ],
                                                validator: (v) {
                                                  final d = (v ?? '')
                                                      .replaceAll(RegExp(r'\D'), '');
                                                  if (d.isEmpty) {
                                                    return l10n
                                                        .driverLoginPhoneAndPasswordRequired;
                                                  }
                                                  if (d.length < 6) {
                                                    return l10n
                                                        .driverRegValidationIncompleteNumber;
                                                  }
                                                  return null;
                                                },
                                                onFieldSubmitted: (_) => _submit(),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppFoundation.spacingLg),
                                        TextFormField(
                                          controller: _passwordController,
                                          decoration: _fieldDecoration(
                                            label: l10n.driverLoginPassword,
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                setState(
                                                  () => _obscurePassword = !_obscurePassword,
                                                );
                                              },
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_outlined
                                                    : Icons.visibility_off_outlined,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                          obscureText: _obscurePassword,
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return l10n
                                                  .driverLoginPhoneAndPasswordRequired;
                                            }
                                            if (v.length < 8) {
                                              return l10n.driverRegValidationMin8Chars;
                                            }
                                            return null;
                                          },
                                          onFieldSubmitted: (_) => _submit(),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: _isLoading
                                                ? null
                                                : () {
                                                    context.pushNamed(
                                                      AppRouter.forgotPassword,
                                                      extra: <String, String>{
                                                        'countryCode':
                                                            _countryCodeController
                                                                .text
                                                                .trim(),
                                                        'phoneLocal':
                                                            _phoneController
                                                                .text
                                                                .trim(),
                                                      },
                                                    );
                                                  },
                                            style: TextButton.styleFrom(
                                              foregroundColor: AppColors.primary,
                                              minimumSize: const Size(48, 48),
                                              tapTargetSize:
                                                  MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            child: Text(
                                              l10n.driverPasswordResetForgotLink,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (_errorMessage != null) ...[
                                          const SizedBox(height: AppFoundation.spacingLg),
                                          DriverInlineError(message: _errorMessage!),
                                        ],
                                        const SizedBox(height: 22),
                                        SizedBox(
                                          height: 52,
                                          width: double.infinity,
                                          child: FilledButton(
                                            onPressed: _isLoading ? null : _submit,
                                            style: FilledButton.styleFrom(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                  AppFoundation.radiusMd,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  l10n.driverLoginButton,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15.5,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  Icons.arrow_forward_rounded,
                                                  size: 18,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            DriverLoginLegalFooter(
                              textColor: AppColors.textSecondary.withValues(alpha: 0.85),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                color: Colors.black.withValues(alpha: 0.52),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 36),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.8,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          loadingMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
