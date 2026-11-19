import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum DriverWaypointPinStyle { pickupPerson, destinationX }

const Color kDriverPinBrandYellow = Color(0xFFF9AB00);
const Color kDriverPinBrandBlack = Color(0xFF111111);
const double kDriverWaypointPinTipAnchorY = 0.97;
const double kDriverMapPinPixelRatio = 3;

double _driverWaypointPinPixelRatio() {
  final views = WidgetsBinding.instance.platformDispatcher.views;
  if (views.isEmpty) return kDriverMapPinPixelRatio;
  return math.max(kDriverMapPinPixelRatio, views.first.devicePixelRatio);
}

Future<BitmapDescriptor> buildDriverWaypointMapPinIcon({
  double logicalSize = 56,
  required Color fill,
  Color? stroke,
  DriverWaypointPinStyle style = DriverWaypointPinStyle.pickupPerson,
}) async {
  final outline = stroke ??
      (style == DriverWaypointPinStyle.destinationX
          ? kDriverPinBrandYellow
          : kDriverPinBrandBlack);
  final logicalWidth = logicalSize;
  final logicalHeight = logicalSize * 1.28;
  final dpr = _driverWaypointPinPixelRatio();
  final pixelW = (logicalWidth * dpr).ceil();
  final pixelH = (logicalHeight * dpr).ceil();
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.scale(dpr);
  final w = logicalWidth;
  final h = logicalHeight;
  final cx = w * 0.5;
  final headCenter = Offset(cx, h * 0.34);
  final headR = w * 0.30;

  final pinPath = Path()
    ..moveTo(cx, h * 0.97)
    ..quadraticBezierTo(
      cx + headR * 0.42,
      headCenter.dy + headR * 0.92,
      cx + headR,
      headCenter.dy,
    )
    ..arcToPoint(
      Offset(cx - headR, headCenter.dy),
      radius: Radius.circular(headR),
      clockwise: true,
    )
    ..quadraticBezierTo(
      cx - headR * 0.42,
      headCenter.dy + headR * 0.92,
      cx,
      h * 0.97,
    )
    ..close();

  canvas.drawShadow(pinPath, Colors.black.withValues(alpha: 0.38), 6, true);
  canvas.drawPath(
    pinPath,
    Paint()
      ..isAntiAlias = true
      ..color = fill
      ..style = PaintingStyle.fill,
  );
  canvas.drawPath(
    pinPath,
    Paint()
      ..isAntiAlias = true
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.drawCircle(
    headCenter,
    headR * 0.62,
    Paint()
      ..isAntiAlias = true
      ..color = Colors.white
      ..style = PaintingStyle.fill,
  );
  canvas.drawCircle(
    headCenter,
    headR * 0.62,
    Paint()
      ..isAntiAlias = true
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6,
  );

  if (style == DriverWaypointPinStyle.pickupPerson) {
    final r = headR * 0.52;
    final paint = Paint()
      ..isAntiAlias = true
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.2, r * 0.22)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()
      ..isAntiAlias = true
      ..color = outline
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(headCenter.dx, headCenter.dy - r * 0.42),
      r * 0.22,
      fillPaint,
    );
    canvas.drawLine(
      Offset(headCenter.dx, headCenter.dy - r * 0.16),
      Offset(headCenter.dx, headCenter.dy + r * 0.28),
      paint,
    );
    canvas.drawLine(
      Offset(headCenter.dx, headCenter.dy + r * 0.02),
      Offset(headCenter.dx - r * 0.38, headCenter.dy + r * 0.22),
      paint,
    );
    canvas.drawLine(
      Offset(headCenter.dx, headCenter.dy),
      Offset(headCenter.dx + r * 0.46, headCenter.dy - r * 0.48),
      paint,
    );
    canvas.drawLine(
      Offset(headCenter.dx, headCenter.dy + r * 0.28),
      Offset(headCenter.dx - r * 0.26, headCenter.dy + r * 0.62),
      paint,
    );
    canvas.drawLine(
      Offset(headCenter.dx, headCenter.dy + r * 0.28),
      Offset(headCenter.dx + r * 0.24, headCenter.dy + r * 0.62),
      paint,
    );
  } else {
    final r = headR * 0.36;
    final paint = Paint()
      ..isAntiAlias = true
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.6, r * 0.38)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(headCenter.dx - r, headCenter.dy - r),
      Offset(headCenter.dx + r, headCenter.dy + r),
      paint,
    );
    canvas.drawLine(
      Offset(headCenter.dx + r, headCenter.dy - r),
      Offset(headCenter.dx - r, headCenter.dy + r),
      paint,
    );
  }

  final picture = recorder.endRecording();
  final img = await picture.toImage(pixelW, pixelH);
  final bd = await img.toByteData(format: ui.ImageByteFormat.png);
  if (bd == null) {
    return BitmapDescriptor.defaultMarkerWithHue(
      style == DriverWaypointPinStyle.destinationX
          ? BitmapDescriptor.hueRed
          : BitmapDescriptor.hueYellow,
    );
  }
  return BitmapDescriptor.bytes(
    bd.buffer.asUint8List(),
    width: logicalWidth,
    height: logicalHeight,
    imagePixelRatio: dpr,
  );
}

