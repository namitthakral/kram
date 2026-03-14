import 'dart:ui';

class CustomAppColors {
  // Primary Colors
  static const Color primary = Color(0xFF3b82f6);
  static const Color primaryBlue = Color(
    0xFF155dfc,
  ); // Primary interactive elements
  static const Color blue500 = Color(
    0xFF3b82f6,
  ); // Primary buttons, active states
  static const Color blue600 = Color(0xFF2563eb); // Hover states
  static const Color blue50 = Color(0xFFeff6ff); // Light backgrounds

  // Secondary Colors
  static const Color secondary = Color(0xFF1e293b);
  static const Color slate800 = Color(0xFF1e293b); // Headings
  static const Color slate700 = Color(0xFF334155); // Subheadings
  static const Color slate600 = Color(0xFF475569); // Body text
  static const Color slate500 = Color(0xFF64748b); // Muted text
  static const Color slate400 = Color(0xFF94a3b8); // Lighter muted text
  static const Color slate300 = Color(0xFFcbd5e1); // Borders
  static const Color slate200 = Color(0xFFe2e8f0); // Light borders
  static const Color slate100 = Color(0xFFf1f5f9); // Subtle backgrounds
  static const Color slate50 = Color(0xFFf8fafc); // Very light backgrounds

  // Status Colors
  static const Color success = Color(0xFF10b981); // Green
  static const Color warning = Color(0xFFf59e0b); // Amber
  static const Color danger = Color(0xFFef4444); // Red
  static const Color error = Color(0xFFef4444); // Red (alias for danger)
  static const Color info = Color(0xFF06b6d4); // Cyan

  // Accent Colors
  static const Color purple = Color(0xFF8b5cf6); // Purple accent
  static const Color pink = Color(0xFFec4899); // Pink accent

  // Red color variants
  static const Color red50 = Color(0xFFfef2f2);
  static const Color red200 = Color(0xFFfecaca);
  static const Color red500 = Color(0xFFef4444);
  static const Color red700 = Color(0xFFb91c1c);

  // Amber color variants
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);

  // Surface Colors
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color background = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1e293b);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textDark = Color(0xFF1e293b);

  // On Colors (for text on colored backgrounds)
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onSurface = Color(0xFF000000);
  static const Color onBackground = Color(0xFF000000);
  static const Color onError = Color(0xFFFFFFFF);

  // Legacy Colors (kept for backward compatibility)
  static const Color black01 = Color(0xFF191D31);
  static const Color black03 = Color(0xFF8C8E98);
  static const Color grey01 = Color(0xFFA7AEC1);
  static const Color grey02 = Color(0xFFF9F9F9);
  static const Color grey03 = Color(0xFFD9D9D9);
  static const Color grey04 = Color(0xFFE2E4EA);
  static const Color grey05 = Color(0xFF78828A);
  static const Color grey06 = Color(0xFFDFE2EB);
  static const Color grey07 = Color(0xFF9CA4AB);
  static const Color yellow01 = Color(0xFFFFBB0D);
  static const Color red01 = Color(0xFFE50000);
  static const Color lightGrey01 = Color(0xFFF3F3F3);
  static const Color green01 = Color(0xFF00D261);

  // Dark theme variants
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
}
