import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';

/// Cadre inspiré d’une porte de **قصبة مديونة** : arc outrepassé, filets or / terre cuite.
class MediounaKasbahFrame extends StatelessWidget {
  const MediounaKasbahFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _KasbahDoorPainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(11, 20, 11, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.mediounaKasbahCaption,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.goldMuted.withValues(alpha: 0.95),
                height: 1.1,
                shadows: [
                  Shadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 8, offset: const Offset(0, 1)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.gold.withValues(alpha: 0.9),
                    Color(0xFFD4A574),
                    AppColors.zerbiyaIndigo.withValues(alpha: 0.88),
                    AppColors.deepBlue.withValues(alpha: 0.92),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.35),
                    blurRadius: 22,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.97),
                    borderRadius: BorderRadius.circular(19.5),
                    border: Border.all(color: AppColors.deepBlue.withValues(alpha: 0.12)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KasbahDoorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cx = w / 2;
    const archLift = 14.0;
    const sideInset = 6.0;

    final gold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = AppColors.gold.withValues(alpha: 0.55);

    // Arc outrepassé (Moorish) au-dessus du bloc — courbe symétrique
    final archPath = Path();
    const yBase = 10.0;
    archPath.moveTo(sideInset, yBase + 8);
    archPath.cubicTo(
      sideInset,
      yBase - archLift * 0.2,
      cx - w * 0.22,
      yBase - archLift,
      cx,
      yBase - archLift,
    );
    archPath.cubicTo(
      cx + w * 0.22,
      yBase - archLift,
      w - sideInset,
      yBase - archLift * 0.2,
      w - sideInset,
      yBase + 8,
    );
    canvas.drawPath(archPath, gold);
    final terracottaThin = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = AppColors.terracottaLight.withValues(alpha: 0.5);
    canvas.drawPath(archPath, terracottaThin);

    // Claveaux / losanges légers sur l’arc
    const n = 5;
    for (var i = 0; i < n; i++) {
      final t = (i + 0.5) / n;
      final ax = sideInset + (w - 2 * sideInset) * t;
      final ay = yBase + 2 - archLift * math.sin(math.pi * t);
      const rDot = 2.2;
      canvas.drawCircle(Offset(ax, ay), rDot, Paint()..color = AppColors.gold.withValues(alpha: 0.35));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
