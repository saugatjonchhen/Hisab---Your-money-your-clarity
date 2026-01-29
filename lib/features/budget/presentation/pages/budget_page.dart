import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart';
import 'package:finance_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:finance_app/features/settings/presentation/pages/category_manager_page.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_app/features/budget/presentation/pages/questionnaire_page.dart';
import 'package:finance_app/features/budget/presentation/providers/budget_providers.dart';
import 'package:finance_app/features/budget/presentation/pages/budget_analysis_page.dart';
import 'package:finance_app/features/budget/presentation/pages/budget_history_page.dart';
import 'package:finance_app/features/budget/presentation/pages/budget_insights_page.dart';
import 'package:finance_app/features/transactions/data/providers/category_provider.dart';
import 'package:finance_app/features/transactions/data/models/category_model.dart';
import 'package:finance_app/core/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BudgetPage extends ConsumerWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final currencySymbol = settingsAsync.when(
      data: (settings) => settings.currencySymbol,
      loading: () => '\$',
      error: (_, __) => '\$',
    );
    
    final budgetsAsync = ref.watch(budgetProgressProvider);
    final activePlan = ref.watch(activeBudgetPlanProvider);
    final questionnaire = ref.watch(budgetQuestionnaireStateProvider);
    final totalBudget = ref.watch(effectiveIncomeProvider);
    final isAdaptiveMode = totalBudget > questionnaire.totalIncome;

    // Activate auto-sync of budget limits based on income
    ref.watch(autoSyncCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Budget'),
        actions: [
          IconButton(
            tooltip: 'Re-plan with AI',
            icon: const Icon(Icons.auto_awesome_rounded),
            onPressed: () {
              AnalyticsService().logBudgetAction('re_plan_with_ai');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QuestionnairePage()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: 'More options',
            onSelected: (value) {
              switch (value) {
                case 'history':
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BudgetHistoryPage()));
                  break;
                case 'insights':
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BudgetInsightsPage()));
                  break;
                case 'analysis':
                  if (activePlan != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const BudgetAnalysisPage()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select or create an active plan first')));
                  }
                  break;
                case 'settings':
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryManagerPage()));
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'history',
                child: Row(children: [Icon(Icons.history_rounded, size: 20), SizedBox(width: 12), Text('Budget History')]),
              ),
              const PopupMenuItem<String>(
                value: 'insights',
                child: Row(children: [Icon(Icons.insights_rounded, size: 20), SizedBox(width: 12), Text('Budget Insights')]),
              ),
              const PopupMenuItem<String>(
                value: 'analysis',
                child: Row(children: [Icon(Icons.info_outline_rounded, size: 20), SizedBox(width: 12), Text('Analysis & Projections')]),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(children: [Icon(Icons.settings_outlined, size: 20), SizedBox(width: 12), Text('Manage Categories')]),
              ),
            ],
          ),
          const SizedBox(width: AppValues.gapSmall),
        ],
      ),
      body: budgetsAsync.when(
        data: (budgets) {
          if (budgets.isEmpty && activePlan == null) {
            return _buildEmptyState(context);
          }

          // Calculate totalSpent for the summary card
          double totalSpent = 0;
          final budgetGroupsAsync = ref.watch(budgetProgressByTypeProvider);
          budgetGroupsAsync.whenData((groups) {
             for (var group in groups) {
               if (group.type != 'income') {
                 totalSpent += group.totalSpent;
               }
             }
          });

          return SingleChildScrollView(
            padding: AppValues.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActivePlanHeader(context, ref),
                if (isAdaptiveMode) ...[
                  const SizedBox(height: AppValues.gapMedium),
                  _buildAdaptiveModeIndicator(context, questionnaire.totalIncome, totalBudget, currencySymbol),
                ],
                const SizedBox(height: AppValues.gapLarge),
                _buildDisposableIncomeCard(context, ref, budgets, currencySymbol),
                const SizedBox(height: AppValues.gapLarge),
                _buildTotalBudgetCard(context, currencySymbol, totalSpent, totalBudget),
                const SizedBox(height: AppValues.gapExtraLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Category Budgets', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryManagerPage()));
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Limits'),
                    ),
                  ],
                ),
                const SizedBox(height: AppValues.gapMedium),
                _buildGroupedCategoryBudgets(context, ref, currencySymbol),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppValues.gapExtraLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 80, color: AppColors.secondary.withValues(alpha: 0.2)),
            const SizedBox(height: AppValues.gapLarge),
            Text('Build Your AI Budget', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppValues.gapMedium),
            Text(
              'We’ll ask a few questions to help you build a budget that fits your life.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).disabledColor),
            ),
            const SizedBox(height: AppValues.gapExtraLarge),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const QuestionnairePage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Start Questionnaire'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePlanHeader(BuildContext context, WidgetRef ref) {
    final activePlan = ref.watch(activeBudgetPlanProvider);
    if (activePlan == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppValues.gapMedium, vertical: AppValues.gapSmall),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppValues.borderRadiusLarge),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.secondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Active AI Plan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                Text(activePlan.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _confirmResetPlan(context, ref),
            child: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _confirmResetPlan(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Budget?'),
        content: const Text('This will clear your active AI plan and reset category limits to zero. You can re-plan anytime.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              AnalyticsService().logBudgetAction('reset_plan');
              ref.read(activeBudgetPlanProvider.notifier).clearPlan();
              final categories = await ref.read(categoriesListProvider.future);
              final notifier = ref.read(categoriesListProvider.notifier);
              for (var c in categories) {
                await notifier.updateCategory(CategoryModel(
                  id: c.id,
                  name: c.name,
                  iconParams: c.iconParams,
                  colorValue: c.colorValue,
                  type: c.type,
                  budgetLimit: 0.0,
                ));
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBudgetCard(BuildContext context, String currencySymbol, double spent, double total) {
    double progress = total > 0 ? (spent / total).clamp(0.0, 1.2) : 0.0;
    double remaining = total - spent;
    bool isOver = spent > total;
    
    return Container(
      padding: const EdgeInsets.all(AppValues.gapLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOver 
            ? [Colors.red.shade800, Colors.red.shade900]
            : [AppColors.secondary, AppColors.secondary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppValues.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: (isOver ? Colors.red : AppColors.secondary).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isOver ? 'Exceeded by' : 'Remaining', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('$currencySymbol${remaining.abs().toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(AppValues.gapMedium),
                decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                child: Icon(isOver ? Icons.warning_amber_rounded : Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: AppValues.gapLarge),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white24,
              color: Colors.white,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: AppValues.gapMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Spent: $currencySymbol${spent.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
              Text('Total Limit: $currencySymbol${total.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedCategoryBudgets(BuildContext context, WidgetRef ref, String currencySymbol) {
    final budgetGroupsAsync = ref.watch(budgetProgressByTypeProvider);

    return budgetGroupsAsync.when(
      data: (groups) {
        if (groups.isEmpty) return const SizedBox.shrink();
        return Column(
          children: groups.map((group) {
            final typeColors = {
              'expense': Colors.red,
              'income': Colors.green,
              'savings': AppColors.savings,
              'investment': AppColors.investment,
              'reserved': Colors.grey,
            };
            final color = typeColors[group.type] ?? Colors.grey;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppValues.gapMedium),
                  child: Row(
                    children: [
                      Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: AppValues.gapSmall),
                      Text(group.type.toUpperCase(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                      const Spacer(),
                      Text('$currencySymbol${group.totalSpent.toStringAsFixed(0)} / $currencySymbol${group.totalLimit.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: group.isOverBudget ? AppColors.error : color)),
                    ],
                  ),
                ),
                ...group.categories.map((budget) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildCategoryBudget(context, currencySymbol, budget))),
              ],
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildCategoryBudget(BuildContext context, String currencySymbol, CategoryBudgetProgress budget) {
    final color = Color(budget.colorValue);
    final percentage = (budget.progress * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(AppValues.gapMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppValues.borderRadius),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(_getIcon(budget.iconParams), color: color, size: 20),
              ),
              const SizedBox(width: AppValues.gapMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(budget.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('$currencySymbol${budget.spent.toStringAsFixed(0)} of $currencySymbol${budget.limit.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: (budget.isOverBudget ? AppColors.error : color).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('$percentage%', style: TextStyle(fontWeight: FontWeight.bold, color: budget.isOverBudget ? AppColors.error : color, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: AppValues.gapMedium),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: budget.progress,
              backgroundColor: color.withValues(alpha: 0.05),
              color: budget.isOverBudget ? AppColors.error : color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisposableIncomeCard(BuildContext context, WidgetRef ref, List<CategoryBudgetProgress> budgets, String currencySymbol) {
    final activePlan = ref.watch(activeBudgetPlanProvider);
    double fixedObligations = 0.0;
    double fixedPaid = 0.0;
    if (activePlan != null) {
      fixedObligations = (activePlan.allocations['Mandatory'] ?? 0) + (activePlan.allocations['Debt'] ?? 0);
    } else {
      for (var b in budgets) {
        final name = b.name.toLowerCase();
        if (name.contains('emi') || name.contains('loan') || name.contains('debt') || name.contains('rent') || name.contains('house') || name.contains('bill')) {
          fixedObligations += b.limit;
        }
      }
    }
    final budgetGroupsAsync = ref.watch(budgetProgressByTypeProvider);
    budgetGroupsAsync.whenData((groups) {
      final reserved = groups.where((g) => g.type == 'reserved').firstOrNull;
      if (reserved != null) fixedPaid += reserved.totalSpent;
      for (var g in groups) {
        if (g.type == 'expense') {
          for (var cat in g.categories) {
            final name = cat.name.toLowerCase();
            if (name.contains('emi') || name.contains('loan') || name.contains('debt') || name.contains('rent') || name.contains('house') || name.contains('bill')) {
              fixedPaid += cat.spent;
            }
          }
        }
      }
    });
    final questionnaire = ref.watch(budgetQuestionnaireStateProvider);
    final totalEffectiveIncome = ref.watch(effectiveIncomeProvider);
    final disposableForDaily = totalEffectiveIncome - fixedObligations;
    final fixedRemaining = (fixedObligations - fixedPaid).clamp(0.0, double.infinity);
    final paidPercentage = fixedObligations > 0 ? (fixedPaid / fixedObligations).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppValues.gapLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppValues.borderRadiusLarge),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Monthly Fixed Commitments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: (paidPercentage >= 1.0 ? Colors.green : Colors.orange).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(paidPercentage >= 1.0 ? 'FULLY PAID' : '${(paidPercentage * 100).toStringAsFixed(0)}% PAID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: paidPercentage >= 1.0 ? Colors.green : Colors.orange)),
              ),
            ],
          ),
          const SizedBox(height: AppValues.gapLarge),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Salary', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                    FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('$currencySymbol${totalEffectiveIncome.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  ],
                ),
              ),
              Container(height: 40, width: 1, color: Theme.of(context).dividerColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('EMI & Fixed', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('$currencySymbol${fixedRemaining.toStringAsFixed(0)} left', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.redAccent))),
                    ],
                  ),
                ),
              ),
              Container(height: 40, width: 1, color: Theme.of(context).dividerColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Disposable', style: TextStyle(fontSize: 12, color: Colors.green)),
                      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('$currencySymbol${disposableForDaily.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppValues.gapLarge),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(flex: fixedPaid.toInt() + 1, child: Container(color: Colors.green.shade400)),
                  Expanded(flex: fixedRemaining.toInt() + 1, child: Container(color: Colors.redAccent.withValues(alpha: 0.3))),
                  Expanded(flex: disposableForDaily.toInt() + 1, child: Container(color: Colors.green.withValues(alpha: 0.1))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Paid: $currencySymbol${fixedPaid.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.w500)),
              Text('Due: $currencySymbol${fixedRemaining.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveModeIndicator(BuildContext context, double planned, double actual, String currencySymbol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange.shade900),
                children: [
                  const TextSpan(text: 'Adaptive Mode: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Monthly income ($currencySymbol${actual.toStringAsFixed(0)}) exceeded plan ($currencySymbol${planned.toStringAsFixed(0)}). Budget limits have been increased.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch(iconName) {
      case 'fastfood_rounded': return Icons.fastfood_rounded;
      case 'directions_bus_rounded': return Icons.directions_bus_rounded;
      case 'shopping_bag_rounded': return Icons.shopping_bag_rounded;
      case 'receipt_long_rounded': return Icons.receipt_long_rounded;
      case 'movie_rounded': return Icons.movie_rounded;
      case 'work_rounded': return Icons.work_rounded;
      case 'savings_rounded': return Icons.savings_rounded;
      case 'trending_up_rounded': return Icons.trending_up_rounded;
      case 'medical_services_rounded': return Icons.medical_services_rounded;
      case 'fitness_center_rounded': return Icons.fitness_center_rounded;
      case 'home_rounded': return Icons.home_rounded;
      case 'school_rounded': return Icons.school_rounded;
      case 'real_estate_agent_rounded': return Icons.real_estate_agent_rounded;
      case 'lock_outline_rounded': return Icons.lock_outline_rounded;
      default: return Icons.category_rounded;
    }
  }
}
