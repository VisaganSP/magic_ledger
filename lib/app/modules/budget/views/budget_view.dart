import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/budget_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../category/controllers/category_controller.dart';
import '../controllers/budget_controller.dart';

class BudgetView extends GetView<BudgetController> {
  const BudgetView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryController = Get.find<CategoryController>();

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.primaryWhite,
      appBar: AppBar(
        title: const Text(
          'BUDGETS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: NeoBrutalismTheme.primaryBlack,
          ),
        ),
        backgroundColor: _getThemedColor(NeoBrutalismTheme.accentBlue, isDark),
        foregroundColor: NeoBrutalismTheme.primaryBlack,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/add-budget'),
        backgroundColor: _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
        label: const Text(
          'ADD BUDGET',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: NeoBrutalismTheme.primaryBlack,
          ),
        ),
        icon: const Icon(Icons.add, color: NeoBrutalismTheme.primaryBlack),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: NeoBrutalismTheme.primaryBlack,
            width: 3,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBudgetSummary(isDark),
            const SizedBox(height: 24),
            _buildOverallBudget(isDark),
            const SizedBox(height: 24),
            _buildCategoryBudgets(categoryController, isDark),
            const SizedBox(height: 80), // Space for FAB
          ],
        );
      }),
    );
  }

  Color _getThemedColor(Color color, bool isDark) {
    if (!isDark) return color;

    final colorMap = {
      NeoBrutalismTheme.accentYellow: Color(0xFFE6B800),
      NeoBrutalismTheme.accentPink: Color(0xFFE667A0),
      NeoBrutalismTheme.accentBlue: Color(0xFF4D94FF),
      NeoBrutalismTheme.accentGreen: Color(0xFF00CC66),
      NeoBrutalismTheme.accentOrange: Color(0xFFFF8533),
      NeoBrutalismTheme.accentPurple: Color(0xFF9966FF),
    };

    return colorMap[color] ?? color;
  }

  Widget _buildBudgetSummary(bool isDark) {
    final summary = controller.getBudgetSummary();

    return NeoCard(
      color: _getThemedColor(NeoBrutalismTheme.accentYellow, isDark),
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart, size: 28, color: NeoBrutalismTheme.primaryBlack),
              const SizedBox(width: 12),
              const Text(
                'BUDGET OVERVIEW',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.primaryBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Budgets',
                  '${summary['totalBudgets']}',
                  Icons.account_balance_wallet,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Exceeded',
                  '${summary['exceededCount']}',
                  Icons.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Budget',
                  '₹${summary['totalBudget'].toStringAsFixed(0)}',
                  Icons.savings,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Total Spent',
                  '₹${summary['totalSpent'].toStringAsFixed(0)}',
                  Icons.shopping_cart,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            summary['percentageUsed'],
            summary['percentageUsed'] > 100
                ? Colors.red
                : summary['percentageUsed'] > 80
                ? Colors.orange
                : Colors.green,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: NeoBrutalismTheme.primaryBlack),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: NeoBrutalismTheme.primaryBlack,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: NeoBrutalismTheme.primaryBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Overall Usage',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: NeoBrutalismTheme.primaryBlack,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.primaryBlack,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 20,
          decoration: BoxDecoration(
            border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              backgroundColor: NeoBrutalismTheme.primaryWhite,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverallBudget(bool isDark) {
    final overallBudget = controller.getOverallBudget();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OVERALL BUDGET',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark
                ? NeoBrutalismTheme.darkText
                : NeoBrutalismTheme.primaryBlack,
          ),
        ),
        const SizedBox(height: 16),
        if (overallBudget != null)
          _buildBudgetCard(overallBudget, null, isDark, 0)
        else
          _buildEmptyBudgetCard(
            'No Overall Budget',
            'Set an overall spending limit for all categories',
            isDark,
          ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildCategoryBudgets(CategoryController categoryController, bool isDark) {
    final categoryBudgets = controller.getCategoryBudgets();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATEGORY BUDGETS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark
                ? NeoBrutalismTheme.darkText
                : NeoBrutalismTheme.primaryBlack,
          ),
        ),
        const SizedBox(height: 16),
        if (categoryBudgets.isEmpty)
          _buildEmptyBudgetCard(
            'No Category Budgets',
            'Set spending limits for specific categories',
            isDark,
          )
        else
          ...categoryBudgets.asMap().entries.map((entry) {
            final index = entry.key;
            final budget = entry.value;
            final category = categoryController.getCategoryById(budget.categoryId!);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildBudgetCard(budget, category, isDark, index),
            );
          }).toList(),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildBudgetCard(
      BudgetModel budget,
      dynamic category,
      bool isDark,
      int index,
      ) {
    final spent = controller.getSpentAmount(budget);
    final remaining = controller.getRemainingAmount(budget);
    final percentage = controller.getPercentageUsed(budget);
    final isExceeded = controller.isBudgetExceeded(budget);

    Color cardColor = category != null
        ? _getThemedColor(category.colorValue, isDark)
        : _getThemedColor(NeoBrutalismTheme.accentPurple, isDark);

    return NeoCard(
      color: cardColor,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (category != null) ...[
                Text(category.icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
              ] else ...[
                Icon(Icons.account_balance_wallet,
                    size: 32, color: NeoBrutalismTheme.primaryBlack),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category?.name.toUpperCase() ?? 'OVERALL BUDGET',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: NeoBrutalismTheme.primaryBlack,
                      ),
                    ),
                    Text(
                      budget.period.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: NeoBrutalismTheme.primaryBlack,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    Get.toNamed('/edit-budget', arguments: budget);
                  } else if (value == 'delete') {
                    _showDeleteDialog(budget, isDark);
                  } else if (value == 'toggle') {
                    controller.toggleBudgetStatus(budget.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(budget.isActive ? 'Deactivate' : 'Activate'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
                child: Icon(Icons.more_vert, color: NeoBrutalismTheme.primaryBlack),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BUDGET',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                  Text(
                    '₹${budget.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'SPENT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                  Text(
                    '₹${spent.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isExceeded ? Colors.red : NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            percentage,
            isExceeded
                ? Colors.red
                : percentage > 80
                ? Colors.orange
                : Colors.green,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining: ₹${remaining.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isExceeded ? Colors.red : NeoBrutalismTheme.primaryBlack,
                ),
              ),
              if (isExceeded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: NeoBrutalismTheme.primaryBlack,
                      width: 2,
                    ),
                  ),
                  child: const Text(
                    'EXCEEDED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: NeoBrutalismTheme.primaryWhite,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (400 + index * 100).ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildEmptyBudgetCard(String title, String subtitle, bool isDark) {
    return NeoCard(
      color: isDark
          ? NeoBrutalismTheme.darkSurface
          : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet,
              size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[600] : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          NeoButton(
            text: 'ADD BUDGET',
            onPressed: () => Get.toNamed('/add-budget'),
            color: _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BudgetModel budget, bool isDark) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: NeoBrutalismTheme.neoBoxRounded(
            color: isDark
                ? NeoBrutalismTheme.darkSurface
                : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'DELETE BUDGET?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              const Text(
                'This action cannot be undone.',
                style: TextStyle(fontSize: 16),
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
                        controller.deleteBudget(budget.id);
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Budget deleted successfully',
                          backgroundColor: NeoBrutalismTheme.accentGreen,
                          colorText: NeoBrutalismTheme.primaryBlack,
                        );
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