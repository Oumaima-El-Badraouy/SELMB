import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Grille d’octogones — rappelle les carreaux centraux du zellige (Fès / Meknès).
class ZellijOctagonGridPainter extends CustomPainter {
  const ZellijOctagonGridPainter({this.opacity = 1.0});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final blue = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.55
      ..color = AppColors.deepBlue.withValues(alpha: 0.065 * opacity);

    final glaze = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = AppColors.zellijGlaze.withValues(alpha: 0.085 * opacity);

    const g = 54.0;
    var row = 0;
    for (double y = -g; y < size.height + g; y += g) {
      var col = 0;
      for (double x = -g; x < size.width + g; x += g) {
        _octagon(canvas, Offset(x + g / 2, y + g / 2), g * 0.36, (row + col) % 3 == 0 ? blue : glaze);
        col++;
      }
      row++;
    }
  }

  void _octagon(Canvas canvas, Offset c, double r, Paint paint) {
    const n = 8;
    final path = Path();
    for (int i = 0; i < n; i++) {
      final ang = (i * math.pi * 2 / n) - math.pi / 8;
      final p = Offset(c.dx + r * math.cos(ang), c.dy + r * math.sin(ang));
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
  bool shouldRepaint(covariant ZellijOctagonGridPainter oldDelegate) => oldDelegate.opacity != opacity;
}

/// Bandes horizontales + « dents de kilim » — texture tapis berbère très subtile.
class RugKilimBandsPainter extends CustomPainter {
  const RugKilimBandsPainter({this.opacity = 1.0});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final band = Paint()..style = PaintingStyle.fill;

    const period = 112.0;
    var y = 0.0;
    var i = 0;
    while (y < size.height + period) {
      final h = 5.0 + (i % 3) * 2.5;
      band.color = i.isEven
          ? AppColors.terracotta.withValues(alpha: 0.045 * opacity)
          : AppColors.burgundy.withValues(alpha: 0.035 * opacity);
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, h), band);
      _zigzag(canvas, size.width, y + h, AppColors.gold.withValues(alpha: 0.08 * opacity));
      y += h + 14;
      i++;
    }
  }

  void _zigzag(Canvas canvas, double w, double y, Color color) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.55
      ..color = color;
    const step = 14.0;
    final path = Path()..moveTo(0, y);
    var up = true;
    for (double x = 0; x <= w; x += step) {
      path.lineTo(x, y + (up ? -3.0 : 3.0));
      up = !up;
    }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant RugKilimBandsPainter oldDelegate) => oldDelegate.opacity != opacity;
}

/// Rosace centrale type médina — pour splash / héros (très basse opacité).
class ZellijSplashRosettePainter extends CustomPainter {
  const ZellijSplashRosettePainter({this.centerBiasY = 0.38});

  /// 0 = haut, 1 = bas — position verticale du centre de la rosace.
  final double centerBiasY;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * centerBiasY);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = AppColors.deepBlue.withValues(alpha: 0.06);

    final gold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85
      ..color = AppColors.gold.withValues(alpha: 0.09);

    _star16(canvas, c, size.shortestSide * 0.42, p);
    _star16(canvas, c, size.shortestSide * 0.28, gold);
    _star8(canvas, c, size.shortestSide * 0.18, AppColors.zellijGlaze.withValues(alpha: 0.08));

    // Losanges sur le pourtour (écho zellige)
    const n = 12;
    final r = size.shortestSide * 0.34;
    for (int i = 0; i < n; i++) {
      final a = i * math.pi * 2 / n;
      final o = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      canvas.save();
      canvas.translate(o.dx, o.dy);
      canvas.rotate(a + math.pi / 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 16, height: 16),
          const Radius.circular(2),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6
          ..color = AppColors.terracotta.withValues(alpha: 0.07),
      );
      canvas.restore();
    }
  }

  void _star16(Canvas canvas, Offset c, double radius, Paint paint) {
    const points = 16;
    final path = Path();
    for (int i = 0; i < points; i++) {
      final ang = (i * math.pi * 2 / points) - math.pi / 2;
      final p = Offset(c.dx + radius * math.cos(ang), c.dy + radius * math.sin(ang));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _star8(Canvas canvas, Offset c, double radius, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = color;
    const points = 8;
    final path = Path();
    for (int i = 0; i < points; i++) {
      final ang = (i * math.pi * 2 / points) - math.pi / 2;
      final p = Offset(c.dx + radius * math.cos(ang), c.dy + radius * math.sin(ang));
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
  bool shouldRepaint(covariant ZellijSplashRosettePainter oldDelegate) =>
      oldDelegate.centerBiasY != centerBiasY;
}
