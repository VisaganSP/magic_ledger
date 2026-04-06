import 'package:get/get.dart';

import '../../../data/models/expense_model.dart';
import '../../../data/models/income_model.dart';
import '../../../data/services/period_service.dart';
import '../../account/controllers/account_controller.dart';
import '../../category/controllers/category_controller.dart';
import '../../expense/controllers/expense_controller.dart';
import '../../income/controllers/income_controller.dart';

class AnalyticsController extends GetxController {
  final ExpenseController expenseController = Get.find();
  final CategoryController categoryController = Get.find();
  final IncomeController incomeController = Get.find();
  final AccountController accountController = Get.find<AccountController>();
  late final PeriodService periodService;

  // Period selection for analytics (separate from home period)
  final RxString selectedPeriod = 'This Month'.obs;
  final Rx<DateTime?> customStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> customEndDate = Rx<DateTime?>(null);

  // ─── CORE STATS ──────────────────────────────────────────
  final RxDouble totalSpent = 0.0.obs;
  final RxDouble totalEarned = 0.0.obs;
  final RxDouble netFlow = 0.0.obs;
  final RxDouble avgDailySpent = 0.0.obs;
  final RxDouble avgDailyEarned = 0.0.obs;
  final RxInt expenseCount = 0.obs;
  final RxInt incomeCount = 0.obs;

  // ─── INSIGHTS ────────────────────────────────────────────
  final RxDouble highestExpense = 0.0.obs;
  final RxString highestExpenseTitle = ''.obs;
  final RxDouble lowestExpense = 0.0.obs;
  final RxDouble avgTransaction = 0.0.obs;
  final RxString mostSpentCategory = ''.obs;
  final RxString mostSpentCategoryIcon = ''.obs;
  final RxDouble mostSpentCategoryAmount = 0.0.obs;
  final RxDouble savingsRate = 0.0.obs;

  // ─── COMPARISON (vs previous period) ─────────────────────
  final RxDouble prevPeriodSpent = 0.0.obs;
  final RxDouble prevPeriodEarned = 0.0.obs;
  final RxDouble spendingChange = 0.0.obs;
  final RxDouble incomeChange = 0.0.obs;

  // ─── CHART DATA ──────────────────────────────────────────
  final RxList<Map<String, dynamic>> categoryData = <Map<String, dynamic>>[].obs;
  final RxList<double> expenseTrendData = <double>[].obs;
  final RxList<double> incomeTrendData = <double>[].obs;
  final RxList<String> trendLabels = <String>[].obs;
  final RxList<ExpenseModel> topExpenses = <ExpenseModel>[].obs;

  // ─── SPENDING VELOCITY ───────────────────────────────────
  final RxDouble spendingVelocity = 0.0.obs; // per day change rate
  final RxDouble projectedMonthEnd = 0.0.obs;
  final RxInt daysRemaining = 0.obs;

  @override
  void onInit() {
    super.onInit();
    periodService = Get.find<PeriodService>();

    ever(selectedPeriod, (_) => updateAnalytics());
    ever(expenseController.expenses, (_) => updateAnalytics());
    ever(incomeController.incomes, (_) => updateAnalytics());
    ever(accountController.selectedAccountId, (_) => updateAnalytics());

    updateAnalytics();
  }

  void changePeriod(String period) {
    if (period != 'Custom') {
      customStartDate.value = null;
      customEndDate.value = null;
    }
    selectedPeriod.value = period;
  }

  void setCustomDateRange(DateTime start, DateTime end) {
    customStartDate.value = start;
    customEndDate.value = end;
    selectedPeriod.value = 'Custom';
    updateAnalytics();
  }

