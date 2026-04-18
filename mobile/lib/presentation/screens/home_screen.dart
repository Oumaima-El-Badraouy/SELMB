import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/moroccan_card.dart';
import '../widgets/moroccan_shell_background.dart';
import '../widgets/moroccan_ui_kit.dart';

/// Accueil — vitrine **médina** : arche, zellige, CTAs comme portes de riad.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MoroccanShellBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Column(
                    children: [
                      Center(child: ZerbiyaMotifStrip(width: w * 0.5, height: 8)),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28),
                            bottom: Radius.circular(20),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.white.withValues(alpha: 0.94),
                              AppColors.parchment.withValues(alpha: 0.98),
                            ],
                          ),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.55), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.deepBlue.withValues(alpha: 0.12),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                            BoxShadow(
                              color: AppColors.zerbiyaGarnet.withValues(alpha: 0.06),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              S.homeDecorLine,
                              style: GoogleFonts.elMessiri(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.zellijGlaze,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              S.homeMainTitle,
                              style: GoogleFonts.elMessiri(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: AppColors.deepBlue,
                                height: 1.05,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              S.homeIntroSubtitle,
                              style: GoogleFonts.cairo(
                                fontSize: 14.5,
                                height: 1.55,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            const MoroccanGoldBand(width: 120),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _HeroCta(
                      title: S.homeCardExploreTitle,
                      subtitle: S.homeCardExploreSubtitle,
                      icon: Icons.explore_rounded,
                      accent: AppColors.zellijGlaze,
                      onTap: () => context.push('/explore'),
                    ),
                    const SizedBox(height: 14),
                    _HeroCta(
                      title: S.homeCardRequestTitle,
                      subtitle: S.homeCardRequestSubtitle,
                      icon: Icons.edit_calendar_rounded,
                      accent: AppColors.terracotta,
                      onTap: () => context.push('/request'),
                    ),
                    const SizedBox(height: 14),
                    _HeroCta(
                      title: S.homeCardArtisanTitle,
                      subtitle: S.homeCardArtisanSubtitle,
                      icon: Icons.architecture_rounded,
                      accent: AppColors.zerbiyaIndigo,
                      onTap: () => context.push('/artisan'),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCta extends StatelessWidget {
  const _HeroCta({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MoroccanCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: 0.88),
                  accent.withValues(alpha: 0.45),
                ],
              ),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.elMessiri(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepBlue,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.deepBlue.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }
}
