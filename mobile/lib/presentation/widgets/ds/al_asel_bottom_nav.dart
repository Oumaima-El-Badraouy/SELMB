import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Barre de navigation inférieure — verre dépoli + liseré or (style riad contemporain).
class AlAselBottomNavBar extends StatelessWidget {
  const AlAselBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.parchment.withValues(alpha: 0.9),
                AppColors.sand.withValues(alpha: 0.96),
              ],
            ),
            border: Border(
              top: BorderSide(color: AppColors.gold.withValues(alpha: 0.42), width: 1.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepBlue.withValues(alpha: 0.1),
                blurRadius: 28,
                offset: const Offset(0, -6),
              ),
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.12),
                blurRadius: 18,
                spreadRadius: -4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                indicatorColor: AppColors.gold.withValues(alpha: 0.38),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return TextStyle(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.2,
                    color: selected ? AppColors.deepBlue : AppColors.muted,
                  );
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return IconThemeData(
                    color: selected ? AppColors.deepBlue : AppColors.muted,
                    size: 26,
                  );
                }),
              ),
              child: NavigationBar(
                height: 74,
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                backgroundColor: Colors.transparent,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: destinations,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
