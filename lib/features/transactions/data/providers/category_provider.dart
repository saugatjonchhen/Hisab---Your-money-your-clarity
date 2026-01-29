import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/features/transactions/data/models/category_model.dart';
import 'package:finance_app/features/transactions/data/repositories/category_repository.dart';
import 'package:finance_app/features/transactions/data/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'category_provider.g.dart';

@riverpod
CategoryRepository categoryRepository(CategoryRepositoryRef ref) {
  return CategoryRepository();
}

@riverpod
class CategoriesList extends _$CategoriesList {
  @override
  Future<List<CategoryModel>> build() async {
    final repository = ref.read(categoryRepositoryProvider);
    var categories = await repository.getCategories();
    
    if (categories.isEmpty) {
      await _initializeDefaultCategories(repository);
      categories = await repository.getCategories();
    }
    
    return categories;
  }

  Future<void> _initializeDefaultCategories(CategoryRepository repository) async {
    final defaults = [
      CategoryModel(
        id: const Uuid().v4(),
        name: 'Food',
        iconParams: 'fastfood_rounded',
        colorValue: AppColors.primary.value, // Using int value
        type: 'expense',
        budgetLimit: 0.0,
      ),
      CategoryModel(
        id: const Uuid().v4(),
        name: 'Transport',
        iconParams: 'directions_bus_rounded',
        colorValue: AppColors.secondary.value,
        type: 'expense',
        budgetLimit: 0.0,
      ),
      CategoryModel(
        id: const Uuid().v4(),
        name: 'Shopping',
        iconParams: 'shopping_bag_rounded',
        colorValue: AppColors.tertiary.value,
        type: 'expense',
        budgetLimit: 0.0,
      ),
      CategoryModel(
        id: const Uuid().v4(),
        name: 'Bills',
        iconParams: 'receipt_long_rounded',
        colorValue: Colors.orange.value,
        type: 'expense',
        budgetLimit: 0.0,
      ),
      CategoryModel(
        id: const Uuid().v4(),
        name: 'EMI / Loan',
        iconParams: 'real_estate_agent_rounded',
        colorValue: Colors.redAccent.value,
        type: 'expense',
        budgetLimit: 0.0,
      ),
        CategoryModel(
        id: const Uuid().v4(),
        name: 'Entertainment',
        iconParams: 'movie_rounded',
        colorValue: Colors.blue.value,
        type: 'expense',
        budgetLimit: 0.0,
      ),
        CategoryModel(
        id: const Uuid().v4(),
        name: 'Salary',
        iconParams: 'work_rounded',
        colorValue: Colors.green.value,
        type: 'income',
        budgetLimit: 0,
      ),
      CategoryModel(
        id: const Uuid().v4(),
        name: 'Emergency Fund',
        iconParams: 'savings_rounded',
        colorValue: AppColors.savings.value,
        type: 'savings',
        budgetLimit: 0,
      ),
      CategoryModel(
        id: const Uuid().v4(),
        name: 'Stocks',
        iconParams: 'trending_up_rounded',
        colorValue: AppColors.investment.value,
        type: 'investment',
        budgetLimit: 0,
      ),
    ];

    for (var cat in defaults) {
      await repository.addCategory(cat);
    }
  }

  Future<String> addCategory({
    required String name,
    required String iconName,
    required int colorValue,
    required String type,
    double budgetLimit = 0,
  }) async {
    final repository = ref.read(categoryRepositoryProvider);
    final id = const Uuid().v4();
    final newCategory = CategoryModel(
      id: id,
      name: name,
      iconParams: iconName,
      colorValue: colorValue,
      type: type,
      budgetLimit: budgetLimit,
    );
    
    await repository.addCategory(newCategory);
    ref.invalidateSelf();
    return id;
  }

  Future<void> updateCategory(CategoryModel category) async {
    final repository = ref.read(categoryRepositoryProvider);
    await repository.addCategory(category); // Hive's put handles updates
    ref.invalidateSelf();
  }

  Future<void> deleteCategory(String id) async {
    final repository = ref.read(categoryRepositoryProvider);
    final transactionRepository = ref.read(transactionRepositoryProvider);
    
    // Cascading delete: Remove all transactions associated with this category
    final transactions = await transactionRepository.getTransactions();
    final toDelete = transactions.where((t) => t.categoryId == id).toList();
    
    for (var t in toDelete) {
      await transactionRepository.deleteTransaction(t.id);
    }
    
    await repository.deleteCategory(id);
    ref.invalidateSelf();
    // Also invalidate transactions list to reflect changes
    ref.invalidate(transactionsListProvider);
  }
}
