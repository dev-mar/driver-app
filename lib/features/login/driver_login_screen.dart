import 'dart:async';

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
import '../../core/ui/driver_ui_states.dart';
import '../../gen_l10n/app_localizations.dart';
import '../session/driver_operational_profile.dart';
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
      if (mounted) _entrance.forward();
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
      try {
        final profile = await ref.read(driverOperationalProfileProvider.future);
        if (profile.needsResumeRegistration) {
          if (!mounted) return;
          context.go('/register?resumeAfterLogin=1');
          return;
        }
        if (profile.needsVehicleRegistration) {
          if (!mounted) return;
          context.goNamed(AppRouter.register, extra: true);
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
        _errorMessage = switch (loginState.errorCode) {
          'NETWORK_TIMEOUT' => l10n.driverLoginErrorNetwork,
          'NETWORK_CONNECTION' => l10n.driverLoginErrorConnection,
          'NETWORK_REQUEST_FAILED' => l10n.driverLoginErrorNetwork,
          'CLIENT_INVALID_RESPONSE' => l10n.driverLoginErrorInvalidResponse,
          'CLIENT_EMPTY_DATA' => l10n.driverLoginErrorInvalidResponse,
          'CLIENT_TOKEN_MISSING' => l10n.driverLoginErrorTokenMissing,
          'CLIENT_UNEXPECTED' => l10n.driverLoginErrorUnexpected,
          _ => loginState.errorMessage ?? l10n.driverLoginErrorGeneric,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final registerCta = l10n.driverLoginRegisterCta;
    final loadingMessage = switch (_loadingTick % 3) {
      0 => '${l10n.commonLoading}...',
      1 => 'Validando credenciales...',
      _ => 'Conectando tu perfil...'
    };

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.loginBackground,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.75),
                  Colors.black,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppFoundation.spacing2xl),
                child: FadeTransition(
                  opacity: _entranceFade,
                  child: SlideTransition(
                    position: _entranceSlide,
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _showValidationErrors
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppFoundation.spacingLg),
                          // Logo superior
                          Center(
                        child: Image.asset(
                          AppAssets.authLogo,
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: AppFoundation.spacing2xl),
                      Text(
                        l10n.driverLoginWelcome,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppFoundation.spacingSm),
                      Text(
                        l10n.driverLoginSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 90,
                            child: TextFormField(
                              controller: _countryCodeController,
                              decoration: InputDecoration(
                                labelText: l10n.loginCode,
                                hintText: l10n.driverLoginCountryCodeHint,
                              ),
                              keyboardType: TextInputType.phone,
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: AppFoundation.spacingMd),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: l10n.loginPhone,
                                hintText: l10n.driverLoginPhoneHint,
                              ),
                              keyboardType: TextInputType.phone,
                              autofillHints: const [AutofillHints.telephoneNumber],
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (v) {
                                final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
                                if (d.isEmpty) return l10n.driverLoginPhoneAndPasswordRequired;
                                if (d.length < 6) return l10n.driverRegValidationIncompleteNumber;
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
                        decoration: InputDecoration(
                          labelText: l10n.driverLoginPassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.driverLoginPhoneAndPasswordRequired;
                          }
                          if (v.length < 8) return l10n.driverRegValidationMin8Chars;
                          return null;
                        },
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: AppFoundation.spacingLg),
                        DriverInlineError(
                          message: _errorMessage!,
                        ),
                      ],
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _submit,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(l10n.driverLoginButton),
                              const SizedBox(width: AppFoundation.spacingSm),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppFoundation.spacingSm),
                      const SizedBox(height: AppFoundation.spacingXl),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.22),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withValues(alpha: 0.45),
                                AppColors.primary.withValues(alpha: 0.12),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(1.5),
                          child: Material(
                            color: AppColors.surface.withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(AppFoundation.radiusMd + 2.5),
                            clipBehavior: Clip.antiAlias,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.primary.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Icon(
                                            Icons.person_add_alt_1_rounded,
                                            color: AppColors.primary,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              l10n.driverLoginRegisterBannerTitle,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    color: AppColors.textPrimary,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              l10n.driverLoginRegisterBannerSubtitle,
                                              style: TextStyle(
                                                fontSize: 13,
                                                height: 1.35,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  FilledButton(
                                    onPressed: () =>
                                        context.goNamed(AppRouter.register),
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size.fromHeight(52),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppFoundation.radiusSm + 2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          registerCta,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(width: AppFoundation.spacingSm),
                                        const Icon(Icons.arrow_forward_rounded, size: 20),
                                      ],
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
                color: Colors.black.withValues(alpha: 0.58),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.34),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(strokeWidth: 3.2),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          loadingMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
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

