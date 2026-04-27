import 'package:flutter/material.dart';

/// Palette AL ASEL — **zellige** (Fès, émail, étoiles) + **زربية** (laine, grenat, indigo, safran).
abstract class AppColors {
  /// Bleu nuit Fès / portes de médina
  static const Color deepBlue = Color(0xFF0F2840);
  static const Color deepBlueLight = Color(0xFF1A3A56);

  /// Terre cuite — chaleur méditerranéenne / Marrakech
  static const Color terracotta = Color(0xFFB85C2E);
  static const Color terracottaLight = Color(0xFFD4784A);

  /// Laine زربية / base écrans (alias **sand** pour le code existant)
  static const Color zerbiyaWool = Color(0xFFF3EBE0);
  static const Color sand = zerbiyaWool;
  static const Color sandDeep = Color(0xFFE4D9CC);
  static const Color parchment = Color(0xFFFDF8F3);

  /// Or zellige / laiton (fort contraste sur bleu nuit)
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldDark = Color(0xFFB8941E);
  static const Color goldMuted = Color(0xFFE8D18A);

  /// Vert émail zellige (Fès)
  static const Color zellijGlaze = Color(0xFF2A6B6F);
  static const Color zellijMint = Color(0xFF3D8A8E);

  /// Prune–ardoise (accent tapis / bordures — **pas** de rouge vif).
  static const Color burgundy = Color(0xFF4A3F55);

  /// **زربية** — slot « grenat » en UI : teinte **indigo–ardoise** (chaleur sans rouge).
  static const Color zerbiyaGarnet = Color(0xFF3D4F62);
  static const Color zerbiyaIndigo = Color(0xFF2C3E6E);
  static const Color zerbiyaSaffron = Color(0xFFC17F3A);

  static const Color ink = Color(0xFF1A1F2A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF6B6570);

  /// Dégradé fond (laine → sable) avec soupçon de chaleur **zerbiya** en bas.
  static const List<Color> sandGradient = [
    Color(0xFFFBF7F0),
    Color(0xFFF0E6DA),
    Color(0xFFE9DDD4),
  ];

  /// Variante plus marquée pour splash / auth (grenat très léger en coin).
  static const List<Color> zellijZerbiyaGradient = [
    Color(0xFFFCF8F3),
    Color(0xFFF2E8DC),
    Color(0xFFE5D8CE),
  ];

  /// Accent pour indicateurs / succès
  static const Color oasis = Color(0xFF2D6A4F);

  /// Tons drapeau / paysage — utilisés avec parcimonie (UI, pas « drapeau à l’écran »).
  /// Vert palmier adouci (accents, focus, liens positifs).
  static const Color moroccoGreen = Color(0xFF1F6F54);
  static const Color moroccoGreenMuted = Color(0xFF3D8F72);
  /// Erreurs / alertes : **terre brûlée** lisible, sans rouge primaire agressif.
  static const Color moroccoRed = Color(0xFF8B5E4D);
  static const Color moroccoRedSoft = Color(0xFFE8D8D2);
  /// Gris ardoise médina (texte secondaire sur fond clair).
  static const Color moroccoSlate = Color(0xFF5A6168);
  static const Color moroccoSlateLight = Color(0xFF8E959D);

  /// AppBar / bandeaux sur le fond shell (motif zellige + parchemin).
  static const Color shellAppBarSurface = Color(0xE8FDF8F3);
}
