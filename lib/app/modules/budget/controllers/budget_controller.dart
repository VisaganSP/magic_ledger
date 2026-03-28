import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../data/models/budget_model.dart';
import '../../category/controllers/category_controller.dart';
import '../../expense/controllers/expense_controller.dart';

class BudgetController extends GetxController {
  final Box<BudgetModel> _budgetBox = Hive.box('budgets');
  final RxList<BudgetModel> budgets = <BudgetModel>[].obs;

  final ExpenseController expenseController = Get.find();
  final CategoryController categoryController = Get.find();

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBudgets();
  }

  void loadBudgets() {
    try {
      isLoading.value = true;
      budgets.value = _budgetBox.values.toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
    } catch (e) {
      print('Error loading budgets: $e');
      budgets.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addBudget(BudgetModel budget) async {
    try {
      await _budgetBox.put(budget.id, budget);
      loadBudgets();
    } catch (e) {
      print('Error adding budget: $e');
      Get.snackbar('Error', 'Failed to add budget');
    }
  }

  Future<void> updateBudget(BudgetModel budget) async {
    try {
      await _budgetBox.put(budget.id, budget);
      loadBudgets();
    } catch (e) {
      print('Error updating budget: $e');
      Get.snackbar('Error', 'Failed to update budget');
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      await _budgetBox.delete(id);
      loadBudgets();
    } catch (e) {
      print('Error deleting budget: $e');
      Get.snackbar('Error', 'Failed to delete budget');
    }
  }

  Future<void> toggleBudgetStatus(String id) async {
    try {
      final budget = _budgetBox.get(id);
      if (budget != null) {
        final updatedBudget = BudgetModel(
          id: budget.id,
          categoryId: budget.categoryId,
          amount: budget.amount,
          period: budget.period,
          startDate: budget.startDate,
          endDate: budget.endDate,
          isActive: !budget.isActive,
          notes: budget.notes,
        );
        await updateBudget(updatedBudget);
      }
    } catch (e) {
      print('Error toggling budget status: $e');
    }
  }

  // Get budget for a specific category
  BudgetModel? getBudgetForCategory(String categoryId) {
    try {
      return budgets.firstWhere(
            (b) => b.categoryId == categoryId && b.isActive,
      );
    } catch (e) {
      return null;
    }
  }

  // Get overall budget (no category)
  BudgetModel? getOverallBudget() {
    try {
      return budgets.firstWhere(
            (b) => b.categoryId == null && b.isActive,
      );
    } catch (e) {
      return null;
    }
  }

  // Calculate spent amount for a budget
  double getSpentAmount(BudgetModel budget) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (budget.period.toLowerCase()) {
      case 'weekly':
        final weekDay = now.weekday;
        startDate = now.subtract(Duration(days: weekDay - 1));
        endDate = startDate.add(const Duration(days: 6));
        break;
      case 'yearly':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31);
        break;
      case 'monthly':
      default:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
        break;
    }

    if (budget.categoryId != null) {
      // Category-specific budget
      return expenseController.expenses
          .where((expense) =>
      expense.categoryId == budget.categoryId &&
          expense.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(endDate.add(const Duration(days: 1))))
          .fold(0.0, (sum, expense) => sum + expense.amount);
    } else {
      // Overall budget
      return expenseController.expenses
          .where((expense) =>
      expense.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(endDate.add(const Duration(days: 1))))
          .fold(0.0, (sum, expense) => sum + expense.amount);
    }
  }

  // Calculate remaining amount
  double getRemainingAmount(BudgetModel budget) {
    return budget.amount - getSpentAmount(budget);
  }

  // Calculate percentage used
  double getPercentageUsed(BudgetModel budget) {
    final spent = getSpentAmount(budget);
    return (spent / budget.amount * 100).clamp(0, 100);
  }

  // Check if budget is exceeded
  bool isBudgetExceeded(BudgetModel budget) {
    return getSpentAmount(budget) > budget.amount;
  }

  // Get all category budgets
  List<BudgetModel> getCategoryBudgets() {
    return budgets.where((b) => b.categoryId != null && b.isActive).toList();
  }

  // Get budget summary
  Map<String, dynamic> getBudgetSummary() {
    final activeBudgets = budgets.where((b) => b.isActive).toList();

    double totalBudget = 0;
    double totalSpent = 0;
    int exceededCount = 0;

    for (var budget in activeBudgets) {
      totalBudget += budget.amount;
      final spent = getSpentAmount(budget);
      totalSpent += spent;
      if (spent > budget.amount) {
        exceededCount++;
      }
    }

    return {
      'totalBudgets': activeBudgets.length,
      'totalBudget': totalBudget,
      'totalSpent': totalSpent,
      'totalRemaining': totalBudget - totalSpent,
      'exceededCount': exceededCount,
      'percentageUsed': totalBudget > 0 ? (totalSpent / totalBudget * 100) : 0.0,
    };
  }
}