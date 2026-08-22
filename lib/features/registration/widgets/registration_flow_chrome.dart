import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../gen_l10n/app_localizations.dart';

class RegistrationBottomBar extends StatelessWidget {
  const RegistrationBottomBar({
    super.key,
    required this.loading,
    required this.step,
    required this.lastStepIndex,
    this.profileCompletionMode = false,
    this.profileReadOnly = false,
    this.profileSavePhotos = false,
    required this.onBack,
    required this.onContinue,
  });

  final bool loading;
  final int step;
  final int lastStepIndex;
  /// Desde perfil: guardar/cerrar sin navegar entre pasos del asistente.
  final bool profileCompletionMode;
  /// Desde perfil: bloque verificado — solo consulta.
  final bool profileReadOnly;
  /// Desde perfil: el bloque aún no está verificado y se pueden guardar fotos.
  final bool profileSavePhotos;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLast = step == lastStepIndex;
    final isActivateStep = step == 3;
    final primaryLabel = profileReadOnly
        ? l10n.commonClose
        : (profileSavePhotos
            ? l10n.driverRegActionSavePhotos
            : (profileCompletionMode
            ? (isActivateStep ? l10n.driverRegActionActivate : l10n.driverRegActionSave)
            : (isActivateStep
                ? l10n.driverRegActionActivate
                : (isLast ? l10n.driverRegActionFinish : l10n.driverRegActionContinue))));
    final primaryIcon = profileReadOnly
        ? Icons.check_rounded
        : (profileSavePhotos
            ? Icons.save_rounded
            : (profileCompletionMode
            ? (isActivateStep
                ? Icons.send_rounded
                : Icons.save_rounded)
            : (isActivateStep
                ? Icons.send_rounded
                : (isLast ? Icons.check_rounded : Icons.arrow_forward_rounded))));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.4)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            (() {
              final systemBottom = MediaQuery.viewPaddingOf(context).bottom;
              final minComfortBottom = 20.0;
              final resolved = systemBottom + 12;
              return resolved > minComfortBottom
                  ? resolved
                  : minComfortBottom;
            })(),
          ),
          child: Row(
            children: [
              if (!profileReadOnly) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: loading ? null : onBack,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.85),
                      ),
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: AppColors.surfaceCard,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.commonCancel),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: FilledButton(
                  onPressed: loading
                      ? null
                      : (profileReadOnly ? onBack : onContinue),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    disabledBackgroundColor: AppColors.border.withValues(alpha: 0.6),
                    disabledForegroundColor: AppColors.textSecondary,
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.25,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(primaryLabel),
                            const SizedBox(width: 8),
                            Icon(
                              primaryIcon,
                              size: 20,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegistrationStepIntroBanner extends StatelessWidget {
  const RegistrationStepIntroBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, size: 20, color: AppColors.primary.withValues(alpha: 0.95)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado positivo breve (sin tecnicismos).
class RegistrationSoftStatusChip extends StatelessWidget {
  const RegistrationSoftStatusChip({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.38,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Encabezado de paso (misma familia visual que las tarjetas de sección).
class RegistrationStepHeroCard extends StatelessWidget {
  const RegistrationStepHeroCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    letterSpacing: 0.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RegistrationColorChoicePill extends StatelessWidget {
  const RegistrationColorChoicePill({
    super.key,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: AppFoundation.spacingSm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.surfaceCard.withValues(alpha: 0.7),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.55)
                : AppColors.border.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.55),
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class RegistrationInfoTileRow extends StatelessWidget {
  const RegistrationInfoTileRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.95),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lado del documento a fotografiar (identidad o licencia).
enum RegistrationCarnetSlotKind { idFront, idBack, licenseFront, licenseBack }

class RegistrationCarnetUploadTile extends StatefulWidget {
  const RegistrationCarnetUploadTile({
    super.key,
    required this.kind,
    required this.isSet,
    required this.onTap,
    this.onLongPress,
    this.previewUrl,
    this.enabled = true,
  });

  final RegistrationCarnetSlotKind kind;
  final bool isSet;
  final VoidCallback onTap;
  /// Captura con `pickImageAsBase64PickerPrefiltered` (menos RAM / modo compatible).
  final VoidCallback? onLongPress;
  final String? previewUrl;
  final bool enabled;

  @override
  State<RegistrationCarnetUploadTile> createState() => RegistrationCarnetUploadTileState();
}

class RegistrationCarnetUploadTileState extends State<RegistrationCarnetUploadTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (title, hint, miniIcon, miniAccent) = _metaForKind(widget.kind);

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
                  onTap: widget.enabled ? widget.onTap : null,
                  onLongPress: widget.enabled ? widget.onLongPress : null,
          onHighlightChanged: (h) => setState(() => _pressed = h),
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.primary.withValues(alpha: 0.12),
          highlightColor: AppColors.primary.withValues(alpha: 0.06),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isSet
                    ? AppColors.success
                    : AppColors.border.withValues(alpha: 0.65),
                width: widget.isSet ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.previewUrl != null && widget.previewUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.previewUrl!,
                        width: 52,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            RegistrationMiniCarnetIllustration(icon: miniIcon, accent: miniAccent),
                      ),
                    )
                  else
                    RegistrationMiniCarnetIllustration(icon: miniIcon, accent: miniAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hint,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.3,
                            color: AppColors.textSecondary.withValues(alpha: 0.95),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              widget.isSet
                                  ? Icons.check_circle_rounded
                                  : Icons.add_photo_alternate_outlined,
                              size: 16,
                              color: widget.isSet
                                  ? AppColors.success
                                  : AppColors.primary.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.isSet
                                  ? l10n.driverRegImageReady
                                  : l10n.driverRegTapToUpload,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: widget.isSet
                                    ? AppColors.success
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary.withValues(alpha: 0.75),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  (String, String, IconData, Color) _metaForKind(RegistrationCarnetSlotKind k) {
    final l10n = AppLocalizations.of(context);
    switch (k) {
      case RegistrationCarnetSlotKind.idFront:
        return (
          l10n.driverRegDocFrontTitle,
          l10n.driverRegDocFrontHint,
          Icons.person_rounded,
          AppColors.primary.withValues(alpha: 0.85),
        );
      case RegistrationCarnetSlotKind.idBack:
        return (
          l10n.driverRegDocBackTitle,
          l10n.driverRegDocBackHint,
          Icons.qr_code_2_rounded,
          AppColors.textSecondary.withValues(alpha: 0.9),
        );
      case RegistrationCarnetSlotKind.licenseFront:
        return (
          l10n.driverRegLicenseFrontTitle,
          l10n.driverRegLicenseFrontHint,
          Icons.person_rounded,
          AppColors.primary.withValues(alpha: 0.85),
        );
      case RegistrationCarnetSlotKind.licenseBack:
        return (
          l10n.driverRegLicenseBackTitle,
          l10n.driverRegLicenseBackHint,
          Icons.qr_code_2_rounded,
          AppColors.textSecondary.withValues(alpha: 0.9),
        );
    }
  }
}

/// Miniatura de referencia para el lado del documento.
class RegistrationMiniCarnetIllustration extends StatelessWidget {
  const RegistrationMiniCarnetIllustration({
    super.key,
    required this.icon,
    required this.accent,
  });

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.inputFill,
            AppColors.surfaceCard,
          ],
        ),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 2,
            left: 4,
            right: 4,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.border.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Icon(icon, size: 28, color: accent),
        ],
      ),
    );
  }
}