  void updateAnalytics() {
    final range = _getDateRange();
    final start = range['start']!;
    final end = range['end']!;
    final accountId = accountController.selectedAccountId.value;

    // Get filtered data
    var expenses = expenseController.getExpensesByDateRange(start, end);
    var incomes = incomeController.getIncomesByDateRange(start, end);

    if (accountId != null) {
      expenses = expenses.where((e) => e.accountId == accountId).toList();
      incomes = incomes.where((i) => i.accountId == accountId).toList();
    }

    if (expenses.isEmpty && incomes.isEmpty) {
      _resetAnalytics();
      return;
    }

    // Core stats
    totalSpent.value = expenses.fold(0.0, (sum, e) => sum + e.amount);
    totalEarned.value = incomes.fold(0.0, (sum, i) => sum + i.amount);
    netFlow.value = totalEarned.value - totalSpent.value;
    expenseCount.value = expenses.length;
    incomeCount.value = incomes.length;

    final days = end.difference(start).inDays + 1;
    avgDailySpent.value = days > 0 ? totalSpent.value / days : 0;
    avgDailyEarned.value = days > 0 ? totalEarned.value / days : 0;

    // Savings rate
    savingsRate.value = totalEarned.value > 0
        ? ((totalEarned.value - totalSpent.value) / totalEarned.value * 100)
        .clamp(-999, 100)
        : 0.0;

    // Insights
    if (expenses.isNotEmpty) {
      final sorted = List<ExpenseModel>.from(expenses)
        ..sort((a, b) => b.amount.compareTo(a.amount));
      highestExpense.value = sorted.first.amount;
      highestExpenseTitle.value = sorted.first.title;
      lowestExpense.value = sorted.last.amount;
      avgTransaction.value = totalSpent.value / expenses.length;
    } else {
      highestExpense.value = 0;
      highestExpenseTitle.value = '';
      lowestExpense.value = 0;
      avgTransaction.value = 0;
    }

    // Category breakdown
    _updateCategoryData(expenses);

    // Trend data (expense + income lines)
    _updateTrendData(start, end, accountId);

    // Top expenses
    topExpenses.value = (List<ExpenseModel>.from(expenses)
      ..sort((a, b) => b.amount.compareTo(a.amount)))
        .take(5)
        .toList();

    // Previous period comparison
    _calculateComparison(start, end, accountId);

    // Spending velocity
    _calculateVelocity(expenses, start, end);
  }

  void _resetAnalytics() {
    totalSpent.value = 0;
    totalEarned.value = 0;
    netFlow.value = 0;
    avgDailySpent.value = 0;
    avgDailyEarned.value = 0;
    expenseCount.value = 0;
    incomeCount.value = 0;
    highestExpense.value = 0;
    highestExpenseTitle.value = '';
    lowestExpense.value = 0;
    avgTransaction.value = 0;
    mostSpentCategory.value = '';
    mostSpentCategoryIcon.value = '';
    mostSpentCategoryAmount.value = 0;
    savingsRate.value = 0;
    prevPeriodSpent.value = 0;
    prevPeriodEarned.value = 0;
    spendingChange.value = 0;
    incomeChange.value = 0;
    categoryData.clear();
    expenseTrendData.clear();
    incomeTrendData.clear();
    trendLabels.clear();
    topExpenses.clear();
    spendingVelocity.value = 0;
    projectedMonthEnd.value = 0;
    daysRemaining.value = 0;
  }

  void _calculateComparison(DateTime start, DateTime end, String? accountId) {
    final duration = end.difference(start);
    final prevStart = start.subtract(duration);
    final prevEnd = start.subtract(const Duration(days: 1));

    var prevExpenses = expenseController.getExpensesByDateRange(prevStart, prevEnd);
    var prevIncomes = incomeController.getIncomesByDateRange(prevStart, prevEnd);

    if (accountId != null) {
      prevExpenses = prevExpenses.where((e) => e.accountId == accountId).toList();
      prevIncomes = prevIncomes.where((i) => i.accountId == accountId).toList();
    }

    prevPeriodSpent.value = prevExpenses.fold(0.0, (sum, e) => sum + e.amount);
    prevPeriodEarned.value = prevIncomes.fold(0.0, (sum, i) => sum + i.amount);

    spendingChange.value = prevPeriodSpent.value > 0
        ? ((totalSpent.value - prevPeriodSpent.value) / prevPeriodSpent.value * 100)
        : (totalSpent.value > 0 ? 100.0 : 0.0);

    incomeChange.value = prevPeriodEarned.value > 0
        ? ((totalEarned.value - prevPeriodEarned.value) / prevPeriodEarned.value * 100)
        : (totalEarned.value > 0 ? 100.0 : 0.0);
  }

  void _calculateVelocity(List<ExpenseModel> expenses, DateTime start, DateTime end) {
    final now = DateTime.now();
    final isCurrentMonth = start.year == now.year && start.month == now.month;

    if (isCurrentMonth && expenses.length >= 2) {
      final daysElapsed = now.day;
      spendingVelocity.value = daysElapsed > 0 ? totalSpent.value / daysElapsed : 0;

      final totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
      daysRemaining.value = totalDaysInMonth - now.day;
      projectedMonthEnd.value = spendingVelocity.value * totalDaysInMonth;
    } else {
      spendingVelocity.value = avgDailySpent.value;
      daysRemaining.value = 0;
      projectedMonthEnd.value = 0;
    }
  }

