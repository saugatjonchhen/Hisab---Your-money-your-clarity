# Firebase App Distribution Deployment Guide (Android + iOS)

**Purpose:**
This document is a complete instruction set for an AI agent (Google Antigravity) to configure CI/CD deployment of **Flutter Android and iOS apps** using **Firebase App Distribution**.

The goal is:
- Automatic build generation
- Automatic upload to Firebase App Distribution
- Tester invitation + distribution
- Secure environment configuration
- CI/CD-ready pipeline

---

## System Overview

### Target Platforms
- Android (.apk / .aab)
- iOS (.ipa)

### Distribution Platform
- Firebase App Distribution

### CI/CD
- Codemagic (or any CI system)

---

# Architecture Flow

```
Flutter App
   ↓
CI/CD Pipeline (Codemagic)
   ↓
Build Artifacts (APK / IPA)
   ↓
Firebase App Distribution
   ↓
Tester Email / Invite Link
   ↓
App Install
```

---

# Prerequisites

## Accounts
- Google Firebase account
- Apple Developer account
- Google Play Console account (optional)
- CI/CD account (Codemagic or equivalent)

---

# Firebase Setup

## Step 1: Create Firebase Project

1. Go to Firebase Console
2. Create new project
3. Disable analytics (optional)
4. Create project

---

## Step 2: Register Apps

### Android
- Add Android app
- Package name = applicationId
- Download `google-services.json`
- Place in `android/app/`

### iOS
- Add iOS app
- Bundle ID = iOS bundle identifier
- Download `GoogleService-Info.plist`
- Place in `ios/Runner/`

---

## Step 3: Enable Firebase App Distribution

1. Firebase Console
2. Go to **App Distribution**
3. Enable for both Android and iOS apps

---

# Android Configuration

## Build Type

### Recommended:
- `APK` for testing
- `AAB` optional

---

# iOS Configuration

## Distribution Method

### Required:
- Ad Hoc distribution

### Requirements:
- Registered tester UDIDs
- Ad Hoc provisioning profile
- Ad Hoc certificate

---

# Firebase CLI Setup

## Install CLI

```
npm install -g firebase-tools
```

## Login

```
firebase login
```

## Project Setup

```
firebase use <project-id>
```

---

# Firebase App Distribution CLI

## Android Upload

```
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app <ANDROID_FIREBASE_APP_ID> \
  --groups "testers"
```

---

## iOS Upload

```
firebase appdistribution:distribute build/ios/ipa/app.ipa \
  --app <IOS_FIREBASE_APP_ID> \
  --groups "testers"
```

---

# Tester Management

## Create Groups

- Firebase Console → App Distribution → Testers & Groups
- Create group: `testers`
- Add tester emails

---

# CI/CD ENVIRONMENT VARIABLES

```
FIREBASE_TOKEN
ANDROID_FIREBASE_APP_ID
IOS_FIREBASE_APP_ID
```

---

# Codemagic CI/CD Pipeline

## Environment Variables

- `FIREBASE_TOKEN`
- `ANDROID_FIREBASE_APP_ID`
- `IOS_FIREBASE_APP_ID`

---

# CI/CD Scripts

## Android Pipeline

```bash
flutter pub get
flutter build apk --release
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app $ANDROID_FIREBASE_APP_ID \
  --groups "testers"
```

---

## iOS Pipeline

```bash
flutter pub get
flutter build ios --release
flutter build ipa
firebase appdistribution:distribute build/ios/ipa/*.ipa \
  --app $IOS_FIREBASE_APP_ID \
  --groups "testers"
```

---

# Security Model

## Secrets Handling

- All tokens stored in CI/CD secrets
- No credentials in repo
- No plaintext keys

---

# Distribution Model

## Android
- Direct install via Firebase link

## iOS
- Ad Hoc provisioning required
- Device registration enforced
- Firebase manages install flow

---

# Scaling Strategy

- Multiple tester groups
- Versioned releases
- Automated changelog
- CI tagging
- Branch-based distribution

---

# Production Safety Rules

- No production signing keys in dev pipelines
- Separate Firebase projects for dev/staging/prod
- Separate Apple certificates

---

# Multi-Environment Strategy

| Environment | Firebase Project | Distribution |
|------|------|------|
| Dev | firebase-dev | Internal testers |
| Staging | firebase-staging | QA group |
| Prod | firebase-prod | External testers |

---

# Automation Goals

- Zero manual uploads
- Zero manual tester invites
- Auto CI trigger on merge
- Auto version tagging
- Auto distribution

---

# Success Criteria

- Build triggers on commit
- Artifacts generated
- Upload to Firebase successful
- Testers receive email
- Installable build available

---

# Final Objective

Fully automated CI/CD pipeline:

```
Git Push
 → Build
 → Test
 → Package
 → Upload
 → Distribute
 → Notify Testers
```

No manual steps.
No local builds.
No manual uploads.

---

# End of Document

