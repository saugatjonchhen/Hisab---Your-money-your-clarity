import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:finance_app/features/transactions/data/models/transaction_model.dart';
import 'package:finance_app/features/transactions/data/providers/transaction_provider.dart';
import 'package:finance_app/features/transactions/data/providers/category_provider.dart';
import 'package:finance_app/features/transactions/data/models/category_model.dart';
import 'package:finance_app/features/budget/presentation/providers/budget_providers.dart';
import 'package:finance_app/features/budget/presentation/providers/budget_history_providers.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';

// Re-export common math providers to keep symbols consistent
export 'package:finance_app/features/transactions/data/providers/transaction_provider.dart'
    show
        totalWealthProvider,
        totalSavingsProvider,
        totalInvestmentProvider,
        totalBalanceProvider,
        totalIncomeProvider,
        totalExpenseProvider;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_providers.g.dart';

@riverpod
bool isBackupOutOfSync(IsBackupOutOfSyncRef ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.maybeWhen(
    data: (settings) {
      if (kIsWeb) return false;

      // ALWAYS show banner if auto-backup is disabled (Mandatory requirement)
      if (!settings.autoBackupEnabled) return true;

      // If it failed recently, it's out of sync
      if (settings.lastBackupFailed) return true;

      // If it's the first run, it will trigger in splash, so we wait
      // but if splash failed or finished and no backup exists, it's out of sync
      if (settings.lastBackupTime == null) return true;

      final now = DateTime.now();
      return now.difference(settings.lastBackupTime!).inHours >= 24;
    },
    orElse: () => false,
  );
}

enum DashboardViewMode { daily, weekly, monthly, yearly }

@riverpod
class DashboardDate extends _$DashboardDate {
  @override
  DateTime build() {
    return DateTime.now();
  }

  void setDate(DateTime date) {
    state = date;
  }

  void previousDay() {
    state = state.subtract(const Duration(days: 1));
  }

  void nextDay() {
    state = state.add(const Duration(days: 1));
  }
}

@riverpod
class DashboardViewModeState extends _$DashboardViewModeState {
  @override
  DashboardViewMode build() {
    return DashboardViewMode.daily;
  }

  void setMode(DashboardViewMode mode) {
    state = mode;
  }
}

@riverpod
Future<List<TransactionModel>> filteredTransactions(
    FilteredTransactionsRef ref) async {
  final transactions = await ref.watch(transactionsListProvider.future);
  final selectedDate = ref.watch(dashboardDateProvider);
  final viewMode = ref.watch(dashboardViewModeStateProvider);

  return transactions.where((t) {
    if (viewMode == DashboardViewMode.daily) {
      return t.date.year == selectedDate.year &&
          t.date.month == selectedDate.month &&
          t.date.day == selectedDate.day;
    }
    // For weekly/monthly we might want different logic or just return all for the stats page to handle
    // But for now, let's keep it strictly for the dashboard daily view logic as requested
    // If we want to support weekly/monthly on the dashboard itself, we can add logic here.
    // However, the request said "dive deeper into new page", so likely the dashboard stays daily.
    // Let's assume this filtered provider is primarily for the main dashboard which is daily.

    return t.date.year == selectedDate.year &&
        t.date.month == selectedDate.month &&
        t.date.day == selectedDate.day;
  }).toList();
}

@riverpod
Future<double> liquidCash(LiquidCashRef ref) async {
  // Use the standardized balance as the source for actual liquid cash
  return ref.watch(totalBalanceProvider.future);
}

