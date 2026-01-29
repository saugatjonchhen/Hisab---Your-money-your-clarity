import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart';
import 'package:finance_app/features/budget/data/models/budget_models.dart';
import 'package:finance_app/features/budget/presentation/providers/budget_providers.dart';
import 'package:finance_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetAnalysisPage extends ConsumerWidget {
  const BudgetAnalysisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlan = ref.watch(activeBudgetPlanProvider);
    final questionnaire = ref.watch(budgetQuestionnaireStateProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final currency = settingsAsync.when(
      data: (s) => s.currencySymbol,
      loading: () => 'Rs.',
      error: (_, __) => 'Rs.',
    );

    if (activePlan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Budget Analysis')),
        body: const Center(child: Text('No active budget plan found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Budget Analysis & Outlook')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppValues.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlanOverview(context, activePlan),
            const SizedBox(height: AppValues.gapLarge),
            _buildYearlyProjections(context, activePlan, questionnaire, currency),
            const SizedBox(height: AppValues.gapLarge),
            _buildTransactionTypeBreakdown(context, ref, currency),
            const SizedBox(height: AppValues.gapLarge),
            _buildHumanReadableLogic(context, activePlan, questionnaire, currency),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanOverview(BuildContext context, BudgetPlan plan) {
    return Container(
      padding: const EdgeInsets.all(AppValues.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppValues.borderRadiusLarge),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 28),
              const SizedBox(width: AppValues.gapSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current Strategy', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(plan.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppValues.gapSmall),
          Text(plan.description, style: TextStyle(color: Colors.grey[800], height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildYearlyProjections(BuildContext context, BudgetPlan plan, BudgetQuestionnaire input, String currency) {
    // Calculate monthly metrics
    final monthlyFixed = input.fixedExpenses.values.fold(0.0, (sum, val) => sum + val);
    
    // Total Debt Repayment = Base EMI + Extra Repayment from the plan
    final monthlyDebtRepayment = (input.fixedExpenses['emi'] ?? 0) + (plan.allocations['Debt'] ?? 0);
    
    // Savings = Sum of all savings allocations in the plan
    final monthlySavings = (plan.allocations['Savings'] ?? 0);
    
    // Lifestyle = Everything else (Wants, Living, Discretionary)
    final monthlyWants = (plan.allocations['Lifestyle'] ?? 0) + 
                         (plan.allocations['Variable'] ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('1-Year Outlook', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppValues.gapMedium),
        Row(
          children: [
            // Fixed Costs is Rent + Utilities + etc (Excluded EMI to avoid double counting if shown in Debt)
            // But usually "Fixed Costs" includes everything.
            // Let's show "Non-Debt Fixed Costs" to be precise, OR just show Total Debt Repaid separately.
            Expanded(child: _buildProjectionCard(context, 'Total Fixed (Non-Debt)', (monthlyFixed - (input.fixedExpenses['emi'] ?? 0)) * 12, currency, Colors.orange)),
            const SizedBox(width: AppValues.gapSmall),
            Expanded(child: _buildProjectionCard(context, 'Total Savings', monthlySavings * 12, currency, Colors.green)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildProjectionCard(context, 'Total Debt Repaid', monthlyDebtRepayment * 12, currency, Colors.redAccent)),
            const SizedBox(width: 12),
            Expanded(child: _buildProjectionCard(context, 'Total Lifestyle/Wants', monthlyWants * 12, currency, Colors.blueAccent)),
          ],
        ),
        const SizedBox(height: 24),
        _buildCalculationLogic(context, input, currency),
        const SizedBox(height: 24),
        _buildFullAllocationBreakdown(context, plan, currency),
      ],
    );
  }

  Widget _buildCalculationLogic(BuildContext context, BudgetQuestionnaire input, String currency) {
    final fixedTotal = input.fixedExpenses.values.fold(0.0, (s, v) => s + v);
    final disposable = input.totalIncome - fixedTotal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Projection Calculation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          _buildLogicRow('Monthly Total Income', '$currency${input.totalIncome.toStringAsFixed(0)}'),
          _buildLogicRow('(-) Mandatory Fixed Costs', '- $currency${fixedTotal.toStringAsFixed(0)}', isNegative: true),
          const Divider(),
          _buildLogicRow('Disposable Monthly Income', '$currency${disposable.toStringAsFixed(0)}', isBold: true),
          _buildLogicRow('Yearly Multiplier', 'x 12 Months'),
          const Divider(),
          _buildLogicRow('Estimated Yearly Potential (Gross)', '$currency${(input.totalIncome * 12).toStringAsFixed(0)}', isBold: true),
        ],
      ),
    );
  }

  Widget _buildFullAllocationBreakdown(BuildContext context, BudgetPlan plan, String currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Monthly Allocation Detail', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Exactly where every rupee is going each month:', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: plan.allocations.entries.map((entry) {
              final isLast = entry.key == plan.allocations.keys.last;
              return Column(
                children: [
                  ListTile(
                    title: Text(entry.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: Text('$currency${entry.value.toStringAsFixed(0)}', 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    dense: true,
                  ),
                  if (!isLast) Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.withValues(alpha: 0.1)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLogicRow(String label, String value, {bool isNegative = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: isBold ? Colors.black : Colors.grey[700], fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(
            fontSize: 13, 
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isNegative ? Colors.red : (isBold ? Colors.black : Colors.grey[800]),
          )),
        ],
      ),
    );
  }

  Widget _buildProjectionCard(BuildContext context, String title, double amount, String currency, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('$currency${amount.toStringAsFixed(0)}', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ),
          const SizedBox(height: 4),
          const Text('1-year potential', style: TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeBreakdown(BuildContext context, WidgetRef ref, String currency) {
    final budgetGroupsAsync = ref.watch(budgetProgressByTypeProvider);

    return budgetGroupsAsync.when(
      data: (groups) {
        if (groups.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Performance by Category Group', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...groups.map((group) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildTypeGroup(context, group, currency),
            )),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildTypeGroup(BuildContext context, TransactionTypeGroup group, String currency) {
    final typeColors = {
      'expense': Colors.red,
      'income': Colors.green,
      'savings': AppColors.savings,
      'investment': AppColors.investment,
    };

    final typeIcons = {
      'expense': Icons.shopping_cart_rounded,
      'income': Icons.account_balance_wallet_rounded,
      'savings': Icons.savings_rounded,
      'investment': Icons.trending_up_rounded,
    };

    final typeLabels = {
      'expense': 'Expenses',
      'income': 'Income',
      'savings': 'Savings',
      'investment': 'Investments',
    };

    final color = typeColors[group.type] ?? Colors.grey;
    final icon = typeIcons[group.type] ?? Icons.category_rounded;
    final label = typeLabels[group.type] ?? group.type.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                    Text('${group.categories.length} ${group.categories.length == 1 ? 'category' : 'categories'}', 
                      style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$currency${group.totalLimit.toStringAsFixed(0)}', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                  Text('budgeted', style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: group.progress,
              backgroundColor: color.withValues(alpha: 0.1),
              color: group.isOverBudget ? AppColors.error : color,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Spent: $currency${group.totalSpent.toStringAsFixed(0)}', 
                style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
              Text('${(group.progress * 100).toInt()}%', 
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, 
                  color: group.isOverBudget ? AppColors.error : color)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          ...group.categories.map((category) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Color(category.colorValue),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(category.name, style: const TextStyle(fontSize: 13))),
                Text('$currency${category.limit.toStringAsFixed(0)}', 
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildHumanReadableLogic(BuildContext context, BudgetPlan plan, BudgetQuestionnaire input, String currency) {
    final fixedTotal = input.fixedExpenses.values.fold(0.0, (s,v)=>s+v);
    final disposable = input.totalIncome - fixedTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Calculation Flow', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildCalculationTable(context, [
          _CalcStep('1. Mandatory', 'Total Income - Fixed Costs', '$currency${input.totalIncome.toInt()} - $currency${fixedTotal.toInt()}', '$currency${disposable.toInt()}'),
          _CalcStep('2. Strategy', plan.id.toUpperCase(), _getStrategyFormula(plan), 'See Breakdown'),
          _CalcStep('3. Variable', 'Residual Weighting', 'Importance Weights', 'Final Limits'),
        ]),
        const SizedBox(height: 24),
        _buildStep(1, 'Priority #1: Fixed Costs', 
          'EMIs and Rent ($currency${fixedTotal.toInt()}) are deducted immediately. This is our "Safety First" rule.'),
        _buildStep(2, 'Priority #2: Disposable Split', 
          'The remaining $currency${disposable.toInt()} is then divided. ${_getStrategyBreakdown(plan)}'),
      ],
    );
  }

  Widget _buildCalculationTable(BuildContext context, List<_CalcStep> steps) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(1.5),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1)),
            children: ['Step', 'Formula / Logic', 'Result'].map((e) => Padding(
              padding: const EdgeInsets.all(12),
              child: Text(e, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            )).toList(),
          ),
          ...steps.map((s) => TableRow(
            children: [
              Padding(padding: const EdgeInsets.all(12), child: Text(s.step, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
              Padding(padding: const EdgeInsets.all(12), child: Text(s.formula, style: const TextStyle(fontSize: 11))),
              Padding(padding: const EdgeInsets.all(12), child: Text(s.result, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary))),
            ],
          )),
        ],
      ),
    );
  }

  String _getStrategyFormula(BudgetPlan plan) {
    switch (plan.id) {
      case 'balanced': return '50 Needs / 30 Wants / 20 Savings';
      case 'high_savings': return '60 Savings / 25 Living / 15 Wants';
      case 'debt_focused': return '60 Extra Debt / 15 Save / 25 Live';
      case 'zero_based': return 'Residual = 0 (All Allocated)';
      case 'flexible': return '70 Discretionary / 30 Savings';
      default: return 'Custom Ratio';
    }
  }

  String _getStrategyBreakdown(BudgetPlan plan) {
    switch (plan.id) {
      case 'balanced':
        return 'We target a 50/30/20 split on your disposable income.';
      case 'high_savings':
        return 'We prioritize Savings (60%) on your disposable income.';
      case 'debt_focused':
        return '60% of your disposable income goes straight to killing debt.';
      case 'zero_based':
         return 'Every single rupee is allocated to your chosen variable categories.';
      case 'flexible':
        return '70% of disposable is for life enjoyment, 30% for savings.';
      default:
        return 'Allocated according to the ${plan.name} strategy.';
    }
  }

  Widget _buildStep(int number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primary,
            child: Text('$number', style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalcStep {
  final String step;
  final String logic;
  final String formula;
  final String result;

  _CalcStep(this.step, this.logic, this.formula, this.result);
}
