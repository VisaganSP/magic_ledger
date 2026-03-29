import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../data/models/budget_model.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/period_service.dart';
import '../../category/controllers/category_controller.dart';
import '../../expense/controllers/expense_controller.dart';

class BudgetController extends GetxController {
  final Box<BudgetModel> _budgetBox = Hive.box('budgets');
  final RxList<BudgetModel> budgets = <BudgetModel>[].obs;
  final RxBool isLoading = false.obs;

  late final ExpenseController expenseController;
  late final CategoryController categoryController;
  late final PeriodService periodService;
  final NotificationService _notif = NotificationService();
  final Map<String, int> _lastAlertLevel = {};

  @override
  void onInit() {
    super.onInit();
    expenseController = Get.find<ExpenseController>();
    categoryController = Get.find<CategoryController>();
    periodService = Get.find<PeriodService>();
    loadBudgets();
    ever(expenseController.expenses, (_) => _checkAllAlerts());
  }

  // ═══════════════════════════════════════════════════════════
  // CRUD
  // ═══════════════════════════════════════════════════════════

  void loadBudgets() {
    try {
      isLoading.value = true;
      budgets.value = _budgetBox.values.toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
    } catch (e) {
      debugPrint('Error loading budgets: $e');
      budgets.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addBudget(BudgetModel b) async {
    await _budgetBox.put(b.id, b);
    loadBudgets();
  }

  Future<void> updateBudget(BudgetModel b) async {
    await _budgetBox.put(b.id, b);
    loadBudgets();
  }

  Future<void> deleteBudget(String id) async {
    await _budgetBox.delete(id);
    _lastAlertLevel.remove(id);
    loadBudgets();
  }

  Future<void> toggleBudgetStatus(String id) async {
    final b = _budgetBox.get(id);
    if (b != null) {
      await updateBudget(BudgetModel(
        id: b.id, categoryId: b.categoryId, amount: b.amount,
        period: b.period, startDate: b.startDate, endDate: b.endDate,
        isActive: !b.isActive, notes: b.notes,
      ));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // GETTERS
  // ═══════════════════════════════════════════════════════════

  BudgetModel? getOverallBudget() {
    try { return budgets.firstWhere((b) => b.categoryId == null && b.isActive); }
    catch (_) { return null; }
  }

  BudgetModel? getBudgetForCategory(String catId) {
    try { return budgets.firstWhere((b) => b.categoryId == catId && b.isActive); }
    catch (_) { return null; }
  }

  List<BudgetModel> getCategoryBudgets() =>
      budgets.where((b) => b.categoryId != null && b.isActive).toList();

  List<BudgetModel> get activeBudgets => budgets.where((b) => b.isActive).toList();

  // ═══════════════════════════════════════════════════════════
  // PERIOD HELPERS
  // ═══════════════════════════════════════════════════════════

  Map<String, DateTime> _range(BudgetModel b) {
    final now = DateTime.now();
    DateTime s, e;
    switch (b.period.toLowerCase()) {
      case 'weekly':
        s = DateTime(now.year, now.month, now.day - (now.weekday - 1));
        e = s.add(const Duration(days: 6));
        break;
      case 'yearly':
        s = DateTime(now.year, 1, 1);
        e = DateTime(now.year, 12, 31);
        break;
      default:
        s = DateTime(now.year, now.month, 1);
        e = DateTime(now.year, now.month + 1, 0);
    }
    return {'start': s, 'end': e};
  }

  int _totalDays(BudgetModel b) {
    final r = _range(b);
    return r['end']!.difference(r['start']!).inDays + 1;
  }

  int _elapsed(BudgetModel b) {
    final r = _range(b);
    return DateTime.now().difference(r['start']!).inDays + 1;
  }

  int daysRemaining(BudgetModel b) => _totalDays(b) - _elapsed(b);

  // ═══════════════════════════════════════════════════════════
  // SPENDING
  // ═══════════════════════════════════════════════════════════

  double getSpentAmount(BudgetModel b) {
    final r = _range(b);
    final start = r['start']!.subtract(const Duration(days: 1));
    final end = r['end']!.add(const Duration(days: 1));
    var exps = expenseController.expenses.where(
            (e) => e.date.isAfter(start) && e.date.isBefore(end));
    if (b.categoryId != null) {
      exps = exps.where((e) => e.categoryId == b.categoryId);
    }
    return exps.fold(0.0, (s, e) => s + e.amount);
  }

  double getRemainingAmount(BudgetModel b) => b.amount - getSpentAmount(b);

  double getPercentageUsed(BudgetModel b) {
    if (b.amount <= 0) return 0;
    return getSpentAmount(b) / b.amount * 100;
  }

  bool isBudgetExceeded(BudgetModel b) => getSpentAmount(b) > b.amount;

  // ═══════════════════════════════════════════════════════════
  // SMART INSIGHTS
  // ═══════════════════════════════════════════════════════════

  /// How much you can spend per remaining day
  double getDailyAllowance(BudgetModel b) {
    final rem = getRemainingAmount(b);
    final days = daysRemaining(b);
    if (days <= 0 || rem <= 0) return 0;
    return rem / days;
  }

  /// Projected total spend at current velocity
  double getProjectedSpend(BudgetModel b) {
    final e = _elapsed(b);
    final t = _totalDays(b);
    if (e <= 0) return 0;
    return (getSpentAmount(b) / e) * t;
  }

  bool isOnTrackToExceed(BudgetModel b) => getProjectedSpend(b) > b.amount;

  /// Avg spending per day so far
  double getVelocity(BudgetModel b) {
    final e = _elapsed(b);
    return e > 0 ? getSpentAmount(b) / e : 0;
  }

  /// Budget health grade A+ to F
  String getGrade(BudgetModel b) {
    final pct = getPercentageUsed(b);
    final e = _elapsed(b);
    final t = _totalDays(b);
    final timePct = t > 0 ? (e / t * 100) : 0;

    if (pct > 100) return 'F';
    if (pct > 90) return 'D';
    if (timePct > 0 && pct / timePct > 1.3) return 'C';
    if (timePct > 0 && pct / timePct > 1.1) return 'B';
    if (timePct > 0 && pct / timePct > 0.9) return 'B+';
    if (timePct > 0 && pct / timePct <= 0.9) return 'A';
    return 'A+';
  }

  Color getGradeColor(String grade) {
    switch (grade) {
      case 'A+': case 'A': return const Color(0xFF00CC66);
      case 'B+': case 'B': return const Color(0xFF4D94FF);
      case 'C': return const Color(0xFFFF8533);
      case 'D': return const Color(0xFFE667A0);
      case 'F': return Colors.red;
      default: return Colors.grey;
    }
  }

  /// Budget streak — days on pace
  int getStreak(BudgetModel b) {
    final r = _range(b);
    final elapsed = _elapsed(b);
    int streak = 0;
    double running = 0;

    for (int d = elapsed - 1; d >= 0; d--) {
      final day = r['start']!.add(Duration(days: d));
      final dayEnd = day.add(const Duration(days: 1));
      final daySpend = expenseController.expenses
          .where((e) => e.date.isAfter(day.subtract(const Duration(hours: 1))) &&
          e.date.isBefore(dayEnd))
          .where((e) => b.categoryId == null || e.categoryId == b.categoryId)
          .fold(0.0, (s, e) => s + e.amount);
      running += daySpend;
      final expected = b.amount * ((d + 1) / _totalDays(b));
      if (running <= expected * 1.05) { streak++; } else { break; }
    }
    return streak;
  }

  // ═══════════════════════════════════════════════════════════
  // SUMMARY
  // ═══════════════════════════════════════════════════════════

  Map<String, dynamic> getBudgetSummary() {
    final active = activeBudgets;
    double totalB = 0, totalS = 0;
    int exceeded = 0, onTrack = 0;

    for (final b in active) {
      totalB += b.amount;
      final s = getSpentAmount(b);
      totalS += s;
      if (s > b.amount) exceeded++;
      if (!isOnTrackToExceed(b)) onTrack++;
    }

    return {
      'totalBudgets': active.length,
      'totalBudget': totalB,
      'totalSpent': totalS,
      'totalRemaining': totalB - totalS,
      'exceededCount': exceeded,
      'onTrackCount': onTrack,
      'percentageUsed': totalB > 0 ? (totalS / totalB * 100) : 0.0,
    };
  }

  // ═══════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════

  void _checkAllAlerts() {
    for (final b in activeBudgets) { _checkAlert(b); }
  }

  void _checkAlert(BudgetModel b) {
    final pct = getPercentageUsed(b);
    int level = 0;
    if (pct >= 100) level = 4;
    else if (pct >= 90) level = 3;
    else if (pct >= 75) level = 2;

    final last = _lastAlertLevel[b.id] ?? 0;
    if (level > last && level >= 2) {
      _lastAlertLevel[b.id] = level;
      _fireNotification(b, level, pct);
    }
  }

  Future<void> _fireNotification(BudgetModel b, int level, double pct) async {
    final name = b.categoryId != null
        ? (categoryController.getCategoryById(b.categoryId!)?.name ?? 'Category')
        : 'Overall';
    String title, body;

    switch (level) {
      case 4:
        title = '\u{1F6A8} Budget EXCEEDED: $name';
        body = 'Spent \u{20B9}${getSpentAmount(b).toStringAsFixed(0)} '
            'of \u{20B9}${b.amount.toStringAsFixed(0)} (${pct.toStringAsFixed(0)}%)';
        break;
      case 3:
        title = '\u{26A0}\u{FE0F} Budget danger: $name ${pct.toStringAsFixed(0)}%';
        body = 'Only \u{20B9}${getRemainingAmount(b).toStringAsFixed(0)} remaining. '
            'Limit: \u{20B9}${getDailyAllowance(b).toStringAsFixed(0)}/day';
        break;
      default:
        title = '\u{1F4A1} Budget alert: $name ${pct.toStringAsFixed(0)}%';
        body = '\u{20B9}${getRemainingAmount(b).toStringAsFixed(0)} left for '
            '${daysRemaining(b)} days';
    }

    await _notif.showNotification(id: b.id.hashCode, title: title, body: body);
  }

  void recheckAlerts() { _lastAlertLevel.clear(); _checkAllAlerts(); }

  // ═══════════════════════════════════════════════════════════
  // REPORT DATA
  // ═══════════════════════════════════════════════════════════

  List<Map<String, dynamic>> getReportData() {
    return activeBudgets.map((b) {
      final name = b.categoryId != null
          ? (categoryController.getCategoryById(b.categoryId!)?.name ?? 'Unknown')
          : 'Overall';
      return {
        'name': name,
        'budgetAmount': b.amount,
        'spent': getSpentAmount(b),
        'remaining': getRemainingAmount(b),
        'percentage': getPercentageUsed(b),
        'exceeded': isBudgetExceeded(b),
        'grade': getGrade(b),
        'dailyAllowance': getDailyAllowance(b),
        'projected': getProjectedSpend(b),
        'velocity': getVelocity(b),
        'daysRemaining': daysRemaining(b),
        'streak': getStreak(b),
        'period': b.period,
      };
    }).toList();
  }
}