@riverpod
Future<BreakingDownSpending> spendingBreakdown(SpendingBreakdownRef ref) async {
  final transactions = await ref.watch(transactionsListProvider.future);
  final activePlan = ref.watch(activeBudgetPlanProvider);
  final categories = await ref.watch(categoriesListProvider.future);
  final period = await ref.watch(currentBudgetPeriodProvider.future);

  if (activePlan == null || activePlan.id == 'empty') {
    return BreakingDownSpending(0, 0, 0, 0);
  }

  // 1. Calculate Committed Spent (Strictly Mandatory/Debt categories)
  double committedSpent = 0;
  double otherSpent = 0;

  for (var t in transactions) {
    if (t.type == 'expense' && period.contains(t.date)) {
      final category = categories.firstWhere((c) => c.id == t.categoryId,
          orElse: () => CategoryModel(
              id: '', name: '', iconParams: '', colorValue: 0, type: ''));

      bool isCommitted = false;
      if (category.id.isNotEmpty) {
        final type = category.type.toLowerCase();
        if (type == 'mandatory' || type == 'debt') {
          isCommitted = true;
        }
      }

      if (isCommitted) {
        committedSpent += t.amount;
      } else {
        otherSpent += t.amount;
      }
    }
  }

  // 2. Calculate Total Reserved (Planned)
  final plannedMandatory = (activePlan.allocations['Mandatory'] ?? 0) +
      (activePlan.allocations['Debt'] ?? 0);

  // 3. Calculate Remaining Reserved
  final remainingReserved =
      (plannedMandatory - committedSpent).clamp(0.0, double.infinity);

  return BreakingDownSpending(
      plannedMandatory, committedSpent, otherSpent, remainingReserved);
}

class BreakingDownSpending {
  final double totalReserved;
  final double reservedSpent;
  final double otherSpent;
  final double remainingReserved;

  BreakingDownSpending(this.totalReserved, this.reservedSpent, this.otherSpent,
      this.remainingReserved);
}

@riverpod
Future<double> remainingCommittedExpenses(
    RemainingCommittedExpensesRef ref) async {
  final breakdown = await ref.watch(spendingBreakdownProvider.future);
  return breakdown.remainingReserved;
}

@riverpod
Future<double> filteredBalance(FilteredBalanceRef ref) async {
  final double cash = await ref.watch(liquidCashProvider.future);
  final double remainingCommitted =
      await ref.watch(remainingCommittedExpensesProvider.future);

  // Spendable Balance = Liquid Cash - Remaining Committed Expenses
  return cash - remainingCommitted;
}

@riverpod
Future<double> wealthBalance(WealthBalanceRef ref) async {
  return ref.watch(totalWealthProvider.future);
}

@riverpod
Future<double> filteredIncome(FilteredIncomeRef ref) async {
  final transactions = await ref.watch(filteredTransactionsProvider.future);
  return transactions
      .where((t) => t.type == 'income')
      .fold<double>(0.0, (sum, t) => sum + t.amount);
}

@riverpod
Future<double> filteredExpense(FilteredExpenseRef ref) async {
  final transactions = await ref.watch(filteredTransactionsProvider.future);
  return transactions
      .where((t) => t.type == 'expense')
      .fold<double>(0.0, (sum, t) => sum + t.amount);
}

@riverpod
Future<double> monthlyTotalExpense(MonthlyTotalExpenseRef ref) async {
  final transactions = await ref.watch(transactionsListProvider.future);
  final period = await ref.watch(currentBudgetPeriodProvider.future);

  return transactions
      .where((t) => t.type == 'expense' && period.contains(t.date))
      .fold<double>(0.0, (sum, t) => sum + t.amount);
}

@riverpod
Future<double> filteredSavings(FilteredSavingsRef ref) async {
  final transactions = await ref.watch(filteredTransactionsProvider.future);
  return transactions
      .where((t) => t.type == 'savings')
      .fold<double>(0.0, (sum, t) => sum + t.amount);
}

@riverpod
Future<double> filteredInvestment(FilteredInvestmentRef ref) async {
  final transactions = await ref.watch(filteredTransactionsProvider.future);
  return transactions
      .where((t) => t.type == 'investment')
      .fold<double>(0.0, (sum, t) => sum + t.amount);
}

@riverpod
Future<Map<String, double>> monthlyCategorySpending(
    MonthlyCategorySpendingRef ref) async {
  final transactions = await ref.watch(transactionsListProvider.future);

  // Import budget history provider to get current budget period
  final period = await ref.watch(currentBudgetPeriodProvider.future);

  // Filter for current budget period's expenses, savings, and investments
  final periodExpenses = transactions.where((t) =>
      (t.type == 'expense' || t.type == 'savings' || t.type == 'investment') &&
      (t.date.isAfter(period.start) || t.date.isAtSameMomentAs(period.start)) &&
      (t.date.isBefore(period.end) || t.date.isAtSameMomentAs(period.end)));

  final Map<String, double> spending = {};
  for (var t in periodExpenses) {
    spending[t.categoryId] = (spending[t.categoryId] ?? 0) + t.amount;
  }

  return spending;
}

