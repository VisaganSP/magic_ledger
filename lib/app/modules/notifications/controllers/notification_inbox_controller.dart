import 'package:get/get.dart';

import '../../../data/services/sms_transaction_service.dart';
import '../../../data/services/transaction_parser.dart';
import '../../account/controllers/account_controller.dart';

class NotificationInboxController extends GetxController {
  late final SmsTransactionService smsService;
  late final AccountController accountController;

  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    smsService = Get.find<SmsTransactionService>();
    accountController = Get.find<AccountController>();

    // Keep unread count in sync
    ever(smsService.pendingSuggestions, (_) => _updateCount());
    ever(smsService.history, (_) => _updateCount());
    _updateCount();
  }

  void _updateCount() {
    unreadCount.value = smsService.pendingSuggestions.length;
  }

  /// Get pending suggestions (not yet added/dismissed)
  List<TransactionParseResult> get pending => smsService.pendingSuggestions;

  /// Get history (already shown, may or may not be added)
  List<TransactionParseResult> get history => smsService.history;

  /// Navigate to add-expense or add-income with pre-filled data
  void addTransaction(TransactionParseResult result) {
    // Match account
    String? accountId;
    try {
      if (result.accountLast4 != null) {
        for (final a in accountController.accounts) {
          final s = '${a.name} ${a.description ?? ''} ${a.bankName}';
          if (s.contains(result.accountLast4!)) {
            accountId = a.id;
            break;
          }
        }
      }
      if (accountId == null && result.bankName != null) {
        for (final a in accountController.accounts) {
          if (a.bankName.toLowerCase().contains(result.bankName!.toLowerCase())) {
            accountId = a.id;
            break;
          }
        }
      }
    } catch (_) {}

    if (result.isCredit) {
      Get.toNamed('/add-income', arguments: {
        'prefill': true,
        'amount': result.amount,
        'title': result.suggestedTitle,
        'description': result.suggestedDescription,
        'accountId': accountId,
        'source': result.bankName ?? 'Bank Transfer',
      });
    } else {
      Get.toNamed('/add-expense', arguments: {
        'prefill': true,
        'amount': result.amount,
        'title': result.suggestedTitle,
        'description': result.suggestedDescription,
        'category': result.suggestedCategory,
        'accountId': accountId,
      });
    }

    // Mark as processed
    smsService.markProcessed(result);
  }

  /// Dismiss without adding
  void dismiss(TransactionParseResult result) {
    smsService.dismissSuggestion(result);
  }

  /// Dismiss all pending
  void dismissAll() {
    final all = List<TransactionParseResult>.from(smsService.pendingSuggestions);
    for (final r in all) {
      smsService.dismissSuggestion(r);
    }
  }

  /// Clear entire history
  Future<void> clearHistory() async {
    await smsService.clearProcessedHistory();
  }

  /// Trigger a manual scan
  Future<void> rescan() async {
    await smsService.scanRecentSms(hours: 48);
  }
}