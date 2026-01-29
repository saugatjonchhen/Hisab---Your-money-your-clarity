import 'package:flutter/foundation.dart';
import 'package:finance_app/features/transactions/data/models/category_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CategoryRepository {
  static const String boxName = 'categories';

  Future<Box<CategoryModel>> _openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<CategoryModel>(boxName);
    }
    return Hive.box<CategoryModel>(boxName);
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      final box = await _openBox();
      await box.put(category.id, category);
    } catch (e) {
      debugPrint('Error adding category: $e');
      rethrow;
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final box = await _openBox();
      return box.values.toList();
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final box = await _openBox();
      await box.delete(id);
    } catch (e) {
      debugPrint('Error deleting category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    final box = await _openBox();
    await box.put(category.id, category);
  }
}
