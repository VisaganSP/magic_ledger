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
      backgroundColor: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.lightBackground,
      body: Column(
        children: [
          _buildHeader(isDark),
          _buildFilterRow(isDark),
          // Everything reactive in ONE Obx
          Expanded(child: Obx(() {
            // Read reactive values up front so GetX always sees them
            final isScanning = controller.isScanning.value;
            final filter = controller.activeFilter.value;
            final depth = controller.scanDepthDays.value;
            final credits = controller.totalCreditsObs.value;
            final debits = controller.totalDebitsObs.value;
            final creditAmt = controller.totalCreditAmountObs.value;
            final debitAmt = controller.totalDebitAmountObs.value;
            final unread = controller.unreadCount.value;

            if (isScanning) return _buildScanningState(isDark, depth);

            final grouped = controller.groupedPending;
            final historyList = controller.history;

            if (grouped.isEmpty && historyList.isEmpty) {
              return _buildEmptyState(isDark, depth);
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              children: [
                // Stats bar (inline, no Obx)
                if (credits > 0 || debits > 0)
                  _buildStatsBarWidget(credits, debits, creditAmt, debitAmt, isDark),

                if (grouped.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildSectionLabel('PENDING', '${controller.pending.length} to review',
                      NeoBrutalismTheme.accentOrange, isDark,
                      showAction: true, actionLabel: 'DISMISS ALL',
                      onAction: () => _showDismissAllDialog(isDark)),
                  const SizedBox(height: 10),
                  ..._buildGroupedList(grouped, isDark),
                  const SizedBox(height: 16),
                ],

                _buildScanSection(isDark, depth),
                const SizedBox(height: 20),

                if (historyList.isNotEmpty) ...[
                  _buildSectionLabel('RECENT DETECTIONS', '${historyList.length} found',
                      NeoBrutalismTheme.accentPurple, isDark,
                      showAction: true, actionLabel: 'CLEAR',
                      onAction: () => _showClearHistoryDialog(isDark)),
                  const SizedBox(height: 10),
                  for (var i = 0; i < historyList.length && i < 20; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildHistoryCard(historyList[i], isDark),
                    ),
                ],
              ],
            );
          })),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedList(Map<String, List<TransactionParseResult>> grouped, bool isDark) {
    final widgets = <Widget>[];
    for (final entry in grouped.entries) {
      widgets.add(_buildDateHeader(entry.key, entry.value.length, isDark));
      for (var i = 0; i < entry.value.length; i++) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildPendingCard(entry.value[i], isDark),
        ));
      }
      widgets.add(const SizedBox(height: 4));
    }
    return widgets;
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(Get.context!).padding.top + 16,
          left: 20, right: 20, bottom: 14),
      decoration: BoxDecoration(
          color: isDark ? NeoBrutalismTheme.darkSurface : _t(NeoBrutalismTheme.accentSkyBlue, isDark),
          border: const Border(bottom: BorderSide(
              color: NeoBrutalismTheme.primaryBlack, width: NeoBrutalismTheme.borderWidth))),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(Get.context!).pop(),
          child: Container(padding: const EdgeInsets.all(8),
              decoration: NeoBrutalismTheme.neoBox(
                  color: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
                  offset: 3, borderColor: NeoBrutalismTheme.primaryBlack),
              child: Icon(Icons.arrow_back,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SMS TRANSACTIONS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          Obx(() {
            // This Obx is fine — always reads .value, never returns SizedBox.shrink
            final listening = Get.find<SmsTransactionService>().isListening.value;
            final days = controller.scanDepthDays.value;
            return Text(
                listening ? 'Live detection active • ${days}d scan' : 'SMS detection off',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: listening
                        ? (isDark ? Colors.green[400] : Colors.green[700])
                        : (isDark ? Colors.grey[500] : Colors.grey[600])));
          }),
        ])),
        GestureDetector(
          onTap: () => _showScanDepthPicker(isDark),
          child: Container(padding: const EdgeInsets.all(8),
              decoration: NeoBrutalismTheme.neoBox(
                  color: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
                  offset: 3, borderColor: NeoBrutalismTheme.primaryBlack),
              child: Icon(Icons.tune, size: 20,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => controller.rescan(),
          child: Container(padding: const EdgeInsets.all(8),
              decoration: NeoBrutalismTheme.neoBox(
                  color: _t(NeoBrutalismTheme.accentGreen, isDark),
                  offset: 3, borderColor: NeoBrutalismTheme.primaryBlack),
              child: const Icon(Icons.refresh, size: 20, color: NeoBrutalismTheme.primaryBlack)),
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FILTERS
  // ═══════════════════════════════════════════════════════════

  Widget _buildFilterRow(bool isDark) {
    final filters = [
      {'label': 'all', 'text': 'ALL', 'icon': Icons.all_inclusive},
      {'label': 'today', 'text': 'TODAY', 'icon': Icons.today},
      {'label': 'week', 'text': 'WEEK', 'icon': Icons.view_week},
      {'label': 'month', 'text': 'MONTH', 'icon': Icons.calendar_month},
      {'label': 'credits', 'text': 'CREDITS', 'icon': Icons.arrow_downward},
      {'label': 'debits', 'text': 'DEBITS', 'icon': Icons.arrow_upward},
    ];
    return SizedBox(height: 48,
      child: Obx(() {
        // Always reads activeFilter.value — safe
        final currentFilter = controller.activeFilter.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemCount: filters.length,
          itemBuilder: (_, i) {
            final f = filters[i];
            final isSel = currentFilter == f['label'];
            Color chipColor;
            if (f['label'] == 'credits') chipColor = NeoBrutalismTheme.accentGreen;
            else if (f['label'] == 'debits') chipColor = NeoBrutalismTheme.accentOrange;
            else chipColor = NeoBrutalismTheme.accentPurple;

            return GestureDetector(
              onTap: () => controller.setFilter(f['label'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: isSel
                    ? NeoBrutalismTheme.neoBox(color: _t(chipColor, isDark), offset: 2,
                    borderColor: NeoBrutalismTheme.primaryBlack)
                    : BoxDecoration(
                    color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
                    border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(f['icon'] as IconData, size: 14,
                      color: isSel ? NeoBrutalismTheme.primaryBlack
                          : (isDark ? Colors.grey[500] : Colors.grey[600])),
                  const SizedBox(width: 5),
                  Text(f['text'] as String, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
                      color: isSel ? NeoBrutalismTheme.primaryBlack
                          : (isDark ? Colors.grey[500] : Colors.grey[600]))),
                ]),
              ),
            );
          },
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // STATS BAR — plain widget, no Obx
  // ═══════════════════════════════════════════════════════════

  Widget _buildStatsBarWidget(int cr, int dr, double creditAmt, double debitAmt, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: NeoBrutalismTheme.neoBox(
          color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
          offset: 3, borderColor: NeoBrutalismTheme.primaryBlack),
      child: Row(children: [
        Expanded(child: Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(
              color: isDark ? Colors.green[400] : Colors.green[700], shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$cr', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900,
              color: isDark ? Colors.green[400] : Colors.green[700])),
          const SizedBox(width: 4),
          Flexible(child: Text('+₹${_fmtAmt(creditAmt)}',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: isDark ? Colors.green[400] : Colors.green[700]),
              overflow: TextOverflow.ellipsis)),
        ])),
        Container(width: 1, height: 20, color: isDark ? Colors.grey[700] : Colors.grey[300]),
        const SizedBox(width: 12),
        Expanded(child: Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(
              color: isDark ? Colors.red[400] : Colors.red[700], shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$dr', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900,
              color: isDark ? Colors.red[400] : Colors.red[700])),
          const SizedBox(width: 4),
          Flexible(child: Text('-₹${_fmtAmt(debitAmt)}',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: isDark ? Colors.red[400] : Colors.red[700]),
              overflow: TextOverflow.ellipsis)),
        ])),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DATE HEADER
  // ═══════════════════════════════════════════════════════════

  Widget _buildDateHeader(String label, int count, bool isDark) {
    Color accentColor;
    switch (label) {
      case 'TODAY': accentColor = NeoBrutalismTheme.accentGreen; break;
      case 'YESTERDAY': accentColor = NeoBrutalismTheme.accentSkyBlue; break;
      case 'THIS WEEK': accentColor = NeoBrutalismTheme.accentPurple; break;
      case 'THIS MONTH': accentColor = NeoBrutalismTheme.accentYellow; break;
      default: accentColor = NeoBrutalismTheme.accentBeige; break;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Row(children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(
            color: _t(accentColor, isDark), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: _t(accentColor, isDark),
              border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5),
              borderRadius: BorderRadius.circular(3)),
          child: Text('$count', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.primaryBlack)),
        ),
        const Spacer(),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SECTION LABEL
  // ═══════════════════════════════════════════════════════════

  Widget _buildSectionLabel(String title, String subtitle, Color color, bool isDark,
      {bool showAction = false, String? actionLabel, VoidCallback? onAction}) {
    return Row(children: [
      Container(width: 4, height: 24, decoration: BoxDecoration(
          color: _t(color, isDark), borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        Text(subtitle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[500] : Colors.grey[600])),
      ]),
      const Spacer(),
      if (showAction && actionLabel != null)
        GestureDetector(onTap: onAction, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5)),
          child: Text(actionLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
              color: isDark ? Colors.grey[400] : Colors.grey[700], letterSpacing: 0.3)),
        )),
    ]);
  }

  // ═══════════════════════════════════════════════════════════
  // PENDING CARD
  // ═══════════════════════════════════════════════════════════

  Widget _buildPendingCard(TransactionParseResult result, bool isDark) {
    final isIncome = result.isCredit;
    final accentColor = isIncome ? _t(NeoBrutalismTheme.accentGreen, isDark)
        : _t(NeoBrutalismTheme.accentOrange, isDark);
    final typeLabel = isIncome ? 'INCOME' : 'EXPENSE';
    final typeEmoji = isIncome ? '💰' : '💸';
    final dateStr = result.date != null ? '${result.date!.day}/${result.date!.month}' : '';

    return Dismissible(
      key: Key('p_${result.refNumber ?? ''}_${result.amount}_${result.date?.millisecondsSinceEpoch ?? 0}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => controller.dismiss(result),
      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(color: Colors.red,
              border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2)),
          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.close, color: Colors.white, size: 24),
            SizedBox(height: 2),
            Text('DISMISS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
          ])),
      child: NeoCard(
        color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
        borderColor: NeoBrutalismTheme.primaryBlack, padding: EdgeInsets.zero,
        child: Column(children: [
          Container(height: 4, color: accentColor),
          Padding(padding: const EdgeInsets.all(14), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: accentColor,
                      border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5)),
                  child: Text('$typeEmoji $typeLabel', style: const TextStyle(fontSize: 10,
                      fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack))),
              const SizedBox(width: 6),
              if (result.bankName != null)
                Flexible(child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: isDark ? NeoBrutalismTheme.darkBackground : Colors.grey[100],
                        border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5)),
                    child: Text(result.bankName!, style: TextStyle(fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
                        overflow: TextOverflow.ellipsis))),
              if (dateStr.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(dateStr, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey[500] : Colors.grey[500])),
              ],
              const Spacer(),
              Text('${isIncome ? '+' : '-'}₹${result.amount.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                      color: isIncome ? (isDark ? Colors.green[400] : Colors.green[700])
                          : (isDark ? Colors.red[400] : Colors.red[700]))),
            ]),
            const SizedBox(height: 10),
            Text(result.suggestedTitle, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 4, children: [
              if (result.accountLast4 != null) _chip('A/c •••${result.accountLast4}', isDark),
              if (result.suggestedCategory != null) _chip(result.suggestedCategory!, isDark),
              if (result.upiId != null) _chip('UPI', isDark),
              if (result.refNumber != null) _chip('Ref: ${result.refNumber!.length > 10
                  ? '${result.refNumber!.substring(0, 10)}...' : result.refNumber!}', isDark),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(flex: 3, child: GestureDetector(
                onTap: () => controller.addTransaction(result),
                child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: NeoBrutalismTheme.neoBox(color: accentColor, offset: 3,
                        borderColor: NeoBrutalismTheme.primaryBlack),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.check_circle, size: 18, color: NeoBrutalismTheme.primaryBlack),
                      const SizedBox(width: 6),
                      Text(isIncome ? 'ADD INCOME' : 'ADD EXPENSE',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
                              color: NeoBrutalismTheme.primaryBlack, letterSpacing: 0.3)),
                    ])),
              )),
              const SizedBox(width: 6),
              Expanded(flex: 1, child: GestureDetector(
                onTap: () => controller.editAndAdd(result),
                child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: NeoBrutalismTheme.neoBox(
                        color: isDark ? NeoBrutalismTheme.darkBackground : Colors.grey[200]!,
                        offset: 2, borderColor: NeoBrutalismTheme.primaryBlack),
                    child: const Icon(Icons.edit, size: 18, color: NeoBrutalismTheme.primaryBlack)),
              )),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => controller.dismiss(result),
                child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: NeoBrutalismTheme.neoBox(
                        color: isDark ? NeoBrutalismTheme.darkBackground : Colors.grey[100]!,
                        offset: 2, borderColor: NeoBrutalismTheme.primaryBlack),
                    child: const Icon(Icons.close, size: 18, color: NeoBrutalismTheme.primaryBlack)),
              ),
            ]),
          ])),
        ]),
      ),
    );
  }

  Widget _chip(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(3)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
          color: isDark ? Colors.grey[400] : Colors.grey[700])),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HISTORY CARD
  // ═══════════════════════════════════════════════════════════

  Widget _buildHistoryCard(TransactionParseResult result, bool isDark) {
    final isIncome = result.isCredit;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
          border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5)),
      child: Row(children: [
        Container(width: 36, height: 36,
            decoration: BoxDecoration(
                color: isIncome ? _t(NeoBrutalismTheme.accentGreen, isDark)
                    : _t(NeoBrutalismTheme.accentOrange, isDark),
                border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5)),
            child: Center(child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                size: 18, color: NeoBrutalismTheme.primaryBlack))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(result.suggestedTitle, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text([
            result.bankName,
            if (result.accountLast4 != null) '•••${result.accountLast4}',
            if (result.date != null) '${result.date!.day}/${result.date!.month}',
          ].whereType<String>().join(' • '),
              style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[500] : Colors.grey[600])),
        ])),
        const SizedBox(width: 8),
        Text('${isIncome ? '+' : '-'}₹${result.amount.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                color: isIncome ? (isDark ? Colors.green[400] : Colors.green[700])
                    : (isDark ? Colors.red[400] : Colors.red[700]))),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SCAN SECTION — no Obx, depth passed in
  // ═══════════════════════════════════════════════════════════

  Widget _buildScanSection(bool isDark, int depth) {
    return GestureDetector(
      onTap: () => controller.rescan(),
      child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: NeoBrutalismTheme.neoBox(color: _t(NeoBrutalismTheme.accentSkyBlue, isDark),
              offset: 3, borderColor: NeoBrutalismTheme.primaryBlack),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.sms, size: 18, color: NeoBrutalismTheme.primaryBlack),
            const SizedBox(width: 8),
            Text('SCAN LAST $depth DAYS',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900,
                    color: NeoBrutalismTheme.primaryBlack, letterSpacing: 0.3)),
          ])),
    );
  }

  Widget _buildScanningState(bool isDark, int depth) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 80, height: 80,
          decoration: NeoBrutalismTheme.neoBox(color: _t(NeoBrutalismTheme.accentSkyBlue, isDark),
              offset: 4, borderColor: NeoBrutalismTheme.primaryBlack),
          child: const Center(child: SizedBox(width: 36, height: 36,
              child: CircularProgressIndicator(strokeWidth: 3, color: NeoBrutalismTheme.primaryBlack)))),
      const SizedBox(height: 20),
      Text('SCANNING SMS...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
      const SizedBox(height: 8),
      Text('Reading last $depth days of messages',
          style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[500] : Colors.grey[600])),
    ]));
  }

  Widget _buildEmptyState(bool isDark, int depth) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 80, height: 80,
          decoration: NeoBrutalismTheme.neoBox(color: _t(NeoBrutalismTheme.accentSkyBlue, isDark),
              offset: 4, borderColor: NeoBrutalismTheme.primaryBlack),
          child: const Icon(Icons.notifications_none, size: 40, color: NeoBrutalismTheme.primaryBlack)),
      const SizedBox(height: 20),
      Text('NO SMS DETECTED', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
      const SizedBox(height: 8),
      Text('Tap below to scan your SMS inbox', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[500] : Colors.grey[600])),
      const SizedBox(height: 24),
      SizedBox(width: 240, child: NeoButton(text: 'SCAN LAST 30 DAYS',
          onPressed: () => controller.scanLast30Days(),
          color: _t(NeoBrutalismTheme.accentSkyBlue, isDark), icon: Icons.sms)),
      const SizedBox(height: 12),
      SizedBox(width: 240, child: NeoButton(text: 'DEEP SCAN (90 DAYS)',
          onPressed: () => controller.scanLast90Days(),
          color: _t(NeoBrutalismTheme.accentPurple, isDark), icon: Icons.manage_search)),
    ]));
  }

  // ═══════════════════════════════════════════════════════════
  // DIALOGS
  // ═══════════════════════════════════════════════════════════

  void _showScanDepthPicker(bool isDark) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: const Border(top: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
              left: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
              right: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Text('SCAN DEPTH', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 6),
        Text('How far back to read bank SMS',
            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[600])),
        const SizedBox(height: 20),
        _depthBtn('Last 7 Days', 7, isDark),
        const SizedBox(height: 8),
        _depthBtn('Last 30 Days', 30, isDark),
        const SizedBox(height: 8),
        _depthBtn('Last 90 Days', 90, isDark),
        const SizedBox(height: 8),
        _depthBtn('Last 6 Months', 180, isDark),
        const SizedBox(height: 8),
        _depthBtn('Last 1 Year', 365, isDark),
        const SizedBox(height: 16),
      ]),
    ));
  }

  Widget _depthBtn(String label, int days, bool isDark) {
    return Obx(() {
      final isSel = controller.scanDepthDays.value == days;
      return GestureDetector(
        onTap: () { controller.scanDepthDays.value = days; Navigator.of(Get.context!).pop();
        controller.rescan(days: days); },
        child: Container(width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: isSel
                ? NeoBrutalismTheme.neoBox(color: _t(NeoBrutalismTheme.accentGreen, isDark),
                offset: 3, borderColor: NeoBrutalismTheme.primaryBlack)
                : NeoBrutalismTheme.neoBox(
                color: isDark ? NeoBrutalismTheme.darkBackground : Colors.grey[50]!,
                offset: 2, borderColor: NeoBrutalismTheme.primaryBlack),
            child: Row(children: [
              Text(label, style: TextStyle(fontSize: 15,
                  fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
              const Spacer(),
              Text('$days days', style: TextStyle(fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[600])),
              if (isSel) ...[const SizedBox(width: 8),
                const Icon(Icons.check_circle, size: 20, color: NeoBrutalismTheme.primaryBlack)],
            ])),
      );
    });
  }

  void _showDismissAllDialog(bool isDark) {
    Get.dialog(Dialog(backgroundColor: Colors.transparent, child: Container(
      padding: const EdgeInsets.all(24),
      decoration: NeoBrutalismTheme.neoBoxRounded(
          color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
          borderColor: NeoBrutalismTheme.primaryBlack),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('DISMISS ALL?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 12),
        Text("They'll come back on next scan.", textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: NeoButton(text: 'CANCEL',
              onPressed: () => Navigator.of(Get.context!).pop(),
              color: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
              textColor: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(width: 12),
          Expanded(child: NeoButton(text: 'DISMISS ALL',
              onPressed: () { Navigator.of(Get.context!).pop(); controller.dismissAll(); },
              color: _t(NeoBrutalismTheme.accentOrange, isDark))),
        ]),
      ]),
    )));
  }

  void _showClearHistoryDialog(bool isDark) {
    Get.dialog(Dialog(backgroundColor: Colors.transparent, child: Container(
      padding: const EdgeInsets.all(24),
      decoration: NeoBrutalismTheme.neoBoxRounded(
          color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
          borderColor: NeoBrutalismTheme.primaryBlack),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('CLEAR HISTORY?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 12),
        Text('Previously seen SMS can be detected again.', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: NeoButton(text: 'CANCEL',
              onPressed: () => Navigator.of(Get.context!).pop(),
              color: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
              textColor: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(width: 12),
          Expanded(child: NeoButton(text: 'CLEAR',
              onPressed: () async { Navigator.of(Get.context!).pop(); await controller.clearHistory(); },
              color: Colors.red, textColor: NeoBrutalismTheme.primaryWhite)),
        ]),
      ]),
    )));
  }

  String _fmtAmt(double a) {
    if (a >= 100000) return '${(a / 100000).toStringAsFixed(1)}L';
    if (a >= 1000) return '${(a / 1000).toStringAsFixed(1)}K';
    return a.toStringAsFixed(0);
  }
}