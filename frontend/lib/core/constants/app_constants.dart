class AppConstants {
  // App Information
  static const String appName = 'Kram';
  static const String appVersion = '1.0.0';

  // API Configuration
  // baseUrl is set via --dart-define at launch time
  //
  // IMPORTANT: Defaults to LOCAL DEVELOPMENT if not specified!
  //
  // For local development (default):
  //   Just run: flutter run
  //   OR use VS Code launch configuration: "Development (Local API)"
  //   OR run: flutter run --dart-define=BASE_URL=http://localhost:3000
  //
  // For production:
  //   Use VS Code launch configuration: "Production"
  //   OR run: flutter run --dart-define=BASE_URL=https://api.kramedu.in
  //
  // See .vscode/launch.json for pre-configured environments
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:3000', // Default to local for development
  );
  static const String apiVersion = ''; // No prefix needed - routes are at root
  static const Duration apiTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenExpiryKey = 'token_expiry';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String onboardingCompletedKey = 'onboarding_completed';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;
  static const double defaultRadius = 8.0;
  static const double defaultElevation = 2.0;

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double maxContentWidth = 1440;

  // Layout constants for different screen sizes
  static const double mobilePadding = 16.0;
  static const double tabletPadding = 24.0;
  static const double desktopPadding = 32.0;

  // Navigation drawer width for tablet/desktop
  static const double drawerWidth = 280;
  static const double railWidth = 80;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
}
