import 'package:finance_app/features/settings/data/repositories/settings_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finance_app/core/services/backup_service.dart';
import 'package:finance_app/core/services/notification_service.dart';

part 'settings_provider.g.dart';

enum BudgetCycleType { calendar, custom }

class SettingsState {
  final ThemeMode themeMode;
  final String currency;
  final bool dailyReminderEnabled;
  final TimeOfDay dailyReminderTime;
  final bool budgetAlertsEnabled;
  final bool recurringAlertsEnabled;
  final BudgetCycleType budgetCycleType;
  final int customCycleStartDay; // 1-31, day of month to start budget cycle
  final bool hasSeenOnboarding;
  final bool autoBackupEnabled;
  final DateTime? lastBackupTime;
  final bool lastBackupFailed;

  SettingsState({
    required this.themeMode,
    required this.currency,
    required this.dailyReminderEnabled,
    required this.dailyReminderTime,
    required this.budgetAlertsEnabled,
    required this.recurringAlertsEnabled,
    this.budgetCycleType = BudgetCycleType.calendar,
    this.customCycleStartDay = 1,
    required this.hasSeenOnboarding,
    this.autoBackupEnabled = true,
    this.lastBackupTime,
    this.lastBackupFailed = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? currency,
    bool? dailyReminderEnabled,
    TimeOfDay? dailyReminderTime,
    bool? budgetAlertsEnabled,
    bool? recurringAlertsEnabled,
    BudgetCycleType? budgetCycleType,
    int? customCycleStartDay,
    bool? hasSeenOnboarding,
    bool? autoBackupEnabled,
    DateTime? lastBackupTime,
    bool? lastBackupFailed,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      budgetAlertsEnabled: budgetAlertsEnabled ?? this.budgetAlertsEnabled,
      recurringAlertsEnabled:
          recurringAlertsEnabled ?? this.recurringAlertsEnabled,
      budgetCycleType: budgetCycleType ?? this.budgetCycleType,
      customCycleStartDay: customCycleStartDay ?? this.customCycleStartDay,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      lastBackupFailed: lastBackupFailed ?? this.lastBackupFailed,
    );
  }

  String get currencySymbol {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'INR':
        return '₹';
      case 'NPR':
        return 'Rs.';
      default:
        return 'UNKNOWN';
    }
  }
}

