import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../gen_l10n/app_localizations.dart';

/// Botón sin texto: mapa + ruta + pines. El tap abre el detalle.
class DriverOfferSeeOnMapButton extends StatelessWidget {
  const DriverOfferSeeOnMapButton({
    super.key,
    required this.l10n,
    required this.onPressed,
    this.enabled = true,
  });

  final AppLocalizations l10n;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: l10n.driverTripOfferSeeOnMap,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: l10n.driverTripOfferSeeOnMap,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled
                ? () {
                    HapticFeedback.lightImpact();
                    onPressed();
                  }
                : null,
            customBorder: const CircleBorder(),
            child: Ink(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Opacity(
                opacity: enabled ? 1 : 0.45,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: CustomPaint(painter: _SeeTripDetailPainter()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeeTripDetailPainter extends CustomPainter {
  const _SeeTripDetailPainter();

  static const Color _fill = Color(0xFF141414);
  static const Color _ring = Color(0xFFFFD600);
  static const Color _map = Color(0xFF2A2A24);
  static const Color _fold = Color(0xFF3A382C);
  static const Color _teal = Color(0xFF00BFA5);

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final c = Offset(size.width / 2, size.height / 2);
    final r = side / 2;

    canvas.drawCircle(
      c.translate(0, 1.2),
      r - 1.2,
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );
    canvas.drawCircle(
      c,
      r - 1.4,
      Paint()
        ..shader = const RadialGradient(
          colors: [_fill, Color(0xFF0C0C0C)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c,
      r - 2.1,
      Paint()
        ..color = _ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    final map = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c.translate(0, 1), width: side * 0.58, height: side * 0.42),
      const Radius.circular(5),
    );
    canvas.drawRRect(map, Paint()..color = _map);
    canvas.drawRRect(
      map,
      Paint()
        ..color = _ring.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final fold = Path()
      ..moveTo(map.right - 9, map.top)
      ..lineTo(map.right, map.top + 9)
      ..lineTo(map.right, map.top)
      ..close();
    canvas.drawPath(fold, Paint()..color = _fold);

    final start = Offset(c.dx - side * 0.16, c.dy + side * 0.08);
    final end = Offset(c.dx + side * 0.16, c.dy - side * 0.08);
    final mid = Offset(c.dx + side * 0.02, c.dy - side * 0.12);
    final route = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);
    canvas.drawPath(
      route,
      Paint()
        ..shader = LinearGradient(
          colors: const [_teal, _ring],
        ).createShader(Rect.fromPoints(start, end))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );

    _pin(canvas, start, _teal);
    _pin(canvas, end, _ring);
  }

  void _pin(Canvas canvas, Offset tip, Color color) {
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..quadraticBezierTo(tip.dx - 4.2, tip.dy - 7.2, tip.dx, tip.dy - 10.2)
      ..quadraticBezierTo(tip.dx + 4.2, tip.dy - 7.2, tip.dx, tip.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawCircle(
      Offset(tip.dx, tip.dy - 7.1),
      1.35,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
