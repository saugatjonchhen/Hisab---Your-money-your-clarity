import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart';
import 'package:finance_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:finance_app/features/dashboard/presentation/widgets/daily_breakdown_chart.dart';
import 'package:finance_app/features/dashboard/presentation/widgets/date_selector.dart';
import 'package:finance_app/features/transactions/data/models/category_model.dart';
import 'package:finance_app/features/transactions/data/providers/category_provider.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DailyBreakdownPage extends ConsumerWidget {
  const DailyBreakdownPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(filteredTransactionsProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);
    final selectedDate = ref.watch(dashboardDateProvider);
    
    final currencySymbol = settingsAsync.when(
      data: (settings) => settings.currencySymbol,
      loading: () => '\$',
      error: (_, __) => '\$',
    );
    
    final categories = categoriesAsync.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Breakdown'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppValues.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: DateSelector()),
            const SizedBox(height: AppValues.gapLarge),
            transactionsAsync.when(
              data: (transactions) => Column(
                children: [
                  DailyBreakdownChart(transactions: transactions),
                  const SizedBox(height: AppValues.gapLarge),
                  _buildTransactionList(context, transactions, categories, currencySymbol),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, __) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context, 
    List transactions, 
    List<CategoryModel> categories, 
    String currencySymbol
  ) {
    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: 48, color: Theme.of(context).disabledColor),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transactions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppValues.gapMedium),
        ListView.separated(
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
              orElse: () => null
            );
            
            final color = category != null ? Color(category.colorValue) : (isIncome ? AppColors.secondary : AppColors.tertiary);
            final iconName = category?.iconParams ?? (isIncome ? 'arrow_downward' : 'shopping_bag_outlined');

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(AppValues.borderRadius),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
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
                  transaction.note.isEmpty ? (category?.name ?? 'Transaction') : transaction.note,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  DateFormat('h:mm a').format(transaction.date),
                ),
                trailing: Text(
                  '${isIncome ? '+' : '-'}$currencySymbol${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isIncome ? AppColors.secondary : AppColors.tertiary,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getIcon(String iconName, bool isIncome) {
    switch (iconName) {
      case 'fastfood_rounded': return Icons.fastfood_rounded;
      case 'directions_bus_rounded': return Icons.directions_bus_rounded;
      case 'shopping_bag_rounded': return Icons.shopping_bag_rounded;
      case 'receipt_long_rounded': return Icons.receipt_long_rounded;
      case 'movie_rounded': return Icons.movie_rounded;
      case 'work_rounded': return Icons.work_rounded;
      case 'arrow_downward': return Icons.arrow_downward;
      case 'shopping_bag_outlined': return Icons.shopping_bag_outlined;
      default: return isIncome ? Icons.arrow_downward : Icons.category_rounded;
    }
  }
}
