import 'dart:async';
import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/services/notification_service.dart';
import 'package:finance_app/features/budget/presentation/pages/budget_page.dart';
import 'package:finance_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:finance_app/features/settings/presentation/pages/settings_page.dart';
import 'package:finance_app/features/tax_calculator/presentation/pages/tax_calculator_page.dart';
import 'package:finance_app/features/transactions/presentation/pages/all_transactions_page.dart';
import 'package:finance_app/core/providers/navigation_provider.dart';
import 'package:finance_app/core/services/analytics_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  StreamSubscription<String?>? _notificationSubscription;

  final List<Widget> _pages = const [
    DashboardPage(),
    AllTransactionsPage(),
    BudgetPage(),
    TaxCalculatorPage(),
    SettingsPage(),
  ];

  void _logTabSelection(int index) {
    final names = ['Dashboard', 'Transactions', 'Budget', 'Tax', 'Settings'];
    if (index >= 0 && index < names.length) {
      AnalyticsService().logScreenView(names[index]);
    }
  }

  @override
  void initState() {
    super.initState();
    // Log the initial tab (Dashboard)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logTabSelection(ref.read(navigationProvider));
    });

    // Listen to notification taps for navigation
    _notificationSubscription =
        NotificationService().onNotificationTapped.listen((payload) {
      if (payload != null &&
          (payload == 'backup_success' || payload == 'backup_failed')) {
        debugPrint(
            'MainShell: Navigating to Settings due to backup notification');
        ref
            .read(navigationProvider.notifier)
            .setIndex(4); // Settings is index 4
      }
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(navigationProvider.notifier).setIndex(index);
          _logTabSelection(index);
        },
        backgroundColor: Theme.of(context).cardTheme.color,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon:
                Icon(Icons.dashboard_rounded, color: AppColors.primary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon:
                Icon(Icons.receipt_long_rounded, color: AppColors.primary),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline_rounded),
            selectedIcon:
                Icon(Icons.pie_chart_rounded, color: AppColors.primary),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon:
                Icon(Icons.calculate_rounded, color: AppColors.primary),
            label: 'Tax',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon:
                Icon(Icons.settings_rounded, color: AppColors.primary),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
