import 'package:flutter/material.dart';

import 'moroccan_zellij_cream_background.dart';

/// Fond écrans **auth** (inscription / connexion) — aligné sur le **zellij crème** global.
class CinematicMoroccanBackground extends StatelessWidget {
  const CinematicMoroccanBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MoroccanZellijCreamBackground(child: child);
  }
}
