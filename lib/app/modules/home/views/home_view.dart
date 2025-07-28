import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/expense_model.dart';
import '../../../data/models/todo_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../analytics/views/analytics_view.dart';
import '../../expense/views/expense_view.dart';
import '../../todo/views/todo_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalismTheme.primaryWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildQuickStats(),
            Expanded(
              child: Obx(
                () => IndexedStack(
                  index: controller.selectedIndex.value,
                  children: [
                    _buildDashboard(),
                    ExpenseView(),
                    TodoView(),
                    AnalyticsView(),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: NeoBrutalismTheme.accentYellow,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MAGIC LEDGER',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'Track. Save. Achieve.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Get.toNamed('/settings'),
            icon: const Icon(Icons.settings, size: 28),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildQuickStats() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildStatCard(
            'THIS MONTH',
            '\$${controller.totalExpensesThisMonth.value.toStringAsFixed(2)}',
            NeoBrutalismTheme.accentPink,
            Icons.attach_money,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'PENDING',
            '${controller.pendingTodos.value}',
            NeoBrutalismTheme.accentBlue,
            Icons.checklist,
          ),
          const SizedBox(width: 16),
          _buildStatCard(
            'SAVED',
            '${controller.savingsPercentage.value.toStringAsFixed(0)}%',
            NeoBrutalismTheme.accentGreen,
            Icons.savings,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return NeoCard(
      width: 150,
      color: color,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 24),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Replace AnimatedCounter with simple Text for now
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Obx(
          //   () => Expanded(
          //     child: AnimatedCounter(
          //       value: value,
          //       textStyle: const TextStyle(
          //         fontSize: 24,
          //         fontWeight: FontWeight.w900,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildQuickActions(),
        const SizedBox(height: 24),
        _buildRecentExpenses(),
        const SizedBox(height: 24),
        _buildUpcomingTodos(),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUICK ACTIONS',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: NeoButton(
                text: 'ADD EXPENSE',
                onPressed: () => Get.toNamed('/add-expense'),
                color: NeoBrutalismTheme.accentOrange,
                icon: Icons.add_circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: NeoButton(
                text: 'ADD TODO',
                onPressed: () => Get.toNamed('/add-todo'),
                color: NeoBrutalismTheme.accentPurple,
                icon: Icons.task_alt,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildRecentExpenses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'RECENT EXPENSES',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            TextButton(
              onPressed: () => controller.changeTab(1),
              child: const Text('SEE ALL'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          final recentExpenses =
              controller.expenseController.expenses.take(3).toList();

          if (recentExpenses.isEmpty) {
            return NeoCard(
              child: Center(
                child: Text(
                  'No expenses yet',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
            );
          }

          return Column(
            children:
                recentExpenses
                    .map(
                      (expense) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildExpenseItem(expense),
                      ),
                    )
                    .toList(),
          );
        }),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildExpenseItem(ExpenseModel expense) {
    return NeoCard(
      onTap: () => Get.toNamed('/expense-detail', arguments: expense),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: NeoBrutalismTheme.neoBox(
                  color: NeoBrutalismTheme.accentBlue,
                ),
                child: const Icon(Icons.shopping_bag),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${expense.date.day}/${expense.date.month}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          Text(
            '-\$${expense.amount.toStringAsFixed(2)}',
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

  Widget _buildUpcomingTodos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'UPCOMING TODOS',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            TextButton(
              onPressed: () => controller.changeTab(2),
              child: const Text('SEE ALL'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          final upcomingTodos =
              controller.todoController.todos
                  .where((todo) => !todo.isCompleted)
                  .take(3)
                  .toList();

          if (upcomingTodos.isEmpty) {
            return NeoCard(
              child: Center(
                child: Text(
                  'No todos yet',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
            );
          }

          return Column(
            children:
                upcomingTodos
                    .map(
                      (todo) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTodoItem(todo),
                      ),
                    )
                    .toList(),
          );
        }),
      ],
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildTodoItem(TodoModel todo) {
    return NeoCard(
      color: _getPriorityColor(todo.priority),
      child: Row(
        children: [
          Checkbox(
            value: todo.isCompleted,
            onChanged: (value) {
              todo.isCompleted = value ?? false;
              todo.save();
              controller.todoController.update();
            },
            activeColor: NeoBrutalismTheme.primaryBlack,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration:
                        todo.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (todo.dueDate != null)
                  Text(
                    'Due: ${todo.dueDate!.day}/${todo.dueDate!.month}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
              ],
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

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: NeoBrutalismTheme.primaryBlack,
            width: NeoBrutalismTheme.borderWidth,
          ),
        ),
      ),
      child: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: NeoBrutalismTheme.primaryWhite,
          selectedItemColor: NeoBrutalismTheme.primaryBlack,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 28),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money, size: 28),
              label: 'EXPENSES',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt, size: 28),
              label: 'TODOS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics, size: 28),
              label: 'ANALYTICS',
            ),
          ],
        ),
      ),
    );
  }
}
