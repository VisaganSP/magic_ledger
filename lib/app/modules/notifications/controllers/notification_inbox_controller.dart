import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/expense_model.dart';
import '../../../data/models/income_model.dart';
import '../../../data/services/sms_transaction_service.dart';
import '../../../data/services/transaction_parser.dart';
import '../../account/controllers/account_controller.dart';
import '../../category/controllers/category_controller.dart';
import '../../expense/controllers/expense_controller.dart';
import '../../income/controllers/income_controller.dart';

class NotificationInboxController extends GetxController {
  late final SmsTransactionService smsService;
  late final AccountController accountController;

  final RxInt unreadCount = 0.obs;
  final RxBool isScanning = false.obs;
  final RxSet<String> _sessionDismissed = <String>{}.obs;
  final RxString activeFilter = 'all'.obs;
  final RxInt scanDepthDays = 30.obs;
  // Add these fields at the top (near unreadCount):
  final RxInt totalCreditsObs = 0.obs;
  final RxInt totalDebitsObs = 0.obs;
  final RxDouble totalCreditAmountObs = 0.0.obs;
  final RxDouble totalDebitAmountObs = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    smsService = Get.find<SmsTransactionService>();
    accountController = Get.find<AccountController>();
    ever(smsService.pendingSuggestions, (_) => _updateCount());
    ever(smsService.history, (_) => _updateCount());
    _updateCount();
  }

  void _updateCount() {
    final all = _allPending;
    unreadCount.value = pending.length;
    totalCreditsObs.value = all.where((r) => r.isCredit).length;
    totalDebitsObs.value = all.where((r) => !r.isCredit).length;
    totalCreditAmountObs.value = all.where((r) => r.isCredit).fold(0.0, (s, r) => s + r.amount);
    totalDebitAmountObs.value = all.where((r) => !r.isCredit).fold(0.0, (s, r) => s + r.amount);
  }

  String _resultKey(TransactionParseResult r) {
    return '${r.amount}_${r.suggestedTitle}_${r.refNumber ?? ''}_${r.accountLast4 ?? ''}';
  }

  DateTime _getDate(TransactionParseResult r) => r.date ?? DateTime.now();

  List<TransactionParseResult> get _allPending {
    return smsService.pendingSuggestions
        .where((r) => !_sessionDismissed.contains(_resultKey(r)))
        .toList();
  }

  List<TransactionParseResult> get pending {
    var list = _allPending;
    switch (activeFilter.value) {
      case 'today':
        final now = DateTime.now();
        list = list.where((r) {
          final d = _getDate(r);
          return d.year == now.year && d.month == now.month && d.day == now.day;
        }).toList();
        break;
      case 'week':
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        list = list.where((r) => _getDate(r).isAfter(weekAgo)).toList();
        break;
      case 'month':
        final now = DateTime.now();
        list = list.where((r) {
          final d = _getDate(r);
          return d.year == now.year && d.month == now.month;
        }).toList();
        break;
      case 'credits':
        list = list.where((r) => r.isCredit).toList();
        break;
      case 'debits':
        list = list.where((r) => !r.isCredit).toList();
        break;
    }
    list.sort((a, b) => _getDate(b).compareTo(_getDate(a)));
    return list;
  }

  List<TransactionParseResult> get history {
    final list = smsService.history.toList();
    list.sort((a, b) => _getDate(b).compareTo(_getDate(a)));
    return list;
  }

  String getDateGroup(TransactionParseResult r) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = _getDate(r);
    final dateOnly = DateTime(d.year, d.month, d.day);
    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) return 'TODAY';
    if (diff == 1) return 'YESTERDAY';
    if (diff < 7) return 'THIS WEEK';
    if (d.year == now.year && d.month == now.month) return 'THIS MONTH';

    const months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
    if (d.year == now.year) return months[d.month - 1];
    return '${months[d.month - 1]} ${d.year}';
  }

  Map<String, List<TransactionParseResult>> get groupedPending {
    final groups = <String, List<TransactionParseResult>>{};
    for (final r in pending) {
      final group = getDateGroup(r);
      groups.putIfAbsent(group, () => []).add(r);
    }
    return groups;
  }

  int get totalCredits => _allPending.where((r) => r.isCredit).length;
  int get totalDebits => _allPending.where((r) => !r.isCredit).length;
  double get totalCreditAmount => _allPending.where((r) => r.isCredit).fold(0.0, (s, r) => s + r.amount);
  double get totalDebitAmount => _allPending.where((r) => !r.isCredit).fold(0.0, (s, r) => s + r.amount);

  String? _matchAccount(TransactionParseResult result) {
    try {
      if (result.accountLast4 != null) {
        for (final a in accountController.accounts) {
          final s = '${a.name} ${a.description ?? ''} ${a.bankName}';
          if (s.contains(result.accountLast4!)) return a.id;
        }
      }
      if (result.bankName != null) {
        for (final a in accountController.accounts) {
          if (a.bankName.toLowerCase().contains(result.bankName!.toLowerCase())) return a.id;
        }
      }
    } catch (_) {}
    return null;
  }

  void addTransaction(TransactionParseResult result) {
    final accountId = _matchAccount(result);
    try {
      if (result.isCredit) {
        final incCtrl = Get.find<IncomeController>();
        final income = IncomeModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: result.suggestedTitle,
          amount: result.amount,
          date: _getDate(result),
          source: result.bankName ?? 'Bank Transfer',
          description: result.suggestedDescription,
          accountId: accountId,
        );
        incCtrl.addIncome(income);
        if (accountId != null) accountController.adjustBalance(accountId, result.amount);
        Get.snackbar('✅ Income Added', '+₹${result.amount.toStringAsFixed(0)} • ${result.suggestedTitle}',
            snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2),
            backgroundColor: Colors.green[100], colorText: Colors.green[900],
            borderWidth: 2, borderColor: Colors.green[700]!, margin: const EdgeInsets.all(12));
      } else {
        final expCtrl = Get.find<ExpenseController>();
        final catCtrl = Get.find<CategoryController>();
        String? categoryId;
        if (result.suggestedCategory != null) {
          try {
            final cat = catCtrl.categories.firstWhere(
                    (c) => c.name.toLowerCase() == result.suggestedCategory!.toLowerCase());
            categoryId = cat.id;
          } catch (_) {
            if (catCtrl.categories.isNotEmpty) categoryId = catCtrl.categories.first.id;
          }
        }
        categoryId ??= catCtrl.categories.isNotEmpty ? catCtrl.categories.first.id : 'uncategorized';
        final expense = ExpenseModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: result.suggestedTitle,
          amount: result.amount,
          date: _getDate(result),
          categoryId: categoryId,
          description: result.suggestedDescription,
          accountId: accountId,
        );
        expCtrl.addExpense(expense);
        if (accountId != null) accountController.adjustBalance(accountId, -result.amount);
        Get.snackbar('✅ Expense Added', '-₹${result.amount.toStringAsFixed(0)} • ${result.suggestedTitle}',
            snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange[100], colorText: Colors.orange[900],
            borderWidth: 2, borderColor: Colors.orange[700]!, margin: const EdgeInsets.all(12));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add: $e', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100], colorText: Colors.red[900]);
    }
    smsService.markProcessed(result);
    _updateCount();
  }

  void editAndAdd(TransactionParseResult result) {
    final accountId = _matchAccount(result);
    _sessionDismissed.add(_resultKey(result));
    _updateCount();
    if (result.isCredit) {
      Get.toNamed('/add-income', arguments: {
        'prefill': true, 'amount': result.amount, 'title': result.suggestedTitle,
        'description': result.suggestedDescription, 'accountId': accountId,
        'source': result.bankName ?? 'Bank Transfer',
      });
    } else {
      Get.toNamed('/add-expense', arguments: {
        'prefill': true, 'amount': result.amount, 'title': result.suggestedTitle,
        'description': result.suggestedDescription, 'category': result.suggestedCategory,
        'accountId': accountId,
      });
    }
  }

  void dismiss(TransactionParseResult result) {
    _sessionDismissed.add(_resultKey(result));
    _updateCount();
  }

  void dismissAll() {
    for (final r in smsService.pendingSuggestions) _sessionDismissed.add(_resultKey(r));
    _updateCount();
  }

  Future<void> clearHistory() async => await smsService.clearProcessedHistory();

  Future<void> rescan({int? days}) async {
    isScanning.value = true;
    _sessionDismissed.clear();
    await smsService.scanRecentSms(hours: (days ?? scanDepthDays.value) * 24);
    isScanning.value = false;
    _updateCount();
  }

  Future<void> scanLast7Days() async { scanDepthDays.value = 7; await rescan(days: 7); }
  Future<void> scanLast30Days() async { scanDepthDays.value = 30; await rescan(days: 30); }
  Future<void> scanLast90Days() async { scanDepthDays.value = 90; await rescan(days: 90); }
  Future<void> scanAllTime() async { scanDepthDays.value = 365; await rescan(days: 365); }

  void setFilter(String filter) => activeFilter.value = filter;
}