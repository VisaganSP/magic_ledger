import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  // Helper method to get muted colors for dark theme
  Color _getThemedColor(Color color, bool isDark) {
    if (!isDark) return color;

    // Return slightly muted versions of colors for dark theme
    if (color == NeoBrutalismTheme.accentYellow) {
      return Color(0xFFE6B800); // Slightly darker yellow
    } else if (color == NeoBrutalismTheme.accentPink) {
      return Color(0xFFE667A0); // Slightly darker pink
    } else if (color == NeoBrutalismTheme.accentBlue) {
      return Color(0xFF4D94FF); // Slightly darker blue
    } else if (color == NeoBrutalismTheme.accentGreen) {
      return Color(0xFF00CC66); // Slightly darker green
    } else if (color == NeoBrutalismTheme.accentOrange) {
      return Color(0xFFFF8533); // Slightly darker orange
    } else if (color == NeoBrutalismTheme.accentPurple) {
      return Color(0xFF9966FF); // Slightly darker purple
    }
    return color;
  }

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
        backgroundColor: _getThemedColor(
          NeoBrutalismTheme.accentPurple,
          isDark,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGeneralSection(isDark),
          const SizedBox(height: 24),
          _buildNotificationSection(isDark),
          const SizedBox(height: 24),
          _buildDataSection(isDark),
          // const SizedBox(height: 24),
          // _buildAccountSection(isDark),
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
        color: _getThemedColor(NeoBrutalismTheme.accentYellow, isDark),
        borderColor: NeoBrutalismTheme.primaryBlack,
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: NeoBrutalismTheme.neoBox(
              color: NeoBrutalismTheme.primaryBlack,
              borderColor: NeoBrutalismTheme.primaryBlack,
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
              _buildSocialButton(Icons.language, () async {
                try {
                  // Fixed URL construction
                  final Uri webLink = Uri.parse("https://github.com/VisaganSP");

                  // Check if URL can be launched before attempting
                  if (await canLaunchUrl(webLink)) {
                    await launchUrl(
                      webLink,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    Get.snackbar(
                      'Error',
                      'Could not open GitHub',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                } catch (e) {
                  debugPrint('Error launching GitHub: $e');
                  Get.snackbar(
                    'Error',
                    'Failed to open GitHub',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              }, isDark),

              _buildSocialButton(Icons.email, () async {
                try {
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: 'visagansvvg@gmail.com',
                    queryParameters: {'subject': 'Magic Ledger Feedback'},
                  );

                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  } else {
                    Get.snackbar(
                      'Error',
                      'Could not open email app',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                } catch (e) {
                  debugPrint('Error launching email: $e');
                  Get.snackbar(
                    'Error',
                    'Failed to open email app',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              }, isDark),

              _buildSocialButton(Icons.phone, () async {
                try {
                  // Remove spaces from phone number
                  final Uri phoneUri = Uri(
                    scheme: 'tel',
                    path: '+917339124748',
                  );

                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  } else {
                    Get.snackbar(
                      'Error',
                      'Could not open phone app',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                } catch (e) {
                  debugPrint('Error launching phone: $e');
                  Get.snackbar(
                    'Error',
                    'Failed to open phone app',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              }, isDark),
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
          borderColor: NeoBrutalismTheme.primaryBlack,
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
            borderColor: NeoBrutalismTheme.primaryBlack,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: NeoBrutalismTheme.neoBox(
                  color: Colors.red,
                  borderColor: NeoBrutalismTheme.primaryBlack,
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
                    child: NeoButton(
                      text: 'CANCEL',
                      onPressed: () => Get.back(),
                      color:
                          isDark
                              ? NeoBrutalismTheme.darkBackground
                              : NeoBrutalismTheme.primaryWhite,
                      textColor:
                          isDark
                              ? NeoBrutalismTheme.darkText
                              : NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      text: 'DELETE ALL',
                      onPressed: () async {
                        Get.back(); // Close dialog first
                        await controller.clearAllData();
                        Get.snackbar(
                          'Success',
                          'All data has been cleared',
                          backgroundColor: _getThemedColor(
                            NeoBrutalismTheme.accentGreen,
                            isDark,
                          ),
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

  Widget _buildAccountSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NeoBrutalismTheme.neoBox(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACCOUNT',
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
          // Show current username if logged in
          if (Get.find<AuthController>().currentUsername != null) ...[
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: isDark ? NeoBrutalismTheme.darkText : null,
                ),
                const SizedBox(width: 12),
                Text(
                  'Logged in as: ${Get.find<AuthController>().currentUsername}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? NeoBrutalismTheme.darkText : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          _buildActionTile(
            'Logout',
            'Sign out of your account',
            Icons.logout,
            () => _showLogoutDialog(isDark),
            isDestructive: true,
            isDark: isDark,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0);
  }

  void _showLogoutDialog(bool isDark) {
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
            borderColor: NeoBrutalismTheme.primaryBlack,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: NeoBrutalismTheme.neoBox(
                  color: _getThemedColor(
                    NeoBrutalismTheme.accentOrange,
                    isDark,
                  ),
                  borderColor: NeoBrutalismTheme.primaryBlack,
                ),
                child: const Icon(
                  Icons.logout,
                  color: NeoBrutalismTheme.primaryBlack,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'LOGOUT?',
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
                'Are you sure you want to logout?',
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
                    child: NeoButton(
                      text: 'CANCEL',
                      onPressed: () => Get.back(),
                      color:
                          isDark
                              ? NeoBrutalismTheme.darkBackground
                              : NeoBrutalismTheme.primaryWhite,
                      textColor:
                          isDark
                              ? NeoBrutalismTheme.darkText
                              : NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      text: 'LOGOUT',
                      onPressed: () {
                        Get.back();
                        Get.find<AuthController>().logout();
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
