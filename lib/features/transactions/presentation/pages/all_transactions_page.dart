import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart';
import 'package:finance_app/features/transactions/data/models/transaction_model.dart';
import 'package:fl_chart/fl_chart.dart';
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
  ConsumerState<AllTransactionsPage> createState() =>
      _AllTransactionsPageState();
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
        content:
            const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(transactionsListProvider.notifier)
                  .deleteTransaction(transaction.id);
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
                _dateRange != null
                    ? Icons.date_range_rounded
                    : Icons.calendar_today_outlined,
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
            _buildHistoryTab(
                transactionsAsync, categoriesAsync, currencySymbol),
            // Analysis Tab
            _buildAnalysisTab(transactionsAsync, currencySymbol),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(AsyncValue<List<TransactionModel>> transactionsAsync,
      AsyncValue<List<CategoryModel>> categoriesAsync, String currencySymbol) {
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
              children: ['All', 'Expense', 'Income', 'Savings', 'Investment']
                  .map((f) => Padding(
                        padding:
                            const EdgeInsets.only(right: AppValues.gapSmall),
                        child: _buildFilterChip(f, f),
                      ))
                  .toList(),
            ),
          ),
        ),
        if (_dateRange != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(AppValues.gapMedium,
                AppValues.gapSmall, AppValues.gapMedium, 0),
            child: Row(
              children: [
                const Icon(Icons.date_range_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('MMM d, yyyy').format(_dateRange!.start)} - ${DateFormat('MMM d, yyyy').format(_dateRange!.end)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, color: AppColors.primary),
                ),
              ],
            ),
          ),
        Expanded(
          child: transactionsAsync.when(
            data: (transactions) {
              final filtered = transactions.where((t) {
                final matchesQuery =
                    t.note.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        (t.categoryId
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()));
                final matchesType = _selectedFilter == 'All' ||
                    t.type == _selectedFilter.toLowerCase();

                bool matchesDate = true;
                if (_dateRange != null) {
                  matchesDate = (t.date.isAfter(_dateRange!.start
                          .subtract(const Duration(seconds: 1))) &&
                      t.date.isBefore(
                          _dateRange!.end.add(const Duration(days: 1))));
                }

                return matchesQuery && matchesType && matchesDate;
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_rounded,
                          size: 80, color: Colors.grey.withOpacity(0.3)),
                      const SizedBox(height: AppValues.gapMedium),
                      const Text('No transactions found',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
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
                        margin:
                            const EdgeInsets.only(bottom: AppValues.gapMedium),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius:
                              BorderRadius.circular(AppValues.borderRadius),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(AppValues.gapSmall),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  AppValues.borderRadiusSmall),
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
                                  color: isIncome
                                      ? AppColors.secondary
                                      : AppColors.tertiary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert_rounded,
                                    size: 20, color: Colors.grey),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AddTransactionPage(
                                                  initialTransaction: t)),
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
                                        Icon(Icons.delete_outline_rounded,
                                            size: 20, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddTransactionPage(initialTransaction: t)),
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

  Widget _buildAnalysisTab(AsyncValue<List<TransactionModel>> transactionsAsync,
      String currencySymbol) {
    return transactionsAsync.when(
      data: (transactions) {
        // Filter by date range if selected
        final filtered = transactions.where((t) {
          if (_dateRange == null) return true;
          return (t.date.isAfter(
                  _dateRange!.start.subtract(const Duration(seconds: 1))) &&
              t.date.isBefore(_dateRange!.end.add(const Duration(days: 1))));
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No transactions for analysis'));
        }

        // We can basically use the logic from DetailedStatsPage here
        // or just navigate to it if preferred, but user said "move details and visualizations to a separate screen inside transactions tab"
        // I'll implement a condensed version of DetailedStatsPage here.

        return MultiSectionAnalysis(
            transactions: filtered, currencySymbol: currencySymbol);
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
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppValues.borderRadiusSmall)),
      side: BorderSide.none,
      backgroundColor: Theme.of(context).cardTheme.color,
    );
  }

  IconData _getIcon(String iconName, bool isIncome, String type) {
    switch (iconName) {
      case 'fastfood_rounded':
        return Icons.fastfood_rounded;
      case 'directions_bus_rounded':
        return Icons.directions_bus_rounded;
      case 'shopping_bag_rounded':
        return Icons.shopping_bag_rounded;
      case 'receipt_long_rounded':
        return Icons.receipt_long_rounded;
      case 'movie_rounded':
        return Icons.movie_rounded;
      case 'work_rounded':
        return Icons.work_rounded;
      case 'savings_rounded':
        return Icons.savings_rounded;
      case 'trending_up_rounded':
        return Icons.trending_up_rounded;
      case 'medical_services_rounded':
        return Icons.medical_services_rounded;
      case 'fitness_center_rounded':
        return Icons.fitness_center_rounded;
      case 'home_rounded':
        return Icons.home_rounded;
      case 'school_rounded':
        return Icons.school_rounded;
      default:
        if (type == 'savings') return Icons.savings_rounded;
        if (type == 'investment') return Icons.trending_up_rounded;
        return isIncome ? Icons.arrow_downward : Icons.category_rounded;
    }
  }
}

