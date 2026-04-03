import 'dart:convert';

import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/account_model.dart';
import 'notification_service.dart';
import 'transaction_parser.dart';

/// Background SMS handler — MUST be a top-level function.
@pragma('vm:entry-point')
void onBackgroundMessage(SmsMessage message) {
  debugPrint('[SMS BG] From: ${message.address}, Body: ${message.body}');
}

class SmsTransactionService extends GetxService {
  final Telephony _telephony = Telephony.instance;
  final NotificationService _notificationService = NotificationService();

  final RxBool isListening = false.obs;
  final RxBool hasPermission = false.obs;
  final Rxn<TransactionParseResult> lastDetected = Rxn<TransactionParseResult>(null);
  final RxList<TransactionParseResult> pendingSuggestions = <TransactionParseResult>[].obs;
  final RxList<TransactionParseResult> history = <TransactionParseResult>[].obs;

  late Box _processedBox;

  @override
  void onInit() {
    super.onInit();
    _initProcessedBox();
  }

  Future<void> _initProcessedBox() async {
    if (!Hive.isBoxOpen('sms_processed')) {
      _processedBox = await Hive.openBox('sms_processed');
    } else {
      _processedBox = Hive.box('sms_processed');
    }
  }

  Future<bool> requestPermission() async {
    final granted = await _telephony.requestPhoneAndSmsPermissions ?? false;
    hasPermission.value = granted;
    if (granted) startListening();
    return granted;
  }

  void startListening() {
    if (isListening.value) return;
    if (!hasPermission.value) return;

    _telephony.listenIncomingSms(
      onNewMessage: _onSmsReceived,
      onBackgroundMessage: onBackgroundMessage,
      listenInBackground: true,
    );

    isListening.value = true;
    debugPrint('[SMS] Listening for bank transactions...');
  }

  void stopListening() {
    isListening.value = false;
  }

  void _onSmsReceived(SmsMessage message) {
    final body = message.body;
    if (body == null || body.isEmpty) return;

    final result = TransactionParser.parse(body);
    if (result == null) return;

    final fp = _fingerprint(result);
    if (_processedBox.containsKey(fp)) return;

    lastDetected.value = result;
    history.insert(0, result);
    if (history.length > 30) history.removeLast();

    final account = _matchAccount(result);
    _showNotification(result, account);
  }

  /// Scan recent SMS inbox for missed transactions (app was killed).
  /// Call from HomeController.onReady().
  Future<void> scanRecentSms({int hours = 24}) async {
    if (!hasPermission.value) {
      final granted = await requestPermission();
      if (!granted) return;
    }

    try {
      final cutoff = DateTime.now().subtract(Duration(hours: hours));

      final messages = await _telephony.getInboxSms(
        columns: [SmsColumn.BODY, SmsColumn.DATE, SmsColumn.ADDRESS],
        filter: SmsFilter.where(SmsColumn.DATE).greaterThan(
          cutoff.millisecondsSinceEpoch.toString(),
        ),
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
      );

      final newOnes = <TransactionParseResult>[];

      for (final msg in messages) {
        if (msg.body == null || msg.body!.isEmpty) continue;
        final result = TransactionParser.parse(msg.body!);
        if (result == null) continue;
        if (_processedBox.containsKey(_fingerprint(result))) continue;
        newOnes.add(result);
      }

      if (newOnes.isNotEmpty) {
        pendingSuggestions.value = newOnes;
        await _notificationService.showNotification(
          id: 999999,
          title: '📱 ${newOnes.length} missed transaction${newOnes.length == 1 ? '' : 's'}',
          body: 'Open Magic Ledger to review and add them',
        );
      }
    } catch (e) {
      debugPrint('[SMS Scan] Error: $e');
    }
  }

  void markProcessed(TransactionParseResult result) {
    _processedBox.put(_fingerprint(result), DateTime.now().millisecondsSinceEpoch);
    pendingSuggestions.remove(result);
  }

  void dismissSuggestion(TransactionParseResult result) => markProcessed(result);

  AccountModel? _matchAccount(TransactionParseResult result) {
    try {
      final accounts = Get.find<dynamic>().accounts as List<AccountModel>;

      if (result.accountLast4 != null) {
        for (final a in accounts) {
          final s = '${a.name} ${a.description ?? ''} ${a.bankName}';
          if (s.contains(result.accountLast4!)) return a;
        }
      }

      if (result.bankName != null) {
        for (final a in accounts) {
          if (a.bankName.toLowerCase().contains(result.bankName!.toLowerCase())) return a;
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _showNotification(TransactionParseResult result, AccountModel? account) async {
    final isIncome = result.isCredit;
    final emoji = isIncome ? '💰' : '💸';
    final amount = '₹${result.amount.toStringAsFixed(2)}';

    final title = '$emoji ${isIncome ? "Income" : "Expense"} Detected: $amount';

    final parts = <String>[];
    if (result.suggestedTitle.isNotEmpty) parts.add(result.suggestedTitle);
    if (account != null) parts.add('${account.icon} ${account.name}');
    if (result.bankName != null && account == null) parts.add(result.bankName!);
    parts.add('Tap to add to Magic Ledger');

    final payload = jsonEncode({
      'type': result.type,
      'amount': result.amount,
      'title': result.suggestedTitle,
      'description': result.suggestedDescription,
      'category': result.suggestedCategory,
      'accountId': account?.id,
      'bankName': result.bankName,
      'accountLast4': result.accountLast4,
      'merchant': result.merchant,
      'upiId': result.upiId,
      'refNumber': result.refNumber,
      'source': result.bankName ?? 'Bank Transfer',
    });

    await _notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: parts.join(' • '),
      payload: payload,
    );
  }

  static void handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type'] as String?;

      if (type == 'credit') {
        Get.toNamed('/add-income', arguments: {
          'prefill': true,
          'amount': data['amount'],
          'title': data['title'],
          'description': data['description'],
          'accountId': data['accountId'],
          'source': data['source'] ?? data['bankName'] ?? 'Bank Transfer',
        });
      } else if (type == 'debit') {
        Get.toNamed('/add-expense', arguments: {
          'prefill': true,
          'amount': data['amount'],
          'title': data['title'],
          'description': data['description'],
          'category': data['category'],
          'accountId': data['accountId'],
        });
      }

      try {
        final svc = Get.find<SmsTransactionService>();
        final fp = '${data['amount']}_${data['title']}_${data['refNumber'] ?? ''}';
        svc._processedBox.put(fp, DateTime.now().millisecondsSinceEpoch);
      } catch (_) {}
    } catch (e) {
      debugPrint('[SMS] Notification tap error: $e');
    }
  }

  String _fingerprint(TransactionParseResult r) {
    if (r.refNumber != null) return 'ref_${r.refNumber}';
    final d = DateTime.now();
    return '${r.amount}_${r.suggestedTitle}_${d.day}${d.month}';
  }

  TransactionParseResult? testParse(String message) => TransactionParser.parse(message);

  Future<void> clearProcessedHistory() async {
    await _processedBox.clear();
    pendingSuggestions.clear();
    history.clear();
  }
}