/// Foto de perfil con vista previa (base64).
class RegistrationProfilePhotoCircleSlot extends StatefulWidget {
  const RegistrationProfilePhotoCircleSlot({
    super.key,
    required this.base64Image,
    required this.onTap,
    this.onLongPress,
    this.previewUrl,
    this.enabled = true,
  });

  final String? base64Image;
  final String? previewUrl;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  State<RegistrationProfilePhotoCircleSlot> createState() => RegistrationProfilePhotoCircleSlotState();
}

class RegistrationProfilePhotoCircleSlotState extends State<RegistrationProfilePhotoCircleSlot> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasImage = (widget.base64Image != null && widget.base64Image!.isNotEmpty) ||
        (widget.previewUrl != null && widget.previewUrl!.isNotEmpty);
    Uint8List? bytes;
    if (hasImage) {
      try {
        bytes = base64Decode(widget.base64Image!);
      } catch (_) {
        bytes = null;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOut,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: widget.enabled ? widget.onTap : null,
                  onLongPress: widget.enabled ? widget.onLongPress : null,
                  onHighlightChanged: (h) => setState(() => _pressed = h),
                  splashColor: AppColors.primary.withValues(alpha: 0.15),
                  highlightColor: AppColors.primary.withValues(alpha: 0.06),
                  child: Ink(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasImage
                            ? AppColors.success
                            : AppColors.primary.withValues(alpha: 0.55),
                        width: hasImage ? 3 : 2,
                      ),
                    ),
                    child: ClipOval(
                      child: bytes != null
                          ? Image.memory(
                              bytes,
                              fit: BoxFit.cover,
                              width: 140,
                              height: 140,
                              gaplessPlayback: true,
                            )
                          : (widget.previewUrl != null && widget.previewUrl!.isNotEmpty)
                              ? Image.network(
                                  widget.previewUrl!,
                                  fit: BoxFit.cover,
                                  width: 140,
                                  height: 140,
                                  errorBuilder: (_, _, _) => Container(
                                    color: AppColors.inputFill,
                                    child: Icon(
                                      Icons.face_retouching_natural,
                                      size: 48,
                                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                                    ),
                                  ),
                                )
                          : Container(
                              color: AppColors.inputFill,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.face_retouching_natural,
                                    size: 48,
                                    color: AppColors.textSecondary.withValues(alpha: 0.9),
                                  ),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      l10n.driverRegTapToUpload,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary.withValues(alpha: 0.95),
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
          ),
        ),
        const SizedBox(height: 12),
        Text(
          hasImage
              ? l10n.driverRegProfilePhotoReadyHint
              : l10n.driverRegProfilePhotoGuideHint,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            height: 1.35,
            color: hasImage
                ? AppColors.success.withValues(alpha: 0.95)
                : AppColors.textSecondary,
            fontWeight: hasImage ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class RegistrationPhotoSlot extends StatefulWidget {
  const RegistrationPhotoSlot({
    super.key,
    required this.title,
    required this.isSet,
    required this.onTap,
  });

  final String title;
  final bool isSet;
  final VoidCallback onTap;

  @override
  State<RegistrationPhotoSlot> createState() => RegistrationPhotoSlotState();
}

class RegistrationPhotoSlotState extends State<RegistrationPhotoSlot> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedScale(
      scale: _pressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (h) => setState(() => _pressed = h),
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.primary.withValues(alpha: 0.12),
          highlightColor: AppColors.primary.withValues(alpha: 0.06),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isSet
                    ? AppColors.success
                    : AppColors.border.withValues(alpha: 0.65),
                width: widget.isSet ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    widget.isSet ? Icons.check_circle_rounded : Icons.add_a_photo_rounded,
                    color: widget.isSet ? AppColors.success : AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(
                          widget.isSet
                              ? l10n.driverRegImageReady
                              : l10n.driverRegTapToUpload,
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isSet ? AppColors.success : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegistrationCarAngleCard extends StatefulWidget {
  const RegistrationCarAngleCard({
    super.key,
    required this.title,
    required this.hint,
    required this.icon,
    required this.isDone,
    this.previewBase64,
    this.previewUrl,
    this.enabled = true,
    required this.onTap,
  });

  final String title;
  final String hint;
  final IconData icon;
  final bool isDone;
  /// Miniatura de la foto elegida (mismo base64 que se envía al servidor).
  final String? previewBase64;
  final String? previewUrl;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<RegistrationCarAngleCard> createState() => RegistrationCarAngleCardState();
}

class RegistrationCarAngleCardState extends State<RegistrationCarAngleCard> {
  bool _pressed = false;

  Uint8List? _decodePreview(String? b64) {
    if (b64 == null || b64.isEmpty) return null;
    try {
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preview = _decodePreview(widget.previewBase64);
    final hasRemote = widget.previewUrl != null && widget.previewUrl!.isNotEmpty;
    final hasPreview = preview != null || hasRemote;
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
          onTap: widget.enabled ? widget.onTap : null,
          onHighlightChanged: (h) => setState(() => _pressed = h),
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.primary.withValues(alpha: 0.12),
          highlightColor: AppColors.primary.withValues(alpha: 0.06),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isDone
                    ? AppColors.success
                    : AppColors.border.withValues(alpha: 0.65),
                width: widget.isDone ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(widget.icon, color: AppColors.primary, size: 22),
                      const Spacer(),
                      if (widget.isDone)
                        const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    ],
                  ),
                  if (hasPreview) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: 72,
                        width: double.infinity,
                        child: preview != null
                            ? Image.memory(
                                preview,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              )
                            : Image.network(
                                widget.previewUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const SizedBox.shrink(),
                              ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      hasPreview
                          ? l10n.driverRegTapCardToReplacePhoto
                          : widget.hint,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasPreview
                        ? l10n.driverRegChangePhoto
                        : l10n.driverRegTakeOrChoosePhoto,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.isDone ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
