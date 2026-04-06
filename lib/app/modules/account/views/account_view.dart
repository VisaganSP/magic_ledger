import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/account_model.dart';
import '../../../data/models/transfer_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../controllers/account_controller.dart';

class AccountView extends GetView<AccountController> {
  const AccountView({super.key});

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
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.accounts.isEmpty) {
                return _buildEmptyState(isDark);
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTotalBalanceCard(isDark),
                  const SizedBox(height: 24),
                  Text(
                    'YOUR ACCOUNTS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...controller.accounts.asMap().entries.map(
                        (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildAccountCard(entry.value, isDark)
                          .animate()
                          .fadeIn(delay: (100 * entry.key).ms)
                          .slideX(begin: 0.1, end: 0),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: NeoBrutalismTheme.neoBox(
          color: NeoBrutalismTheme.accentGreen,
          offset: 4,
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: FloatingActionButton(
          onPressed: () => Get.toNamed('/add-account'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.add,
            color: NeoBrutalismTheme.primaryBlack,
            size: 28,
          ),
        ),
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
            'ACCOUNTS',
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

  Widget _buildTotalBalanceCard(bool isDark) {
    return Obx(() {
      final total = controller.getTotalBalance();

      return NeoCard(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : NeoBrutalismTheme.accentSage,
        borderColor: NeoBrutalismTheme.primaryBlack,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'TOTAL BALANCE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.grey[400] : Colors.black54,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '₹${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.primaryBlack,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${controller.accounts.length} account${controller.accounts.length == 1 ? '' : 's'}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildAccountCard(AccountModel account, bool isDark) {
    final balance = controller.getAccountBalance(account.id);

    return NeoCard(
      onTap: () => _showAccountOptions(account, isDark),
      color: isDark ? NeoBrutalismTheme.darkSurface : account.colorValue,
      borderColor: NeoBrutalismTheme.primaryBlack,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: NeoBrutalismTheme.neoBox(
              color: isDark
                  ? NeoBrutalismTheme.darkBackground
                  : NeoBrutalismTheme.primaryWhite,
              offset: 3,
              borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: Center(
              child: Text(account.icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        account.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: NeoBrutalismTheme.primaryBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (account.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: NeoBrutalismTheme.primaryBlack,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'DEFAULT',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: NeoBrutalismTheme.primaryWhite,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${account.bankName} • ${account.accountTypeLabel}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${_formatAmount(balance)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: balance >= 0 ? Colors.green[800] : Colors.red[700],
                ),
              ),
              Text(
                'Balance',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount.abs() >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount.abs() >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount.abs() >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(2);
  }

  void _showAccountOptions(AccountModel account, bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: const Border(
            top: BorderSide(
              color: NeoBrutalismTheme.primaryBlack,
              width: 3,
            ),
            left: BorderSide(
              color: NeoBrutalismTheme.primaryBlack,
              width: 3,
            ),
            right: BorderSide(
              color: NeoBrutalismTheme.primaryBlack,
              width: 3,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              account.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isDark
                    ? NeoBrutalismTheme.darkText
                    : NeoBrutalismTheme.primaryBlack,
              ),
            ),
            const SizedBox(height: 24),
            NeoButton(
              text: 'EDIT ACCOUNT',
              onPressed: () {
                Navigator.of(Get.context!).pop();
                Get.toNamed('/add-account', arguments: account);
              },
              color: NeoBrutalismTheme.accentSkyBlue,
              icon: Icons.edit,
            ),
            const SizedBox(height: 12),
            NeoButton(
              text: 'SET AS DEFAULT',
              onPressed: () {
                _setAsDefault(account);
                Navigator.of(Get.context!).pop();
              },
              color: NeoBrutalismTheme.accentGreen,
              icon: Icons.star,
            ),
            const SizedBox(height: 12),
            NeoButton(
              text: 'TRANSFER MONEY',
              onPressed: () {
                Navigator.of(Get.context!).pop();
                _showTransferDialog(account, isDark);
              },
              color: NeoBrutalismTheme.accentPurple,
              icon: Icons.swap_horiz,
            ),
            if (!account.isDefault) ...[
              const SizedBox(height: 12),
              NeoButton(
                text: 'DELETE ACCOUNT',
                onPressed: () {
                  Navigator.of(Get.context!).pop();
                  _confirmDelete(account, isDark);
                },
                color: NeoBrutalismTheme.accentPink,
                icon: Icons.delete,
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _setAsDefault(AccountModel account) {
    // Remove default from all other accounts
    for (var acc in controller.accounts) {
      if (acc.isDefault && acc.id != account.id) {
        final updated = AccountModel(
          id: acc.id,
          name: acc.name,
          bankName: acc.bankName,
          accountType: acc.accountType,
          color: acc.color,
          icon: acc.icon,
          initialBalance: acc.initialBalance,
          isDefault: false,
          createdAt: acc.createdAt,
          description: acc.description,
          isActive: acc.isActive,
        );
        controller.updateAccount(updated);
      }
    }

    // Set this one as default
    final updated = AccountModel(
      id: account.id,
      name: account.name,
      bankName: account.bankName,
      accountType: account.accountType,
      color: account.color,
      icon: account.icon,
      initialBalance: account.initialBalance,
      isDefault: true,
      createdAt: account.createdAt,
      description: account.description,
      isActive: account.isActive,
    );
    controller.updateAccount(updated);

    Get.snackbar('Done', '${account.name} is now your default account',
        snackPosition: SnackPosition.BOTTOM);
  }

  void _confirmDelete(AccountModel account, bool isDark) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
              color: NeoBrutalismTheme.primaryBlack, width: 3),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? NeoBrutalismTheme.darkSurface
                : NeoBrutalismTheme.primaryWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                'Delete ${account.name}?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Existing transactions will remain but show as "Deleted Account". This action cannot be undone.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      text: 'CANCEL',
                      onPressed: () => Navigator.of(Get.context!).pop(),
                      color: NeoBrutalismTheme.primaryWhite,
                      textColor: NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      text: 'DELETE',
                      onPressed: () {
                        controller.deleteAccount(account.id);
                        Navigator.of(Get.context!).pop();
                      },
                      color: Colors.red[400]!,
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

  void _showTransferDialog(AccountModel fromAccount, bool isDark) {
    final otherAccounts =
    controller.accounts.where((a) => a.id != fromAccount.id).toList();

    if (otherAccounts.isEmpty) {
      Get.snackbar('No Accounts',
          'You need at least 2 accounts to make a transfer.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final amountController = TextEditingController();
    final descController = TextEditingController();
    final selectedTo = otherAccounts.first.id.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
              color: NeoBrutalismTheme.primaryBlack, width: 3),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? NeoBrutalismTheme.darkSurface
                : NeoBrutalismTheme.primaryWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRANSFER FROM ${fromAccount.name.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'To Account',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: NeoBrutalismTheme.primaryBlack, width: 2),
                    color: isDark
                        ? NeoBrutalismTheme.darkBackground
                        : NeoBrutalismTheme.primaryWhite,
                  ),
                  child: DropdownButton<String>(
                    value: selectedTo.value,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: otherAccounts.map((a) {
                      return DropdownMenuItem(
                        value: a.id,
                        child: Text('${a.icon} ${a.name}'),
                      );
                    }).toList(),
                    onChanged: (v) => selectedTo.value = v!,
                  ),
                )),
                const SizedBox(height: 16),
                Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: NeoBrutalismTheme.primaryBlack, width: 2),
                      borderRadius: BorderRadius.zero,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: NeoBrutalismTheme.primaryBlack, width: 2),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    hintText: 'Description (optional)',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: NeoBrutalismTheme.primaryBlack, width: 2),
                      borderRadius: BorderRadius.zero,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: NeoBrutalismTheme.primaryBlack, width: 2),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: NeoButton(
                        text: 'CANCEL',
                        onPressed: () => Navigator.of(Get.context!).pop(),
                        color: NeoBrutalismTheme.primaryWhite,
                        textColor: NeoBrutalismTheme.primaryBlack,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeoButton(
                        text: 'TRANSFER',
                        onPressed: () {
                          final amount =
                          double.tryParse(amountController.text);
                          if (amount == null || amount <= 0) {
                            Get.snackbar('Error', 'Enter a valid amount',
                                snackPosition: SnackPosition.BOTTOM);
                            return;
                          }

                          final transfer = TransferModel(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            fromAccountId: fromAccount.id,
                            toAccountId: selectedTo.value,
                            amount: amount,
                            date: DateTime.now(),
                            description: descController.text.isEmpty
                                ? null
                                : descController.text,
                            createdAt: DateTime.now(),
                          );

                          controller.addTransfer(transfer);
                          Navigator.of(Get.context!).pop();
                        },
                        color: NeoBrutalismTheme.accentGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No accounts yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your bank accounts to track money across them',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[600] : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            NeoButton(
              text: 'ADD ACCOUNT',
              onPressed: () => Get.toNamed('/add-account'),
              color: NeoBrutalismTheme.accentGreen,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }
}