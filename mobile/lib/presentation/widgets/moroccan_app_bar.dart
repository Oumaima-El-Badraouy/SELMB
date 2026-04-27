import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

/// AppBar avec dégradé maghrébin + bandeau zellij sous le titre.
class MoroccanAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MoroccanAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
  });

  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          elevation: 0,
          scrolledUnderElevation: 0.5,
          shadowColor: AppColors.deepBlue.withValues(alpha: 0.08),
          backgroundColor: AppColors.shellAppBarSurface,
          surfaceTintColor: Colors.transparent,
          foregroundColor: AppColors.deepBlue,
          leading: leading,
          title: title,
          actions: actions,
        ),
        SizedBox(
          height: 10,
          width: double.infinity,
          child: CustomPaint(
            painter: _ZellijBandPainter(),
          ),
        ),
      ],
    );
  }
}

class _ZellijBandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.parchment.withValues(alpha: 0.35);

    final g = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = AppColors.gold.withValues(alpha: 0.45);

    const step = 24.0;
    for (double x = 0; x < size.width + step; x += step) {
      _star(canvas, Offset(x, mid), 5, p);
      _star(canvas, Offset(x + step / 2, mid), 3, g);
    }
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    const n = 8;
    final path = Path();
    for (int i = 0; i < n; i++) {
      final a = (i * math.pi * 2 / n) - math.pi / 2;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
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

/// AppBar simple — dégradé pleine largeur (écrans formulaires / listes).
class AlAselFlatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AlAselFlatAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.centerTitle = false,
  }) : assert(title != null || titleWidget != null, 'Provide title or titleWidget');

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final t = titleWidget ??
        Text(
          title!,
          style: GoogleFonts.elMessiri(
            fontWeight: FontWeight.w700,
            fontSize: 19,
            color: AppColors.parchment,
          ),
        );

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: leading,
      centerTitle: centerTitle,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppGradients.headerWarm),
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.parchment,
      iconTheme: const IconThemeData(color: AppColors.parchment),
      title: DefaultTextStyle.merge(
        style: const TextStyle(color: AppColors.parchment),
        child: t,
      ),
      actions: actions,
    );
  }
}
