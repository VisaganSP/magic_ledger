import 'package:get/get.dart';

import '../../../data/services/home_widget_service.dart';
import '../../../data/services/period_service.dart';
import '../../../data/services/recurring_service.dart';
import '../../../data/services/sms_transaction_service.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../account/controllers/account_controller.dart';
import '../../expense/controllers/expense_controller.dart';
import '../../income/controllers/income_controller.dart';
import '../../todo/controllers/todo_controller.dart';

class HomeController extends GetxController {
  late final ExpenseController expenseController;
  late final TodoController todoController;
  late final IncomeController incomeController;
  late final AccountController accountController;
  late final PeriodService periodService;

  final RxInt selectedIndex = 0.obs;

  // ─── PERIOD STATS ────────────────────────────────────────
  final RxDouble totalExpenses = 0.0.obs;
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble balance = 0.0.obs;
  final RxDouble savingsPercentage = 0.0.obs;
  final RxInt pendingTodos = 0.obs;
  final RxInt totalTransactions = 0.obs;

  // ─── COMPARISON DATA ─────────────────────────────────────
  final RxDouble prevMonthExpenses = 0.0.obs;
  final RxDouble prevMonthIncome = 0.0.obs;
  final RxDouble expenseChangePercent = 0.0.obs;
  final RxDouble incomeChangePercent = 0.0.obs;

  // ─── DAILY AVERAGE ───────────────────────────────────────
  final RxDouble dailyAvgExpense = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    expenseController = Get.find<ExpenseController>();
    todoController = Get.find<TodoController>();
    incomeController = Get.find<IncomeController>();
    accountController = Get.find<AccountController>();
    periodService = Get.find<PeriodService>();

