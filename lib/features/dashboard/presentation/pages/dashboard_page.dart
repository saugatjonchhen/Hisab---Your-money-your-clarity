import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart';
import 'package:finance_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:finance_app/features/dashboard/presentation/pages/detailed_stats_page.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_app/features/transactions/data/models/category_model.dart';
import 'package:finance_app/features/transactions/data/providers/category_provider.dart';
import 'package:finance_app/features/dashboard/presentation/pages/daily_breakdown_page.dart';
import 'package:finance_app/features/dashboard/presentation/pages/wealth_breakdown_page.dart';
import 'package:finance_app/features/transactions/presentation/pages/add_transaction_page.dart';
import 'package:finance_app/features/transactions/presentation/pages/all_transactions_page.dart';
import 'package:finance_app/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:finance_app/features/profile/presentation/pages/profile_setup_page.dart';
import 'package:finance_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:finance_app/features/notifications/data/repositories/notification_repository.dart';
import 'package:finance_app/features/dashboard/presentation/widgets/budget_progress_widget.dart';
import 'package:finance_app/core/providers/navigation_provider.dart';
import 'package:finance_app/core/utils/string_extensions.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: 120,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                  left: AppValues.horizontalPadding, bottom: 16),
              title: Consumer(
                builder: (context, ref, child) {
                  final profileAsync = ref.watch(userProfileNotifierProvider);
                  final name =
                      profileAsync.valueOrNull?.fullName.split(' ').first ??
                          'User';
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $name',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleLarge?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  );
                },
              ),
              centerTitle: false,
            ),
            actions: [
              Consumer(
                builder: (context, ref, child) {
                  final notificationsAsync =
                      ref.watch(notificationsStreamProvider);
                  final unreadCount = notificationsAsync.valueOrNull
                          ?.where((n) => !n.isRead)
                          .length ??
                      0;

                  return IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppValues.gapSmall),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              size: 20),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationsPage()),
                      );
                    },
                  );
                },
              ),
              const SizedBox(width: AppValues.gapSmall),
              Consumer(
                builder: (context, ref, child) {
                  final profileAsync = ref.watch(userProfileNotifierProvider);
                  return profileAsync.when(
                    data: (profile) => IconButton(
                      icon: CircleAvatar(
                        radius: 16,
                        backgroundImage: (profile?.imagePath != null &&
                                (profile!.imagePath!.startsWith('http') ||
                                    profile.imagePath!.startsWith('blob:')))
                            ? NetworkImage(profile.imagePath!)
                            : (profile?.imagePath != null &&
                                    !kIsWeb &&
                                    !profile!.imagePath!.startsWith('icon:'))
                                ? FileImage(File(profile.imagePath!))
                                    as ImageProvider
                                : null,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.2),
                        child: (profile == null ||
                                (profile.imagePath == null ||
                                    (!profile.imagePath!.startsWith('http') &&
                                        !profile.imagePath!
                                            .startsWith('blob:') &&
                                        (kIsWeb ||
                                            profile.imagePath!
                                                .startsWith('icon:')))))
                            ? (profile?.imagePath != null &&
                                    profile!.imagePath!.startsWith('icon:'))
                                ? Icon(
                                    _getIconFromName(
                                        profile.imagePath!.substring(5)),
                                    size: 20,
                                    color: AppColors.primary)
                                : Text(
                                    profile?.fullName.initials ?? 'U',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary),
                                  )
                            : null,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileSetupPage()),
                        );
                      },
                    ),
                    loading: () => const CircleAvatar(
                        radius: 16,
                        child: SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2))),
                    error: (_, __) => IconButton(
                      icon: const CircleAvatar(
                          radius: 16,
                          child: Icon(Icons.error_outline_rounded, size: 16)),
                      onPressed: () {},
                    ),
                  );
                },
              ),
              const SizedBox(width: AppValues.horizontalPadding),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppValues.horizontalPadding,
              vertical: AppValues.verticalPadding,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Consumer(
                  builder: (context, ref, child) {
                    final balanceAsync = ref.watch(filteredBalanceProvider);
                    final wealthAsync = ref.watch(wealthBalanceProvider);
                    final monthlyExpenseAsync =
                        ref.watch(monthlyTotalExpenseProvider);

                    final settingsAsync = ref.watch(settingsProvider);
                    final currencySymbol = settingsAsync.when(
                      data: (s) => s.currencySymbol,
                      loading: () => '\$',
                      error: (_, __) => '\$',
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEmeraldHeroCard(
                          context,
                          ref,
                          balanceAsync.valueOrNull ?? 0.0,
                          wealthAsync.valueOrNull ?? 0.0,
                          monthlyExpenseAsync.valueOrNull ?? 0.0,
                          currencySymbol,
                        ),
                        const SizedBox(height: AppValues.gapLarge),
                        _buildQuickActions(context, ref),
                        const SizedBox(height: AppValues.gapLarge),
                        Consumer(
                          builder: (context, ref, child) {
                            final budgetAsync =
                                ref.watch(budgetProgressProvider);
                            return budgetAsync.when(
                              data: (budgets) {
                                if (budgets.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Monthly Budget',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: AppValues.gapSmall),
                                    BudgetProgressWidget(
                                      budgets: budgets,
                                      currencySymbol: currencySymbol,
                                    ),
                                  ],
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            );
                          },
                        ),
                        const SizedBox(height: AppValues.gapLarge),
                        _buildRecentTransactionsHeader(context),
                        const SizedBox(height: AppValues.gapMedium),
                        _buildRecentTransactionsList(context),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 100), // Space for FAB
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final selectedDate = ref.watch(dashboardDateProvider);
          return FloatingActionButton.extended(
            heroTag: 'dashboard_fab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddTransactionPage(initialDate: selectedDate)),
              );
            },
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add New'),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildRecentTransactionsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Transactions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AllTransactionsPage()),
            );
          },
          child: const Text('View All'),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsList(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final transactionsAsync = ref.watch(filteredTransactionsProvider);
        final settingsAsync = ref.watch(settingsProvider);
        final categoriesAsync = ref.watch(categoriesListProvider);

        final currencySymbol = settingsAsync.when(
          data: (settings) => settings.currencySymbol,
          loading: () => '\$',
          error: (_, __) => '\$',
        );

        final categories = categoriesAsync.valueOrNull ?? [];

        return transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 48, color: Theme.of(context).disabledColor),
                      const SizedBox(height: AppValues.gapMedium),
                      Text(
                        'No transactions for this day',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).disabledColor,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final isIncome = transaction.type == 'income';

                final category = categories.cast<CategoryModel?>().firstWhere(
                    (c) => c?.id == transaction.categoryId,
                    orElse: () => null);

                final color = category != null
                    ? Color(category.colorValue)
                    : (isIncome ? AppColors.secondary : AppColors.tertiary);
                final iconName = category?.iconParams ??
                    (isIncome ? 'arrow_downward' : 'shopping_bag_outlined');

                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(AppValues.borderRadius),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIcon(iconName, isIncome),
                        color: color,
                      ),
                    ),
                    title: Text(
                      transaction.note.isEmpty
                          ? (category?.name ?? 'Transaction')
                          : transaction.note,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      DateFormat('h:mm a').format(transaction.date),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isIncome
                            ? AppColors.secondary.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${isIncome ? '+' : '-'}$currencySymbol${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isIncome ? AppColors.secondary : Colors.red,
                        ),
                      ),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err'),
        );
      },
    );
  }

  Widget _buildEmeraldHeroCard(
      BuildContext context,
      WidgetRef ref,
      double balance,
      double wealth,
      double monthlyExpense,
      String currencySymbol) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const WealthBreakdownPage()),
          );
        },
        borderRadius: BorderRadius.circular(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Safe to Spend',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.info_outline_rounded,
                    color: Colors.white70, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$currencySymbol${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WealthBreakdownPage()),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Wealth',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$currencySymbol${wealth.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spent this Month',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$currencySymbol${monthlyExpense.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          context,
          'Add',
          Icons.add_rounded,
          AppColors.primary,
          () {
            final selectedDate = ref.read(dashboardDateProvider);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AddTransactionPage(initialDate: selectedDate)),
            );
          },
        ),
        _buildActionItem(
          context,
          'Daily',
          Icons.calendar_view_day_rounded,
          AppColors.info,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DailyBreakdownPage()),
            );
          },
        ),
        _buildActionItem(
          context,
          'Stats',
          Icons.bar_chart_rounded,
          AppColors.investment,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DetailedStatsPage()),
            );
          },
        ),
        _buildActionItem(
          context,
          'Budget',
          Icons.account_balance_wallet_rounded,
          AppColors.warning,
          () {
            ref.read(navigationProvider.notifier).setIndex(2);
          },
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconFromName(String name) {
    switch (name) {
      case 'person_rounded':
        return Icons.person_rounded;
      case 'face_rounded':
        return Icons.face_rounded;
      case 'support_agent_rounded':
        return Icons.support_agent_rounded;
      case 'psychology_rounded':
        return Icons.psychology_rounded;
      case 'engineering_rounded':
        return Icons.engineering_rounded;
      case 'pets_rounded':
        return Icons.pets_rounded;
      case 'sports_esports_rounded':
        return Icons.sports_esports_rounded;
      case 'flight_rounded':
        return Icons.flight_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  IconData _getIcon(String iconName, bool isIncome) {
    switch (iconName) {
      case 'fastfood_rounded':
        return Icons.fastfood_rounded;
      case 'directions_bus_rounded':
        return Icons.directions_bus_rounded;
      case 'shopping_bag_rounded':
        return Icons.shopping_bag_rounded;
      case 'receipt_long_rounded':
        return Icons.receipt_long_rounded;
      case 'movie_rounded':
        return Icons.movie_rounded;
      case 'work_rounded':
        return Icons.work_rounded;
      case 'arrow_downward':
        return Icons.arrow_downward;
      case 'shopping_bag_outlined':
        return Icons.shopping_bag_outlined;
      default:
        return isIncome ? Icons.arrow_downward : Icons.category_rounded;
    }
  }
}
