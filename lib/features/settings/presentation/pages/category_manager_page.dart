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
            onPressed: () => _showAddEditCategoryDialog(context, ref),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          final sortedCategories = List<CategoryModel>.from(categories)..sort((a, b) {
            const typeOrder = {'income': 0, 'expense': 1, 'savings': 2, 'investment': 3};
            final typeCompare = (typeOrder[a.type] ?? 99).compareTo(typeOrder[b.type] ?? 99);
            if (typeCompare != 0) return typeCompare;
            return a.name.compareTo(b.name);
          });

          return ListView.separated(
            padding: AppValues.screenPadding,
            itemCount: sortedCategories.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppValues.gapMedium),
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

  Widget _buildCategoryTile(BuildContext context, WidgetRef ref, CategoryModel category, bool isSmallScreen) {
    final color = Color(category.colorValue);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppValues.borderRadiusLarge),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.05),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppValues.horizontalPadding,
          vertical: AppValues.gapSmall,
        ),
        leading: Container(
          padding: const EdgeInsets.all(AppValues.gapSmall),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getIcon(category.iconParams), color: color, size: isSmallScreen ? 20 : 24),
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
                const Text('Budget', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text(
                  category.budgetLimit > 0 ? '\$${category.budgetLimit.toStringAsFixed(0)}' : 'No Limit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: category.budgetLimit > 0 ? AppColors.primary : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppValues.gapSmall),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _showAddEditCategoryDialog(context, ref, category),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditCategoryDialog(BuildContext context, WidgetRef ref, [CategoryModel? category]) {
    final isEdit = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final budgetController = TextEditingController(text: category?.budgetLimit.toString() ?? '');
    String selectedType = category?.type ?? 'expense';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? 'Edit Category' : 'New Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                ),
                const SizedBox(height: AppValues.gapMedium),
                TextField(
                  controller: budgetController,
                  decoration: const InputDecoration(labelText: 'Monthly Budget Limit'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppValues.gapMedium),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['expense', 'income', 'savings', 'investment']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase())))
                      .toList(),
                  onChanged: (v) => setState(() => selectedType = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final newCategory = CategoryModel(
                  id: category?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  iconParams: category?.iconParams ?? 'category_rounded',
                  colorValue: category?.colorValue ?? AppColors.primary.value,
                  type: selectedType,
                  budgetLimit: double.tryParse(budgetController.text) ?? 0,
                );
                
                if (isEdit) {
                  ref.read(categoriesListProvider.notifier).updateCategory(newCategory);
                } else {
                  ref.read(categoriesListProvider.notifier).addCategory(
                    name: newCategory.name,
                    iconName: newCategory.iconParams,
                    colorValue: newCategory.colorValue,
                    type: newCategory.type,
                    budgetLimit: newCategory.budgetLimit,
                  );
                }
                Navigator.pop(context);
              },
              child: Text(isEdit ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
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
      case 'savings_rounded': return Icons.savings_rounded;
      case 'trending_up_rounded': return Icons.trending_up_rounded;
      case 'medical_services_rounded': return Icons.medical_services_rounded;
      case 'fitness_center_rounded': return Icons.fitness_center_rounded;
      case 'home_rounded': return Icons.home_rounded;
      case 'school_rounded': return Icons.school_rounded;
      case 'real_estate_agent_rounded': return Icons.real_estate_agent_rounded;
      case 'lock_outline_rounded': return Icons.lock_outline_rounded;
      default: return Icons.category_rounded;
    }
  }
}
