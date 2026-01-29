import 'package:finance_app/features/transactions/data/models/transaction_model.dart';

List<TransactionModel> getMockEmiTransactions() {
  final now = DateTime.now();
  return [
    TransactionModel(
      id: '1',
      amount: 15000,
      note: 'Home Loan EMI',
      date: DateTime(now.year, now.month, 5),
      type: 'expense',
      categoryId: 'uncategorized',
    ),
    TransactionModel(
      id: '2',
      amount: 5000,
      note: 'Car Loan repayment',
      date: DateTime(now.year, now.month, 10),
      type: 'expense',
      categoryId: 'uncategorized',
    ),
    TransactionModel(
      id: '3',
      amount: 2000,
      note: 'Electricity Bill',
      date: DateTime(now.year, now.month, 15),
      type: 'expense',
      categoryId: 'uncategorized',
    ),
    TransactionModel(
      id: '4',
      amount: 1000,
      note: 'Groceries',
      date: DateTime(now.year, now.month, 20),
      type: 'expense',
      categoryId: 'uncategorized',
    ),
  ];
}
