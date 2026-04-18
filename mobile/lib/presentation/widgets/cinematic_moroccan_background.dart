import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import 'moroccan_pattern_background.dart';

/// Fond **cinéma** : nuit médina + zellige voilé + vignettes.
class CinematicMoroccanBackground extends StatelessWidget {
  const CinematicMoroccanBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.cinematicBackdrop)),
        Positioned.fill(
          child: Opacity(
            opacity: 0.72,
            child: MoroccanPatternBackground(
              child: const SizedBox.expand(),
            ),
          ),
        ),
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.vignetteTop))),
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.vignetteBottom))),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.25),
                radius: 0.95,
                colors: [
                  AppColors.gold.withValues(alpha: 0.07),
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
