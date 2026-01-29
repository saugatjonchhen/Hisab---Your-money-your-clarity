import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/features/budget/domain/services/budget_sync_service.dart';
import 'package:finance_app/features/budget/data/models/budget_models.dart';
import 'package:finance_app/features/transactions/data/models/category_model.dart';

void main() {
  group('BudgetSyncService Tests', () {
    test('calculateUpdatedLimits correctly scales variable expenses', () {
      final questionnaire = BudgetQuestionnaire(
        primaryIncome: 1000,
        secondaryIncome: 0,
        incomeFrequency: 'monthly',
        fixedExpenses: {'rent': 500},
        variableExpenses: {'food': 200},
        savesMoney: true,
        desiredSavings: 300,
        emergencyFundGoalMonths: 3,
        investsMoney: false,
        preferredInvestments: [],
        riskPreference: 'Medium',
        priorityOrder: ['Saving'],
        lifestyleFlexibility: 'Medium',
      );

      final plan = BudgetPlan(
        id: 'balanced',
        name: 'Balanced',
        description: '',
        bestFor: '',
        allocations: {
          'Mandatory': 500,
          'Variable': 250, // 500 * 0.5
          'Lifestyle': 150, // 500 * 0.3
          'Savings': 100, // 500 * 0.2
        },
        pros: [],
        tradeOffs: [],
      );

      final categories = [
        CategoryModel(id: 'c1', name: 'Rent', iconParams: '', colorValue: 0, type: 'expense'),
        CategoryModel(id: 'c2', name: 'Food', iconParams: '', colorValue: 0, type: 'expense'),
      ];

      final updated = BudgetSyncService.calculateUpdatedLimits(
        plan: plan,
        questionnaire: questionnaire,
        categories: categories,
      );

      final rent = updated.firstWhere((c) => c.name == 'Rent');
      final food = updated.firstWhere((c) => c.name == 'Food');

      expect(rent.budgetLimit, 500.0);
      expect(food.budgetLimit, 400.0); // Variable (250) + Lifestyle (150) = 400
    });

    test('calculateUpdatedLimits with extra debt repayment', () {
      final questionnaire = BudgetQuestionnaire(
        primaryIncome: 1000,
        secondaryIncome: 0,
        incomeFrequency: 'monthly',
        fixedExpenses: {'emi': 300},
        variableExpenses: {},
        savesMoney: false,
        desiredSavings: 0,
        emergencyFundGoalMonths: 0,
        investsMoney: false,
        preferredInvestments: [],
        riskPreference: 'Medium',
        priorityOrder: [],
        lifestyleFlexibility: 'Medium',
      );

      final plan = BudgetPlan(
        id: 'debt_focused',
        name: 'Debt Focused',
        description: '',
        bestFor: '',
        allocations: {
          'Mandatory': 300,
          'Debt': 420, // (1000 - 300) * 0.6
          'Variable': 175, // (1000 - 300) * 0.25
          'Savings': 105, // (1000 - 300) * 0.15
        },
        pros: [],
        tradeOffs: [],
      );

      final categories = [
        CategoryModel(id: 'c1', name: 'Loan EMI', iconParams: '', colorValue: 0, type: 'expense'),
      ];

      final updated = BudgetSyncService.calculateUpdatedLimits(
        plan: plan,
        questionnaire: questionnaire,
        categories: categories,
      );

      final emi = updated.firstWhere((c) => c.name == 'Loan EMI');
      expect(emi.budgetLimit, 300.0 + 420.0); // Fixed + Extra Debt
    });
  });
}
