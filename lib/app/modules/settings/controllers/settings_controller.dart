import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

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
    enableDarkMode.value = _settingsBox.get(
      'enableDarkMode',
      defaultValue: false,
    );
    backupFrequency.value = _settingsBox.get(
      'backupFrequency',
      defaultValue: 'weekly',
    );
    enableBiometric.value = _settingsBox.get(
      'enableBiometric',
      defaultValue: false,
    );

    // Apply theme after the current frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTheme();
    });
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
    Get.changeThemeMode(
      enableDarkMode.value ? ThemeMode.dark : ThemeMode.light,
    );
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
      await Hive.box('expenses').clear();
      await Hive.box('todos').clear();
      await Hive.box('budgets').clear();
      await Hive.box('receipts').clear();
      // Don't clear categories and settings
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear data: $e',
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
