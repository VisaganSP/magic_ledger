import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalismTheme.primaryWhite,
      appBar: AppBar(
        title: const Text('SETTINGS'),
        backgroundColor: NeoBrutalismTheme.accentPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGeneralSection(),
          const SizedBox(height: 24),
          _buildNotificationSection(),
          const SizedBox(height: 24),
          _buildSecuritySection(),
          const SizedBox(height: 24),
          _buildDataSection(),
          const SizedBox(height: 24),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildGeneralSection() {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GENERAL',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          _buildCurrencySelector(),
          const SizedBox(height: 16),
          Obx(
            () => _buildToggleTile(
              'Dark Mode',
              'Enable dark theme',
              controller.enableDarkMode.value,
              (value) => controller.toggleDarkMode(value),
              Icons.dark_mode,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildCurrencySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.attach_money),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Currency',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Obx(
                  () => Text(
                    controller.currency.value,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ],
        ),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: NeoBrutalismTheme.neoBox(),
            child: DropdownButton<String>(
              value: controller.currency.value,
              underline: const SizedBox(),
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

  Widget _buildNotificationSection() {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NOTIFICATIONS',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Obx(
            () => _buildToggleTile(
              'Push Notifications',
              'Get reminders and alerts',
              controller.enableNotifications.value,
              (value) => controller.toggleNotifications(value),
              Icons.notifications,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSecuritySection() {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SECURITY',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Obx(
            () => _buildToggleTile(
              'Biometric Lock',
              'Use fingerprint or face ID',
              controller.enableBiometric.value,
              (value) => controller.toggleBiometric(value),
              Icons.fingerprint,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildDataSection() {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DATA MANAGEMENT',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            'Export Data',
            'Save your data to file',
            Icons.download,
            () => controller.exportData(),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            'Import Data',
            'Restore from backup',
            Icons.upload,
            () => controller.importData(),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            'Clear All Data',
            'Delete all expenses and todos',
            Icons.delete_forever,
            () => _showClearDataDialog(),
            isDestructive: true,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildAboutSection() {
    return NeoCard(
      color: NeoBrutalismTheme.accentYellow,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: NeoBrutalismTheme.neoBox(
              color: NeoBrutalismTheme.primaryBlack,
            ),
            child: const Icon(
              Icons.rocket_launch,
              size: 40,
              color: NeoBrutalismTheme.primaryWhite,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'NEO TRACKER',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const Text(
            'Version 1.0.0',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          const Text(
            'Track. Save. Achieve.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(Icons.language, () {}),
              _buildSocialButton(Icons.email, () {}),
              _buildSocialButton(Icons.star, () {}),
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
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: NeoBrutalismTheme.primaryBlack,
        ),
      ],
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: NeoBrutalismTheme.neoBox(
          color:
              isDestructive
                  ? Colors.red.shade50
                  : NeoBrutalismTheme.primaryWhite,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: isDestructive ? Colors.red : null),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDestructive ? Colors.red : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isDestructive ? Colors.red[300] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(Icons.chevron_right, color: isDestructive ? Colors.red : null),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: NeoBrutalismTheme.neoBox(
          color: NeoBrutalismTheme.primaryWhite,
        ),
        child: Icon(icon),
      ),
    );
  }

  void _showClearDataDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: NeoBrutalismTheme.neoBoxRounded(
            color: NeoBrutalismTheme.primaryWhite,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: NeoBrutalismTheme.neoBox(color: Colors.red),
                child: const Icon(
                  Icons.warning,
                  color: NeoBrutalismTheme.primaryWhite,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'CLEAR ALL DATA?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              const Text(
                'This will delete all your expenses, todos, and receipts. This action cannot be undone!',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      text: 'CANCEL',
                      onPressed: () => Get.back(),
                      color: NeoBrutalismTheme.primaryWhite,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      text: 'DELETE ALL',
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
                      color: Colors.red,
                      textColor: NeoBrutalismTheme.primaryWhite,
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
