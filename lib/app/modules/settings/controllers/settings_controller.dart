import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../data/providers/hive_provider.dart';
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

    // Only load dark mode setting if it exists
    // Don't set a default - let the app use system theme
    if (_settingsBox.containsKey('enableDarkMode')) {
      enableDarkMode.value = _settingsBox.get('enableDarkMode');
      // Only apply theme if user has explicitly set it
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateTheme();
      });
    } else {
      // If no preference saved, check current theme mode
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
      backgroundColor: const Color(0xFF6BFF6B), // NeoBrutalismTheme.accentGreen
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
      backgroundColor: const Color(0xFF6BCFFF), // NeoBrutalismTheme.accentBlue
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
          value
              ? Colors.grey[800]!
              : const Color(0xFFFFD93D), // NeoBrutalismTheme.accentYellow
      colorText: value ? Colors.white : Colors.black,
      borderWidth: 3,
      borderColor: Colors.black,
      duration: const Duration(seconds: 2),
    );
  }

  void _updateTheme() {
    // Only change theme if user has set a preference
    if (_settingsBox.containsKey('enableDarkMode')) {
      Get.changeThemeMode(
        enableDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      );
    }
    // Otherwise, let it use system theme
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
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // First, clear the data in memory from all controllers
      try {
        if (Get.isRegistered<ExpenseController>()) {
          final expenseController = Get.find<ExpenseController>();
          expenseController.expenses.clear();
        }
      } catch (_) {}

      try {
        if (Get.isRegistered<TodoController>()) {
          final todoController = Get.find<TodoController>();
          todoController.todos.clear();
        }
      } catch (_) {}

      try {
        if (Get.isRegistered<IncomeController>()) {
          final incomeController = Get.find<IncomeController>();
          incomeController.incomes.clear();
        }
      } catch (_) {}

      // Clear the Hive boxes
      await HiveProvider.clearAllData();

      // Reset home controller stats
      try {
        if (Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();
          homeController.totalExpensesThisMonth.value = 0.0;
          homeController.totalIncomeThisMonth.value = 0.0;
          homeController.pendingTodos.value = 0;
          homeController.savingsPercentage.value = 0.0;
          homeController.pendingTodos.value = 0;
        }
      } catch (_) {}

      // Wait a bit to ensure everything is cleared
      await Future.delayed(const Duration(milliseconds: 300));

      // Close loading dialog
      Get.back();

      // Force delete all controller instances
      Get.deleteAll(force: true);

      // Navigate to home with a fresh start
      Get.offAllNamed('/home');

      // Show success message after navigation
      await Future.delayed(const Duration(milliseconds: 500));

      Get.snackbar(
        'Success',
        'All data has been cleared',
        backgroundColor: const Color(
          0xFF6BFF6B,
        ), // NeoBrutalismTheme.accentGreen
        colorText: Colors.black,
        borderWidth: 3,
        borderColor: Colors.black,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      // Close loading dialog if still open
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
    // Simulate export functionality
    await Future.delayed(const Duration(seconds: 2));

    Get.snackbar(
      'Export Complete',
      'Your data has been exported successfully',
      backgroundColor: const Color(0xFF6BFF6B), // NeoBrutalismTheme.accentGreen
      colorText: Colors.black,
      borderWidth: 3,
      borderColor: Colors.black,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> importData() async {
    // Simulate import functionality
    await Future.delayed(const Duration(seconds: 2));

    Get.snackbar(
      'Import Complete',
      'Your data has been imported successfully',
      backgroundColor: const Color(0xFFFF6BC6), // NeoBrutalismTheme.accentPink
      colorText: Colors.black,
      borderWidth: 3,
      borderColor: Colors.black,
      duration: const Duration(seconds: 3),
    );
  }

  // Currency symbol helper
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
