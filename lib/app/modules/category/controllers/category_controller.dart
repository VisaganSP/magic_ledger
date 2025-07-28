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
    categories.value = _categoryBox.values.toList();
  }

  void initializeDefaultCategories() {
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
  }

  Future<void> addCategory(CategoryModel category) async {
    await _categoryBox.put(category.id, category);
    loadCategories();
  }

  Future<void> updateCategory(CategoryModel category) async {
    await category.save();
    loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _categoryBox.delete(id);
    loadCategories();
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  bool canDeleteCategory(String id) {
    final category = getCategoryById(id);
    return category != null && !category.isDefault;
  }
}
