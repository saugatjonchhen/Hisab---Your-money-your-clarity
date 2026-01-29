#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting iOS build and distribution..."

# Install dependencies
echo "📥 Getting dependencies..."
flutter pub get

# Build IPA
echo "🏗️ Building IPA..."
flutter build ipa --release --export-method ad-hoc

# Distribute to Firebase
echo "📤 Uploading to Firebase App Distribution..."
firebase appdistribution:distribute build/ios/ipa/*.ipa \
  --app "1:443723927584:ios:4f0965d6790eb0f4192c45" \
  --groups "testers" \
  --release-notes "New iOS build $(date +%Y-%m-%d\ %H:%M:%S)"

echo "✅ iOS distribution complete!"
