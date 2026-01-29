import 'package:finance_app/features/transactions/data/models/transaction_model.dart';
import 'package:finance_app/features/transactions/data/repositories/transaction_repository.dart';
import 'package:finance_app/features/transactions/data/providers/category_provider.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_app/core/services/notification_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_provider.g.dart';

// Repository Provider
@riverpod
TransactionRepository transactionRepository(TransactionRepositoryRef ref) {
  return TransactionRepository();
}

// Transactions List Provider
@riverpod
class TransactionsList extends _$TransactionsList {
  @override
  Future<List<TransactionModel>> build() async {
    final repository = ref.watch(transactionRepositoryProvider);
    return repository.getTransactions();
  }

  Future<void> addTransaction({
    required double amount,
    required String note,
    required DateTime date,
    required String type,
    required String categoryId,
  }) async {
    final repository = ref.read(transactionRepositoryProvider);
    final transaction = TransactionModel.create(
      amount: amount,
      note: note,
      date: date,
      type: type,
      categoryId: categoryId,
    );
    await repository.addTransaction(transaction);
    
    // Check for budget breach
    if (type == 'expense') {
      try {
        final settings = ref.read(settingsProvider).valueOrNull;
        if (settings != null && settings.budgetAlertsEnabled) {
          final categories = await ref.read(categoriesListProvider.future);
          final category = categories.firstWhere((c) => c.id == categoryId);
          
          if (category.budgetLimit > 0) {
            final transactions = await repository.getTransactions();
            final now = DateTime.now();
            final spent = transactions
                .where((t) => t.type == 'expense' && 
                              t.categoryId == categoryId && 
                              t.date.year == now.year && 
                              t.date.month == now.month)
                .fold<double>(0.0, (sum, t) => sum + t.amount);
            
            final previousSpent = spent - amount;
            final limit = category.budgetLimit;
            
            // 80% Warning
            if (previousSpent <= (limit * 0.8) && spent > (limit * 0.8) && spent <= limit) {
               await NotificationService().showNotification(
                id: categoryId.hashCode + 1000, 
                title: 'Approaching Limit: ${category.name}',
                body: 'You have used over 80% of your budget for ${category.name}. Remaining: ${settings.currencySymbol}${(limit - spent).toStringAsFixed(2)}',
                payload: 'budget_warning_$categoryId',
              );
            }

            // 100% Breach
            if (previousSpent <= limit && spent > limit) {
              await NotificationService().showNotification(
                id: categoryId.hashCode,
                title: 'Budget Breach: ${category.name}',
                body: 'You have exceeded your monthly budget for ${category.name}. Total spent: ${settings.currencySymbol}${spent.toStringAsFixed(2)}',
                payload: 'budget_breach_$categoryId',
              );
            }
          }
        }
      } catch (e) {
        // Silently fail notification check to avoid blocking transaction add
        print('Error checking budget breach: $e');
      }
    }

    // Refresh the list
    ref.invalidateSelf();
  }

  Future<void> deleteTransaction(String id) async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.deleteTransaction(id);
    ref.invalidateSelf();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.updateTransaction(transaction);
    ref.invalidateSelf();
  }
}

// Balance Provider (Liquid Cash / Spendable Income)
@riverpod
Future<double> totalBalance(TotalBalanceRef ref) async {
  final transactions = await ref.watch(transactionsListProvider.future);
  double balance = 0;
  for (var t in transactions) {
    if (t.type == 'income') {
      balance += t.amount;
    } else {
      // Deducts expense, savings, and investment from active cash
      balance -= t.amount;
    }
  }
  return balance;
}

// Total Wealth Provider (Total Assets = Income - Expenses)
@riverpod
Future<double> totalWealth(TotalWealthRef ref) async {
  final transactions = await ref.watch(transactionsListProvider.future);
  double wealth = 0;
  for (var t in transactions) {
    if (t.type == 'income') {
      wealth += t.amount;
    } else if (t.type == 'expense') {
      wealth -= t.amount;
    }
    // Savings and Investments are internal transfers for wealth calculation
  }
  return wealth;
}

// Savings Provider
@riverpod
Future<double> totalSavings(TotalSavingsRef ref) async {
  final transactions = await ref.watch(transactionsListProvider.future);
  return transactions
      .where((t) => t.type == 'savings')
      .fold<double>(0.0, (sum, t) => sum + t.amount);
}

// Investment Provider
@riverpod
Future<double> totalInvestment(TotalInvestmentRef ref) async {
  final transactions = await ref.watch(transactionsListProvider.future);
  return transactions
      .where((t) => t.type == 'investment')
      .fold<double>(0.0, (sum, t) => sum + t.amount);
}

// Income Provider (Total all time)
@riverpod
Future<double> totalIncome(TotalIncomeRef ref) async {
  final transactions = await ref.watch(transactionsListProvider.future);
  return transactions
      .where((t) => t.type == 'income')
      .fold<double>(0.0, (sum, t) => sum + t.amount);
}

// Current Month Income Provider
@riverpod
Future<double> currentMonthIncome(CurrentMonthIncomeRef ref) async {
  final transactions = await ref.watch(transactionsListProvider.future);
  final now = DateTime.now();
  return transactions
      .where((t) => t.type == 'income' && 
                    t.date.year == now.year && 
                    t.date.month == now.month)
      .fold<double>(0.0, (sum, t) => sum + t.amount);
}

// Expense Provider
@riverpod
Future<double> totalExpense(TotalExpenseRef ref) async {
  final transactions = await ref.watch(transactionsListProvider.future);
  return transactions
      .where((t) => t.type == 'expense')
      .fold<double>(0.0, (sum, t) => sum + t.amount);
}
