import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

class RosterScreen extends StatelessWidget {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 80,
                color: AppColors.navInactive,
              ),
              const SizedBox(height: 24),
              Text(
                'Roster',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Placeholder screen – coming soon',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
