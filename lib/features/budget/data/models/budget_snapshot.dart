import 'package:hive/hive.dart';
import 'package:finance_app/features/budget/data/models/budget_models.dart';
import 'package:finance_app/features/transactions/data/models/transaction_model.dart';

part 'budget_snapshot.g.dart';

@HiveType(typeId: 10)
class BudgetMonthSnapshot extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime month; // First day of the budget period

  @HiveField(2)
  final String? activePlanId;

  @HiveField(3)
  final String? activePlanName;

  @HiveField(4)
  final Map<String, double> plannedAllocations; // Category type -> planned amount

  @HiveField(5)
  final Map<String, double> actualSpending; // Category type -> actual amount

  @HiveField(6)
  final double totalIncome;

  @HiveField(7)
  final double totalExpenses;

  @HiveField(8)
  final double totalSavings;

  @HiveField(9)
  final double totalInvestments;

  @HiveField(10)
  final DateTime periodStart;

  @HiveField(11)
  final DateTime periodEnd;

  BudgetMonthSnapshot({
    required this.id,
    required this.month,
    this.activePlanId,
    this.activePlanName,
    required this.plannedAllocations,
    required this.actualSpending,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalSavings,
    required this.totalInvestments,
    required this.periodStart,
    required this.periodEnd,
  });

  // Calculate how well savings goal was met
  double get savingsVariance => totalSavings - (plannedAllocations['Savings'] ?? 0);
  bool get metSavingsGoal => totalSavings >= (plannedAllocations['Savings'] ?? 0);

  // Calculate how well investment goal was met
  double get investmentVariance => totalInvestments - (plannedAllocations['Investment'] ?? 0);
  bool get metInvestmentGoal => totalInvestments >= (plannedAllocations['Investment'] ?? 0);

  // Calculate expense variance (negative is good - spent less than planned)
  double get expenseVariance => totalExpenses - (plannedAllocations['Mandatory'] ?? 0) - (plannedAllocations['Variable'] ?? 0) - (plannedAllocations['Lifestyle'] ?? 0);
  bool get metExpenseGoal => totalExpenses <= (plannedAllocations['Mandatory'] ?? 0) + (plannedAllocations['Variable'] ?? 0) + (plannedAllocations['Lifestyle'] ?? 0);

  // Overall performance score (0-10)
  double get performanceScore {
    double score = 5.0; // Start neutral

    // Savings score (40% weight)
    if (plannedAllocations['Savings'] != null && plannedAllocations['Savings']! > 0) {
      final savingsRatio = totalSavings / plannedAllocations['Savings']!;
      score += (savingsRatio - 1.0) * 2.0; // +2 points per 100% over goal
    }

    // Investment score (30% weight)
    if (plannedAllocations['Investment'] != null && plannedAllocations['Investment']! > 0) {
      final investmentRatio = totalInvestments / (plannedAllocations['Investment']! + 0.01);
      score += (investmentRatio - 1.0) * 1.5;
    }

    // Expense control score (30% weight)
    final totalPlannedExpenses = (plannedAllocations['Mandatory'] ?? 0) + 
                                  (plannedAllocations['Variable'] ?? 0) + 
                                  (plannedAllocations['Lifestyle'] ?? 0);
    if (totalPlannedExpenses > 0) {
      final expenseRatio = totalExpenses / totalPlannedExpenses;
      score += (1.0 - expenseRatio) * 1.5; // Lower expenses = better score
    }

    return score.clamp(0.0, 10.0);
  }

  // Factory constructor to create from current month data
  factory BudgetMonthSnapshot.fromCurrentMonth({
    required DateTime month,
    required DateTime periodStart,
    required DateTime periodEnd,
    BudgetPlan? activePlan,
    required List<TransactionModel> transactions,
  }) {
    // Calculate actuals from transactions
    final income = transactions
        .where((t) => t.type == 'income')
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final expenses = transactions
        .where((t) => t.type == 'expense')
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final savings = transactions
        .where((t) => t.type == 'savings')
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final investments = transactions
        .where((t) => t.type == 'investment')
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    // Group actual spending by category type
    final Map<String, double> actualSpending = {
      'Income': income,
      'Expense': expenses,
      'Savings': savings,
      'Investment': investments,
    };

    return BudgetMonthSnapshot(
      id: '${month.year}-${month.month.toString().padLeft(2, '0')}',
      month: month,
      activePlanId: activePlan?.id,
      activePlanName: activePlan?.name,
      plannedAllocations: activePlan?.allocations ?? {},
      actualSpending: actualSpending,
      totalIncome: income,
      totalExpenses: expenses,
      totalSavings: savings,
      totalInvestments: investments,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'month': month.toIso8601String(),
      'activePlanId': activePlanId,
      'activePlanName': activePlanName,
      'plannedAllocations': plannedAllocations,
      'actualSpending': actualSpending,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'totalSavings': totalSavings,
      'totalInvestments': totalInvestments,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }

  factory BudgetMonthSnapshot.fromMap(Map<String, dynamic> map) {
    return BudgetMonthSnapshot(
      id: map['id'],
      month: DateTime.parse(map['month']),
      activePlanId: map['activePlanId'],
      activePlanName: map['activePlanName'],
      plannedAllocations: Map<String, double>.from(map['plannedAllocations'] ?? {}),
      actualSpending: Map<String, double>.from(map['actualSpending'] ?? {}),
      totalIncome: map['totalIncome']?.toDouble() ?? 0.0,
      totalExpenses: map['totalExpenses']?.toDouble() ?? 0.0,
      totalSavings: map['totalSavings']?.toDouble() ?? 0.0,
      totalInvestments: map['totalInvestments']?.toDouble() ?? 0.0,
      periodStart: DateTime.parse(map['periodStart']),
      periodEnd: DateTime.parse(map['periodEnd']),
    );
  }
}
