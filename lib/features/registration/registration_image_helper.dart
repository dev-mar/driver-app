import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../gen_l10n/app_localizations.dart';
import 'registration_image_isolate_codec.dart';
import 'widgets/registration_photo_review_sheet.dart';

// ---------------------------------------------------------------------------
// Registro conductor — captura + compresión JPEG (isolate principal) y Base64
// vía `registration_image_isolate_codec.dart` ([compute]).
//
// Identidad / licencia: captura **alta pero acotada** en el picker (evita OOM
// al abrir [ImageCropper] con sensores 48–200 MP), recorte opcional y salida
// del crop limitada (`maxWidth`/`maxHeight` en cropImage), luego compresión final.
// Sin tope en picker, muchos dispositivos **cierran la app** al aceptar la foto.
// Si falla o no cabe bajo el tope KB, se reintenta **una vez** en modo compatible
// (picker ya limitado al borde final `edge`).
//
// Backend: documentos usan `*_storage_key` cuando el presign de registro responde; la galería
// vehículo la arma `driver_registration_controller` **siempre** intentando presign por ítem
// (`POST .../vehicles/media/presign` + PUT S3) antes de `image` inline en JSON.
//
// - [document]: carnet identidad / licencia (legibilidad).
// - [facePortrait]: selfie face_image.
// - [vehicleAngle]: 4 fotos; captura + hoja «revisar» (conservar / cambiar / recortar) + UCrop si aplica.
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

const int kDriverRegistrationCompressExtraPasses = 5;
const int kDriverRegistrationCompressExtraPassesFullCapture = 8;

/// Borde largo máximo en **picker** antes del recorte (documento / licencia).
/// Por debajo de ~3k px suele ser estable con UCrop + cámaras modernas.
const double kDriverRegistrationPickerSafeMaxEdgeDocument = 2560;

/// Igual para selfie (menos píxeles = menos RAM en crop cuadrado).
const double kDriverRegistrationPickerSafeMaxEdgeFace = 1920;

/// Vistas del vehículo (cuatro fotos): mismo tope seguro que documento antes del recorte.
const double kDriverRegistrationPickerSafeMaxEdgeVehicle = 2560;

/// Tope de salida del **crop** (reduce bitmap intermedio en UCrop y peso del JSON).
const int kDriverRegistrationCropMaxOutputEdgeDocument = 2800;
const int kDriverRegistrationCropMaxOutputEdgeFace = 1600;

/// Desactivar captura full-res (documento + selfie) con:
/// `--dart-define=DRIVER_REGISTRATION_FULL_RES_CAPTURE=false`
const bool kDriverRegistrationFullResCaptureEnabled = bool.fromEnvironment(
  'DRIVER_REGISTRATION_FULL_RES_CAPTURE',
  defaultValue: true,
);

const bool kDriverSelfieCropEnabled = bool.fromEnvironment(
  'DRIVER_SELFIE_CROP_ENABLED',
  defaultValue: bool.fromEnvironment(
    'SELFIE_CROP_ENABLED',
    defaultValue: true,
  ),
);
const bool kDriverDocumentCropEnabled = bool.fromEnvironment(
  'DRIVER_DOCUMENT_CROP_ENABLED',
  defaultValue: true,
);

/// Recorte UCrop en fotos de vehículo (alinear con documento/selfie).
const bool kDriverVehicleCropEnabled = bool.fromEnvironment(
  'DRIVER_VEHICLE_CROP_ENABLED',
  defaultValue: true,
);

/// KYC: por defecto **solo cámara** (menos fraude / fotos arbitrarias). Para permitir galería en QA:
/// `--dart-define=DRIVER_REGISTRATION_ALLOW_GALLERY=true`
const bool kDriverRegistrationAllowGalleryPicker = bool.fromEnvironment(
  'DRIVER_REGISTRATION_ALLOW_GALLERY',
  defaultValue: false,
);

const Color _kCropToolbarBg = Color(0xFFFFFFFF);
const Color _kCropToolbarFg = Color(0xFF1C1B1F);

