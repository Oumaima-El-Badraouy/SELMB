import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Icône sur fond « verre » léger (glassmorphism) pour cartes à dégradé.
class GlassIconCircle extends StatelessWidget {
  const GlassIconCircle({
    super.key,
    required this.icon,
    this.size = 44,
    this.iconSize = 22,
  });

  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white.withValues(alpha: 0.22),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: iconSize, color: AppColors.white.withValues(alpha: 0.95)),
    );
  }
}
