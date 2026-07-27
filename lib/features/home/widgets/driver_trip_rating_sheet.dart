import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_realtime_state.dart';

/// Contenido del sheet de calificación (premium): pasajero + estrellas.
class DriverTripRatingSheet extends StatefulWidget {
  final void Function(int stars, List<String> feedbackCodes) onSubmitted;
  final VoidCallback onSkipped;
  final DriverActiveTrip? trip;
  final Future<List<DriverRatingFeedbackItem>> Function(int stars)
  loadFeedbackCatalog;

  const DriverTripRatingSheet({
    super.key,
    required this.onSubmitted,
    required this.onSkipped,
    required this.loadFeedbackCatalog,
    this.trip,
  });

  @override
  State<DriverTripRatingSheet> createState() => DriverTripRatingSheetState();
}

class DriverTripRatingSheetState extends State<DriverTripRatingSheet>
    with SingleTickerProviderStateMixin {
  int _rating = 5;
  bool _loadingCatalog = true;
  List<DriverRatingFeedbackItem> _feedbackLow = const [];
  List<DriverRatingFeedbackItem> _feedbackHigh = const [];
  final Set<String> _selectedFeedbackCodes = <String>{};
  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  List<DriverRatingFeedbackItem> get _displayedOptions =>
      _rating <= 3 ? _feedbackLow : _feedbackHigh;

  Future<void> _preloadFeedbackCatalogs() async {
    if (!mounted) return;
    setState(() => _loadingCatalog = true);
    try {
      final results = await Future.wait([
        widget.loadFeedbackCatalog(3),
        widget.loadFeedbackCatalog(5),
      ]);
      if (!mounted) return;
      final lowRaw = results[0];
      final highRaw = results[1];
      setState(() {
        _feedbackLow = (lowRaw.isEmpty ? _fallbackFeedback(2) : lowRaw)
            .take(5)
            .toList(growable: false);
        _feedbackHigh = (highRaw.isEmpty ? _fallbackFeedback(5) : highRaw)
            .take(5)
            .toList(growable: false);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _feedbackLow = _fallbackFeedback(2).take(5).toList(growable: false);
        _feedbackHigh = _fallbackFeedback(5).take(5).toList(growable: false);
      });
    } finally {
      if (mounted) setState(() => _loadingCatalog = false);
    }
  }

  void _setRating(int stars) {
    HapticFeedback.selectionClick();
    final prevBucket = _rating <= 3;
    final nextBucket = stars <= 3;
    setState(() {
      _rating = stars;
      if (prevBucket != nextBucket) {
        _selectedFeedbackCodes.removeWhere(
          (code) => !_displayedOptions.any((item) => item.code == code),
        );
      }
    });
  }

  List<DriverRatingFeedbackItem> _fallbackFeedback(int stars) {
    final l10n = AppLocalizations.of(context);
    if (stars <= 3) {
      return [
        DriverRatingFeedbackItem(
          code: 'fallback_delay',
          label: l10n.driverRatingFallbackDelay,
          minStars: 1,
          maxStars: 3,
        ),
        DriverRatingFeedbackItem(
          code: 'fallback_location',
          label: l10n.driverRatingFallbackLocation,
          minStars: 1,
          maxStars: 3,
        ),
        DriverRatingFeedbackItem(
          code: 'fallback_respect',
          label: l10n.driverRatingFallbackRespect,
          minStars: 1,
          maxStars: 3,
        ),
        DriverRatingFeedbackItem(
          code: 'fallback_payment',
          label: l10n.driverRatingFallbackPayment,
          minStars: 1,
          maxStars: 3,
        ),
        DriverRatingFeedbackItem(
          code: 'fallback_other',
          label: l10n.driverRatingFallbackOther,
          minStars: 1,
          maxStars: 3,
        ),
      ];
    }
    return [
      DriverRatingFeedbackItem(
        code: 'fallback_punctual',
        label: l10n.driverRatingFallbackPunctual,
        minStars: 4,
        maxStars: 5,
      ),
      DriverRatingFeedbackItem(
        code: 'fallback_respectful',
        label: l10n.driverRatingFallbackRespectful,
        minStars: 4,
        maxStars: 5,
      ),
      DriverRatingFeedbackItem(
        code: 'fallback_clear_pickup',
        label: l10n.driverRatingFallbackClearPickup,
        minStars: 4,
        maxStars: 5,
      ),
      DriverRatingFeedbackItem(
        code: 'fallback_recommended',
        label: l10n.driverRatingFallbackRecommended,
        minStars: 4,
        maxStars: 5,
      ),
      DriverRatingFeedbackItem(
        code: 'fallback_excellent',
        label: l10n.driverRatingFallbackExcellent,
        minStars: 4,
        maxStars: 5,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: AppMotion.sheetEntrance,
    );
    _fade = CurvedAnimation(parent: _entrance, curve: AppMotion.standard);
    _slide = Tween<Offset>(
      begin: Offset(0, AppMotion.slideDySubtle),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrance, curve: AppMotion.standard));
    _entrance.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_preloadFeedbackCatalogs());
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trip = widget.trip;
    final passengerName = (trip?.passengerName ?? '').isNotEmpty
        ? trip!.passengerName!
        : l10n.driverTripRatingPassengerDefault;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.55),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 28,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.border.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary.withValues(alpha: 0.75),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: AppColors.onPrimary,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.driverTripRatingHeaderTitle,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.driverTripRatingTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.driverTripRatingSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.96,
                            ),
                          ),
                        ),
                        if (trip != null) ...[
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: AppColors.background,
                                  border: Border.all(
                                    color: AppColors.border.withValues(
                                      alpha: 0.62,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.person_rounded,
                                      size: 17,
                                      color: AppColors.primary.withValues(
                                        alpha: 0.92,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      passengerName,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),
                        Text(
                          l10n.driverTripRatingYourRating,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final filled = _rating >= index + 1;
                            return IconButton(
                              onPressed: () => _setRating(index + 1),
                              icon: Icon(
                                filled
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 38,
                                color: filled
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            );
                          }),
                        ),
                        if (_rating > 0) ...[
                          const SizedBox(height: 12),
                          Text(
                            _rating <= 3
                                ? l10n.driverTripRatingFeedbackPromptLow
                                : l10n.driverTripRatingFeedbackPromptHigh,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_loadingCatalog)
                            const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else if (_displayedOptions.isNotEmpty)
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: _displayedOptions
                                  .map((item) {
                                    final selected = _selectedFeedbackCodes
                                        .contains(item.code);
                                    return FilterChip(
                                      selected: selected,
                                      onSelected: (value) {
                                        setState(() {
                                          if (value) {
                                            _selectedFeedbackCodes.add(
                                              item.code,
                                            );
                                          } else {
                                            _selectedFeedbackCodes.remove(
                                              item.code,
                                            );
                                          }
                                        });
                                      },
                                      label: Text(item.label),
                                    );
                                  })
                                  .toList(growable: false),
                            ),
                        ],
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _rating == 0 || _loadingCatalog
                              ? null
                              : () {
                                  HapticFeedback.lightImpact();
                                  widget.onSubmitted(
                                    _rating,
                                    _selectedFeedbackCodes.toList(
                                      growable: false,
                                    ),
                                  );
                                },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            l10n.driverTripRatingSubmit,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            widget.onSkipped();
                          },
                          child: Text(
                            l10n.driverTripRatingSkip,
                            style: const TextStyle(fontWeight: FontWeight.w600),
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
      ),
    );
  }
}
