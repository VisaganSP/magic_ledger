import 'package:get/get.dart';

import '../../expense/controllers/expense_controller.dart';
import '../../income/controllers/income_controller.dart';
import '../../todo/controllers/todo_controller.dart';

class HomeController extends GetxController {
  late final ExpenseController expenseController;
  late final TodoController todoController;
  late final IncomeController incomeController;

  final RxInt selectedIndex = 0.obs;
  final RxDouble totalExpensesThisMonth = 0.0.obs;
  final RxDouble totalIncomeThisMonth = 0.0.obs;
  final RxInt pendingTodos = 0.obs;
  final RxDouble savingsPercentage = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize controllers
    expenseController = Get.find<ExpenseController>();
    todoController = Get.find<TodoController>();
    incomeController = Get.find<IncomeController>();

    // Initial calculation
    calculateStats();

    // Set up reactive bindings with more specific listeners
    setupReactiveBindings();
  }

  void setupReactiveBindings() {
    // Listen to changes in expenses
    ever(expenseController.expenses, (_) {
      print('Expenses changed, recalculating stats...');
      calculateStats();
    });

    // Listen to changes in todos
    ever(todoController.todos, (_) {
      print('Todos changed, recalculating stats...');
      calculateStats();
    });

    // Listen to changes in incomes
    ever(incomeController.incomes, (_) {
      print('Incomes changed, recalculating stats...');
      calculateStats();
    });

    // Also listen to todo counts
    ever(todoController.pendingCount, (_) => calculateStats());
    ever(todoController.completedCount, (_) => calculateStats());
  }

  @override
  void onReady() {
    super.onReady();
    // Force a refresh when the view is ready
    refreshStats();
  }

  void calculateStats() {
    try {
      // Calculate total expenses this month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      // Make sure we're using the latest data
      final expenses = expenseController.expenses;
      final todos = todoController.todos;
      final incomes = incomeController.incomes;

      totalExpensesThisMonth.value = expenses
          .where(
            (expense) =>
                expense.date.year == now.year &&
                expense.date.month == now.month,
          )
          .fold(0.0, (sum, expense) => sum + expense.amount);

      // Calculate total income this month
      totalIncomeThisMonth.value = incomeController.getTotalIncomeByDateRange(
        startOfMonth,
        endOfMonth,
      );

      // Calculate pending todos - force refresh from the list
      pendingTodos.value = todos.where((todo) => !todo.isCompleted).length;

      print('Pending todos calculated: ${pendingTodos.value}');
      print('Total todos: ${todos.length}');

      // Calculate savings percentage
      if (totalIncomeThisMonth.value > 0) {
        final saved = totalIncomeThisMonth.value - totalExpensesThisMonth.value;
        savingsPercentage.value = (saved / totalIncomeThisMonth.value * 100)
            .clamp(0, 100);
      } else {
        savingsPercentage.value = 0.0;
      }

      // Force UI update
      update();
    } catch (e) {
      print('Error calculating stats: $e');
      // Set default values in case of error
      totalExpensesThisMonth.value = 0.0;
      totalIncomeThisMonth.value = 0.0;
      pendingTodos.value = 0;
      savingsPercentage.value = 0.0;
      update();
    }
  }

  void changeTab(int index) {
    selectedIndex.value = index;

    // Always refresh stats when returning to home tab
    if (index == 0) {
      // Small delay to ensure any pending updates are complete
      Future.delayed(const Duration(milliseconds: 100), () {
        refreshStats();
      });
    }
  }

  // Force refresh method that can be called from other views
  void refreshStats() {
    print('Refreshing all stats...');

    // Refresh all controller data first
    expenseController.loadExpenses();
    incomeController.loadIncomes();
    todoController.loadTodos();

    // Small delay to ensure data is loaded
    Future.delayed(const Duration(milliseconds: 100), () {
      // Then recalculate stats
      calculateStats();
    });
  }

  // Method to be called when returning to home from other screens
  void onReturnToHome() {
    refreshStats();
  }
}
