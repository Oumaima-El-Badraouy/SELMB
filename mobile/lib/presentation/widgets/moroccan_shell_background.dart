import 'package:flutter/material.dart';

import 'moroccan_zellij_cream_background.dart';

/// Fond global de l’app : **zellij crème** (identique au splash).
class MoroccanShellBackground extends StatelessWidget {
  const MoroccanShellBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MoroccanZellijCreamBackground(child: child);
  }
}
