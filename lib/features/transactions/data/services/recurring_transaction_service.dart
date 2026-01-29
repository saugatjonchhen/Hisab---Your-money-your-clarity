import 'package:finance_app/features/transactions/data/models/transaction_model.dart';
import 'package:finance_app/features/transactions/data/repositories/recurring_transaction_repository.dart';
import 'package:finance_app/features/transactions/data/repositories/transaction_repository.dart';
import 'package:finance_app/core/services/notification_service.dart';
import 'package:finance_app/core/utils/string_extensions.dart';

class RecurringTransactionService {
  final RecurringTransactionRepository recurringRepository;
  final TransactionRepository transactionRepository;

  RecurringTransactionService({
    required this.recurringRepository,
    required this.transactionRepository,
  });

  Future<void> processRecurringTransactions() async {
    final recurringList = await recurringRepository.getRecurringTransactions();
    final now = DateTime.now();

    for (var recurring in recurringList) {
      if (!recurring.isActive) continue;

      DateTime lastRun = recurring.lastGeneratedDate ?? 
          recurring.startDate.subtract(const Duration(seconds: 1));
      
      DateTime nextRun = _calculateNextRun(lastRun, recurring.frequency, recurring.startDate);

      bool updated = false;
      while (nextRun.isBefore(now) || _isSameDay(nextRun, now)) {
        // Generate transaction
        final transaction = TransactionModel.create(
          amount: recurring.amount,
          note: recurring.note,
          date: nextRun,
          type: recurring.type,
          categoryId: recurring.categoryId,
        );
        
        await transactionRepository.addTransaction(transaction);
        
        lastRun = nextRun;
        nextRun = _calculateNextRun(lastRun, recurring.frequency, recurring.startDate);
        updated = true;
      }

      if (updated) {
        final updatedRecurring = recurring.copyWith(lastGeneratedDate: lastRun);
        await recurringRepository.updateRecurringTransaction(updatedRecurring);
      }
    }
  }

  Future<void> scheduleUpcomingAlerts(bool enabled) async {
    if (!enabled) {
      // If disabled, we could cancel all recurring IDs, but for now we just skip
      return;
    }

    final recurringList = await recurringRepository.getRecurringTransactions();
    for (var recurring in recurringList) {
      if (!recurring.isActive) continue;

      final lastRun = recurring.lastGeneratedDate ?? 
          recurring.startDate.subtract(const Duration(seconds: 1));
      
      final nextOccurrence = _calculateNextRun(lastRun, recurring.frequency, recurring.startDate);
      
      // Schedule 24h before
      final notificationDate = nextOccurrence.subtract(const Duration(hours: 24));
      
      // Only schedule if it's in the future
      if (notificationDate.isAfter(DateTime.now())) {
        await NotificationService().scheduleNotification(
          id: recurring.id.hashCode,
          title: 'Upcoming ${recurring.type.capitalize}: ${recurring.note}',
          body: 'Your recurring ${recurring.type} of ${recurring.amount.toStringAsFixed(2)} is due tomorrow.',
          scheduledDate: notificationDate,
        );
      }
    }
  }

  DateTime _calculateNextRun(DateTime lastRun, String frequency, DateTime originalStartDate) {
    switch (frequency) {
      case 'daily':
        return lastRun.add(const Duration(days: 1));
      case 'weekly':
        return lastRun.add(const Duration(days: 7));
      case 'monthly':
        // Handle monthly increment properly (e.g. 31st to 30th/28th)
        int year = lastRun.year;
        int month = lastRun.month + 1;
        if (month > 12) {
          month = 1;
          year++;
        }
        // Try to keep the same day as original start date, but cap at end of month
        int day = originalStartDate.day;
        int lastDayOfMonth = DateTime(year, month + 1, 0).day;
        if (day > lastDayOfMonth) {
          day = lastDayOfMonth;
        }
        return DateTime(year, month, day, originalStartDate.hour, originalStartDate.minute, originalStartDate.second);
      case 'yearly':
        int year = lastRun.year + 1;
        int month = originalStartDate.month;
        int day = originalStartDate.day;
        int lastDayOfMonth = DateTime(year, month + 1, 0).day;
        if (day > lastDayOfMonth) {
          day = lastDayOfMonth;
        }
        return DateTime(year, month, day, originalStartDate.hour, originalStartDate.minute, originalStartDate.second);
      default:
        return lastRun.add(const Duration(days: 30)); // fallback
    }
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
