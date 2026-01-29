import 'package:flutter/foundation.dart';
import 'package:finance_app/features/transactions/data/models/recurring_transaction_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RecurringTransactionRepository {
  static const String boxName = 'recurring_transactions';

  Future<Box<RecurringTransactionModel>> _openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<RecurringTransactionModel>(boxName);
    }
    return Hive.box<RecurringTransactionModel>(boxName);
  }

  Future<void> addRecurringTransaction(RecurringTransactionModel recurring) async {
    try {
      final box = await _openBox();
      await box.put(recurring.id, recurring);
    } catch (e) {
      debugPrint('Error adding recurring transaction: $e');
      rethrow;
    }
  }

  Future<List<RecurringTransactionModel>> getRecurringTransactions() async {
    try {
      final box = await _openBox();
      return box.values.toList();
    } catch (e) {
      debugPrint('Error getting recurring transactions: $e');
      return [];
    }
  }

  Future<void> updateRecurringTransaction(RecurringTransactionModel recurring) async {
    try {
      final box = await _openBox();
      await box.put(recurring.id, recurring);
    } catch (e) {
      debugPrint('Error updating recurring transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteRecurringTransaction(String id) async {
    try {
      final box = await _openBox();
      await box.delete(id);
    } catch (e) {
      debugPrint('Error deleting recurring transaction: $e');
      rethrow;
    }
  }
}
