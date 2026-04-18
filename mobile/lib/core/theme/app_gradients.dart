import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Dégradés et ombres « glow » — palette logo (bleu nuit, terre cuite, or, zellige).
abstract class AppGradients {
  AppGradients._();

  /// Fond d’écran — chaleur tadelakt + profondeur
  static const LinearGradient screenBackdrop = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFDF8F3),
      Color(0xFFF0E6D8),
      Color(0xFFE8DFD4),
    ],
    stops: [0.0, 0.45, 1.0],
  );

  /// Header large (Sliver flexible) — passage nuit médina → chaleur
  static const LinearGradient headerHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF152B45),
      Color(0xFF1C3D5A),
      Color(0xFF2A4A63),
      Color(0xFF8B4518),
    ],
    stops: [0.0, 0.35, 0.65, 1.0],
  );

  /// Variante plus « or zellige »
  static const LinearGradient headerWarm = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF152B45),
      Color(0xFF1E4A5C),
      Color(0xFFB85C2E),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  /// Carte — parchemin vers blanc (évite aplats)
  static const LinearGradient cardBody = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFBF7),
      Color(0xFFFDF8F3),
      Color(0xFFF5EDE4),
    ],
  );

  /// Titre — métal / or → terre (ShaderMask)
  static const LinearGradient titleChrome = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8D48A),
      Color(0xFFC9A227),
      Color(0xFFF6EFE6),
      Color(0xFFD4784A),
    ],
    stops: [0.0, 0.35, 0.55, 1.0],
  );

  /// Accent bouton / chip
  static const LinearGradient ctaFill = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF152B45), Color(0xFF1C3D5A)],
  );

  /// Ombres colorées (glow) — pas de noir
  static List<BoxShadow> glowDeepBlue({double blur = 28, double y = 14}) => [
        BoxShadow(
          color: AppColors.deepBlue.withValues(alpha: 0.22),
          blurRadius: blur,
          spreadRadius: -2,
          offset: Offset(0, y),
        ),
        BoxShadow(
          color: AppColors.gold.withValues(alpha: 0.18),
          blurRadius: blur * 1.2,
          spreadRadius: -4,
          offset: Offset(0, y + 4),
        ),
      ];

  static List<BoxShadow> glowTerracotta({double blur = 24, double y = 12}) => [
        BoxShadow(
          color: AppColors.terracotta.withValues(alpha: 0.28),
          blurRadius: blur,
          spreadRadius: -2,
          offset: Offset(0, y),
        ),
        BoxShadow(
          color: AppColors.gold.withValues(alpha: 0.14),
          blurRadius: blur * 1.1,
          offset: Offset(0, y + 6),
        ),
      ];

  static List<BoxShadow> glowGold({double blur = 20, double y = 10}) => [
        BoxShadow(
          color: AppColors.gold.withValues(alpha: 0.32),
          blurRadius: blur,
          spreadRadius: -3,
          offset: Offset(0, y),
        ),
      ];
}
