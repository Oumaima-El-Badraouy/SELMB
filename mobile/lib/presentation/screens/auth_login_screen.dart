import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/auth/auth_notifier.dart';
import '../../core/l10n/strings.dart';
import '../../core/network/dio_error_message.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/form_spacing.dart';
import '../widgets/cinematic_moroccan_background.dart';
import '../widgets/gradient_primary_button.dart';
import '../widgets/moroccan_card.dart';
import '../widgets/moroccan_ui_kit.dart';

class AuthLoginScreen extends ConsumerStatefulWidget {
  const AuthLoginScreen({super.key});

  @override
  ConsumerState<AuthLoginScreen> createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends ConsumerState<AuthLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool loading = false;
  String? err;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRemembered();
  }

  Future<void> _loadRemembered() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    if (p.getBool('al_asel_remember_login') == true) {
      setState(() {
        _rememberMe = true;
        _email.text = p.getString('al_asel_saved_email') ?? '';
        _password.text = p.getString('al_asel_saved_password') ?? '';
      });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (loading) return;
    setState(() {
      loading = true;
      err = null;
    });
    try {
      await ref.read(authNotifierProvider.notifier).login(
            _email.text.trim(),
            _password.text,
            rememberMe: _rememberMe,
          );
      final u = ref.read(authNotifierProvider).user;
      if (!mounted) return;
      if (u?.role == 'client') {
        context.go('/client');
      } else if (u?.role == 'artisan') {
        context.go('/artisan');
      }
    } catch (e) {
      setState(() => err = friendlyDioError(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (b) => AppGradients.titleArabic.createShader(Offset.zero & b.size),
          child: Text(
            S.loginTitle,
            style: GoogleFonts.elMessiri(fontWeight: FontWeight.w800, fontSize: 21, color: Colors.white),
          ),
        ),
      ),
      body: CinematicMoroccanBackground(
        child: SafeArea(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, t, child) {
              return Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, 28 * (1 - t)),
                  child: child,
                ),
              );
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Hero(
                      tag: 'al_asel_logo',
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.35),
                              blurRadius: 20,
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: AppColors.zellijGlaze.withValues(alpha: 0.2),
                              blurRadius: 14,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Container(
                            color: AppColors.white.withValues(alpha: 0.92),
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              'assets/branding/logo_al_asel.png',
                              height: 92,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => SvgPicture.asset(
                                'assets/branding/logo.svg',
                                height: 92,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(child: MoroccanGoldBand(width: 110)),
                  const SizedBox(height: 18),
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (b) => AppGradients.titleArabic.createShader(Offset.zero & b.size),
                    child: Text(
                      S.welcomeLogin,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.elMessiri(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 14.5,
                      color: AppColors.white.withValues(alpha: 0.88),
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 22),
                  MoroccanCard(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.cairo(),
                          decoration: const InputDecoration(
                            labelText: S.emailLabel,
                            prefixIcon: Icon(Icons.mail_outline_rounded, color: AppColors.deepBlue),
                          ),
                        ),
                        FormSpacing.betweenInputs,
                        TextField(
                          controller: _password,
                          obscureText: true,
                          style: GoogleFonts.cairo(),
                          decoration: const InputDecoration(
                            labelText: S.passwordLabel,
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.deepBlue),
                          ),
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _rememberMe,
                          onChanged: loading ? null : (v) => setState(() => _rememberMe = v ?? false),
                          title: Text(S.rememberLogin, style: GoogleFonts.cairo(fontSize: 14)),
                          activeColor: AppColors.deepBlue,
                          checkColor: AppColors.white,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        if (err != null) ...[
                          const SizedBox(height: 12),
                          Text(err!, style: GoogleFonts.cairo(color: AppColors.terracotta, fontWeight: FontWeight.w700)),
                        ],
                        const SizedBox(height: 20),
                        GradientPrimaryButton(
                          onPressed: _submit,
                          loading: loading,
                          label: S.loginButton,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.push('/auth/register/client'),
                    child: Text(
                      S.registerClient,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.goldMuted),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/auth/register/artisan'),
                    child: Text(
                      S.registerArtisan,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.goldMuted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
