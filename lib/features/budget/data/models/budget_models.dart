import 'package:hive/hive.dart';

part 'budget_models.g.dart';

@HiveType(typeId: 2)
class BudgetQuestionnaire extends HiveObject {
  @HiveField(0)
  final double primaryIncome;

  @HiveField(1)
  final double secondaryIncome;

  @HiveField(2)
  final String incomeFrequency; // 'monthly', 'irregular'

  @HiveField(3)
  final Map<String, double> fixedExpenses; // rent, emi, utilities, etc.

  @HiveField(4)
  final Map<String, double> variableExpenses; // food, transport, etc.

  @HiveField(5)
  final bool savesMoney;

  @HiveField(6)
  final double desiredSavings; // amount or percentage handled in logic

  @HiveField(7)
  final int emergencyFundGoalMonths;

  @HiveField(8)
  final bool investsMoney;

  @HiveField(9)
  final List<String> preferredInvestments;

  @HiveField(10)
  final String riskPreference; // 'Low', 'Medium', 'High'

  @HiveField(11)
  final List<String> priorityOrder; // ['Saving', 'Investing', ...]

  @HiveField(12)
  final String lifestyleFlexibility; // 'Low', 'Medium', 'High'

  BudgetQuestionnaire({
    required this.primaryIncome,
    required this.secondaryIncome,
    required this.incomeFrequency,
    required this.fixedExpenses,
    required this.variableExpenses,
    required this.savesMoney,
    required this.desiredSavings,
    required this.emergencyFundGoalMonths,
    required this.investsMoney,
    required this.preferredInvestments,
    required this.riskPreference,
    required this.priorityOrder,
    required this.lifestyleFlexibility,
  });

  double get totalIncome => primaryIncome + secondaryIncome;

  Map<String, dynamic> toMap() {
    return {
      'primaryIncome': primaryIncome,
      'secondaryIncome': secondaryIncome,
      'incomeFrequency': incomeFrequency,
      'fixedExpenses': fixedExpenses,
      'variableExpenses': variableExpenses,
      'savesMoney': savesMoney,
      'desiredSavings': desiredSavings,
      'emergencyFundGoalMonths': emergencyFundGoalMonths,
      'investsMoney': investsMoney,
      'preferredInvestments': preferredInvestments,
      'riskPreference': riskPreference,
      'priorityOrder': priorityOrder,
      'lifestyleFlexibility': lifestyleFlexibility,
    };
  }

  factory BudgetQuestionnaire.fromMap(Map<String, dynamic> map) {
    return BudgetQuestionnaire(
      primaryIncome: map['primaryIncome']?.toDouble() ?? 0.0,
      secondaryIncome: map['secondaryIncome']?.toDouble() ?? 0.0,
      incomeFrequency: map['incomeFrequency'],
      fixedExpenses: Map<String, double>.from(map['fixedExpenses'] ?? {}),
      variableExpenses: Map<String, double>.from(map['variableExpenses'] ?? {}),
      savesMoney: map['savesMoney'] ?? false,
      desiredSavings: map['desiredSavings']?.toDouble() ?? 0.0,
      emergencyFundGoalMonths: map['emergencyFundGoalMonths']?.toInt() ?? 0,
      investsMoney: map['investsMoney'] ?? false,
      preferredInvestments: List<String>.from(map['preferredInvestments'] ?? []),
      riskPreference: map['riskPreference'],
      priorityOrder: List<String>.from(map['priorityOrder'] ?? []),
      lifestyleFlexibility: map['lifestyleFlexibility'],
    );
  }
}

@HiveType(typeId: 3)
class BudgetPlan extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String bestFor;

  @HiveField(4)
  final Map<String, double> allocations; // Category type -> Amount

  @HiveField(5)
  final List<String> pros;

  @HiveField(6)
  final List<String> tradeOffs;

  @HiveField(7)
  final double score; // AI ranking score

  BudgetPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.bestFor,
    required this.allocations,
    required this.pros,
    required this.tradeOffs,
    this.score = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'bestFor': bestFor,
      'allocations': allocations,
      'pros': pros,
      'tradeOffs': tradeOffs,
      'score': score,
    };
  }

  factory BudgetPlan.fromMap(Map<String, dynamic> map) {
    return BudgetPlan(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      bestFor: map['bestFor'],
      allocations: Map<String, double>.from(map['allocations'] ?? {}),
      pros: List<String>.from(map['pros'] ?? []),
      tradeOffs: List<String>.from(map['tradeOffs'] ?? []),
      score: map['score']?.toDouble() ?? 0.0,
    );
  }
}
