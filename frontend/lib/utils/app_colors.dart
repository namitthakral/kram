import 'dart:ui';
import 'custom_colors.dart';

class AppColors {
  // Primary
  static const Color primary = CustomAppColors.primary;
  static const Color primaryBlue = CustomAppColors.primaryBlue;

  // Secondary / Neutrals
  static const Color secondary = CustomAppColors.secondary;
  static const Color surface = CustomAppColors.surfaceColor;
  static const Color background = CustomAppColors.backgroundColor;
  static const Color white = CustomAppColors.white;

  // Status
  static const Color success = CustomAppColors.success;
  static const Color warning = CustomAppColors.warning;
  static const Color danger = CustomAppColors.danger; // Alias for error
  static const Color error = CustomAppColors.error;
  static const Color info = CustomAppColors.info;

  // Text
  static const Color textPrimary = CustomAppColors.textPrimary;
  static const Color textSecondary = CustomAppColors.textSecondary;

  // Custom Grays from CustomAppColors
  static const Color gray100 = CustomAppColors.slate100;
  static const Color gray200 = CustomAppColors.slate200;
  static const Color gray300 = CustomAppColors.slate300;
  static const Color gray400 = CustomAppColors.slate400;
  static const Color gray500 = CustomAppColors.slate500;

  // Legacy aliases if needed
  static const Color black = Color(0xFF000000);
}
