import 'dart:math';
import 'package:finance_app/features/budget/data/models/budget_models.dart';

class BudgetEngine {
  static List<BudgetPlan> generatePlans(BudgetQuestionnaire input) {
    var plans = <BudgetPlan>[];
    
    // 1. Balanced Budget (50/30/20)
    plans.add(_generateBalancedPlan(input));
    
    // 2. High Savings & Investment Plan
    plans.add(_generateHighSavingsPlan(input));
    
    // 3. Debt-Focused Plan (Only if they have debt)
    if (input.fixedExpenses.containsKey('emi') && input.fixedExpenses['emi']! > 0) {
      plans.add(_generateDebtFocusedPlan(input));
    }
    
    // 4. Zero-Based Budget
    plans.add(_generateZeroBasedPlan(input));
    
    // 5. Flexible Lifestyle Plan
    plans.add(_generateFlexiblePlan(input));
    
    // Apply dynamic scoring based on priorities
    plans = plans.map((plan) => _calculateDynamicScore(plan, input)).toList();
    
    // Sort by score (descending)
    plans.sort((a, b) => b.score.compareTo(a.score));
    
    return plans;
  }

  static BudgetPlan _calculateDynamicScore(BudgetPlan plan, BudgetQuestionnaire input) {
    double scoreAdjustment = 0.0;
    final topPriority = input.priorityOrder.isNotEmpty ? input.priorityOrder.first : '';

    // Adjust based on Priority
    if (topPriority == 'Saving' || topPriority == 'Investing') {
      if (plan.id == 'high_savings') scoreAdjustment += 0.2;
      if (plan.id == 'balanced') scoreAdjustment += 0.1;
    } else if (topPriority == 'Debt') {
      if (plan.id == 'debt_focused') scoreAdjustment += 0.3;
    } else if (topPriority == 'Spending') {
      if (plan.id == 'flexible') scoreAdjustment += 0.2;
    }

    // Adjust based on Risk Preference
    if (input.riskPreference == 'High') {
      if (plan.id == 'high_savings') scoreAdjustment += 0.1;
    } else if (input.riskPreference == 'Low') {
      if (plan.id == 'balanced' || plan.id == 'zero_based') scoreAdjustment += 0.1;
    }

    // Adjust based on Lifestyle Flexibility
    if (input.lifestyleFlexibility == 'Low') {
      if (plan.id == 'zero_based') scoreAdjustment += 0.2;
    } else if (input.lifestyleFlexibility == 'High') {
      if (plan.id == 'flexible') scoreAdjustment += 0.2;
    }

    return BudgetPlan(
      id: plan.id,
      name: plan.name,
      description: plan.description,
      bestFor: plan.bestFor,
      allocations: plan.allocations,
      pros: plan.pros,
      tradeOffs: plan.tradeOffs,
      score: (plan.score + scoreAdjustment).clamp(0.0, 1.0),
    );
  }

  static BudgetPlan _generateBalancedPlan(BudgetQuestionnaire input) {
    final income = input.totalIncome;
    final fixed = input.fixedExpenses.values.fold(0.0, (sum, val) => sum + val);
    
    // Deduct Fixed Obligations first
    final remaining = max(0.0, income - fixed);
    
    // Allocate remaining based on 50/30/20 ratio (adjusted for fixed being priority #1)
    final needsVar = remaining * 0.50; // Variable needs like food/transport
    final wants = remaining * 0.30;
    final savings = remaining * 0.20;

    return BudgetPlan(
      id: 'balanced',
      name: 'Balanced Budget',
      description: 'Prioritizes your fixed bills, then applies a stable 50/30/20 split to what remains.',
      bestFor: 'First-time budgeters & stable income users',
      allocations: {
        'Mandatory': fixed,
        'Variable': needsVar,
        'Lifestyle': wants,
        'Savings': savings,
      },
      pros: ['Easy to follow', 'Balanced lifestyle', 'Sustainable'],
      tradeOffs: ['May not pay off debt fast', 'Lower investment growth'],
      score: 0.9,
    );
  }

