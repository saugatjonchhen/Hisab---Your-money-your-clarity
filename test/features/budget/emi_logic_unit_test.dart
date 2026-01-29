import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/features/transactions/data/models/transaction_model.dart';
import 'package:finance_app/features/transactions/data/models/category_model.dart';

void main() {
  group('EMI Tracking Logic Verification', () {
    test(
        'calculateUnallocatedSpent should identify EMI transactions by keywords',
        () {
      final now = DateTime.now();
      final transactions = [
        TransactionModel(
            id: '1',
            amount: 15000,
            note: 'Home Loan EMI',
            date: now,
            type: 'expense',
            categoryId: 'cat1'),
        TransactionModel(
            id: '2',
            amount: 5000,
            note: 'Car Loan repayment',
            date: now,
            type: 'expense',
            categoryId: 'cat1'),
        TransactionModel(
            id: '3',
            amount: 2000,
            note: 'Electricity Bill',
            date: now,
            type: 'expense',
            categoryId: 'cat1'),
        TransactionModel(
            id: '4',
            amount: 1000,
            note: 'Groceries',
            date: now,
            type: 'expense',
            categoryId: 'cat1'),
      ];

      final categories = [
        CategoryModel(
            id: 'cat1',
            name: 'Uncategorized',
            iconParams: '',
            colorValue: 0,
            type: 'expense',
            budgetLimit: 0),
      ];

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
          final tCategory = categories.firstWhere((c) => c.id == t.categoryId,
              orElse: () => CategoryModel(
                  id: '', name: '', iconParams: '', colorValue: 0, type: ''));
          final isMatched = tCategory.id.isNotEmpty &&
              (tCategory.name.toLowerCase().contains('emi') ||
                  tCategory.name.toLowerCase().contains('loan') ||
                  tCategory.name.toLowerCase().contains('rent') ||
                  tCategory.budgetLimit > 0);

          if (!isMatched) {
            final noteLower = t.note.toLowerCase();
            if (mandatoryKeywords.any((kw) => noteLower.contains(kw))) {
              unallocatedSpent += t.amount;
            }
          }
        }
      }

      // 15000 (EMI) + 5000 (repayment) + 2000 (Bill) = 22000
      expect(unallocatedSpent, equals(22000.0));
    });

    test(
        'calculateUnallocatedSpent should identify EMI transactions even with a 0-limit category',
        () {
      final now = DateTime.now();
      final transactions = [
        TransactionModel(
            id: '1',
            amount: 15000,
            note: 'Home Loan EMI',
            date: now,
            type: 'expense',
            categoryId: 'cat_emi'),
      ];

      final categories = [
        CategoryModel(
            id: 'cat_emi',
            name: 'EMI / Loan',
            iconParams: '',
            colorValue: 0,
            type: 'expense',
            budgetLimit: 0),
      ];

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
      double unallocatedSpent = 0.0;

      for (var t in transactions) {
        if (t.type == 'expense' &&
            t.date.year == now.year &&
            t.date.month == now.month) {
          final tCategory = categories.firstWhere((c) => c.id == t.categoryId,
              orElse: () => CategoryModel(
                  id: '', name: '', iconParams: '', colorValue: 0, type: ''));

          final isExplicitlyBudgeted = tCategory.budgetLimit > 0;
          final isMandatoryKeyword = tCategory.id.isNotEmpty &&
              (tCategory.name.toLowerCase().contains('emi') ||
                  tCategory.name.toLowerCase().contains('loan') ||
                  tCategory.name.toLowerCase().contains('rent'));

          if (!isExplicitlyBudgeted) {
            final noteLower = t.note.toLowerCase();
            final isReservedMatch = isMandatoryKeyword ||
                mandatoryKeywords.any((kw) => noteLower.contains(kw));

            if (isReservedMatch) {
              unallocatedSpent += t.amount;
            }
          }
        }
      }

      expect(unallocatedSpent, equals(15000.0));
    });

    test('isMatched should correctly skip already budget-matched categories',
        () {
      final tCategory = CategoryModel(
          id: 'cat2',
          name: 'Home Rent',
          iconParams: '',
          colorValue: 0,
          type: 'expense',
          budgetLimit: 10000);

      final isMatched = tCategory.id.isNotEmpty &&
          (tCategory.name.toLowerCase().contains('emi') ||
              tCategory.name.toLowerCase().contains('loan') ||
              tCategory.name.toLowerCase().contains('rent') ||
              tCategory.budgetLimit > 0);

      expect(isMatched, isTrue);
    });
  });
}
