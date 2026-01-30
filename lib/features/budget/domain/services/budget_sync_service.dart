import 'package:finance_app/features/budget/data/models/budget_models.dart';
import 'package:finance_app/features/transactions/data/models/category_model.dart';

class BudgetSyncService {
  /// Calculates updated category limits based on the provided [plan] and [questionnaire].
  /// This implements the "Waterfall Method" or "Allocation Ratio" logic.
  static List<CategoryModel> calculateUpdatedLimits({
    required BudgetPlan plan,
    required BudgetQuestionnaire questionnaire,
    required List<CategoryModel> categories,
  }) {
    // 1. Identify active categories and assign weights
    final expenseWeights = <String, double>{};
    final savingsWeights = <String, double>{};
    double totalVariableWeight = 0.0;
    double totalSavingsWeight = 0.0;

    // Group categories by matched fixed key
    final categoriesByFixedKey = <String, List<String>>{};

    for (var category in categories) {
      final name = category.name.toLowerCase();
      double weight = 0.0;

      if (category.type == 'expense') {
        // Check if this is a known Fixed Expense from the Questionnaire
        String? matchedKey;
        if ((name.contains('emi') || name.contains('loan'))) {
          matchedKey = 'emi';
        } else if ((name.contains('rent') || name.contains('house'))) {
          matchedKey = 'rent';
        } else if (name.contains('utility') || name.contains('bill')) {
          matchedKey = 'utilities';
        } else if (name.contains('education') || name.contains('school')) {
          matchedKey = 'education';
        }

        if (matchedKey != null &&
            questionnaire.fixedExpenses.containsKey(matchedKey)) {
          // This is a fixed expense category
          if (!categoriesByFixedKey.containsKey(matchedKey)) {
            categoriesByFixedKey[matchedKey] = [];
          }
          categoriesByFixedKey[matchedKey]!.add(category.id);
        } else {
          // Variable Expense logic
          weight = 5; // Default for anything else
          if (name.contains('food') ||
              name.contains('grocery') ||
              name.contains('eat')) {
            weight = 30;
          } else if (name.contains('transport') ||
              name.contains('fuel') ||
              name.contains('auto') ||
              name.contains('cab')) {
            weight = 15;
          } else if (name.contains('health') ||
              name.contains('medical') ||
              name.contains('doc') ||
              name.contains('pharm')) {
            weight = 10;
          } else if (name.contains('shop') ||
              name.contains('mall') ||
              name.contains('cloth') ||
              name.contains('item')) {
            weight = 15;
          } else if (name.contains('ent') ||
              name.contains('fun') ||
              name.contains('movie') ||
              name.contains('sub') ||
              name.contains('ott')) {
            weight = 10;
          } else if (name.contains('bill') ||
              name.contains('utility') ||
              name.contains('recharge')) {
            weight = 10;
          }

          expenseWeights[category.id] = weight;
          totalVariableWeight += weight;
        }
      } else {
        // Savings/Investment Distribution Weights
        weight = 5; // Default
        final cName = category.name.toLowerCase();
        if (cName.contains('save') ||
            cName.contains('depo') ||
            cName.contains('fd') ||
            cName.contains('emergency') ||
            cName.contains('piggy')) {
          weight = 60;
        } else if (cName.contains('stock') ||
            cName.contains('equity') ||
            cName.contains('mutual') ||
            cName.contains('fund') ||
            cName.contains('invest') ||
            cName.contains('crypto') ||
            cName.contains('gold') ||
            cName.contains('sip')) {
          weight = 40;
        } else if (category.type == 'savings') {
          weight = 30; // Generic fallback
        } else {
          weight = 20; // Generic investment fallback
        }

        savingsWeights[category.id] = weight;
        totalSavingsWeight += weight;
      }
    }

    // 2. Distribute allocations - WATERFALL METHOD (Matches BudgetEngine Logic)
    // Unified keys: 'Mandatory', 'Variable', 'Lifestyle', 'Savings', 'Debt'

    // Step A: Define Pools
    final mandatoryFromPlan = (plan.allocations['Mandatory'] ?? 0);
    final variablePool = (plan.allocations['Variable'] ?? 0) +
        (plan.allocations['Lifestyle'] ?? 0);
    final debtPool = (plan.allocations['Debt'] ?? 0);
    final savingsPool = (plan.allocations['Savings'] ?? 0);

    // Step B: Calculate Mandatory Distributions (Strictly for matched categories)
    final finalAllocations = <String, double>{};

    categoriesByFixedKey.forEach((key, categoryIds) {
      final totalForKey = questionnaire.fixedExpenses[key] ?? 0;
      final perCategory = totalForKey / categoryIds.length;
      for (var id in categoryIds) {
        finalAllocations[id] = perCategory;
      }
    });

    // Step C: Update Categories
    final updatedCategories = <CategoryModel>[];
    for (var category in categories) {
      double newLimit = 0.0;

      if (category.type == 'expense') {
        if (finalAllocations.containsKey(category.id)) {
          // Priority 1: Mandatory Fixed Amount (Rent/EMI)
          newLimit = finalAllocations[category.id]!;

          // If this is an EMI category, also add its share of the Extra Debt Repayment
          final name = category.name.toLowerCase();
          if (name.contains('emi') || name.contains('loan')) {
            final debtCategoryIds = categoriesByFixedKey['emi'] ?? [];
            if (debtCategoryIds.isNotEmpty) {
              newLimit += debtPool / debtCategoryIds.length;
            }
          }
        } else if (totalVariableWeight > 0) {
          // Priority 2: Variable/Lifestyle Pool distribution
          final weight = expenseWeights[category.id] ?? 0;
          newLimit = variablePool * (weight / totalVariableWeight);
        }
      } else if (category.type == 'savings' || category.type == 'investment') {
        if (totalSavingsWeight > 0) {
          final weight = savingsWeights[category.id] ?? 0;
          newLimit = savingsPool * (weight / totalSavingsWeight);
        }
      }

      updatedCategories.add(CategoryModel(
        id: category.id,
        name: category.name,
        iconParams: category.iconParams,
        colorValue: category.colorValue,
        type: category.type,
        budgetLimit: newLimit,
      ));
    }

    return updatedCategories;
  }
}