  void _updateCategoryData(List<ExpenseModel> expenses) {
    final Map<String, double> categoryTotals = {};

    for (final expense in expenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
    }

    if (categoryTotals.isNotEmpty) {
      final mostSpentEntry = categoryTotals.entries.reduce(
            (a, b) => a.value > b.value ? a : b,
      );
      final cat = categoryController.getCategoryForExpense(mostSpentEntry.key);
      mostSpentCategory.value = cat.name;
      mostSpentCategoryIcon.value = cat.icon;
      mostSpentCategoryAmount.value = mostSpentEntry.value;
    }

    categoryData.value = categoryTotals.entries.map((entry) {
      final cat = categoryController.getCategoryForExpense(entry.key);
      final pct = totalSpent.value > 0
          ? (entry.value / totalSpent.value * 100).round()
          : 0;

      return {
        'name': cat.name,
        'amount': entry.value,
        'percentage': pct,
        'color': cat.colorValue,
        'icon': cat.icon,
        'categoryId': cat.id,
      };
    }).toList()
      ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
  }

  void _updateTrendData(DateTime start, DateTime end, String? accountId) {
    expenseTrendData.clear();
    incomeTrendData.clear();
    trendLabels.clear();

    final days = end.difference(start).inDays + 1;

    if (days > 60) {
      // Monthly grouping
      DateTime current = DateTime(start.year, start.month, 1);
      while (current.isBefore(end) ||
          (current.year == end.year && current.month == end.month)) {
        final monthEnd = DateTime(current.year, current.month + 1, 0);

        var monthExp = expenseController.getExpensesByDateRange(current, monthEnd);
        var monthInc = incomeController.getIncomesByDateRange(current, monthEnd);

        if (accountId != null) {
          monthExp = monthExp.where((e) => e.accountId == accountId).toList();
          monthInc = monthInc.where((i) => i.accountId == accountId).toList();
        }

        trendLabels.add(_getMonthAbbr(current.month));
        expenseTrendData.add(monthExp.fold(0.0, (s, e) => s + e.amount));
        incomeTrendData.add(monthInc.fold(0.0, (s, i) => s + i.amount));

        current = DateTime(current.year, current.month + 1, 1);
      }
    } else if (days > 14) {
      // Weekly grouping
      DateTime current = start;
      int weekNum = 1;
      while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
        final weekEnd = current.add(const Duration(days: 6));
        final actualEnd = weekEnd.isAfter(end) ? end : weekEnd;

        var weekExp = expenseController.getExpensesByDateRange(current, actualEnd);
        var weekInc = incomeController.getIncomesByDateRange(current, actualEnd);

        if (accountId != null) {
          weekExp = weekExp.where((e) => e.accountId == accountId).toList();
          weekInc = weekInc.where((i) => i.accountId == accountId).toList();
        }

        trendLabels.add('W$weekNum');
        expenseTrendData.add(weekExp.fold(0.0, (s, e) => s + e.amount));
        incomeTrendData.add(weekInc.fold(0.0, (s, i) => s + i.amount));

        current = current.add(const Duration(days: 7));
        weekNum++;
      }
    } else {
      // Daily grouping
      for (int i = 0; i < days; i++) {
        final date = start.add(Duration(days: i));

        var dayExp = expenseController.expenses.where((e) =>
        e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day);
        var dayInc = incomeController.incomes.where((i) =>
        i.date.year == date.year &&
            i.date.month == date.month &&
            i.date.day == date.day);

        if (accountId != null) {
          dayExp = dayExp.where((e) => e.accountId == accountId);
          dayInc = dayInc.where((i) => i.accountId == accountId);
        }

        trendLabels.add('${date.day}');
        expenseTrendData.add(dayExp.fold(0.0, (s, e) => s + e.amount));
        incomeTrendData.add(dayInc.fold(0.0, (s, i) => s + i.amount));
      }
    }
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
        if (customStartDate.value != null && customEndDate.value != null) {
          return {'start': customStartDate.value!, 'end': customEndDate.value!};
        }
        start = DateTime(now.year, now.month, 1);
        break;
      default:
        start = DateTime(now.year, now.month, 1);
    }

    return {'start': start, 'end': end};
  }

  String _getMonthAbbr(int month) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return m[month - 1];
  }

  String getDateRangeString() {
    if (selectedPeriod.value == 'Custom' &&
        customStartDate.value != null &&
        customEndDate.value != null) {
      return '${customStartDate.value!.day}/${customStartDate.value!.month} — ${customEndDate.value!.day}/${customEndDate.value!.month}';
    }
    return selectedPeriod.value;
  }
}