import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/services/auth_service.dart';
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
                _buildSecuritySection(isDark),
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
        left: 20, right: 20, bottom: 16,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : _getThemedColor(NeoBrutalismTheme.accentPurple, isDark),
        border: const Border(bottom: BorderSide(
            color: NeoBrutalismTheme.primaryBlack, width: NeoBrutalismTheme.borderWidth)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(Get.context!).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: NeoBrutalismTheme.neoBox(
                color: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
                offset: 3, borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: Icon(Icons.arrow_back,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
            ),
          ),
          const SizedBox(width: 16),
          Text('SETTINGS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
              letterSpacing: -1,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
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
          Obx(() => _buildToggleTile('Dark Mode', 'Enable dark theme',
              controller.enableDarkMode.value,
                  (v) => controller.toggleDarkMode(v), Icons.dark_mode, isDark)),
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
              Icon(Icons.attach_money, color: isDark ? NeoBrutalismTheme.darkText : null),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Currency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                        color: isDark ? NeoBrutalismTheme.darkText : null)),
                    Obx(() => Text(controller.currency.value,
                        style: TextStyle(fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600]))),
                  ],
                ),
              ),
            ],
          ),
        ),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: NeoBrutalismTheme.neoBox(isDark: isDark),
          child: DropdownButton<String>(
            value: controller.currency.value,
            underline: const SizedBox(),
            dropdownColor: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            style: TextStyle(color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
            onChanged: (v) { if (v != null) controller.updateCurrency(v); },
            items: ['USD', 'EUR', 'GBP', 'INR', 'JPY'].map((c) =>
                DropdownMenuItem(value: c, child: Text(c))).toList(),
          ),
        )),
      ],
    );
  }

  // ─── SECURITY ────────────────────────────────────────────

  Widget _buildSecuritySection(bool isDark) {
    final auth = Get.find<AuthService>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NeoBrutalismTheme.neoBox(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSectionTitle('SECURITY', isDark),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
                  border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5),
                ),
                child: const Text('🔐', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // PIN status
          Obx(() => _buildInfoTile(
            'PIN Lock',
            auth.isSetupComplete.value ? 'Active' : 'Not set up',
            Icons.lock,
            isDark,
          )),
          const SizedBox(height: 16),

          // Biometric toggle
          Obx(() => _buildToggleTile(
            'Biometric Unlock',
            auth.biometricAvailable.value
                ? 'Use fingerprint or face to unlock'
                : 'Not available on this device',
            auth.biometricEnabled.value,
            auth.biometricAvailable.value
                ? (v) => auth.setBiometric(v)
                : (_) {},
            Icons.fingerprint,
            isDark,
          )),
          const SizedBox(height: 16),

          // Lock timeout
          Obx(() {
            final timeout = auth.lockTimeout.value;
            String timeoutLabel;
            if (timeout == 0) {
              timeoutLabel = 'Immediately';
            } else if (timeout < 60) {
              timeoutLabel = '${timeout}s';
            } else {
              timeoutLabel = '${timeout ~/ 60} min';
            }

            return _buildActionTile(
              'Lock Timeout',
              'Lock after $timeoutLabel in background',
              Icons.timer,
                  () => _showTimeoutPicker(isDark, auth),
              isDark: isDark,
            );
          }),
          const SizedBox(height: 12),

          // Change PIN
          _buildActionTile(
            'Change PIN',
            'Set a new PIN code',
            Icons.pin,
                () => _showChangePinDialog(isDark, auth),
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // View recovery phrase warning
          _buildActionTile(
            'Recovery Info',
            'What to do if you forget your PIN',
            Icons.help_outline,
                () => _showRecoveryInfo(isDark),
            isDark: isDark,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0);
  }

  void _showTimeoutPicker(bool isDark, AuthService auth) {
    final options = [
      {'label': 'Immediately', 'value': 0},
      {'label': '30 seconds', 'value': 30},
      {'label': '1 minute', 'value': 60},
      {'label': '5 minutes', 'value': 300},
      {'label': '15 minutes', 'value': 900},
    ];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: const Border(
            top: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
            left: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
            right: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('LOCK TIMEOUT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
            const SizedBox(height: 6),
            Text('How long before the app locks after going to background',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[600])),
            const SizedBox(height: 20),
            ...options.map((opt) {
              final isSelected = auth.lockTimeout.value == opt['value'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    auth.setLockTimeout(opt['value'] as int);
                    Navigator.of(Get.context!).pop();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: isSelected
                        ? NeoBrutalismTheme.neoBox(
                        color: _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
                        offset: 3, borderColor: NeoBrutalismTheme.primaryBlack)
                        : NeoBrutalismTheme.neoBox(
                        color: isDark ? NeoBrutalismTheme.darkBackground : Colors.grey[50]!,
                        offset: 2, borderColor: NeoBrutalismTheme.primaryBlack),
                    child: Row(
                      children: [
                        Text(opt['label'] as String, style: TextStyle(fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                        const Spacer(),
                        if (isSelected)
                          const Icon(Icons.check_circle, size: 20, color: NeoBrutalismTheme.primaryBlack),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showChangePinDialog(bool isDark, AuthService auth) {
    final oldPinCtrl = TextEditingController();
    final newPinCtrl = TextEditingController();
    final confirmPinCtrl = TextEditingController();
    final error = ''.obs;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: NeoBrutalismTheme.neoBoxRounded(
            color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('CHANGE PIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
              const SizedBox(height: 20),
              _buildPinField(oldPinCtrl, 'Current PIN', isDark),
              const SizedBox(height: 12),
              _buildPinField(newPinCtrl, 'New PIN (4-6 digits)', isDark),
              const SizedBox(height: 12),
              _buildPinField(confirmPinCtrl, 'Confirm New PIN', isDark),
              const SizedBox(height: 8),
              Obx(() => error.value.isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(error.value, style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w700, color: Colors.red)),
              )
                  : const SizedBox.shrink()),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: NeoButton(
                    text: 'CANCEL', onPressed: () => Navigator.of(Get.context!).pop(),
                    color: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
                    textColor: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: NeoButton(
                    text: 'SAVE',
                    onPressed: () async {
                      if (newPinCtrl.text.length < 4) {
                        error.value = 'New PIN must be at least 4 digits';
                        return;
                      }
                      if (newPinCtrl.text != confirmPinCtrl.text) {
                        error.value = 'New PINs don\'t match';
                        return;
                      }
                      final success = await auth.changePin(oldPinCtrl.text, newPinCtrl.text);
                      if (success) {
                        Navigator.of(Get.context!).pop();
                        Get.snackbar('PIN Changed', 'Your new PIN is active',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green[100], colorText: Colors.green[900]);
                      } else {
                        error.value = 'Current PIN is incorrect';
                      }
                    },
                    color: _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinField(TextEditingController ctrl, String hint, bool isDark) {
    return Container(
      decoration: NeoBrutalismTheme.neoBox(
        color: isDark ? NeoBrutalismTheme.darkBackground : Colors.grey[50]!,
        offset: 2, borderColor: NeoBrutalismTheme.primaryBlack,
      ),
      child: TextField(
        controller: ctrl,
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: 6,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 8,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
        decoration: InputDecoration(
          hintText: hint,
          counterText: '',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintStyle: TextStyle(fontSize: 13, letterSpacing: 0,
              color: isDark ? Colors.grey[600] : Colors.grey[400]),
        ),
      ),
    );
  }

  void _showRecoveryInfo(bool isDark) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: NeoBrutalismTheme.neoBoxRounded(
            color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔑', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text('FORGOT YOUR PIN?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
              const SizedBox(height: 12),
              Text(
                'On the lock screen, tap "Forgot PIN?" and enter your 12-word recovery phrase that was shown during setup.\n\n'
                    'If you lost your recovery phrase, your data cannot be recovered. This is by design — no one, not even us, can access your data.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.5,
                    color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              NeoButton(text: 'GOT IT', onPressed: () => Navigator.of(Get.context!).pop(),
                  color: _getThemedColor(NeoBrutalismTheme.accentPurple, isDark)),
            ],
          ),
        ),
      ),
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
          Obx(() {
            final accountController = Get.find<AccountController>();
            final accountCount = accountController.accounts.length;
            return _buildActionTile('Manage Accounts',
                '$accountCount account${accountCount == 1 ? '' : 's'} configured',
                Icons.account_balance, () => Get.toNamed('/accounts'), isDark: isDark);
          }),
          const SizedBox(height: 12),
          Obx(() {
            final accountController = Get.find<AccountController>();
            final defaultAcc = accountController.getDefaultAccount();
            return _buildInfoTile('Default Account',
                '${defaultAcc?.icon ?? '💰'} ${defaultAcc?.name ?? 'None'}',
                Icons.star, isDark);
          }),
          const SizedBox(height: 12),
          Obx(() {
            final periodService = Get.find<PeriodService>();
            return _buildInfoTile('Viewing Period', periodService.periodLabel,
                Icons.calendar_month, isDark);
          }),
          const SizedBox(height: 12),
          _buildActionTile('Savings Goals', 'Track progress toward your targets',
              Icons.savings, () => Get.toNamed('/savings'), isDark: isDark),
          const SizedBox(height: 12),
          _buildActionTile('Debt / EMI Tracker', 'Manage loans and EMI payments',
              Icons.account_balance, () => Get.toNamed('/debt'), isDark: isDark),
          const SizedBox(height: 12),
          _buildActionTile('Financial Calendar', 'Spending heatmap by day',
              Icons.calendar_month, () => Get.toNamed('/financial-calendar'), isDark: isDark),
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
          Obx(() => _buildToggleTile('Push Notifications', 'Get reminders and alerts',
              controller.enableNotifications.value,
                  (v) => controller.toggleNotifications(v), Icons.notifications, isDark)),
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
          _buildActionTile('Export Data', 'Save your data to file', Icons.download,
                  () => ExportService().exportAll(
                expenses: Get.find<ExpenseController>().expenses,
                incomes: Get.find<IncomeController>().incomes,
                categories: Get.find<CategoryController>().categories,
                accounts: Get.find<AccountController>().accounts,
              ), isDark: isDark),
          const SizedBox(height: 12),
          _buildActionTile('Import Data', 'Restore from backup', Icons.upload,
                  () => controller.importData(), isDark: isDark),
          const SizedBox(height: 12),
          _buildActionTile('Clear All Data', 'Delete all expenses, incomes, and todos',
              Icons.delete_forever, () => _showClearDataDialog(isDark),
              isDestructive: true, isDark: isDark),
          const SizedBox(height: 12),
          _buildActionTile(
            'Backup & Restore',
            'Encrypted backup to file',
            Icons.cloud_upload,
                () => Get.toNamed('/backup'),
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
            width: 72, height: 72,
            decoration: NeoBrutalismTheme.neoBox(
                color: NeoBrutalismTheme.primaryBlack, borderColor: NeoBrutalismTheme.primaryBlack),
            child: const Icon(Icons.rocket_launch, size: 36, color: NeoBrutalismTheme.primaryWhite),
          ),
          const SizedBox(height: 14),
          const Text('MAGIC LEDGER', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.primaryBlack)),
          const Text('Version 2.0.0', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
              color: NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 8),
          const Text('Track. Save. Achieve.', style: TextStyle(fontSize: 15,
              fontWeight: FontWeight.w600, color: NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 8),
          const Text('Multi-account • Period history • Smart comparisons',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(Icons.language, () async {
                try {
                  final Uri webLink = Uri.parse("https://github.com/VisaganSP");
                  if (await canLaunchUrl(webLink)) {
                    await launchUrl(webLink, mode: LaunchMode.externalApplication);
                  }
                } catch (e) { debugPrint('Error: $e'); }
              }, isDark),
              _buildSocialButton(Icons.email, () async {
                try {
                  final Uri emailUri = Uri(scheme: 'mailto', path: 'visagansvvg@gmail.com',
                      queryParameters: {'subject': 'Magic Ledger Feedback'});
                  if (await canLaunchUrl(emailUri)) await launchUrl(emailUri);
                } catch (e) { debugPrint('Error: $e'); }
              }, isDark),
              _buildSocialButton(Icons.phone, () async {
                try {
                  final Uri phoneUri = Uri(scheme: 'tel', path: '+917339124748');
                  if (await canLaunchUrl(phoneUri)) await launchUrl(phoneUri);
                } catch (e) { debugPrint('Error: $e'); }
              }, isDark),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0);
  }

  // ─── SHARED WIDGETS ──────────────────────────────────────

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
        color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack));
  }

  Widget _buildToggleTile(String title, String subtitle, bool value,
      Function(bool) onChanged, IconData icon, bool isDark) {
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
                    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                        color: isDark ? NeoBrutalismTheme.darkText : null)),
                    Text(subtitle, style: TextStyle(fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600])),
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

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap,
      {bool isDestructive = false, required bool isDark}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: NeoBrutalismTheme.neoBox(
          color: isDestructive ? Colors.red.shade50
              : (isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite),
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(icon, size: 22, color: isDestructive ? Colors.red
                      : (isDark ? NeoBrutalismTheme.darkText : null)),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                            color: isDestructive ? Colors.red
                                : (isDark ? NeoBrutalismTheme.darkText : null))),
                        Text(subtitle, style: TextStyle(fontSize: 13,
                            color: isDestructive ? Colors.red[300]
                                : (isDark ? Colors.grey[400] : Colors.grey[600]))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: isDestructive ? Colors.red
                : (isDark ? NeoBrutalismTheme.darkText : null)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 22, color: isDark ? Colors.grey[400] : Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600])),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48, height: 48,
        decoration: NeoBrutalismTheme.neoBox(
            color: NeoBrutalismTheme.primaryWhite, borderColor: Colors.black),
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
            color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60, height: 60,
                decoration: NeoBrutalismTheme.neoBox(
                    color: Colors.red, borderColor: NeoBrutalismTheme.primaryBlack),
                child: const Icon(Icons.warning, color: NeoBrutalismTheme.primaryWhite, size: 32),
              ),
              const SizedBox(height: 16),
              Text('CLEAR ALL DATA?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
              const SizedBox(height: 16),
              Text('This will delete all expenses, incomes, todos, transfers, and receipts. '
                  'Accounts and categories will be kept. This cannot be undone!',
                  style: TextStyle(fontSize: 14,
                      color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: NeoButton(text: 'CANCEL', onPressed: () => Navigator.of(Get.context!).pop(),
                      color: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
                      textColor: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                  const SizedBox(width: 12),
                  Expanded(child: NeoButton(text: 'DELETE ALL',
                      onPressed: () async { Navigator.of(Get.context!).pop(); await controller.clearAllData(); },
                      color: Colors.red, textColor: NeoBrutalismTheme.primaryWhite)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}