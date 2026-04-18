import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import 'moroccan_card.dart';
import 'moroccan_ui_kit.dart';

/// Bandeau héros (dégradé médina) pour écrans internes — à placer en [SliverToBoxAdapter].
class MoroccanDashboardHeroSliver extends StatelessWidget {
  const MoroccanDashboardHeroSliver({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox_rounded,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.deepBlue,
                const Color(0xFF1A3F5C),
                AppColors.zellijGlaze.withValues(alpha: 0.92),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepBlue.withValues(alpha: 0.28),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -24,
                bottom: -16,
                child: Icon(Icons.hexagon_outlined, size: 100, color: Colors.white.withValues(alpha: 0.06)),
              ),
              Positioned(
                right: -12,
                top: -8,
                child: Icon(Icons.diamond_outlined, size: 72, color: AppColors.gold.withValues(alpha: 0.12)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.14),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.55)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.2),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.elMessiri(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              height: 1.45,
                              color: Colors.white.withValues(alpha: 0.92),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: ZerbiyaMotifStrip(width: w * 0.42, height: 4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bandeau compact sous une AppBar (fil client).
class MoroccanFeedWelcomeStrip extends StatelessWidget {
  const MoroccanFeedWelcomeStrip({super.key, required this.line});

  final String line;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.white.withValues(alpha: 0.95),
              AppColors.parchment.withValues(alpha: 0.98),
            ],
          ),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepBlue.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.zellijGlaze.withValues(alpha: 0.9)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                line,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepBlue.withValues(alpha: 0.92),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Conteneur pour la rangée de filtres (chips).
class MoroccanChipsPanel extends StatelessWidget {
  const MoroccanChipsPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepBlue.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          height: 44,
          child: child,
        ),
      ),
    );
  }
}

/// État vide illustré (liste demandes, etc.).
class MoroccanEmptyState extends StatelessWidget {
  const MoroccanEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: MoroccanCard(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.18),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
                ),
                child: Icon(icon, size: 40, color: AppColors.deepBlue.withValues(alpha: 0.85)),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.elMessiri(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepBlue,
                  height: 1.3,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    color: AppColors.muted,
                    height: 1.45,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
