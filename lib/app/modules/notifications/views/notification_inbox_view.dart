import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/services/sms_transaction_service.dart';
import '../../../data/services/transaction_parser.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../controllers/notification_inbox_controller.dart';

class NotificationInboxView extends GetView<NotificationInboxController> {
  const NotificationInboxView({super.key});

  Color _t(Color c, bool d) => NeoBrutalismTheme.getThemedColor(c, d);

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
              final pending = controller.pending;
              final history = controller.history;

              if (pending.isEmpty && history.isEmpty) {
                return _buildEmptyState(isDark);
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                children: [
                  // ── Pending section ──
                  if (pending.isNotEmpty) ...[
                    _buildSectionHeader(
                      'PENDING',
                      '${pending.length} to review',
                      NeoBrutalismTheme.accentOrange,
                      isDark,
                      showAction: true,
                      actionLabel: 'DISMISS ALL',
                      onAction: () => _showDismissAllDialog(isDark),
                    ),
                    const SizedBox(height: 10),
                    ...pending.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildPendingCard(entry.value, isDark)
                            .animate()
                            .fadeIn(delay: (100 + entry.key * 60).ms)
                            .slideX(begin: 0.05, end: 0),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],

                  // ── Scan button ──
                  _buildScanButton(isDark),
                  const SizedBox(height: 20),

                  // ── History section ──
                  if (history.isNotEmpty) ...[
                    _buildSectionHeader(
                      'RECENT DETECTIONS',
                      '${history.length} found',
                      NeoBrutalismTheme.accentPurple,
                      isDark,
                      showAction: history.isNotEmpty,
                      actionLabel: 'CLEAR',
                      onAction: () => _showClearHistoryDialog(isDark),
                    ),
                    const SizedBox(height: 10),
                    ...history.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildHistoryCard(entry.value, isDark)
                            .animate()
                            .fadeIn(delay: (200 + entry.key * 40).ms),
                      );
                    }),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 14,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : _t(NeoBrutalismTheme.accentSkyBlue, isDark),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOTIFICATIONS',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
                  ),
                ),
                Obx(() {
                  final sms = Get.find<SmsTransactionService>();
                  return Text(
                    sms.isListening.value
                        ? 'SMS detection active'
                        : 'SMS detection off',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: sms.isListening.value
                          ? (isDark ? Colors.green[400] : Colors.green[700])
                          : (isDark ? Colors.grey[500] : Colors.grey[600]),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Refresh button
          GestureDetector(
            onTap: () async {
              Get.snackbar(
                'Scanning...',
                'Checking SMS inbox for transactions',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
                backgroundColor: _t(NeoBrutalismTheme.accentSkyBlue, isDark),
                colorText: NeoBrutalismTheme.primaryBlack,
                borderWidth: 2,
                borderColor: NeoBrutalismTheme.primaryBlack,
              );
              await controller.rescan();
            },
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
                Icons.refresh,
                color: isDark
                    ? NeoBrutalismTheme.darkText
                    : NeoBrutalismTheme.primaryBlack,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  // ═══════════════════════════════════════════════════════════
  // SECTION HEADER
  // ═══════════════════════════════════════════════════════════

  Widget _buildSectionHeader(
      String title,
      String subtitle,
      Color accentColor,
      bool isDark, {
        bool showAction = false,
        String? actionLabel,
        VoidCallback? onAction,
      }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: _t(accentColor, isDark),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark
                    ? NeoBrutalismTheme.darkText
                    : NeoBrutalismTheme.primaryBlack,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
          ],
        ),
        const Spacer(),
        if (showAction && actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: NeoBrutalismTheme.primaryBlack,
                  width: 1.5,
                ),
              ),
              child: Text(
                actionLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PENDING CARD — main actionable card
  // ═══════════════════════════════════════════════════════════

  Widget _buildPendingCard(TransactionParseResult result, bool isDark) {
    final isIncome = result.isCredit;
    final accentColor = isIncome
        ? _t(NeoBrutalismTheme.accentGreen, isDark)
        : _t(NeoBrutalismTheme.accentOrange, isDark);
    final typeLabel = isIncome ? 'INCOME' : 'EXPENSE';
    final typeEmoji = isIncome ? '💰' : '💸';

    return Dismissible(
      key: Key('pending_${result.refNumber ?? result.amount}_${result.suggestedTitle}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => controller.dismiss(result),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          border: Border.all(
            color: NeoBrutalismTheme.primaryBlack,
            width: 2,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.close, color: Colors.white, size: 24),
            SizedBox(height: 2),
            Text('DISMISS',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
          ],
        ),
      ),
      child: NeoCard(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : NeoBrutalismTheme.primaryWhite,
        borderColor: NeoBrutalismTheme.primaryBlack,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // ── Top accent strip ──
            Container(
              height: 4,
              color: accentColor,
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Type badge + amount ──
                  Row(
                    children: [
                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accentColor,
                          border: Border.all(
                            color: NeoBrutalismTheme.primaryBlack,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          '$typeEmoji $typeLabel',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: NeoBrutalismTheme.primaryBlack,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Bank badge
                      if (result.bankName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? NeoBrutalismTheme.darkBackground
                                : Colors.grey[100],
                            border: Border.all(
                              color: NeoBrutalismTheme.primaryBlack,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            result.bankName!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? NeoBrutalismTheme.darkText
                                  : NeoBrutalismTheme.primaryBlack,
                            ),
                          ),
                        ),
                      const Spacer(),
                      // Amount
                      Text(
                        '${isIncome ? '+' : '-'}₹${result.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isIncome
                              ? (isDark ? Colors.green[400] : Colors.green[700])
                              : (isDark ? Colors.red[400] : Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Title ──
                  Text(
                    result.suggestedTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // ── Details row ──
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (result.accountLast4 != null)
                        _buildDetailChip(
                            'A/c •••${result.accountLast4}', isDark),
                      if (result.suggestedCategory != null)
                        _buildDetailChip(result.suggestedCategory!, isDark),
                      if (result.upiId != null)
                        _buildDetailChip('UPI', isDark),
                      if (result.refNumber != null)
                        _buildDetailChip(
                            'Ref: ${result.refNumber!.length > 10 ? '${result.refNumber!.substring(0, 10)}...' : result.refNumber!}',
                            isDark),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Action buttons ──
                  Row(
                    children: [
                      // ADD button — primary action
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTap: () => controller.addTransaction(result),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: NeoBrutalismTheme.neoBox(
                              color: accentColor,
                              offset: 3,
                              borderColor: NeoBrutalismTheme.primaryBlack,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_circle,
                                    size: 18,
                                    color: NeoBrutalismTheme.primaryBlack),
                                const SizedBox(width: 6),
                                Text(
                                  isIncome ? 'ADD AS INCOME' : 'ADD AS EXPENSE',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: NeoBrutalismTheme.primaryBlack,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // DISMISS button
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => controller.dismiss(result),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: NeoBrutalismTheme.neoBox(
                              color: isDark
                                  ? NeoBrutalismTheme.darkBackground
                                  : Colors.grey[100]!,
                              offset: 2,
                              borderColor: NeoBrutalismTheme.primaryBlack,
                            ),
                            child: const Icon(Icons.close,
                                size: 18,
                                color: NeoBrutalismTheme.primaryBlack),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.grey[400] : Colors.grey[700],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HISTORY CARD — compact, non-actionable
  // ═══════════════════════════════════════════════════════════

  Widget _buildHistoryCard(TransactionParseResult result, bool isDark) {
    final isIncome = result.isCredit;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : NeoBrutalismTheme.primaryWhite,
        border: Border.all(
          color: NeoBrutalismTheme.primaryBlack,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isIncome
                  ? _t(NeoBrutalismTheme.accentGreen, isDark)
                  : _t(NeoBrutalismTheme.accentOrange, isDark),
              border: Border.all(
                color: NeoBrutalismTheme.primaryBlack,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                size: 18,
                color: NeoBrutalismTheme.primaryBlack,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.suggestedTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    result.bankName,
                    if (result.accountLast4 != null) '•••${result.accountLast4}',
                    result.suggestedCategory,
                  ].whereType<String>().join(' • '),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Amount
          Text(
            '${isIncome ? '+' : '-'}₹${result.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isIncome
                  ? (isDark ? Colors.green[400] : Colors.green[700])
                  : (isDark ? Colors.red[400] : Colors.red[700]),
            ),
          ),
          const SizedBox(width: 8),
          // Re-add button
          GestureDetector(
            onTap: () => controller.addTransaction(result),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: NeoBrutalismTheme.primaryBlack,
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.add,
                  size: 16, color: NeoBrutalismTheme.primaryBlack),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SCAN BUTTON
  // ═══════════════════════════════════════════════════════════

  Widget _buildScanButton(bool isDark) {
    return GestureDetector(
      onTap: () async {
        Get.snackbar(
          'Scanning SMS...',
          'Looking for bank transactions in last 48 hours',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: _t(NeoBrutalismTheme.accentSkyBlue, isDark),
          colorText: NeoBrutalismTheme.primaryBlack,
          borderWidth: 2,
          borderColor: NeoBrutalismTheme.primaryBlack,
        );
        await controller.rescan();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: NeoBrutalismTheme.neoBox(
          color: _t(NeoBrutalismTheme.accentSkyBlue, isDark),
          offset: 3,
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sms, size: 18, color: NeoBrutalismTheme.primaryBlack),
            SizedBox(width: 8),
            Text(
              'SCAN SMS FOR TRANSACTIONS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.primaryBlack,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  // ═══════════════════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════════════════

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: NeoBrutalismTheme.neoBox(
              color: _t(NeoBrutalismTheme.accentSkyBlue, isDark),
              offset: 4,
              borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: const Icon(Icons.notifications_none,
                size: 40, color: NeoBrutalismTheme.primaryBlack),
          ),
          const SizedBox(height: 20),
          Text(
            'NO NOTIFICATIONS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark
                  ? NeoBrutalismTheme.darkText
                  : NeoBrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bank SMS transactions will appear here\nfor you to review and add',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 240,
            child: NeoButton(
              text: 'SCAN SMS NOW',
              onPressed: () async {
                await controller.rescan();
              },
              color: _t(NeoBrutalismTheme.accentSkyBlue, isDark),
              icon: Icons.sms,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  // ═══════════════════════════════════════════════════════════
  // DIALOGS
  // ═══════════════════════════════════════════════════════════

  void _showDismissAllDialog(bool isDark) {
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
              Text(
                'DISMISS ALL?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This will clear all pending transaction suggestions. You can always scan again later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
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
                      text: 'DISMISS ALL',
                      onPressed: () {
                        Get.back();
                        controller.dismissAll();
                      },
                      color: _t(NeoBrutalismTheme.accentOrange, isDark),
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

  void _showClearHistoryDialog(bool isDark) {
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
              Text(
                'CLEAR HISTORY?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This will clear detection history and allow previously seen SMS to be detected again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
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
                      text: 'CLEAR',
                      onPressed: () async {
                        Get.back();
                        await controller.clearHistory();
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