import 'package:get/get.dart';
import 'package:hive/hive.dart';

class SettingsController extends GetxController {
  final Box _settingsBox = Hive.box('settings');

  final RxString currency = 'USD'.obs;
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
    currency.value = _settingsBox.get('currency', defaultValue: 'USD');
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
  }

  Future<void> updateCurrency(String value) async {
    currency.value = value;
    await _settingsBox.put('currency', value);
  }

  Future<void> toggleNotifications(bool value) async {
    enableNotifications.value = value;
    await _settingsBox.put('enableNotifications', value);
  }

  Future<void> toggleDarkMode(bool value) async {
    enableDarkMode.value = value;
    await _settingsBox.put('enableDarkMode', value);
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
    await Hive.box('expenses').clear();
    await Hive.box('todos').clear();
    await Hive.box('budgets').clear();
    await Hive.box('receipts').clear();
    // Don't clear categories and settings
  }

  Future<void> exportData() async {
    // Implement data export functionality
  }

  Future<void> importData() async {
    // Implement data import functionality
  }
}
