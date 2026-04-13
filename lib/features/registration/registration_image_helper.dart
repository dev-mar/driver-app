import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import '../../gen_l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Registro conductor — varias imágenes Base64 en el mismo JSON (documentos,
// vehículo). Backend: API_V2_JSON_LIMIT en Express (~32mb típico).
//
// - [document]: carnet identidad / licencia (legibilidad).
// - [facePortrait]: selfie face_image; mismo criterio que pasajero (payload ya
//   incluye frente+dorso).
// - [vehicleAngle]: 4 fotos en un POST; cada ángulo más liviano.
// ---------------------------------------------------------------------------

/// Carnet / licencia (2 por POST o 2 de 3 en identidad).
const int kDriverRegistrationDocImageMaxBytes = 620 * 1024;
const double kDriverRegistrationDocImageMaxEdgePx = 1400;
const int kDriverRegistrationDocImageQuality = 66;

/// Selfie verificación (acompaña 2 carnets en el mismo JSON).
const int kDriverRegistrationFaceImageMaxBytes = 320 * 1024;
const double kDriverRegistrationFaceImageMaxEdgePx = 640;
const int kDriverRegistrationFaceImageQuality = 52;

/// Una de las 4 vistas del vehículo en un solo POST.
const int kDriverRegistrationVehicleImageMaxBytes = 450 * 1024;
const double kDriverRegistrationVehicleImageMaxEdgePx = 1100;
const int kDriverRegistrationVehicleImageQuality = 62;

const int kDriverRegistrationCompressExtraPasses = 4;

/// Qué tipo de foto se está cargando (define tope y resolución por defecto).
enum DriverRegistrationImageKind {
  /// Frente/dorso documento identidad o licencia.
  document,

  /// `face_image` en paso identidad.
  facePortrait,

  /// Fotos de ángulos del auto (4 en un request).
  vehicleAngle,
}

class _ResolvedPickingLimits {
  const _ResolvedPickingLimits({
    required this.maxBytes,
    required this.imageQuality,
    required this.maxEdgePx,
    required this.pickerQuality,
  });

  final int maxBytes;
  final int imageQuality;
  final double maxEdgePx;
  final int pickerQuality;
}

_ResolvedPickingLimits _limitsForKind(DriverRegistrationImageKind kind) {
  switch (kind) {
    case DriverRegistrationImageKind.document:
      return const _ResolvedPickingLimits(
        maxBytes: kDriverRegistrationDocImageMaxBytes,
        imageQuality: kDriverRegistrationDocImageQuality,
        maxEdgePx: kDriverRegistrationDocImageMaxEdgePx,
        pickerQuality: 82,
      );
    case DriverRegistrationImageKind.facePortrait:
      return const _ResolvedPickingLimits(
        maxBytes: kDriverRegistrationFaceImageMaxBytes,
        imageQuality: kDriverRegistrationFaceImageQuality,
        maxEdgePx: kDriverRegistrationFaceImageMaxEdgePx,
        pickerQuality: 72,
      );
    case DriverRegistrationImageKind.vehicleAngle:
      return const _ResolvedPickingLimits(
        maxBytes: kDriverRegistrationVehicleImageMaxBytes,
        imageQuality: kDriverRegistrationVehicleImageQuality,
        maxEdgePx: kDriverRegistrationVehicleImageMaxEdgePx,
        pickerQuality: 78,
      );
  }
}

/// Encodes JPEG (sin EXIF) a Base64 crudo. [kind] ajusta peso y borde según el paso.
Future<String?> pickImageAsBase64(
  BuildContext context, {
  DriverRegistrationImageKind kind = DriverRegistrationImageKind.document,
  int? maxBytes,
  int? imageQuality,
  double? maxWidth,
}) async {
  final lim = _limitsForKind(kind);
  final cap = maxBytes ?? lim.maxBytes;
  final q0 = imageQuality ?? lim.imageQuality;
  final edge = (maxWidth ?? lim.maxEdgePx).round().clamp(320, 4096);

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
      imageQuality: lim.pickerQuality,
      maxWidth: edge.toDouble(),
      maxHeight: edge.toDouble(),
    );
    if (xfile == null) return null;
    final path = xfile.path;
    var q = q0.clamp(50, 95);
    var targetW = edge;

    var bytes = await FlutterImageCompress.compressWithFile(
          path,
          quality: q,
          minWidth: targetW,
          minHeight: 0,
          format: CompressFormat.jpeg,
          keepExif: false,
        ) ??
        await xfile.readAsBytes();

    for (var pass = 0;
        pass < kDriverRegistrationCompressExtraPasses && bytes.lengthInBytes > cap;
        pass++) {
      q = (q - 7).clamp(50, 95);
      targetW = (targetW * 0.88).round().clamp(480, edge);
      bytes = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: targetW,
        minHeight: 0,
        quality: q,
        format: CompressFormat.jpeg,
        keepExif: false,
      );
    }

    if (!context.mounted) return null;
    if (bytes.lengthInBytes > cap) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.driverRegImageTooLarge((cap / 1024).round()),
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
