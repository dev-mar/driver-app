import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Pin de navegación externa, dibujado en canvas.
///
/// Geometría propia (no es un asset de terceros): escala nítida en cualquier
/// densidad y no depende de un PNG.
class DriverMapsNavigateMark extends StatelessWidget {
  const DriverMapsNavigateMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(painter: _MapsNavigateMarkPainter()),
    );
  }
}

class _MapsNavigateMarkPainter extends CustomPainter {
  const _MapsNavigateMarkPainter();

  static const Color _red = Color(0xFFEA4335);
  static const Color _blue = Color(0xFF4285F4);
  static const Color _green = Color(0xFF34A853);
  static const Color _yellow = Color(0xFFFBBC04);
  static const Color _hole = Color(0xFFFFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(side / 64);

    const center = Offset(32, 24.5);
    const radius = 15.2;
    const tip = Offset(32, 54.8);
    final pin = _pinPath(center, radius, tip);

    canvas.drawPath(
      pin.shift(const Offset(0, 1.6)),
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2)
        ..isAntiAlias = true,
    );

    canvas.save();
    canvas.clipPath(pin);
    canvas.drawPath(pin, Paint()..color = _green);

    final wedge = Paint()..isAntiAlias = true;
    final bulb = Rect.fromCircle(center: center, radius: radius + 1.8);

    wedge.color = _yellow;
    canvas.drawArc(bulb, _rad(100), _rad(94), true, wedge);

    wedge.color = _blue;
    canvas.drawArc(bulb, _rad(336), _rad(80), true, wedge);

    wedge.color = _red;
    canvas.drawArc(bulb, _rad(188), _rad(154), true, wedge);
    canvas.restore();

    canvas.drawCircle(center, 5.7, Paint()..color = _hole);

    canvas.drawPath(
      pin,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..color = const Color(0x2E000000)
        ..isAntiAlias = true,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  double _rad(double degrees) => degrees * math.pi / 180;

  /// Cabeza circular y punta tangente. El arco largo va por arriba.
  Path _pinPath(Offset center, double radius, Offset tip) {
    final dx = tip.dx - center.dx;
    final dy = tip.dy - center.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    final base = math.atan2(dy, dx);
    final offset = math.acos((radius / dist).clamp(0.0, 1.0));
    final start = base - offset;
    final end = base + offset;
    final topSweep = -(math.pi * 2 - (end - start));

    return Path()
      ..moveTo(
        center.dx + radius * math.cos(start),
        center.dy + radius * math.sin(start),
      )
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        start,
        topSweep,
        false,
      )
      ..lineTo(tip.dx, tip.dy)
      ..close();
  }
}

/// Flecha de navegación asistida. Mismos cuatro colores que el pin de la
/// tarjeta, con la forma que el conductor ya asocia a “iniciar ruta”.
class DriverMapsNavigateArrow extends StatelessWidget {
  const DriverMapsNavigateArrow({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(painter: _MapsNavigateArrowPainter()),
    );
  }
}

class _MapsNavigateArrowPainter extends CustomPainter {
  const _MapsNavigateArrowPainter();

  static const Color _red = Color(0xFFEA4335);
  static const Color _blue = Color(0xFF4285F4);
  static const Color _green = Color(0xFF34A853);
  static const Color _yellow = Color(0xFFFBBC04);

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(side / 64);
    canvas.translate(32, 32);
    canvas.rotate(0.58);
    canvas.scale(0.88);
    canvas.translate(-32, -32);

    final arrow = _arrowPath();
    canvas.drawPath(
      arrow.shift(const Offset(0.6, 1.5)),
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6)
        ..isAntiAlias = true,
    );

    canvas.save();
    canvas.clipPath(arrow);
    canvas.drawPath(arrow, Paint()..color = _green);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 32, 64),
      Paint()..color = _yellow,
    );
    canvas.drawRect(const Rect.fromLTWH(32, 0, 32, 64), Paint()..color = _blue);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 64, 26), Paint()..color = _red);
    canvas.drawRect(
      const Rect.fromLTWH(16, 44, 32, 20),
      Paint()..color = _green,
    );
    canvas.restore();

    canvas.drawPath(
      arrow,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0x40FFFFFF)
        ..isAntiAlias = true,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  /// Punta arriba y muesca en la cola: la silueta de “ir”.
  Path _arrowPath() {
    return Path()
      ..moveTo(32, 6)
      ..lineTo(56, 40)
      ..lineTo(39, 36)
      ..lineTo(39, 56)
      ..quadraticBezierTo(32, 44, 25, 56)
      ..lineTo(25, 36)
      ..lineTo(8, 40)
      ..close();
  }
}
