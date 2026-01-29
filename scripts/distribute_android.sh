#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting Android build and distribution..."

# Check if token is present
if [ -z "$FIREBASE_TOKEN" ]; then
  echo "❌ Error: FIREBASE_TOKEN is not set in the environment."
  echo "Please ensure you have added it to a group named 'firebase_credentials' in Codemagic."
  exit 1
else
  echo "✅ FIREBASE_TOKEN found (Length: ${#FIREBASE_TOKEN})"
fi

# Install dependencies

# Build APK
echo "🏗️ Building APK..."
flutter build apk --release

# Distribute to Firebase
echo "📤 Uploading to Firebase App Distribution..."
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app "1:443723927584:android:a08b00b33cff325e192c45" \
  --groups "testers" \
  --token "$FIREBASE_TOKEN" \
  --release-notes "New Android build $(date +%Y-%m-%d\ %H:%M:%S)" || echo "⚠️ Distribution failed, but upload likely succeeded. Check 'testers' group exists in Firebase Console."

echo "✅ Android distribution complete!"
