import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Primary Colors
  static const Color blue500 = Color(
    0xFF3b82f6,
  ); // Primary buttons, active states
  static const Color blue600 = Color(0xFF2563eb); // Hover states
  static const Color blue50 = Color(0xFFeff6ff); // Light backgrounds

  // Secondary Colors
  static const Color slate800 = Color(0xFF1e293b); // Headings
  static const Color slate600 = Color(0xFF475569); // Body text
  static const Color slate500 = Color(0xFF64748b); // Muted text
  static const Color slate200 = Color(0xFFe2e8f0); // Borders, dividers
  static const Color slate100 = Color(0xFFf1f5f9); // Subtle backgrounds

  // Status Colors
  static const Color success = Color(0xFF10b981); // Green
  static const Color warning = Color(0xFFf59e0b); // Amber
  static const Color danger = Color(0xFFef4444); // Red
  static const Color info = Color(0xFF06b6d4); // Cyan

  // Surface Colors
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onSurface = Color(0xFF000000);
  static const Color onBackground = Color(0xFF000000);
  static const Color onError = Color(0xFFFFFFFF);

  // Typography - Font Sizes
  static const double fontSize3xl = 30.0; // Large headings
  static const double fontSize2xl = 24.0; // Page titles
  static const double fontSizeXl = 20.0; // Section headings
  static const double fontSizeLg = 18.0; // Card titles
  static const double fontSizeBase = 16.0; // Body text
  static const double fontSizeSm = 14.0; // Secondary text
  static const double fontSizeXs = 12.0; // Captions

  // Typography - Font Weights
  static const FontWeight fontWeightBold =
      FontWeight.w700; // Important headings
  static const FontWeight fontWeightSemibold = FontWeight.w600; // Card titles
  static const FontWeight fontWeightMedium = FontWeight.w500; // Buttons, labels
  static const FontWeight fontWeightNormal = FontWeight.w400; // Body text
}
