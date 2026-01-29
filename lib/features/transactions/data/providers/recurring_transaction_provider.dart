import 'package:finance_app/features/transactions/data/models/recurring_transaction_model.dart';
import 'package:finance_app/features/transactions/data/repositories/recurring_transaction_repository.dart';
import 'package:finance_app/features/transactions/data/providers/transaction_provider.dart';
import 'package:finance_app/features/transactions/data/services/recurring_transaction_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recurring_transaction_provider.g.dart';

@riverpod
RecurringTransactionRepository recurringTransactionRepository(RecurringTransactionRepositoryRef ref) {
  return RecurringTransactionRepository();
}

@riverpod
RecurringTransactionService recurringTransactionService(RecurringTransactionServiceRef ref) {
  final recurringRepo = ref.watch(recurringTransactionRepositoryProvider);
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  return RecurringTransactionService(
    recurringRepository: recurringRepo,
    transactionRepository: transactionRepo,
  );
}

@riverpod
class RecurringTransactionsList extends _$RecurringTransactionsList {
  @override
  Future<List<RecurringTransactionModel>> build() async {
    final repository = ref.watch(recurringTransactionRepositoryProvider);
    return repository.getRecurringTransactions();
  }

  Future<void> addRecurringTransaction({
    required double amount,
    required String note,
    required String type,
    required String categoryId,
    required String frequency,
    required DateTime startDate,
  }) async {
    final repository = ref.read(recurringTransactionRepositoryProvider);
    final recurring = RecurringTransactionModel.create(
      amount: amount,
      note: note,
      type: type,
      categoryId: categoryId,
      frequency: frequency,
      startDate: startDate,
    );
    await repository.addRecurringTransaction(recurring);
    ref.invalidateSelf();
  }

  Future<void> updateRecurringTransaction(RecurringTransactionModel recurring) async {
    final repository = ref.read(recurringTransactionRepositoryProvider);
    await repository.updateRecurringTransaction(recurring);
    ref.invalidateSelf();
  }

  Future<void> toggleActive(RecurringTransactionModel recurring) async {
    final repository = ref.read(recurringTransactionRepositoryProvider);
    final updated = recurring.copyWith(isActive: !recurring.isActive);
    await repository.updateRecurringTransaction(updated);
    ref.invalidateSelf();
  }

  Future<void> deleteRecurringTransaction(String id) async {
    final repository = ref.read(recurringTransactionRepositoryProvider);
    await repository.deleteRecurringTransaction(id);
    ref.invalidateSelf();
  }
}
