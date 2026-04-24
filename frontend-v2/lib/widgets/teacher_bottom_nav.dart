import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';

enum TeacherNavItem {
  dashboard,
  roster,
  insights,
}

class TeacherBottomNav extends StatelessWidget {
  final TeacherNavItem currentIndex;
  final ValueChanged<TeacherNavItem> onTap;

  const TeacherBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE2E8F0).withOpacity(0.15),
          ),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              label: 'DASHBOARD',
              icon: Icons.grid_view_rounded,
              isActive: currentIndex == TeacherNavItem.dashboard,
              onTap: () => onTap(TeacherNavItem.dashboard),
            ),
            _NavItem(
              label: 'ROSTER',
              icon: Icons.people_outline,
              isActive: currentIndex == TeacherNavItem.roster,
              onTap: () => onTap(TeacherNavItem.roster),
            ),
            _NavItem(
              label: 'INSIGHTS',
              icon: Icons.bar_chart_outlined,
              isActive: currentIndex == TeacherNavItem.insights,
              onTap: () => onTap(TeacherNavItem.insights),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryPurpleLight,
                    AppColors.primaryPurpleLighter,
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primaryPurpleLight.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : AppColors.navInactive,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.275,
                color: isActive ? Colors.white : AppColors.navInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
