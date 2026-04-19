import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Carte « zellige » + *lift* / *scale* léger au press si [onTap] est défini.
class MoroccanCard extends StatefulWidget {
  const MoroccanCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  State<MoroccanCard> createState() => _MoroccanCardState();
}

class _MoroccanCardState extends State<MoroccanCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final inner = CustomPaint(
      foregroundPainter: _ZellijCornerPainter(),
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.62), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepBlue.withValues(alpha: _pressed ? 0.06 : 0.09),
              blurRadius: _pressed ? 14 : 22,
              offset: Offset(0, _pressed ? 4 : 10),
            ),
            BoxShadow(
              color: AppColors.zerbiyaGarnet.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppColors.terracotta.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: widget.child,
      ),
    );

    final scaled = AnimatedScale(
      scale: _pressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: inner,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: widget.onTap == null
          ? scaled
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(22),
                splashColor: AppColors.gold.withValues(alpha: 0.18),
                highlightColor: AppColors.moroccoGreen.withValues(alpha: 0.06),
                onHighlightChanged: (v) => setState(() => _pressed = v),
                child: scaled,
              ),
            ),
    );
  }
}

class _ZellijCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const r = 14.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..color = AppColors.deepBlue.withValues(alpha: 0.38);

    final gold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = AppColors.gold.withValues(alpha: 0.72);

    void star(Offset c) {
      _drawStar(canvas, c, r, paint);
      _drawStar(canvas, c, r * 0.45, gold);
    }

    const inset = r * 0.35;
    star(const Offset(inset, inset));
    star(Offset(size.width - inset, inset));
    star(Offset(inset, size.height - inset));
    star(Offset(size.width - inset, size.height - inset));
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
