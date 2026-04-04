import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/subscription_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../controllers/subscription_controller.dart';

class AddSubscriptionView extends GetView<SubscriptionController> {
  const AddSubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Check for editing
    final args = Get.arguments;
    final editing = args is SubscriptionModel ? args : null;

    final nameCtrl = TextEditingController(text: editing?.name ?? '');
    final amountCtrl = TextEditingController(
        text: editing != null ? editing.amount.toStringAsFixed(2) : '');
    final notesCtrl = TextEditingController(text: editing?.notes ?? '');
    final urlCtrl = TextEditingController(text: editing?.url ?? '');

    final selectedCycle = (editing?.cycle ?? 'monthly').obs;
    final selectedIcon = (editing?.icon ?? '📦').obs;
    final autoPay = (editing?.autoDeducted ?? false).obs;
    final startDate = (editing?.startDate ?? DateTime.now()).obs;
    final selectedCategoryId = Rxn<String>(editing?.categoryId);
    final selectedAccountId = Rxn<String>(editing?.accountId);

    final commonSubs = [
      {'name': 'Netflix', 'icon': '🎬', 'amount': '649', 'cycle': 'monthly'},
      {'name': 'Spotify', 'icon': '🎵', 'amount': '119', 'cycle': 'monthly'},
      {'name': 'YouTube', 'icon': '▶️', 'amount': '149', 'cycle': 'monthly'},
      {'name': 'Prime', 'icon': '📦', 'amount': '1499', 'cycle': 'yearly'},
      {'name': 'Hotstar', 'icon': '⭐', 'amount': '299', 'cycle': 'monthly'},
      {'name': 'Gym', 'icon': '💪', 'amount': '1500', 'cycle': 'monthly'},
      {'name': 'iCloud', 'icon': '☁️', 'amount': '75', 'cycle': 'monthly'},
      {'name': 'ChatGPT', 'icon': '🤖', 'amount': '1680', 'cycle': 'monthly'},
      {'name': 'Claude', 'icon': '🧠', 'amount': '1680', 'cycle': 'monthly'},
      {'name': 'Notion', 'icon': '📝', 'amount': '640', 'cycle': 'monthly'},
    ];

