import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart';
import 'package:finance_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:finance_app/features/dashboard/presentation/widgets/budget_progress_widget.dart';
import 'package:finance_app/features/dashboard/presentation/widgets/spending_chart.dart';
import 'package:finance_app/features/transactions/data/models/category_model.dart';
import 'package:finance_app/features/transactions/data/models/transaction_model.dart';
import 'package:finance_app/features/transactions/data/providers/category_provider.dart';
import 'package:finance_app/features/transactions/data/providers/transaction_provider.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_app/features/transactions/data/services/report_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DetailedStatsPage extends ConsumerStatefulWidget {
  const DetailedStatsPage({super.key});

  @override
  ConsumerState<DetailedStatsPage> createState() => _DetailedStatsPageState();
}

class _DetailedStatsPageState extends ConsumerState<DetailedStatsPage> {
  DashboardViewMode _viewMode = DashboardViewMode.weekly;
  bool _compareMode = false;

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => _showExportDialog(context),
            tooltip: 'Export Data',
          ),
          const SizedBox(width: AppValues.gapSmall),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppValues.horizontalPadding, 0, AppValues.horizontalPadding, AppValues.gapExtraLarge),
        child: Column(
          children: [
            _buildViewModeSelector(),
            const SizedBox(height: AppValues.gapMedium),
            if (_viewMode != DashboardViewMode.yearly)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Compare with previous period', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(width: AppValues.gapSmall),
                  Switch(
                    value: _compareMode,
                    onChanged: (val) => setState(() => _compareMode = val),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            const SizedBox(height: AppValues.gapLarge),
            transactionsAsync.when(
              data: (transactions) {
                final filteredTransactions = _filterTransactions(transactions);
                final settingsAsync = ref.watch(settingsProvider);
                final currencySymbol = settingsAsync.when(
                  data: (s) => s.currencySymbol,
                  loading: () => '\$',
                  error: (_, __) => '\$',
                );
                
                double maxX = 6;
                if (_viewMode == DashboardViewMode.monthly) {
                  maxX = 29;
                } else if (_viewMode == DashboardViewMode.yearly) {
                  maxX = 11;
                }
                
                final previousTransactions = _compareMode ? _filterPreviousTransactions(transactions) : <TransactionModel>[];

                return Column(
                  children: [
                    SpendingChart(
                      barGroups: _generateBarGroups(filteredTransactions, previousTransactions),
                      seriesNames: _compareMode 
                          ? const ['Expense', 'Previous Expense']
                          : const ['Income', 'Expense', 'Savings', 'Investment'],
                      title: _viewMode == DashboardViewMode.weekly 
                        ? 'This Week' 
                        : _viewMode == DashboardViewMode.monthly 
                          ? 'This Month'
                          : 'This Year',
                      getBottomTitles: (value, meta) => _getBottomTitles(value, meta, _viewMode),
                      maxX: maxX,
                    ),
                    const SizedBox(height: AppValues.gapLarge),
                    _buildStatsSummary(filteredTransactions, currencySymbol),
                    if (_viewMode == DashboardViewMode.monthly) ...[
                      const SizedBox(height: AppValues.gapLarge),
                      Consumer(
                        builder: (context, ref, child) {
                          final budgetAsync = ref.watch(budgetProgressProvider);
                          return budgetAsync.when(
                            data: (budgets) => BudgetProgressWidget(
                              budgets: budgets, 
                              currencySymbol: currencySymbol,
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: AppValues.gapLarge),
                    _buildCategoryBreakdown(filteredTransactions, currencySymbol),
                    const SizedBox(height: AppValues.gapLarge),
                    _buildTransactionList(filteredTransactions, currencySymbol),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSelectorButton('Weekly', DashboardViewMode.weekly),
          ),
          Expanded(
            child: _buildSelectorButton('Monthly', DashboardViewMode.monthly),
          ),
          Expanded(
            child: _buildSelectorButton('Yearly', DashboardViewMode.yearly),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorButton(String label, DashboardViewMode mode) {
    final isSelected = _viewMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _viewMode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<TransactionModel> _filterTransactions(List<TransactionModel> transactions) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    return transactions.where((t) {
      if (_viewMode == DashboardViewMode.weekly) {
        final tDate = DateUtils.dateOnly(t.date);
        final endDate = DateUtils.dateOnly(now);
        final startDate = endDate.subtract(const Duration(days: 6));
        return (tDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
                tDate.isBefore(endDate.add(const Duration(days: 1))));
      } else if (_viewMode == DashboardViewMode.monthly) {
        final tDate = DateUtils.dateOnly(t.date);
        final endDate = DateUtils.dateOnly(now);
        final startDate = endDate.subtract(const Duration(days: 29));
        return (tDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
                tDate.isBefore(endDate.add(const Duration(days: 1))));
      } else {
        return t.date.year == now.year;
      }
    }).toList();
  }

  List<TransactionModel> _filterPreviousTransactions(List<TransactionModel> transactions) {
     final now = DateTime.now();
     final yesterday = now.subtract(const Duration(days: 1));
     
     if (_viewMode == DashboardViewMode.weekly) {
       final endDate = DateUtils.dateOnly(now).subtract(const Duration(days: 7));
       final startDate = endDate.subtract(const Duration(days: 6));
       return transactions.where((t) {
         final tDate = DateUtils.dateOnly(t.date);
         return tDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
                tDate.isBefore(endDate.add(const Duration(days: 1)));
       }).toList();
     } else if (_viewMode == DashboardViewMode.monthly) {
        final endDate = DateUtils.dateOnly(now).subtract(const Duration(days: 30));
        final startDate = endDate.subtract(const Duration(days: 29));
        return transactions.where((t) {
         final tDate = DateUtils.dateOnly(t.date);
         return tDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
                tDate.isBefore(endDate.add(const Duration(days: 1)));
       }).toList();
     } else if (_viewMode == DashboardViewMode.yearly) {
       final lastYear = now.year - 1;
       return transactions.where((t) => t.date.year == lastYear).toList();
     }
     return [];
  }

  List<BarChartGroupData> _generateBarGroups(List<TransactionModel> transactions, [List<TransactionModel> previousTransactions = const []]) {
    final Map<int, double> income = {};
    final Map<int, double> expense = {};
    final Map<int, double> savings = {};
    final Map<int, double> investment = {};
    final Map<int, double> prevExpense = {};
    
    final now = DateTime.now();
    
    int daysCount = 7;
    if (_viewMode == DashboardViewMode.monthly) daysCount = 30;
    if (_viewMode == DashboardViewMode.yearly) daysCount = 12;

    for(int i=0; i<daysCount; i++) {
        income[i] = 0;
        expense[i] = 0;
        savings[i] = 0;
        investment[i] = 0;
        prevExpense[i] = 0;
    }

    if (_viewMode == DashboardViewMode.yearly) {
      for (var t in transactions) {
        final month = t.date.month - 1;
        if (t.type == 'income') {
           income[month] = (income[month] ?? 0) + t.amount;
        } else if (t.type == 'expense') {
           expense[month] = (expense[month] ?? 0) + t.amount;
        } else if (t.type == 'savings') {
           savings[month] = (savings[month] ?? 0) + t.amount;
        } else if (t.type == 'investment') {
           investment[month] = (investment[month] ?? 0) + t.amount;
        }
      }
      if (previousTransactions.isNotEmpty) {
        for (var t in previousTransactions) {
          final month = t.date.month - 1; 
          if (t.type == 'expense') {
             prevExpense[month] = (prevExpense[month] ?? 0) + t.amount;
          }
        }
      }
    } else {
      final endDate = now;
      for (var t in transactions) {
          final tDate = DateUtils.dateOnly(t.date);
          final end = DateUtils.dateOnly(endDate);
          final diff = end.difference(tDate).inDays;
          if(diff >= 0 && diff < daysCount) {
            final x = (daysCount - 1) - diff;
            if (t.type == 'income') {
               income[x] = (income[x] ?? 0) + t.amount;
            } else if (t.type == 'expense') {
               expense[x] = (expense[x] ?? 0) + t.amount;
            } else if (t.type == 'savings') {
               savings[x] = (savings[x] ?? 0) + t.amount;
            } else if (t.type == 'investment') {
               investment[x] = (investment[x] ?? 0) + t.amount;
            }
          }
      }
      if (previousTransactions.isNotEmpty) {
        final prevEndDate = _viewMode == DashboardViewMode.weekly 
            ? endDate.subtract(const Duration(days: 7)) 
            : endDate.subtract(const Duration(days: 30));
        for (var t in previousTransactions) {
          final tDate = DateUtils.dateOnly(t.date);
          final end = DateUtils.dateOnly(prevEndDate);
          final diff = end.difference(tDate).inDays;
           if(diff >= 0 && diff < daysCount) {
             final x = (daysCount - 1) - diff;
             if (t.type == 'expense') {
                prevExpense[x] = (prevExpense[x] ?? 0) + t.amount;
             }
           }
        }
      }
    }

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < daysCount; i++) {
       List<BarChartRodData> rods = [];
       if (_compareMode) {
          rods = [
             _makeRodData(expense[i] ?? 0, AppColors.tertiary),
             _makeRodData(prevExpense[i] ?? 0, Colors.grey.withValues(alpha: 0.5)),
          ];
       } else {
          rods = [
            if ((income[i] ?? 0) > 0) _makeRodData(income[i]!, AppColors.secondary),
            if ((expense[i] ?? 0) > 0) _makeRodData(expense[i]!, AppColors.tertiary),
            if ((savings[i] ?? 0) > 0) _makeRodData(savings[i]!, AppColors.savings),
            if ((investment[i] ?? 0) > 0) _makeRodData(investment[i]!, AppColors.investment),
          ];
       }
      barGroups.add(BarChartGroupData(x: i, barRods: rods));
    }
    return barGroups;
  }

  BarChartRodData _makeRodData(double y, Color color) {
    return BarChartRodData(
      toY: y,
      color: color,
      width: 6,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      backDrawRodData: BackgroundBarChartRodData(show: true, toY: 0, color: Colors.transparent),
    );
  }

  Widget _buildStatsSummary(List<TransactionModel> transactions, String currencySymbol) {
    double updatedIncome = 0;
    double updatedExpense = 0;
    double updatedSavings = 0;
    double updatedInvestment = 0;

    for (var t in transactions) {
      if (t.type == 'income') {
        updatedIncome += t.amount;
      } else if (t.type == 'expense') {
        updatedExpense += t.amount;
      } else if (t.type == 'savings') {
        updatedSavings += t.amount;
      } else if (t.type == 'investment') {
        updatedInvestment += t.amount;
      }
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Income', updatedIncome, AppColors.secondary, currencySymbol)),
            const SizedBox(width: AppValues.gapMedium),
            Expanded(child: _buildSummaryCard('Expense', updatedExpense, AppColors.tertiary, currencySymbol)),
          ],
        ),
        const SizedBox(height: AppValues.gapMedium),
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Savings', updatedSavings, AppColors.savings, currencySymbol)),
            const SizedBox(width: AppValues.gapMedium),
            Expanded(child: _buildSummaryCard('Investment', updatedInvestment, AppColors.investment, currencySymbol)),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, String currencySymbol) {
    return Container(
      padding: const EdgeInsets.all(AppValues.gapMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppValues.borderRadius),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppValues.gapSmall),
          Text(
            '$currencySymbol${amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getBottomTitles(double value, TitleMeta meta, DashboardViewMode mode) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey);
    final now = DateTime.now();
    final endDate = now;
    final int daysCount = mode == DashboardViewMode.weekly ? 7 : 30;
    final int index = value.toInt();
    if (index < 0 || (mode != DashboardViewMode.yearly && index >= daysCount)) return const SizedBox.shrink();

    String text = '';
    if (mode == DashboardViewMode.yearly) {
       if (index >= 0 && index < 12) {
         text = DateFormat('MMM').format(DateTime(2024, index + 1));
       }
    } else {
      final diff = (daysCount - 1) - index;
      final date = endDate.subtract(Duration(days: diff));
      if (mode == DashboardViewMode.weekly) {
         text = DateFormat('E').format(date);
      } else if (mode == DashboardViewMode.monthly) {
        if (index % 5 == 0 || index == daysCount - 1) {
          text = DateFormat('d').format(date);
        }
      }
    }
    return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text(text, style: style));
  }

  Widget _buildTransactionList(List<TransactionModel> transactions, String currencySymbol) {
    return Consumer(
      builder: (context, ref, child) {
        final categoriesAsync = ref.watch(categoriesListProvider);
        final categories = categoriesAsync.valueOrNull ?? [];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transactions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppValues.gapMedium),
            if (transactions.isEmpty) 
                const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No transactions"))),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length > 5 ? 5 : transactions.length, // Only show top 5 here
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final t = transactions[index];
                final isIncome = t.type == 'income';
                final category = categories.cast<CategoryModel?>().firstWhere((c) => c?.id == t.categoryId, orElse: () => null);
                final color = category != null ? Color(category.colorValue) : (isIncome ? AppColors.secondary : AppColors.tertiary);
                final iconName = category?.iconParams ?? (isIncome ? 'arrow_downward' : 'shopping_bag_outlined');
                
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(AppValues.borderRadius),
                    border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_getIcon(iconName, isIncome, t.type), color: color),
                    ),
                    title: Text(t.note.isEmpty ? (category?.name ?? 'Transaction') : t.note, style: Theme.of(context).textTheme.bodyLarge), 
                    subtitle: Text('${DateFormat('MMM d').format(t.date)} • ${DateFormat('h:mm a').format(t.date)}', style: Theme.of(context).textTheme.bodySmall),
                    trailing: Text(
                        '${isIncome ? "+" : "-"}$currencySymbol${t.amount.toStringAsFixed(0)}',
                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isIncome ? AppColors.secondary : Colors.red),
                      ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryBreakdown(List<TransactionModel> transactions, String currencySymbol) {
    return Consumer(
      builder: (context, ref, child) {
        final categoriesAsync = ref.watch(categoriesListProvider);
        final categories = categoriesAsync.valueOrNull ?? [];
        final Map<String, double> categorySpending = {};
        double totalExpense = 0;
        for (var t in transactions) {
          if (t.type == 'expense') {
             categorySpending[t.categoryId] = (categorySpending[t.categoryId] ?? 0) + t.amount;
             totalExpense += t.amount;
          }
        }
        if (categorySpending.isEmpty) return const SizedBox.shrink();
        final sortedEntries = categorySpending.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category Breakdown', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppValues.gapMedium),
            ...sortedEntries.map((e) {
              final cat = categories.firstWhere((c) => c.id == e.key, orElse: () => categories.first);
              final percentage = totalExpense > 0 ? (e.value / totalExpense) : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  padding: const EdgeInsets.all(AppValues.gapMedium),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(AppValues.borderRadius),
                  ),
                  child: Row(
                    children: [
                      Container(
                         padding: const EdgeInsets.all(8),
                         decoration: BoxDecoration(color: Color(cat.colorValue).withValues(alpha: 0.1), shape: BoxShape.circle),
                         child: Icon(_getIcon(cat.iconParams, false, 'expense'), size: 16, color: Color(cat.colorValue)),
                      ),
                      const SizedBox(width: AppValues.gapMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(cat.name, style: Theme.of(context).textTheme.bodyMedium),
                                Text('$currencySymbol${e.value.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: AppValues.gapSmall),
                            LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                              color: Color(cat.colorValue),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppValues.gapMedium),
                      Text('${(percentage * 100).toStringAsFixed(1)}%', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
  
  IconData _getIcon(String iconName, bool isIncome, String type) {
     switch(iconName) {
      case 'fastfood_rounded': return Icons.fastfood_rounded;
      case 'directions_bus_rounded': return Icons.directions_bus_rounded;
      case 'shopping_bag_rounded': return Icons.shopping_bag_rounded;
      case 'receipt_long_rounded': return Icons.receipt_long_rounded;
      case 'movie_rounded': return Icons.movie_rounded;
      case 'work_rounded': return Icons.work_rounded;
      default: 
        if (type == 'savings') return Icons.savings_rounded;
        if (type == 'investment') return Icons.trending_up_rounded;
        return isIncome ? Icons.arrow_downward : Icons.category_rounded;
    }
  }

  void _showExportDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const _ExportDialog());
  }
}

class _ExportDialog extends ConsumerStatefulWidget {
  const _ExportDialog();
  @override
  ConsumerState<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<_ExportDialog> {
  String _format = 'CSV';
  String _rangeMode = 'Monthly';
  DateTimeRange? _customRange;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Format'),
            trailing: DropdownButton<String>(
              value: _format,
              items: ['CSV', 'PDF'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (val) => setState(() => _format = val!),
            ),
          ),
          ListTile(
            title: const Text('Range'),
            trailing: DropdownButton<String>(
              value: _rangeMode,
              items: ['Weekly', 'Monthly', 'Yearly', 'Custom']
                  .map((m) => DropdownMenuItem(value: m, child: Text(m.toUpperCase())))
                  .toList(),
              onChanged: (val) {
                setState(() => _rangeMode = val!);
                if (val == 'Custom') _pickDateRange();
              },
            ),
          ),
          if (_rangeMode == 'Custom' && _customRange != null)
             Text('${DateFormat('MMM d').format(_customRange!.start)} - ${DateFormat('MMM d').format(_customRange!.end)}', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            final transactions = ref.read(transactionsListProvider).valueOrNull ?? [];
            final categories = ref.read(categoriesListProvider).valueOrNull ?? [];
            final settings = ref.read(settingsProvider).valueOrNull;
            final now = DateTime.now();
            List<TransactionModel> filtered = [];
            if (_rangeMode == 'Weekly') {
              final startDate = DateUtils.dateOnly(now).subtract(const Duration(days: 6));
              filtered = transactions.where((t) => t.date.isAfter(startDate.subtract(const Duration(days: 1)))).toList();
            } else if (_rangeMode == 'Monthly') {
              final startDate = DateUtils.dateOnly(now).subtract(const Duration(days: 29));
              filtered = transactions.where((t) => t.date.isAfter(startDate.subtract(const Duration(days: 1)))).toList();
            } else if (_rangeMode == 'Yearly') {
              filtered = transactions.where((t) => t.date.year == now.year).toList();
            } else if (_rangeMode == 'Custom' && _customRange != null) {
              filtered = transactions.where((t) => t.date.isAfter(_customRange!.start.subtract(const Duration(seconds: 1))) && t.date.isBefore(_customRange!.end.add(const Duration(days: 1)))).toList();
            } else { filtered = transactions; }

            if (!context.mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exporting ${filtered.length} transactions as $_format...')));
            final symbol = settings?.currencySymbol ?? r'$';
            final title = _rangeMode == 'Custom' && _customRange != null ? '${DateFormat('MMM d').format(_customRange!.start)}-${DateFormat('MMM d').format(_customRange!.end)}' : _rangeMode.toUpperCase();
            try {
              await ReportService.exportTransactions(transactions: filtered, categories: categories, format: _format, currencySymbol: symbol, rangeTitle: title);
            } catch (e) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red));
            }
          },
          child: const Text('Export'),
        ),
      ],
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now(), initialDateRange: _customRange);
    if (picked != null) setState(() => _customRange = picked);
    else if (_customRange == null) setState(() => _rangeMode = 'Monthly');
  }
}
