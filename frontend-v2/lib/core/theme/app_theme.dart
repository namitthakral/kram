import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryPurple,
        secondary: AppColors.primaryPurpleLight,
        surface: AppColors.background,
        error: Colors.red.shade700,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textDark,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.9,
          color: AppColors.textDark,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textMuted,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textMuted,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.textMutedLight,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryPurple,
        ),
      ),
    );
  }
}
