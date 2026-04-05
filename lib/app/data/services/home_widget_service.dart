import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';

import '../../modules/expense/controllers/expense_controller.dart';
import '../../modules/income/controllers/income_controller.dart';
import '../../modules/account/controllers/account_controller.dart';

/// Service that updates the Android home screen widget with latest financial data.
///
/// Uses the `home_widget` package. The Android widget XML layout and
/// AppWidgetProvider class must be created separately in the Android project.
///
/// Call [updateWidget] whenever data changes (after adding expense/income,
/// on app start, etc.)
class HomeWidgetService {
  static const String _appGroupId = 'magic_ledger_widget';
  static const String _androidWidgetName = 'MagicLedgerWidgetProvider';
  static const String _iosWidgetName = 'MagicLedgerWidget';

  /// Initialize home widget (call in main.dart or initial binding)
  static Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
      // Register callback for when widget is tapped
      await HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);
    } catch (e) {
      debugPrint('[HomeWidget] Init error: $e');
    }
  }

  /// Background callback when widget is tapped
  @pragma('vm:entry-point')
  static Future<void> widgetBackgroundCallback(Uri? uri) async {
    // This fires when user taps the widget — app opens automatically
    debugPrint('[HomeWidget] Tapped: $uri');
  }

  /// Update widget with current financial data
  static Future<void> updateWidget() async {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);

      // Get controllers
      final expCtrl = Get.find<ExpenseController>();
      final incCtrl = Get.find<IncomeController>();

      // Calculate this month's data
      final monthExpenses = expCtrl.expenses.where(
              (e) => !e.date.isBefore(monthStart) && !e.date.isAfter(now));
      final monthIncomes = incCtrl.incomes.where(
              (i) => !i.date.isBefore(monthStart) && !i.date.isAfter(now));

      final totalSpent = monthExpenses.fold(0.0, (s, e) => s + e.amount);
      final totalEarned = monthIncomes.fold(0.0, (s, i) => s + i.amount);
      // Real balance from accounts, not income-expenses
      double balance = totalEarned - totalSpent; // fallback
      try {
        final accCtrl = Get.find<AccountController>();
        balance = accCtrl.getTotalBalance();
      } catch (_) {}
      final savingsRate = totalEarned > 0
          ? ((totalEarned - totalSpent) / totalEarned * 100)
          : 0.0;

      // Today's spending
      final today = DateTime(now.year, now.month, now.day);
      final todaySpent = expCtrl.expenses
          .where((e) => e.date.year == today.year &&
          e.date.month == today.month && e.date.day == today.day)
          .fold(0.0, (s, e) => s + e.amount);

      // Daily average
      final daysElapsed = now.day;
      final dailyAvg = daysElapsed > 0 ? totalSpent / daysElapsed : 0.0;

      // Transaction count
      final txCount = monthExpenses.length + monthIncomes.length;

      // Month names
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final monthName = months[now.month - 1];

      // Account balance
      double accountBalance = 0;
      try {
        final accCtrl = Get.find<AccountController>();
        accountBalance = accCtrl.getTotalBalance();
      } catch (_) {}

      // Save all data to shared preferences (accessible by widget)
      await HomeWidget.saveWidgetData('balance', _formatAmount(balance));
      await HomeWidget.saveWidgetData('spent', _formatAmount(totalSpent));
      await HomeWidget.saveWidgetData('earned', _formatAmount(totalEarned));
      await HomeWidget.saveWidgetData('today_spent', _formatAmount(todaySpent));
      await HomeWidget.saveWidgetData('daily_avg', _formatAmount(dailyAvg));
      await HomeWidget.saveWidgetData('savings_rate', '${savingsRate.toStringAsFixed(0)}%');
      await HomeWidget.saveWidgetData('tx_count', '$txCount');
      await HomeWidget.saveWidgetData('month', '$monthName ${now.year}');
      await HomeWidget.saveWidgetData('account_balance', _formatAmount(accountBalance));
      await HomeWidget.saveWidgetData('last_updated',
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}');

      // Balance color indicator
      await HomeWidget.saveWidgetData('balance_positive', balance >= 0 ? 'true' : 'false');

      // Trigger widget update
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        iOSName: _iosWidgetName,
      );

      debugPrint('[HomeWidget] Updated: balance=$balance, spent=$totalSpent');
    } catch (e) {
      debugPrint('[HomeWidget] Update error: $e');
    }
  }

  static String _formatAmount(double amount) {
    final abs = amount.abs();
    final prefix = amount < 0 ? '-' : '';
    if (abs >= 10000000) return '$prefix₹${(abs / 10000000).toStringAsFixed(1)}Cr';
    if (abs >= 100000) return '$prefix₹${(abs / 100000).toStringAsFixed(1)}L';
    if (abs >= 1000) return '$prefix₹${(abs / 1000).toStringAsFixed(1)}K';
    return '$prefix₹${abs.toStringAsFixed(0)}';
  }
}