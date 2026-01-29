import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart';
import 'package:finance_app/features/budget/presentation/providers/budget_history_providers.dart';
import 'package:finance_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BudgetInsightsPage extends ConsumerWidget {
  const BudgetInsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(budgetHistoryProvider(months: 12));
    final settingsAsync = ref.watch(settingsProvider);
    
    final currency = settingsAsync.when(
      data: (s) => s.currencySymbol,
      loading: () => 'Rs.',
      error: (_, __) => 'Rs.',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Insights'),
      ),
      body: historyAsync.when(
        data: (snapshots) {
          if (snapshots.isEmpty) {
            return _buildEmptyState(context);
          }

          // Calculate analytics
          final avgScore = snapshots.fold<double>(0, (sum, s) => sum + s.performanceScore) / snapshots.length;
          final recentSnapshots = snapshots.take(3).toList();
          final avgRecentScore = recentSnapshots.isEmpty ? 0.0 : 
              recentSnapshots.fold<double>(0, (sum, s) => sum + s.performanceScore) / recentSnapshots.length;
          
          // Variance analysis
          final savingsVariances = snapshots.map((s) => s.savingsVariance).toList();
          final investmentVariances = snapshots.map((s) => s.investmentVariance).toList();
          final expenseVariances = snapshots.map((s) => s.expenseVariance).toList();
          
          final avgSavingsVariance = savingsVariances.fold<double>(0, (sum, v) => sum + v) / savingsVariances.length;
          final avgInvestmentVariance = investmentVariances.isEmpty ? 0.0 : 
              investmentVariances.fold<double>(0, (sum, v) => sum + v) / investmentVariances.length;
          final avgExpenseVariance = expenseVariances.fold<double>(0, (sum, v) => sum + v) / expenseVariances.length;

          // Success rates
          final savingsSuccessRate = snapshots.where((s) => s.metSavingsGoal).length / snapshots.length;
          final expenseSuccessRate = snapshots.where((s) => s.metExpenseGoal).length / snapshots.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPerformanceScoreCard(context, avgScore, avgRecentScore),
                const SizedBox(height: 24),
                Text(
                  'Performance Breakdown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildSuccessRateCard(context, 'Savings Goal Met', savingsSuccessRate, AppColors.savings),
                const SizedBox(height: 12),
                _buildSuccessRateCard(context, 'Expense Budget Met', expenseSuccessRate, Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'Average Variance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'How much you typically over/under-perform vs. your plan:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                _buildVarianceCard(context, 'Savings', avgSavingsVariance, currency, AppColors.savings),
                const SizedBox(height: 12),
                _buildVarianceCard(context, 'Investments', avgInvestmentVariance, currency, AppColors.investment),
                const SizedBox(height: 12),
                _buildVarianceCard(context, 'Expenses', avgExpenseVariance, currency, Colors.red),
                const SizedBox(height: 24),
                _buildRecommendations(context, snapshots, avgSavingsVariance, avgExpenseVariance),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Error loading insights'),
              TextButton(
                onPressed: () => ref.invalidate(budgetHistoryProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insights_rounded, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            Text(
              'Not Enough Data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Insights will appear after you complete a few budget cycles.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceScoreCard(BuildContext context, double avgScore, double recentScore) {
    final scoreColor = avgScore >= 7 ? Colors.green : (avgScore >= 5 ? Colors.orange : Colors.red);
    final trend = recentScore > avgScore ? 'improving' : (recentScore < avgScore ? 'declining' : 'stable');
    final trendIcon = recentScore > avgScore ? Icons.trending_up_rounded : 
                     (recentScore < avgScore ? Icons.trending_down_rounded : Icons.trending_flat_rounded);
    final trendColor = recentScore > avgScore ? Colors.green : 
                      (recentScore < avgScore ? Colors.red : Colors.grey);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scoreColor, scoreColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Overall Performance Score',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                avgScore.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                ' / 10',
                style: TextStyle(color: Colors.white70, fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(trendIcon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Recent trend: ${trend.toUpperCase()}',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppValues.gapExtraSmall),
          Text(
            'Last 3 months: ${recentScore.toStringAsFixed(1)}/10',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRateCard(BuildContext context, String label, double rate, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppValues.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppValues.borderRadius),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppValues.paddingSmall),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppValues.borderRadiusSmall),
            ),
            child: Icon(
              (rate * 100).toInt() >= 70 ? Icons.check_circle_rounded : Icons.warning_rounded,
              color: color,
              size: AppValues.iconSizeMedium,
            ),
          ),
          const SizedBox(width: AppValues.gapMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: AppValues.gapTiny),
                Text('${(rate * 100).toInt()}% success rate', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Text(
            '${(rate * 100).toInt()}%',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildVarianceCard(BuildContext context, String label, double variance, String currency, Color color) {
    final isPositive = variance > 0;
    final displayColor = isPositive ? Colors.green : Colors.red;
    
    return Container(
      padding: const EdgeInsets.all(AppValues.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppValues.borderRadius),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppValues.paddingExtraSmall),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppValues.borderRadiusExtraSmall),
            ),
            child: Icon(_getIconForCategory(label), color: color, size: AppValues.iconSizeSmall),
          ),
          const SizedBox(width: AppValues.gapMedium),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                color: displayColor,
                size: AppValues.iconSizeExtraSmall,
              ),
              const SizedBox(width: AppValues.gapTiny),
              Text(
                '$currency${variance.abs().toStringAsFixed(0)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: displayColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String label) {
    switch (label) {
      case 'Savings':
        return Icons.savings_rounded;
      case 'Investments':
        return Icons.trending_up_rounded;
      case 'Expenses':
        return Icons.shopping_cart_rounded;
      default:
        return Icons.analytics_rounded;
    }
  }

  Widget _buildRecommendations(BuildContext context, List snapshots, double savingsVar, double expenseVar) {
    List<Map<String, dynamic>> recommendations = [];

    // Generate recommendations based on data
    if (savingsVar < 0) {
      recommendations.add({
        'icon': Icons.savings_rounded,
        'color': AppColors.savings,
        'title': 'Increase Savings',
        'description': 'You\'re consistently under-saving. Try the "High Savings" budget plan.',
      });
    } else if (savingsVar > 5000) {
      recommendations.add({
        'icon': Icons.celebration_rounded,
        'color': Colors.amber,
        'title': 'Great Job Saving!',
        'description': 'You\'re exceeding your savings goals. Consider increasing your investment allocation.',
      });
    }

    if (expenseVar > 0) {
      recommendations.add({
        'icon': Icons.warning_rounded,
        'color': Colors.red,
        'title': 'Control Spending',
        'description': 'You tend to overspend. Review your expense categories and set stricter limits.',
      });
    }

    final recentSnapshots = snapshots.take(3).toList();
    final consistentlyMeetGoals = recentSnapshots.every((s) => s.metSavingsGoal && s.metExpenseGoal);
    
    if (consistentlyMeetGoals && recommendations.isEmpty) {
      recommendations.add({
        'icon': Icons.emoji_events_rounded,
       'color': Colors.amber,
        'title': 'You\'re Crushing It!',
        'description': 'You\'ve consistently met your goals. Consider setting more ambitious targets.',
      });
    }

    if (recommendations.isEmpty) {
      recommendations.add({
        'icon': Icons.thumb_up_rounded,
        'color': AppColors.primary,
        'title': 'Keep It Up!',
        'description': 'Your budget is on track. Continue with your current plan.',
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommendations',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (rec['color'] as Color).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: (rec['color'] as Color).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(rec['icon'] as IconData, color: rec['color'] as Color, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec['title'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: rec['color'] as Color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rec['description'] as String,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
