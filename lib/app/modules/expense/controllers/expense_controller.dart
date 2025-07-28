import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../data/models/expense_model.dart';
import '../../../data/services/notification_service.dart';

class ExpenseController extends GetxController {
  final Box<ExpenseModel> _expenseBox = Hive.box('expenses');
  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  final NotificationService _notificationService = NotificationService();

  @override
  void onInit() {
    super.onInit();
    loadExpenses();
    checkRecurringExpenses();
  }

  void loadExpenses() {
    expenses.value =
        _expenseBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _expenseBox.put(expense.id, expense);
    loadExpenses();

    // Show notification
    await _notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Expense Added',
      body: '${expense.title}: \$${expense.amount.toStringAsFixed(2)}',
    );
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await expense.save();
    loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await _expenseBox.delete(id);
    loadExpenses();
  }

  void checkRecurringExpenses() {
    final now = DateTime.now();
    final recurringExpenses = expenses.where((e) => e.isRecurring).toList();

    for (final expense in recurringExpenses) {
      // Logic to create recurring expenses based on type
      if (expense.recurringType == 'daily') {
        // Create daily expense if not exists for today
      } else if (expense.recurringType == 'weekly') {
        // Create weekly expense if needed
      } else if (expense.recurringType == 'monthly') {
        // Create monthly expense if needed
      }
    }
  }

  List<ExpenseModel> getExpensesByCategory(String categoryId) {
    return expenses.where((e) => e.categoryId == categoryId).toList();
  }

  List<ExpenseModel> getExpensesByDateRange(DateTime start, DateTime end) {
    return expenses
        .where(
          (e) =>
              e.date.isAfter(start.subtract(const Duration(days: 1))) &&
              e.date.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }

  double getTotalExpensesByCategory(String categoryId) {
    return getExpensesByCategory(
      categoryId,
    ).fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> getCategoryWiseExpenses() {
    final Map<String, double> categoryExpenses = {};

    for (final expense in expenses) {
      categoryExpenses[expense.categoryId] =
          (categoryExpenses[expense.categoryId] ?? 0) + expense.amount;
    }

    return categoryExpenses;
  }
}