  static BudgetPlan _generateHighSavingsPlan(BudgetQuestionnaire input) {
    final income = input.totalIncome;
    final fixed = input.fixedExpenses.values.fold(0.0, (sum, val) => sum + val);
    
    // Deduct Fixed Obligations first
    final remaining = max(0.0, income - fixed);
    
    // Aggressive savings on remaining income
    final savings = remaining * 0.60;
    final living = remaining * 0.25;
    final wants = remaining * 0.15;

    return BudgetPlan(
      id: 'high_savings',
      name: 'High Savings & Investment',
      description: 'Mandatory bills first, then aggressively builds your wealth.',
      bestFor: 'Goal-driven users & fire enthusiasts',
      allocations: {
        'Mandatory': fixed,
        'Variable': living,
        'Savings': savings,
        'Lifestyle': wants,
      },
      pros: ['Rapid wealth building', 'Achieve goals faster'],
      tradeOffs: ['Strict lifestyle', 'Less room for fun'],
      score: 0.85,
    );
  }

  static BudgetPlan _generateDebtFocusedPlan(BudgetQuestionnaire input) {
    final income = input.totalIncome;
    final totalFixed = input.fixedExpenses.values.fold(0.0, (sum, val) => sum + val);
    
    // Deduct Fixed Obligations first (Rent, EMI, etc.)
    final remaining = max(0.0, income - totalFixed);
    
    // Aggressive Debt Repayment from remaining
    final debtExtra = remaining * 0.60; 
    final survivalSavings = remaining * 0.15; // Bare minimum buffer
    final basicLiving = remaining * 0.25; // Bare minimum living

    return BudgetPlan(
      id: 'debt_focused',
      name: 'Debt-Focused Plan',
      description: 'Clears fixed bills (EMI), then kills debt with every extra rupee.',
      bestFor: 'Users with high debt or high interest loans',
      allocations: {
        'Mandatory': totalFixed,
        'Debt': debtExtra,
        'Variable': basicLiving,
        'Savings': survivalSavings,
      },
      pros: ['Freedom from debt', 'Lower interest paid over time'],
      tradeOffs: ['Very limited spending', 'Delayed investments'],
      score: 0.95,
    );
  }

  static BudgetPlan _generateZeroBasedPlan(BudgetQuestionnaire input) {
    final income = input.totalIncome;
    final variableEstimate = input.variableExpenses.values.fold(0.0, (sum, val) => sum + val);
    final fixed = input.fixedExpenses.values.fold(0.0, (sum, val) => sum + val);
    
    // Deduct fixed first
    final afterFixed = max(0.0, income - fixed);
    
    // Respect user's variable estimate but cap it at what's left
    final variable = min(afterFixed, variableEstimate);
    final leftover = max(0.0, afterFixed - variable);
    
    return BudgetPlan(
      id: 'zero_based',
      name: 'Zero-Based Budget',
      description: 'Mandates bills first, then gives every remaining rupee a specific job.',
      bestFor: 'Detail-oriented users & expense controllers',
      allocations: {
        'Mandatory': fixed,
        'Variable': variable,
        'Savings': leftover,
      },
      pros: ['Complete control', 'No wasted money'],
      tradeOffs: ['Time-consuming to track', 'Less flexibility'],
      score: 0.8,
    );
  }

  static BudgetPlan _generateFlexiblePlan(BudgetQuestionnaire input) {
    final income = input.totalIncome;
    final fixed = input.fixedExpenses.values.fold(0.0, (sum, val) => sum + val);
    
    // Deduct fixed first - This is mandatory
    final remaining = max(0.0, income - fixed);
    
    final wants = remaining * 0.70; // Prioritize lifestyle for this plan
    final savings = remaining * 0.30;

    return BudgetPlan(
      id: 'flexible',
      name: 'Flexible Lifestyle Plan',
      description: 'Covers mandatory bills (EMIs) first, then you decide how to live.',
      bestFor: 'Freelancers & variable income earners',
      allocations: {
        'Mandatory': fixed,
        'Lifestyle': wants,
        'Savings': savings,
      },
      pros: ['Stress-free', 'Adaptable'],
      tradeOffs: ['Slower progress', 'Risk of undersaving'],
      score: 0.75,
    );
  }
}
