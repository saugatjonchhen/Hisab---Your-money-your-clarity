#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting Android build and distribution..."

# Install dependencies
echo "📥 Getting dependencies..."
flutter pub get

# Build APK
echo "🏗️ Building APK..."
flutter build apk --release

# Distribute to Firebase
echo "📤 Uploading to Firebase App Distribution..."
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app "1:443723927584:android:a08b00b33cff325e192c45" \
  --groups "testers" \
  --release-notes "New Android build $(date +%Y-%m-%d\ %H:%M:%S)"

echo "✅ Android distribution complete!"
