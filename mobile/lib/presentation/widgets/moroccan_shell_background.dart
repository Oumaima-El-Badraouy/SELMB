import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import 'moroccan_pattern_background.dart';

/// Fond **médina** pour toute l’app : dégradé parchemin + motif zellige / زربية + voiles discrets.
class MoroccanShellBackground extends StatelessWidget {
  const MoroccanShellBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.shellMedinaBackdrop)),
        Positioned.fill(
          child: Opacity(
            opacity: 0.48,
            child: MoroccanPatternBackground(
              child: const SizedBox.expand(),
            ),
          ),
        ),
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.shellTopVeil))),
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.shellBottomVeil))),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.35),
                radius: 1.15,
                colors: [
                  AppColors.gold.withValues(alpha: 0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