    calculateStats();
    setupReactiveBindings();
  }

  void setupReactiveBindings() {
    // React to data changes
    ever(expenseController.expenses, (_) => calculateStats());
    ever(todoController.todos, (_) => calculateStats());
    ever(incomeController.incomes, (_) => calculateStats());

    // React to period changes
    ever(periodService.selectedMonth, (_) => calculateStats());
    ever(periodService.selectedYear, (_) => calculateStats());

    // React to account filter changes
    ever(accountController.selectedAccountId, (_) => calculateStats());

    // Also listen to todo counts
    ever(todoController.pendingCount, (_) => calculateStats());
    ever(todoController.completedCount, (_) => calculateStats());
  }

  @override
  void onReady() {
    super.onReady();
    refreshStats();
    HomeWidgetService.updateWidget();

    // Process recurring transactions
    try {
      final recurringService = Get.find<RecurringService>();
      recurringService.processAll().then((count) {
        if (count > 0) {
          refreshStats(); // Refresh after generating
          Get.snackbar(
            'Auto-generated',
            '$count recurring transaction${count == 1 ? '' : 's'} added',
            backgroundColor: NeoBrutalismTheme.accentSkyBlue,
            colorText: NeoBrutalismTheme.primaryBlack,
            duration: const Duration(seconds: 3),
          );
        }
      });
    } catch (_) {}

    // SMS scan (already added previously)
    try {
      final smsService = Get.find<SmsTransactionService>();
      smsService.scanRecentSms(hours: 24);
    } catch (_) {}
  }

  void calculateStats() {
    try {
      final start = periodService.periodStart;
      final end = periodService.periodEnd;
      final accountId = accountController.selectedAccountId.value;

      // ── Current period expenses ──
      var periodExpenses = expenseController.expenses.where((e) =>
      e.date.isAfter(start.subtract(const Duration(days: 1))) &&
          e.date.isBefore(end.add(const Duration(days: 1))));

      if (accountId != null) {
        periodExpenses = periodExpenses.where((e) => e.accountId == accountId);
      }

      totalExpenses.value =
          periodExpenses.fold(0.0, (sum, e) => sum + e.amount);

      // ── Current period income ──
      var periodIncomes = incomeController.incomes.where((i) =>
      i.date.isAfter(start.subtract(const Duration(days: 1))) &&
          i.date.isBefore(end.add(const Duration(days: 1))));

      if (accountId != null) {
        periodIncomes = periodIncomes.where((i) => i.accountId == accountId);
      }

      totalIncome.value =
          periodIncomes.fold(0.0, (sum, i) => sum + i.amount);

      // ── Balance ──
      balance.value = totalIncome.value - totalExpenses.value;

      // ── Savings % ──
      if (totalIncome.value > 0) {
        savingsPercentage.value =
            ((totalIncome.value - totalExpenses.value) / totalIncome.value * 100)
                .clamp(-999, 100);
      } else {
        savingsPercentage.value = 0.0;
      }

      // ── Transaction count ──
      totalTransactions.value =
          periodExpenses.length + periodIncomes.length;

      // ── Pending todos ──
      pendingTodos.value =
          todoController.todos.where((t) => !t.isCompleted).length;

      // ── Daily average ──
      final now = DateTime.now();
      int daysElapsed;
      if (periodService.isCurrentPeriod) {
        daysElapsed = now.day;
      } else {
        daysElapsed = end.day; // full month
      }
      dailyAvgExpense.value =
      daysElapsed > 0 ? totalExpenses.value / daysElapsed : 0.0;

      // ── Previous month comparison ──
      _calculateComparison(accountId);

      update();
    } catch (e) {
      print('Error calculating stats: $e');
      _resetStats();
    }
  }

  void _calculateComparison(String? accountId) {
    try {
      final prevStart = periodService.previousPeriodStart;
      final prevEnd = periodService.previousPeriodEnd;

      // Previous month expenses
      var prevExpenses = expenseController.expenses.where((e) =>
      e.date.isAfter(prevStart.subtract(const Duration(days: 1))) &&
          e.date.isBefore(prevEnd.add(const Duration(days: 1))));

      if (accountId != null) {
        prevExpenses = prevExpenses.where((e) => e.accountId == accountId);
      }

      prevMonthExpenses.value =
          prevExpenses.fold(0.0, (sum, e) => sum + e.amount);

      // Previous month income
      var prevIncomes = incomeController.incomes.where((i) =>
      i.date.isAfter(prevStart.subtract(const Duration(days: 1))) &&
          i.date.isBefore(prevEnd.add(const Duration(days: 1))));

      if (accountId != null) {
        prevIncomes = prevIncomes.where((i) => i.accountId == accountId);
      }

      prevMonthIncome.value =
          prevIncomes.fold(0.0, (sum, i) => sum + i.amount);

      // Change percentages
      if (prevMonthExpenses.value > 0) {
        expenseChangePercent.value =
        ((totalExpenses.value - prevMonthExpenses.value) /
            prevMonthExpenses.value *
            100);
      } else {
        expenseChangePercent.value = totalExpenses.value > 0 ? 100.0 : 0.0;
      }

      if (prevMonthIncome.value > 0) {
        incomeChangePercent.value =
        ((totalIncome.value - prevMonthIncome.value) /
            prevMonthIncome.value *
            100);
      } else {
        incomeChangePercent.value = totalIncome.value > 0 ? 100.0 : 0.0;
      }
    } catch (e) {
      print('Error calculating comparison: $e');
      prevMonthExpenses.value = 0.0;
      prevMonthIncome.value = 0.0;
      expenseChangePercent.value = 0.0;
      incomeChangePercent.value = 0.0;
    }
  }

  void _resetStats() {
    totalExpenses.value = 0.0;
    totalIncome.value = 0.0;
    balance.value = 0.0;
    savingsPercentage.value = 0.0;
    pendingTodos.value = 0;
    totalTransactions.value = 0;
    dailyAvgExpense.value = 0.0;
    prevMonthExpenses.value = 0.0;
    prevMonthIncome.value = 0.0;
    expenseChangePercent.value = 0.0;
    incomeChangePercent.value = 0.0;
    update();
  }

  void changeTab(int index) {
    selectedIndex.value = index;
    if (index == 0) {
      Future.delayed(const Duration(milliseconds: 100), () {
        refreshStats();
      });
    }
  }

  void refreshStats() {
    expenseController.loadExpenses();
    incomeController.loadIncomes();
    todoController.loadTodos();
    accountController.loadAccounts();
    accountController.loadTransfers();

    Future.delayed(const Duration(milliseconds: 100), () {
      calculateStats();
    });
  }

  void onReturnToHome() {
    refreshStats();
  }

  // ─── HELPERS FOR VIEW ────────────────────────────────────

  /// Get recent transactions for the selected period + account
  List<Map<String, dynamic>> getRecentTransactions({int limit = 6}) {
    final start = periodService.periodStart;
    final end = periodService.periodEnd;
    final accountId = accountController.selectedAccountId.value;

    final List<Map<String, dynamic>> transactions = [];

    for (var expense in expenseController.expenses) {
      if (expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(end.add(const Duration(days: 1)))) {
        if (accountId == null || expense.accountId == accountId) {
          transactions.add({
            'type': 'expense',
            'data': expense,
            'date': expense.date,
          });
        }
      }
    }

    for (var income in incomeController.incomes) {
      if (income.date.isAfter(start.subtract(const Duration(days: 1))) &&
          income.date.isBefore(end.add(const Duration(days: 1)))) {
        if (accountId == null || income.accountId == accountId) {
          transactions.add({
            'type': 'income',
            'data': income,
            'date': income.date,
          });
        }
      }
    }

    transactions.sort((a, b) => b['date'].compareTo(a['date']));
    return transactions.take(limit).toList();
  }

  /// Get all transactions for the "see all" dialog
  List<Map<String, dynamic>> getAllTransactions() {
    return getRecentTransactions(limit: 99999);
  }

  /// Get a spending "health" indicator
  String get spendingHealth {
    if (savingsPercentage.value >= 30) return 'EXCELLENT';
    if (savingsPercentage.value >= 15) return 'GOOD';
    if (savingsPercentage.value >= 0) return 'OK';
    return 'OVERSPENT';
  }

  /// Daily budget remaining (if user has income this month)
  double get dailyBudgetRemaining {
    if (totalIncome.value <= 0) return 0;
    final now = DateTime.now();
    final daysLeft = periodService.isCurrentPeriod
        ? periodService.periodEnd.day - now.day + 1
        : 0;
    if (daysLeft <= 0) return 0;
    return (totalIncome.value - totalExpenses.value) / daysLeft;
  }
}