class CategoryBudgetProgress {
  final String categoryId;
  final String name;
  final String iconParams;
  final int colorValue;
  final double spent;
  final double limit;

  CategoryBudgetProgress({
    required this.categoryId,
    required this.name,
    required this.iconParams,
    required this.colorValue,
    required this.spent,
    required this.limit,
  });

  double get progress => limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
  bool get isOverBudget => spent > limit;
}

@riverpod
Future<List<CategoryBudgetProgress>> budgetProgress(
    BudgetProgressRef ref) async {
  final categories = await ref.watch(categoriesListProvider.future);
  final spending = await ref.watch(monthlyCategorySpendingProvider.future);

  return categories
      .where((c) => c.budgetLimit > 0 || (spending[c.id] ?? 0.0) > 0)
      .map((c) => CategoryBudgetProgress(
            categoryId: c.id,
            name: c.name,
            iconParams: c.iconParams,
            colorValue: c.colorValue,
            spent: spending[c.id] ?? 0.0,
            limit: c.budgetLimit,
          ))
      .toList();
}

class TransactionTypeGroup {
  final String type;
  final List<CategoryBudgetProgress> categories;
  final double totalLimit;
  final double totalSpent;

  TransactionTypeGroup({
    required this.type,
    required this.categories,
    required this.totalLimit,
    required this.totalSpent,
  });

  double get progress =>
      totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;
  bool get isOverBudget => totalSpent > totalLimit;
}