/// Chrome compartido documento vs selfie (misma barra inferior en Android; iOS en nav).
/// Tema de actividad UCrop: `android/app/src/main/res/values/themes_ucrop.xml` + manifest.
List<PlatformUiSettings> _registrationCropUiSettings({
  required String title,
  required bool isSquarePortrait,
}) {
  return <PlatformUiSettings>[
    AndroidUiSettings(
      toolbarTitle: title,
      toolbarColor: _kCropToolbarBg,
      toolbarWidgetColor: _kCropToolbarFg,
      statusBarLight: true,
      navBarLight: true,
      backgroundColor: const Color(0xFFF4F4F5),
      activeControlsWidgetColor: const Color(0xFF1565C0),
      dimmedLayerColor: const Color(0x99000000),
      hideBottomControls: false,
      lockAspectRatio: isSquarePortrait,
      initAspectRatio:
          isSquarePortrait ? CropAspectRatioPreset.square : CropAspectRatioPreset.original,
      aspectRatioPresets: isSquarePortrait
          ? const [CropAspectRatioPreset.square, CropAspectRatioPreset.original]
          : const [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.square,
            ],
      cropStyle: CropStyle.rectangle,
    ),
    IOSUiSettings(
      title: title,
      embedInNavigationController: true,
      aspectRatioLockEnabled: isSquarePortrait,
      aspectRatioPickerButtonHidden: isSquarePortrait,
      resetAspectRatioEnabled: !isSquarePortrait,
      aspectRatioPresets: isSquarePortrait
          ? const [CropAspectRatioPreset.square, CropAspectRatioPreset.original]
          : const [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.square,
            ],
      cropStyle: CropStyle.rectangle,
    ),
  ];
}

Future<String> _maybeCropFaceImagePath(String sourcePath, String title) async {
  try {
    final cropped = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      maxWidth: kDriverRegistrationCropMaxOutputEdgeFace,
      maxHeight: kDriverRegistrationCropMaxOutputEdgeFace,
      compressQuality: 82,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: _registrationCropUiSettings(title: title, isSquarePortrait: true),
    );
    if (cropped == null) return sourcePath;
    return cropped.path;
  } catch (_) {
    return sourcePath;
  }
}

Future<String> _maybeCropDocumentImagePath(String sourcePath, String title) async {
  try {
    final cropped = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      maxWidth: kDriverRegistrationCropMaxOutputEdgeDocument,
      maxHeight: kDriverRegistrationCropMaxOutputEdgeDocument,
      compressQuality: 85,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: _registrationCropUiSettings(title: title, isSquarePortrait: false),
    );
    if (cropped == null) return sourcePath;
    return cropped.path;
  } catch (_) {
    return sourcePath;
  }
}

Future<String> _maybeCropVehicleImagePath(String sourcePath, String title) async {
  try {
    final cropped = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      maxWidth: kDriverRegistrationCropMaxOutputEdgeDocument,
      maxHeight: kDriverRegistrationCropMaxOutputEdgeDocument,
      compressQuality: 85,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: _registrationCropUiSettings(title: title, isSquarePortrait: false),
    );
    if (cropped == null) return sourcePath;
    return cropped.path;
  } catch (_) {
    return sourcePath;
  }
}

/// Qué tipo de foto se está cargando (define tope y resolución por defecto).
enum DriverRegistrationImageKind {
  /// Frente/dorso documento identidad o licencia.
  document,

  /// `face_image` en paso identidad.
  facePortrait,

  /// Fotos de ángulos del auto (4 en un request).
  vehicleAngle,
}

/// Cómo capturar **antes** del recorte ([ImageCropper]) y la compresión final.
enum DriverRegistrationImageCaptureStrategy {
  /// Captura alta con tope seguro en picker (no ilimitada) + crop + compresión final.
  fullResolutionThenCompress,

