import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:finance_app/core/utils/csv_exporter.dart';
import 'package:finance_app/core/utils/pdf_exporter.dart';
import 'package:finance_app/features/transactions/data/models/transaction_model.dart';
import 'package:finance_app/features/transactions/data/models/category_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ReportService {
  static Future<void> exportTransactions({
    required List<TransactionModel> transactions,
    required List<CategoryModel> categories,
    required String format,
    required String currencySymbol,
    required String rangeTitle,
  }) async {
    try {
      if (format.toUpperCase() == 'CSV') {
        final csvData = CsvExporter.transactionsToCsv(
          transactions: transactions,
          categories: categories,
        );

        final directory = await getTemporaryDirectory();
        final file = File(
            "${directory.path}/hisab_report_${DateTime.now().millisecondsSinceEpoch}.csv");
        await file.writeAsString(csvData);

        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Hisab Transaction Report - $rangeTitle',
        );
      } else if (format.toUpperCase() == 'PDF') {
        final file = await PdfExporter.generateTransactionsPdf(
          transactions: transactions,
          categories: categories,
          title: 'Hisab Transaction Report - $rangeTitle',
          currencySymbol: currencySymbol,
        );

        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Hisab Transaction Report - $rangeTitle',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Export Error: $e");
      }
      rethrow;
    }
  }
}
