import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_colors.dart';

/// Titre avec remplissage en dégradé (ShaderMask) — style « chrome » maghrébin.
class AlAselGradientTitle extends StatelessWidget {
  const AlAselGradientTitle(
    this.text, {
    super.key,
    this.fontSize = 26,
    this.fontWeight = FontWeight.w800,
    this.textAlign,
    this.maxLines,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => AppGradients.titleChrome.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        style: GoogleFonts.elMessiri(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: AppColors.white,
          height: 1.15,
        ),
      ),
    );
  }
}

/// Variante sur fond clair : dégradé bleu → terre
class AlAselGradientTitleOnLight extends StatelessWidget {
  const AlAselGradientTitleOnLight(
    this.text, {
    super.key,
    this.fontSize = 22,
    this.fontWeight = FontWeight.w800,
    this.textAlign,
  });

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign? textAlign;

  static const _g = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF152B45),
      Color(0xFF2A6B6F),
      Color(0xFFB85C2E),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => _g.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        textAlign: textAlign,
        style: GoogleFonts.elMessiri(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: AppColors.white,
          height: 1.2,
        ),
      ),
    );
  }
}
