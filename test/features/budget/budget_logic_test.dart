import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/features/budget/domain/engine/budget_engine.dart';
import 'package:finance_app/features/budget/data/models/budget_models.dart';

void main() {
  group('Budget Calculation & Mapping Tests', () {
    late BudgetQuestionnaire input;

    setUp(() {
      input = BudgetQuestionnaire(
        primaryIncome: 96000,
        secondaryIncome: 0,
        incomeFrequency: 'monthly',
        fixedExpenses: {
          'emi': 33000,
          'utilities': 6000,
        },
        variableExpenses: {
          'food': 5000,
          'transport': 5000,
          'entertainment': 5000,
        },
        savesMoney: true,
        desiredSavings: 12000, // For Zero-Based, it tries to respect this
        emergencyFundGoalMonths: 6,
        investsMoney: true,
        preferredInvestments: ['Stocks'],
        riskPreference: 'Medium',
        priorityOrder: ['Saving', 'Investing'],
        lifestyleFlexibility: 'Medium',
      );
    });

    final plansToTest = {
      'balanced': 'Balanced Budget',
      'high_savings': 'High Savings & Investment',
      'debt_focused': 'Debt-Focused Plan',
      'zero_based': 'Zero-Based Budget',
      'flexible': 'Flexible Lifestyle Plan',
    };

    plansToTest.forEach((planId, description) {
      test('Plan: $planId - $description (Missing EMI Category)', () {
        final plans = BudgetEngine.generatePlans(input);
        final plan = plans.firstWhere((p) => p.id == planId);

        // Simulated Categories (No EMI)
        final categories = [
          {
            'id': '1',
            'name': 'Bills',
            'type': 'expense'
          }, // Matches 'utilities'
          {'id': '2', 'name': 'Food', 'type': 'expense'},
          {'id': '3', 'name': 'Transport', 'type': 'expense'},
        ];

        // Pools from plan
        final variablePool = (plan.allocations['Variable'] ?? 0) +
            (plan.allocations['Lifestyle'] ?? 0);
        final debtPool = (plan.allocations['Debt'] ?? 0);

        // Weight calculation
        final expenseWeights = <String, double>{};
        double totalVariableWeight = 0.0;
        final categoriesByFixedKey = <String, List<String>>{};

        for (var cat in categories) {
          final name = cat['name']!.toLowerCase();
          if (cat['type'] == 'expense') {
            String? matchedKey;
            if (name.contains('utility') || name.contains('bill'))
              matchedKey = 'utilities';

            if (matchedKey != null) {
              categoriesByFixedKey
                  .putIfAbsent(matchedKey, () => [])
                  .add(cat['id']!);
            } else {
              double weight = 5;
              if (name.contains('food'))
                weight = 30;
              else if (name.contains('transport')) weight = 15;
              expenseWeights[cat['id']!] = weight;
              totalVariableWeight += weight;
            }
          }
        }

        // Allocation Steps
        final finalAllocations = <String, double>{};
        categoriesByFixedKey.forEach((key, ids) {
          final totalForKey = input.fixedExpenses[key] ?? 0;
          for (var id in ids) finalAllocations[id] = totalForKey / ids.length;
        });

        final results = <String, double>{};
        for (var cat in categories) {
          double limit = 0;
          final id = cat['id']!;
          if (finalAllocations.containsKey(id)) {
            limit = finalAllocations[id]!;
          } else {
            limit = variablePool * (expenseWeights[id]! / totalVariableWeight);
          }
          results[cat['name']!] = limit;
        }

        print('--- Results for $planId ---');
        print('Variable Pool: $variablePool, Debt Pool: $debtPool');
        results.forEach((name, limit) => print('$name: $limit'));

        // Check 1: Variable pool is accurately split between variable categories
        final variableSum = results['Food']! + results['Transport']!;
        if (variablePool > 0) {
          expect(variableSum, closeTo(variablePool, 0.01));
        }

        // Check 2: Unallocated funds should match the sum of pools that have no matching categories
        final totalAllocatedInCategories =
            results.values.fold(0.0, (sum, val) => sum + val);
        final planTotal =
            plan.allocations.values.fold(0.0, (sum, v) => sum + v);
        final unallocatedActual = planTotal - totalAllocatedInCategories;

        // Expected Unallocated = (Unmatched Mandatory) + (Savings Pool) + (Debt Pool if no EMI cat)
        final unmatchedMandatory = 33000.0; // 33k EMI
        final savingsPool = plan.allocations['Savings'] ?? 0.0;
        final unallocatedDebt = plan.allocations['Debt'] ?? 0.0;

        final expectedUnallocated =
            unmatchedMandatory + savingsPool + unallocatedDebt;

        expect(unallocatedActual, closeTo(expectedUnallocated, 0.01),
            reason:
                'Unallocated funds for $planId must include unmatched EMI ($unmatchedMandatory), '
                'Savings Pool ($savingsPool), and Debt Repayment Pool ($unallocatedDebt)');

        print('Expected Unallocated for $planId: $expectedUnallocated');
        print('Actual Unallocated: $unallocatedActual');
      });
    });
  });
}
