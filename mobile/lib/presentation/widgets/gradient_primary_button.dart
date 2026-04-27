import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

/// CTA : dégradé + *ripple* Material + *shine* + *glow pulse* + léger scale au press.
class GradientPrimaryButton extends StatefulWidget {
  const GradientPrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.loading = false,
    this.minHeight = 52,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool loading;
  final double minHeight;

  @override
  State<GradientPrimaryButton> createState() => _GradientPrimaryButtonState();
}

class _GradientPrimaryButtonState extends State<GradientPrimaryButton> with TickerProviderStateMixin {
  late AnimationController _pulse;
  late AnimationController _shine;
  bool _pressed = false;

  void _syncAmbientAnimations() {
    final active = widget.onPressed != null && !widget.loading;
    if (active) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
      if (!_shine.isAnimating) _shine.repeat();
    } else {
      _pulse.stop();
      _shine.stop();
    }
  }

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _shine = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
    _syncAmbientAnimations();
  }

  @override
  void didUpdateWidget(covariant GradientPrimaryButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onPressed != widget.onPressed || oldWidget.loading != widget.loading) {
      _syncAmbientAnimations();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inactive = widget.onPressed == null;
    final glow = 0.32 + 0.22 * CurvedAnimation(parent: _pulse, curve: Curves.easeInOut).value;

    return AnimatedOpacity(
      opacity: inactive ? 0.55 : 1,
      duration: const Duration(milliseconds: 200),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulse, _shine]),
          builder: (context, _) {
            return Container(
              constraints: BoxConstraints(minHeight: widget.minHeight),
              decoration: BoxDecoration(
                gradient: AppGradients.primaryButton,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.55 + 0.12 * glow), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: inactive ? 0.12 : 0.35 + 0.2 * glow),
                    blurRadius: inactive ? 8 : 16 + 14 * glow,
                    spreadRadius: inactive ? 0 : -1,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: AppColors.deepBlue.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: (widget.loading || inactive) ? null : widget.onPressed,
                  borderRadius: BorderRadius.circular(18),
                  splashColor: AppColors.gold.withValues(alpha: 0.28),
                  highlightColor: AppColors.moroccoGreen.withValues(alpha: 0.12),
                  onHighlightChanged: (v) => setState(() => _pressed = v),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            child: widget.loading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white),
                                  )
                                : Text(
                                    widget.label,
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: AppColors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),
                        if (!widget.loading && !inactive)
                          Positioned.fill(
                            child: LayoutBuilder(
                              builder: (context, c) {
                                final w = c.maxWidth;
                                return IgnorePointer(
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: -w * 0.35 + w * 1.7 * _shine.value,
                                        top: 0,
                                        bottom: 0,
                                        width: w * 0.38,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.white.withValues(alpha: 0),
                                                Colors.white.withValues(alpha: 0.38),
                                                Colors.white.withValues(alpha: 0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
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
