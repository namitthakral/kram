#!/bin/bash

# Build Flutter web app and copy to backend for deployment
# This script builds the Flutter frontend for web and copies it to the backend's public folder

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
BACKEND_DIR="$PROJECT_ROOT/backend"
OUTPUT_DIR="$BACKEND_DIR/public/dashboard"

echo "🔨 Building Flutter web app..."
echo "   Frontend: $FRONTEND_DIR"
echo "   Output: $OUTPUT_DIR"

# Navigate to frontend directory
cd "$FRONTEND_DIR"

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Build Flutter web with base-href for /dashboard
echo "🌐 Building Flutter for web..."
flutter build web --release --base-href "/" --dart-define=BASE_URL=https://api.kramedu.in

# Create output directory if it doesn't exist
echo "📁 Preparing output directory..."
mkdir -p "$OUTPUT_DIR"

# Remove old build if exists
rm -rf "$OUTPUT_DIR"/*

# Copy build to backend public folder
echo "📋 Copying build to backend..."
cp -r build/web/* "$OUTPUT_DIR/"

echo "✅ Flutter web build complete!"
echo "   Build location: $OUTPUT_DIR"
echo ""
echo "   To test locally, run the backend and visit:"
echo "   http://localhost:3000/dashboard"
