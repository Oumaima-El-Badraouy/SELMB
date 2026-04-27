import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

/// Barre du bas — *glass* + dégradé royal + filet or (نقوش خفيفة).
class MoroccanNavDestination {
  const MoroccanNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class MoroccanBottomNavBar extends StatelessWidget {
  const MoroccanBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<MoroccanNavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 20,
      shadowColor: AppColors.deepBlue.withValues(alpha: 0.4),
      color: Colors.transparent,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xE60C1F33),
                  Color(0xE8122A42),
                  Color(0xEB152B45),
                ],
              ),
              border: Border(
                top: BorderSide(color: AppColors.gold.withValues(alpha: 0.92), width: 2),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.22),
                  blurRadius: 22,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = 0; i < destinations.length; i++)
                      _NavTile(
                        spec: destinations[i],
                        selected: i == currentIndex,
                        onTap: () => onDestinationSelected(i),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  const _NavTile({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final MoroccanNavDestination spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: AppColors.gold.withValues(alpha: 0.28),
          highlightColor: AppColors.moroccoGreen.withValues(alpha: 0.15),
          onHighlightChanged: (v) => setState(() => _pressed = v),
          child: AnimatedScale(
            scale: _pressed ? 0.9 : 1.0,
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOutCubic,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.selected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.gold.withValues(alpha: 0.58),
                                AppColors.zellijGlaze.withValues(alpha: 0.52),
                              ],
                            )
                          : null,
                      color: widget.selected ? null : AppColors.white.withValues(alpha: 0.08),
                      border: Border.all(
                        color: widget.selected ? AppColors.gold : AppColors.white.withValues(alpha: 0.14),
                        width: widget.selected ? 1.5 : 1,
                      ),
                      boxShadow: widget.selected
                          ? [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.45),
                                blurRadius: 14,
                                spreadRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      widget.selected ? widget.spec.selectedIcon : widget.spec.icon,
                      size: 24,
                      color: widget.selected ? AppColors.white : AppColors.white.withValues(alpha: 0.74),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.spec.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 10.5,
                      height: 1.1,
                      fontWeight: widget.selected ? FontWeight.w800 : FontWeight.w600,
                      color: widget.selected ? AppColors.goldMuted : AppColors.white.withValues(alpha: 0.64),
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
