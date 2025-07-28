import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../data/models/category_model.dart';

class CategoryController extends GetxController {
  final Box<CategoryModel> _categoryBox = Hive.box('categories');
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  // Default categories
  final List<Map<String, dynamic>> defaultCategories = [
    {'name': 'Food', 'icon': '🍔', 'color': Colors.orange.value},
    {'name': 'Transport', 'icon': '🚗', 'color': Colors.blue.value},
    {'name': 'Shopping', 'icon': '🛍️', 'color': Colors.pink.value},
    {'name': 'Bills', 'icon': '💡', 'color': Colors.yellow.value},
    {'name': 'Entertainment', 'icon': '🎬', 'color': Colors.purple.value},
    {'name': 'Health', 'icon': '💊', 'color': Colors.green.value},
    {'name': 'Education', 'icon': '📚', 'color': Colors.indigo.value},
    {'name': 'Others', 'icon': '📌', 'color': Colors.grey.value},
  ];

  @override
  void onInit() {
    super.onInit();
    loadCategories();

    // Initialize default categories if empty
    if (categories.isEmpty) {
      initializeDefaultCategories();
    }
  }

  void loadCategories() {
    try {
      categories.value = _categoryBox.values.toList();

      // Sort categories: default categories first, then custom ones
      categories.sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return a.name.compareTo(b.name);
      });
    } catch (e) {
      print('Error loading categories: $e');
      categories.value = [];
    }
  }

  void initializeDefaultCategories() {
    try {
      for (var cat in defaultCategories) {
        final category = CategoryModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + cat['name'],
          name: cat['name'],
          icon: cat['icon'],
          color: cat['color'],
          isDefault: true,
        );
        _categoryBox.put(category.id, category);
      }
      loadCategories();
    } catch (e) {
      print('Error initializing default categories: $e');
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await _categoryBox.put(category.id, category);
      loadCategories();
    } catch (e) {
      print('Error adding category: $e');
      Get.snackbar(
        'Error',
        'Failed to add category. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await category.save();
      loadCategories();
    } catch (e) {
      print('Error updating category: $e');
      Get.snackbar(
        'Error',
        'Failed to update category. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _categoryBox.delete(id);
      loadCategories();
    } catch (e) {
      print('Error deleting category: $e');
      Get.snackbar(
        'Error',
        'Failed to delete category. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      print('Category not found for id: $id');
      // Return first available category as fallback
      if (categories.isNotEmpty) {
        return categories.first;
      }
      return null;
    }
  }

  CategoryModel? getCategoryByIdSafe(String id) {
    try {
      final categoryIndex = categories.indexWhere((c) => c.id == id);
      return categoryIndex != -1 ? categories[categoryIndex] : null;
    } catch (e) {
      print('Error getting category by id: $e');
      return null;
    }
  }

  bool canDeleteCategory(String id) {
    try {
      final category = getCategoryById(id);
      return category != null && !category.isDefault;
    } catch (e) {
      print('Error checking if category can be deleted: $e');
      return false;
    }
  }

  // Get category with fallback for UI safety
  CategoryModel getCategoryForExpense(String categoryId) {
    final category = getCategoryByIdSafe(categoryId);

    if (category != null) {
      return category;
    }

    // Return default fallback category
    return CategoryModel(
      id: 'fallback',
      name: 'Unknown',
      icon: '💰',
      color: Colors.grey.value,
      isDefault: false,
    );
  }

  // Validate that a category exists before using it
  bool categoryExists(String id) {
    return categories.any((c) => c.id == id);
  }

  // Get all non-default categories
  List<CategoryModel> getCustomCategories() {
    return categories.where((c) => !c.isDefault).toList();
  }

  // Get all default categories
  List<CategoryModel> getDefaultCategories() {
    return categories.where((c) => c.isDefault).toList();
  }

  // Clean up orphaned references (categories that don't exist anymore)
  void cleanupOrphanedReferences() {
    // This would be called when needed to clean up any references
    // to categories that no longer exist
    loadCategories();
  }
}