    final icons = [
      '📦', '🎬', '🎵', '▶️', '⭐', '💪', '☁️', '🤖', '🧠',
      '📝', '🎮', '📱', '💻', '📰', '🏠', '🚗', '📚', '🏥', '🛡️', '📡',
    ];

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      body: Column(
        children: [
          _buildHeader(isDark, editing != null),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ═══ Quick-add popular subscriptions (only when adding new) ═══
                if (editing == null) ...[
                  _buildLabel('QUICK ADD', isDark),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemCount: commonSubs.length,
                      itemBuilder: (ctx, i) {
                        final s = commonSubs[i];
                        return GestureDetector(
                          onTap: () {
                            nameCtrl.text = s['name']!;
                            amountCtrl.text = s['amount']!;
                            selectedIcon.value = s['icon']!;
                            selectedCycle.value = s['cycle']!;
                          },
                          child: Container(
                            width: 76,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 10),
                            decoration: NeoBrutalismTheme.neoBox(
                              color: isDark
                                  ? NeoBrutalismTheme.darkSurface
                                  : NeoBrutalismTheme.primaryWhite,
                              offset: 2,
                              borderColor: NeoBrutalismTheme.primaryBlack,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(s['icon']!,
                                    style: const TextStyle(fontSize: 22)),
                                const SizedBox(height: 4),
                                Text(
                                  s['name']!,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? NeoBrutalismTheme.darkText
                                        : NeoBrutalismTheme.primaryBlack,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ═══ Icon selector ═══
                _buildLabel('ICON', isDark),
                const SizedBox(height: 8),
                Obx(() {
                  final sel = selectedIcon.value;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: icons
                        .map((emoji) => GestureDetector(
                      onTap: () => selectedIcon.value = emoji,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: sel == emoji
                            ? NeoBrutalismTheme.neoBox(
                          color: NeoBrutalismTheme.accentPink,
                          offset: 2,
                          borderColor:
                          NeoBrutalismTheme.primaryBlack,
                        )
                            : BoxDecoration(
                          color: isDark
                              ? NeoBrutalismTheme.darkSurface
                              : Colors.grey[100],
                          border: Border.all(
                              color:
                              NeoBrutalismTheme.primaryBlack,
                              width: 1.5),
                        ),
                        child: Center(
                            child: Text(emoji,
                                style: const TextStyle(fontSize: 18))),
                      ),
                    ))
                        .toList(),
                  );
                }),
                const SizedBox(height: 20),

                // ═══ Name ═══
                _buildLabel('SUBSCRIPTION NAME', isDark),
                const SizedBox(height: 8),
                _buildField(nameCtrl, 'Netflix, Spotify...', isDark),
                const SizedBox(height: 20),

                // ═══ Amount ═══
                _buildLabel('AMOUNT', isDark),
                const SizedBox(height: 8),
                _buildField(amountCtrl, '0', isDark,
                    prefixText: '₹ ',
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 20),

                // ═══ Cycle ═══
                _buildLabel('BILLING CYCLE', isDark),
                const SizedBox(height: 8),
                Obx(() {
                  final sel = selectedCycle.value;
                  return Row(
                    children: ['weekly', 'monthly', 'quarterly', 'yearly']
                        .map((c) => Expanded(
                      child: GestureDetector(
                        onTap: () => selectedCycle.value = c,
                        child: Container(
                          margin: EdgeInsets.only(
                              right: c != 'yearly' ? 8 : 0),
                          padding:
                          const EdgeInsets.symmetric(vertical: 10),
                          decoration: sel == c
                              ? NeoBrutalismTheme.neoBox(
                            color: NeoBrutalismTheme.accentPurple,
                            offset: 2,
                            borderColor:
                            NeoBrutalismTheme.primaryBlack,
                          )
                              : BoxDecoration(
                            color: isDark
                                ? NeoBrutalismTheme.darkSurface
                                : NeoBrutalismTheme.primaryWhite,
                            border: Border.all(
                                color: NeoBrutalismTheme
                                    .primaryBlack,
                                width: 2),
                          ),
                          child: Center(
                            child: Text(
                              c.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: sel == c
                                    ? NeoBrutalismTheme.primaryBlack
                                    : (isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600]),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ))
                        .toList(),
                  );
                }),
                const SizedBox(height: 20),

                // ═══ Start date ═══
                _buildLabel('START DATE', isDark),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) startDate.value = picked;
                  },
                  child: Obx(() => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: NeoBrutalismTheme.neoBox(
                      color: isDark
                          ? NeoBrutalismTheme.darkSurface
                          : NeoBrutalismTheme.primaryWhite,
                      offset: 3,
                      borderColor: NeoBrutalismTheme.primaryBlack,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 18,
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey[600]),
                        const SizedBox(width: 10),
                        Text(
                          '${startDate.value.day}/${startDate.value.month}/${startDate.value.year}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? NeoBrutalismTheme.darkText
                                : NeoBrutalismTheme.primaryBlack,
                          ),
                        ),
                      ],
                    ),
                  )),
                ),
                const SizedBox(height: 20),

                // ═══ Auto-pay toggle ═══
                Obx(() {
                  final isAuto = autoPay.value;
                  return GestureDetector(
                    onTap: () => autoPay.value = !isAuto,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: NeoBrutalismTheme.neoBox(
                        color: isAuto
                            ? NeoBrutalismTheme.getThemedColor(
                            NeoBrutalismTheme.accentGreen, isDark)
                            : (isDark
                            ? NeoBrutalismTheme.darkSurface
                            : NeoBrutalismTheme.primaryWhite),
                        offset: 3,
                        borderColor: NeoBrutalismTheme.primaryBlack,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isAuto
                                  ? NeoBrutalismTheme.primaryBlack
                                  : Colors.transparent,
                              border: Border.all(
                                  color: NeoBrutalismTheme.primaryBlack,
                                  width: 2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: isAuto
                                ? const Icon(Icons.check,
                                size: 16,
                                color: NeoBrutalismTheme.primaryWhite)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AUTO-PAY',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? NeoBrutalismTheme.darkText
                                        : NeoBrutalismTheme.primaryBlack,
                                  ),
                                ),
                                Text(
                                  'Automatically deducted from bank/card',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // ═══ Notes ═══
                _buildLabel('NOTES (OPTIONAL)', isDark),
                const SizedBox(height: 8),
                _buildField(notesCtrl, 'Login email, plan details...', isDark,
                    maxLines: 2),
                const SizedBox(height: 20),

                // ═══ URL ═══
                _buildLabel('MANAGE URL (OPTIONAL)', isDark),
                const SizedBox(height: 8),
                _buildField(urlCtrl, 'https://netflix.com/account', isDark),
                const SizedBox(height: 32),

                // ═══ Save ═══
                NeoButton(
                  text: editing != null ? 'UPDATE' : 'ADD SUBSCRIPTION',
                  onPressed: () => _save(
                    editing,
                    nameCtrl.text,
                    amountCtrl.text,
                    selectedCycle.value,
                    selectedIcon.value,
                    startDate.value,
                    autoPay.value,
                    notesCtrl.text,
                    urlCtrl.text,
                    selectedCategoryId.value,
                    selectedAccountId.value,
                  ),
                  color: NeoBrutalismTheme.accentGreen,
                  icon: Icons.check,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeader(bool isDark, bool isEdit) {
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
            : NeoBrutalismTheme.getThemedColor(
            NeoBrutalismTheme.accentPink, isDark),
        border: const Border(
          bottom: BorderSide(
              color: NeoBrutalismTheme.primaryBlack,
              width: NeoBrutalismTheme.borderWidth),
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
              child: Icon(Icons.arrow_back,
                  color: isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            isEdit ? 'EDIT SUB' : 'NEW SUBSCRIPTION',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: isDark
                  ? NeoBrutalismTheme.darkText
                  : NeoBrutalismTheme.primaryBlack,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════

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

  Widget _buildField(TextEditingController ctrl, String hint, bool isDark,
      {String? prefixText, TextInputType? keyboardType, int maxLines = 1}) {
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
          hintStyle:
          TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SAVE
  // ═══════════════════════════════════════════════════════════

  void _save(
      SubscriptionModel? editing,
      String name,
      String amountStr,
      String cycle,
      String icon,
      DateTime start,
      bool autoPay,
      String notes,
      String url,
      String? catId,
      String? accId,
      ) {
    if (name.trim().isEmpty) {
      Get.snackbar('Error', 'Name is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final amount = double.tryParse(amountStr) ?? 0;
    if (amount <= 0) {
      Get.snackbar('Error', 'Enter a valid amount',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Calculate first renewal
    DateTime nextRenewal;
    if (editing != null) {
      nextRenewal = editing.nextRenewal;
    } else {
      switch (cycle) {
        case 'weekly':
          nextRenewal = start.add(const Duration(days: 7));
          break;
        case 'quarterly':
          nextRenewal = DateTime(start.year, start.month + 3, start.day);
          break;
        case 'yearly':
          nextRenewal = DateTime(start.year + 1, start.month, start.day);
          break;
        default:
          nextRenewal = DateTime(start.year, start.month + 1, start.day);
      }
      // Advance past today if already overdue
      final now = DateTime.now();
      while (nextRenewal.isBefore(now)) {
        switch (cycle) {
          case 'weekly':
            nextRenewal = nextRenewal.add(const Duration(days: 7));
            break;
          case 'quarterly':
            nextRenewal = DateTime(
                nextRenewal.year, nextRenewal.month + 3, nextRenewal.day);
            break;
          case 'yearly':
            nextRenewal = DateTime(
                nextRenewal.year + 1, nextRenewal.month, nextRenewal.day);
            break;
          default:
            nextRenewal = DateTime(
                nextRenewal.year, nextRenewal.month + 1, nextRenewal.day);
        }
      }
    }

    final sub = SubscriptionModel(
      id: editing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      amount: amount,
      cycle: cycle,
      startDate: start,
      nextRenewal: nextRenewal,
      categoryId: catId,
      accountId: accId,
      icon: icon,
      isActive: editing?.isActive ?? true,
      notes: notes.trim().isEmpty ? null : notes.trim(),
      autoDeducted: autoPay,
      url: url.trim().isEmpty ? null : url.trim(),
    );

    if (editing != null) {
      controller.updateSubscription(sub);
    } else {
      controller.addSubscription(sub);
    }
    Get.back();
  }
}