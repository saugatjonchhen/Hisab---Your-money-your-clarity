import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart';
import 'package:finance_app/features/transactions/data/models/transaction_model.dart';
import 'package:finance_app/features/dashboard/presentation/widgets/income_expense_chart.dart';
import 'package:finance_app/features/transactions/data/models/category_model.dart';

import 'package:finance_app/features/transactions/data/providers/category_provider.dart';
import 'package:finance_app/features/transactions/data/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_app/features/dashboard/presentation/pages/detailed_stats_page.dart';
import 'package:intl/intl.dart';
import 'package:finance_app/features/transactions/presentation/pages/add_transaction_page.dart';


class AllTransactionsPage extends ConsumerStatefulWidget {
  final String? initialFilter;
  const AllTransactionsPage({super.key, this.initialFilter});

  @override
  ConsumerState<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends ConsumerState<AllTransactionsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late String _selectedFilter;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter ?? 'All';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _confirmDelete(TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(transactionsListProvider.notifier).deleteTransaction(transaction.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);
    final settingsAsync = ref.watch(settingsProvider);

    final currencySymbol = settingsAsync.when(
      data: (s) => s.currencySymbol,
      loading: () => '\$',
      error: (_, __) => '\$',
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transactions'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'History', icon: Icon(Icons.history_rounded)),
              Tab(text: 'Analysis', icon: Icon(Icons.analytics_outlined)),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                _dateRange != null ? Icons.date_range_rounded : Icons.calendar_today_outlined,
                color: _dateRange != null ? AppColors.primary : null,
              ),
              onPressed: _selectDateRange,
              tooltip: 'Filter by date range',
            ),
            if (_dateRange != null)
              IconButton(
                icon: const Icon(Icons.clear_rounded, size: 20),
                onPressed: () => setState(() => _dateRange = null),
                tooltip: 'Clear date filter',
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: TabBarView(
          children: [
            // History Tab
            _buildHistoryTab(transactionsAsync, categoriesAsync, currencySymbol),
            // Analysis Tab
            _buildAnalysisTab(transactionsAsync, currencySymbol),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(AsyncValue<List<TransactionModel>> transactionsAsync, AsyncValue<List<CategoryModel>> categoriesAsync, String currencySymbol) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppValues.gapMedium),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: const Icon(Icons.search_rounded),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppValues.gapMedium,
                vertical: AppValues.gapSmall,
              ),
              filled: true,
              fillColor: Theme.of(context).cardTheme.color,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppValues.gapMedium),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'All', 'Expense', 'Income', 'Savings', 'Investment'
              ].map((f) => Padding(
                padding: const EdgeInsets.only(right: AppValues.gapSmall),
                child: _buildFilterChip(f, f),
              )).toList(),
            ),
          ),
        ),
        if (_dateRange != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(AppValues.gapMedium, AppValues.gapSmall, AppValues.gapMedium, 0),
            child: Row(
              children: [
                const Icon(Icons.date_range_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('MMM d, yyyy').format(_dateRange!.start)} - ${DateFormat('MMM d, yyyy').format(_dateRange!.end)}',
                  style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.primary),
                ),
              ],
            ),
          ),
        Expanded(
          child: transactionsAsync.when(
            data: (transactions) {
              final filtered = transactions.where((t) {
                final matchesQuery = t.note.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    (t.categoryId.toLowerCase().contains(_searchQuery.toLowerCase()));
                final matchesType = _selectedFilter == 'All' || t.type == _selectedFilter.toLowerCase();
                
                bool matchesDate = true;
                if (_dateRange != null) {
                  matchesDate = (t.date.isAfter(_dateRange!.start.subtract(const Duration(seconds: 1))) && 
                                t.date.isBefore(_dateRange!.end.add(const Duration(days: 1))));
                }
                
                return matchesQuery && matchesType && matchesDate;
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
                      const SizedBox(height: AppValues.gapMedium),
                      const Text('No transactions found', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: AppValues.screenPadding,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final t = filtered[index];
                  final isIncome = t.type == 'income';
                  
                  return categoriesAsync.when(
                    data: (cats) {
                      final category = cats.firstWhere(
                        (c) => c.id == t.categoryId,
                        orElse: () => cats.first,
                      );
                      
                      final color = Color(category.colorValue);
                      final iconName = category.iconParams;

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppValues.gapMedium),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(AppValues.borderRadius),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(AppValues.gapSmall),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppValues.borderRadiusSmall),
                            ),
                            child: Icon(
                              _getIcon(iconName, isIncome, t.type),
                              color: color,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            t.note.isEmpty ? category.name : t.note,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            DateFormat('MMM dd, yyyy').format(t.date),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${isIncome ? '+' : '-'}$currencySymbol${t.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isIncome ? AppColors.secondary : AppColors.tertiary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert_rounded, size: 20, color: Colors.grey),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => AddTransactionPage(initialTransaction: t)),
                                    );
                                  } else if (value == 'delete') {
                                    _confirmDelete(t);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined, size: 20),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddTransactionPage(initialTransaction: t)),
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisTab(AsyncValue<List<TransactionModel>> transactionsAsync, String currencySymbol) {
    return transactionsAsync.when(
      data: (transactions) {
        // Filter by date range if selected
        final filtered = transactions.where((t) {
          if (_dateRange == null) return true;
          return (t.date.isAfter(_dateRange!.start.subtract(const Duration(seconds: 1))) && 
                  t.date.isBefore(_dateRange!.end.add(const Duration(days: 1))));
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No transactions for analysis'));
        }

        // We can basically use the logic from DetailedStatsPage here
        // or just navigate to it if preferred, but user said "move details and visualizations to a separate screen inside transactions tab"
        // I'll implement a condensed version of DetailedStatsPage here.
        
        return MultiSectionAnalysis(transactions: filtered, currencySymbol: currencySymbol);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppValues.borderRadiusSmall)),
      side: BorderSide.none,
      backgroundColor: Theme.of(context).cardTheme.color,
    );
  }

  IconData _getIcon(String iconName, bool isIncome, String type) {
    switch (iconName) {
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
      default:
        if (type == 'savings') return Icons.savings_rounded;
        if (type == 'investment') return Icons.trending_up_rounded;
        return isIncome ? Icons.arrow_downward : Icons.category_rounded;
    }
  }
}

class MultiSectionAnalysis extends ConsumerWidget {
  final List<TransactionModel> transactions;
  final String currencySymbol;

  const MultiSectionAnalysis({
    super.key,
    required this.transactions,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesListProvider);
    final categories = categoriesAsync.valueOrNull ?? [];

    double income = 0;
    double expense = 0;
    double savings = 0;
    double investment = 0;

    final Map<String, double> categorySpending = {};

    for (var t in transactions) {
      if (t.type == 'income') income += t.amount;
      else if (t.type == 'expense') {
        expense += t.amount;
        categorySpending[t.categoryId] = (categorySpending[t.categoryId] ?? 0) + t.amount;
      }
      else if (t.type == 'savings') savings += t.amount;
      else if (t.type == 'investment') investment += t.amount;
    }

    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: AppValues.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryGrid(income, expense, savings, investment),
          const SizedBox(height: AppValues.gapLarge),
          Text(
            'Expense Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppValues.gapMedium),
          if (sortedCategories.isEmpty)
            const Center(child: Text('No expenses to show'))
          else
            ...sortedCategories.map((e) {
              final cat = categories.firstWhere(
                (c) => c.id == e.key,
                orElse: () => CategoryModel(id: 'unknown', name: 'Unknown', iconParams: 'category', colorValue: Colors.grey.value, type: 'expense'),
              );
              final percentage = expense > 0 ? e.value / expense : 0.0;
              return _buildCategoryItem(context, cat, e.value, percentage);
            }),
          const SizedBox(height: AppValues.gapLarge),
          // Link to full stats page for deep dive
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DetailedStatsPage()),
                );
              },
              icon: const Icon(Icons.insights_rounded),
              label: const Text('View Detailed Analytics'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 100), // Space for FAB if any
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(double income, double expense, double savings, double investment) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppValues.gapMedium,
      mainAxisSpacing: AppValues.gapMedium,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Income', income, AppColors.secondary, Icons.arrow_downward),
        _buildStatCard('Expense', expense, AppColors.tertiary, Icons.arrow_upward),
        _buildStatCard('Savings', savings, AppColors.savings, Icons.savings_rounded),
        _buildStatCard('Investment', investment, AppColors.investment, Icons.trending_up_rounded),
      ],
    );
  }

  Widget _buildStatCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppValues.gapMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              '$currencySymbol${amount.toStringAsFixed(0)}',
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryModel cat, double amount, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(cat.colorValue).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(cat.iconParams),
              size: 20,
              color: Color(cat.colorValue),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text('$currencySymbol${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey.withOpacity(0.1),
                    color: Color(cat.colorValue),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('${(percentage * 100).toStringAsFixed(1)}%', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'fastfood_rounded': return Icons.fastfood_rounded;
      case 'directions_bus_rounded': return Icons.directions_bus_rounded;
      case 'shopping_bag_rounded': return Icons.shopping_bag_rounded;
      case 'receipt_long_rounded': return Icons.receipt_long_rounded;
      case 'movie_rounded': return Icons.movie_rounded;
      case 'work_rounded': return Icons.work_rounded;
      default: return Icons.category_rounded;
    }
  }
}
