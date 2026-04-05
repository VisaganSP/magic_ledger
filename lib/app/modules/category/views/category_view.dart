import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/category_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../expense/controllers/expense_controller.dart';
import '../controllers/category_controller.dart';

class CategoryView extends GetView<CategoryController> {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(isDark),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: Obx(() {
              final defaults = controller.getDefaultCategories();
              final custom = controller.getCustomCategories();

              return SliverList(delegate: SliverChildListDelegate([
                // Stats strip
                _buildStatsStrip(isDark),
                const SizedBox(height: 20),

                // Default categories
                _sectionTitle('DEFAULT CATEGORIES', '${defaults.length}', isDark),
                const SizedBox(height: 12),
                _buildCategoryGrid(defaults, isDark, 0),
                const SizedBox(height: 24),

                // Custom categories
                _sectionTitle('YOUR CATEGORIES', '${custom.length}', isDark),
                const SizedBox(height: 12),
                if (custom.isEmpty)
                  _buildEmptyCustom(isDark)
                else
                  _buildCategoryGrid(custom, isDark, defaults.length),
                const SizedBox(height: 100),
              ]));
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/add-category'),
        backgroundColor: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
        label: const Text('NEW CATEGORY', style: TextStyle(fontWeight: FontWeight.w900,
            color: NeoBrutalismTheme.primaryBlack)),
        icon: const Icon(Icons.add, color: NeoBrutalismTheme.primaryBlack),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3)),
      ),
    );
  }

  SliverAppBar _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 90,
      pinned: true,
      backgroundColor: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentBlue, isDark),
      foregroundColor: NeoBrutalismTheme.primaryBlack,
      flexibleSpace: const FlexibleSpaceBar(
        title: Text('CATEGORIES', style: TextStyle(fontWeight: FontWeight.w900,
            fontSize: 20, color: NeoBrutalismTheme.primaryBlack)),
        titlePadding: EdgeInsets.only(left: 56, bottom: 14),
      ),
    );
  }

  Widget _buildStatsStrip(bool isDark) {
    final total = controller.categories.length;
    final defaults = controller.getDefaultCategories().length;
    final custom = controller.getCustomCategories().length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: NeoBrutalismTheme.neoBox(
        color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentYellow, isDark),
        borderColor: NeoBrutalismTheme.primaryBlack, offset: 4,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _statItem('$total', 'Total', isDark),
        Container(width: 2, height: 30, color: NeoBrutalismTheme.primaryBlack.withOpacity(0.2)),
        _statItem('$defaults', 'Default', isDark),
        Container(width: 2, height: 30, color: NeoBrutalismTheme.primaryBlack.withOpacity(0.2)),
        _statItem('$custom', 'Custom', isDark),
      ]),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _statItem(String value, String label, bool isDark) {
    return Column(children: [
      Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
          color: NeoBrutalismTheme.primaryBlack)),
      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: Colors.black.withOpacity(0.5))),
    ]);
  }

  Widget _sectionTitle(String text, String count, bool isDark) {
    return Row(children: [
      Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: NeoBrutalismTheme.primaryBlack,
            borderRadius: BorderRadius.circular(10)),
        child: Text(count, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
            color: Colors.white)),
      ),
    ]);
  }

  Widget _buildCategoryGrid(List<CategoryModel> cats, bool isDark, int startIndex) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: cats.length,
      itemBuilder: (ctx, i) => _buildCategoryCard(cats[i], isDark, startIndex + i),
    );
  }

  Widget _buildCategoryCard(CategoryModel cat, bool isDark, int index) {
    // Try to get expense count for this category
    int expCount = 0;
    try {
      final expCtrl = Get.find<ExpenseController>();
      expCount = expCtrl.expenses.where((e) => e.categoryId == cat.id).length;
    } catch (_) {}

    return GestureDetector(
      onTap: () => Get.toNamed('/add-category', arguments: {'isEdit': true, 'category': cat}),
      onLongPress: () {
        if (!cat.isDefault) _showDeleteDialog(cat, isDark);
      },
      child: Container(
        decoration: NeoBrutalismTheme.neoBox(
          color: cat.colorValue,
          borderColor: NeoBrutalismTheme.primaryBlack, offset: 4,
        ),
        child: Stack(children: [
          // Expense count badge
          if (expCount > 0)
            Positioned(top: 6, right: 6, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: NeoBrutalismTheme.primaryBlack,
                  borderRadius: BorderRadius.circular(8)),
              child: Text('$expCount', style: const TextStyle(fontSize: 9,
                  fontWeight: FontWeight.w900, color: Colors.white)),
            )),

          // Default badge
          if (cat.isDefault)
            Positioned(top: 6, left: 6, child: Container(
              width: 8, height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: NeoBrutalismTheme.primaryBlack.withOpacity(0.3)),
            )),

          // Content
          Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(cat.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(cat.name.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
                      color: NeoBrutalismTheme.primaryBlack),
                  textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            if (cat.budget != null) ...[
              const SizedBox(height: 3),
              Text('\u{20B9}${cat.budget!.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.5))),
            ],
          ])),
        ]),
      ),
    ).animate().fadeIn(delay: (80 * index).ms).scale(
        begin: const Offset(0.85, 0.85), end: const Offset(1, 1), duration: 250.ms);
  }

  Widget _buildEmptyCustom(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: NeoBrutalismTheme.neoBox(
        color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
        borderColor: NeoBrutalismTheme.primaryBlack, offset: 4,
      ),
      child: Column(children: [
        Icon(Icons.palette_outlined, size: 40, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Text('No custom categories yet', style: TextStyle(fontSize: 14,
            fontWeight: FontWeight.w800, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        const SizedBox(height: 4),
        Text('Tap + to create your own', style: TextStyle(fontSize: 12,
            color: isDark ? Colors.grey[600] : Colors.grey[500])),
      ]),
    );
  }

  void _showDeleteDialog(CategoryModel cat, bool isDark) {
    Get.dialog(Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: NeoBrutalismTheme.neoBoxRounded(
            color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(cat.icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text('DELETE "${cat.name.toUpperCase()}"?',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('This cannot be undone.', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: NeoButton(text: 'CANCEL', onPressed: () => Navigator.of(Get.context!).pop(),
                color: NeoBrutalismTheme.primaryWhite)),
            const SizedBox(width: 12),
            Expanded(child: NeoButton(text: 'DELETE', onPressed: () {
              controller.deleteCategory(cat.id);
              Navigator.of(Get.context!).pop();
              Get.snackbar('Deleted', '${cat.name} removed',
                  backgroundColor: NeoBrutalismTheme.accentGreen,
                  colorText: NeoBrutalismTheme.primaryBlack);
            }, color: Colors.red, textColor: Colors.white)),
          ]),
        ]),
      ),
    ));
  }
}