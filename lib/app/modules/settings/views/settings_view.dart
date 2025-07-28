import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../theme/neo_brutalism_theme.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? NeoBrutalismTheme.darkBackground
              : NeoBrutalismTheme.primaryWhite,
      appBar: AppBar(
        title: const Text('SETTINGS'),
        backgroundColor:
            isDark
                ? NeoBrutalismTheme.accentPurple
                : NeoBrutalismTheme.accentPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGeneralSection(isDark),
          const SizedBox(height: 24),
          _buildNotificationSection(isDark),
          const SizedBox(height: 24),
          _buildDataSection(isDark),
          const SizedBox(height: 24),
          _buildAboutSection(isDark),
        ],
      ),
    );
  }

  Widget _buildGeneralSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NeoBrutalismTheme.neoBox(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GENERAL',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color:
                  isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 16),
          _buildCurrencySelector(isDark),
          const SizedBox(height: 16),
          Obx(
            () => _buildToggleTile(
              'Dark Mode',
              'Enable dark theme',
              controller.enableDarkMode.value,
              (value) => controller.toggleDarkMode(value),
              Icons.dark_mode,
              isDark,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildCurrencySelector(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.attach_money,
                color: isDark ? NeoBrutalismTheme.darkText : null,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Currency',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? NeoBrutalismTheme.darkText : null,
                      ),
                    ),
                    Obx(
                      () => Text(
                        controller.currency.value,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: NeoBrutalismTheme.neoBox(isDark: isDark),
            child: DropdownButton<String>(
              value: controller.currency.value,
              underline: const SizedBox(),
              dropdownColor:
                  isDark
                      ? NeoBrutalismTheme.darkSurface
                      : NeoBrutalismTheme.primaryWhite,
              style: TextStyle(
                color:
                    isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
              ),
              onChanged: (value) {
                if (value != null) {
                  controller.updateCurrency(value);
                }
              },
              items:
                  ['USD', 'EUR', 'GBP', 'INR', 'JPY']
                      .map(
                        (currency) => DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NeoBrutalismTheme.neoBox(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NOTIFICATIONS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color:
                  isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => _buildToggleTile(
              'Push Notifications',
              'Get reminders and alerts',
              controller.enableNotifications.value,
              (value) => controller.toggleNotifications(value),
              Icons.notifications,
              isDark,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildDataSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NeoBrutalismTheme.neoBox(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DATA MANAGEMENT',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color:
                  isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            'Export Data',
            'Save your data to file',
            Icons.download,
            () => controller.exportData(),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            'Import Data',
            'Restore from backup',
            Icons.upload,
            () => controller.importData(),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            'Clear All Data',
            'Delete all expenses and todos',
            Icons.delete_forever,
            () => _showClearDataDialog(isDark),
            isDestructive: true,
            isDark: isDark,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildAboutSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NeoBrutalismTheme.neoBox(
        color: NeoBrutalismTheme.accentYellow,
        borderColor:
            isDark
                ? NeoBrutalismTheme.primaryWhite
                : NeoBrutalismTheme.primaryBlack,
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: NeoBrutalismTheme.neoBox(
              color: NeoBrutalismTheme.primaryBlack,
              borderColor:
                  isDark
                      ? NeoBrutalismTheme.primaryWhite
                      : NeoBrutalismTheme.primaryBlack,
            ),
            child: const Icon(
              Icons.rocket_launch,
              size: 40,
              color: NeoBrutalismTheme.primaryWhite,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'MAGIC LEDGER',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Track. Save. Achieve.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(Icons.language, () {}, isDark),
              _buildSocialButton(Icons.email, () {}, isDark),
              _buildSocialButton(Icons.star, () {}, isDark),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon, color: isDark ? NeoBrutalismTheme.darkText : null),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? NeoBrutalismTheme.darkText : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: NeoBrutalismTheme.neoBox(
          color:
              isDestructive
                  ? Colors.red.shade50
                  : (isDark
                      ? NeoBrutalismTheme.darkSurface
                      : NeoBrutalismTheme.primaryWhite),
          borderColor:
              isDark
                  ? NeoBrutalismTheme.primaryWhite
                  : NeoBrutalismTheme.primaryBlack,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    icon,
                    color:
                        isDestructive
                            ? Colors.red
                            : (isDark ? NeoBrutalismTheme.darkText : null),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isDestructive
                                    ? Colors.red
                                    : (isDark
                                        ? NeoBrutalismTheme.darkText
                                        : null),
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDestructive
                                    ? Colors.red[300]
                                    : (isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color:
                  isDestructive
                      ? Colors.red
                      : (isDark ? NeoBrutalismTheme.darkText : null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: NeoBrutalismTheme.neoBox(
          color: NeoBrutalismTheme.primaryWhite,
          borderColor: Colors.black,
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }

  void _showClearDataDialog(bool isDark) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: NeoBrutalismTheme.neoBoxRounded(
            color:
                isDark
                    ? NeoBrutalismTheme.darkSurface
                    : NeoBrutalismTheme.primaryWhite,
            borderColor:
                isDark
                    ? NeoBrutalismTheme.primaryWhite
                    : NeoBrutalismTheme.primaryBlack,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: NeoBrutalismTheme.neoBox(
                  color: Colors.red,
                  borderColor:
                      isDark
                          ? NeoBrutalismTheme.primaryWhite
                          : NeoBrutalismTheme.primaryBlack,
                ),
                child: const Icon(
                  Icons.warning,
                  color: NeoBrutalismTheme.primaryWhite,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'CLEAR ALL DATA?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color:
                      isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This will delete all your expenses, todos, and receipts. This action cannot be undone!',
                style: TextStyle(
                  fontSize: 16,
                  color:
                      isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark
                                ? NeoBrutalismTheme.darkSurface
                                : NeoBrutalismTheme.primaryWhite,
                        foregroundColor:
                            isDark
                                ? NeoBrutalismTheme.darkText
                                : NeoBrutalismTheme.primaryBlack,
                        side: BorderSide(
                          color:
                              isDark
                                  ? NeoBrutalismTheme.primaryWhite
                                  : NeoBrutalismTheme.primaryBlack,
                          width: 3,
                        ),
                      ),
                      child: const Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await controller.clearAllData();
                        Get.back();
                        Get.offAllNamed('/home');
                        Get.snackbar(
                          'Success',
                          'All data has been cleared',
                          backgroundColor: NeoBrutalismTheme.accentGreen,
                          colorText: NeoBrutalismTheme.primaryBlack,
                          borderWidth: 3,
                          borderColor: NeoBrutalismTheme.primaryBlack,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: NeoBrutalismTheme.primaryWhite,
                        side: const BorderSide(
                          color: NeoBrutalismTheme.primaryBlack,
                          width: 3,
                        ),
                      ),
                      child: const Text('DELETE ALL'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
