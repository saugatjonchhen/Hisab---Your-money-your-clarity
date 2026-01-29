import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetProgressWidget extends StatelessWidget {
  final List<CategoryBudgetProgress> budgets;
  final String currencySymbol;

  const BudgetProgressWidget({
    super.key,
    required this.budgets,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    if (budgets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Budget Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              DateFormat('MMMM').format(DateTime.now()),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: budgets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return _buildBudgetCard(context, budget);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(BuildContext context, CategoryBudgetProgress budget) {
    final color = Color(budget.colorValue);
    final percentage = (budget.progress * 100).toStringAsFixed(0);
    
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_getIcon(budget.iconParams), color: color, size: 18),
              ),
              const Spacer(),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: budget.isOverBudget ? AppColors.error : color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            budget.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '$currencySymbol${budget.spent.toStringAsFixed(0)} / $currencySymbol${budget.limit.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: budget.progress,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                budget.isOverBudget ? AppColors.error : color
              ),
              minHeight: 6,
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
      default: return Icons.category_rounded;
    }
  }
}
