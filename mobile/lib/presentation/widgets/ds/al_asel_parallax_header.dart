import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';

/// Espace flexible type SliverAppBar : dégradé + formes géométriques banches (rotation lente).
/// Utiliser dans [flexibleSpace] avec [expandedHeight] ~ 240–280.
class AlAselParallaxHeader extends StatefulWidget {
  const AlAselParallaxHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.bottomOverlap = 0,
  });

  final Widget title;
  final Widget? subtitle;
  /// Marge basse si un élément (search) est collé sous le header.
  final double bottomOverlap;

  @override
  State<AlAselParallaxHeader> createState() => _AlAselParallaxHeaderState();
}

class _AlAselParallaxHeaderState extends State<AlAselParallaxHeader> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 48))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final w = constraints.maxWidth;
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.headerHero),
            ),
            // Voile léger pour lisibilité du titre
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.12),
                  ],
                ),
              ),
            ),
            ..._cornerDecor(w, h),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + widget.bottomOverlap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    DefaultTextStyle(
                      style: const TextStyle(color: AppColors.white),
                      child: widget.title,
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 8),
                      DefaultTextStyle(
                        style: TextStyle(
                          color: AppColors.parchment.withValues(alpha: 0.92),
                          fontSize: 14,
                          height: 1.35,
                        ),
                        child: widget.subtitle!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _cornerDecor(double w, double h) {
    Widget blob(Alignment align, IconData icon, double size, double phase) {
      return Align(
        alignment: align,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            final t = _ctrl.value * 2 * math.pi + phase;
            return Transform.rotate(
              angle: t * 0.08,
              child: Opacity(
                opacity: 0.1,
                child: Icon(icon, size: size, color: AppColors.white),
              ),
            );
          },
        ),
      );
    }

    return [
      blob(Alignment.topLeft, Icons.hexagon_outlined, w * 0.42, 0),
      blob(Alignment.topRight, Icons.auto_awesome, w * 0.36, 1.2),
      blob(Alignment.bottomLeft, Icons.texture_rounded, w * 0.28, 2.1),
      blob(Alignment.bottomRight, Icons.star_border_rounded, w * 0.32, 0.7),
    ];
  }
}
