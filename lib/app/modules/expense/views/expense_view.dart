import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/category_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/income_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../category/controllers/category_controller.dart';
import '../../income/controllers/income_controller.dart';
import '../controllers/expense_controller.dart';

class ExpenseView extends GetView<ExpenseController> {
  final CategoryController categoryController = Get.find();
  final IncomeController incomeController = Get.find();

  ExpenseView({super.key});

  final RxString selectedFilter = 'All'.obs;
  final RxString selectedType = 'Expenses'.obs; // 'Expenses' or 'Income'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalismTheme.primaryWhite,
      floatingActionButton: Obx(
        () => FloatingActionButton(
          heroTag: "home_fab_${selectedType.value}", // Dynamic unique heroTag
          onPressed:
              () =>
                  selectedType.value == 'Expenses'
                      ? Get.toNamed('/add-expense')
                      : Get.toNamed('/add-income'),
          backgroundColor:
              selectedType.value == 'Expenses'
                  ? NeoBrutalismTheme.accentOrange
                  : NeoBrutalismTheme.accentGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: NeoBrutalismTheme.primaryBlack,
              width: 3,
            ),
          ),
          child: Icon(
            selectedType.value == 'Expenses' ? Icons.remove : Icons.add,
            size: 32,
            color: NeoBrutalismTheme.primaryBlack,
          ),
        ).animate().scale(delay: 500.ms),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTypeToggle(),
            _buildFilterSection(),
            Obx(() {
              if (selectedType.value == 'Expenses') {
                final filteredExpenses = _getFilteredExpenses();
                if (filteredExpenses.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildExpenseList(filteredExpenses);
              } else {
                final filteredIncomes = _getFilteredIncomes();
                if (filteredIncomes.isEmpty) {
                  return _buildEmptyIncomeState();
                }
                return _buildIncomeList(filteredIncomes);
              }
            }),
            const SizedBox(height: 65), // Extra space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Text(
              selectedType.value.toUpperCase(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (selectedType.value == 'Expenses') {
              final filteredExpenses = _getFilteredExpenses();
              final total = filteredExpenses.fold(
                0.0,
                (sum, e) => sum + e.amount,
              );
              return Text(
                'Total: ₹${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              );
            } else {
              final filteredIncomes = _getFilteredIncomes();
              final total = filteredIncomes.fold(
                0.0,
                (sum, e) => sum + e.amount,
              );
              return Text(
                'Total: ₹${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              );
            }
          }),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => GestureDetector(
                onTap: () => selectedType.value = 'Expenses',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: NeoBrutalismTheme.neoBox(
                    color:
                        selectedType.value == 'Expenses'
                            ? NeoBrutalismTheme.accentOrange
                            : NeoBrutalismTheme.primaryWhite,
                    offset: selectedType.value == 'Expenses' ? 2 : 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.remove_circle,
                        color:
                            selectedType.value == 'Expenses'
                                ? NeoBrutalismTheme.primaryBlack
                                : Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'EXPENSES',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color:
                              selectedType.value == 'Expenses'
                                  ? NeoBrutalismTheme.primaryBlack
                                  : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(
              () => GestureDetector(
                onTap: () => selectedType.value = 'Income',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: NeoBrutalismTheme.neoBox(
                    color:
                        selectedType.value == 'Income'
                            ? NeoBrutalismTheme.accentGreen
                            : NeoBrutalismTheme.primaryWhite,
                    offset: selectedType.value == 'Income' ? 2 : 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle,
                        color:
                            selectedType.value == 'Income'
                                ? NeoBrutalismTheme.primaryBlack
                                : Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'INCOME',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color:
                              selectedType.value == 'Income'
                                  ? NeoBrutalismTheme.primaryBlack
                                  : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FILTER BY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          _buildFilterGrid(),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildFilterGrid() {
    final filters = [
      {'label': 'All', 'icon': Icons.all_inclusive},
      {'label': 'Today', 'icon': Icons.today},
      {'label': 'This Week', 'icon': Icons.view_week},
      {'label': 'This Month', 'icon': Icons.calendar_month},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filters.length,
      itemBuilder: (context, index) {
        final filter = filters[index];
        return Obx(
          () => _buildFilterChip(
            filter['label'] as String,
            filter['icon'] as IconData,
            selectedFilter.value == filter['label'],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => selectedFilter.value = label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: NeoBrutalismTheme.neoBox(
          color:
              isSelected
                  ? NeoBrutalismTheme.accentYellow
                  : NeoBrutalismTheme.primaryWhite,
          offset: isSelected ? 2 : 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color:
                  isSelected
                      ? NeoBrutalismTheme.primaryBlack
                      : Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color:
                      isSelected
                          ? NeoBrutalismTheme.primaryBlack
                          : Colors.grey[700],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ExpenseModel> _getFilteredExpenses() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (selectedFilter.value) {
      case 'Today':
        return controller.expenses.where((expense) {
          final expenseDate = DateTime(
            expense.date.year,
            expense.date.month,
            expense.date.day,
          );
          return expenseDate.isAtSameMomentAs(today);
        }).toList();
      case 'This Week':
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return controller.expenses.where((expense) {
          final expenseDate = DateTime(
            expense.date.year,
            expense.date.month,
            expense.date.day,
          );
          return expenseDate.isAfter(
                weekStart.subtract(const Duration(days: 1)),
              ) &&
              expenseDate.isBefore(weekEnd.add(const Duration(days: 1)));
        }).toList();
      case 'This Month':
        return controller.expenses.where((expense) {
          return expense.date.year == now.year &&
              expense.date.month == now.month;
        }).toList();
      default:
        return controller.expenses.toList();
    }
  }

  List<IncomeModel> _getFilteredIncomes() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (selectedFilter.value) {
      case 'Today':
        return incomeController.incomes.where((income) {
          final incomeDate = DateTime(
            income.date.year,
            income.date.month,
            income.date.day,
          );
          return incomeDate.isAtSameMomentAs(today);
        }).toList();
      case 'This Week':
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return incomeController.incomes.where((income) {
          final incomeDate = DateTime(
            income.date.year,
            income.date.month,
            income.date.day,
          );
          return incomeDate.isAfter(
                weekStart.subtract(const Duration(days: 1)),
              ) &&
              incomeDate.isBefore(weekEnd.add(const Duration(days: 1)));
        }).toList();
      case 'This Month':
        return incomeController.incomes.where((income) {
          return income.date.year == now.year && income.date.month == now.month;
        }).toList();
      default:
        return incomeController.incomes.toList();
    }
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
          Obx(() {
            final isFiltered = selectedFilter.value != 'All';
            return Column(
              children: [
                Text(
                  isFiltered ? 'NO EXPENSES FOUND' : 'NO EXPENSES YET',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isFiltered
                      ? 'No expenses for ${selectedFilter.value.toLowerCase()}'
                      : 'Start tracking your expenses',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),
          NeoButton(
            text: 'ADD EXPENSE',
            onPressed: () => Get.toNamed('/add-expense'),
            color: NeoBrutalismTheme.accentOrange,
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyIncomeState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: NeoBrutalismTheme.neoBox(
              color: NeoBrutalismTheme.accentGreen,
            ),
            child: const Icon(Icons.account_balance_wallet, size: 60),
          ).animate().scale(duration: 500.ms),
          const SizedBox(height: 24),
          Obx(() {
            final isFiltered = selectedFilter.value != 'All';
            return Column(
              children: [
                Text(
                  isFiltered ? 'NO INCOME FOUND' : 'NO INCOME YET',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isFiltered
                      ? 'No income for ${selectedFilter.value.toLowerCase()}'
                      : 'Start tracking your income',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),
          NeoButton(
            text: 'ADD INCOME',
            onPressed: () => Get.toNamed('/add-income'),
            color: NeoBrutalismTheme.accentGreen,
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(List<ExpenseModel> expenses) {
    return Column(
      children:
          expenses.asMap().entries.map((entry) {
            final index = entry.key;
            final expense = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildExpenseCard(expense, index),
            );
          }).toList(),
    );
  }

  Widget _buildIncomeList(List<IncomeModel> incomes) {
    return Column(
      children:
          incomes.asMap().entries.map((entry) {
            final index = entry.key;
            final income = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildIncomeCard(income, index),
            );
          }).toList(),
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense, int index) {
    CategoryModel? category;
    try {
      category = categoryController.categories.firstWhere(
        (c) => c.id == expense.categoryId,
      );
    } catch (e) {
      if (categoryController.categories.isNotEmpty) {
        category = categoryController.categories.first;
      }
    }

    final categoryIcon = category?.icon ?? '💰';
    final categoryName = category?.name ?? 'Unknown';
    final categoryColor = category?.colorValue ?? Colors.grey;

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
      confirmDismiss: (direction) async {
        return await Get.dialog<bool>(
              AlertDialog(
                title: const Text('Delete Expense'),
                content: Text(
                  'Are you sure you want to delete "${expense.title}"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) {
        controller.deleteExpense(expense.id);
        Get.snackbar(
          'Deleted',
          '${expense.title} removed',
          backgroundColor: NeoBrutalismTheme.accentPink,
          colorText: NeoBrutalismTheme.primaryBlack,
          borderWidth: 3,
          borderColor: NeoBrutalismTheme.primaryBlack,
          duration: const Duration(seconds: 2),
        );
      },
      child: NeoCard(
        onTap: () => Get.toNamed('/expense-detail', arguments: expense),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: NeoBrutalismTheme.neoBox(color: categoryColor),
              child: Center(
                child: Text(categoryIcon, style: const TextStyle(fontSize: 28)),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          categoryName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${expense.date.day}/${expense.date.month}/${expense.date.year}',
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
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-₹${expense.amount.toStringAsFixed(2)}',
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
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      expense.recurringType?.toUpperCase() ?? 'RECURRING',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: NeoBrutalismTheme.primaryWhite,
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

  Widget _buildIncomeCard(IncomeModel income, int index) {
    return Dismissible(
      key: Key(income.id),
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
      confirmDismiss: (direction) async {
        return await Get.dialog<bool>(
              AlertDialog(
                title: const Text('Delete Income'),
                content: Text(
                  'Are you sure you want to delete "${income.title}"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) {
        incomeController.deleteIncome(income.id);
        Get.snackbar(
          'Deleted',
          '${income.title} removed',
          backgroundColor: NeoBrutalismTheme.accentGreen,
          colorText: NeoBrutalismTheme.primaryBlack,
          borderWidth: 3,
          borderColor: NeoBrutalismTheme.primaryBlack,
          duration: const Duration(seconds: 2),
        );
      },
      child: NeoCard(
        onTap: () => Get.toNamed('/income-detail', arguments: income),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: NeoBrutalismTheme.neoBox(
                color: NeoBrutalismTheme.accentGreen,
              ),
              child: const Center(
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 28,
                  color: NeoBrutalismTheme.primaryBlack,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    income.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          income.source,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${income.date.day}/${income.date.month}/${income.date.year}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '+₹${income.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2, end: 0);
  }
}
