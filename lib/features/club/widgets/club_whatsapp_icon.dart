import 'package:flutter/material.dart';

/// Glifo compacto estilo WhatsApp, alineado a la paleta del hub Club.
class ClubWhatsAppIcon extends StatelessWidget {
  const ClubWhatsAppIcon({
    super.key,
    this.size = 18,
    this.color = const Color(0xFF25D366),
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ClubWhatsAppPainter(color),
      ),
    );
  }
}

class _ClubWhatsAppPainter extends CustomPainter {
  _ClubWhatsAppPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    final bubble = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.08, h * 0.02, w * 0.84, h * 0.78),
          Radius.circular(w * 0.38),
        ),
      )
      ..moveTo(w * 0.22, h * 0.72)
      ..lineTo(w * 0.16, h * 0.98)
      ..lineTo(w * 0.42, h * 0.78)
      ..close();
    canvas.drawPath(bubble, paint);

    final handset = Path()
      ..moveTo(w * 0.32, h * 0.28)
      ..quadraticBezierTo(w * 0.28, h * 0.42, w * 0.38, h * 0.54)
      ..quadraticBezierTo(w * 0.5, h * 0.66, w * 0.64, h * 0.58)
      ..quadraticBezierTo(w * 0.7, h * 0.54, w * 0.66, h * 0.44)
      ..quadraticBezierTo(w * 0.62, h * 0.4, w * 0.56, h * 0.44)
      ..quadraticBezierTo(w * 0.48, h * 0.5, w * 0.42, h * 0.42)
      ..quadraticBezierTo(w * 0.36, h * 0.32, w * 0.4, h * 0.26)
      ..quadraticBezierTo(w * 0.36, h * 0.22, w * 0.32, h * 0.28)
      ..close();
    canvas.drawPath(
      handset,
      Paint()
        ..color = const Color(0xFF0B1A12)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _ClubWhatsAppPainter oldDelegate) =>
      oldDelegate.color != color;
}
