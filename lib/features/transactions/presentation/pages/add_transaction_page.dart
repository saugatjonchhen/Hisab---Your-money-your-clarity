import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart';
import 'package:finance_app/features/transactions/data/models/transaction_model.dart';
import 'package:finance_app/features/transactions/data/providers/transaction_provider.dart';
import 'package:finance_app/features/transactions/data/providers/category_provider.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_app/core/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  final TransactionModel? initialTransaction;
  final DateTime? initialDate;

  const AddTransactionPage(
      {super.key, this.initialTransaction, this.initialDate});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  late String _selectedType;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialTransaction?.amount.toString() ?? '',
    );
    _noteController = TextEditingController(
      text: widget.initialTransaction?.note ?? '',
    );
    _selectedDate =
        widget.initialTransaction?.date ?? widget.initialDate ?? DateTime.now();
    _selectedType = widget.initialTransaction?.type ?? 'expense';
    _selectedCategoryId = widget.initialTransaction?.categoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesListProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final filteredCategories = categoriesAsync.when(
      data: (cats) => cats.where((c) => c.type == _selectedType).toList(),
      loading: () => [],
      error: (_, __) => [],
    );

    final currencySymbol = settingsAsync.when(
      data: (s) => s.currencySymbol,
      loading: () => '\$',
      error: (_, __) => '\$',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialTransaction == null
            ? 'Add Transaction'
            : 'Edit Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: AppValues.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeSelector(),
              const SizedBox(height: AppValues.gapLarge),
              const Text('Amount',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: AppValues.gapSmall),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppValues.gapSmall,
                        vertical: AppValues.gapSmall),
                    child: Text(currencySymbol,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                  hintText: '0.00',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppValues.gapLarge),
              const Text('Category',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: AppValues.gapSmall),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...filteredCategories.map((cat) {
                    final isSelected = _selectedCategoryId == cat.id;
                    return FilterChip(
                      label: Text(cat.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() =>
                            _selectedCategoryId = selected ? cat.id : null);
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppValues.gapSmall,
                          vertical: AppValues.gapExtraSmall),
                    );
                  }),
                  ActionChip(
                    avatar: const Icon(Icons.add_rounded,
                        size: 16, color: AppColors.primary),
                    label: const Text('Add New',
                        style: TextStyle(color: AppColors.primary)),
                    onPressed: () => _showAddCategorySheet(context),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppValues.borderRadiusSmall)),
                  ),
                ],
              ),
              const SizedBox(height: AppValues.gapLarge),
              const Text('Date',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: AppValues.gapSmall),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(AppValues.gapMedium),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(AppValues.borderRadius),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: AppValues.gapMedium),
                      Text(
                        DateFormat('MMMM dd, yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppValues.gapLarge),
              const Text('Note',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: AppValues.gapSmall),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  hintText: 'What was this for?',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppValues.gapExtraLarge),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  child: Text(widget.initialTransaction == null
                      ? 'Save Transaction'
                      : 'Update Transaction'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(AppValues.gapExtraSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppValues.borderRadius),
      ),
      child: Row(
        children: [
          _buildTypeButton('Expense', 'expense', AppColors.tertiary),
          _buildTypeButton('Income', 'income', AppColors.secondary),
          _buildTypeButton('Savings', 'savings', AppColors.savings),
          _buildTypeButton('Invest', 'investment', AppColors.investment),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, String type, Color color) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            _selectedCategoryId = null; // Reset category when type changes
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppValues.gapMedium),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(AppValues.borderRadius),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showAddCategorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddCategorySheet(type: _selectedType),
    ).then((categoryId) {
      if (categoryId != null && categoryId is String) {
        setState(() => _selectedCategoryId = categoryId);
      }
    });
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || _selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Please select a category and enter a valid amount')),
        );
        return;
      }

      if (widget.initialTransaction == null) {
        ref.read(transactionsListProvider.notifier).addTransaction(
              amount: amount,
              note: _noteController.text,
              date: _selectedDate,
              type: _selectedType,
              categoryId: _selectedCategoryId!,
            );
      } else {
        final updated = widget.initialTransaction!.copyWith(
          amount: amount,
          note: _noteController.text,
          date: _selectedDate,
          type: _selectedType,
          categoryId: _selectedCategoryId!,
        );
        ref.read(transactionsListProvider.notifier).updateTransaction(updated);
      }

      AnalyticsService().logTransactionAdded(
        category: _selectedCategoryId!,
        amount: amount,
        type: _selectedType,
      );

      Navigator.pop(context);
    }
  }
}

class _AddCategorySheet extends ConsumerStatefulWidget {
  final String type;
  const _AddCategorySheet({required this.type});

  @override
  ConsumerState<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends ConsumerState<_AddCategorySheet> {
  final _nameController = TextEditingController();
  String _selectedIcon = 'category_rounded';
  Color _selectedColor = AppColors.primary;

  final List<String> _icons = [
    'category_rounded',
    'fastfood_rounded',
    'directions_bus_rounded',
    'shopping_bag_rounded',
    'receipt_long_rounded',
    'movie_rounded',
    'work_rounded',
    'savings_rounded',
    'trending_up_rounded',
    'medical_services_rounded',
    'fitness_center_rounded',
    'home_rounded',
    'school_rounded',
  ];

  final List<Color> _colors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.tertiary,
    AppColors.savings,
    AppColors.investment,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.cyan,
    Colors.amber,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppValues.gapLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Category',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppValues.gapLarge),
            const Text('Category Name',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppValues.gapSmall),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'e.g. Groceries'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppValues.gapLarge),
            const Text('Icon', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppValues.gapSmall),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _icons.length,
                itemBuilder: (context, index) {
                  final iconName = _icons[index];
                  final isSelected = _selectedIcon == iconName;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = iconName),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withOpacity(0.1)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? _selectedColor
                              : Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Icon(
                        _getIcon(iconName),
                        color: isSelected ? _selectedColor : Colors.grey,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppValues.gapLarge),
            const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppValues.gapSmall),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _colors.length,
                itemBuilder: (context, index) {
                  final color = _colors[index];
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 10)
                              ]
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppValues.gapExtraLarge),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.isEmpty) return;
                  final categoryId = await ref
                      .read(categoriesListProvider.notifier)
                      .addCategory(
                        name: _nameController.text,
                        iconName: _selectedIcon,
                        colorValue: _selectedColor.value,
                        type: widget.type,
                      );
                  if (context.mounted) Navigator.pop(context, categoryId);
                },
                child: const Text('Add Category'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String iconName) {
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
        return Icons.category_rounded;
    }
  }
}
