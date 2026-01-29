# Personal Finance Tracker App – Product & AI Design Document

## 1. Overview

This document outlines the feature set, architecture, and roadmap for a cross-platform personal finance tracking application built using Flutter. The app focuses on privacy, offline-first performance, and intelligent budgeting.

### Target Users
- Individuals managing personal finances with a focus on assets and spendable income.
- Users tracking EMIs, subscriptions, and recurring payments.
- People planning for long-term financial goals through custom budget cycles.
- Taxpayers looking for quick tax liability assessments (initially focused on Nepal).

### Goals
- **Privacy-First**: Zero bank integrations, all data resides locally on the device (Hive).
- **Intelligent Budgeting**: AI-assisted personalized budget plans via questionnaires.
- **Accurate Financial Outlook**: Distinction between total wealth (assets) and spendable balance.
- **Data Portability**: Robust backup and restore system using JSON exports.

---

## 2. Core Features (Implemented)

### 2.1 Navigation & Branding
- **Splash Screen**: Animated branding with feature highlights and initial profile checks.
- **Dynamic Theme**: Full support for Light, Dark, and System-based themes using a premium design system.

### 2.2 User Profile & Personalization
- **Initial Setup**: Personalized onboarding (Name, Age, Email, Profile Icon).
- **Profile Customization**: Update details and profile icons (Preset or File-based) anytime.

### 2.3 Comprehensive Wealth Dashboard
- **Financial Status**: Real-time tracking of "Total Wealth" (Total Assets) vs. "Spendable Balance".
- **Wealth Breakdown**: Dedicated page for analyzing asset distribution (Savings, Investments, Cash).
- **Interactive Visualizations**: Income vs. Expense donut charts and trend analysis using `fl_chart`.
- **Advanced Stats**: Detailed stats page with monthly/yearly view modes and historical comparisons.

### 2.4 Transactions & Category Management
- **Manual Logging**: Categorized entry for Income, Expense, Savings, and Investments.
- **Recurring Transactions**: Automated generation for Daily, Weekly, and Monthly schedules (EMIs, Subscriptions).
- **Category Manager**: Global management of custom categories with icons and colors.
- **Multi-Currency**: Support for multiple currencies (NPR, USD, INR, EUR, etc.) with dynamic formatting.

### 2.5 AI-Driven Budget Planning (Questionnaire Module)
- **Questionnaire**: Structured assessment of fixed commitments (EMIs, Rent), variable expenses, and savings goals.
- **Smart Plans**: Generation of personalized budget plans (Balanced, High Savings, Debt-Focused).
- **Financial Outlook**: Detailed 1-year outlook and "How it works" breakdown for budget education.
- **History & Insights**: Tracking of budget adherence and historical performance.

### 2.6 Custom Budget Cycles
- **Salary-Based Tracking**: Ability to set a custom cycle start day (e.g., 25th of the month) to align with income cycles.
- **Flexible Management**: Switch between Calendar Month and Custom Cycles anytime in Settings.

### 2.7 Tax Calculator (Region-Specific)
- **Nepal Tax Engine**: Comprehensive calculator for Nepal's FY 2081/82 (and updates).
- **Configuration Management**: View and edit tax bracket configurations directly within the app.

### 2.8 Notifications & Alarms
- **Daily Reminders**: Scheduled notifications to log daily transactions.
- **Budget Alerts**: Real-time alerts when approaching or exceeding budget category limits.
- **Upcoming Bill Reminders**: 24-hour alerts before recurring payments are due.

### 2.9 Data Security & Portability
- **Backup & Restore**: Share/Export data as JSON files and Restore them to move between devices.

---

## 3. Technical Architecture

### Tech Stack
- **Framework**: Flutter (Android, iOS, Web)
- **State Management**: Riverpod (Notifier-based architecture for reactive data flow)
- **Persistence**: Hive (High-performance, encrypted-ready local storage)
- **Services**:
  - `NotificationService`: `flutter_local_notifications` for local scheduling.
  - `BackupService`: `file_picker` and `share_plus` for data portability.
- **UI Architecture**: Features-based folder structure (Domain-driven design).

---

## 4. Roadmap & Evolution

| Phase | Status | Key Features |
|------|--------|----------|
| **V1 (Core)** | Done | Transactions, Dashboard, AI Budget Questionnaire, Profiles |
| **V2 (Utility)** | Done | Tax Calculator, Backup/Restore, Notifications, Custom Cycles |
| **V3 (Insights)** | In-Progress | Historical Analysis, Wealth Breakdown refinement, Detailed Stats |
| **V4 (AI Path)** | Planned | Receipt OCR (Google ML Kit), automated rule-based categorization |

---

## 5. Vision
A private, intelligent, and beautifully designed companion for effortless financial mastery.
