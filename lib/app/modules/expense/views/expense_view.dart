import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/expense_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../category/controllers/category_controller.dart';
import '../controllers/expense_controller.dart';

class ExpenseView extends GetView<ExpenseController> {
  final CategoryController categoryController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalismTheme.primaryWhite,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-expense'),
        backgroundColor: NeoBrutalismTheme.accentOrange,
        child: const Icon(Icons.add, size: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: NeoBrutalismTheme.primaryBlack,
            width: 3,
          ),
        ),
      ).animate().scale(delay: 500.ms),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              if (controller.expenses.isEmpty) {
                return _buildEmptyState();
              }
              return _buildExpenseList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EXPENSES',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              'Total: \$${controller.expenses.fold(0.0, (sum, e) => sum + e.amount).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All', true),
          const SizedBox(width: 12),
          _buildFilterChip('Today', false),
          const SizedBox(width: 12),
          _buildFilterChip('This Week', false),
          const SizedBox(width: 12),
          _buildFilterChip('This Month', false),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: NeoBrutalismTheme.neoBox(
        color:
            isSelected
                ? NeoBrutalismTheme.accentYellow
                : NeoBrutalismTheme.primaryWhite,
        offset: isSelected ? 2 : 5,
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: NeoBrutalismTheme.neoBox(
              color: NeoBrutalismTheme.accentPink,
            ),
            child: const Icon(Icons.receipt_long, size: 60),
          ).animate().scale(duration: 500.ms),
          const SizedBox(height: 24),
          const Text(
            'NO EXPENSES YET',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start tracking your expenses',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          NeoButton(
            text: 'ADD FIRST EXPENSE',
            onPressed: () => Get.toNamed('/add-expense'),
            color: NeoBrutalismTheme.accentOrange,
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.expenses.length,
      itemBuilder: (context, index) {
        final expense = controller.expenses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildExpenseCard(expense, index),
        );
      },
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense, int index) {
    final category = categoryController.categories.firstWhere(
      (c) => c.id == expense.categoryId,
    );

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: NeoBrutalismTheme.neoBox(color: Colors.red),
        child: const Icon(
          Icons.delete,
          color: NeoBrutalismTheme.primaryWhite,
          size: 32,
        ),
      ),
      onDismissed: (direction) {
        controller.deleteExpense(expense.id);
        Get.snackbar(
          'Deleted',
          '${expense.title} removed',
          backgroundColor: NeoBrutalismTheme.accentPink,
          colorText: NeoBrutalismTheme.primaryBlack,
          borderWidth: 3,
          borderColor: NeoBrutalismTheme.primaryBlack,
        );
      },
      child: NeoCard(
        onTap: () => Get.toNamed('/expense-detail', arguments: expense),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: NeoBrutalismTheme.neoBox(color: category.colorValue),
              child: Center(
                child: Text(
                  category.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${expense.date.day}/${expense.date.month}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (expense.tags != null && expense.tags!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children:
                          expense.tags!
                              .take(3)
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: NeoBrutalismTheme.accentYellow,
                                    border: Border.all(
                                      color: NeoBrutalismTheme.primaryBlack,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-\$${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.red,
                  ),
                ),
                if (expense.isRecurring) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: NeoBrutalismTheme.accentPurple,
                      border: Border.all(
                        color: NeoBrutalismTheme.primaryBlack,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      expense.recurringType!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2, end: 0);
  }
}
