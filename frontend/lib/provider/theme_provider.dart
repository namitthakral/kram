// import 'package:flutter/material.dart';

// class ThemeProvider extends ChangeNotifier {
//   ThemeMode themeMode = ThemeMode.system;

//   bool get isDarkMode => themeMode == ThemeMode.dark;

//   void toggleTheme(bool isOn) {
//     themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
//     notifyListeners();
//   }

//   ThemeData get themeData => isDarkMode ? darkTheme : lightTheme;

//   ThemeData get lightTheme => ThemeData(
//     colorScheme: ColorScheme.light(
//       primary: Color(0xFFFF9933), // Purple
//       secondary: Color(0xFF6A0DAD), // Blue
//       surface: Color(0xFFFCFCFC), // Light Gray
//       onPrimary: Color(0xFFFFFFFF), // Text on primary
//       onSecondary: Color(0xFFFFFFFF), // Text on secondary
//       onSurface: Color(0xFF333333), // Dark text
//     ),
//     useMaterial3: true,
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Color(0xFFFF9933), // Button color
//         foregroundColor: Color(0xFFFFFFFF), // White text
//       ),
//     ),
//     bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//       backgroundColor: Colors.white,
//       selectedItemColor: Color(0xFFFF9933), // Selected (Blue)
//       unselectedItemColor: Colors.grey, // Unselected (Grey)
//       showUnselectedLabels: true,
//       type: BottomNavigationBarType.fixed,
//     ),
//     fontFamily: 'Outfit',
//     switchTheme: SwitchThemeData(
//       trackColor: WidgetStateProperty.all(Color(0xFFFF9933)),
//       trackOutlineColor: WidgetStateProperty.all(Color(0xFFFF9933)),
//       thumbColor: WidgetStateProperty.all(Colors.white),
//     ),
//     dividerTheme: const DividerThemeData(color: Color(0xFFE3E7EC)),
//     textTheme: const TextTheme().apply(
//       bodyColor: Color(0xFF191D31), // Light mode
//       displayColor: Color(0xFF191D31),
//     ),
//   );

//   ThemeData get darkTheme => ThemeData(
//     colorScheme: ColorScheme.dark(
//       primary: Color(0xFFFF9933), // Purple
//       secondary: Color(0xFF2E86C1), // Blue
//       surface: Color(0xFF1E1E1E), // Dark Gray
//       onPrimary: Color(0xFFFFFFFF), // Text on primary
//       onSecondary: Color(0xFFFFFFFF), // Text on secondary
//       onSurface: Color(0xFFE0E0E0), // Light text
//     ),
//     useMaterial3: true,
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Color(0xFFFF9933),
//         foregroundColor: Color(0xFF333333),
//       ),
//     ),
//     bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//       backgroundColor: Color(0xFF1E1E1E),
//       selectedItemColor: Color(0xFFFF9933),
//       unselectedItemColor: Colors.grey,
//       showUnselectedLabels: true,
//       type: BottomNavigationBarType.fixed,
//     ),
//     fontFamily: 'Outfit',
//     switchTheme: SwitchThemeData(
//       trackColor: WidgetStateProperty.all(Color(0xFFFF9933)),
//       trackOutlineColor: WidgetStateProperty.all(Color(0xFFFF9933)),
//       thumbColor: WidgetStateProperty.all(Colors.white),
//     ),
//     dividerTheme: const DividerThemeData(color: Color(0xFFE3E7EC)),
//     textTheme: const TextTheme().apply(
//       bodyColor: Color(0xFFE0E0E0), // Dark mode
//       displayColor: Color(0xFFE0E0E0),
//     ),
//   );
// }

import 'package:flutter/material.dart';

import '../utils/custom_colors.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;
  // ThemeMode themeMode = ThemeMode.system;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme({bool isOn = false}) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  ThemeData get themeData => isDarkMode ? darkTheme : lightTheme;

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: CustomAppColors.primary, // Blue
      secondary: CustomAppColors.secondary, // Slate
      error: CustomAppColors.error,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CustomAppColors.blue500, // Button color
        foregroundColor: CustomAppColors.white, // White text
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: CustomAppColors.white,
      indicatorColor: CustomAppColors.blue50, // Light blue indicator
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: CustomAppColors.blue500,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }
        return const TextStyle(color: CustomAppColors.grey07, fontSize: 12);
      }),
      elevation: 3,
      height: 60,
    ),
    fontFamily: 'Outfit',
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.all(CustomAppColors.blue500),
      trackOutlineColor: WidgetStateProperty.all(CustomAppColors.blue500),
      thumbColor: WidgetStateProperty.all(CustomAppColors.white),
    ),
    dividerTheme: const DividerThemeData(color: CustomAppColors.grey06),
    textTheme: const TextTheme().apply(
      bodyColor: CustomAppColors.textPrimary, // Light mode
      displayColor: CustomAppColors.textPrimary,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: CustomAppColors.blue500, // Primary blue color
      inactiveTrackColor: CustomAppColors.slate100,
      trackHeight: 12.0,
      thumbColor: CustomAppColors.white,
      overlayColor: Colors.transparent,
      overlayShape: SliderComponentShape.noOverlay,
      valueIndicatorColor: CustomAppColors.blue500,
      valueIndicatorTextStyle: const TextStyle(color: CustomAppColors.white),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      dragHandleColor: CustomAppColors.grey06,
      dragHandleSize: Size(60, 6),
      showDragHandle: true,
    ),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: CustomAppColors.primary, // Blue
      secondary: CustomAppColors.secondary, // Slate
      onPrimary: CustomAppColors.onPrimary, // White
      onSecondary: CustomAppColors.onPrimary, // White
      onSurface: CustomAppColors.darkTextPrimary, // Light text
      error: CustomAppColors.error,
      onError: CustomAppColors.onError,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CustomAppColors.blue500,
        foregroundColor: CustomAppColors.white,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: CustomAppColors.darkBackground,
      indicatorColor: CustomAppColors.blue500.withValues(
        alpha: 0.2,
      ), // Light blue indicator
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: CustomAppColors.blue500,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }
        return const TextStyle(color: CustomAppColors.grey07, fontSize: 12);
      }),
      elevation: 0,
      height: 60,
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.all(CustomAppColors.blue500),
      trackOutlineColor: WidgetStateProperty.all(CustomAppColors.blue500),
      thumbColor: WidgetStateProperty.all(CustomAppColors.white),
    ),
    dividerTheme: const DividerThemeData(color: CustomAppColors.grey06),
    fontFamily: 'Outfit',
    textTheme: const TextTheme().apply(
      bodyColor: CustomAppColors.darkTextPrimary, // Dark mode
      displayColor: CustomAppColors.darkTextPrimary,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: CustomAppColors.blue500, // Primary blue color
      inactiveTrackColor: CustomAppColors.slate500,
      trackHeight: 12.0,
      thumbColor: CustomAppColors.white,
      overlayColor: Colors.transparent,
      overlayShape: SliderComponentShape.noOverlay,
      valueIndicatorColor: CustomAppColors.blue500,
      valueIndicatorTextStyle: const TextStyle(color: CustomAppColors.white),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      dragHandleColor: CustomAppColors.grey06,
      dragHandleSize: Size(60, 6),
      showDragHandle: true,
    ),
  );
}
