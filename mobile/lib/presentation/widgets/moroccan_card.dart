import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

/// Carte design system : dégradé léger, coins décoratifs *clippés*, ombre colorée (glow), grand rayon.
class MoroccanCard extends StatelessWidget {
  const MoroccanCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  static const double _r = 28;

  @override
  Widget build(BuildContext context) {
    final inner = ClipRRect(
      borderRadius: BorderRadius.circular(_r),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.cardBody),
            ),
          ),
          // Lisière type kilim / bordure tapis
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(_r)),
                gradient: LinearGradient(
                  colors: [
                    AppColors.burgundy.withValues(alpha: 0.65),
                    AppColors.gold,
                    AppColors.zellijGlaze,
                    AppColors.terracotta.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
          ),
          // Bulles décoratives dans les coins (clipées par le parent)
          Positioned(
            top: -24,
            right: -20,
            child: _blob(72, AppColors.gold.withValues(alpha: 0.14)),
          ),
          Positioned(
            bottom: -18,
            left: -14,
            child: _blob(56, AppColors.terracotta.withValues(alpha: 0.12)),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: CustomPaint(
              size: const Size(40, 40),
              painter: _ZellijSparkPainter(),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: CustomPaint(
              size: const Size(36, 36),
              painter: _ZellijSparkPainter(small: true),
            ),
          ),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );

    final decorated = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.45), width: 1.2),
        boxShadow: AppGradients.glowDeepBlue(blur: 26, y: 12),
      ),
      child: inner,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: onTap == null
          ? decorated
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(_r),
                splashColor: AppColors.gold.withValues(alpha: 0.12),
                highlightColor: AppColors.deepBlue.withValues(alpha: 0.04),
                child: decorated,
              ),
            ),
    );
  }

  static Widget _blob(double d, Color color) {
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _ZellijSparkPainter extends CustomPainter {
  _ZellijSparkPainter({this.small = false});

  final bool small;

  @override
  void paint(Canvas canvas, Size size) {
    final r = small ? 6.0 : 8.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = small ? 0.9 : 1.1
      ..color = AppColors.deepBlue.withValues(alpha: 0.22);

    final gold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = AppColors.gold.withValues(alpha: 0.5);

    void star(Offset c) {
      _drawStar(canvas, c, r, paint);
      _drawStar(canvas, c, r * 0.45, gold);
    }

    star(Offset(size.width * 0.35, size.height * 0.35));
    star(Offset(size.width * 0.72, size.height * 0.68));
  }

  void _drawStar(Canvas canvas, Offset c, double radius, Paint paint) {
    const n = 8;
    final path = Path();
    for (int i = 0; i < n; i++) {
      final a = (i * math.pi * 2 / n) - math.pi / 2;
      final p = Offset(c.dx + radius * math.cos(a), c.dy + radius * math.sin(a));
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
