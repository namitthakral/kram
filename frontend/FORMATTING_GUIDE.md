# Dart Formatting Guide for Kram Frontend

## Important Note

**Flutter/Dart projects use Dart's built-in formatter, NOT Prettier.**

Prettier is for JavaScript/TypeScript projects. For Dart/Flutter, we use `dart format`.

## What Was Set Up

### 1. VS Code/Cursor Configuration (`.vscode/settings.json`)

Automatic formatting is now enabled:

- ✅ Format on save
- ✅ Format on type
- ✅ Organize imports on save
- ✅ Fix all auto-fixable issues on save
- ✅ 80 character line length

### 2. EditorConfig (`.editorconfig`)

Cross-editor configuration for consistent formatting across different IDEs.

### 3. Format Script (`format.sh`)

Quick command to format all Dart files:

```bash
./format.sh
```

### 4. Pre-commit Hook Sample (`.git-hooks/pre-commit.sample`)

Optional Git hook to ensure code is formatted before commits.

To enable:

```bash
cd frontend
mv .git-hooks/pre-commit.sample .git-hooks/pre-commit
chmod +x .git-hooks/pre-commit
git config core.hooksPath .git-hooks
```

## How to Use

### Automatic Formatting (Recommended)

With VS Code/Cursor:

1. Install the official Dart extension
2. Open any `.dart` file
3. Save the file (Cmd+S / Ctrl+S)
4. Code is automatically formatted! ✨

### Manual Formatting

```bash
# Format all files
dart format lib/ test/ --line-length 80

# Format specific file
dart format lib/main.dart

# Check if files need formatting (doesn't modify files)
dart format --output=none --set-exit-if-changed lib/ test/
```

### Using the Format Script

```bash
cd frontend
./format.sh
```

## Dart Style Guidelines

- **Line length**: 80 characters
- **Indentation**: 2 spaces (no tabs)
- **Quotes**: Single quotes for strings
- **Trailing commas**: Use them for better formatting
- **Imports**: Organized automatically (dart imports → package imports → relative imports)

### Example of Good Formatting

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Hello World',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
```

## Linting

The project uses strict linting rules defined in `analysis_options.yaml`.

### Check for Issues

```bash
# Analyze all files
flutter analyze

# Auto-fix issues
dart fix --apply
```

## Common Issues

### Issue: "Format on save not working"

**Solution:**

1. Ensure Dart extension is installed and enabled
2. Reload VS Code/Cursor window
3. Check that `.vscode/settings.json` exists
4. Verify you're editing a `.dart` file

### Issue: "Line too long" warnings

**Solution:**
Break long lines at logical points:

```dart
// Bad
final myLongVariable = SomeWidget(parameter1: value1, parameter2: value2, parameter3: value3);

// Good
final myLongVariable = SomeWidget(
  parameter1: value1,
  parameter2: value2,
  parameter3: value3,
);
```

### Issue: "Import order is wrong"

**Solution:**
Save the file - imports are automatically organized on save.

## Resources

- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Code Formatting](https://docs.flutter.dev/development/tools/formatting)
- [Dart Format Tool](https://dart.dev/tools/dart-format)

## Summary

✅ All Dart files have been formatted
✅ Auto-formatting is configured
✅ Linting rules are in place
✅ Format script is available
✅ Documentation is complete

**Remember**: Use `dart format`, not Prettier! 🎯
