import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Gradients AL ASEL — boutons, vitrines, texte métal-or.
abstract class AppGradients {
  static const LinearGradient cinematicBackdrop = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A1628),
      Color(0xFF152B45),
      Color(0xFFE8DDD4),
      Color(0xFF1A3050),
    ],
    stops: [0.0, 0.35, 0.72, 1.0],
  );

  static const LinearGradient vignetteTop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x660F2840),
      Colors.transparent,
    ],
    stops: [0.0, 0.45],
  );

  static const LinearGradient vignetteBottom = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0x558B2942),
      Colors.transparent,
    ],
    stops: [0.0, 0.5],
  );

  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E4A6E),
      AppColors.deepBlue,
      Color(0xFF0A1F35),
    ],
  );

  static const LinearGradient goldShimmer = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.goldDark,
      AppColors.gold,
      Color(0xFFFFF8E7),
      AppColors.gold,
      AppColors.goldDark,
    ],
    stops: [0.0, 0.35, 0.5, 0.65, 1.0],
  );

  static const LinearGradient titleArabic = LinearGradient(
    colors: [
      AppColors.deepBlue,
      AppColors.zellijGlaze,
      AppColors.deepBlue,
    ],
  );

  /// Fond principal de l’app (onglets + flux) : parchemin chaud + coins bleu nuit / grenat très légers.
  static const LinearGradient shellMedinaBackdrop = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFDF8F3),
      Color(0xFFF4EBE2),
      Color(0xFFE9DDD4),
      Color(0xFFF1E8DE),
    ],
    stops: [0.0, 0.32, 0.68, 1.0],
  );

  static const LinearGradient shellTopVeil = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x220F2840),
      Colors.transparent,
    ],
    stops: [0.0, 0.42],
  );

  static const LinearGradient shellBottomVeil = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0x188B2942),
      Colors.transparent,
    ],
    stops: [0.0, 0.38],
  );
}
