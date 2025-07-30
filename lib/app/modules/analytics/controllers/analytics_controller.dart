import 'package:get/get.dart';

import '../../../data/models/expense_model.dart';
import '../../category/controllers/category_controller.dart';
import '../../expense/controllers/expense_controller.dart';

class AnalyticsController extends GetxController {
  final ExpenseController expenseController = Get.find();
  final CategoryController categoryController = Get.find();

  // Observable values
  final RxString selectedPeriod = 'This Month'.obs;
  final RxDouble totalSpent = 0.0.obs;
  final RxDouble avgDailySpent = 0.0.obs;
  final RxList<Map<String, dynamic>> categoryData =
      <Map<String, dynamic>>[].obs;
  final RxList<double> trendData = <double>[].obs;
  final RxList<String> trendLabels = <String>[].obs;
  final RxList<ExpenseModel> topExpenses = <ExpenseModel>[].obs;

  // Additional analytics
  final RxDouble highestExpense = 0.0.obs;
  final RxDouble lowestExpense = 0.0.obs;
  final RxString mostSpentCategory = ''.obs;
  final RxInt totalTransactions = 0.obs;
  final RxDouble monthlyAverage = 0.0.obs;
  final RxMap<String, double> monthlyTotals = <String, double>{}.obs;

  // Add custom date range properties
  final Rx<DateTime?> customStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> customEndDate = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    // Update analytics whenever period changes
    ever(selectedPeriod, (_) => updateAnalytics());
    // Update analytics whenever expenses change
    ever(expenseController.expenses, (_) => updateAnalytics());
    // Initial analytics calculation
    updateAnalytics();
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;

    // Reset custom dates when selecting other periods
    if (period != 'Custom') {
      customStartDate.value = null;
      customEndDate.value = null;
    }

