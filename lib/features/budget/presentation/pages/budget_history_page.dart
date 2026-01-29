import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart';
import 'package:finance_app/features/budget/presentation/providers/budget_history_providers.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BudgetHistoryPage extends ConsumerWidget {
  const BudgetHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(budgetHistoryProvider());
    final settingsAsync = ref.watch(settingsProvider);
    
    final currency = settingsAsync.when(
      data: (s) => s.currencySymbol,
      loading: () => 'Rs.',
      error: (_, __) => 'Rs.',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              // Manually create snapshot for current period
              await ref.read(budgetSnapshotGeneratorProvider.notifier).createCurrentSnapshot();
              ref.invalidate(budgetHistoryProvider);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: historyAsync.when(
        data: (snapshots) {
          if (snapshots.isEmpty) {
            return _buildEmptyState(context);
          }

          return SingleChildScrollView(
            padding: AppValues.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(context, snapshots, currency),
                const SizedBox(height: AppValues.gapLarge),
                _buildTrendCharts(context, snapshots, currency),
                const SizedBox(height: AppValues.gapLarge),
                Text(
                  'Monthly Breakdown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppValues.gapMedium),
                ...snapshots.map((snapshot) => Padding(
                      padding: const EdgeInsets.only(bottom: AppValues.gapMedium),
                      child: _buildMonthCard(context, snapshot, currency),
                    )),
                const SizedBox(height: AppValues.gapExtraLarge),
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
              const SizedBox(height: AppValues.gapMedium),
              Text('Error loading history'),
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
            Icon(Icons.history_rounded, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            Text(
              'No History Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Budget history will appear here as months complete.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, List snapshots, String currency) {
    double totalSavings = 0;
    double totalInvestments = 0;
    double totalExpenses = 0;
    
    for (var snapshot in snapshots) {
      totalSavings += snapshot.totalSavings;
      totalInvestments += snapshot.totalInvestments;
      totalExpenses += snapshot.totalExpenses;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last ${snapshots.length} Months Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Total Saved',
                totalSavings,
                currency,
                AppColors.savings,
                Icons.savings_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Total Invested',
                totalInvestments,
                currency,
                AppColors.investment,
                Icons.trending_up_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          context,
          'Total Expenses',
          totalExpenses,
          currency,
          Colors.red,
          Icons.shopping_cart_rounded,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    double amount,
    String currency,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '$currency${amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCharts(BuildContext context, List snapshots, String currency) {
    final reversedSnapshots = snapshots.reversed.toList(); // Oldest first for chart

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trends Over Time',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Savings & Investments', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${(value / 1000).toStringAsFixed(0)}k',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < reversedSnapshots.length) {
                              final snapshot = reversedSnapshots[index];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  DateFormat('MMM').format(snapshot.month),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // Savings line
                      LineChartBarData(
                        spots: reversedSnapshots.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), e.value.totalSavings);
                        }).toList(),
                        isCurved: true,
                        color: AppColors.savings,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      ),
                      // Investments line
                      LineChartBarData(
                        spots: reversedSnapshots.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), e.value.totalInvestments);
                        }).toList(),
                        isCurved: true,
                        color: AppColors.investment,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Savings', AppColors.savings),
                  const SizedBox(width: 24),
                  _buildLegendItem('Investments', AppColors.investment),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildMonthCard(BuildContext context, dynamic snapshot, String currency) {
    final dateFormat = DateFormat('MMMM yyyy');
    final score = snapshot.performanceScore;
    final scoreColor = score >= 7 ? Colors.green : (score >= 5 ? Colors.orange : Colors.red);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  Text(
                    dateFormat.format(snapshot.month),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (snapshot.activePlanName != null)
                    Text(
                      snapshot.activePlanName!,
                      style: TextStyle(fontSize: 12, color: AppColors.secondary),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, color: scoreColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      score.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildMetric('Income', snapshot.totalIncome, currency, Colors.green)),
              Expanded(child: _buildMetric('Expenses', snapshot.totalExpenses, currency, Colors.red)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetric('Savings', snapshot.totalSavings, currency, AppColors.savings)),
              Expanded(child: _buildMetric('Investments', snapshot.totalInvestments, currency, AppColors.investment)),
            ],
          ),
          if (snapshot.plannedAllocations.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _buildGoalComparison(
              context,
              'Savings Goal',
              snapshot.totalSavings,
              snapshot.plannedAllocations['Savings'] ?? 0,
              currency,
              snapshot.metSavingsGoal,
            ),
            const SizedBox(height: 8),
            _buildGoalComparison(
              context,
              'Expense Budget',
              snapshot.totalExpenses,
              (snapshot.plannedAllocations['Mandatory'] ?? 0) +
                  (snapshot.plannedAllocations['Variable'] ?? 0) +
                  (snapshot.plannedAllocations['Lifestyle'] ?? 0),
              currency,
              snapshot.metExpenseGoal,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetric(String label, double value, String currency, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            '$currency${value.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalComparison(
    BuildContext context,
    String label,
    double actual,
    double planned,
    String currency,
    bool metGoal,
  ) {
    final variance = actual - planned;
    final variancePercent = planned > 0 ? ((actual / planned - 1) * 100) : 0.0;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '$currency${actual.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    ' / $currency${planned.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (metGoal ? Colors.green : Colors.red).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                metGoal ? Icons.check_circle_rounded : Icons.warning_rounded,
                size: 14,
                color: metGoal ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                '${variancePercent >= 0 ? '+' : ''}${variancePercent.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: metGoal ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
