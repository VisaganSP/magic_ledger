import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/neo_brutalism_theme.dart';
import '../../category/controllers/category_controller.dart';

void showCategoryBottomSheet({
  required BuildContext context,
  required bool isDark,
  required String? selectedCategoryId,
  required Function(String) onCategorySelected,
  required Color Function(Color, bool) getThemedColor,
}) {
  final CategoryController categoryController = Get.find();

  Get.bottomSheet(
    Container(
      height: Get.height * 0.65,
      decoration: BoxDecoration(
        color: isDark
            ? NeoBrutalismTheme.darkBackground
            : NeoBrutalismTheme.primaryWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: const Border(
          top: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
          left: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
          right: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(isDark),
          Expanded(
            child: _buildCategoryGrid(
              isDark,
              categoryController,
              selectedCategoryId,
              onCategorySelected,
              getThemedColor,
            ),
          ),
        ],
      ),
    ),
    isDismissible: true,
    enableDrag: true,
  );
}

Widget _buildHeader(bool isDark) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'SELECT CATEGORY',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark
                ? NeoBrutalismTheme.darkText
                : NeoBrutalismTheme.primaryBlack,
          ),
        ),
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: NeoBrutalismTheme.neoBox(
              color: isDark
                  ? NeoBrutalismTheme.darkSurface
                  : NeoBrutalismTheme.primaryWhite,
              borderColor: NeoBrutalismTheme.primaryBlack,
              offset: 2,
            ),
            child: Icon(
              Icons.close,
              size: 20,
              color: isDark
                  ? NeoBrutalismTheme.darkText
                  : NeoBrutalismTheme.primaryBlack,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildCategoryGrid(
    bool isDark,
    CategoryController categoryController,
    String? selectedCategoryId,
    Function(String) onCategorySelected,
    Color Function(Color, bool) getThemedColor,
    ) {
  return Obx(
        () => GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: categoryController.categories.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildAddCategoryButton(isDark, getThemedColor);
        }

        final category = categoryController.categories[index - 1];
        final isSelected = selectedCategoryId == category.id;

        return _buildCategoryItem(
          category: category,
          isSelected: isSelected,
          isDark: isDark,
          onTap: () {
            onCategorySelected(category.id);
            Get.back();
          },
          getThemedColor: getThemedColor,
        );
      },
    ),
  );
}

Widget _buildAddCategoryButton(
    bool isDark,
    Color Function(Color, bool) getThemedColor,
    ) {
  return GestureDetector(
    onTap: () {
      Get.back();
      Get.toNamed('/add-category');
    },
    child: Container(
      decoration: NeoBrutalismTheme.neoBoxRounded(
        color: getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
        borderColor: NeoBrutalismTheme.primaryBlack,
        offset: 3,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 28,
            color: NeoBrutalismTheme.primaryBlack,
          ),
          const SizedBox(height: 6),
          Text(
            'ADD',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.primaryBlack,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget _buildCategoryItem({
  required dynamic category,
  required bool isSelected,
  required bool isDark,
  required VoidCallback onTap,
  required Color Function(Color, bool) getThemedColor,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: NeoBrutalismTheme.neoBoxRounded(
        color: isSelected
            ? getThemedColor(category.colorValue, isDark)
            : (isDark
            ? NeoBrutalismTheme.darkSurface
            : NeoBrutalismTheme.primaryWhite),
        offset: isSelected ? 2 : 4,
        borderColor: NeoBrutalismTheme.primaryBlack,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            category.icon,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              category.name.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? NeoBrutalismTheme.primaryBlack
                    : (isDark
                    ? NeoBrutalismTheme.darkText.withOpacity(0.8)
                    : NeoBrutalismTheme.primaryBlack.withOpacity(0.7)),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}