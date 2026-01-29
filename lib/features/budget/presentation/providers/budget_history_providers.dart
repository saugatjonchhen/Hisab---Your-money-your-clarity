import 'package:finance_app/features/budget/data/models/budget_models.dart';
import 'package:finance_app/features/budget/data/models/budget_snapshot.dart';
import 'package:finance_app/features/budget/data/repositories/budget_snapshot_repository.dart';
import 'package:finance_app/features/budget/presentation/providers/budget_providers.dart';
import 'package:finance_app/features/transactions/data/providers/transaction_provider.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_history_providers.g.dart';

/// Get budget history snapshots
@riverpod
Future<List<BudgetMonthSnapshot>> budgetHistory(
  BudgetHistoryRef ref, {
  int months = 6,
}) async {
  final repository = BudgetSnapshotRepository();
  final allSnapshots = await repository.getAllSnapshots();
  
  final now = DateTime.now();
  final cutoffDate = DateTime(now.year, now.month - months, 1);
  
  return allSnapshots
      .where((s) => s.month.isAfter(cutoffDate) || s.month.isAtSameMomentAs(cutoffDate))
      .toList();
}

/// Get yearly budget summary
@riverpod
Future<Map<String, double>> yearlyBudgetSummary(
  YearlyBudgetSummaryRef ref,
  int year,
) async {
  final repository = BudgetSnapshotRepository();
  final snapshots = await repository.getSnapshotsForYear(year);
  
  double totalIncome = 0;
  double totalExpenses = 0;
  double totalSavings = 0;
  double totalInvestments = 0;
  
  for (var snapshot in snapshots) {
    totalIncome += snapshot.totalIncome;
    totalExpenses += snapshot.totalExpenses;
    totalSavings += snapshot.totalSavings;
    totalInvestments += snapshot.totalInvestments;
  }
  
  return {
    'income': totalIncome,
    'expenses': totalExpenses,
    'savings': totalSavings,
    'investments': totalInvestments,
  };
}

/// Calculate budget period start and end dates
class BudgetPeriod {
  final DateTime start;
  final DateTime end;
  
  BudgetPeriod(this.start, this.end);
  
  bool contains(DateTime date) {
    return (date.isAfter(start) || date.isAtSameMomentAs(start)) &&
           (date.isBefore(end) || date.isAtSameMomentAs(end));
  }
}

/// Get current budget period based on settings
@riverpod
Future<BudgetPeriod> currentBudgetPeriod(CurrentBudgetPeriodRef ref) async {
  final settings = await ref.watch(settingsProvider.future);
  final now = DateTime.now();
  
  if (settings.budgetCycleType == BudgetCycleType.calendar) {
    // Calendar month: 1st to last day of month
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return BudgetPeriod(start, end);
  } else {
    // Custom cycle based on start day
    final startDay = settings.customCycleStartDay;
    
    // Determine if we're before or after the cycle day this month
    DateTime start;
    DateTime end;
    
    if (now.day >= startDay) {
      // We're in the current cycle (startDay of this month to startDay-1 of next month)
      start = DateTime(now.year, now.month, startDay);
      end = DateTime(now.year, now.month + 1, startDay - 1, 23, 59, 59);
    } else {
      // We're in the previous cycle (startDay of last month to startDay-1 of this month)
      start = DateTime(now.year, now.month - 1, startDay);
      end = DateTime(now.year, now.month, startDay - 1, 23, 59, 59);
    }
    
    return BudgetPeriod(start, end);
  }
}

/// Snapshot generator - creates monthly snapshots automatically
@riverpod
class BudgetSnapshotGenerator extends _$BudgetSnapshotGenerator {
  @override
  Future<void> build() async {
    // Auto-generate snapshot if needed
    await generateSnapshotIfNeeded();
  }
  
  Future<void> generateSnapshotIfNeeded() async {
    final repository = BudgetSnapshotRepository();
    final latest = await repository.getLatestSnapshot();
    final period = await ref.read(currentBudgetPeriodProvider.future);
    
    // Check if we need to create a snapshot for the previous period
    final now = DateTime.now();
    
    if (latest == null) {
      // No snapshots exist, create one for last month
      await _createSnapshotForPreviousPeriod();
    } else {
      // Check if latest snapshot is from a previous period
      if (!period.contains(latest.month)) {
        // Current period is different from latest snapshot, create new one
        await _createSnapshotForPreviousPeriod();
      }
    }
  }
  
  Future<void> _createSnapshotForPreviousPeriod() async {
    final repository = BudgetSnapshotRepository();
    final settings = await ref.read(settingsProvider.future);
    final transactions = await ref.read(transactionsListProvider.future);
    final activePlan = ref.read(activeBudgetPlanProvider);
    
    // Calculate previous period dates
    final period = await ref.read(currentBudgetPeriodProvider.future);
    final previousPeriodEnd = period.start.subtract(const Duration(days: 1));
    
    DateTime previousPeriodStart;
    if (settings.budgetCycleType == BudgetCycleType.calendar) {
      previousPeriodStart = DateTime(previousPeriodEnd.year, previousPeriodEnd.month, 1);
    } else {
      final startDay = settings.customCycleStartDay;
      previousPeriodStart = DateTime(previousPeriodEnd.year, previousPeriodEnd.month, startDay);
    }
    
    // Filter transactions for the previous period
    final periodTransactions = transactions.where((t) {
      return (t.date.isAfter(previousPeriodStart) || t.date.isAtSameMomentAs(previousPeriodStart)) &&
             (t.date.isBefore(previousPeriodEnd) || t.date.isAtSameMomentAs(previousPeriodEnd));
    }).toList();
    
    // Create snapshot
    final snapshot = BudgetMonthSnapshot.fromCurrentMonth(
      month: previousPeriodStart,
      periodStart: previousPeriodStart,
      periodEnd: previousPeriodEnd,
      activePlan: activePlan,
      transactions: periodTransactions,
    );
    
    await repository.saveSnapshot(snapshot);
  }
  
  /// Manually create snapshot for current period (useful for testing or manual triggers)
  Future<void> createCurrentSnapshot() async {
    final repository = BudgetSnapshotRepository();
    final transactions = await ref.read(transactionsListProvider.future);
    final activePlan = ref.read(activeBudgetPlanProvider);
    final period = await ref.read(currentBudgetPeriodProvider.future);
    
    // Filter transactions for current period
    final periodTransactions = transactions.where((t) {
      return period.contains(t.date);
    }).toList();
    
    // Create snapshot
    final snapshot = BudgetMonthSnapshot.fromCurrentMonth(
      month: period.start,
      periodStart: period.start,
      periodEnd: period.end,
      activePlan: activePlan,
      transactions: periodTransactions,
    );
    
    await repository.saveSnapshot(snapshot);
  }
}
