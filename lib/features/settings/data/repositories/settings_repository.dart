import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';


class SettingsRepository {
  static const String _settingsBoxName = 'settings_box';
  static const String _themeKey = 'theme_mode';
  static const String _currencyKey = 'currency';
  static const String _dailyReminderKey = 'daily_reminder';
  static const String _dailyReminderHourKey = 'daily_reminder_hour';
  static const String _dailyReminderMinuteKey = 'daily_reminder_minute';
  static const String _budgetAlertsKey = 'budget_alerts';
  static const String _recurringAlertsKey = 'recurring_alerts';
  static const String _budgetCycleTypeKey = 'budget_cycle_type';
  static const String _customCycleStartDayKey = 'custom_cycle_start_day';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  Future<Box> _getBox() async {
    if (Hive.isBoxOpen(_settingsBoxName)) {
      return Hive.box(_settingsBoxName);
    }
    return await Hive.openBox(_settingsBoxName);
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final box = await _getBox();
    await box.put(_themeKey, mode.index);
  }

  Future<ThemeMode> getThemeMode() async {
    final box = await _getBox();
    final index = box.get(_themeKey, defaultValue: ThemeMode.system.index);
    return ThemeMode.values[index];
  }

  Future<void> saveCurrency(String currencyCode) async {
    final box = await _getBox();
    await box.put(_currencyKey, currencyCode);
  }

  Future<String> getCurrency() async {
    final box = await _getBox();
    return box.get(_currencyKey, defaultValue: 'NPR');
  }

  Future<void> saveDailyReminder(bool enabled) async {
    final box = await _getBox();
    await box.put(_dailyReminderKey, enabled);
  }

  Future<bool> getDailyReminder() async {
    final box = await _getBox();
    return box.get(_dailyReminderKey) ?? false;
  }

  Future<void> saveDailyReminderTime(int hour, int minute) async {
    final box = await _getBox();
    await box.put(_dailyReminderHourKey, hour);
    await box.put(_dailyReminderMinuteKey, minute);
  }

  Future<TimeOfDay> getDailyReminderTime() async {
    final box = await _getBox();
    final hour = box.get(_dailyReminderHourKey) ?? 20;
    final minute = box.get(_dailyReminderMinuteKey) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> saveBudgetAlerts(bool enabled) async {
    final box = await _getBox();
    await box.put(_budgetAlertsKey, enabled);
  }

  Future<bool> getBudgetAlerts() async {
    final box = await _getBox();
    return box.get(_budgetAlertsKey) ?? true;
  }

  Future<void> saveRecurringAlerts(bool enabled) async {
    final box = await _getBox();
    await box.put(_recurringAlertsKey, enabled);
  }

  Future<bool> getRecurringAlerts() async {
    final box = await _getBox();
    return box.get(_recurringAlertsKey) ?? true;
  }

  Future<void> saveBudgetCycleType(dynamic type) async {
    final box = await _getBox();
    // Store as string: 'calendar' or 'custom'
    final typeString = type.toString().split('.').last;
    await box.put(_budgetCycleTypeKey, typeString);
  }

  Future<BudgetCycleType> getBudgetCycleType() async {
    final box = await _getBox();
    final typeString = box.get(_budgetCycleTypeKey, defaultValue: 'calendar');
    return typeString == 'custom' ? BudgetCycleType.custom : BudgetCycleType.calendar;
  }

  Future<void> saveCustomCycleStartDay(int day) async {
    final box = await _getBox();
    await box.put(_customCycleStartDayKey, day.clamp(1, 31));
  }

  Future<int> getCustomCycleStartDay() async {
    final box = await _getBox();
    return box.get(_customCycleStartDayKey, defaultValue: 1);
  }

  Future<void> saveHasSeenOnboarding(bool hasSeen) async {
    final box = await _getBox();
    await box.put(_hasSeenOnboardingKey, hasSeen);
  }

  Future<bool> getHasSeenOnboarding() async {
    final box = await _getBox();
    return box.get(_hasSeenOnboardingKey, defaultValue: false);
  }
}