  /// Pide al picker limitar ya al borde final del producto (`edge`, p. ej. 1400 px doc).
  pickerPrefiltered,
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

DriverRegistrationImageCaptureStrategy _defaultCaptureStrategyForKind(
  DriverRegistrationImageKind kind,
) {
  if (!kDriverRegistrationFullResCaptureEnabled) {
    return DriverRegistrationImageCaptureStrategy.pickerPrefiltered;
  }
  return DriverRegistrationImageCaptureStrategy.fullResolutionThenCompress;
}

/// Primera pasada JPEG desde archivo de recorte/cámara (plugin puede devolver null en HEIC/raros).
Future<Uint8List> _decodePathToJpegBytes(
  String path,
  XFile xfile,
  int quality,
  int minWidth,
) async {
  try {
    final out = await FlutterImageCompress.compressWithFile(
      path,
      quality: quality,
      minWidth: minWidth,
      minHeight: 0,
      format: CompressFormat.jpeg,
      keepExif: false,
    );
    if (out != null && out.isNotEmpty) return out;
  } catch (_) {}
  try {
    final raw = await File(path).readAsBytes();
    if (raw.isEmpty) return Uint8List(0);
    return await FlutterImageCompress.compressWithList(
      raw,
      minWidth: minWidth > 0 ? minWidth : 1280,
      minHeight: 0,
      quality: quality,
      format: CompressFormat.jpeg,
      keepExif: false,
    );
  } catch (_) {}
  final fallback = await xfile.readAsBytes();
  return Uint8List.fromList(fallback);
}

Future<Uint8List> _compressLoopUnderCap({
  required Uint8List initial,
  required int cap,
  required int edge,
  required int q0,
  required int maxPasses,
}) async {
  var bytes = initial;
  var q = q0.clamp(50, 95);
  var targetW = edge;

  for (var pass = 0; pass < maxPasses && bytes.lengthInBytes > cap; pass++) {
    await Future<void>.delayed(Duration.zero);
    q = (q - 6).clamp(50, 95);
    targetW = (targetW * 0.86).round().clamp(480, edge);
    bytes = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: targetW,
      minHeight: 0,
      quality: q,
      format: CompressFormat.jpeg,
      keepExif: false,
    );
  }
  return bytes;
}

