# Kram Frontend

A Flutter-based educational platform frontend.

## Development Setup

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (comes with Flutter)
- VS Code or Android Studio with Flutter/Dart plugins

### Environment Configuration

The app supports multiple environments (local development, production) through the `BASE_URL` configuration.

#### Using VS Code/Cursor (Recommended)

The project includes pre-configured launch configurations in `.vscode/launch.json`:

1. **Development (Local API)** - Uses `http://localhost:3000` (default for local development)
2. **Development (Local API - iOS Simulator)** - Uses `http://127.0.0.1:3000` (for iOS simulator)
3. **Production** - Uses `https://api.kramedu.in`
4. **Development (Debug)** - Local API with debug mode
5. **Production (Release)** - Production API with release mode

**To run:**
1. Press `F5` or click "Run and Debug" in VS Code
2. Select your desired configuration from the dropdown
3. The app will launch with the correct API endpoint

#### Command Line

If running from terminal, specify the API URL:

```bash
# Local development
flutter run --dart-define=BASE_URL=http://localhost:3000

# Production
flutter run --dart-define=BASE_URL=https://api.kramedu.in

# iOS Simulator (use 127.0.0.1 instead of localhost)
flutter run --dart-define=BASE_URL=http://127.0.0.1:3000
```

#### Default Behavior

If no `BASE_URL` is specified, the app defaults to **local development** (`http://localhost:3000`). This makes local development seamless. For production testing, explicitly specify the production URL.

### Code Formatting

This project uses Dart's built-in formatter (not Prettier). The code is automatically formatted on save when using VS Code/Cursor with the Dart extension.

#### Manual Formatting

Format all Dart files:

```bash
# Using the provided script
./format.sh

# Or manually
dart format lib/ test/ --line-length 80
```

#### Verify Formatting

```bash
dart format --output=none --set-exit-if-changed lib/ test/
```

#### Editor Configuration

The project includes:

- `.vscode/settings.json` - VS Code/Cursor settings for auto-formatting
- `.vscode/launch.json` - Pre-configured launch configurations for different environments
- `.editorconfig` - Cross-editor formatting configuration
- `analysis_options.yaml` - Dart linter rules

### Running the App

```bash
# Get dependencies
flutter pub get

# Run on connected device/simulator (production API by default)
flutter run

# Run with local backend
flutter run --dart-define=BASE_URL=http://localhost:3000

# Run in debug mode with local backend
flutter run --debug --dart-define=BASE_URL=http://localhost:3000

# Run in release mode with production API
flutter run --release --dart-define=BASE_URL=https://api.kramedu.in
```

### Code Style

- Line length: 80 characters
- Indentation: 2 spaces
- Follow Dart style guide: https://dart.dev/guides/language/effective-dart/style
- Use `dart fix --apply` to automatically fix common issues

## Troubleshooting

### Cannot connect to backend

If your app cannot connect to the backend:
1. Verify the backend is running: `curl http://localhost:3000/health`
2. Check that the backend is on port 3000 (the default)
3. For iOS simulator, use the "Development (Local API - iOS Simulator)" configuration (uses `127.0.0.1` instead of `localhost`)
4. Clear app data and rebuild if needed

### Want to test against production API

The app defaults to local. To use production:
1. Use the "Production" launch configuration in VS Code, OR
2. Run: `flutter run --dart-define=BASE_URL=https://api.kramedu.in`
