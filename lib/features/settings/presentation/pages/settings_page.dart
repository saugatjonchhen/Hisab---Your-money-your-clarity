import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/services/backup_service.dart';
import 'package:finance_app/features/transactions/data/providers/transaction_provider.dart';
import 'package:finance_app/features/transactions/data/providers/category_provider.dart';
import 'package:finance_app/features/budget/presentation/providers/budget_providers.dart';
import 'package:finance_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:finance_app/core/services/notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:finance_app/core/utils/string_extensions.dart';
import 'package:finance_app/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:finance_app/features/profile/presentation/pages/profile_setup_page.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_app/features/settings/presentation/pages/category_manager_page.dart';
import 'package:finance_app/features/transactions/presentation/pages/recurring_transactions_page.dart';
import 'package:finance_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'dart:io' show File;
import 'package:finance_app/core/theme/app_values.dart';
import 'package:finance_app/features/settings/presentation/pages/faq_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        data: (settings) {
          return ListView(
            padding: AppValues.screenPadding,
            children: [
              _buildProfileSection(context, ref),
              const SizedBox(height: AppValues.gapLarge),
              _buildSectionHeader('Appearance'),
              _buildThemeSelector(context, ref, settings.themeMode),
              const SizedBox(height: AppValues.gapLarge),
              _buildSectionHeader('Preferences'),
              _buildCurrencySelector(context, ref, settings.currency),
              const SizedBox(height: AppValues.gapSmall),
              _buildBudgetCycleSettings(context, ref, settings),
              const SizedBox(height: AppValues.gapLarge),
              _buildSectionHeader('Notifications'),
              _buildNotificationSettings(context, ref, settings),
              const SizedBox(height: AppValues.gapLarge),
              _buildSectionHeader('Help & Info'),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                  title: const Text('Welcome Screen'),
                  subtitle: const Text('View intro and features'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OnboardingPage(isFromSettings: true),
                      ),
                    );
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
                  title: const Text('Frequently Asked Questions'),
                  subtitle: const Text('Get help with app features'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FaqPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppValues.gapLarge),
              _buildSectionHeader('Data'),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.category_rounded, color: AppColors.primary),
                    title: const Text('Manage Categories'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CategoryManagerPage()),
                      );
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.repeat_rounded, color: AppColors.primary),
                    title: const Text('Recurring Transactions'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RecurringTransactionsPage()),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppValues.gapExtraSmall, vertical: AppValues.gapSmall),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _handleBackup(context),
                          icon: const Icon(Icons.cloud_upload_rounded),
                          label: const Text('Backup Data'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppValues.gapSmall),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppValues.borderRadius)),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppValues.gapMedium),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _handleRestore(context, ref),
                          icon: const Icon(Icons.cloud_download_rounded),
                          label: const Text('Restore Data'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppValues.gapSmall),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppValues.borderRadius)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppValues.gapLarge),
                _buildSectionHeader('Danger Zone'),
                Card(
                  color: AppColors.error.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppValues.borderRadius),
                    side: BorderSide(color: AppColors.error.withValues(alpha: 0.2)),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                    title: const Text('Factory Reset', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Clear all data and start over', style: TextStyle(fontSize: 12)),
                    onTap: () => _handleFactoryReset(context, ref),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return profileAsync.when(
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.all(AppValues.gapMedium),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppValues.borderRadius),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: (profile.imagePath != null && (profile.imagePath!.startsWith('http') || profile.imagePath!.startsWith('blob:')))
                    ? NetworkImage(profile.imagePath!)
                    : (profile.imagePath != null && !kIsWeb && !profile.imagePath!.startsWith('icon:'))
                        ? FileImage(File(profile.imagePath!)) as ImageProvider
                        : null,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: (profile.imagePath == null || (!profile.imagePath!.startsWith('http') && !profile.imagePath!.startsWith('blob:') && (kIsWeb || profile.imagePath!.startsWith('icon:'))))
                    ? profile.imagePath != null && profile.imagePath!.startsWith('icon:')
                        ? Icon(_getIconFromName(profile.imagePath!.substring(5)), size: 30, color: AppColors.primary)
                        : Text(
                            profile.fullName.initials,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                          )
                    : null,
              ),
              const SizedBox(width: AppValues.gapMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${profile.age} years old • ${profile.email ?? "No email"}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileSetupPage()),
                  );
                },
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  IconData _getIconFromName(String name) {
    switch (name) {
      case 'person_rounded': return Icons.person_rounded;
      case 'face_rounded': return Icons.face_rounded;
      case 'support_agent_rounded': return Icons.support_agent_rounded;
      case 'psychology_rounded': return Icons.psychology_rounded;
      case 'engineering_rounded': return Icons.engineering_rounded;
      case 'pets_rounded': return Icons.pets_rounded;
      case 'sports_esports_rounded': return Icons.sports_esports_rounded;
      case 'flight_rounded': return Icons.flight_rounded;
      default: return Icons.person_rounded;
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppValues.gapSmall, left: AppValues.gapExtraSmall),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(
      BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    return Card(
      child: Column(
        children: [
          _buildRadioTile(
            title: 'System Default',
            value: ThemeMode.system,
            groupValue: currentMode,
            onChanged: (val) =>
                ref.read(settingsProvider.notifier).setThemeMode(val!),
          ),
          const Divider(height: 1),
          _buildRadioTile(
            title: 'Light Mode',
            value: ThemeMode.light,
            groupValue: currentMode,
            onChanged: (val) =>
                ref.read(settingsProvider.notifier).setThemeMode(val!),
          ),
          const Divider(height: 1),
          _buildRadioTile(
            title: 'Dark Mode',
            value: ThemeMode.dark,
            groupValue: currentMode,
            onChanged: (val) =>
                ref.read(settingsProvider.notifier).setThemeMode(val!),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile<T>({
    required String title,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    return RadioListTile<T>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildCurrencySelector(
      BuildContext context, WidgetRef ref, String currentCurrency) {
    final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'INR', 'NPR'];

    return Card(
      child: ListTile(
        title: const Text('Currency'),
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentCurrency,
            items: currencies.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Text(c),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                ref.read(settingsProvider.notifier).setCurrency(val);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCycleSettings(BuildContext context, WidgetRef ref, SettingsState settings) {
    return Card(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budget Cycle',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Choose when your budget period starts',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildRadioTile(
            title: 'Calendar Month (1st - Last day)',
            value: BudgetCycleType.calendar,
            groupValue: settings.budgetCycleType,
            onChanged: (val) {
              if (val != null) {
                ref.read(settingsProvider.notifier).setBudgetCycleType(val);
              }
            },
          ),
          const Divider(height: 1),
          _buildRadioTile(
            title: 'Custom Cycle (Align with salary date)',
            value: BudgetCycleType.custom,
            groupValue: settings.budgetCycleType,
            onChanged: (val) {
              if (val != null) {
                ref.read(settingsProvider.notifier).setBudgetCycleType(val);
              }
            },
          ),
          if (settings.budgetCycleType == BudgetCycleType.custom) ...[
            const Divider(height: 1),
            ListTile(
              title: const Text('Cycle Start Day'),
              subtitle: Text('Budget starts on day ${settings.customCycleStartDay} of each month'),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: settings.customCycleStartDay,
                  items: List.generate(31, (i) => i + 1).map((day) {
                    return DropdownMenuItem(
                      value: day,
                      child: Text('$day'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(settingsProvider.notifier).setCustomCycleStartDay(val);
                    }
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(BuildContext context, WidgetRef ref, SettingsState settings) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Daily Reminders'),
            subtitle: const Text('Get notified to log your daily expenses'),
            value: settings.dailyReminderEnabled,
            onChanged: (val) async {
              await ref.read(settingsProvider.notifier).setDailyReminder(val);
              if (val) {
                await NotificationService().scheduleDailyNotification(
                  id: 100,
                  title: 'Daily Expense Logging',
                  body: "Don't forget to log your expenses for today!",
                  hour: settings.dailyReminderTime.hour,
                  minute: settings.dailyReminderTime.minute,
                  payload: 'daily_reminder',
                );
              } else {
                await NotificationService().cancel(100);
              }
            },
            activeColor: AppColors.primary,
          ),
          if (settings.dailyReminderEnabled) ...[
            const Divider(height: 1),
            ListTile(
              title: const Text('Reminder Time'),
              trailing: Text(
                DateFormat.jm().format(
                  DateTime(2022, 1, 1, settings.dailyReminderTime.hour, settings.dailyReminderTime.minute),
                ),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: settings.dailyReminderTime,
                );
                if (time != null) {
                  await ref.read(settingsProvider.notifier).setDailyReminderTime(time);
                  // Reschedule with new time
                  await NotificationService().scheduleDailyNotification(
                    id: 100,
                    title: 'Daily Expense Logging',
                    body: "Don't forget to log your expenses for today!",
                    hour: time.hour,
                    minute: time.minute,
                    payload: 'daily_reminder',
                  );
                }
              },
            ),
          ],
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Budget Alerts'),
            subtitle: const Text('Get notified when you exceed budget limits'),
            value: settings.budgetAlertsEnabled,
            onChanged: (val) => ref.read(settingsProvider.notifier).setBudgetAlerts(val),
            activeColor: AppColors.primary,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Upcoming Bill Reminders'),
            subtitle: const Text('Alerts 24 hours before recurring payments'),
            value: settings.recurringAlertsEnabled,
            onChanged: (val) => ref.read(settingsProvider.notifier).setRecurringAlerts(val),
            activeColor: AppColors.primary,
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await NotificationService().testNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Test notification sent! One immediate, one in 10s.')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.notification_important_rounded),
                label: const Text('Send Test Notification'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final scheduledTime = now.add(const Duration(minutes: 1));
                  try {
                    await NotificationService().scheduleNotification(
                      id: 101,
                      title: '1-Minute Test',
                      body: 'This notification was scheduled 1 minute ago.',
                      scheduledDate: scheduledTime,
                      payload: 'daily_reminder',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Scheduled for ${DateFormat.jm().format(scheduledTime)}')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.timer_outlined),
                label: const Text('Schedule in 1 Minute'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: BorderSide(color: AppColors.secondary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBackup(BuildContext context) async {
    try {
      await BackupService.createBackup();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup shared successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data?'),
        content: const Text('This will overwrite all current app data. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (proceed != true) return;

    try {
      final success = await BackupService.restoreBackup();
      if (success) {
        // Refresh all providers
        ref.invalidate(settingsProvider);
        ref.invalidate(transactionsListProvider);
        ref.invalidate(categoriesListProvider);
        ref.invalidate(userProfileNotifierProvider);
        ref.invalidate(activeBudgetPlanProvider);
        ref.invalidate(budgetProgressProvider);
        ref.invalidate(budgetProgressByTypeProvider);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data restored successfully!')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleFactoryReset(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Fresh Start?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'This will permanently delete ALL your data including transactions, budgets, and settings.\n\nThis action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context, 'backup'),
                  icon: const Icon(Icons.cloud_upload_rounded),
                  label: const Text('Backup Data First (Recommended)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, 'delete'),
                  icon: const Icon(Icons.delete_forever_rounded),
                  label: const Text('Yes, Delete Everything'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context, 'cancel'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == 'backup') {
      if (context.mounted) {
        await _handleBackup(context);
        // Ask again or just stop? Let's just stop and let user click reset again if they want.
        // Or better, recursively call _handleFactoryReset?
        // Let's just let them click it again to be safe.
      }
      return;
    }

    if (result != 'delete') return;

    try {
      if (context.mounted) {
         // Show loading indicator
         showDialog(
           context: context,
           barrierDismissible: false,
           builder: (_) => const Center(child: CircularProgressIndicator()),
         );
      }

      await BackupService.clearAllData();
      
      // Clear Providers
      ref.invalidate(settingsProvider);
      ref.invalidate(transactionsListProvider);
      ref.invalidate(categoriesListProvider);
      ref.invalidate(userProfileNotifierProvider);
      ref.invalidate(activeBudgetPlanProvider);
      ref.invalidate(budgetProgressProvider);
      ref.invalidate(budgetProgressByTypeProvider);

      if (context.mounted) {
        // Pop loading dialog
        Navigator.pop(context); 
        
        // Navigate to Splash to restart flow
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        // Pop loading dialog if visible (it might be tricky if error happens fast, but safe enough)
        // If we want to be robust we keep a reference to the dialog or just rely on the fact that we are in a try block.
        Navigator.pop(context); // close loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reset failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
