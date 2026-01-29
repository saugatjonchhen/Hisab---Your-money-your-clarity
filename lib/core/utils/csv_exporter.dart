import 'package:csv/csv.dart';
import 'package:finance_app/features/transactions/data/models/transaction_model.dart';
import 'package:finance_app/features/transactions/data/models/category_model.dart';
import 'package:intl/intl.dart';

class CsvExporter {
  static String transactionsToCsv({
    required List<TransactionModel> transactions,
    required List<CategoryModel> categories,
  }) {
    List<List<dynamic>> rows = [];

    // Header
    rows.add([
      'Date',
      'Time',
      'Category',
      'Type',
      'Amount',
      'Note',
    ]);

    for (var t in transactions) {
      final category = categories.cast<CategoryModel?>().firstWhere(
        (c) => c?.id == t.categoryId,
        orElse: () => null,
      );

      rows.add([
        DateFormat('yyyy-MM-dd').format(t.date),
        DateFormat('HH:mm').format(t.date),
        category?.name ?? 'Uncategorized',
        t.type.toUpperCase(),
        t.amount,
        t.note,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}
