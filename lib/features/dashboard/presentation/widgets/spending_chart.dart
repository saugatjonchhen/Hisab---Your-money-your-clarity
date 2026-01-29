import 'package:finance_app/core/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SpendingChart extends StatelessWidget {
  final List<BarChartGroupData> barGroups;
  final List<String> seriesNames;
  final String title;
  final Widget Function(double, TitleMeta)? getBottomTitles;
  final double maxX;
  
  const SpendingChart({
    super.key, 
    this.title = 'Spending Trends',
    required this.barGroups,
    required this.seriesNames,
    this.getBottomTitles,
    this.maxX = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              // Legend
              Row(
                children: seriesNames.map((key) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                          Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getColor(key),
                            shape: BoxShape.circle,
                          ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            key, 
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.70,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000, // Adjust interval based on data ideally
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
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
                      reservedSize: 30,
                      getTitlesWidget: getBottomTitles ?? bottomTitleWidgets,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false, 
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
                alignment: BarChartAlignment.spaceAround,
                maxY: _findMaxY(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Theme.of(context).cardTheme.color!,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(0)}\n',
                        TextStyle(
                          color: rod.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _findMaxY() {
    double max = 0;
    for (var group in barGroups) {
      for (var rod in group.barRods) {
        if (rod.toY > max) max = rod.toY;
      }
    }
    return max == 0 ? 100 : max * 1.2; // Add 20% buffer
  }

  Color _getColor(String key) {
    if (key.toLowerCase().contains('previous')) return Colors.grey.withValues(alpha: 0.5);
    if (key.toLowerCase().contains('income')) return AppColors.secondary;
    if (key.toLowerCase().contains('expense')) return AppColors.tertiary; // red
    if (key.toLowerCase().contains('saving')) return AppColors.savings;
    if (key.toLowerCase().contains('invest')) return AppColors.investment;
    return AppColors.primary;
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Colors.grey,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Mon', style: style);
        break;
      case 2:
        text = const Text('Wed', style: style);
        break;
      case 4:
        text = const Text('Fri', style: style);
        break;
      case 6:
        text = const Text('Sun', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }
}