/// Pin con el nombre de calle encima, para el detalle de solicitud.
Future<BitmapDescriptor> buildDriverLabeledWaypointPinIcon({
  required Color fill,
  required String label,
  Color? stroke,
  DriverWaypointPinStyle style = DriverWaypointPinStyle.pickupPerson,
}) async {
  final short = _shortWaypointLabel(label);
  final pinSize = 52.0;
  final pinH = pinSize * 1.28;
  final textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    maxLines: 1,
    ellipsis: '…',
    text: TextSpan(
      text: short,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.1,
      ),
    ),
  )..layout(maxWidth: 168);
  const labelPadX = 8.0;
  const labelPadY = 5.0;
  final labelW = math.min(184.0, textPainter.width + labelPadX * 2);
  final labelH = textPainter.height + labelPadY * 2;
  final logicalWidth = math.max(pinSize, labelW + 8);
  final logicalHeight = labelH + 6 + pinH;
  final dpr = _driverWaypointPinPixelRatio();
  final pixelW = (logicalWidth * dpr).ceil();
  final pixelH = (logicalHeight * dpr).ceil();
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.scale(dpr);

  final labelRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(
      (logicalWidth - labelW) / 2,
      0,
      labelW,
      labelH,
    ),
    const Radius.circular(8),
  );
  canvas.drawRRect(
    labelRect,
    Paint()..color = const Color(0xE6111111),
  );
  canvas.drawRRect(
    labelRect,
    Paint()
      ..color = (style == DriverWaypointPinStyle.destinationX
              ? kDriverPinBrandYellow
              : fill)
          .withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1,
  );
  textPainter.paint(
    canvas,
    Offset(
      (logicalWidth - textPainter.width) / 2,
      (labelH - textPainter.height) / 2,
    ),
  );

  canvas.save();
  canvas.translate((logicalWidth - pinSize) / 2, labelH + 6);
  _paintWaypointPin(
    canvas: canvas,
    logicalSize: pinSize,
    fill: fill,
    stroke: stroke,
    style: style,
  );
  canvas.restore();

  final picture = recorder.endRecording();
  final img = await picture.toImage(pixelW, pixelH);
  final bd = await img.toByteData(format: ui.ImageByteFormat.png);
  if (bd == null) {
    return buildDriverWaypointMapPinIcon(
      fill: fill,
      stroke: stroke,
      style: style,
    );
  }
  return BitmapDescriptor.bytes(
    bd.buffer.asUint8List(),
    width: logicalWidth,
    height: logicalHeight,
    imagePixelRatio: dpr,
  );
}

String _shortWaypointLabel(String raw) {
  final first = raw.split(',').first.trim();
  if (first.isEmpty) return raw.trim();
  if (first.length <= 28) return first;
  return '${first.substring(0, 26)}…';
}

