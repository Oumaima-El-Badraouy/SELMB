import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

/// Bouton principal **or & nuit** — ombre portée forte.
class GradientPrimaryButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final inactive = onPressed == null;
    return AnimatedOpacity(
      opacity: inactive ? 0.55 : 1,
      duration: const Duration(milliseconds: 200),
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        decoration: BoxDecoration(
          gradient: AppGradients.primaryButton,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.55), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: inactive ? 0.15 : 0.45),
              blurRadius: inactive ? 8 : 22,
              spreadRadius: 0,
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
            onTap: (loading || inactive) ? null : onPressed,
            borderRadius: BorderRadius.circular(18),
            splashColor: AppColors.gold.withValues(alpha: 0.25),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white),
                      )
                    : Text(
                        label,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
