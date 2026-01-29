import 'package:flutter/foundation.dart';
import 'package:finance_app/features/transactions/data/models/transaction_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TransactionRepository {
  static const String boxName = 'transactions';

  Future<Box<TransactionModel>> _openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<TransactionModel>(boxName);
    }
    return Hive.box<TransactionModel>(boxName);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final box = await _openBox();
      await box.put(transaction.id, transaction);
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final box = await _openBox();
      return box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      debugPrint('Error getting transactions: $e');
      return [];
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final box = await _openBox();
      await box.delete(id);
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      final box = await _openBox();
      await box.put(transaction.id, transaction);
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }
  
  Future<double> getTotalBalance() async {
    final transactions = await getTransactions();
    double balance = 0;
    for (var t in transactions) {
      if (t.type == 'income') {
        balance += t.amount;
      } else {
        balance -= t.amount;
      }
    }
    return balance;
  }
}
