import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> buildDriverWaypointMapPinIcon({
  double logicalSize = 56,
  required Color fill,
  Color stroke = const Color(0xFFFFFFFF),
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final w = logicalSize;
  final h = logicalSize;
  final center = Offset(w * 0.5, h * 0.38);
  final radius = w * 0.24;

  final pinPath = Path()
    ..addOval(Rect.fromCircle(center: center, radius: radius))
    ..moveTo(w * 0.5, h * 0.93)
    ..lineTo(w * 0.68, h * 0.56)
    ..lineTo(w * 0.32, h * 0.56)
    ..close();

  canvas.drawShadow(pinPath, Colors.black.withValues(alpha: 0.35), 5, true);
  canvas.drawPath(
    pinPath,
    Paint()
      ..color = fill
      ..style = PaintingStyle.fill,
  );
  canvas.drawPath(
    pinPath,
    Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2,
  );
  canvas.drawCircle(
    center,
    radius * 0.45,
    Paint()
      ..color = Colors.white.withValues(alpha: 0.92)
      ..style = PaintingStyle.fill,
  );
  final haloRadius = radius * 0.62;
  canvas.drawCircle(
    center,
    haloRadius,
    Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6,
  );

  final pulseAngle = math.pi / 6;
  final accentPath = Path()
    ..moveTo(
      center.dx + math.cos(pulseAngle) * radius * 1.08,
      center.dy - math.sin(pulseAngle) * radius * 1.08,
    )
    ..arcTo(
      Rect.fromCircle(center: center, radius: radius * 1.08),
      -pulseAngle,
      pulseAngle * 1.4,
      false,
    );
  canvas.drawPath(
    accentPath,
    Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8,
  );

  final picture = recorder.endRecording();
  final img = await picture.toImage(logicalSize.ceil(), logicalSize.ceil());
  final bd = await img.toByteData(format: ui.ImageByteFormat.png);
  if (bd == null) {
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  }
  return BitmapDescriptor.bytes(bd.buffer.asUint8List());
}

Future<BitmapDescriptor> buildDriverRouteReferenceIcon({
  required IconData icon,
  required Color background,
  double logicalSize = 56,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final center = Offset(logicalSize * 0.5, logicalSize * 0.5);
  final radius = logicalSize * 0.32;
  final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.28);

  canvas.drawCircle(center.translate(0, 2), radius, shadowPaint);
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..color = background
      ..style = PaintingStyle.fill,
  );
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8,
  );

  final textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    text: TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: logicalSize * 0.34,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: Colors.white,
      ),
    ),
  )..layout();
  textPainter.paint(
    canvas,
    Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    ),
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(logicalSize.ceil(), logicalSize.ceil());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) {
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  }
  return BitmapDescriptor.bytes(bytes.buffer.asUint8List());
}
