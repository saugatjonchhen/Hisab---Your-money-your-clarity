import 'package:finance_app/features/settings/data/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      budgetAlertsEnabled: budgetAlertsEnabled ?? this.budgetAlertsEnabled,
      recurringAlertsEnabled: recurringAlertsEnabled ?? this.recurringAlertsEnabled,
      budgetCycleType: budgetCycleType ?? this.budgetCycleType,
      customCycleStartDay: customCycleStartDay ?? this.customCycleStartDay,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
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
}
