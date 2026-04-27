import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_gradients.dart';

/// Fond **zellij crème** (hexagones + khatam) — shell app, auth, splash.
class MoroccanZellijCreamBackground extends StatelessWidget {
  const MoroccanZellijCreamBackground({super.key, required this.child});

  final Widget child;

  static const Color creamBase = Color(0xFFF5E6D3);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: creamBase),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppGradients.splashCreamBackdrop,
          ),
        ),
        Positioned.fill(
          child: CustomPaint(painter: MoroccanZellijCreamFieldPainter()),
        ),
        child,
      ],
    );
  }
}

/// Pavage hexagonal + étoile khatam (8 branches), tons crème / sable doré.
class MoroccanZellijCreamFieldPainter extends CustomPainter {
  static const Color _strand = Color(0xFFC4B896);
  static const Color _strandDeep = Color(0xFFB8A078);
  static const Color _underCream = Color(0xFFF5E6D3);

  @override
  void paint(Canvas canvas, Size size) {
    const a = 30.5;
    // ignore: prefer_const_declarations
    final dx = math.sqrt(3) * a;
    // ignore: prefer_const_declarations
    final dy = 1.5 * a;

    final pWeaveUnder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.15
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _underCream.withValues(alpha: 0.95);

    final pHex = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.02
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _strand.withValues(alpha: 0.26);

    final pStar = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _strandDeep.withValues(alpha: 0.28);

    canvas.saveLayer(Offset.zero & size, Paint());

    var j = 0;
    for (var y = -dy; y < size.height + dy * 2; y += dy, j++) {
      final ox = (j % 2) * (dx / 2);
      for (var x = -dx + ox; x < size.width + dx * 2; x += dx) {
        final c = Offset(x, y);
        _pointyTopHex(canvas, c, a, pWeaveUnder);
        _khatam(canvas, c, a * 0.9, a * 0.36, pWeaveUnder);
        _pointyTopHex(canvas, c, a, pHex);
        _khatam(canvas, c, a * 0.9, a * 0.36, pStar);
      }
    }

    final veil = Paint()
      ..blendMode = BlendMode.dstIn
      ..shader = const RadialGradient(
        center: Alignment(0.9, -0.85),
        radius: 1.38,
        colors: [
          Colors.white,
          Color(0xDDFFFFFF),
          Colors.transparent,
        ],
        stops: [0.0, 0.42, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, veil);

    canvas.restore();
  }

  void _pointyTopHex(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (int k = 0; k < 6; k++) {
      final ang = -math.pi / 2 + k * math.pi / 3;
      final p = Offset(c.dx + r * math.cos(ang), c.dy + r * math.sin(ang));
      if (k == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _khatam(Canvas canvas, Offset c, double outer, double inner, Paint paint) {
    final path = Path();
    for (int i = 0; i < 16; i++) {
      final ang = (i * math.pi / 8) - math.pi / 2;
      final rad = i.isEven ? outer : inner;
      final p = Offset(c.dx + rad * math.cos(ang), c.dy + rad * math.sin(ang));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
