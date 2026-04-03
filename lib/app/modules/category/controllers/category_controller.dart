import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../data/models/category_model.dart';

class CategoryController extends GetxController {
  final Box<CategoryModel> _categoryBox = Hive.box('categories');
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  final List<Map<String, dynamic>> defaultCategories = [
    {'name': 'Food', 'icon': '🍔', 'color': Color(0xFFFFB49A).value},
    {'name': 'Transport', 'icon': '🚗', 'color': Color(0xFF9DB4FF).value},
    {'name': 'Shopping', 'icon': '🛍️', 'color': Color(0xFFFDB5D6).value},
    {'name': 'Bills', 'icon': '💡', 'color': Color(0xFFFDD663).value},
    {'name': 'Entertainment', 'icon': '🎬', 'color': Color(0xFFE8CCFF).value},
    {'name': 'Health', 'icon': '💊', 'color': Color(0xFFB8E994).value},
    {'name': 'Education', 'icon': '📚', 'color': Color(0xFFBFE3F0).value},
    {'name': 'Groceries', 'icon': '🛒', 'color': Color(0xFFD4E4D1).value},
    {'name': 'Home', 'icon': '🏠', 'color': Color(0xFFF5E6D3).value},
    {'name': 'Subscriptions', 'icon': '🔁', 'color': Color(0xFFDCC9E8).value},
    {'name': 'Travel', 'icon': '✈️', 'color': Color(0xFFA7C7E7).value},
    {'name': 'Personal Care', 'icon': '🧴', 'color': Color(0xFFFFDAB9).value},
    {'name': 'Fitness', 'icon': '🏋️', 'color': Color(0xFF4DB6AC).value},
    {'name': 'Gifts', 'icon': '🎁', 'color': Color(0xFFE57373).value},
    {'name': 'Work', 'icon': '💼', 'color': Color(0xFFC8B593).value},
    {'name': 'Others', 'icon': '📌', 'color': Color(0xFFB0BEC5).value},
  ];

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    if (categories.isEmpty) initializeDefaultCategories();
  }

  void loadCategories() {
    try {
      categories.value = _categoryBox.values.toList();
      categories.sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return a.name.compareTo(b.name);
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
      categories.value = [];
    }
  }

  void initializeDefaultCategories() {
    try {
      for (final cat in defaultCategories) {
        final category = CategoryModel(
          id: '${DateTime.now().millisecondsSinceEpoch}${cat['name']}',
          name: cat['name'], icon: cat['icon'], color: cat['color'],
          isDefault: true,
        );
        _categoryBox.put(category.id, category);
      }
      loadCategories();
    } catch (e) {
      debugPrint('Error initializing categories: $e');
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await _categoryBox.put(category.id, category);
      loadCategories();
    } catch (e) {
      debugPrint('Error adding category: $e');
      Get.snackbar('Error', 'Failed to add category', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _categoryBox.put(category.id, category);
      loadCategories();
    } catch (e) {
      debugPrint('Error updating category: $e');
      Get.snackbar('Error', 'Failed to update category', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _categoryBox.delete(id);
      loadCategories();
    } catch (e) {
      debugPrint('Error deleting category: $e');
      Get.snackbar('Error', 'Failed to delete category', snackPosition: SnackPosition.BOTTOM);
    }
  }

  CategoryModel? getCategoryById(String id) {
    try { return categories.firstWhere((c) => c.id == id); }
    catch (_) {
      if (categories.isNotEmpty) return categories.first;
      return null;
    }
  }

  CategoryModel? getCategoryByIdSafe(String id) {
    final i = categories.indexWhere((c) => c.id == id);
    return i != -1 ? categories[i] : null;
  }

  bool canDeleteCategory(String id) {
    final c = getCategoryById(id);
    return c != null && !c.isDefault;
  }

  CategoryModel getCategoryForExpense(String categoryId) {
    return getCategoryByIdSafe(categoryId) ?? CategoryModel(
      id: 'fallback', name: 'Unknown', icon: '💰',
      color: Colors.grey.value, isDefault: false,
    );
  }

  bool categoryExists(String id) => categories.any((c) => c.id == id);
  List<CategoryModel> getCustomCategories() => categories.where((c) => !c.isDefault).toList();
  List<CategoryModel> getDefaultCategories() => categories.where((c) => c.isDefault).toList();
  void cleanupOrphanedReferences() => loadCategories();
}