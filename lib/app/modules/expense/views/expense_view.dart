import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/category_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/income_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
// Import your custom date range picker
import '../../../widgets/neo_date_range_picker.dart';
import '../../category/controllers/category_controller.dart';
import '../../income/controllers/income_controller.dart';
import '../controllers/expense_controller.dart';

class ExpenseView extends GetView<ExpenseController> {
  final CategoryController categoryController = Get.find();
  final IncomeController incomeController = Get.find();

  ExpenseView({super.key});

  final RxString selectedFilter = 'All'.obs;
  final RxString selectedType = 'Expenses'.obs; // 'Expenses' or 'Income'

  // Add custom date range variables
  final Rx<DateTime?> customStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> customEndDate = Rx<DateTime?>(null);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? NeoBrutalismTheme.darkBackground
              : NeoBrutalismTheme.primaryWhite,
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
                  ? _getThemedColor(NeoBrutalismTheme.accentOrange, isDark)
                  : _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
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
            _buildHeader(isDark),
            _buildTypeToggle(isDark),
            _buildFilterSection(isDark),
            Obx(() {
              if (selectedType.value == 'Expenses') {
                final filteredExpenses = _getFilteredExpenses();
                if (filteredExpenses.isEmpty) {
                  return _buildEmptyState(isDark);
                }
                return _buildExpenseList(filteredExpenses, isDark);
              } else {
                final filteredIncomes = _getFilteredIncomes();
                if (filteredIncomes.isEmpty) {
                  return _buildEmptyIncomeState(isDark);
                }
                return _buildIncomeList(filteredIncomes, isDark);
              }
            }),
            const SizedBox(height: 65), // Extra space for FAB
          ],
        ),
      ),
    );
  }

  // Helper method to get muted colors for dark theme
  Color _getThemedColor(Color color, bool isDark) {
    if (!isDark) return color;

    // Return slightly muted versions of colors for dark theme
    if (color == NeoBrutalismTheme.accentYellow) {
      return Color(0xFFE6B800); // Slightly darker yellow
    } else if (color == NeoBrutalismTheme.accentPink) {
      return Color(0xFFE667A0); // Slightly darker pink
    } else if (color == NeoBrutalismTheme.accentBlue) {
      return Color(0xFF4D94FF); // Slightly darker blue
    } else if (color == NeoBrutalismTheme.accentGreen) {
      return Color(0xFF00CC66); // Slightly darker green
    } else if (color == NeoBrutalismTheme.accentOrange) {
      return Color(0xFFFF8533); // Slightly darker orange
    } else if (color == NeoBrutalismTheme.accentPurple) {
      return Color(0xFF9966FF); // Slightly darker purple
    }
    return color;
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Text(
              selectedType.value.toUpperCase(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color:
                    isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
              ),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color:
                      isDark
                          ? Colors.grey[400]
                          : NeoBrutalismTheme.primaryBlack,
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color:
                      isDark
                          ? Colors.grey[400]
                          : NeoBrutalismTheme.primaryBlack,
                ),
              );
            }
          }),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }

  Widget _buildTypeToggle(bool isDark) {
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
                            ? _getThemedColor(
                              NeoBrutalismTheme.accentOrange,
                              isDark,
                            )
                            : (isDark
                                ? NeoBrutalismTheme.darkSurface
                                : NeoBrutalismTheme.primaryWhite),
                    offset: selectedType.value == 'Expenses' ? 2 : 5,
                    borderColor: NeoBrutalismTheme.primaryBlack,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.remove_circle,
                        color:
                            selectedType.value == 'Expenses'
                                ? NeoBrutalismTheme.primaryBlack
                                : (isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600]),
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
                                  : (isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600]),
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
                            ? _getThemedColor(
                              NeoBrutalismTheme.accentGreen,
                              isDark,
                            )
                            : (isDark
                                ? NeoBrutalismTheme.darkSurface
                                : NeoBrutalismTheme.primaryWhite),
                    offset: selectedType.value == 'Income' ? 2 : 5,
                    borderColor: NeoBrutalismTheme.primaryBlack,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle,
                        color:
                            selectedType.value == 'Income'
                                ? NeoBrutalismTheme.primaryBlack
                                : (isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600]),
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
                                  : (isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600]),
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

  Widget _buildFilterSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FILTER BY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.grey[600] : Colors.grey,
            ),
          ),
          const SizedBox(height: 0),
          _buildFilterGrid(isDark),
          // Add custom date range display if selected
          Obx(() {
            if (selectedFilter.value == 'Custom' &&
                customStartDate.value != null &&
                customEndDate.value != null) {
              return Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: NeoBrutalismTheme.neoBox(
                  color: _getThemedColor(NeoBrutalismTheme.accentBlue, isDark),
                  borderColor: NeoBrutalismTheme.primaryBlack,
                  offset: 2,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.date_range,
                      size: 20,
                      color: NeoBrutalismTheme.primaryBlack,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${customStartDate.value!.day}/${customStartDate.value!.month}/${customStartDate.value!.year} - ${customEndDate.value!.day}/${customEndDate.value!.month}/${customEndDate.value!.year}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: NeoBrutalismTheme.primaryBlack,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: NeoBrutalismTheme.primaryBlack,
                      ),
                      onPressed: () {
                        customStartDate.value = null;
                        customEndDate.value = null;
                        selectedFilter.value = 'All';
                      },
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.5, end: 0);
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildFilterGrid(bool isDark) {
    final filters = [
      {'label': 'All', 'icon': Icons.all_inclusive},
      {'label': 'Today', 'icon': Icons.today},
      {'label': 'This Week', 'icon': Icons.view_week},
      {'label': 'This Month', 'icon': Icons.calendar_month},
      {'label': 'Custom', 'icon': Icons.date_range}, // Add custom filter
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
            isDark,
            context, // Pass context for showing date picker
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    IconData icon,
    bool isSelected,
    bool isDark,
    BuildContext context, // Add context parameter
  ) {
    return GestureDetector(
      onTap: () {
        if (label == 'Custom') {
          // Show date range picker
          showDialog(
            context: context,
            builder:
                (context) => NeoDateRangePicker(
                  initialStartDate: customStartDate.value,
                  initialEndDate: customEndDate.value,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                  onDateRangeSelected: (start, end) {
                    if (start != null && end != null) {
                      customStartDate.value = start;
                      customEndDate.value = end;
                      selectedFilter.value = 'Custom';
                    }
                  },
                ),
          );
        } else {
          selectedFilter.value = label;
          // Reset custom dates when selecting other filters
          if (label != 'Custom') {
            customStartDate.value = null;
            customEndDate.value = null;
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: NeoBrutalismTheme.neoBox(
          color:
              isSelected
                  ? _getThemedColor(NeoBrutalismTheme.accentYellow, isDark)
                  : (isDark
                      ? NeoBrutalismTheme.darkSurface
                      : NeoBrutalismTheme.primaryWhite),
          offset: isSelected ? 2 : 5,
          borderColor: NeoBrutalismTheme.primaryBlack,
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
                      : (isDark ? Colors.grey[400] : Colors.grey[700]),
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
                          : (isDark ? Colors.grey[400] : Colors.grey[700]),
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
      case 'Custom':
        if (customStartDate.value != null && customEndDate.value != null) {
          return controller.getExpensesByDateRange(
            customStartDate.value!,
            customEndDate.value!,
          );
        }
        return controller.expenses.toList();
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
      case 'Custom':
        if (customStartDate.value != null && customEndDate.value != null) {
          // Add custom date range filtering for income
          return incomeController.incomes.where((income) {
            return income.date.isAfter(
                  customStartDate.value!.subtract(const Duration(days: 1)),
                ) &&
                income.date.isBefore(
                  customEndDate.value!.add(const Duration(days: 1)),
                );
          }).toList();
        }
        return incomeController.incomes.toList();
      default:
        return incomeController.incomes.toList();
    }
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: NeoBrutalismTheme.neoBox(
              color: _getThemedColor(NeoBrutalismTheme.accentPink, isDark),
              borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: const Icon(
              Icons.receipt_long,
              size: 60,
              color: NeoBrutalismTheme.primaryBlack,
            ),
          ).animate().scale(duration: 500.ms),
          const SizedBox(height: 24),
          Obx(() {
            final isFiltered = selectedFilter.value != 'All';
            return Column(
              children: [
                Text(
                  isFiltered ? 'NO EXPENSES FOUND' : 'NO EXPENSES YET',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color:
                        isDark
                            ? NeoBrutalismTheme.darkText
                            : NeoBrutalismTheme.primaryBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isFiltered
                      ? 'No expenses for ${selectedFilter.value.toLowerCase()}'
                      : 'Start tracking your expenses',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),
          NeoButton(
            text: 'ADD EXPENSE',
            onPressed: () => Get.toNamed('/add-expense'),
            color: _getThemedColor(NeoBrutalismTheme.accentOrange, isDark),
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyIncomeState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: NeoBrutalismTheme.neoBox(
              color: _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
              borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              size: 60,
              color: NeoBrutalismTheme.primaryBlack,
            ),
          ).animate().scale(duration: 500.ms),
          const SizedBox(height: 24),
          Obx(() {
            final isFiltered = selectedFilter.value != 'All';
            return Column(
              children: [
                Text(
                  isFiltered ? 'NO INCOME FOUND' : 'NO INCOME YET',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color:
                        isDark
                            ? NeoBrutalismTheme.darkText
                            : NeoBrutalismTheme.primaryBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isFiltered
                      ? 'No income for ${selectedFilter.value.toLowerCase()}'
                      : 'Start tracking your income',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),
          NeoButton(
            text: 'ADD INCOME',
            onPressed: () => Get.toNamed('/add-income'),
            color: _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(List<ExpenseModel> expenses, bool isDark) {
    return Column(
      children:
          expenses.asMap().entries.map((entry) {
            final index = entry.key;
            final expense = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildExpenseCard(expense, index, isDark),
            );
          }).toList(),
    );
  }

  Widget _buildIncomeList(List<IncomeModel> incomes, bool isDark) {
    return Column(
      children:
          incomes.asMap().entries.map((entry) {
            final index = entry.key;
            final income = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildIncomeCard(income, index, isDark),
            );
          }).toList(),
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense, int index, bool isDark) {
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
        decoration: NeoBrutalismTheme.neoBox(
          color: Colors.red,
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: const Icon(
          Icons.delete,
          color: NeoBrutalismTheme.primaryWhite,
          size: 32,
        ),
      ),
      confirmDismiss: (direction) async {
        return await Get.dialog<bool>(
              AlertDialog(
                backgroundColor:
                    isDark
                        ? NeoBrutalismTheme.darkSurface
                        : NeoBrutalismTheme.primaryWhite,
                title: Text(
                  'Delete Expense',
                  style: TextStyle(
                    color:
                        isDark
                            ? NeoBrutalismTheme.darkText
                            : NeoBrutalismTheme.primaryBlack,
                  ),
                ),
                content: Text(
                  'Are you sure you want to delete "${expense.title}"?',
                  style: TextStyle(
                    color:
                        isDark
                            ? NeoBrutalismTheme.darkText
                            : NeoBrutalismTheme.primaryBlack,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color:
                            isDark
                                ? NeoBrutalismTheme.darkText
                                : NeoBrutalismTheme.primaryBlack,
                      ),
                    ),
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
          backgroundColor: _getThemedColor(
            NeoBrutalismTheme.accentPink,
            isDark,
          ),
          colorText: NeoBrutalismTheme.primaryBlack,
          borderWidth: 3,
          borderColor: NeoBrutalismTheme.primaryBlack,
          duration: const Duration(seconds: 2),
        );
      },
      child: NeoCard(
        onTap: () => Get.toNamed('/expense-detail', arguments: expense),
        color:
            isDark
                ? NeoBrutalismTheme.darkSurface
                : NeoBrutalismTheme.primaryWhite,
        borderColor: NeoBrutalismTheme.primaryBlack,
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: NeoBrutalismTheme.neoBox(
                color: _getThemedColor(categoryColor, isDark),
                borderColor: NeoBrutalismTheme.primaryBlack,
              ),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark
                              ? NeoBrutalismTheme.darkText
                              : NeoBrutalismTheme.primaryBlack,
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
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${expense.date.day}/${expense.date.month}/${expense.date.year}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
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
                                    color: _getThemedColor(
                                      NeoBrutalismTheme.accentYellow,
                                      isDark,
                                    ),
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
                                      color: NeoBrutalismTheme.primaryBlack,
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
                      color: _getThemedColor(
                        NeoBrutalismTheme.accentPurple,
                        isDark,
                      ),
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

  Widget _buildIncomeCard(IncomeModel income, int index, bool isDark) {
    return Dismissible(
      key: Key(income.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: NeoBrutalismTheme.neoBox(
          color: Colors.red,
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: const Icon(
          Icons.delete,
          color: NeoBrutalismTheme.primaryWhite,
          size: 32,
        ),
      ),
      confirmDismiss: (direction) async {
        return await Get.dialog<bool>(
              AlertDialog(
                backgroundColor:
                    isDark
                        ? NeoBrutalismTheme.darkSurface
                        : NeoBrutalismTheme.primaryWhite,
                title: Text(
                  'Delete Income',
                  style: TextStyle(
                    color:
                        isDark
                            ? NeoBrutalismTheme.darkText
                            : NeoBrutalismTheme.primaryBlack,
                  ),
                ),
                content: Text(
                  'Are you sure you want to delete "${income.title}"?',
                  style: TextStyle(
                    color:
                        isDark
                            ? NeoBrutalismTheme.darkText
                            : NeoBrutalismTheme.primaryBlack,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color:
                            isDark
                                ? NeoBrutalismTheme.darkText
                                : NeoBrutalismTheme.primaryBlack,
                      ),
                    ),
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
          backgroundColor: _getThemedColor(
            NeoBrutalismTheme.accentGreen,
            isDark,
          ),
          colorText: NeoBrutalismTheme.primaryBlack,
          borderWidth: 3,
          borderColor: NeoBrutalismTheme.primaryBlack,
          duration: const Duration(seconds: 2),
        );
      },
      child: NeoCard(
        onTap: () => Get.toNamed('/income-detail', arguments: income),
        color:
            isDark
                ? NeoBrutalismTheme.darkSurface
                : NeoBrutalismTheme.primaryWhite,
        borderColor: NeoBrutalismTheme.primaryBlack,
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: NeoBrutalismTheme.neoBox(
                color: _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
                borderColor: NeoBrutalismTheme.primaryBlack,
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark
                              ? NeoBrutalismTheme.darkText
                              : NeoBrutalismTheme.primaryBlack,
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
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${income.date.day}/${income.date.month}/${income.date.year}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
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
