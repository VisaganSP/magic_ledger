import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../data/models/account_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/income_model.dart';
import '../../../data/models/transfer_model.dart';
import '../../../data/services/notification_service.dart';

class AccountController extends GetxController {
  final Box<AccountModel> _accountBox = Hive.box('accounts');
  final Box<TransferModel> _transferBox = Hive.box('transfers');

  final RxList<AccountModel> accounts = <AccountModel>[].obs;
  final RxList<TransferModel> transfers = <TransferModel>[].obs;
  final NotificationService _notificationService = NotificationService();

  // Currently selected account for filtering (null = all accounts)
  final Rxn<String> selectedAccountId = Rxn<String>(null);

  // Loading state
  final RxBool isLoading = false.obs;

  // Default accounts to initialize on first run
  final List<Map<String, dynamic>> defaultAccounts = [
    {
      'name': 'Cash',
      'bankName': 'Cash',
      'accountType': 'cash',
      'color': Color(0xFFB8E994).value, // Mint green
      'icon': '💵',
      'isDefault': true,
    },
  ];

  @override
  void onInit() {
    super.onInit();
    loadAccounts();
    loadTransfers();

    if (accounts.isEmpty) {
      initializeDefaultAccounts();
    }
  }

  // ─── ACCOUNT CRUD ────────────────────────────────────────

