import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // Light Theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: blue500,
      primaryContainer: blue600,
      secondary: slate600,
      secondaryContainer: slate100,
      surface: backgroundColor,
      error: danger,
    ),
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: fontSize3xl,
          fontWeight: fontWeightBold,
          color: slate800,
        ),
        displayMedium: TextStyle(
          fontSize: fontSize2xl,
          fontWeight: fontWeightBold,
          color: slate800,
        ),
        displaySmall: TextStyle(
          fontSize: fontSizeXl,
          fontWeight: fontWeightSemibold,
          color: slate800,
        ),
        headlineMedium: TextStyle(
          fontSize: fontSizeLg,
          fontWeight: fontWeightSemibold,
          color: slate800,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSizeBase,
          fontWeight: fontWeightNormal,
          color: slate600,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSizeSm,
          fontWeight: fontWeightNormal,
          color: slate600,
        ),
        bodySmall: TextStyle(
          fontSize: fontSizeXs,
          fontWeight: fontWeightNormal,
          color: slate500,
        ),
        labelLarge: TextStyle(
          fontSize: fontSizeBase,
          fontWeight: fontWeightMedium,
          color: slate800,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: blue500,
      foregroundColor: onPrimary,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.inter(
        fontSize: fontSizeXl,
        fontWeight: fontWeightSemibold,
        color: onPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        backgroundColor: blue500,
        foregroundColor: onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.inter(
          fontSize: fontSizeBase,
          fontWeight: fontWeightMedium,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: GoogleFonts.inter(
        fontSize: fontSizeSm,
        fontWeight: fontWeightNormal,
        color: slate500,
      ),
    ),
  );

  // Dark Theme
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: blue500,
      primaryContainer: blue600,
      secondary: slate500,
      secondaryContainer: slate800,
      surface: Color(0xFF1e293b),
      error: danger,
      onPrimary: onPrimary,
      onSecondary: onPrimary,
      onError: onError,
    ),
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: fontSize3xl,
          fontWeight: fontWeightBold,
          color: Color(0xFFFFFFFF),
        ),
        displayMedium: TextStyle(
          fontSize: fontSize2xl,
          fontWeight: fontWeightBold,
          color: Color(0xFFFFFFFF),
        ),
        displaySmall: TextStyle(
          fontSize: fontSizeXl,
          fontWeight: fontWeightSemibold,
          color: Color(0xFFFFFFFF),
        ),
        headlineMedium: TextStyle(
          fontSize: fontSizeLg,
          fontWeight: fontWeightSemibold,
          color: Color(0xFFFFFFFF),
        ),
        bodyLarge: TextStyle(
          fontSize: fontSizeBase,
          fontWeight: fontWeightNormal,
          color: slate100,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSizeSm,
          fontWeight: fontWeightNormal,
          color: slate100,
        ),
        bodySmall: TextStyle(
          fontSize: fontSizeXs,
          fontWeight: fontWeightNormal,
          color: slate500,
        ),
        labelLarge: TextStyle(
          fontSize: fontSizeBase,
          fontWeight: fontWeightMedium,
          color: Color(0xFFFFFFFF),
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: slate800,
      foregroundColor: onPrimary,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.inter(
        fontSize: fontSizeXl,
        fontWeight: fontWeightSemibold,
        color: onPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        backgroundColor: blue500,
        foregroundColor: onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.inter(
          fontSize: fontSizeBase,
          fontWeight: fontWeightMedium,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: slate800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: GoogleFonts.inter(
        fontSize: fontSizeSm,
        fontWeight: fontWeightNormal,
        color: slate500,
      ),
    ),
  );
}
