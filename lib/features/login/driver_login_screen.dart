import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/router/app_router.dart';
import '../../core/ui/driver_ui_states.dart';
import '../../gen_l10n/app_localizations.dart';
import 'driver_login_controller.dart';

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
    _countryCodeController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    final l10n = AppLocalizations.of(context);

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final countryCode = _countryCodeController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = l10n.driverLoginPhoneAndPasswordRequired;
        _isLoading = false;
      });
      return;
    }

    final fullPhone =
        countryCode.replaceAll(RegExp(r'[^\d+]'), '') + phone.replaceAll(RegExp(r'[^\d]'), '');

    final success = await ref.read(driverLoginControllerProvider.notifier).login(
          fullPhone: fullPhone,
          password: password,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.goNamed(AppRouter.home);
    } else {
      setState(() {
        _errorMessage =
            ref.read(driverLoginControllerProvider).errorMessage ??
                l10n.driverLoginErrorGeneric;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final registerHint = l10n.driverLoginRegisterHint;
    final registerCta = l10n.driverLoginRegisterCta;

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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _entranceFade,
                  child: SlideTransition(
                    position: _entranceSlide,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          // Logo superior
                          Center(
                        child: Image.asset(
                          AppAssets.authLogo,
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.driverLoginWelcome,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: l10n.loginPhone,
                                hintText: l10n.driverLoginPhoneHint,
                              ),
                              keyboardType: TextInputType.phone,
                              autofillHints: const [AutofillHints.telephoneNumber],
                              onFieldSubmitted: (_) => _submit(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: l10n.driverLoginPassword),
                        obscureText: true,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
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
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l10n.driverLoginButton),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.how_to_reg_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                registerHint,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.goNamed(AppRouter.register),
                              child: Text(registerCta),
                            ),
                          ],
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
        ],
      ),
    );
  }
}

