import 'package:get/get.dart';

import '../../expense/controllers/expense_controller.dart';
import '../../income/controllers/income_controller.dart';
import '../../todo/controllers/todo_controller.dart';

class HomeController extends GetxController {
  final ExpenseController expenseController = Get.find();
  final TodoController todoController = Get.find();
  final IncomeController incomeController = Get.find();

  final RxInt selectedIndex = 0.obs;
  final RxDouble totalExpensesThisMonth = 0.0.obs;
  final RxDouble totalIncomeThisMonth = 0.0.obs;
  final RxInt pendingTodos = 0.obs;
  final RxDouble savingsPercentage = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    calculateStats();

    // Listen to changes in all controllers
    ever(expenseController.expenses, (_) => calculateStats());
    ever(todoController.todos, (_) => calculateStats());
    ever(incomeController.incomes, (_) => calculateStats());
  }

  @override
  void onReady() {
    super.onReady();
    // Recalculate stats when the view is ready
    calculateStats();
  }

  void calculateStats() {
    try {
      // Calculate total expenses this month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      totalExpensesThisMonth.value = expenseController.expenses
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

      // Calculate pending todos
      pendingTodos.value =
          todoController.todos.where((todo) => !todo.isCompleted).length;

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
    }
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  // Force refresh method that can be called from other views
  void refreshStats() {
    // Refresh all controller data first
    expenseController.loadExpenses();
    incomeController.loadIncomes();
    todoController.loadTodos();

    // Then recalculate stats
    calculateStats();
  }
}
