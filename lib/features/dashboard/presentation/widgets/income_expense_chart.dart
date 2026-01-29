import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/features/transactions/data/models/transaction_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class IncomeExpenseChart extends ConsumerWidget {
  final List<TransactionModel> transactions;

  const IncomeExpenseChart({super.key, required this.transactions});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final currencySymbol = settingsAsync.when(
      data: (s) => s.currencySymbol,
      loading: () => r'$',
      error: (_, __) => r'$',
    );
    // Group transactions by week
    final weeklyData = _groupByWeek(transactions);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Income vs Expense vs Assets',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(weeklyData),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Theme.of(context).cardTheme.color!,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String label = '';
                      switch (rodIndex) {
                        case 0: label = 'Income'; break;
                        case 1: label = 'Expense'; break;
                        case 2: label = 'Savings'; break;
                        case 3: label = 'Invest'; break;
                      }
                      return BarTooltipItem(
                        '$label\n',
                        const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: '$currencySymbol${rod.toY.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: rod.color,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < weeklyData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              weeklyData[index]['label'],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '$currencySymbol${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxY(weeklyData) / 5,
                ),
                barGroups: weeklyData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data['income'],
                        color: AppColors.secondary,
                        width: 8,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                      ),
                      BarChartRodData(
                        toY: data['expense'],
                        color: Colors.red,
                        width: 8,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                      ),
                      BarChartRodData(
                        toY: data['savings'],
                        color: AppColors.savings,
                        width: 8,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                      ),
                      BarChartRodData(
                        toY: data['investment'],
                        color: AppColors.investment,
                        width: 8,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildLegend('Income', AppColors.secondary),
              _buildLegend('Expense', Colors.red),
              _buildLegend('Savings', AppColors.savings),
              _buildLegend('Investment', AppColors.investment),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  List<Map<String, dynamic>> _groupByWeek(List<TransactionModel> transactions) {
    if (transactions.isEmpty) return [];

    // Get last 4 weeks
    final now = DateTime.now();
    final weeks = <Map<String, dynamic>>[];
    
    for (int i = 3; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: 7 * i + now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      final weekTransactions = transactions.where((t) {
        return t.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
               t.date.isBefore(weekEnd.add(const Duration(days: 1)));
      }).toList();
      
      double income = 0;
      double expense = 0;
      double savings = 0;
      double investment = 0;
      
      for (var t in weekTransactions) {
        if (t.type == 'income') {
          income += t.amount;
        } else if (t.type == 'expense') {
          expense += t.amount;
        } else if (t.type == 'savings') {
          savings += t.amount;
        } else if (t.type == 'investment') {
          investment += t.amount;
        }
      }
      
      weeks.add({
        'label': 'Week ${4 - i}',
        'income': income,
        'expense': expense,
        'savings': savings,
        'investment': investment,
      });
    }
    
    return weeks;
  }

  double _getMaxY(List<Map<String, dynamic>> data) {
    double max = 0;
    for (var week in data) {
      if (week['income'] > max) max = week['income'];
      if (week['expense'] > max) max = week['expense'];
      if (week['savings'] > max) max = week['savings'];
      if (week['investment'] > max) max = week['investment'];
    }
    return max > 0 ? max * 1.2 : 100;
  }
}