@riverpod
Future<List<TransactionTypeGroup>> budgetProgressByType(
    BudgetProgressByTypeRef ref) async {
  final categories = await ref.watch(categoriesListProvider.future);
  final spending = await ref.watch(monthlyCategorySpendingProvider.future);

  // Group categories by type
  final Map<String, List<CategoryBudgetProgress>> groupedByType = {};

  for (var category in categories) {
    if (category.budgetLimit > 0 || (spending[category.id] ?? 0.0) > 0) {
      final progress = CategoryBudgetProgress(
        categoryId: category.id,
        name: category.name,
        iconParams: category.iconParams,
        colorValue: category.colorValue,
        spent: spending[category.id] ?? 0.0,
        limit: category.budgetLimit,
      );

      final normalizedType = category.type.toLowerCase().trim();
      if (!groupedByType.containsKey(normalizedType)) {
        groupedByType[normalizedType] = [];
      }
      groupedByType[normalizedType]!.add(progress);
    }
  }

  // Final Step: Merge and ensure unique category IDs
  final Map<String, TransactionTypeGroup> mergedGroups = {};

  for (var entry in groupedByType.entries) {
    final type = entry.key;
    final categories = entry.value;

    // Sort and unique categories within the group
    final uniqueCats = <String, CategoryBudgetProgress>{};
    for (var cat in categories) {
      uniqueCats[cat.categoryId] = cat;
    }
    final finalCategories = uniqueCats.values.toList();

    final totalLimit =
        finalCategories.fold<double>(0.0, (sum, cat) => sum + cat.limit);
    final totalSpent =
        finalCategories.fold<double>(0.0, (sum, cat) => sum + cat.spent);

    if (mergedGroups.containsKey(type)) {
      final existing = mergedGroups[type]!;
      // Merge unique categories from both
      final allCatsMap = {for (var c in existing.categories) c.categoryId: c};
      for (var c in finalCategories) {
        allCatsMap[c.categoryId] = c;
      }
      final mergedUniqueCats = allCatsMap.values.toList();

      mergedGroups[type] = TransactionTypeGroup(
        type: type,
        categories: mergedUniqueCats,
        totalLimit:
            mergedUniqueCats.fold<double>(0.0, (sum, c) => sum + c.limit),
        totalSpent:
            mergedUniqueCats.fold<double>(0.0, (sum, c) => sum + c.spent),
      );
    } else {
      mergedGroups[type] = TransactionTypeGroup(
        type: type,
        categories: finalCategories,
        totalLimit: totalLimit,
        totalSpent: totalSpent,
      );
    }
  }

  // Step 3: Add 'Reserved' group if there are unallocated mandatory funds
  final activePlan = ref.watch(activeBudgetPlanProvider);
  if (activePlan != null && activePlan.id != 'empty') {
    final plannedMandatory = (activePlan.allocations['Mandatory'] ?? 0) +
        (activePlan.allocations['Debt'] ?? 0);

    // Find matched mandatory amount from categories
    double matchedMandatory = 0;
    for (var cat in categories) {
      if (cat.type == 'expense' || cat.type == 'Mandatory') {
        final name = cat.name.toLowerCase();
        if (name.contains('emi') ||
            name.contains('loan') ||
            name.contains('rent') ||
            name.contains('house') ||
            name.contains('bill') ||
            name.contains('utility') ||
            name.contains('education') ||
            name.contains('school')) {
          matchedMandatory += cat.budgetLimit;
        }
      }
    }

    final unallocated =
        (plannedMandatory - matchedMandatory).clamp(0.0, double.infinity);
    if (unallocated > 1.0) {
      // Only show if significant (> Rs. 1)
      // For unallocated mandatory funds, we calculate "spent" by looking for
      // keywords in transactions that are NOT associated with a budget-matched category
      final transactions = await ref.watch(transactionsListProvider.future);
      final now = DateTime.now();

      double unallocatedSpent = 0.0;
      final mandatoryKeywords = [
        'emi',
        'loan',
        'debt',
        'repayment',
        'mortgage',
        'rent',
        'utility',
        'bill'
      ];

      for (var t in transactions) {
        if (t.type == 'expense' &&
            t.date.year == now.year &&
            t.date.month == now.month) {
          // Check if this transaction's category is already matched above
          final tCategory = categories.firstWhere((c) => c.id == t.categoryId,
              orElse: () => CategoryModel(
                  id: '', name: '', iconParams: '', colorValue: 0, type: ''));

          // A category is "matched" if it's already explicitly budget-tracked or
          // if it's one of the keywords but has a NON-ZERO limit (meaning it's handled in its own group).
          // If it has a ZERO limit but matches keywords, it should be captured in 'Reserved' pool.

          final isExplicitlyBudgeted = tCategory.budgetLimit > 0;
          final isMandatoryKeyword = tCategory.id.isNotEmpty &&
              (tCategory.name.toLowerCase().contains('emi') ||
                  tCategory.name.toLowerCase().contains('loan') ||
                  tCategory.name.toLowerCase().contains('rent'));

          if (!isExplicitlyBudgeted) {
            // If not explicitly budgeted, check if it's a mandatory category by name OR has keyword in note
            final noteLower = t.note.toLowerCase();
            final isReservedMatch = isMandatoryKeyword ||
                mandatoryKeywords.any((kw) => noteLower.contains(kw));

            if (isReservedMatch) {
              unallocatedSpent += t.amount;
            }
          }
        }
      }

      final reservedProgress = CategoryBudgetProgress(
        categoryId: 'reserved_funds',
        name: 'Uncategorized Bills/EMI',
        iconParams: 'lock_outline_rounded',
        colorValue: Colors.grey.shade600.value,
        spent: unallocatedSpent,
        limit: unallocated,
      );

      const reservedType = 'reserved';
      if (!mergedGroups.containsKey(reservedType)) {
        mergedGroups[reservedType] = TransactionTypeGroup(
          type: reservedType,
          categories: [reservedProgress],
          totalLimit: unallocated,
          totalSpent: unallocatedSpent,
        );
      }
    }
  }

  final List<TransactionTypeGroup> groups = mergedGroups.values.toList();

  // Sort by type priority: expense, reserved, income, savings, investment
  final typePriority = {
    'expense': 0,
    'reserved': 1,
    'income': 2,
    'savings': 3,
    'investment': 4
  };
  groups.sort((a, b) =>
      (typePriority[a.type] ?? 99).compareTo(typePriority[b.type] ?? 99));

  return groups;
}
