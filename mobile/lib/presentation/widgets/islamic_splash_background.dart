import 'package:flutter/material.dart';

import 'moroccan_zellij_cream_background.dart';

/// Fond splash — même **zellij crème** que le reste de l’app.
class IslamicSplashBackground extends StatelessWidget {
  const IslamicSplashBackground({super.key, required this.child});

  final Widget child;

  static const Color splashCreamBase = MoroccanZellijCreamBackground.creamBase;

  @override
  Widget build(BuildContext context) {
    return MoroccanZellijCreamBackground(child: child);
  }
}
