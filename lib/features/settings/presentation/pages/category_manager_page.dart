import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_app/features/transactions/data/models/category_model.dart';
import 'package:finance_app/features/transactions/data/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryManagerPage extends ConsumerWidget {
  const CategoryManagerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesListProvider);
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddEditCategorySheet(context, ref),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          final sortedCategories = List<CategoryModel>.from(categories)
            ..sort((a, b) {
              const typeOrder = {
                'income': 0,
                'expense': 1,
                'savings': 2,
                'investment': 3
              };
              final typeCompare =
                  (typeOrder[a.type] ?? 99).compareTo(typeOrder[b.type] ?? 99);
              if (typeCompare != 0) return typeCompare;
              return a.name.compareTo(b.name);
            });

          return ListView.separated(
            padding: AppValues.screenPadding,
            itemCount: sortedCategories.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppValues.gapMedium),
            itemBuilder: (context, index) {
              final category = sortedCategories[index];
              return _buildCategoryTile(context, ref, category, isSmallScreen);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, WidgetRef ref,
      CategoryModel category, bool isSmallScreen) {
    final color = Color(category.colorValue);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppValues.borderRadiusLarge),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppValues.horizontalPadding,
          vertical: AppValues.gapSmall,
        ),
        leading: Container(
          padding: const EdgeInsets.all(AppValues.gapSmall),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getIcon(category.iconParams),
              color: color, size: isSmallScreen ? 20 : 24),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          category.type.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Budget',
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text(
                  category.budgetLimit > 0
                      ? '\$${category.budgetLimit.toStringAsFixed(0)}'
                      : 'No Limit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: category.budgetLimit > 0
                        ? AppColors.primary
                        : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppValues.gapSmall),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () =>
                  _showAddEditCategorySheet(context, ref, category),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditCategorySheet(BuildContext context, WidgetRef ref,
      [CategoryModel? category]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditCategorySheet(category: category),
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
      case 'real_estate_agent_rounded':
        return Icons.real_estate_agent_rounded;
      case 'lock_outline_rounded':
        return Icons.lock_outline_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}

class _EditCategorySheet extends ConsumerStatefulWidget {
  final CategoryModel? category;
  const _EditCategorySheet({this.category});

  @override
  ConsumerState<_EditCategorySheet> createState() => _EditCategorySheetState();
}

class _EditCategorySheetState extends ConsumerState<_EditCategorySheet> {
  late TextEditingController _nameController;
  late TextEditingController _budgetController;
  late String _selectedIcon;
  late Color _selectedColor;
  late String _selectedType;

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
    'real_estate_agent_rounded',
    'lock_outline_rounded',
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
    Colors.teal,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _budgetController = TextEditingController(
      text: widget.category?.budgetLimit != null &&
              widget.category!.budgetLimit > 0
          ? widget.category!.budgetLimit.toString()
          : '',
    );
    _selectedIcon = widget.category?.iconParams ?? 'category_rounded';
    _selectedColor = widget.category != null
        ? Color(widget.category!.colorValue)
        : AppColors.primary;
    _selectedType = widget.category?.type ?? 'expense';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;
    final settingsAsync = ref.watch(settingsProvider);
    final currencySymbol = settingsAsync.when(
      data: (s) => s.currencySymbol,
      loading: () => '\$',
      error: (_, __) => '\$',
    );

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
                Text(
                  isEdit ? 'Edit Category' : 'Add Category',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
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
            const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppValues.gapSmall),
            Container(
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
                  _buildTypeButton(
                      'Invest', 'investment', AppColors.investment),
                ],
              ),
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
                            ? _selectedColor.withValues(alpha: 0.1)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? _selectedColor
                              : Colors.grey.withValues(alpha: 0.2),
                          width: 2,
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
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 10)
                              ]
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppValues.gapLarge),
            const Text('Monthly Budget Limit (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppValues.gapSmall),
            TextField(
              controller: _budgetController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Leave empty for no limit',
                prefixText: '$currencySymbol ',
              ),
            ),
            const SizedBox(height: AppValues.gapExtraLarge),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter a category name')),
                    );
                    return;
                  }

                  final budgetLimit =
                      double.tryParse(_budgetController.text) ?? 0.0;

                  if (isEdit) {
                    final updatedCategory = CategoryModel(
                      id: widget.category!.id,
                      name: _nameController.text,
                      iconParams: _selectedIcon,
                      colorValue: _selectedColor.toARGB32(),
                      type: _selectedType,
                      budgetLimit: budgetLimit,
                    );
                    ref
                        .read(categoriesListProvider.notifier)
                        .updateCategory(updatedCategory);
                  } else {
                    await ref.read(categoriesListProvider.notifier).addCategory(
                          name: _nameController.text,
                          iconName: _selectedIcon,
                          colorValue: _selectedColor.toARGB32(),
                          type: _selectedType,
                          budgetLimit: budgetLimit,
                        );
                  }

                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(isEdit ? 'Update Category' : 'Add Category'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, String type, Color color) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
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
      case 'real_estate_agent_rounded':
        return Icons.real_estate_agent_rounded;
      case 'lock_outline_rounded':
        return Icons.lock_outline_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
