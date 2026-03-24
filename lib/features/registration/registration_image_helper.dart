import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../gen_l10n/app_localizations.dart';

/// Selecciona imagen (cámara o galería) y devuelve Base64 sin prefijo `data:`.
Future<String?> pickImageAsBase64(
  BuildContext context, {
  int maxBytes = 900 * 1024,
  int imageQuality = 65,
  double maxWidth = 1600,
}) async {
  final l10n = AppLocalizations.of(context);
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_rounded),
            title: Text(l10n.driverRegImageTakePhoto),
            onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded),
            title: Text(l10n.driverRegImageChooseGallery),
            onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (!context.mounted || source == null) return null;

  final picker = ImagePicker();
  try {
    final xfile = await picker.pickImage(
      source: source,
      imageQuality: imageQuality,
      maxWidth: maxWidth,
    );
    if (xfile == null) return null;
    final bytes = await xfile.readAsBytes();
    if (!context.mounted) return null;
    if (bytes.lengthInBytes > maxBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.driverRegImageTooLarge((maxBytes / 1024).round()),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return null;
    }
    return base64Encode(bytes);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.driverRegImageReadError),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return null;
  }
}
