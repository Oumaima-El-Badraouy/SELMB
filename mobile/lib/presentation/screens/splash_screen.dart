import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/auth/auth_notifier.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/islamic_splash_background.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  bool _scheduled = false;
  late AnimationController _c;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();
    // Animation plus lente : le logo reste lisible (fondu + échelle).
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3400));
    _logoScale = Tween<double>(begin: 0.22, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: const Interval(0, 0.55, curve: Curves.easeOutCubic)),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: const Interval(0, 0.48, curve: Curves.easeOut)),
    );
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _navigateAfterSplash() async {
    final prefs = await SharedPreferences.getInstance();
    final longDone = prefs.getBool('splash_long_shown') ?? false;
    // Première visite : laisser le temps d’apprécier le logo + fin d’animation.
    final ms = longDone ? 1600 : 4600;
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
      body: IslamicSplashBackground(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            return Center(
              child: Transform.scale(
                scale: _logoScale.value,
                child: Opacity(
                  opacity: _logoOpacity.value,
                  child: Hero(
                    tag: 'al_asel_logo',
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.65),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B7355).withValues(alpha: 0.14),
                            blurRadius: 42,
                            spreadRadius: 0,
                            offset: const Offset(0, 16),
                          ),
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.22),
                            blurRadius: 24,
                            spreadRadius: -4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Container(
                          color: AppColors.white,
                          padding: const EdgeInsets.all(14),
                          child: Image.asset(
                            'assets/branding/logo_al_asel.png',
                            width: 260,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => SvgPicture.asset(
                              'assets/branding/logo.svg',
                              width: 130,
                              height: 130,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
