import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/category_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../controllers/category_controller.dart';

class CategoryView extends GetView<CategoryController> {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalismTheme.primaryWhite,
      appBar: AppBar(
        title: const Text('CATEGORIES'),
        backgroundColor: NeoBrutalismTheme.accentBlue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-category'),
        backgroundColor: NeoBrutalismTheme.accentGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: NeoBrutalismTheme.primaryBlack,
            width: 3,
          ),
        ),
        child: const Icon(Icons.add, size: 32),
      ).animate().scale(delay: 500.ms),
      body: Obx(
        () => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return _buildCategoryCard(category, index);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category, int index) {
    return NeoCard(
          color: category.colorValue,
          onTap: () {
            // Edit category
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(category.icon, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(
                category.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              if (category.budget != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Budget: \$${category.budget!.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (!category.isDefault) ...[
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _showDeleteDialog(category),
                ),
              ],
            ],
          ),
        )
        .animate()
        .fadeIn(delay: (100 * index).ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  void _showDeleteDialog(CategoryModel category) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: NeoBrutalismTheme.neoBoxRounded(
            color: NeoBrutalismTheme.primaryWhite,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'DELETE CATEGORY?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete "${category.name}"? This cannot be undone.',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      text: 'CANCEL',
                      onPressed: () => Get.back(),
                      color: NeoBrutalismTheme.primaryWhite,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      text: 'DELETE',
                      onPressed: () {
                        controller.deleteCategory(category.id);
                        Get.back();
                      },
                      color: Colors.red,
                      textColor: NeoBrutalismTheme.primaryWhite,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
