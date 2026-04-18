import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/auth/auth_notifier.dart';
import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/ds/cultural_motifs_painter.dart';
import '../widgets/ds/gradient_title.dart';
import '../widgets/moroccan_pattern_background.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _scheduled = false;

  /// Même instance de tween sur tous les rebuilds — évite de relancer l’animation à chaque [ref.watch].
  final Tween<double> _entranceTween = Tween<double>(begin: 0.0, end: 1.0);

  Future<void> _navigateAfterSplash() async {
    final prefs = await SharedPreferences.getInstance();
    final longDone = prefs.getBool('splash_long_shown') ?? false;
    final ms = longDone ? 900 : 1600;
    await Future.delayed(Duration(milliseconds: ms));
    if (!longDone) await prefs.setBool('splash_long_shown', true);
    if (!mounted) return;
    final a = ref.read(authNotifierProvider);
    if (!a.isAuthenticated) {
      context.go('/auth/login');
    } else if (a.user?.role == 'client') {
      context.go('/client');
    } else {
      context.go('/artisan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);

    if (auth.ready && !_scheduled) {
      _scheduled = true;
      _navigateAfterSplash();
    }

    return Scaffold(
      body: MoroccanPatternBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(
              child: CustomPaint(
                painter: ZellijSplashRosettePainter(centerBiasY: 0.36),
              ),
            ),
            Center(
              child: TweenAnimationBuilder<double>(
                key: const ValueKey<String>('splash_entrance'),
                tween: _entranceTween,
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (context, t, child) {
                  return Opacity(
                    opacity: t,
                    child: Transform.scale(
                      scale: 0.86 + 0.14 * t,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepBlue.withValues(alpha: 0.18),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.32),
                            blurRadius: 36,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.white.withValues(alpha: 0.95),
                                AppColors.parchment.withValues(alpha: 0.88),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Hero(
                            tag: 'al_asel_logo',
                            child: Image.asset(
                              'assets/branding/logo_al_asel.png',
                              width: 260,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => SvgPicture.asset(
                                'assets/branding/logo.svg',
                                width: 140,
                                height: 140,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const AlAselGradientTitleOnLight(
                      S.appName,
                      fontSize: 34,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: AppColors.sandDeep.withValues(alpha: 0.6),
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
