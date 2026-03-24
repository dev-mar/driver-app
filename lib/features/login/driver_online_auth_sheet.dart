import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../gen_l10n/app_localizations.dart';

/// Hoja inferior previa a `local_auth`: misma seguridad, UX fluida y animada.
Future<bool> showDriverOnlineAuthPrompt(
  BuildContext context,
  AppLocalizations l10n,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _DriverOnlineAuthSheet(l10n: l10n),
  );
  return result == true;
}

class _DriverOnlineAuthSheet extends StatefulWidget {
  const _DriverOnlineAuthSheet({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_DriverOnlineAuthSheet> createState() => _DriverOnlineAuthSheetState();
}

class _DriverOnlineAuthSheetState extends State<_DriverOnlineAuthSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Asa + línea: aparición rápida
  late final Animation<double> _topFade;

  /// Icono principal: escala con ligero rebote
  late final Animation<double> _iconScale;

  /// Textos y botones: fade + deslizamiento suave
  late final Animation<double> _bodyFade;
  late final Animation<Offset> _bodySlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );

    _topFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.28, curve: Curves.easeOutCubic),
      ),
    );

    _iconScale = Tween<double>(begin: 0.78, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.06, 0.52, curve: Curves.easeOutBack),
      ),
    );

    _bodyFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.22, 0.62, curve: Curves.easeOutCubic),
      ),
    );

    _bodySlide = Tween<Offset>(
      begin: Offset(0, AppMotion.slideDySubtle),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.22, 0.72, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset > 0 ? 0 : 8),
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 28,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Opacity(
                          opacity: _topFade.value,
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.border.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                height: 3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withValues(alpha: 0.35),
                                      AppColors.primary,
                                      AppColors.primary.withValues(alpha: 0.35),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Transform.scale(
                          scale: _iconScale.value,
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primary.withValues(alpha: 0.4),
                                      AppColors.primary.withValues(alpha: 0.06),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.22),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.fingerprint_rounded,
                                  size: 52,
                                  color: AppColors.primary,
                                ),
                              ),
                              Positioned(
                                right: 4,
                                bottom: 6,
                                child: Opacity(
                                  opacity: _bodyFade.value,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.border.withValues(alpha: 0.85),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.face_retouching_natural_rounded,
                                      size: 18,
                                      color: AppColors.primary.withValues(alpha: 0.95),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        FadeTransition(
                          opacity: _bodyFade,
                          child: SlideTransition(
                            position: _bodySlide,
                            child: Column(
                              children: [
                                const SizedBox(height: 24),
                                Text(
                                  l10n.driverOnlineAuthTitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.4,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  l10n.driverOnlineAuthSubtitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.45,
                                    color: AppColors.textSecondary.withValues(alpha: 0.96),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                FilledButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.of(context).pop(true);
                                  },
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(54),
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.onPrimary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.driverOnlineAuthContinue,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextButton(
                                  onPressed: () {
                                    HapticFeedback.selectionClick();
                                    Navigator.of(context).pop(false);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.textSecondary,
                                    minimumSize: const Size.fromHeight(44),
                                  ),
                                  child: Text(
                                    l10n.driverOnlineAuthCancel,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
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
            );
          },
        ),
      ),
    );
  }
}
