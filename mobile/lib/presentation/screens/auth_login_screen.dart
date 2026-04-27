import 'dart:math' as math;

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
import '../widgets/moroccan_zellij_cream_background.dart';
import '../widgets/moroccan_ui_kit.dart';

/// Connexion — **version classique** : AppBar titre, bienvenue, carte blanche sur fond zellij crème.
class AuthLoginScreen extends ConsumerStatefulWidget {
  const AuthLoginScreen({super.key});

  @override
  ConsumerState<AuthLoginScreen> createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends ConsumerState<AuthLoginScreen> with TickerProviderStateMixin {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool loading = false;
  String? err;
  bool _rememberMe = false;

  late AnimationController _entry;
  late AnimationController _float;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    _float = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat(reverse: true);
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
    _entry.dispose();
    _float.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  double _seg(double start, double end) {
    final v = _entry.value;
    if (v <= start) return 0;
    if (v >= end) return 1;
    return Curves.easeOutCubic.transform((v - start) / (end - start));
  }

  Widget _enter(Widget child, double start, double end) {
    return AnimatedBuilder(
      animation: _entry,
      builder: (_, __) {
        final t = _seg(start, end);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - t)),
            child: Transform.scale(
              scale: 0.97 + 0.03 * t,
              child: child,
            ),
          ),
        );
      },
    );
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
      backgroundColor: MoroccanZellijCreamBackground.creamBase,
      appBar: AppBar(
        backgroundColor: AppColors.shellAppBarSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        foregroundColor: AppColors.deepBlue,
        iconTheme: const IconThemeData(color: AppColors.deepBlue),
        title: Text(
          S.loginTitle,
          style: GoogleFonts.elMessiri(
            fontWeight: FontWeight.w800,
            fontSize: 21,
            color: AppColors.deepBlue,
          ),
        ),
        centerTitle: true,
      ),
      body: CinematicMoroccanBackground(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _enter(
                  Center(
                    child: AnimatedBuilder(
                      animation: _float,
                      builder: (_, __) {
                        final dy = 2.8 * math.sin(_float.value * math.pi * 2);
                        return Transform.translate(
                          offset: Offset(0, dy),
                          child: Hero(
                            tag: 'al_asel_logo',
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withValues(alpha: 0.28),
                                    blurRadius: 18,
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: AppColors.deepBlue.withValues(alpha: 0.08),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Container(
                                  color: AppColors.white,
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    'assets/branding/logo_al_asel.png',
                                    height: 88,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => SvgPicture.asset(
                                      'assets/branding/logo.svg',
                                      height: 88,
                                      fit: BoxFit.contain,
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
                  0.0,
                  0.18,
                ),
                const SizedBox(height: 10),
                _enter(const Center(child: MoroccanGoldBand(width: 110)), 0.06, 0.22),
                const SizedBox(height: 16),
                _enter(
                  Column(
                    children: [
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
                          color: AppColors.moroccoSlate,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  0.1,
                  0.3,
                ),
                const SizedBox(height: 20),
                _enter(
                  MoroccanCard(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.cairo(color: AppColors.ink, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            labelText: S.emailLabel,
                            labelStyle: GoogleFonts.cairo(color: AppColors.moroccoSlate, fontWeight: FontWeight.w600),
                            floatingLabelStyle: GoogleFonts.cairo(color: AppColors.moroccoGreen, fontWeight: FontWeight.w700),
                            prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.moroccoGreen),
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.moroccoSlateLight.withValues(alpha: 0.35)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.moroccoGreen, width: 2),
                            ),
                          ),
                        ),
                        FormSpacing.betweenInputs,
                        TextField(
                          controller: _password,
                          obscureText: true,
                          style: GoogleFonts.cairo(color: AppColors.ink, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            labelText: S.passwordLabel,
                            labelStyle: GoogleFonts.cairo(color: AppColors.moroccoSlate, fontWeight: FontWeight.w600),
                            floatingLabelStyle: GoogleFonts.cairo(color: AppColors.moroccoGreen, fontWeight: FontWeight.w700),
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.moroccoGreen),
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.moroccoSlateLight.withValues(alpha: 0.35)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppColors.moroccoGreen, width: 2),
                            ),
                          ),
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _rememberMe,
                          onChanged: loading ? null : (v) => setState(() => _rememberMe = v ?? false),
                          title: Text(S.rememberLogin, style: GoogleFonts.cairo(fontSize: 14, color: AppColors.ink, fontWeight: FontWeight.w600)),
                          activeColor: AppColors.moroccoGreen,
                          checkColor: AppColors.white,
                          side: BorderSide(color: AppColors.moroccoSlateLight.withValues(alpha: 0.5)),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        if (err != null) ...[
                          const SizedBox(height: 12),
                          Text(err!, style: GoogleFonts.cairo(color: AppColors.moroccoRed, fontWeight: FontWeight.w700)),
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
                  0.16,
                  0.38,
                ),
                const SizedBox(height: 12),
                _enter(
                  TextButton(
                    onPressed: () => context.push('/auth/register/client'),
                    child: Text(
                      S.registerClient,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.deepBlue,
                      ),
                    ),
                  ),
                  0.26,
                  0.44,
                ),
                _enter(
                  TextButton(
                    onPressed: () => context.push('/auth/register/artisan'),
                    child: Text(
                      S.registerArtisan,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.moroccoGreen,
                      ),
                    ),
                  ),
                  0.3,
                  0.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
