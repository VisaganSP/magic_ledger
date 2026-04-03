import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/services/export_service.dart';
import '../../../data/services/period_service.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../account/controllers/account_controller.dart';
import '../../category/controllers/category_controller.dart';
import '../../expense/controllers/expense_controller.dart';
import '../../income/controllers/income_controller.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  Color _getThemedColor(Color color, bool isDark) {
    return NeoBrutalismTheme.getThemedColor(color, isDark);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      body: Column(
        children: [
          _buildHeader(isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildGeneralSection(isDark),
                const SizedBox(height: 20),
                _buildAccountsSection(isDark),
                const SizedBox(height: 20),
                _buildNotificationSection(isDark),
                const SizedBox(height: 20),
                _buildDataSection(isDark),
                const SizedBox(height: 20),
                _buildAboutSection(isDark),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : _getThemedColor(NeoBrutalismTheme.accentPurple, isDark),
        border: const Border(
          bottom: BorderSide(
            color: NeoBrutalismTheme.primaryBlack,
            width: NeoBrutalismTheme.borderWidth,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: NeoBrutalismTheme.neoBox(
                color: isDark
                    ? NeoBrutalismTheme.darkBackground
                    : NeoBrutalismTheme.primaryWhite,
                offset: 3,
                borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: Icon(
                Icons.arrow_back,
                color: isDark
                    ? NeoBrutalismTheme.darkText
                    : NeoBrutalismTheme.primaryBlack,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'SETTINGS',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              color: isDark
                  ? NeoBrutalismTheme.darkText
                  : NeoBrutalismTheme.primaryBlack,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  // ─── GENERAL ─────────────────────────────────────────────

  Widget _buildGeneralSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NeoBrutalismTheme.neoBox(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('GENERAL', isDark),
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
              dropdownColor: isDark
                  ? NeoBrutalismTheme.darkSurface
                  : NeoBrutalismTheme.primaryWhite,
              style: TextStyle(
                color: isDark
                    ? NeoBrutalismTheme.darkText
                    : NeoBrutalismTheme.primaryBlack,
              ),
              onChanged: (value) {
                if (value != null) {
                  controller.updateCurrency(value);
                }
              },
              items: ['USD', 'EUR', 'GBP', 'INR', 'JPY']
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

  // ─── ACCOUNTS ────────────────────────────────────────────

  Widget _buildAccountsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NeoBrutalismTheme.neoBox(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('ACCOUNTS & DATA', isDark),
          const SizedBox(height: 16),

          // Account summary
          Obx(() {
            final accountController = Get.find<AccountController>();
            final accountCount = accountController.accounts.length;

            return _buildActionTile(
              'Manage Accounts',
              '$accountCount account${accountCount == 1 ? '' : 's'} configured',
              Icons.account_balance,
                  () => Get.toNamed('/accounts'),
              isDark: isDark,
            );
          }),
          const SizedBox(height: 12),

          // Default account info
          Obx(() {
            final accountController = Get.find<AccountController>();
            final defaultAcc = accountController.getDefaultAccount();
            final defaultName = defaultAcc?.name ?? 'None';

            return _buildInfoTile(
              'Default Account',
              '${defaultAcc?.icon ?? '💰'} $defaultName',
              Icons.star,
              isDark,
            );
          }),
          const SizedBox(height: 12),

          // Period info
          Obx(() {
            final periodService = Get.find<PeriodService>();
            return _buildInfoTile(
              'Viewing Period',
              periodService.periodLabel,
              Icons.calendar_month,
              isDark,
            );
          }),

          const SizedBox(height: 12),
          _buildActionTile(
            'Savings Goals',
            'Track progress toward your targets',
            Icons.savings,
                () => Get.toNamed('/savings'),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            'Debt / EMI Tracker',
            'Manage loans and EMI payments',
            Icons.account_balance,
                () => Get.toNamed('/debt'),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            'Financial Calendar',
            'Spending heatmap by day',
            Icons.calendar_month,
                () => Get.toNamed('/financial-calendar'),
            isDark: isDark,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  // ─── NOTIFICATIONS ───────────────────────────────────────

  Widget _buildNotificationSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NeoBrutalismTheme.neoBox(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('NOTIFICATIONS', isDark),
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
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  // ─── DATA MANAGEMENT ─────────────────────────────────────

  Widget _buildDataSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NeoBrutalismTheme.neoBox(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('DATA MANAGEMENT', isDark),
          const SizedBox(height: 16),
          _buildActionTile(
            'Export Data',
            'Save your data to file',
            Icons.download,
                () => ExportService().exportAll(
              expenses: Get.find<ExpenseController>().expenses,
              incomes: Get.find<IncomeController>().incomes,
              categories: Get.find<CategoryController>().categories,
              accounts: Get.find<AccountController>().accounts,
            ),
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
            'Delete all expenses, incomes, and todos',
            Icons.delete_forever,
                () => _showClearDataDialog(isDark),
            isDestructive: true,
            isDark: isDark,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }

  // ─── ABOUT ───────────────────────────────────────────────

  Widget _buildAboutSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NeoBrutalismTheme.neoBox(
        color: _getThemedColor(NeoBrutalismTheme.accentPurple, isDark),
        borderColor: NeoBrutalismTheme.primaryBlack,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: NeoBrutalismTheme.neoBox(
              color: NeoBrutalismTheme.primaryBlack,
              borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: const Icon(
              Icons.rocket_launch,
              size: 36,
              color: NeoBrutalismTheme.primaryWhite,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'MAGIC LEDGER',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.primaryBlack,
            ),
          ),
          const Text(
            'Version 2.0.0',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: NeoBrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track. Save. Achieve.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: NeoBrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Multi-account • Period history • Smart comparisons',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(Icons.language, () async {
                try {
                  final Uri webLink =
                  Uri.parse("https://github.com/VisaganSP");
                  if (await canLaunchUrl(webLink)) {
                    await launchUrl(webLink,
                        mode: LaunchMode.externalApplication);
                  } else {
                    Get.snackbar('Error', 'Could not open GitHub',
                        backgroundColor: Colors.red, colorText: Colors.white);
                  }
                } catch (e) {
                  debugPrint('Error launching GitHub: $e');
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
                    Get.snackbar('Error', 'Could not open email app',
                        backgroundColor: Colors.red, colorText: Colors.white);
                  }
                } catch (e) {
                  debugPrint('Error launching email: $e');
                }
              }, isDark),
              _buildSocialButton(Icons.phone, () async {
                try {
                  final Uri phoneUri = Uri(
                    scheme: 'tel',
                    path: '+917339124748',
                  );
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  } else {
                    Get.snackbar('Error', 'Could not open phone app',
                        backgroundColor: Colors.red, colorText: Colors.white);
                  }
                } catch (e) {
                  debugPrint('Error launching phone: $e');
                }
              }, isDark),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0);
  }

  // ─── SHARED WIDGETS ──────────────────────────────────────

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: isDark
            ? NeoBrutalismTheme.darkText
            : NeoBrutalismTheme.primaryBlack,
      ),
    );
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
        padding: const EdgeInsets.all(14),
        decoration: NeoBrutalismTheme.neoBox(
          color: isDestructive
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
                    size: 22,
                    color: isDestructive
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
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDestructive
                                ? Colors.red
                                : (isDark
                                ? NeoBrutalismTheme.darkText
                                : null),
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDestructive
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
              size: 20,
              color: isDestructive
                  ? Colors.red
                  : (isDark ? NeoBrutalismTheme.darkText : null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
      String title, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 22,
            color: isDark ? Colors.grey[400] : Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? NeoBrutalismTheme.darkText
                    : NeoBrutalismTheme.primaryBlack,
              ),
            ),
          ],
        ),
      ],
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
            color: isDark
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
                  color: isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This will delete all expenses, incomes, todos, transfers, and receipts. Accounts and categories will be kept. This cannot be undone!',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
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
                      color: isDark
                          ? NeoBrutalismTheme.darkBackground
                          : NeoBrutalismTheme.primaryWhite,
                      textColor: isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      text: 'DELETE ALL',
                      onPressed: () async {
                        Get.back();
                        await controller.clearAllData();
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