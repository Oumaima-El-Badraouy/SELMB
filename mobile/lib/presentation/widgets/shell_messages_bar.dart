import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../providers/app_providers.dart';

/// شريط علوي : شعار + مديونة + إبلاغ + رسائل.
class ShellMessagesBar extends ConsumerStatefulWidget {
  const ShellMessagesBar({super.key});

  @override
  ConsumerState<ShellMessagesBar> createState() => _ShellMessagesBarState();
}

class _ShellMessagesBarState extends ConsumerState<ShellMessagesBar> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 18), (_) {
      ref.invalidate(inboxUnreadTotalProvider);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(inboxUnreadTotalProvider);
    return Material(
      elevation: 6,
      shadowColor: AppColors.deepBlue.withValues(alpha: 0.2),
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.white.withValues(alpha: 0.97),
              AppColors.parchment,
              AppColors.sandDeep.withValues(alpha: 0.85),
            ],
          ),
          border: Border(
            bottom: BorderSide(color: AppColors.gold.withValues(alpha: 0.65), width: 2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.zellijGlaze.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: S.reportProblem,
                  onPressed: () => context.push('/report'),
                  icon: const Icon(Icons.flag_outlined, color: AppColors.deepBlue),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/branding/logo_al_asel.png',
                        height: 52,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox(height: 52, width: 52),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        S.mediouna,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.terracotta.withValues(alpha: 0.95),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                async.when(
                  data: (n) => Badge(
                    isLabelVisible: n > 0,
                    backgroundColor: AppColors.terracotta,
                    textColor: AppColors.white,
                    label: Text(n > 99 ? '99+' : '$n', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 11)),
                    child: Material(
                      color: AppColors.deepBlue.withValues(alpha: 0.08),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: S.messages,
                        onPressed: () => context.push('/inbox'),
                        icon: const Icon(Icons.mark_chat_unread_outlined, color: AppColors.deepBlue),
                      ),
                    ),
                  ),
                  loading: () => IconButton(
                    tooltip: S.messages,
                    onPressed: () => context.push('/inbox'),
                    icon: const Icon(Icons.mark_chat_unread_outlined, color: AppColors.deepBlue),
                  ),
                  error: (_, __) => IconButton(
                    tooltip: S.messages,
                    onPressed: () => context.push('/inbox'),
                    icon: const Icon(Icons.mark_chat_unread_outlined, color: AppColors.deepBlue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
