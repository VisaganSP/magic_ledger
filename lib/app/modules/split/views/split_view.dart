import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/split_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../controllers/split_controller.dart';

class SplitView extends GetView<SplitController> {
  const SplitView({super.key});

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
              if (controller.splits.isEmpty) return _buildEmpty(isDark);

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                children: [
                  _buildStatsStrip(isDark),
                  const SizedBox(height: 16),

                  if (controller.pendingSplits.isNotEmpty) ...[
                    _buildSectionTitle('PENDING', controller.pendingSplits.length, isDark),
                    const SizedBox(height: 10),
                    ...controller.pendingSplits.asMap().entries.map((entry) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildSplitCard(entry.value, isDark)
                              .animate()
                              .fadeIn(delay: (100 + entry.key * 60).ms)
                              .slideY(begin: 0.04, end: 0),
                        )),
                    const SizedBox(height: 16),
                  ],

                  if (controller.settledSplits.isNotEmpty) ...[
                    _buildSectionTitle('SETTLED', controller.settledSplits.length, isDark),
                    const SizedBox(height: 10),
                    ...controller.settledSplits.map((s) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildSplitCard(s, isDark, compact: true),
                        )),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 16,
        left: 20, right: 20, bottom: 14,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : _t(NeoBrutalismTheme.accentLilac, isDark),
        border: const Border(
          bottom: BorderSide(color: NeoBrutalismTheme.primaryBlack,
              width: NeoBrutalismTheme.borderWidth),
        ),
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
          Text('SPLIT EXPENSES',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const Spacer(),
          GestureDetector(
            onTap: () => Get.toNamed('/add-split'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: NeoBrutalismTheme.neoBox(
                color: NeoBrutalismTheme.accentGreen,
                offset: 3, borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: const Icon(Icons.add, color: NeoBrutalismTheme.primaryBlack),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildStatsStrip(bool isDark) {
    return Obx(() => Row(
      children: [
        Expanded(child: _buildStatCard(
          'OWED TO YOU', '₹${controller.totalOwedToYou.value.toStringAsFixed(0)}',
          _t(NeoBrutalismTheme.accentGreen, isDark), isDark,
        )),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard(
          'ACTIVE SPLITS', '${controller.activeSplits.value}',
          _t(NeoBrutalismTheme.accentPurple, isDark), isDark,
        )),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard(
          'TOTAL', '${controller.splits.length}',
          _t(NeoBrutalismTheme.accentSkyBlue, isDark), isDark,
        )),
      ],
    ));
  }

  Widget _buildStatCard(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: NeoBrutalismTheme.neoBox(
        color: color, offset: 3, borderColor: NeoBrutalismTheme.primaryBlack,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.primaryBlack, letterSpacing: 0.3)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.primaryBlack)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count, bool isDark) {
    return Row(
      children: [
        Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
              color: isDark ? Colors.grey[400] : Colors.grey[700])),
        ),
      ],
    );
  }

  Widget _buildSplitCard(SplitModel split, bool isDark, {bool compact = false}) {
    final progress = split.participants.isEmpty ? 0.0 :
    split.settledCount / split.participants.length;

    return GestureDetector(
      onTap: () => _showSplitDetail(split, isDark),
      child: NeoCard(
        color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
        borderColor: NeoBrutalismTheme.primaryBlack,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: compact ? 32 : 40,
                  height: compact ? 32 : 40,
                  decoration: BoxDecoration(
                    color: split.isFullySettled
                        ? _t(NeoBrutalismTheme.accentGreen, isDark)
                        : _t(NeoBrutalismTheme.accentOrange, isDark),
                    border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
                  ),
                  child: Center(child: Icon(
                    split.isFullySettled ? Icons.check : Icons.call_split,
                    size: compact ? 16 : 20, color: NeoBrutalismTheme.primaryBlack,
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(split.title, style: TextStyle(
                          fontSize: compact ? 13 : 15, fontWeight: FontWeight.w800,
                          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('${split.participants.length} people • Paid by ${split.paidBy}',
                          style: TextStyle(fontSize: 11,
                              color: isDark ? Colors.grey[500] : Colors.grey[600])),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${split.totalAmount.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: compact ? 14 : 17, fontWeight: FontWeight.w900,
                            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                    if (!split.isFullySettled)
                      Text('₹${split.pendingAmount.toStringAsFixed(0)} left',
                          style: TextStyle(fontSize: 10,
                              color: isDark ? Colors.red[400] : Colors.red[700])),
                  ],
                ),
              ],
            ),
            if (!compact) ...[
              const SizedBox(height: 12),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1),
                ),
                child: FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _t(NeoBrutalismTheme.accentGreen, isDark),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: split.participants.asMap().entries.map((entry) {
                  final i = entry.key;
                  final name = entry.value;
                  final isSettled = split.settled[i];
                  final isPayer = name == split.paidBy;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPayer
                          ? _t(NeoBrutalismTheme.accentPurple, isDark)
                          : (isSettled
                          ? _t(NeoBrutalismTheme.accentGreen, isDark)
                          : (isDark ? Colors.grey[800] : Colors.grey[200])),
                      border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      isPayer ? '$name (paid)' : '$name ₹${split.shares[i].toStringAsFixed(0)}${isSettled ? ' ✓' : ''}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: NeoBrutalismTheme.primaryBlack,
                        decoration: isSettled && !isPayer ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SPLIT DETAIL — scrollable bottom sheet
  // ═══════════════════════════════════════════════════════════

  void _showSplitDetail(SplitModel split, bool isDark) {
    final splitId = split.id;

    Get.bottomSheet(
      Obx(() {
        // Reactively find the latest version of this split from the controller
        final currentSplit = controller.splits.firstWhereOrNull((s) => s.id == splitId);
        if (currentSplit == null) {
          // Split was deleted while sheet was open
          return const SizedBox.shrink();
        }

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.75,
          ),
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
              // ── Drag handle ──
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // ── Scrollable content ──
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(currentSplit.title, style: TextStyle(fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark ? NeoBrutalismTheme.darkText
                              : NeoBrutalismTheme.primaryBlack)),
                      const SizedBox(height: 4),
                      Text(
                        '₹${currentSplit.totalAmount.toStringAsFixed(2)} • ${currentSplit.splitType} split',
                        style: TextStyle(fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),

                      // Each participant with toggle
                      ...currentSplit.participants.asMap().entries.map((entry) {
                        final i = entry.key;
                        final name = entry.value;
                        final share = currentSplit.shares[i];
                        final isSettled = currentSplit.settled[i];
                        final isPayer = name == currentSplit.paidBy;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: NeoBrutalismTheme.neoBox(
                              color: isPayer
                                  ? _t(NeoBrutalismTheme.accentPurple, isDark)
                                  : (isSettled
                                  ? _t(NeoBrutalismTheme.accentGreen, isDark)
                                  : (isDark
                                  ? NeoBrutalismTheme.darkBackground
                                  : Colors.grey[100]!)),
                              offset: 2,
                              borderColor: NeoBrutalismTheme.primaryBlack,
                            ),
                            child: Row(
                              children: [
                                if (!isPayer)
                                  GestureDetector(
                                    onTap: () {
                                      // Just toggle — Obx rebuilds automatically
                                      controller.toggleSettled(splitId, i);
                                    },
                                    child: Container(
                                      width: 24, height: 24,
                                      decoration: BoxDecoration(
                                        color: isSettled
                                            ? NeoBrutalismTheme.primaryBlack
                                            : Colors.transparent,
                                        border: Border.all(
                                            color: NeoBrutalismTheme.primaryBlack,
                                            width: 2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: isSettled
                                          ? const Icon(Icons.check, size: 16,
                                          color: NeoBrutalismTheme.primaryWhite)
                                          : null,
                                    ),
                                  ),
                                if (isPayer)
                                  const Icon(Icons.star, size: 22,
                                      color: NeoBrutalismTheme.primaryBlack),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: NeoBrutalismTheme.primaryBlack,
                                          decoration: isSettled && !isPayer
                                              ? TextDecoration.lineThrough
                                              : null)),
                                      if (isPayer)
                                        Text('Paid the bill',
                                            style: TextStyle(fontSize: 11,
                                                color: Colors.grey[700])),
                                    ],
                                  ),
                                ),
                                Text('₹${share.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: NeoBrutalismTheme.primaryBlack)),
                              ],
                            ),
                          ),
                        );
                      }),

                      if (currentSplit.notes != null && currentSplit.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(currentSplit.notes!, style: TextStyle(fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[600])),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Buttons — fixed at bottom ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: NeoButton(
                        text: 'DELETE',
                        onPressed: () {
                          Navigator.of(Get.context!).pop();
                          controller.deleteSplit(splitId);
                        },
                        color: Colors.red.shade100,
                        textColor: Colors.red,
                        icon: Icons.delete,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeoButton(
                        text: 'SHARE',
                        onPressed: () {
                          final s = currentSplit;
                          final lines = <String>[
                            '${s.title} — ₹${s.totalAmount.toStringAsFixed(2)}',
                            '',
                          ];
                          for (int i = 0; i < s.participants.length; i++) {
                            final status = s.participants[i] == s.paidBy
                                ? '(paid)'
                                : (s.settled[i] ? '✓ settled' : 'owes');
                            lines.add(
                                '${s.participants[i]}: ₹${s.shares[i].toStringAsFixed(2)} $status');
                          }
                          lines.add('\nSent from Magic Ledger');
                          Navigator.of(Get.context!).pop();
                          Get.snackbar('Copied!',
                              'Split details copied to clipboard',
                              snackPosition: SnackPosition.BOTTOM);
                        },
                        color: _t(NeoBrutalismTheme.accentSkyBlue, isDark),
                        icon: Icons.share,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: NeoBrutalismTheme.neoBox(
              color: _t(NeoBrutalismTheme.accentLilac, isDark),
              offset: 4, borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: const Icon(Icons.call_split, size: 40,
                color: NeoBrutalismTheme.primaryBlack),
          ),
          const SizedBox(height: 20),
          Text('NO SPLITS YET', style: TextStyle(fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText
                  : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 8),
          Text('Split expenses with friends\nand track who owes what',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13,
                  color: isDark ? Colors.grey[500] : Colors.grey[600])),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: NeoButton(
              text: 'CREATE SPLIT',
              onPressed: () => Get.toNamed('/add-split'),
              color: NeoBrutalismTheme.accentGreen,
              icon: Icons.add,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}