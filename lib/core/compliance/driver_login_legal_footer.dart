import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../gen_l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_foundation.dart';
import 'driver_legal_links.dart';

/// Aviso legal sutil en login / activación de registro.
enum DriverLegalNoticeTone {
  /// Login: una línea con enlaces inline.
  compact,
  /// Pantalla de envío a revisión: microcopy aún más corto.
  activate,
  /// Compat: se renderiza como [activate].
  emphasized,
}

class DriverLoginLegalFooter extends StatefulWidget {
  const DriverLoginLegalFooter({
    super.key,
    this.textColor,
    this.tone = DriverLegalNoticeTone.compact,
  });

  final Color? textColor;
  final DriverLegalNoticeTone tone;

  @override
  State<DriverLoginLegalFooter> createState() => _DriverLoginLegalFooterState();
}

class _DriverLoginLegalFooterState extends State<DriverLoginLegalFooter> {
  late final TapGestureRecognizer _primaryLinkTap;
  late final TapGestureRecognizer _termsTap;

  @override
  void initState() {
    super.initState();
    _primaryLinkTap = TapGestureRecognizer()
      ..onTap = () {
        HapticFeedback.selectionClick();
        final isActivate = widget.tone == DriverLegalNoticeTone.activate ||
            widget.tone == DriverLegalNoticeTone.emphasized;
        if (isActivate) {
          openDriverTerms(context);
        } else {
          openDriverPrivacyPolicy(context);
        }
      };
    _termsTap = TapGestureRecognizer()
      ..onTap = () {
        HapticFeedback.selectionClick();
        openDriverTerms(context);
      };
  }

  @override
  void dispose() {
    _primaryLinkTap.dispose();
    _termsTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final secondary = widget.textColor ?? AppColors.textSecondary.withValues(alpha: 0.92);
    final linkColor = AppColors.primary.withValues(alpha: 0.92);
    final isActivate = widget.tone == DriverLegalNoticeTone.activate ||
        widget.tone == DriverLegalNoticeTone.emphasized;

    final baseStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: secondary,
          height: 1.35,
          fontSize: isActivate ? 12.5 : 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        );

    final linkStyle = baseStyle?.copyWith(
      color: linkColor,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: linkColor.withValues(alpha: 0.35),
      decorationThickness: 1,
    );

    final spans = <InlineSpan>[
      TextSpan(
        text: isActivate ? l10n.driverLegalActivatePrefix : l10n.driverLegalLoginPrefix,
        style: baseStyle,
      ),
      TextSpan(
        text: l10n.driverLegalUsagePolicies,
        style: linkStyle,
        recognizer: _primaryLinkTap,
      ),
    ];

    if (!isActivate) {
      spans.addAll([
        TextSpan(text: l10n.driverLegalLoginConjunction, style: baseStyle),
        TextSpan(
          text: l10n.driverLegalTermsOfService,
          style: linkStyle,
          recognizer: _termsTap,
        ),
      ]);
    }

    spans.add(TextSpan(text: '.', style: baseStyle));

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isActivate ? AppFoundation.spacingSm : 0,
        vertical: isActivate ? AppFoundation.spacingXs : 0,
      ),
      child: Text.rich(
        TextSpan(children: spans),
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    );
  }
}
