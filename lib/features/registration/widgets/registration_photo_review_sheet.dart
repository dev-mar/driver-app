import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_foundation.dart';
import '../../../gen_l10n/app_localizations.dart';

enum RegistrationPhotoReviewAction { confirmed, retake, cancelled }

/// Salida de [showRegistrationPhotoReviewSheet]. Si [action] es [confirmed], [path] es la ruta final.
@immutable
class RegistrationPhotoReviewOutcome {
  const RegistrationPhotoReviewOutcome.confirmed(String this.path)
      : action = RegistrationPhotoReviewAction.confirmed;

  const RegistrationPhotoReviewOutcome.retake()
      : action = RegistrationPhotoReviewAction.retake,
        path = null;

  const RegistrationPhotoReviewOutcome.cancelled()
      : action = RegistrationPhotoReviewAction.cancelled,
        path = null;

  final RegistrationPhotoReviewAction action;
  final String? path;
}

/// Vista previa + acciones antes de comprimir a Base64. El recorte solo si el usuario elige «Recortar».
Future<RegistrationPhotoReviewOutcome?> showRegistrationPhotoReviewSheet(
  BuildContext context, {
  required String imagePath,
  required bool cropEnabled,
  required Future<String> Function(String path) onCrop,
}) {
  return showModalBottomSheet<RegistrationPhotoReviewOutcome>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _RegistrationPhotoReviewBody(
      imagePath: imagePath,
      cropEnabled: cropEnabled,
      onCrop: onCrop,
    ),
  );
}

class _RegistrationPhotoReviewBody extends StatefulWidget {
  const _RegistrationPhotoReviewBody({
    required this.imagePath,
    required this.cropEnabled,
    required this.onCrop,
  });

  final String imagePath;
  final bool cropEnabled;
  final Future<String> Function(String path) onCrop;

  @override
  State<_RegistrationPhotoReviewBody> createState() => _RegistrationPhotoReviewBodyState();
}

class _RegistrationPhotoReviewBodyState extends State<_RegistrationPhotoReviewBody> {
  late String _path;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _path = widget.imagePath;
  }

  Future<void> _onEdit() async {
    if (!widget.cropEnabled || _busy) return;
    setState(() => _busy = true);
    try {
      final next = await widget.onCrop(_path);
      if (mounted && next.isNotEmpty) {
        setState(() => _path = next);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: AppColors.surfaceCard,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppFoundation.radiusLg)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.driverRegPhotoReviewTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.driverRegPhotoReviewSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: AppColors.textSecondary.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
                  ),
                  child: Image.file(
                    File(_path),
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _busy
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop(
                        RegistrationPhotoReviewOutcome.confirmed(_path),
                      );
                    },
              icon: const Icon(Icons.check_rounded, size: 22),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  l10n.driverRegPhotoReviewUse,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _busy
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pop(const RegistrationPhotoReviewOutcome.retake());
                    },
              icon: const Icon(Icons.photo_camera_outlined, size: 20),
              label: Text(
                l10n.driverRegPhotoReviewChange,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: scheme.outline.withValues(alpha: 0.65)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppFoundation.radiusMd),
                ),
              ),
            ),
            if (widget.cropEnabled) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _busy ? null : _onEdit,
                icon: _busy
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.primary,
                        ),
                      )
                    : const Icon(Icons.crop_rounded, size: 20),
                label: Text(
                  l10n.driverRegPhotoReviewEdit,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
            TextButton(
              onPressed: _busy
                  ? null
                  : () => Navigator.of(context).pop(const RegistrationPhotoReviewOutcome.cancelled()),
              child: Text(
                l10n.driverRegPhotoReviewCancel,
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