class MultiSectionAnalysis extends ConsumerStatefulWidget {
  final List<TransactionModel> transactions;
  final String currencySymbol;

  const MultiSectionAnalysis({
    super.key,
    required this.transactions,
    required this.currencySymbol,
  });

  @override
  ConsumerState<MultiSectionAnalysis> createState() =>
      _MultiSectionAnalysisState();
}

class _MultiSectionAnalysisState extends ConsumerState<MultiSectionAnalysis> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesListProvider);
    final categories = categoriesAsync.valueOrNull ?? [];

    double income = 0;
    double expense = 0;
    double savings = 0;
    double investment = 0;

    final Map<String, double> categorySpending = {};

    for (var t in widget.transactions) {
      if (t.type == 'income')
        income += t.amount;
      else if (t.type == 'expense') {
        expense += t.amount;
        categorySpending[t.categoryId] =
            (categorySpending[t.categoryId] ?? 0) + t.amount;
      } else if (t.type == 'savings')
        savings += t.amount;
      else if (t.type == 'investment') investment += t.amount;
    }

    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Prepare data for painter
    final List<ChartLabelItem> labelItems = [];
    if (expense > 0) {
      for (var entry in sortedCategories) {
        final cat = categories.firstWhere(
          (c) => c.id == entry.key,
          orElse: () => CategoryModel(
              id: 'unknown',
              name: 'Unknown',
              iconParams: 'category',
              colorValue: Colors.grey.value,
              type: 'expense'),
        );
        labelItems.add(ChartLabelItem(
          value: entry.value,
          color: Color(cat.colorValue),
          text:
              '${cat.name}\n${((entry.value / expense) * 100).toStringAsFixed(1)}%',
        ));
      }
    }

    return SingleChildScrollView(
      padding: AppValues.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryGrid(income, expense, savings, investment),
          const SizedBox(height: AppValues.gapLarge),
          Text(
            'Expense Breakdown',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppValues.gapMedium),
          if (sortedCategories.isEmpty)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No expenses to show'),
            ))
          else
            Column(
              children: [
                SizedBox(
                  height: 400, // Increased height for labels
                  child: Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          startDegreeOffset:
                              -90, // Ensure strictly top-aligned start to match painter
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
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
                          sectionsSpace: 0,
                          centerSpaceRadius: 0,
                          sections: _showingSections(
                              sortedCategories, categories, expense),
                        ),
                      ),
                      IgnorePointer(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: PieChartLabelPainter(
                            items: labelItems,
                            // The PieChart itself centers within its SizedBox.
                            // We need to pass the radius used by the PieChart sections.
                            radius:
                                80, // This should match the base radius in _showingSections
                            textColor: Theme.of(context).colorScheme.onSurface,
                            dividerColor: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Legend - Keep it for quick reference
                const SizedBox(height: AppValues.gapLarge),
                ...sortedCategories.map((e) {
                  final cat = categories.firstWhere(
                    (c) => c.id == e.key,
                    orElse: () => CategoryModel(
                        id: 'unknown',
                        name: 'Unknown',
                        iconParams: 'category',
                        colorValue: Colors.grey.value,
                        type: 'expense'),
                  );
                  final percentage = expense > 0 ? e.value / expense : 0.0;
                  return _buildLegendItem(cat, e.value, percentage);
                }),
              ],
            ),

          const SizedBox(height: AppValues.gapLarge),
          // Link to full stats page for deep dive
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DetailedStatsPage()),
                );
              },
              icon: const Icon(Icons.insights_rounded),
              label: const Text('View Detailed Analytics'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 100), // Space for FAB if any
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingSections(
    List<MapEntry<String, double>> sortedCategories,
    List<CategoryModel> categories,
    double totalExpense,
  ) {
    return List.generate(sortedCategories.length, (i) {
      final isTouched = i == touchedIndex;
      final radius =
          isTouched ? 90.0 : 80.0; // Reduced radius to make room for labels
      final entry = sortedCategories[i];
      final cat = categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => CategoryModel(
            id: 'unknown',
            name: 'Unknown',
            iconParams: 'category',
            colorValue: Colors.grey.value,
            type: 'expense'),
      );

      return PieChartSectionData(
        color: Color(cat.colorValue),
        value: entry.value,
        title: '', // Hiding native titles
        radius: radius,
        showTitle: false,
        borderSide:
            const BorderSide(color: Colors.black12, width: 1), // Separator
      );
    });
  }

  Widget _buildSummaryGrid(
      double income, double expense, double savings, double investment) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppValues.gapMedium,
      mainAxisSpacing: AppValues.gapMedium,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
            'Income', income, AppColors.secondary, Icons.arrow_downward),
        _buildStatCard(
            'Expense', expense, AppColors.tertiary, Icons.arrow_upward),
        _buildStatCard(
            'Savings', savings, AppColors.savings, Icons.savings_rounded),
        _buildStatCard('Investment', investment, AppColors.investment,
            Icons.trending_up_rounded),
      ],
    );
  }

  Widget _buildStatCard(
      String title, double amount, Color color, IconData icon) {
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
              Text(title,
                  style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              '${widget.currencySymbol}${amount.toStringAsFixed(0)}',
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(CategoryModel cat, double amount, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(cat.colorValue),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              cat.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '${(percentage * 100).toStringAsFixed(1)}%',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.currencySymbol}${amount.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class ChartLabelItem {
  final double value;
  final Color color;
  final String text;

  ChartLabelItem(
      {required this.value, required this.color, required this.text});
}

class PieChartLabelPainter extends CustomPainter {
  final List<ChartLabelItem> items;
  final double radius;
  final Color textColor;
  final Color dividerColor;

  PieChartLabelPainter({
    required this.items,
    required this.radius,
    required this.textColor,
    required this.dividerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final total = items.fold(0.0, (sum, item) => sum + item.value);

    double currentAngle = -math.pi / 2; // Start from top (-90 degrees)

    // Calculate initial positions
    List<_LabelPos> labelPositions = [];

    for (var item in items) {
      final sweepAngle = (item.value / total) * 2 * math.pi;
      final midAngle = currentAngle + sweepAngle / 2;

      // Start exactly at the chart edge
      final anchorRadius = radius;
      final anchorX = center.dx + anchorRadius * math.cos(midAngle);
      final anchorY = center.dy + anchorRadius * math.sin(midAngle);

      // Calculate ideal label start point (outside the slice)
      // Push labels further out to avoid crowding near the chart
      final labelRadius = radius + 40;
      final idealX = center.dx + labelRadius * math.cos(midAngle);
      final idealY = center.dy + labelRadius * math.sin(midAngle);

      final isRightSide = math.cos(midAngle) >= 0;

      labelPositions.add(_LabelPos(
        item: item,
        midAngle: midAngle,
        anchor: Offset(anchorX, anchorY),
        idealPos: Offset(idealX, idealY),
        isRightSide: isRightSide,
      ));

      currentAngle += sweepAngle;
    }

    // Resolve Overlaps
    _resolveOverlaps(labelPositions.where((l) => l.isRightSide).toList(), size);
    _resolveOverlaps(
        labelPositions.where((l) => !l.isRightSide).toList(), size);

    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    final paint = Paint()
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()..style = PaintingStyle.fill;

    for (var pos in labelPositions) {
      paint.color = pos.item.color;
      dotPaint.color = pos.item.color;

      // Draw Anchor Dot
      // canvas.drawCircle(pos.anchor, 2.0, dotPaint); // Removed to avoid "drawing on top" look

      // Draw Leader Line with three segments:
      // 1. Start at chart edge
      // 2. Go outward radially to clear the chart
      // 3. Angle to the label position
      final path = Path();
      path.moveTo(pos.anchor.dx, pos.anchor.dy);

      // Segment 1: Go outward radially to get clear of the chart
      final clearRadius = radius + 15;
      final clearX = center.dx + clearRadius * math.cos(pos.midAngle);
      final clearY = center.dy + clearRadius * math.sin(pos.midAngle);
      path.lineTo(clearX, clearY);

      // Segment 2: Go to the label position (creating the angled segment)
      path.lineTo(pos.finalPos.dx, pos.finalPos.dy);

      // Segment 3: Horizontal tail
      final tailEnd = Offset(
          pos.finalPos.dx + (pos.isRightSide ? 20 : -20), pos.finalPos.dy);
      path.lineTo(tailEnd.dx, tailEnd.dy);

      canvas.drawPath(path, paint);

      // Draw Text
      textPainter.text = TextSpan(
        children: [
          TextSpan(
            text: pos.item.text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
        ],
      );
      textPainter.layout();

      final textOffset = Offset(
        pos.isRightSide ? tailEnd.dx + 4 : tailEnd.dx - textPainter.width - 4,
        tailEnd.dy - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }
  }

  void _resolveOverlaps(List<_LabelPos> group, Size size) {
    if (group.isEmpty) return;

    // Sort by Ideal Y
    group.sort((a, b) => a.idealPos.dy.compareTo(b.idealPos.dy));

    const minSpacing = 28.0; // Increased spacing for clarity

    // Basic collision resolution: Push Down
    for (int i = 0; i < group.length - 1; i++) {
      final current = group[i];
      final next = group[i + 1];

      if (next.idealPos.dy < current.finalPos.dy + minSpacing) {
        // Push next down
        final newY = current.finalPos.dy + minSpacing;
        next.finalPos = Offset(next.finalPos.dx, newY);
      } else {
        next.finalPos = next.idealPos;
      }
    }

    // Check if we pushed too far down (bottom bound)?
    // For now, let's just accept the push.
    // Ideally we should center the group if it exceeds bounds, but "Push Down" is safer for top-down lists.
  }

  @override
  bool shouldRepaint(covariant PieChartLabelPainter oldDelegate) {
    return oldDelegate.items != items;
  }
}

class _LabelPos {
  final ChartLabelItem item;
  final double midAngle;
  final Offset anchor;
  final Offset idealPos;
  final bool isRightSide;
  Offset finalPos;

  _LabelPos({
    required this.item,
    required this.midAngle,
    required this.anchor,
    required this.idealPos,
    required this.isRightSide,
  }) : finalPos = idealPos;
}