double labeledWaypointPinAnchorY(String label) {
  final short = _shortWaypointLabel(label);
  final textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    maxLines: 1,
    text: TextSpan(
      text: short,
      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
    ),
  )..layout(maxWidth: 168);
  final labelH = textPainter.height + 10;
  final pinH = 52.0 * 1.28;
  final logicalHeight = labelH + 6 + pinH;
  return (labelH + 6 + pinH * 0.97) / logicalHeight;
}

void _paintWaypointPin({
  required Canvas canvas,
  required double logicalSize,
  required Color fill,
  Color? stroke,
  required DriverWaypointPinStyle style,
}) {
  final outline = stroke ??
      (style == DriverWaypointPinStyle.destinationX
          ? kDriverPinBrandYellow
          : kDriverPinBrandBlack);
  final w = logicalSize;
  final h = logicalSize * 1.28;
  final cx = w * 0.5;
  final headCenter = Offset(cx, h * 0.34);
  final headR = w * 0.30;

  final pinPath = Path()
    ..moveTo(cx, h * 0.97)
    ..quadraticBezierTo(
      cx + headR * 0.42,
      headCenter.dy + headR * 0.92,
      cx + headR,
      headCenter.dy,
    )
    ..arcToPoint(
      Offset(cx - headR, headCenter.dy),
      radius: Radius.circular(headR),
      clockwise: true,
    )
    ..quadraticBezierTo(
      cx - headR * 0.42,
      headCenter.dy + headR * 0.92,
      cx,
      h * 0.97,
    )
    ..close();

  canvas.drawShadow(pinPath, Colors.black.withValues(alpha: 0.38), 6, true);
  canvas.drawPath(
    pinPath,
    Paint()
      ..isAntiAlias = true
      ..color = fill
      ..style = PaintingStyle.fill,
  );
  canvas.drawPath(
    pinPath,
    Paint()
      ..isAntiAlias = true
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeJoin = StrokeJoin.round,
  );
  canvas.drawCircle(
    headCenter,
    headR * 0.62,
    Paint()
      ..isAntiAlias = true
      ..color = Colors.white
      ..style = PaintingStyle.fill,
  );
  canvas.drawCircle(
    headCenter,
    headR * 0.62,
    Paint()
      ..isAntiAlias = true
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6,
  );

  if (style == DriverWaypointPinStyle.pickupPerson) {
    final r = headR * 0.52;
    final paint = Paint()
      ..isAntiAlias = true
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.2, r * 0.22)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()
      ..isAntiAlias = true
      ..color = outline
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(headCenter.dx, headCenter.dy - r * 0.42),
      r * 0.22,
      fillPaint,
    );
    canvas.drawLine(
      Offset(headCenter.dx, headCenter.dy - r * 0.16),
      Offset(headCenter.dx, headCenter.dy + r * 0.28),
      paint,
    );
    canvas.drawLine(
      Offset(headCenter.dx, headCenter.dy + r * 0.02),
      Offset(headCenter.dx - r * 0.38, headCenter.dy + r * 0.22),
      paint,
    );
    canvas.drawLine(
      Offset(headCenter.dx, headCenter.dy),
      Offset(headCenter.dx + r * 0.46, headCenter.dy - r * 0.48),
      paint,
    );
    canvas.drawLine(
      Offset(headCenter.dx, headCenter.dy + r * 0.28),
      Offset(headCenter.dx - r * 0.26, headCenter.dy + r * 0.62),
      paint,
    );
    canvas.drawLine(
      Offset(headCenter.dx, headCenter.dy + r * 0.28),
      Offset(headCenter.dx + r * 0.24, headCenter.dy + r * 0.62),
      paint,
    );
  } else {
    final r = headR * 0.36;
    final paint = Paint()
      ..isAntiAlias = true
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2.6, r * 0.38)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(headCenter.dx - r, headCenter.dy - r),
      Offset(headCenter.dx + r, headCenter.dy + r),
      paint,
    );
    canvas.drawLine(
      Offset(headCenter.dx + r, headCenter.dy - r),
      Offset(headCenter.dx - r, headCenter.dy + r),
      paint,
    );
  }
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
