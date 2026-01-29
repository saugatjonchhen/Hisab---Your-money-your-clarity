import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart';
import 'package:finance_app/features/transactions/data/models/recurring_transaction_model.dart';
import 'package:finance_app/features/transactions/data/providers/recurring_transaction_provider.dart';
import 'package:finance_app/features/transactions/data/providers/category_provider.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_app/features/transactions/presentation/pages/add_recurring_transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class RecurringTransactionsPage extends ConsumerWidget {
  const RecurringTransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringAsync = ref.watch(recurringTransactionsListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);
    final settingsAsync = ref.watch(settingsProvider);

    final currencySymbol = settingsAsync.when(
      data: (s) => s.currencySymbol,
      loading: () => '\$',
      error: (_, __) => '\$',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Transactions'),
      ),
      body: recurringAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.repeat_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
                   const SizedBox(height: AppValues.gapMedium),
                   const Text('No recurring transactions', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: AppValues.screenPadding,
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return categoriesAsync.when(
                data: (cats) {
                  final category = cats.firstWhere(
                    (c) => c.id == transaction.categoryId,
                    orElse: () => cats.first,
                  );
                  return _buildRecurringTile(context, ref, transaction, category, currencySymbol);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddRecurringTransactionPage()),
        ),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildRecurringTile(BuildContext context, WidgetRef ref, RecurringTransactionModel item, dynamic category, String currencySymbol) {
    final color = Color(category.colorValue);

    return Card(
      margin: const EdgeInsets.only(bottom: AppValues.gapMedium),
      clipBehavior: Clip.antiAlias,
      child: Slidable(
        key: ValueKey(item.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddRecurringTransactionPage(initialRecurring: item),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: Icons.edit_outlined,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (context) => _confirmDelete(context, ref, item.id),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
              label: 'Delete',
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppValues.gapMedium,
            vertical: AppValues.gapSmall,
          ),
          leading: Container(
            padding: const EdgeInsets.all(AppValues.gapSmall),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppValues.smallRadius),
            ),
            child: Icon(_getIcon(category.iconParams), color: color, size: 24),
          ),
          title: Text(
            item.note.isNotEmpty ? item.note : category.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category?.name ?? 'No Category', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(
                '${item.frequency[0].toUpperCase()}${item.frequency.substring(1)} • Next: ${DateFormat('MMM d').format(_calculateNextDate(item))}',
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ],
          ),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.type == 'income' ? '+' : '-'}$currencySymbol${item.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: item.type == 'income' ? AppColors.secondary : AppColors.tertiary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 24,
                child: Switch.adaptive(
                  value: item.isActive,
                  onChanged: (_) => ref.read(recurringTransactionsListProvider.notifier).toggleActive(item),
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ),
          onLongPress: () => _showDeleteConfirm(context, ref, item),
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, RecurringTransactionModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recurring?'),
        content: const Text('Are you sure you want to delete this recurring transaction template?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(recurringTransactionsListProvider.notifier).deleteRecurringTransaction(item.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recurring?'),
        content: const Text('Are you sure you want to delete this recurring transaction?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(recurringTransactionsListProvider.notifier).deleteRecurringTransaction(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch(iconName) {
      case 'fastfood_rounded': return Icons.fastfood_rounded;
      case 'directions_bus_rounded': return Icons.directions_bus_rounded;
      case 'shopping_bag_rounded': return Icons.shopping_bag_rounded;
      case 'receipt_long_rounded': return Icons.receipt_long_rounded;
      case 'movie_rounded': return Icons.movie_rounded;
      case 'work_rounded': return Icons.work_rounded;
      case 'savings_rounded': return Icons.savings_rounded;
      default: return Icons.category_rounded;
    }
  }

  DateTime _calculateNextDate(RecurringTransactionModel item) {
    final lastRun = item.lastGeneratedDate ?? item.startDate.subtract(const Duration(seconds: 1));
    switch (item.frequency) {
      case 'daily': return lastRun.add(const Duration(days: 1));
      case 'weekly': return lastRun.add(const Duration(days: 7));
      case 'monthly':
        int year = lastRun.year;
        int month = lastRun.month + 1;
        if (month > 12) { month = 1; year++; }
        int lastDayOfMonth = DateTime(year, month + 1, 0).day;
        int day = item.startDate.day > lastDayOfMonth ? lastDayOfMonth : item.startDate.day;
        return DateTime(year, month, day);
      case 'yearly': return DateTime(lastRun.year + 1, lastRun.month, lastRun.day);
      default: return lastRun.add(const Duration(days: 30));
    }
  }
}
