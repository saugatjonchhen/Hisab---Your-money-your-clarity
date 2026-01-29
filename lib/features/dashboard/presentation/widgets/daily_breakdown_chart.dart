import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_app/features/transactions/data/models/category_model.dart';
import 'package:finance_app/features/transactions/data/providers/category_provider.dart';
import 'package:finance_app/features/transactions/data/models/transaction_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyBreakdownChart extends ConsumerStatefulWidget {
  final List<TransactionModel> transactions;

  const DailyBreakdownChart({super.key, required this.transactions});

  @override
  ConsumerState<DailyBreakdownChart> createState() => _DailyBreakdownChartState();
}

class _DailyBreakdownChartState extends ConsumerState<DailyBreakdownChart> {
  int touchedIndex = -1;
  int selectedTypeIndex = 0;

  // Transaction types with their colors
  static const List<Map<String, dynamic>> transactionTypes = [
    {'type': 'expense', 'label': 'Expense', 'color': AppColors.tertiary, 'icon': Icons.shopping_bag_rounded},
    {'type': 'income', 'label': 'Income', 'color': AppColors.primary, 'icon': Icons.account_balance_wallet_rounded},
    {'type': 'savings', 'label': 'Savings', 'color': AppColors.savings, 'icon': Icons.savings_rounded},
    {'type': 'investment', 'label': 'Investment', 'color': AppColors.investment, 'icon': Icons.trending_up_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final currencySymbol = settingsAsync.when(
      data: (s) => s.currencySymbol,
      loading: () => '',
      error: (_, __) => '',
    );
    final categoriesAsync = ref.watch(categoriesListProvider);
    final categories = categoriesAsync.valueOrNull ?? [];

    final currentType = transactionTypes[selectedTypeIndex];
    final filteredTransactions = widget.transactions
        .where((t) => t.type == currentType['type'])
        .toList();

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
            'Daily Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          // Transaction type selector chips
          _buildTypeSelector(context),
          const SizedBox(height: 24),
          // Chart content
          _buildChartContent(
            context, 
            filteredTransactions, 
            categories, 
            currencySymbol,
            currentType,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(transactionTypes.length, (index) {
          final type = transactionTypes[index];
          final isSelected = selectedTypeIndex == index;
          final color = type['color'] as Color;
          
          // Count transactions of this type
          final count = widget.transactions
              .where((t) => t.type == type['type'])
              .length;
          
          return Padding(
            padding: EdgeInsets.only(right: index < transactionTypes.length - 1 ? 8 : 0),
            child: FilterChip(
              selected: isSelected,
              onSelected: (_) => setState(() {
                selectedTypeIndex = index;
                touchedIndex = -1;
              }),
              avatar: Icon(
                type['icon'] as IconData,
                size: 16,
                color: isSelected ? Colors.white : color,
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    type['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.white.withValues(alpha: 0.3)
                            : color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : color,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              selectedColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? color : color.withValues(alpha: 0.3),
                ),
              ),
              showCheckmark: false,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChartContent(
    BuildContext context,
    List<TransactionModel> transactions,
    List<CategoryModel> categories,
    String currencySymbol,
    Map<String, dynamic> typeInfo,
  ) {
    if (transactions.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              typeInfo['icon'] as IconData,
              size: 48,
              color: (typeInfo['color'] as Color).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              "No ${typeInfo['label'].toString().toLowerCase()} today",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      );
    }

    final total = transactions.fold(0.0, (sum, t) => sum + t.amount);
    
    final Map<String, double> grouped = {};
    for (var t in transactions) {
      grouped[t.categoryId] = (grouped[t.categoryId] ?? 0) + t.amount;
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => grouped[b]!.compareTo(grouped[a]!));

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 5,
                  centerSpaceRadius: 70,
                  sections: _showingSections(grouped, sortedKeys, categories, typeInfo['color'] as Color),
                  startDegreeOffset: 270,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    typeInfo['label'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$currencySymbol${total.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: typeInfo['color'] as Color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Legend / Chips
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sortedKeys.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final catId = sortedKeys[index];
              final value = grouped[catId]!;
              final category = categories.cast<CategoryModel?>().firstWhere(
                (c) => c?.id == catId, 
                orElse: () => null
              );
              final color = category != null 
                  ? Color(category.colorValue) 
                  : Colors.primaries[index % Colors.primaries.length];
              final iconName = category?.iconParams ?? 'category_rounded';
              final name = category?.name ?? 'Unknown';

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                   children: [
                     Container(
                       padding: const EdgeInsets.all(8),
                       decoration: BoxDecoration(
                         color: color,
                         shape: BoxShape.circle,
                       ),
                       child: Icon(_getIcon(iconName), color: Colors.white, size: 20),
                     ),
                     const SizedBox(width: 12),
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                         const SizedBox(height: 2),
                         Text(
                           '$currencySymbol${value.toStringAsFixed(0)}', 
                           style: Theme.of(context).textTheme.bodySmall
                         ),
                       ],
                     ),
                   ],
                ),
              );
            },
          ),
        ),
      ],
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
      case 'account_balance_wallet_rounded': return Icons.account_balance_wallet_rounded;
      case 'savings_rounded': return Icons.savings_rounded;
      case 'trending_up_rounded': return Icons.trending_up_rounded;
      case 'attach_money_rounded': return Icons.attach_money_rounded;
      case 'business_center_rounded': return Icons.business_center_rounded;
      case 'card_giftcard_rounded': return Icons.card_giftcard_rounded;
      case 'home_rounded': return Icons.home_rounded;
      case 'health_and_safety_rounded': return Icons.health_and_safety_rounded;
      case 'school_rounded': return Icons.school_rounded;
      case 'flight_rounded': return Icons.flight_rounded;
      case 'sports_esports_rounded': return Icons.sports_esports_rounded;
      case 'pets_rounded': return Icons.pets_rounded;
      default: return Icons.category_rounded;
    }
  }

  List<PieChartSectionData> _showingSections(
    Map<String, double> grouped, 
    List<String> sortedKeys, 
    List<CategoryModel> categories,
    Color typeColor,
  ) {
    return List.generate(sortedKeys.length, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 25.0 : 20.0;
      final catId = sortedKeys[i];
      final value = grouped[catId]!;
      
      final category = categories.cast<CategoryModel?>().firstWhere(
        (c) => c?.id == catId, 
        orElse: () => null
      );
      
      final color = category != null 
          ? Color(category.colorValue) 
          : Colors.primaries[i % Colors.primaries.length];

      return PieChartSectionData(
        color: color,
        value: value,
        title: '', 
        radius: radius,
        badgeWidget: null, 
      );
    });
  }
}
