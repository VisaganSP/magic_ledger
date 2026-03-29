import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/expense_model.dart';
import '../models/income_model.dart';

/// Automatically generates recurring expenses/incomes on app launch.
///
/// How it works:
/// 1. On each app launch, scans all recurring expenses and incomes
/// 2. For each recurring item, checks if entries exist for the current period
/// 3. If missing, generates them automatically (back-fills missed periods too)
/// 4. Tracks the last generation date per item to avoid duplicates
///
/// Call [processAll] from HomeController.onReady() once per app launch.
class RecurringService extends GetxService {
  late Box _trackingBox;

  final RxInt lastRunGenerated = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initBox();
  }

  Future<void> _initBox() async {
    _trackingBox = Hive.isBoxOpen('recurring_tracking')
        ? Hive.box('recurring_tracking')
        : await Hive.openBox('recurring_tracking');
  }

  /// Main entry point — call once on app launch.
  /// Returns the number of entries generated.
  Future<int> processAll() async {
    int count = 0;
    try {
      final expBox = Hive.box<ExpenseModel>('expenses');
      final incBox = Hive.box<IncomeModel>('incomes');

      // Process recurring expenses
      final recurringExps = expBox.values.where((e) => e.isRecurring && e.parentRecurringId == null).toList();
      for (final exp in recurringExps) {
        count += await _processRecurringExpense(exp, expBox);
      }

      // Process recurring incomes
      final recurringIncs = incBox.values.where((i) => i.isRecurring && i.parentRecurringId == null).toList();
      for (final inc in recurringIncs) {
        count += await _processRecurringIncome(inc, incBox);
      }

      lastRunGenerated.value = count;
      if (count > 0) {
        debugPrint('[Recurring] Generated $count entries');
      }
    } catch (e) {
      debugPrint('[Recurring] Error: $e');
    }
    return count;
  }

  Future<int> _processRecurringExpense(ExpenseModel template, Box<ExpenseModel> box) async {
    int count = 0;
    final periods = _getMissingPeriods(template.id, template.recurringType ?? 'monthly', template.date);

    for (final date in periods) {
      // Check no duplicate exists for this date
      final exists = box.values.any((e) =>
      e.parentRecurringId == template.id &&
          e.date.year == date.year && e.date.month == date.month && e.date.day == date.day);
      if (exists) continue;

      final newExp = ExpenseModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_r$count',
        title: template.title,
        amount: template.amount,
        categoryId: template.categoryId,
        date: date,
        description: '${template.description ?? ''} [Auto-recurring]'.trim(),
        location: template.location,
        tags: template.tags,
        isRecurring: false,
        accountId: template.accountId,
        parentRecurringId: template.id,
      );

      await box.put(newExp.id, newExp);
      count++;
    }

    // Update tracking
    if (count > 0) {
      await _trackingBox.put('exp_${template.id}', DateTime.now().millisecondsSinceEpoch);
    }
    return count;
  }

  Future<int> _processRecurringIncome(IncomeModel template, Box<IncomeModel> box) async {
    int count = 0;
    final periods = _getMissingPeriods(template.id, template.recurringType ?? 'monthly', template.date);

    for (final date in periods) {
      final exists = box.values.any((i) =>
      i.parentRecurringId == template.id &&
          i.date.year == date.year && i.date.month == date.month && i.date.day == date.day);
      if (exists) continue;

      final newInc = IncomeModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_r$count',
        title: template.title,
        amount: template.amount,
        source: template.source,
        date: date,
        description: '${template.description ?? ''} [Auto-recurring]'.trim(),
        isRecurring: false,
        accountId: template.accountId,
        parentRecurringId: template.id,
      );

      await box.put(newInc.id, newInc);
      count++;
    }

    if (count > 0) {
      await _trackingBox.put('inc_${template.id}', DateTime.now().millisecondsSinceEpoch);
    }
    return count;
  }

  /// Calculate which dates need entries generated.
  /// Only generates for dates between the template date and today.
  List<DateTime> _getMissingPeriods(String templateId, String type, DateTime startDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dates = <DateTime>[];

    DateTime cursor = startDate;

    // Generate dates from start until today
    while (true) {
      cursor = _nextDate(cursor, type, startDate.day);
      if (cursor.isAfter(today)) break;
      dates.add(cursor);
      // Safety: max 12 back-fill entries
      if (dates.length >= 12) break;
    }

    return dates;
  }

  DateTime _nextDate(DateTime current, String type, int preferredDay) {
    switch (type.toLowerCase()) {
      case 'daily':
        return current.add(const Duration(days: 1));
      case 'weekly':
        return current.add(const Duration(days: 7));
      case 'yearly':
        return DateTime(current.year + 1, current.month, preferredDay.clamp(1, 28));
      case 'monthly':
      default:
        final nextMonth = current.month + 1;
        final nextYear = nextMonth > 12 ? current.year + 1 : current.year;
        final m = nextMonth > 12 ? nextMonth - 12 : nextMonth;
        final lastDay = DateTime(nextYear, m + 1, 0).day;
        return DateTime(nextYear, m, preferredDay.clamp(1, lastDay));
    }
  }
}