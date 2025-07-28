import 'package:get/get.dart';

import '../../../data/models/expense_model.dart';
import '../../../data/models/todo_model.dart';
import '../../expense/controllers/expense_controller.dart';
import '../../todo/controllers/todo_controller.dart';

class HomeController extends GetxController {
  final ExpenseController expenseController = Get.find();
  final TodoController todoController = Get.find();

  final RxInt selectedIndex = 0.obs;
  final RxDouble totalExpensesThisMonth = 0.0.obs;
  final RxInt pendingTodos = 0.obs;
  final RxDouble savingsPercentage = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    calculateStats();
    ever(expenseController.expenses, (_) => calculateStats());
    ever(todoController.todos, (_) => calculateStats());
  }

  void calculateStats() {
    // Calculate total expenses this month
    final now = DateTime.now();
    final thisMonthExpenses =
        expenseController.expenses
            .where(
              (expense) =>
                  expense.date.year == now.year &&
                  expense.date.month == now.month,
            )
            .toList();

    totalExpensesThisMonth.value = thisMonthExpenses.fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    // Calculate pending todos
    pendingTodos.value =
        todoController.todos.where((todo) => !todo.isCompleted).length;

    // Calculate savings percentage (mock calculation)
    final budget = 5000.0; // This should come from budget settings
    if (budget > 0) {
      savingsPercentage.value = ((budget - totalExpensesThisMonth.value) /
              budget *
              100)
          .clamp(0, 100);
    }
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}