Future<String?> _pickImageAsBase64OneStrategy(
  BuildContext context, {
  required DriverRegistrationImageKind kind,
  required int cap,
  required int q0,
  required int edge,
  required DriverRegistrationImageCaptureStrategy strategy,
  required bool silentFailureSnack,
  required bool showCompatibleModeInfo,
}) async {
  final l10n = AppLocalizations.of(context);
  final lim = _limitsForKind(kind);
  final ImageSource? source = kDriverRegistrationAllowGalleryPicker
      ? await showModalBottomSheet<ImageSource>(
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
        )
      : ImageSource.camera;
  if (!context.mounted || source == null) return null;

  final picker = ImagePicker();
  try {
    Future<XFile?> pickOnce() async {
      if (strategy == DriverRegistrationImageCaptureStrategy.fullResolutionThenCompress) {
        final capPx = switch (kind) {
          DriverRegistrationImageKind.facePortrait => kDriverRegistrationPickerSafeMaxEdgeFace,
          DriverRegistrationImageKind.document => kDriverRegistrationPickerSafeMaxEdgeDocument,
          DriverRegistrationImageKind.vehicleAngle => kDriverRegistrationPickerSafeMaxEdgeVehicle,
        };
        return picker.pickImage(
          source: source,
          imageQuality: 92,
          maxWidth: capPx,
          maxHeight: capPx,
        );
      }
      return picker.pickImage(
        source: source,
        imageQuality: lim.pickerQuality,
        maxWidth: edge.toDouble(),
        maxHeight: edge.toDouble(),
      );
    }

    XFile? xfile = await pickOnce();
    if (xfile == null) return null;

    // Deja que la actividad nativa de la cámara libere recursos antes del sheet / UCrop.
    await Future<void>.delayed(const Duration(milliseconds: 160));

    Future<String> runCrop(String path) async {
      return switch (kind) {
        DriverRegistrationImageKind.facePortrait when kDriverSelfieCropEnabled =>
          await _maybeCropFaceImagePath(path, l10n.driverRegCropSelfieTitle),
        DriverRegistrationImageKind.document when kDriverDocumentCropEnabled =>
          await _maybeCropDocumentImagePath(path, l10n.driverRegCropDocumentTitle),
        DriverRegistrationImageKind.vehicleAngle when kDriverVehicleCropEnabled =>
          await _maybeCropVehicleImagePath(path, l10n.driverRegCropVehicleTitle),
        _ => path,
      };
    }

    final cropOffered = (kind == DriverRegistrationImageKind.facePortrait &&
            kDriverSelfieCropEnabled) ||
        (kind == DriverRegistrationImageKind.document && kDriverDocumentCropEnabled) ||
        (kind == DriverRegistrationImageKind.vehicleAngle && kDriverVehicleCropEnabled);

    var workingPath = xfile.path;
    while (context.mounted) {
      if (!context.mounted) return null;
      final outcome = await showRegistrationPhotoReviewSheet(
        context,
        imagePath: workingPath,
        cropEnabled: cropOffered,
        onCrop: runCrop,
      );
      if (!context.mounted) return null;
      if (outcome == null || outcome.action == RegistrationPhotoReviewAction.cancelled) {
        return null;
      }
      if (outcome.action == RegistrationPhotoReviewAction.retake) {
        xfile = await pickOnce();
        if (xfile == null) return null;
        workingPath = xfile.path;
        await Future<void>.delayed(const Duration(milliseconds: 160));
        if (!context.mounted) return null;
        continue;
      }
      if (outcome.action == RegistrationPhotoReviewAction.confirmed) {
        final p = outcome.path;
        if (p == null || p.isEmpty) return null;
        workingPath = p;
        break;
      }
    }

    final path = workingPath;
    final xfileForDecode = XFile(path);

    final passes = strategy == DriverRegistrationImageCaptureStrategy.fullResolutionThenCompress
        ? kDriverRegistrationCompressExtraPassesFullCapture
        : kDriverRegistrationCompressExtraPasses;

    var bytes = await _decodePathToJpegBytes(path, xfileForDecode, q0, edge);
    if (bytes.isEmpty) {
      if (context.mounted && !silentFailureSnack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.driverRegImageReadError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return null;
    }
    bytes = await _compressLoopUnderCap(
      initial: bytes,
      cap: cap,
      edge: edge,
      q0: q0,
      maxPasses: passes,
    );

    if (!context.mounted) return null;
    if (bytes.lengthInBytes > cap) {
      if (!silentFailureSnack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.driverRegImageTooLarge((cap / 1024).round())),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return null;
    }
    if (showCompatibleModeInfo) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.driverRegImageCompatibleCaptureUsed),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    return encodeRegistrationJpegBytesToBase64(bytes);
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('registration_image_helper strategy=$strategy err=$e');
      debugPrint('$st');
    }
    if (context.mounted && !silentFailureSnack) {
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

/// Codifica JPEG (sin EXIF) a Base64 crudo. [kind] ajusta peso y borde según el paso.
///
/// Tras la captura se muestra una **hoja de revisión** (usar / otra foto / recortar); el
/// recorte UCrop solo si el usuario elige editar (o si los flags `*_CROP_ENABLED` lo permiten).
///
/// [captureStrategy] por defecto: con full-res habilitado, documento, selfie y vehículo usan
/// **captura alta acotada** en picker (~2560 px borde largo salvo selfie 1920) + compresión
/// final y reintento compatible si falla.
Future<String?> pickImageAsBase64(
  BuildContext context, {
  DriverRegistrationImageKind kind = DriverRegistrationImageKind.document,
  int? maxBytes,
  int? imageQuality,
  double? maxWidth,
  DriverRegistrationImageCaptureStrategy? captureStrategy,
}) async {
  final lim = _limitsForKind(kind);
  final cap = maxBytes ?? lim.maxBytes;
  final q0 = imageQuality ?? lim.imageQuality;
  final edge = (maxWidth ?? lim.maxEdgePx).round().clamp(320, 4096);

  final primary = captureStrategy ?? _defaultCaptureStrategyForKind(kind);
  final attempts = <DriverRegistrationImageCaptureStrategy>[primary];
  if (primary == DriverRegistrationImageCaptureStrategy.fullResolutionThenCompress) {
    attempts.add(DriverRegistrationImageCaptureStrategy.pickerPrefiltered);
  }

  for (var i = 0; i < attempts.length; i++) {
    final silent = i < attempts.length - 1;
    final showInfo = i > 0 && !silent;
    final r = await _pickImageAsBase64OneStrategy(
      context,
      kind: kind,
      cap: cap,
      q0: q0,
      edge: edge,
      strategy: attempts[i],
      silentFailureSnack: silent,
      showCompatibleModeInfo: showInfo,
    );
    if (r != null) return r;
  }
  return null;
}

/// Fuerza el modo **picker prefiltado** (una sola pasada). Útil si el usuario quiere
/// repetir la carga con menos resolución inicial sin tocar defines.
Future<String?> pickImageAsBase64PickerPrefiltered(
  BuildContext context, {
  DriverRegistrationImageKind kind = DriverRegistrationImageKind.document,
  int? maxBytes,
  int? imageQuality,
  double? maxWidth,
}) {
  return pickImageAsBase64(
    context,
    kind: kind,
    maxBytes: maxBytes,
    imageQuality: imageQuality,
    maxWidth: maxWidth,
    captureStrategy: DriverRegistrationImageCaptureStrategy.pickerPrefiltered,
  );
}