@riverpod
class Settings extends _$Settings {
  @override
  Future<SettingsState> build() async {
    final repository = SettingsRepository();
    final theme = await repository.getThemeMode();
    final currency = await repository.getCurrency();
    final dailyReminder = await repository.getDailyReminder();
    final dailyReminderTime = await repository.getDailyReminderTime();
    final budgetAlerts = await repository.getBudgetAlerts();
    final recurringAlerts = await repository.getRecurringAlerts();
    final budgetCycleType = await repository.getBudgetCycleType();
    final customCycleStartDay = await repository.getCustomCycleStartDay();
    final hasSeenOnboarding = await repository.getHasSeenOnboarding();
    final autoBackupEnabled = await repository.getAutoBackupEnabled();
    final lastBackupTime = await repository.getLastBackupTime();
    final lastBackupFailed = await repository.getLastBackupFailed();

    return SettingsState(
      themeMode: theme,
      currency: currency,
      dailyReminderEnabled: dailyReminder,
      dailyReminderTime: dailyReminderTime,
      budgetAlertsEnabled: budgetAlerts,
      recurringAlertsEnabled: recurringAlerts,
      budgetCycleType: budgetCycleType,
      customCycleStartDay: customCycleStartDay,
      hasSeenOnboarding: hasSeenOnboarding,
      autoBackupEnabled: autoBackupEnabled,
      lastBackupTime: lastBackupTime,
      lastBackupFailed: lastBackupFailed,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = SettingsRepository();
      await repository.saveThemeMode(mode);
      final current = state.value!;
      return current.copyWith(themeMode: mode);
    });
  }

  Future<void> setCurrency(String currency) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = SettingsRepository();
      await repository.saveCurrency(currency);
      final current = state.value!;
      return current.copyWith(currency: currency);
    });
  }

  Future<void> setDailyReminder(bool enabled) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = SettingsRepository();
      await repository.saveDailyReminder(enabled);
      final current = state.value!;
      return current.copyWith(dailyReminderEnabled: enabled);
    });
  }

  Future<void> setDailyReminderTime(TimeOfDay time) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = SettingsRepository();
      await repository.saveDailyReminderTime(time.hour, time.minute);
      final current = state.value!;
      return current.copyWith(dailyReminderTime: time);
    });
  }

  Future<void> setBudgetAlerts(bool enabled) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = SettingsRepository();
      await repository.saveBudgetAlerts(enabled);
      final current = state.value!;
      return current.copyWith(budgetAlertsEnabled: enabled);
    });
  }

  Future<void> setRecurringAlerts(bool enabled) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = SettingsRepository();
      await repository.saveRecurringAlerts(enabled);
      final current = state.value!;
      return current.copyWith(recurringAlertsEnabled: enabled);
    });
  }

  Future<void> setBudgetCycleType(BudgetCycleType type) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = SettingsRepository();
      await repository.saveBudgetCycleType(type);
      final current = state.value!;
      return current.copyWith(budgetCycleType: type);
    });
  }

  Future<void> setCustomCycleStartDay(int day) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = SettingsRepository();
      await repository.saveCustomCycleStartDay(day);
      final current = state.value!;
      return current.copyWith(customCycleStartDay: day);
    });
  }

  Future<void> setHasSeenOnboarding(bool hasSeen) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = SettingsRepository();
      await repository.saveHasSeenOnboarding(hasSeen);
      final current = state.value!;
      return current.copyWith(hasSeenOnboarding: hasSeen);
    });
  }

  Future<void> setAutoBackupEnabled(bool enabled) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = SettingsRepository();
      await repository.saveAutoBackupEnabled(enabled);
      final current = state.value!;
      return current.copyWith(autoBackupEnabled: enabled);
    });
  }

  Future<void> updateLastBackupTime(DateTime time) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = SettingsRepository();
      await repository.saveLastBackupTime(time);
      final current = state.value!;
      return current.copyWith(lastBackupTime: time, lastBackupFailed: false);
    });
  }

  Future<void> setLastBackupFailed(bool failed) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = SettingsRepository();
      await repository.saveLastBackupFailed(failed);
      final current = state.value!;
      return current.copyWith(lastBackupFailed: failed);
    });
  }

  Future<void> checkAndPerformAutoBackup() async {
    // Skip on web as it requires user interaction for file saving
    if (kIsWeb) return;

    final current = state.valueOrNull;
    if (current == null) return;

    // 1. Check if feature is enabled
    if (!current.autoBackupEnabled) return;

    // 2. Check if 24 hours have passed since last backup
    final lastBackup = current.lastBackupTime;
    final now = DateTime.now();

    if (lastBackup == null || now.difference(lastBackup).inHours >= 24) {
      // Perform backup
      debugPrint('SettingsProvider: Starting auto-backup...');
      try {
        await BackupService.createPersistentBackup();

        // Update last backup time and reset failure status
        await updateLastBackupTime(now);

        // Show success notification
        await NotificationService().showNotification(
          id: 200,
          title: 'Backup Complete',
          body: 'Your data has been backed up successfully.',
          payload: 'backup_success',
        );
        debugPrint('SettingsProvider: Auto-backup complete.');
      } catch (e) {
        debugPrint('SettingsProvider: Auto-backup failed: $e');
        await setLastBackupFailed(true);

        // Show failure notification
        await NotificationService().showNotification(
          id: 201,
          title: 'Backup Failed',
          body: 'Automatic backup failed. Please check your storage.',
          payload: 'backup_failed',
        );
      }
    }
  }
}
