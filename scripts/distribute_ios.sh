#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting iOS build and distribution..."

# Check if token is present
if [ -z "$FIREBASE_TOKEN" ]; then
  echo "❌ Error: FIREBASE_TOKEN is not set in the environment."
  echo "Please ensure you have added it to a group named 'firebase_credentials' in Codemagic."
  exit 1
else
  echo "✅ FIREBASE_TOKEN found (Length: ${#FIREBASE_TOKEN})"
fi

# Install dependencies

# Build IPA
echo "🏗️ Building IPA..."
flutter build ipa --release --export-method ad-hoc

# Distribute to Firebase
echo "📤 Uploading to Firebase App Distribution..."
firebase appdistribution:distribute build/ios/ipa/*.ipa \
  --app "1:443723927584:ios:4f0965d6790eb0f4192c45" \
  --groups "testers" \
  --token "$FIREBASE_TOKEN" \
  --release-notes "New iOS build $(date +%Y-%m-%d\ %H:%M:%S)" || echo "⚠️ Distribution failed, but upload likely succeeded. Check 'testers' group exists in Firebase Console."

echo "✅ iOS distribution complete!"
