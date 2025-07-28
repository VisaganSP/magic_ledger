import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../data/models/expense_model.dart';
import '../../../data/services/notification_service.dart';

class ExpenseController extends GetxController {
  final Box<ExpenseModel> _expenseBox = Hive.box('expenses');
  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  final NotificationService _notificationService = NotificationService();

  // Loading state
  final RxBool isLoading = false.obs;

  // Error handling
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadExpenses();
    checkRecurringExpenses();
  }

  void loadExpenses() {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      expenses.value =
          _expenseBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      print('Error loading expenses: $e');
      errorMessage.value = 'Failed to load expenses';
      expenses.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await _expenseBox.put(expense.id, expense);
      loadExpenses();

      // Show notification
      await _notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Expense Added',
        body: '${expense.title}: ₹${expense.amount.toStringAsFixed(2)}',
      );
    } catch (e) {
      print('Error adding expense: $e');
      Get.snackbar(
        'Error',
        'Failed to add expense. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await _expenseBox.put(expense.id, expense);
      loadExpenses();

      // Show notification
      await _notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Expense Updated',
        body: '${expense.title} has been updated',
      );
    } catch (e) {
      print('Error updating expense: $e');
      Get.snackbar(
        'Error',
        'Failed to update expense. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _expenseBox.delete(id);
      loadExpenses();
    } catch (e) {
      print('Error deleting expense: $e');
      Get.snackbar(
        'Error',
        'Failed to delete expense. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Recurring expense handling
  void checkRecurringExpenses() {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final recurringExpenses = expenses.where((e) => e.isRecurring).toList();

      for (final expense in recurringExpenses) {
        if (expense.recurringType == null) continue;

        switch (expense.recurringType!.toLowerCase()) {
          case 'daily':
            _handleDailyRecurring(expense, today);
            break;
          case 'weekly':
            _handleWeeklyRecurring(expense, today);
            break;
          case 'monthly':
            _handleMonthlyRecurring(expense, today);
            break;
          case 'yearly':
            _handleYearlyRecurring(expense, today);
            break;
        }
      }
    } catch (e) {
      print('Error checking recurring expenses: $e');
    }
  }

  void _handleDailyRecurring(ExpenseModel expense, DateTime today) {
    final lastExpenseDate = DateTime(
      expense.date.year,
      expense.date.month,
      expense.date.day,
    );

    if (lastExpenseDate.isBefore(today)) {
      final daysDifference = today.difference(lastExpenseDate).inDays;

      // Create missing daily expenses
      for (int i = 1; i <= daysDifference; i++) {
        final newDate = lastExpenseDate.add(Duration(days: i));
        _createRecurringExpense(expense, newDate);
      }
    }
  }

  void _handleWeeklyRecurring(ExpenseModel expense, DateTime today) {
    final lastExpenseDate = DateTime(
      expense.date.year,
      expense.date.month,
      expense.date.day,
    );

    if (lastExpenseDate.isBefore(today)) {
      final weeksDifference = today.difference(lastExpenseDate).inDays ~/ 7;

      // Create missing weekly expenses
      for (int i = 1; i <= weeksDifference; i++) {
        final newDate = lastExpenseDate.add(Duration(days: i * 7));
        if (newDate.isBefore(today) || newDate.isAtSameMomentAs(today)) {
          _createRecurringExpense(expense, newDate);
        }
      }
    }
  }

  void _handleMonthlyRecurring(ExpenseModel expense, DateTime today) {
    final lastExpenseDate = DateTime(
      expense.date.year,
      expense.date.month,
      expense.date.day,
    );

    // Calculate months difference
    int monthsDiff =
        (today.year - lastExpenseDate.year) * 12 +
        (today.month - lastExpenseDate.month);

    if (monthsDiff > 0) {
      for (int i = 1; i <= monthsDiff; i++) {
        var newDate = DateTime(
          lastExpenseDate.year,
          lastExpenseDate.month + i,
          lastExpenseDate.day,
        );

        // Handle month overflow
        while (newDate.month > 12) {
          newDate = DateTime(newDate.year + 1, newDate.month - 12, newDate.day);
        }

        if (newDate.isBefore(today) || newDate.isAtSameMomentAs(today)) {
          _createRecurringExpense(expense, newDate);
        }
      }
    }
  }

  void _handleYearlyRecurring(ExpenseModel expense, DateTime today) {
    final lastExpenseDate = DateTime(
      expense.date.year,
      expense.date.month,
      expense.date.day,
    );

    final yearsDiff = today.year - lastExpenseDate.year;

    if (yearsDiff > 0) {
      for (int i = 1; i <= yearsDiff; i++) {
        final newDate = DateTime(
          lastExpenseDate.year + i,
          lastExpenseDate.month,
          lastExpenseDate.day,
        );

        if (newDate.isBefore(today) || newDate.isAtSameMomentAs(today)) {
          _createRecurringExpense(expense, newDate);
        }
      }
    }
  }

  void _createRecurringExpense(ExpenseModel baseExpense, DateTime date) {
    // Check if expense already exists for this date
    final existingExpense = expenses.any(
      (e) =>
          e.title == baseExpense.title &&
          e.amount == baseExpense.amount &&
          e.categoryId == baseExpense.categoryId &&
          _isSameDay(e.date, date),
    );

    if (!existingExpense) {
      final newExpense = ExpenseModel(
        id: '${baseExpense.id}_${date.millisecondsSinceEpoch}',
        title: baseExpense.title,
        amount: baseExpense.amount,
        categoryId: baseExpense.categoryId,
        date: date,
        description: baseExpense.description,
        location: baseExpense.location,
        tags: baseExpense.tags,
        isRecurring: true,
        recurringType: baseExpense.recurringType,
        // Don't copy receipt path for recurring expenses
        receiptPath: null,
      );

      // Add without notification to avoid spam
      _expenseBox.put(newExpense.id, newExpense);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Filter methods
  List<ExpenseModel> getTodayExpenses() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return expenses
        .where((expense) => _isSameDay(expense.date, today))
        .toList();
  }

  List<ExpenseModel> getThisWeekExpenses() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return expenses.where((expense) {
      final expenseDate = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      return expenseDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          expenseDate.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
  }

  List<ExpenseModel> getThisMonthExpenses() {
    final now = DateTime.now();
    return expenses
        .where(
          (expense) =>
              expense.date.year == now.year && expense.date.month == now.month,
        )
        .toList();
  }

  List<ExpenseModel> getExpensesByCategory(String categoryId) {
    try {
      return expenses.where((e) => e.categoryId == categoryId).toList();
    } catch (e) {
      print('Error getting expenses by category: $e');
      return [];
    }
  }

  List<ExpenseModel> getExpensesByDateRange(DateTime start, DateTime end) {
    try {
      return expenses
          .where(
            (e) =>
                e.date.isAfter(start.subtract(const Duration(days: 1))) &&
                e.date.isBefore(end.add(const Duration(days: 1))),
          )
          .toList();
    } catch (e) {
      print('Error getting expenses by date range: $e');
      return [];
    }
  }

  double getTotalExpensesByCategory(String categoryId) {
    try {
      return getExpensesByCategory(
        categoryId,
      ).fold(0.0, (sum, e) => sum + e.amount);
    } catch (e) {
      print('Error getting total expenses by category: $e');
      return 0.0;
    }
  }

  Map<String, double> getCategoryWiseExpenses() {
    try {
      final Map<String, double> categoryExpenses = {};

      for (final expense in expenses) {
        categoryExpenses[expense.categoryId] =
            (categoryExpenses[expense.categoryId] ?? 0) + expense.amount;
      }

      return categoryExpenses;
    } catch (e) {
      print('Error getting category wise expenses: $e');
      return {};
    }
  }

  // Statistics
  Map<String, dynamic> getExpenseStats() {
    try {
      final now = DateTime.now();
      final thisMonth = getThisMonthExpenses();
      final thisWeek = getThisWeekExpenses();
      final today = getTodayExpenses();
      final thisYear = expenses.where((e) => e.date.year == now.year).toList();

      // Calculate last month for comparison
      final lastMonth = DateTime(now.year, now.month - 1);
      final lastMonthExpenses =
          expenses
              .where(
                (e) =>
                    e.date.year == lastMonth.year &&
                    e.date.month == lastMonth.month,
              )
              .toList();

      final thisMonthTotal = thisMonth.fold(0.0, (sum, e) => sum + e.amount);
      final lastMonthTotal = lastMonthExpenses.fold(
        0.0,
        (sum, e) => sum + e.amount,
      );

      // Get top category
      final categoryExpenses = getCategoryWiseExpenses();
      String topCategory = 'N/A';
      if (categoryExpenses.isNotEmpty) {
        final topEntry = categoryExpenses.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
        );
        topCategory = topEntry.key;
      }

      return {
        'total': expenses.fold(0.0, (sum, e) => sum + e.amount),
        'thisMonth': thisMonthTotal,
        'thisWeek': thisWeek.fold(0.0, (sum, e) => sum + e.amount),
        'today': today.fold(0.0, (sum, e) => sum + e.amount),
        'thisYear': thisYear.fold(0.0, (sum, e) => sum + e.amount),
        'count': expenses.length,
        'thisMonthCount': thisMonth.length,
        'averageExpense':
            expenses.isNotEmpty
                ? expenses.fold(0.0, (sum, e) => sum + e.amount) /
                    expenses.length
                : 0.0,
        'recurringCount': expenses.where((e) => e.isRecurring).length,
        'oneTimeCount': expenses.where((e) => !e.isRecurring).length,
        'monthlyGrowth':
            lastMonthTotal > 0
                ? ((thisMonthTotal - lastMonthTotal) / lastMonthTotal * 100)
                : 0.0,
        'topCategory': topCategory,
        'categoriesCount': categoryExpenses.length,
        'highestExpense':
            expenses.isNotEmpty
                ? expenses.reduce((a, b) => a.amount > b.amount ? a : b).amount
                : 0.0,
      };
    } catch (e) {
      print('Error getting expense stats: $e');
      return {
        'total': 0.0,
        'thisMonth': 0.0,
        'thisWeek': 0.0,
        'today': 0.0,
        'thisYear': 0.0,
        'count': 0,
        'thisMonthCount': 0,
        'averageExpense': 0.0,
        'recurringCount': 0,
        'oneTimeCount': 0,
        'monthlyGrowth': 0.0,
        'topCategory': 'N/A',
        'categoriesCount': 0,
        'highestExpense': 0.0,
      };
    }
  }

  // Search functionality
  List<ExpenseModel> searchExpenses(String query) {
    if (query.isEmpty) return expenses;

    final lowerQuery = query.toLowerCase();
    return expenses
        .where(
          (expense) =>
              expense.title.toLowerCase().contains(lowerQuery) ||
              (expense.description?.toLowerCase().contains(lowerQuery) ??
                  false) ||
              (expense.location?.toLowerCase().contains(lowerQuery) ?? false) ||
              (expense.tags?.any(
                    (tag) => tag.toLowerCase().contains(lowerQuery),
                  ) ??
                  false),
        )
        .toList();
  }

  // Get expenses by tag
  List<ExpenseModel> getExpensesByTag(String tag) {
    return expenses
        .where((expense) => expense.tags?.contains(tag) ?? false)
        .toList();
  }

  // Get all unique tags
  List<String> getAllTags() {
    final Set<String> tags = {};
    for (final expense in expenses) {
      if (expense.tags != null) {
        tags.addAll(expense.tags!);
      }
    }
    return tags.toList()..sort();
  }

  // Budget tracking helpers
  double getTotalExpensesByDateRange(DateTime start, DateTime end) {
    try {
      return getExpensesByDateRange(
        start,
        end,
      ).fold(0.0, (sum, e) => sum + e.amount);
    } catch (e) {
      print('Error getting total expenses by date range: $e');
      return 0.0;
    }
  }

  // Get expense trends (for charts)
  Map<DateTime, double> getDailyExpenseTrends(int days) {
    final Map<DateTime, double> trends = {};
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day - i);

      final dayExpenses = expenses.where((e) => _isSameDay(e.date, date));
      trends[date] = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);
    }

    return trends;
  }

  // Get monthly expense trends
  Map<String, double> getMonthlyExpenseTrends(int months) {
    final Map<String, double> trends = {};
    final now = DateTime.now();

    for (int i = 0; i < months; i++) {
      final date = DateTime(now.year, now.month - i);
      final monthName = _getMonthName(date.month);

      final monthExpenses = expenses.where(
        (e) => e.date.year == date.year && e.date.month == date.month,
      );

      trends[monthName] = monthExpenses.fold(0.0, (sum, e) => sum + e.amount);
    }

    return trends;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  // Category breakdown for current month
  Map<String, double> getCurrentMonthCategoryBreakdown() {
    final now = DateTime.now();
    final currentMonthExpenses = expenses.where(
      (e) => e.date.year == now.year && e.date.month == now.month,
    );

    final Map<String, double> breakdown = {};
    for (final expense in currentMonthExpenses) {
      breakdown[expense.categoryId] =
          (breakdown[expense.categoryId] ?? 0) + expense.amount;
    }

    return breakdown;
  }

  // Get recurring expenses summary
  Map<String, dynamic> getRecurringExpensesSummary() {
    final recurringExpenses = expenses.where((e) => e.isRecurring).toList();

    double dailyTotal = 0;
    double weeklyTotal = 0;
    double monthlyTotal = 0;
    double yearlyTotal = 0;

    for (final expense in recurringExpenses) {
      switch (expense.recurringType?.toLowerCase()) {
        case 'daily':
          dailyTotal += expense.amount;
          break;
        case 'weekly':
          weeklyTotal += expense.amount;
          break;
        case 'monthly':
          monthlyTotal += expense.amount;
          break;
        case 'yearly':
          yearlyTotal += expense.amount;
          break;
      }
    }

    // Calculate monthly equivalent
    final monthlyEquivalent =
        dailyTotal * 30 + weeklyTotal * 4.33 + monthlyTotal + yearlyTotal / 12;

    return {
      'daily': dailyTotal,
      'weekly': weeklyTotal,
      'monthly': monthlyTotal,
      'yearly': yearlyTotal,
      'monthlyEquivalent': monthlyEquivalent,
      'count': recurringExpenses.length,
    };
  }
}
