import 'package:flutter/material.dart';

/// Responsive utility class to handle different screen sizes
class ResponsiveUtils {
  /// Breakpoints for different device sizes
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Get current device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else if (width < desktopBreakpoint) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  /// Check if current device is mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  /// Check if current device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if current device is desktop
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  /// Check if current device is large desktop
  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  /// Get responsive value based on device type
  static T responsive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  /// Get responsive width based on percentage
  static double width(BuildContext context, double percentage) =>
      MediaQuery.of(context).size.width * percentage;

  /// Get responsive height based on percentage
  static double height(BuildContext context, double percentage) =>
      MediaQuery.of(context).size.height * percentage;

  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.fromLTRB(24.0, 4.0, 24.0, 4.0);
    } else {
      return const EdgeInsets.fromLTRB(32.0, 4.0, 32.0, 4.0);
    }
  }

  /// Get responsive horizontal padding
  static EdgeInsets responsiveHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 64.0);
    }
  }

  /// Get max content width for desktop
  static double getMaxContentWidth(BuildContext context) {
    if (isMobile(context)) {
      return MediaQuery.of(context).size.width;
    } else if (isTablet(context)) {
      return 768;
    } else {
      return 1200;
    }
  }

  /// Get responsive font size
  static double responsiveFontSize(BuildContext context, double baseFontSize) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return baseFontSize;
    } else if (width < tabletBreakpoint) {
      return baseFontSize * 1.1;
    } else {
      return baseFontSize * 1.2;
    }
  }

  /// Calculate responsive size based on screen width
  static double getResponsiveSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return mobile;
    } else if (width < tabletBreakpoint) {
      return tablet ?? mobile * 1.2;
    } else {
      return desktop ?? tablet ?? mobile * 1.5;
    }
  }

  /// Get number of columns for grid based on screen size
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return 1;
    } else if (width < tabletBreakpoint) {
      return 2;
    } else if (width < desktopBreakpoint) {
      return 3;
    } else {
      return 4;
    }
  }

  /// Get number of columns for grid based on screen size AND orientation
  /// Note: Mobile devices keep the same column count regardless of orientation
  static int getGridColumnsWithOrientation(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLandscapeMode = isLandscape(context);

    if (width < mobileBreakpoint) {
      // Mobile devices: same layout for both portrait and landscape
      return 1;
    } else if (width < tabletBreakpoint) {
      return isLandscapeMode ? 3 : 2;
    } else if (width < desktopBreakpoint) {
      return isLandscapeMode ? 4 : 3;
    } else {
      return isLandscapeMode ? 5 : 4;
    }
  }

  /// Check if the device is in landscape mode
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// Check if the device is in portrait mode
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  /// Get responsive value based on device type AND orientation
  /// Note: Mobile devices ignore orientation and always return mobilePortrait value
  static T responsiveWithOrientation<T>({
    required BuildContext context,
    required T mobilePortrait,
    T? mobileLandscape,
    T? tabletPortrait,
    T? tabletLandscape,
    T? desktopPortrait,
    T? desktopLandscape,
  }) {
    final deviceType = getDeviceType(context);
    final isLandscapeMode = isLandscape(context);

    switch (deviceType) {
      case DeviceType.mobile:
        // Mobile devices: same value for both portrait and landscape
        return mobilePortrait;
      case DeviceType.tablet:
        return isLandscapeMode
            ? (tabletLandscape ?? tabletPortrait ?? mobilePortrait)
            : (tabletPortrait ?? mobilePortrait);
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return isLandscapeMode
            ? (desktopLandscape ??
                tabletLandscape ??
                desktopPortrait ??
                tabletPortrait ??
                mobilePortrait)
            : (desktopPortrait ??
                tabletPortrait ??
                desktopLandscape ??
                mobilePortrait);
    }
  }

  /// Get responsive value based on orientation only
  static T orientationValue<T>({
    required BuildContext context,
    required T portrait,
    required T landscape,
  }) => isLandscape(context) ? landscape : portrait;

  /// Get responsive padding based on orientation
  /// Note: Mobile devices keep the same padding regardless of orientation
  static EdgeInsets responsivePaddingWithOrientation(BuildContext context) {
    final isLandscapeMode = isLandscape(context);

    if (isMobile(context)) {
      // Mobile devices: same padding for both portrait and landscape
      return const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0);
    } else if (isTablet(context)) {
      return isLandscapeMode
          ? const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0)
          : const EdgeInsets.all(24.0);
    } else {
      return isLandscapeMode
          ? const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0)
          : const EdgeInsets.all(32.0);
    }
  }
}

/// Device type enum
enum DeviceType { mobile, tablet, desktop, largeDesktop }

/// Extension on BuildContext for easy access to responsive utilities
extension ResponsiveExtension on BuildContext {
  /// Get device type
  DeviceType get deviceType => ResponsiveUtils.getDeviceType(this);

  /// Check if mobile
  bool get isMobile => ResponsiveUtils.isMobile(this);

  /// Check if tablet
  bool get isTablet => ResponsiveUtils.isTablet(this);

  /// Check if desktop
  bool get isDesktop => ResponsiveUtils.isDesktop(this);

  /// Check if large desktop
  bool get isLargeDesktop => ResponsiveUtils.isLargeDesktop(this);

  /// Check if landscape
  bool get isLandscape => ResponsiveUtils.isLandscape(this);

  /// Check if portrait
  bool get isPortrait => ResponsiveUtils.isPortrait(this);

  /// Get responsive padding
  EdgeInsets get responsivePadding => ResponsiveUtils.responsivePadding(this);

  /// Get responsive horizontal padding
  EdgeInsets get responsiveHorizontalPadding =>
      ResponsiveUtils.responsiveHorizontalPadding(this);

  /// Get max content width
  double get maxContentWidth => ResponsiveUtils.getMaxContentWidth(this);

  /// Get grid columns
  int get gridColumns => ResponsiveUtils.getGridColumns(this);
}
