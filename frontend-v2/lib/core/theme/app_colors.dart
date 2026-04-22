import 'package:flutter/material.dart';

/// Design tokens from Figma - Teacher Home v4 + Semantic colors
class AppColors {
  AppColors._();

  // === Semantic Colors (Material Design compatible) ===
  // Primary
  static const Color primary = Color(0xFF630ED4);
  static const Color primaryVariant = Color(0xFF4C1D95);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary
  static const Color secondary = Color(0xFF7C3AED);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Background & Surface
  static const Color background = Color(0xFFFAF8FF);
  static const Color onBackground = Color(0xFF131B2E);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF131B2E);

  // Status Colors
  static const Color success = Color(0xFF047857);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color info = Color(0xFF006D9C);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFF59E0B);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);

  // Shadow
  static const Color shadow = Color(0x1A000000);

  // === Original Design Tokens ===
  // Primary variations
  static const Color primaryPurple = primary; // Alias
  static const Color primaryPurpleLight = Color(0xFF7C3AED);
  static const Color primaryPurpleLighter = Color(0xFFA78BFA);

  // Card Backgrounds
  static const Color cardBackground = Color(0xFFF2F3FF);
  static const Color cardBackgroundMint = Color(0xFFECFDF5);
  static const Color cardBackgroundPurple = Color(0xFFF5F3FF);
  static const Color lavenderPlaceholder = Color(0xFFE2E7FF);

  // Text
  static const Color textDark = onBackground; // Alias
  static const Color textDarkAlt = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF4A4455);
  static const Color textMutedLight = Color(0x994A4455);

  // Accents
  static const Color greenPrimary = success; // Alias
  static const Color greenBorder = Color(0xFFD1FAE5);
  static const Color greenBorderLight = Color(0xFFA7F3D0);
  static const Color blueTrend = Color(0xFF005479);
  static const Color presentBlue = info; // Alias
  static const Color absentRed = error; // Alias
  static const Color absentRedDark = Color(0xFF93000A);
  static const Color absentRedLight = Color(0xFFFFDAD6);
  static const Color purpleDark = primaryVariant; // Alias
  static const Color purpleMedium = Color(0xFF6D28D9);
  static const Color tagBlue = Color(0xFFD5E3FC);
  static const Color tagBlueText = Color(0xFF57657A);
  static const Color tagLavender = Color(0xFFEAEDFF);
  static const Color navInactive = Color(0xFF94A3B8);

  // Borders
  static const Color borderLight = Color(0x1ACCC3D8);
  static const Color borderPurple = Color(0xFFEDE9FE);
}
