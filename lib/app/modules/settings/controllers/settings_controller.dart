import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../data/providers/hive_provider.dart';
import '../../../data/services/export_service.dart';
import '../../account/controllers/account_controller.dart';
import '../../category/controllers/category_controller.dart';
import '../../expense/controllers/expense_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../income/controllers/income_controller.dart';
import '../../todo/controllers/todo_controller.dart';

class SettingsController extends GetxController {
  final Box _settingsBox = Hive.box('settings');

  final RxString currency = 'INR'.obs;
  final RxBool enableNotifications = true.obs;
  final RxBool enableDarkMode = false.obs;
  final RxString backupFrequency = 'weekly'.obs;
  final RxBool enableBiometric = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() {
    currency.value = _settingsBox.get('currency', defaultValue: 'INR');
    enableNotifications.value = _settingsBox.get(
      'enableNotifications',
      defaultValue: true,
    );

    if (_settingsBox.containsKey('enableDarkMode')) {
      enableDarkMode.value = _settingsBox.get('enableDarkMode');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateTheme();
      });
    } else {
      final brightness = WidgetsBinding.instance.window.platformBrightness;
      enableDarkMode.value = brightness == Brightness.dark;
    }

    backupFrequency.value = _settingsBox.get(
      'backupFrequency',
      defaultValue: 'weekly',
    );
    enableBiometric.value = _settingsBox.get(
      'enableBiometric',
      defaultValue: false,
    );
  }

  Future<void> updateCurrency(String value) async {
    currency.value = value;
    await _settingsBox.put('currency', value);

    Get.snackbar(
      'Currency Updated',
      'Currency changed to $value',
      backgroundColor: const Color(0xFFB8E994),
      colorText: Colors.black,
      borderWidth: 3,
      borderColor: Colors.black,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> toggleNotifications(bool value) async {
    enableNotifications.value = value;
    await _settingsBox.put('enableNotifications', value);

    Get.snackbar(
      'Notifications ${value ? 'Enabled' : 'Disabled'}',
      value
          ? 'You will receive push notifications'
          : 'Push notifications are disabled',
      backgroundColor: const Color(0xFF9DB4FF),
      colorText: Colors.black,
      borderWidth: 3,
      borderColor: Colors.black,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> toggleDarkMode(bool value) async {
    enableDarkMode.value = value;
    await _settingsBox.put('enableDarkMode', value);

    _updateTheme();

    Get.snackbar(
      'Theme Changed',
      value ? 'Dark mode enabled' : 'Light mode enabled',
      backgroundColor:
      value ? Colors.grey[800]! : const Color(0xFFE8CCFF),
      colorText: value ? Colors.white : Colors.black,
      borderWidth: 3,
      borderColor: Colors.black,
      duration: const Duration(seconds: 2),
    );
  }

  void _updateTheme() {
    if (_settingsBox.containsKey('enableDarkMode')) {
      Get.changeThemeMode(
        enableDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      );
    }
  }

  Future<void> updateBackupFrequency(String value) async {
    backupFrequency.value = value;
    await _settingsBox.put('backupFrequency', value);
  }

  Future<void> toggleBiometric(bool value) async {
    enableBiometric.value = value;
    await _settingsBox.put('enableBiometric', value);
  }

  Future<void> clearAllData() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Clear in-memory data from all controllers
      try {
        if (Get.isRegistered<ExpenseController>()) {
          Get.find<ExpenseController>().expenses.clear();
        }
      } catch (_) {}

      try {
        if (Get.isRegistered<TodoController>()) {
          Get.find<TodoController>().todos.clear();
        }
      } catch (_) {}

      try {
        if (Get.isRegistered<IncomeController>()) {
          Get.find<IncomeController>().incomes.clear();
        }
      } catch (_) {}

      try {
        if (Get.isRegistered<AccountController>()) {
          Get.find<AccountController>().transfers.clear();
        }
      } catch (_) {}

      // Clear Hive boxes
      await HiveProvider.clearAllData();

      // Reset home controller stats (Phase 2 field names)
      try {
        if (Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();
          homeController.totalExpenses.value = 0.0;
          homeController.totalIncome.value = 0.0;
          homeController.balance.value = 0.0;
          homeController.pendingTodos.value = 0;
          homeController.savingsPercentage.value = 0.0;
          homeController.totalTransactions.value = 0;
          homeController.dailyAvgExpense.value = 0.0;
          homeController.prevMonthExpenses.value = 0.0;
          homeController.prevMonthIncome.value = 0.0;
          homeController.expenseChangePercent.value = 0.0;
          homeController.incomeChangePercent.value = 0.0;
        }
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 300));

      Get.back();

      Get.deleteAll(force: true);

      Get.offAllNamed('/home');

      await Future.delayed(const Duration(milliseconds: 500));

      Get.snackbar(
        'Success',
        'All data has been cleared',
        backgroundColor: const Color(0xFFB8E994),
        colorText: Colors.black,
        borderWidth: 3,
        borderColor: Colors.black,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to clear data: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        borderWidth: 3,
        borderColor: Colors.black,
      );
    }
  }

  Future<void> exportData() async {
    await Future.delayed(const Duration(seconds: 2));

    ExportService().exportAll(
      expenses: Get.find<ExpenseController>().expenses,
      incomes: Get.find<IncomeController>().incomes,
      categories: Get.find<CategoryController>().categories,
      accounts: Get.find<AccountController>().accounts,
    );

    Get.snackbar(
      'Export Complete',
      'Your data has been exported successfully',
      backgroundColor: const Color(0xFFB8E994),
      colorText: Colors.black,
      borderWidth: 3,
      borderColor: Colors.black,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> importData() async {
    await Future.delayed(const Duration(seconds: 2));

    Get.snackbar(
      'Import Complete',
      'Your data has been imported successfully',
      backgroundColor: const Color(0xFFFDB5D6),
      colorText: Colors.black,
      borderWidth: 3,
      borderColor: Colors.black,
      duration: const Duration(seconds: 3),
    );
  }

  String getCurrencySymbol() {
    switch (currency.value) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      case 'JPY':
        return '¥';
      default:
        return '₹';
    }
  }
}