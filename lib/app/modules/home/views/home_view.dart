import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/expense_model.dart';
import '../../../data/models/income_model.dart';
import '../../../data/models/todo_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../analytics/views/analytics_view.dart';
import '../../category/controllers/category_controller.dart';
import '../../expense/views/expense_view.dart';
import '../../todo/views/todo_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.selectedIndex.value == 0) {
        controller.refreshStats();
      }
    });

    final categoryController = Get.find<CategoryController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(isDark),
              _buildQuickStats(isDark),
              Expanded(
                child: Obx(
                      () => IndexedStack(
                    index: controller.selectedIndex.value,
                    children: [
                      _buildDashboard(categoryController, isDark),
                      ExpenseView(),
                      TodoView(),
                      AnalyticsView(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.11),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNav(isDark),
          ),
        ],
      ),
    );
  }

  // Helper method to get muted colors for dark theme
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

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : NeoBrutalismTheme.accentYellow,
        border: Border(
          bottom: BorderSide(
            color: NeoBrutalismTheme.primaryBlack,
            width: NeoBrutalismTheme.borderWidth,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MAGIC LEDGER',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
                  ),
                ),
                Text(
                  'Track. Save. Achieve.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.grey[400]
                        : NeoBrutalismTheme.primaryBlack,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: NeoBrutalismTheme.neoBox(
                  color: _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
                  offset: 3,
                  borderColor: NeoBrutalismTheme.primaryBlack,
                ),
                child: IconButton(
                  onPressed: () => Get.toNamed('/add-income'),
                  icon: Icon(
                    Icons.add_circle_outline,
                    size: 24,
                    color: NeoBrutalismTheme.primaryBlack,
                  ),
                  tooltip: 'Add Income',
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => Get.toNamed('/settings'),
                icon: Icon(
                  Icons.settings,
                  size: 28,
                  color: isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildQuickStats(bool isDark) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Obx(
                () => _buildStatCard(
              'BALANCE',
              _formatCurrency(
                controller.totalIncomeThisMonth.value -
                    controller.totalExpensesThisMonth.value,
              ),
              _getThemedColor(NeoBrutalismTheme.accentSage, isDark),
              Icons.balance,
              isDark: isDark,
              onTap: () => _showStatDialog(
                'Monthly Balance',
                '₹${controller.totalIncomeThisMonth.value - controller.totalExpensesThisMonth.value}',
                'Total balance left this month',
                _getThemedColor(NeoBrutalismTheme.accentSage, isDark),
                Icons.balance,
                isDark,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Obx(
                () => _buildStatCard(
              'THIS MONTH',
              _formatCurrency(controller.totalExpensesThisMonth.value),
              _getThemedColor(NeoBrutalismTheme.accentPink, isDark),
              Icons.attach_money,
              isDark: isDark,
              onTap: () => _showStatDialog(
                'Monthly Expenses',
                '₹${controller.totalExpensesThisMonth.value.toStringAsFixed(2)}',
                'Total amount spent this month',
                _getThemedColor(NeoBrutalismTheme.accentPink, isDark),
                Icons.attach_money,
                isDark,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Obx(
                () => _buildStatCard(
              'PENDING',
              '${controller.pendingTodos.value}',
              _getThemedColor(NeoBrutalismTheme.accentBlue, isDark),
              Icons.checklist,
              isDark: isDark,
              onTap: () => _showStatDialog(
                'Pending Tasks',
                '${controller.pendingTodos.value} tasks',
                'Number of incomplete todos',
                _getThemedColor(NeoBrutalismTheme.accentBlue, isDark),
                Icons.checklist,
                isDark,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Obx(
                () => _buildStatCard(
              'SAVED',
              '${controller.savingsPercentage.value.toStringAsFixed(1)}%',
              _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
              Icons.savings,
              isDark: isDark,
              onTap: () => _showStatDialog(
                'Savings Rate',
                '${controller.savingsPercentage.value.toStringAsFixed(1)}%',
                'Percentage of income saved this month\nIncome: ₹${controller.totalIncomeThisMonth.value.toStringAsFixed(2)}\nExpenses: ₹${controller.totalExpensesThisMonth.value.toStringAsFixed(2)}',
                _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
                Icons.savings,
                isDark,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Obx(
                () => _buildStatCard(
              'INCOME',
              _formatCurrency(controller.totalIncomeThisMonth.value),
              _getThemedColor(NeoBrutalismTheme.accentPurple, isDark),
              Icons.account_balance_wallet,
              isDark: isDark,
              onTap: () => _showStatDialog(
                'Monthly Income',
                '₹${controller.totalIncomeThisMonth.value.toStringAsFixed(2)}',
                'Total income received this month',
                _getThemedColor(NeoBrutalismTheme.accentPurple, isDark),
                Icons.account_balance_wallet,
                isDark,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0);
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }

  Widget _buildStatCard(
      String label,
      String value,
      Color color,
      IconData icon, {
        VoidCallback? onTap,
        required bool isDark,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: NeoCard(
        width: 150,
        color: color,
        padding: const EdgeInsets.all(12),
        borderColor: NeoBrutalismTheme.primaryBlack,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: NeoBrutalismTheme.primaryBlack),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      color: NeoBrutalismTheme.primaryBlack,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: NeoBrutalismTheme.primaryBlack,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Colors.black54,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStatDialog(
      String title,
      String value,
      String description,
      Color color,
      IconData icon,
      bool isDark,
      ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, size: 32, color: NeoBrutalismTheme.primaryBlack),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: NeoBrutalismTheme.primaryBlack,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.primaryBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: NeoBrutalismTheme.primaryBlack,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              NeoButton(
                text: 'CLOSE',
                onPressed: () => Get.back(),
                color: NeoBrutalismTheme.primaryWhite,
                textColor: NeoBrutalismTheme.primaryBlack,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(CategoryController categoryController, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildQuickActions(isDark),
        const SizedBox(height: 24),
        _buildManagementSection(categoryController, isDark),
        const SizedBox(height: 24),
        _buildRecentTransactions(categoryController, isDark),
        const SizedBox(height: 24),
        _buildUpcomingTodos(isDark),
      ],
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACTIONS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark
                ? NeoBrutalismTheme.darkText
                : NeoBrutalismTheme.primaryBlack,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: NeoButton(
                text: 'ADD EXPENSE',
                onPressed: () => Get.toNamed('/add-expense'),
                color: _getThemedColor(NeoBrutalismTheme.accentOrange, isDark),
                icon: Icons.remove_circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: NeoButton(
                text: 'ADD TODO',
                onPressed: () => Get.toNamed('/add-todo'),
                color: _getThemedColor(NeoBrutalismTheme.accentPurple, isDark),
                icon: Icons.task_alt,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  // NEW MANAGEMENT SECTION
  Widget _buildManagementSection(
      CategoryController categoryController, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MANAGE',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark
                ? NeoBrutalismTheme.darkText
                : NeoBrutalismTheme.primaryBlack,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildManagementCard(
                'CATEGORIES',
                Icons.category,
                _getThemedColor(NeoBrutalismTheme.accentYellow, isDark),
                    () => Get.toNamed('/categories'),
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildManagementCard(
                'BUDGETS',
                Icons.account_balance_wallet,
                _getThemedColor(NeoBrutalismTheme.accentBlue, isDark),
                    () => Get.toNamed('/budgets'),
                isDark,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildManagementCard(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      bool isDark,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: NeoCard(
        color: color,
        borderColor: NeoBrutalismTheme.primaryBlack,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: NeoBrutalismTheme.primaryBlack),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.primaryBlack,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: NeoBrutalismTheme.primaryBlack,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(
      CategoryController categoryController,
      bool isDark,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT TRANSACTIONS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark
                    ? NeoBrutalismTheme.darkText
                    : NeoBrutalismTheme.primaryBlack,
              ),
            ),
            TextButton(
              onPressed: () => _showAllTransactionsDialog(categoryController, isDark),
              child: const Text(
                'SEE ALL',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          final recentExpenses =
          controller.expenseController.expenses.take(3).toList();
          final recentIncomes =
          controller.incomeController.incomes.take(3).toList();

          final List<Map<String, dynamic>> recentTransactions = [];

          for (var expense in recentExpenses) {
            recentTransactions.add({
              'type': 'expense',
              'data': expense,
              'date': expense.date,
            });
          }

          for (var income in recentIncomes) {
            recentTransactions.add({
              'type': 'income',
              'data': income,
              'date': income.date,
            });
          }

          recentTransactions.sort((a, b) => b['date'].compareTo(a['date']));
          final displayTransactions = recentTransactions.take(6).toList();

          if (displayTransactions.isEmpty) {
            return _buildEmptyState(
              icon: Icons.receipt_long,
              title: 'No transactions yet',
              subtitle: 'Add your first expense or income to get started',
              isDark: isDark,
            );
          }

          return Column(
            children: displayTransactions
                .map(
                  (transaction) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: transaction['type'] == 'expense'
                    ? _buildExpenseItem(
                  transaction['data'],
                  categoryController,
                  isDark,
                )
                    : _buildIncomeItem(transaction['data'], isDark),
              ),
            )
                .toList(),
          );
        }),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  void _showAllTransactionsDialog(
      CategoryController categoryController, bool isDark) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
        ),
        child: Container(
          height: Get.height * 0.7,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? NeoBrutalismTheme.darkSurface
                : NeoBrutalismTheme.primaryWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ALL TRANSACTIONS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close,
                      color: isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  final allExpenses = controller.expenseController.expenses;
                  final allIncomes = controller.incomeController.incomes;

                  final List<Map<String, dynamic>> allTransactions = [];

                  for (var expense in allExpenses) {
                    allTransactions.add({
                      'type': 'expense',
                      'data': expense,
                      'date': expense.date,
                    });
                  }

                  for (var income in allIncomes) {
                    allTransactions.add({
                      'type': 'income',
                      'data': income,
                      'date': income.date,
                    });
                  }

                  allTransactions
                      .sort((a, b) => b['date'].compareTo(a['date']));

                  if (allTransactions.isEmpty) {
                    return Center(
                      child: Text(
                        'No transactions found',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: allTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = allTransactions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: transaction['type'] == 'expense'
                            ? _buildExpenseItem(
                          transaction['data'],
                          categoryController,
                          isDark,
                        )
                            : _buildIncomeItem(transaction['data'], isDark),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return NeoCard(
      color: isDark
          ? NeoBrutalismTheme.darkSurface
          : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(icon, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark ? Colors.grey[600] : Colors.grey[500],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseItem(
      ExpenseModel expense,
      CategoryController categoryController,
      bool isDark,
      ) {
    final category = categoryController.categories.firstWhere(
          (c) => c.id == expense.categoryId,
      orElse: () => categoryController.categories.first,
    );

    return NeoCard(
      onTap: () => Get.toNamed('/expense-detail', arguments: expense),
      color: isDark
          ? NeoBrutalismTheme.darkSurface
          : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: NeoBrutalismTheme.neoBox(
              color: _getThemedColor(category.colorValue, isDark),
              borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: Center(
              child: Text(category.icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red, width: 1),
                      ),
                      child: const Text(
                        'EXPENSE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        expense.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? NeoBrutalismTheme.darkText
                              : NeoBrutalismTheme.primaryBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      ' • ${expense.date.day}/${expense.date.month}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '-₹${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeItem(IncomeModel income, bool isDark) {
    return NeoCard(
      onTap: () => Get.toNamed('/income-detail', arguments: income),
      color: isDark
          ? NeoBrutalismTheme.darkSurface
          : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: NeoBrutalismTheme.neoBox(
              color: _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
              borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: const Center(
              child: Icon(
                Icons.account_balance_wallet,
                size: 24,
                color: NeoBrutalismTheme.primaryBlack,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green, width: 1),
                      ),
                      child: const Text(
                        'INCOME',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        income.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? NeoBrutalismTheme.darkText
                              : NeoBrutalismTheme.primaryBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        income.source,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      ' • ${income.date.day}/${income.date.month}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
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
    );
  }

  Widget _buildUpcomingTodos(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'UPCOMING TODOS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark
                    ? NeoBrutalismTheme.darkText
                    : NeoBrutalismTheme.primaryBlack,
              ),
            ),
            TextButton(
              onPressed: () => controller.changeTab(2),
              child: const Text('SEE ALL'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          final upcomingTodos = controller.todoController.todos
              .where((todo) => !todo.isCompleted)
              .take(3)
              .toList();

          if (upcomingTodos.isEmpty) {
            return _buildEmptyState(
              icon: Icons.task_alt,
              title: 'No todos yet',
              subtitle: 'Add your first todo to stay organized',
              isDark: isDark,
            );
          }

          return Column(
            children: upcomingTodos
                .map(
                  (todo) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTodoItem(todo, isDark),
              ),
            )
                .toList(),
          );
        }),
      ],
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildTodoItem(TodoModel todo, bool isDark) {
    final bgColor = _getThemedColor(_getPriorityColor(todo.priority), isDark);
    final textColor = _getContrastTextColor(bgColor);

    return NeoCard(
      color: bgColor,
      borderColor: NeoBrutalismTheme.primaryBlack,
      onTap: () => Get.toNamed('/todo-detail', arguments: todo),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              await controller.todoController.toggleTodo(todo);
              controller.calculateStats();
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: todo.isCompleted
                    ? NeoBrutalismTheme.primaryBlack
                    : Colors.transparent,
                border: Border.all(color: textColor, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: todo.isCompleted
                  ? Icon(
                Icons.check,
                size: 16,
                color: NeoBrutalismTheme.primaryWhite,
              )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed('/todo-detail', arguments: todo),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      decoration:
                      todo.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (todo.dueDate != null)
                    Text(
                      'Due: ${todo.dueDate!.day}/${todo.dueDate!.month}',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: textColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getPriorityLabel(todo.priority),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: bgColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 3:
        return NeoBrutalismTheme.accentPink;
      case 2:
        return NeoBrutalismTheme.accentYellow;
      default:
        return NeoBrutalismTheme.primaryWhite;
    }
  }

  Color _getContrastTextColor(Color backgroundColor) {
    if (backgroundColor == NeoBrutalismTheme.primaryWhite) {
      return NeoBrutalismTheme.primaryBlack;
    }
    return NeoBrutalismTheme.primaryBlack;
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 3:
        return 'HIGH';
      case 2:
        return 'MED';
      default:
        return 'LOW';
    }
  }

  Widget _buildBottomNav(bool isDark) {
    final screenHeight = MediaQuery.of(Get.context!).size.height;
    final navbarHeight = screenHeight * 0.09;

    return Container(
      margin: EdgeInsets.all(screenHeight * 0.02),
      height: navbarHeight.clamp(65.0, 85.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: NeoBrutalismTheme.primaryBlack,
            offset: const Offset(4, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
          border: Border.all(
            color: NeoBrutalismTheme.primaryBlack,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenHeight * 0.01,
              vertical: screenHeight * 0.008,
            ),
            child: Obx(
                  () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: _buildNavItem(
                      Icons.home_rounded,
                      'HOME',
                      0,
                      _getThemedColor(NeoBrutalismTheme.accentPurple, isDark),
                      isDark,
                    ),
                  ),
                  Flexible(
                    child: _buildNavItem(
                      Icons.receipt_long_rounded,
                      'EXPENSES',
                      1,
                      _getThemedColor(NeoBrutalismTheme.accentPink, isDark),
                      isDark,
                    ),
                  ),
                  Flexible(
                    child: _buildNavItem(
                      Icons.check_box_rounded,
                      'TODOS',
                      2,
                      _getThemedColor(NeoBrutalismTheme.accentBlue, isDark),
                      isDark,
                    ),
                  ),
                  Flexible(
                    child: _buildNavItem(
                      Icons.bar_chart_rounded,
                      'STATS',
                      3,
                      _getThemedColor(NeoBrutalismTheme.accentYellow, isDark),
                      isDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 1, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildNavItem(
      IconData icon,
      String label,
      int index,
      Color activeColor,
      bool isDark,
      ) {
    final isSelected = controller.selectedIndex.value == index;
    final screenHeight = MediaQuery.of(Get.context!).size.height;
    final iconSize = screenHeight * 0.024;
    final selectedIconSize = screenHeight * 0.028;

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isSelected
                    ? selectedIconSize.clamp(32.0, 42.0)
                    : iconSize.clamp(26.0, 36.0),
                height: isSelected
                    ? selectedIconSize.clamp(32.0, 42.0)
                    : iconSize.clamp(26.0, 36.0),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? NeoBrutalismTheme.primaryBlack
                        : Colors.transparent,
                    width: isSelected ? 2 : 0,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: NeoBrutalismTheme.primaryBlack,
                      offset: const Offset(2, 2),
                    ),
                  ]
                      : [],
                ),
                child: Icon(
                  icon,
                  size: isSelected
                      ? (selectedIconSize * 0.6).clamp(16.0, 22.0)
                      : (iconSize * 0.6).clamp(14.0, 20.0),
                  color: isSelected
                      ? NeoBrutalismTheme.primaryBlack
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
              SizedBox(height: screenHeight * 0.004),
              Text(
                label,
                style: TextStyle(
                  fontSize: (screenHeight * 0.011).clamp(8.0, 11.0),
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: isSelected
                      ? (isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack)
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}