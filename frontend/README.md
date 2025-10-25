# EdVerse Frontend

A Flutter-based educational platform frontend.

## Development Setup

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (comes with Flutter)
- VS Code or Android Studio with Flutter/Dart plugins

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
- `.editorconfig` - Cross-editor formatting configuration
- `analysis_options.yaml` - Dart linter rules

### Running the App

```bash
# Get dependencies
flutter pub get

# Run on connected device/simulator
flutter run

# Run in debug mode
flutter run --debug

# Run in release mode
flutter run --release
```

### Code Style

- Line length: 80 characters
- Indentation: 2 spaces
- Follow Dart style guide: https://dart.dev/guides/language/effective-dart/style
- Use `dart fix --apply` to automatically fix common issues
