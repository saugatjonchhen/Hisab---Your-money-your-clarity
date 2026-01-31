import 'package:finance_app/core/presentation/main_shell.dart';
import 'package:finance_app/core/services/analytics_service.dart';
import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/widgets/hisab_logo.dart';
import 'package:finance_app/features/transactions/data/providers/recurring_transaction_provider.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_app/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:finance_app/features/profile/presentation/pages/profile_setup_page.dart';
import 'package:finance_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:finance_app/core/services/notification_service.dart';
import 'package:finance_app/core/services/backup_service.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initial processing of recurring transactions
    _processInitialTasks();

    // Log Splash Screen
    AnalyticsService().logScreenView('Splash');

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Navigate to main app or setup after animation
    Future.delayed(const Duration(milliseconds: 3000), () async {
      if (mounted) {
        final settings = await ref.read(settingsProvider.future);
        final profile = await ref.read(userProfileNotifierProvider.future);
        final isSetupComplete = profile?.isSetupComplete ?? false;

        Widget targetPage;
        if (!settings.hasSeenOnboarding) {
          targetPage = const OnboardingPage();
        } else if (isSetupComplete) {
          targetPage = const MainShell();
        } else {
          targetPage = const ProfileSetupPage();
        }

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => targetPage,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _processInitialTasks() async {
    final recurringService = ref.read(recurringTransactionServiceProvider);
    await recurringService.processRecurringTransactions();

    final settingsAsync = await ref.read(settingsProvider.future);
    await recurringService
        .scheduleUpcomingAlerts(settingsAsync.recurringAlertsEnabled);

    // Re-schedule daily reminder if enabled to ensure it's active
    if (settingsAsync.dailyReminderEnabled) {
      debugPrint('SplashPage: Refreshing daily reminder scheduling');
      await NotificationService().scheduleDailyNotification(
        id: 100,
        title: 'Daily Expense Logging',
        body: "Don't forget to log your expenses for today!",
        hour: settingsAsync.dailyReminderTime.hour,
        minute: settingsAsync.dailyReminderTime.minute,
        payload: 'daily_reminder',
      );
    }

    // Trigger auto-backup check if not on web
    if (!kIsWeb) {
      debugPrint('SplashPage: Triggering auto-backup check');
      BackupService.checkAndPerformAutoBackup();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.backgroundDark,
                    AppColors.backgroundDark.withValues(alpha: 0.8),
                    AppColors.backgroundDark,
                  ]
                : [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.backgroundLight,
                    AppColors.secondary.withValues(alpha: 0.1),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: const HisabLogo(size: 140),
                  ),
                ),
                const SizedBox(height: 32),
                // Animated App Name
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Hisab',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1.0,
                                color:
                                    isDark ? Colors.white : AppColors.secondary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your money. Your clarity.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                    letterSpacing: 0.5,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                // Feature indicators
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeatureIcon(Icons.pie_chart_rounded, 'Analytics'),
                      const SizedBox(width: 40),
                      _buildFeatureIcon(Icons.savings_rounded, 'Budgets'),
                      const SizedBox(width: 40),
                      _buildFeatureIcon(Icons.insights_rounded, 'Insights'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark
                : AppColors.surfaceLight.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}
