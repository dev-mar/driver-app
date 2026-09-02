import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../../gen_l10n/app_localizations.dart';

/// Tope de un comprobante bancario típico (captura de pantalla / foto de voucher).
const int kDriverTopupReceiptMaxSourceBytes = 8 * 1024 * 1024;
const int kDriverTopupReceiptMaxBytes = 600 * 1024;
const int kDriverTopupReceiptMaxEdge = 1600;

const int kDriverTopupOriginAccountMaxLength = 48;
const int kDriverTopupTransactionRefMaxLength = 400;
const int kDriverTopupTransferFieldMinLength = 4;

enum DriverTopupReceiptPickError {
  canceled,
  invalidType,
  tooLarge,
  compressFailed,
}

class DriverTopupReceiptPickResult {
  const DriverTopupReceiptPickResult({this.base64Jpeg, this.error});

  final String? base64Jpeg;
  final DriverTopupReceiptPickError? error;

  bool get ok => base64Jpeg != null && base64Jpeg!.isNotEmpty;
}

/// Galería / archivos del sistema. Sin cámara y sin guardar el permiso.
Future<DriverTopupReceiptPickResult> pickDriverTopupReceiptFromDevice(
  BuildContext context,
) async {
  final l10n = AppLocalizations.of(context);
  final proceed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        title: Text(l10n.driverTopupGalleryDisclosureTitle),
        content: Text(l10n.driverTopupGalleryDisclosureBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.driverTopupGalleryDisclosureContinue),
          ),
        ],
      );
    },
  );
  if (proceed != true || !context.mounted) {
    return const DriverTopupReceiptPickResult(
      error: DriverTopupReceiptPickError.canceled,
    );
  }

  final picker = ImagePicker();
  final XFile? file;
  try {
    file = await picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
      imageQuality: 85,
      maxWidth: kDriverTopupReceiptMaxEdge.toDouble(),
      maxHeight: kDriverTopupReceiptMaxEdge.toDouble(),
    );
  } catch (_) {
    return const DriverTopupReceiptPickResult(
      error: DriverTopupReceiptPickError.invalidType,
    );
  }
  if (file == null) {
    return const DriverTopupReceiptPickResult(
      error: DriverTopupReceiptPickError.canceled,
    );
  }
  if (!_looksLikeReceiptImage(file)) {
    return const DriverTopupReceiptPickResult(
      error: DriverTopupReceiptPickError.invalidType,
    );
  }

  final sourceLen = await file.length();
  if (sourceLen <= 0 || sourceLen > kDriverTopupReceiptMaxSourceBytes) {
    return const DriverTopupReceiptPickResult(
      error: DriverTopupReceiptPickError.tooLarge,
    );
  }

  try {
    var bytes = await _toJpeg(file);
    if (bytes.isEmpty) {
      return const DriverTopupReceiptPickResult(
        error: DriverTopupReceiptPickError.compressFailed,
      );
    }
    var q = 78;
    var edge = kDriverTopupReceiptMaxEdge;
    for (var i = 0; i < 6 && bytes.lengthInBytes > kDriverTopupReceiptMaxBytes; i++) {
      q = (q - 8).clamp(52, 85);
      edge = (edge * 0.88).round().clamp(720, kDriverTopupReceiptMaxEdge);
      bytes = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: edge,
        minHeight: 0,
        quality: q,
        format: CompressFormat.jpeg,
        keepExif: false,
      );
    }
    if (bytes.lengthInBytes > kDriverTopupReceiptMaxBytes) {
      return const DriverTopupReceiptPickResult(
        error: DriverTopupReceiptPickError.tooLarge,
      );
    }
    return DriverTopupReceiptPickResult(base64Jpeg: base64Encode(bytes));
  } catch (_) {
    return const DriverTopupReceiptPickResult(
      error: DriverTopupReceiptPickError.compressFailed,
    );
  }
}

bool _looksLikeReceiptImage(XFile file) {
  final mime = (file.mimeType ?? '').toLowerCase();
  final name = file.name.toLowerCase();
  const ok = <String>['jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'];
  if (mime.startsWith('image/')) {
    return mime.contains('jpeg') ||
        mime.contains('jpg') ||
        mime.contains('png') ||
        mime.contains('webp') ||
        mime.contains('heic') ||
        mime.contains('heif');
  }
  return ok.any((e) => name.endsWith('.$e'));
}

Future<Uint8List> _toJpeg(XFile file) async {
  try {
    final out = await FlutterImageCompress.compressWithFile(
      file.path,
      quality: 78,
      minWidth: kDriverTopupReceiptMaxEdge,
      minHeight: 0,
      format: CompressFormat.jpeg,
      keepExif: false,
    );
    if (out != null && out.isNotEmpty) return out;
  } catch (_) {}
  try {
    final raw = await File(file.path).readAsBytes();
    if (raw.isEmpty) return Uint8List(0);
    return await FlutterImageCompress.compressWithList(
      raw,
      minWidth: kDriverTopupReceiptMaxEdge,
      minHeight: 0,
      quality: 78,
      format: CompressFormat.jpeg,
      keepExif: false,
    );
  } catch (_) {}
  return Uint8List(0);
}