  void loadAccounts() {
    try {
      isLoading.value = true;
      accounts.value = _accountBox.values.where((a) => a.isActive).toList()
        ..sort((a, b) {
          // Default accounts first, then by name
          if (a.isDefault && !b.isDefault) return -1;
          if (!a.isDefault && b.isDefault) return 1;
          return a.name.compareTo(b.name);
        });
    } catch (e) {
      print('Error loading accounts: $e');
      accounts.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void initializeDefaultAccounts() {
    try {
      for (var acc in defaultAccounts) {
        final account = AccountModel(
          id: 'default_${acc['name'].toString().toLowerCase()}',
          name: acc['name'],
          bankName: acc['bankName'],
          accountType: acc['accountType'],
          color: acc['color'],
          icon: acc['icon'],
          isDefault: acc['isDefault'] ?? false,
          createdAt: DateTime.now(),
        );
        _accountBox.put(account.id, account);
      }
      loadAccounts();
    } catch (e) {
      print('Error initializing default accounts: $e');
    }
  }

  Future<void> addAccount(AccountModel account) async {
    try {
      await _accountBox.put(account.id, account);
      loadAccounts();

      await _notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Account Added',
        body: '${account.name} has been added',
      );
    } catch (e) {
      print('Error adding account: $e');
      Get.snackbar('Error', 'Failed to add account. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateAccount(AccountModel account) async {
    try {
      await _accountBox.put(account.id, account);
      loadAccounts();
    } catch (e) {
      print('Error updating account: $e');
      Get.snackbar('Error', 'Failed to update account.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteAccount(String id) async {
    try {
      final account = _accountBox.get(id);
      if (account == null) return;

      if (account.isDefault) {
        Get.snackbar('Cannot Delete', 'Default accounts cannot be deleted.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Soft delete — mark inactive
      final updated = AccountModel(
        id: account.id,
        name: account.name,
        bankName: account.bankName,
        accountType: account.accountType,
        color: account.color,
        icon: account.icon,
        initialBalance: account.initialBalance,
        isDefault: account.isDefault,
        createdAt: account.createdAt,
        description: account.description,
        isActive: false,
      );
      await _accountBox.put(id, updated);
      loadAccounts();

      // Clear selection if deleted account was selected
      if (selectedAccountId.value == id) {
        selectedAccountId.value = null;
      }
    } catch (e) {
      print('Error deleting account: $e');
      Get.snackbar('Error', 'Failed to delete account.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ─── TRANSFER CRUD ───────────────────────────────────────

  void loadTransfers() {
    try {
      transfers.value = _transferBox.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      print('Error loading transfers: $e');
      transfers.value = [];
    }
  }

  Future<void> addTransfer(TransferModel transfer) async {
    try {
      await _transferBox.put(transfer.id, transfer);
      loadTransfers();

      final fromAccount = getAccountById(transfer.fromAccountId);
      final toAccount = getAccountById(transfer.toAccountId);

      await _notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Transfer Complete',
        body:
        '₹${transfer.amount.toStringAsFixed(2)} from ${fromAccount?.name ?? "Unknown"} to ${toAccount?.name ?? "Unknown"}',
      );
    } catch (e) {
      print('Error adding transfer: $e');
      Get.snackbar('Error', 'Failed to add transfer.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteTransfer(String id) async {
    try {
      await _transferBox.delete(id);
      loadTransfers();
    } catch (e) {
      print('Error deleting transfer: $e');
    }
  }

  // ─── BALANCE CALCULATIONS ────────────────────────────────

  /// Calculate the current balance of an account:
  /// initialBalance + all incomes - all expenses - transfersOut + transfersIn
  double getAccountBalance(String accountId) {
    try {
      final account = getAccountById(accountId);
      if (account == null) return 0.0;

      final Box<ExpenseModel> expenseBox = Hive.box('expenses');
      final Box<IncomeModel> incomeBox = Hive.box('income');

      double balance = account.initialBalance;

      // Add incomes to this account
      for (var income in incomeBox.values) {
        if (income.accountId == accountId) {
          balance += income.amount;
        }
      }

      // Subtract expenses from this account
      for (var expense in expenseBox.values) {
        if (expense.accountId == accountId) {
          balance -= expense.amount;
        }
      }

      // Add incoming transfers
      for (var transfer in transfers) {
        if (transfer.toAccountId == accountId) {
          balance += transfer.amount;
        }
      }

      // Subtract outgoing transfers
      for (var transfer in transfers) {
        if (transfer.fromAccountId == accountId) {
          balance -= transfer.amount;
        }
      }

      return balance;
    } catch (e) {
      print('Error calculating account balance: $e');
      return 0.0;
    }
  }

  /// Total balance across all active accounts
  double getTotalBalance() {
    double total = 0.0;
    for (var account in accounts) {
      total += getAccountBalance(account.id);
    }
    return total;
  }

  /// Get balance for a specific month/year
  double getAccountBalanceForPeriod(
      String accountId, int year, int month) {
    try {
      final account = getAccountById(accountId);
      if (account == null) return 0.0;

      final periodEnd = DateTime(year, month + 1, 0, 23, 59, 59);

      final Box<ExpenseModel> expenseBox = Hive.box('expenses');
      final Box<IncomeModel> incomeBox = Hive.box('income');

      double balance = account.initialBalance;

      // Add incomes up to period end
      for (var income in incomeBox.values) {
        if (income.accountId == accountId &&
            !income.date.isAfter(periodEnd)) {
          balance += income.amount;
        }
      }

      // Subtract expenses up to period end
      for (var expense in expenseBox.values) {
        if (expense.accountId == accountId &&
            !expense.date.isAfter(periodEnd)) {
          balance -= expense.amount;
        }
      }

      // Transfers up to period end
      for (var transfer in transfers) {
        if (!transfer.date.isAfter(periodEnd)) {
          if (transfer.toAccountId == accountId) {
            balance += transfer.amount;
          }
          if (transfer.fromAccountId == accountId) {
            balance -= transfer.amount;
          }
        }
      }

      return balance;
    } catch (e) {
      print('Error calculating period balance: $e');
      return 0.0;
    }
  }

  // ─── QUERIES ─────────────────────────────────────────────

  AccountModel? getAccountById(String id) {
    try {
      return _accountBox.get(id);
    } catch (e) {
      return null;
    }
  }

  AccountModel? getDefaultAccount() {
    try {
      return accounts.firstWhere((a) => a.isDefault);
    } catch (e) {
      return accounts.isNotEmpty ? accounts.first : null;
    }
  }

  /// Get account with fallback for UI safety
  AccountModel getAccountForDisplay(String? accountId) {
    if (accountId == null) {
      return getDefaultAccount() ??
          AccountModel(
            id: 'unknown',
            name: 'Unassigned',
            bankName: '',
            accountType: 'cash',
            color: Colors.grey.value,
            icon: '💰',
            createdAt: DateTime.now(),
          );
    }

    return getAccountById(accountId) ??
        AccountModel(
          id: 'unknown',
          name: 'Deleted Account',
          bankName: '',
          accountType: 'cash',
          color: Colors.grey.value,
          icon: '💰',
          createdAt: DateTime.now(),
        );
  }

  bool accountExists(String id) {
    return accounts.any((a) => a.id == id);
  }

  /// Select an account for filtering (null = all accounts)
  void selectAccount(String? accountId) {
    selectedAccountId.value = accountId;
  }

  /// Get transfers for a specific account
  List<TransferModel> getTransfersForAccount(String accountId) {
    return transfers
        .where((t) =>
    t.fromAccountId == accountId || t.toAccountId == accountId)
        .toList();
  }

  /// Get transfers within a date range
  List<TransferModel> getTransfersByDateRange(DateTime start, DateTime end) {
    return transfers
        .where((t) =>
    t.date.isAfter(start.subtract(const Duration(days: 1))) &&
        t.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  // ─── ACCOUNT TYPE HELPERS ────────────────────────────────

  static List<Map<String, String>> get accountTypes => [
    {'value': 'savings', 'label': 'Savings Account'},
    {'value': 'current', 'label': 'Current Account'},
    {'value': 'cash', 'label': 'Cash'},
    {'value': 'wallet', 'label': 'Digital Wallet'},
    {'value': 'upi', 'label': 'UPI Account'},
    {'value': 'credit', 'label': 'Credit Card'},
  ];

  static List<Map<String, dynamic>> get accountIcons => [
    {'icon': '🏦', 'label': 'Bank'},
    {'icon': '💵', 'label': 'Cash'},
    {'icon': '💳', 'label': 'Card'},
    {'icon': '📱', 'label': 'UPI/Mobile'},
    {'icon': '🪙', 'label': 'Savings'},
    {'icon': '👛', 'label': 'Wallet'},
    {'icon': '💰', 'label': 'General'},
    {'icon': '🏠', 'label': 'Home'},
  ];

  static List<Color> get accountColors => [
    const Color(0xFFB8E994), // Mint green
    const Color(0xFF9DB4FF), // Periwinkle
    const Color(0xFFFDB5D6), // Pink
    const Color(0xFFFDD663), // Yellow
    const Color(0xFFFFB49A), // Peach
    const Color(0xFFE8CCFF), // Lavender
    const Color(0xFFBFE3F0), // Sky blue
    const Color(0xFFD4E4D1), // Sage
    const Color(0xFFF5E6D3), // Beige
    const Color(0xFF4DB6AC), // Teal
  ];
}