import 'package:flutter/foundation.dart';

/// Platform helper that safely checks platform without dart:io on web
class PlatformHelper {
  /// Check if running on iOS
  static bool get isIOS {
    if (kIsWeb) {
      return false;
    }
    // Only import dart:io when not on web
    return _isIOSNative();
  }

  /// Check if running on Android
  static bool get isAndroid {
    if (kIsWeb) {
      return false;
    }
    return _isAndroidNative();
  }

  /// Check if running on desktop (Windows, macOS, Linux)
  static bool get isDesktop {
    if (kIsWeb) {
      return false;
    }
    return _isDesktopNative();
  }

  /// Check if should use mobile UI (iOS or Android)
  static bool get isMobilePlatform {
    if (kIsWeb) {
      return false;
    }
    return isIOS || isAndroid;
  }
}

// Conditional imports to avoid dart:io on web
bool _isIOSNative() {
  try {
    // This will only work when dart:io is available (non-web)
    return defaultTargetPlatform == TargetPlatform.iOS;
  } on Exception catch (_) {
    return false;
  }
}

bool _isAndroidNative() {
  try {
    return defaultTargetPlatform == TargetPlatform.android;
  } on Exception catch (_) {
    return false;
  }
}

bool _isDesktopNative() {
  try {
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  } on Exception catch (_) {
    return false;
  }
}
