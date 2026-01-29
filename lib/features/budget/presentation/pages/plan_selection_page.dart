import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart';
import 'package:finance_app/features/budget/data/models/budget_models.dart';
import 'package:finance_app/features/budget/domain/services/budget_sync_service.dart';
import 'package:finance_app/features/budget/presentation/providers/budget_providers.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_app/features/transactions/data/providers/category_provider.dart';
import 'package:finance_app/features/transactions/data/models/category_model.dart';
import 'package:finance_app/features/budget/presentation/pages/questionnaire_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlanSelectionPage extends ConsumerWidget {
  const PlanSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(generatedBudgetPlansProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final currencySymbol = settingsAsync.when(
      data: (s) => s.currencySymbol,
      loading: () => 'Rs.',
      error: (_, __) => 'Rs.',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Your Personal Plans')),
      body: plans.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                // Use a grid for wider screens
                if (constraints.maxWidth > 600) {
                   return GridView.builder(
                    padding: AppValues.screenPadding,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      childAspectRatio: 0.85, 
                      crossAxisSpacing: AppValues.gapMedium,
                      mainAxisSpacing: AppValues.gapMedium,
                    ),
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      return _buildPlanCard(context, plan, currencySymbol, ref);
                    },
                  );
                }
                
                return ListView.builder(
                  padding: AppValues.screenPadding,
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return _buildPlanCard(context, plan, currencySymbol, ref);
                  },
                );
              },
            ),
    );
  }

  Widget _buildPlanCard(BuildContext context, BudgetPlan plan, String currencySymbol, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppValues.gapMedium),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppValues.borderRadius)),
      child: InkWell(
        onTap: () => _showPlanDetails(context, plan, currencySymbol, ref),
        borderRadius: BorderRadius.circular(AppValues.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppValues.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                         Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppValues.borderRadiusSmall),
                          ),
                          child: Text(
                            plan.bestFor,
                            style: TextStyle(
                              fontSize: 12, 
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                plan.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Column(
                children: plan.allocations.entries.take(3).map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('$currencySymbol${e.value.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )).toList(),
              ),
              if (plan.allocations.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Center(child: Text('+ ${plan.allocations.length - 3} more categories', style: const TextStyle(fontSize: 12, color: Colors.grey))),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlanDetails(BuildContext context, BudgetPlan plan, String currencySymbol, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) {
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Stack(
              children: [
                ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 100), // Bottom padding for button
                  children: [
                    Center(
                      child: Container(
                        width: 40, 
                        height: 4, 
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))
                      )
                    ),
                    const SizedBox(height: 24),
                    Text(plan.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    
                    // AI Reasoning Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.psychology, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Text('AI Reasoning', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800], fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(plan.description, style: const TextStyle(height: 1.5)),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    Text('Key Benefits', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...plan.pros.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12), 
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20), 
                          const SizedBox(width: 12), 
                          Expanded(child: Text(p, style: const TextStyle(height: 1.3))),
                        ]
                      )
                    )),
                    
                    const SizedBox(height: 24),
                    Text('Trade-offs', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...plan.tradeOffs.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 12), 
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20), 
                          const SizedBox(width: 12), 
                          Expanded(child: Text(t, style: const TextStyle(height: 1.3))),
                        ]
                      )
                    )),
                    
                    const SizedBox(height: 32),
                    Text('Allocation Preview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                     ...plan.allocations.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key),
                          Text('$currencySymbol${e.value.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )),
                  ],
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 24,
                  child: ElevatedButton(
                    onPressed: () => _applyPlan(context, plan, ref),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: const Text('Apply This Budget', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _applyPlan(BuildContext context, BudgetPlan plan, WidgetRef ref) async {
    final categories = await ref.read(categoriesListProvider.future);
    final notifier = ref.read(categoriesListProvider.notifier);
    
    // Map plan allocations to categories more intelligently
    // Access questionnaire to get exact fixed commitment values
    final questionnaire = ref.read(budgetQuestionnaireStateProvider);

    // Use BudgetSyncService to calculate updated limits
    final updatedCategories = BudgetSyncService.calculateUpdatedLimits(
      plan: plan,
      questionnaire: questionnaire,
      categories: categories,
    );
    
    // Update categories
    for (var updatedCategory in updatedCategories) {
      await notifier.updateCategory(updatedCategory);
    }

    // Register active plan
    ref.read(activeBudgetPlanProvider.notifier).selectPlan(plan);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Plan "${plan.name}" applied successfully!')),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}

