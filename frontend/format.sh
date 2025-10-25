#!/bin/bash

# Script to format all Dart files in the Flutter project
# Usage: ./format.sh

echo "🎨 Formatting Dart files..."

# Format lib directory
dart format lib/ --line-length 80

# Format test directory
dart format test/ --line-length 80

echo "✅ Formatting complete!"

