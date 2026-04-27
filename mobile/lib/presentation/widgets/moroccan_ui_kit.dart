import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'ds/gradient_title.dart';

/// Bandeau **زربية** : indigo — or — émail (bordure tapis, sans rouge).
class ZerbiyaMotifStrip extends StatelessWidget {
  const ZerbiyaMotifStrip({super.key, this.width = 200, this.height = 6});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: LinearGradient(
          colors: [
            AppColors.zerbiyaIndigo.withValues(alpha: 0.88),
            AppColors.gold,
            AppColors.zellijGlaze.withValues(alpha: 0.85),
            AppColors.gold,
            AppColors.zerbiyaIndigo.withValues(alpha: 0.88),
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

/// Filet horizontal type « bande zellige » or.
class MoroccanGoldBand extends StatelessWidget {
  const MoroccanGoldBand({super.key, this.width = 120});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0),
            AppColors.gold,
            AppColors.zellijMint.withValues(alpha: 0.75),
            AppColors.gold,
            AppColors.gold.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

/// Titre de section avec style El Messiri.
class MoroccanSectionTitle extends StatelessWidget {
  const MoroccanSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.gold.withValues(alpha: 0.35))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: AlAselGradientTitleOnLight(text, fontSize: 17, fontWeight: FontWeight.w800),
        ),
        Expanded(child: Divider(color: AppColors.gold.withValues(alpha: 0.35))),
      ],
    );
  }
}

/// AppBar des onglets (client / artisan) : parchemin + filet or sur fond médina.
class MoroccanTabAppBar {
  MoroccanTabAppBar._();

  static AppBar bar({
    required Widget title,
    List<Widget>? actions,
    bool automaticallyImplyLeading = true,
    bool centerTitle = true,
    PreferredSizeWidget? bottom,
  }) {
    return AppBar(
      title: title,
      actions: actions,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      bottom: bottom ??
          PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.2),
                    AppColors.gold.withValues(alpha: 0.55),
                    AppColors.gold.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          ),
      backgroundColor: AppColors.shellAppBarSurface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.deepBlue,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: AppColors.deepBlue.withValues(alpha: 0.08),
    );
  }
}