    updateAnalytics();
  }

  // Add method to handle custom date range
  void setCustomDateRange(DateTime start, DateTime end) {
    customStartDate.value = start;
    customEndDate.value = end;
    selectedPeriod.value = 'Custom';
    updateAnalytics();
  }

  void updateAnalytics() {
    final dateRange = _getDateRange();
    final filteredExpenses = expenseController.getExpensesByDateRange(
      dateRange['start']!,
      dateRange['end']!,
    );

    if (filteredExpenses.isEmpty) {
      _resetAnalytics();
      return;
    }

    // Calculate total spent
    totalSpent.value = filteredExpenses.fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    // Calculate average daily spent
    final days = dateRange['end']!.difference(dateRange['start']!).inDays + 1;
    avgDailySpent.value = days > 0 ? totalSpent.value / days : 0;

    // Calculate total transactions
    totalTransactions.value = filteredExpenses.length;

    // Calculate highest and lowest expense
    filteredExpenses.sort((a, b) => b.amount.compareTo(a.amount));
    highestExpense.value = filteredExpenses.first.amount;
    lowestExpense.value = filteredExpenses.last.amount;

    // Calculate category breakdown
    _updateCategoryData(filteredExpenses);

    // Update spending trend
    _updateTrendData(dateRange['start']!, dateRange['end']!);

    // Get top expenses
    topExpenses.value =
        List.from(filteredExpenses)
          ..sort((a, b) => b.amount.compareTo(a.amount))
          ..take(5).toList();

    // Calculate monthly average
    _calculateMonthlyAverage();
  }

  void _resetAnalytics() {
    totalSpent.value = 0.0;
    avgDailySpent.value = 0.0;
    totalTransactions.value = 0;
    highestExpense.value = 0.0;
    lowestExpense.value = 0.0;
    mostSpentCategory.value = '';
    categoryData.clear();
    trendData.clear();
    trendLabels.clear();
    topExpenses.clear();
    monthlyTotals.clear();
    monthlyAverage.value = 0.0;
  }

  Map<String, DateTime> _getDateRange() {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (selectedPeriod.value) {
      case 'This Week':
        start = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'This Month':
        start = DateTime(now.year, now.month, 1);
        break;
      case '3 Months':
        start = DateTime(now.year, now.month - 2, 1);
        break;
      case '6 Months':
        start = DateTime(now.year, now.month - 5, 1);
        break;
      case 'This Year':
        start = DateTime(now.year, 1, 1);
        break;
      case 'Custom':
        // Use custom dates if available
        if (customStartDate.value != null && customEndDate.value != null) {
          start = customStartDate.value!;
          end = customEndDate.value!;
        } else {
          // Fallback to this month if custom dates not set
          start = DateTime(now.year, now.month, 1);
        }
        break;
      default:
        start = DateTime(now.year, now.month, 1);
    }

    return {'start': start, 'end': end};
  }

  void _updateCategoryData(List<ExpenseModel> expenses) {
    final Map<String, double> categoryTotals = {};

    // Calculate totals per category
    for (final expense in expenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
    }

    // Find most spent category
    if (categoryTotals.isNotEmpty) {
      final mostSpentEntry = categoryTotals.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      final category = categoryController.categories.firstWhere(
        (c) => c.id == mostSpentEntry.key,
        orElse: () => categoryController.categories.first,
      );
      mostSpentCategory.value = category.name;
    }

    // Create category data for pie chart
    categoryData.value =
        categoryTotals.entries.map((entry) {
            final category = categoryController.categories.firstWhere(
              (c) => c.id == entry.key,
              orElse: () => categoryController.categories.first,
            );
            final percentage =
                totalSpent.value > 0
                    ? (entry.value / totalSpent.value * 100).round()
                    : 0;

            return {
              'name': category.name,
              'amount': entry.value.toDouble(), // Ensure it's a double
              'percentage': percentage,
              'color': category.colorValue,
              'icon': category.icon,
              'categoryId': category.id,
            };
          }).toList()
          ..sort((a, b) {
            // Safe comparison with null check
            final aAmount = a['amount'] as double?;
            final bAmount = b['amount'] as double?;
            if (aAmount == null || bAmount == null) return 0;
            return bAmount.compareTo(aAmount);
          });
  }

  void _updateTrendData(DateTime start, DateTime end) {
    trendData.clear();
    trendLabels.clear();

    final days = end.difference(start).inDays + 1;
    final isMonthly = days > 31;

    if (isMonthly) {
      // Group by month for longer periods
      Map<String, double> monthlyData = {};

      // Initialize months
      DateTime current = DateTime(start.year, start.month, 1);
      while (current.isBefore(end) ||
          (current.year == end.year && current.month == end.month)) {
        final monthKey = '${current.month}/${current.year}';
        monthlyData[monthKey] = 0;
        current = DateTime(current.year, current.month + 1, 1);
      }

      // Fill in expense data
      final expenses = expenseController.getExpensesByDateRange(start, end);
      for (final expense in expenses) {
        final monthKey = '${expense.date.month}/${expense.date.year}';
        monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + expense.amount;
      }

      // Convert to lists for chart
      monthlyData.forEach((key, value) {
        final parts = key.split('/');
        trendLabels.add(_getMonthAbbreviation(int.parse(parts[0])));
        trendData.add(value);
      });

      // Store monthly totals for average calculation
      monthlyTotals.value = monthlyData;
    } else if (days > 7) {
      // Group by week for medium periods
      DateTime current = start;
      while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
        final weekEnd = current.add(const Duration(days: 6));
        final weekExpenses = expenseController.expenses
            .where(
              (e) =>
                  e.date.isAfter(current.subtract(const Duration(days: 1))) &&
                  e.date.isBefore(weekEnd.add(const Duration(days: 1))),
            )
            .fold(0.0, (sum, e) => sum + e.amount);

        trendLabels.add('W${_getWeekNumber(current)}');
        trendData.add(weekExpenses);

        current = current.add(const Duration(days: 7));
        if (current.isAfter(end)) break;
      }
    } else {
      // Group by day for short periods
      for (int i = 0; i < days; i++) {
        final date = start.add(Duration(days: i));
        final dayExpenses = expenseController.expenses
            .where(
              (e) =>
                  e.date.year == date.year &&
                  e.date.month == date.month &&
                  e.date.day == date.day,
            )
            .fold(0.0, (sum, e) => sum + e.amount);

        trendLabels.add('${date.day}');
        trendData.add(dayExpenses);
      }
    }
  }

  void _calculateMonthlyAverage() {
    if (monthlyTotals.isNotEmpty) {
      final total = monthlyTotals.values.fold(0.0, (sum, value) => sum + value);
      monthlyAverage.value = total / monthlyTotals.length;
    } else {
      // Calculate based on current data
      final dateRange = _getDateRange();
      final months =
          (dateRange['end']!.month - dateRange['start']!.month + 1) +
          (dateRange['end']!.year - dateRange['start']!.year) * 12;
      monthlyAverage.value =
          months > 0 ? totalSpent.value / months : totalSpent.value;
    }
  }

  String _getMonthAbbreviation(int month) {
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

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday - 1) / 7).ceil();
  }

  // Getters for additional analytics
  double get savingsRate {
    // This would need budget data to calculate properly
    return 0.0;
  }

  Map<String, double> getCategoryBudgetComparison() {
    final Map<String, double> comparison = {};

    for (final categoryDataItem in categoryData) {
      final categoryId = categoryDataItem['categoryId'] as String;
      final spent = categoryDataItem['amount'] as double;
      final category = categoryController.categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => categoryController.categories.first,
      );

      if (category.budget != null && category.budget! > 0) {
        comparison[category.name] = (spent / category.budget! * 100);
      }
    }

    return comparison;
  }

  List<ExpenseModel> getExpensesByCategory(String categoryId) {
    final dateRange = _getDateRange();
    return expenseController
        .getExpensesByDateRange(dateRange['start']!, dateRange['end']!)
        .where((e) => e.categoryId == categoryId)
        .toList();
  }

  // Method to get formatted date range string for display
  String getDateRangeString() {
    if (selectedPeriod.value == 'Custom' &&
        customStartDate.value != null &&
        customEndDate.value != null) {
      return '${customStartDate.value!.day}/${customStartDate.value!.month}/${customStartDate.value!.year} - ${customEndDate.value!.day}/${customEndDate.value!.month}/${customEndDate.value!.year}';
    }
    return selectedPeriod.value;
  }
}
