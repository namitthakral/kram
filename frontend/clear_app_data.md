# Clear App Data for Testing

## Problem

The Android simulator has stored onboarding data, causing the app to skip the welcome screen and go directly to login.

## Solutions

### Option 1: Use the Debug Code (Current)

The splash screen now includes debug code that clears stored data on every launch.

### Option 2: Clear Android App Data Manually

1. Open Android simulator
2. Go to Settings > Apps
3. Find "EdVerse" app
4. Tap "Storage"
5. Tap "Clear Data" or "Clear Storage"

### Option 3: Uninstall and Reinstall

```bash
cd frontend
flutter clean
flutter pub get
flutter run -d android
```

### Option 4: Use ADB Command

```bash
adb shell pm clear com.example.ed_verse
```

## For Production

Remember to remove/comment out lines 32-36 in splash_screen.dart:

```dart
// FOR TESTING: Clear stored data to always show welcome screen
// Comment out these lines in production
await _secureStorage.delete(AppConstants.onboardingCompletedKey);
await _secureStorage.delete(AppConstants.tokenKey);
print('DEBUG: Cleared onboarding data for testing');
```
