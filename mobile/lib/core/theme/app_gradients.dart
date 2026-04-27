import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Gradients AL ASEL — boutons, vitrines, texte métal-or.
abstract class AppGradients {
  /// Fond **splash** (ref. visuel) : crème `#F5E6D3`, halo centre **porcelain**, bords **pêche dorée**.
  static const RadialGradient splashCreamBackdrop = RadialGradient(
    center: Alignment(0, -0.04),
    radius: 1.05,
    colors: [
      Color(0xFFFFFBF6),
      Color(0xFFFAF0E4),
      Color(0xFFF5E6D3),
      Color(0xFFF0E6DA),
      Color(0xFFEDE4DA),
    ],
    stops: [0.0, 0.28, 0.52, 0.82, 1.0],
  );

  /// Fond auth / splash : **nuit Fès** — encre, lapis, émail jade, brume lunaire (sans rouge).
  static const LinearGradient cinematicBackdrop = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF070F1C),
      Color(0xFF0F2840),
      Color(0xFF153D52),
      Color(0xFF256B6F),
      Color(0xFF1A3A56),
      Color(0xFF0A1524),
    ],
    stops: [0.0, 0.22, 0.44, 0.58, 0.78, 1.0],
  );

  static const LinearGradient vignetteTop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x441F6F54),
      Color(0x100F2840),
      Colors.transparent,
    ],
    stops: [0.0, 0.32, 0.58],
  );

  static const LinearGradient vignetteBottom = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0x382A6B6F),
      Color(0x121E4A6E),
      Colors.transparent,
    ],
    stops: [0.0, 0.28, 0.52],
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

  /// Titres lisibles sur fond sombre (évite masques trop sombres sur dégradé).
  static const LinearGradient titleOnDark = LinearGradient(
    colors: [
      Color(0xFFF5FBF8),
      AppColors.moroccoGreenMuted,
      Color(0xFFF2F4F6),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient titleArabic = LinearGradient(
    colors: [
      AppColors.deepBlue,
      AppColors.zellijGlaze,
      AppColors.deepBlue,
    ],
  );

  /// Fond onglets : **patio riad** — ivoire froid, brume jade, perle (sans beige lourd ni rouge).
  static const LinearGradient shellMedinaBackdrop = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF7F9FB),
      Color(0xFFEFF6F4),
      Color(0xFFF5F2EC),
      Color(0xFFE8EEF4),
    ],
    stops: [0.0, 0.34, 0.62, 1.0],
  );

  static const LinearGradient shellTopVeil = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x222A6B6F),
      Color(0x0C0F2840),
      Colors.transparent,
    ],
    stops: [0.0, 0.24, 0.5],
  );

  static const LinearGradient shellBottomVeil = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0x182A6B6F),
      Color(0x0A1E4A6E),
      Colors.transparent,
    ],
    stops: [0.0, 0.22, 0.45],
  );
}
