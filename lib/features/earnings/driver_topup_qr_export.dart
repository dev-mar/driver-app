import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/money_formatter.dart';
import 'driver_credits_topup_models.dart';

/// Descarga el QR a un archivo temporal para guardar o compartir.
Future<File> downloadDriverTopupQrFile(DriverTopupPackage pkg) async {
  final url = pkg.qrImageUrl?.trim() ?? '';
  if (url.isEmpty) {
    throw const DriverTopupQrExportException('missing_url');
  }
  final dio = Dio();
  final res = await dio.get<List<int>>(
    url,
    options: Options(responseType: ResponseType.bytes),
  );
  final bytes = res.data;
  if (bytes == null || bytes.isEmpty) {
    throw const DriverTopupQrExportException('empty');
  }
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/texi-qr-${pkg.amount.toStringAsFixed(0)}.jpg');
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

Future<void> shareDriverTopupQrFile(File file, DriverTopupPackage pkg) async {
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'image/jpeg')],
      text: '${pkg.title} · ${formatMoney(pkg.amount)}',
    ),
  );
}

/// Guarda en la galería / fotos del dispositivo (sin permiso de lectura amplio).
Future<DriverTopupQrSaveResult> saveDriverTopupQrToGallery(File file) async {
  final hasAccess = await Gal.hasAccess(toAlbum: true);
  if (!hasAccess) {
    final granted = await Gal.requestAccess(toAlbum: true);
    if (!granted) return DriverTopupQrSaveResult.permissionDenied;
  }
  await Gal.putImage(file.path, album: 'TEXIAPP');
  return DriverTopupQrSaveResult.saved;
}

enum DriverTopupQrSaveResult { saved, permissionDenied }

class DriverTopupQrExportException implements Exception {
  const DriverTopupQrExportException(this.code);
  final String code;
}
