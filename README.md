# Personal Finance Tracker

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A private, intelligent, and beautifully designed companion for effortless financial mastery. This cross-platform application (Android, iOS, Web) helps you manage your wealth with an offline-first, privacy-centric approach.

## ✨ Key Features

### 🏦 Comprehensive Wealth Management
- **Total Wealth vs. Spendable Balance**: Distinguish between your total assets and what you actually have available to spend.
- **Wealth Breakdown**: Analyze your asset distribution across Savings, Investments, and Cash.
- **Interactive Visualizations**: Beautiful donut charts and trend analysis for income vs. expenses.

### 🤖 AI-Driven Budgeting
- **Smart Questionnaire**: Personalized budget planning based on your commitments, goals, and lifestyle.
- **Tailored Plans**: Choose from Balanced, High Savings, or Debt-Focused strategies.
- **1-Year Outlook**: See your financial trajectory with detailed monthly projections.

### 📅 Advanced Tracking
- **Custom Budget Cycles**: Align your tracking with your salary date (e.g., 25th to 25th) instead of just calendar months.
- **Recurring Transactions**: Automated logging for EMIs, subscriptions, and regular bills.
- **Category Manager**: Full control over spend categories with custom icons and colors.

### 📊 Utility & Security
- **Nepal Tax Calculator**: Built-in tax liability assessment for Nepal (FY 2081/82).
- **Offline-First (Hive)**: Your data stays on your device. Zero bank integrations for maximum privacy.
- **Backup & Restore**: Easily move your data between devices using JSON exports.
- **Smart Notifications**: Reminders for daily logging, budget breaches, and upcoming bills.

## 🛠 Tech Stack

- **Frontend**: [Flutter](https://flutter.dev)
- **State Management**: [Riverpod](https://riverpod.dev) (Notifier-based architecture)
- **Local Database**: [Hive](https://docs.hivedb.dev) (NoSQL, high performance)
- **Charts**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Notifications**: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (Latest Stable)
- Android Studio / VS Code with Flutter extensions
- CocoaPods (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/finance_app.git
   cd finance_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # Run on any connected device
   flutter run
   ```

## 🛡 Privacy & Data

This app is designed with **Privacy-First** principles.
- No data is sent to external servers.
- No mandatory login/cloud sync.
- Data portability is handled via manual JSON backups.

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.
