import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/account_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../controllers/account_controller.dart';

class AddAccountView extends GetView<AccountController> {
  const AddAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final AccountModel? editingAccount = Get.arguments as AccountModel?;
    final isEditing = editingAccount != null;

    final nameController =
    TextEditingController(text: editingAccount?.name ?? '');
    final bankController =
    TextEditingController(text: editingAccount?.bankName ?? '');
    final balanceController = TextEditingController(
        text: editingAccount?.initialBalance.toString() ?? '0');
    final descController =
    TextEditingController(text: editingAccount?.description ?? '');

    final selectedType =
        (editingAccount?.accountType ?? 'savings').obs;
    final selectedIcon = (editingAccount?.icon ?? '🏦').obs;
    final selectedColor =
        (editingAccount?.color ?? AccountController.accountColors.first.value)
            .obs;

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      body: Column(
        children: [
          _buildHeader(isDark, isEditing),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Account Name
                _buildLabel('ACCOUNT NAME', isDark),
                const SizedBox(height: 8),
                _buildTextField(nameController, 'e.g. SBI Savings', isDark),
                const SizedBox(height: 20),

                // Bank Name
                _buildLabel('BANK / PROVIDER', isDark),
                const SizedBox(height: 8),
                _buildTextField(
                    bankController, 'e.g. SBI, HDFC, Paytm', isDark),
                const SizedBox(height: 20),

                // Account Type
                _buildLabel('ACCOUNT TYPE', isDark),
                const SizedBox(height: 8),
                Obx(() => _buildAccountTypeSelector(selectedType, isDark)),
                const SizedBox(height: 20),

                // Initial Balance
                _buildLabel('INITIAL BALANCE', isDark),
                const SizedBox(height: 8),
                _buildTextField(balanceController, '0', isDark,
                    prefixText: '₹ ',
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 20),

                // Icon
                _buildLabel('ICON', isDark),
                const SizedBox(height: 8),
                Obx(() => _buildIconSelector(selectedIcon, isDark)),
                const SizedBox(height: 20),

                // Color
                _buildLabel('COLOR', isDark),
                const SizedBox(height: 8),
                Obx(() => _buildColorSelector(selectedColor, isDark)),
                const SizedBox(height: 20),

                // Description
                _buildLabel('DESCRIPTION (OPTIONAL)', isDark),
                const SizedBox(height: 8),
                _buildTextField(descController, 'Any notes...', isDark,
                    maxLines: 3),
                const SizedBox(height: 32),

                // Save Button
                NeoButton(
                  text: isEditing ? 'UPDATE ACCOUNT' : 'CREATE ACCOUNT',
                  onPressed: () => _saveAccount(
                    editingAccount: editingAccount,
                    name: nameController.text,
                    bankName: bankController.text,
                    accountType: selectedType.value,
                    balance: balanceController.text,
                    icon: selectedIcon.value,
                    color: selectedColor.value,
                    description: descController.text,
                  ),
                  color: NeoBrutalismTheme.accentGreen,
                  icon: isEditing ? Icons.save : Icons.add,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isEditing) {
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
            : NeoBrutalismTheme.accentSkyBlue,
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
            onTap: () => Navigator.of(Get.context!).pop(),
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
            isEditing ? 'EDIT ACCOUNT' : 'NEW ACCOUNT',
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

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
        color: isDark
            ? NeoBrutalismTheme.darkText
            : NeoBrutalismTheme.primaryBlack,
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController ctrl,
      String hint,
      bool isDark, {
        String? prefixText,
        TextInputType? keyboardType,
        int maxLines = 1,
      }) {
    return Container(
      decoration: NeoBrutalismTheme.neoBox(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : NeoBrutalismTheme.primaryWhite,
        offset: 3,
        borderColor: NeoBrutalismTheme.primaryBlack,
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark
              ? NeoBrutalismTheme.darkText
              : NeoBrutalismTheme.primaryBlack,
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefixText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTypeSelector(RxString selectedType, bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AccountController.accountTypes.map((type) {
        final isSelected = selectedType.value == type['value'];
        return GestureDetector(
          onTap: () => selectedType.value = type['value']!,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: NeoBrutalismTheme.neoBox(
              color: isSelected
                  ? NeoBrutalismTheme.accentGreen
                  : (isDark
                  ? NeoBrutalismTheme.darkSurface
                  : NeoBrutalismTheme.primaryWhite),
              offset: isSelected ? 3 : 2,
              borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: Text(
              type['label']!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected
                    ? NeoBrutalismTheme.primaryBlack
                    : (isDark ? Colors.grey[400] : Colors.grey[700]),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconSelector(RxString selectedIcon, bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: AccountController.accountIcons.map((item) {
        final isSelected = selectedIcon.value == item['icon'];
        return GestureDetector(
          onTap: () => selectedIcon.value = item['icon']!,
          child: Container(
            width: 48,
            height: 48,
            decoration: NeoBrutalismTheme.neoBox(
              color: isSelected
                  ? NeoBrutalismTheme.accentPurple
                  : (isDark
                  ? NeoBrutalismTheme.darkSurface
                  : NeoBrutalismTheme.primaryWhite),
              offset: isSelected ? 3 : 2,
              borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: Center(
              child: Text(
                item['icon'] as String,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorSelector(RxInt selectedColor, bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: AccountController.accountColors.map((color) {
        final isSelected = selectedColor.value == color.value;
        return GestureDetector(
          onTap: () => selectedColor.value = color.value,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: isSelected
                    ? NeoBrutalismTheme.primaryBlack
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                const BoxShadow(
                  color: NeoBrutalismTheme.primaryBlack,
                  offset: Offset(3, 3),
                ),
              ]
                  : [],
            ),
            child: isSelected
                ? const Icon(Icons.check,
                color: NeoBrutalismTheme.primaryBlack, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  void _saveAccount({
    AccountModel? editingAccount,
    required String name,
    required String bankName,
    required String accountType,
    required String balance,
    required String icon,
    required int color,
    required String description,
  }) {
    if (name.trim().isEmpty) {
      Get.snackbar('Error', 'Account name is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (bankName.trim().isEmpty) {
      Get.snackbar('Error', 'Bank/provider name is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final initialBalance = double.tryParse(balance) ?? 0.0;

    final account = AccountModel(
      id: editingAccount?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      bankName: bankName.trim(),
      accountType: accountType,
      color: color,
      icon: icon,
      initialBalance: initialBalance,
      isDefault: editingAccount?.isDefault ?? false,
      createdAt: editingAccount?.createdAt ?? DateTime.now(),
      description: description.trim().isEmpty ? null : description.trim(),
      isActive: true,
    );

    if (editingAccount != null) {
      controller.updateAccount(account);
    } else {
      controller.addAccount(account);
    }

    Navigator.of(Get.context!).pop();
  }
}