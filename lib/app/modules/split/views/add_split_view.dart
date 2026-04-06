import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/split_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../controllers/split_controller.dart';

class AddSplitView extends GetView<SplitController> {
  const AddSplitView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final paidBy = ''.obs;
    final splitType = 'equal'.obs;
    final participants = <String>[].obs;
    final customShares = <double>[].obs;
    final nameCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      body: Column(
        children: [
          _buildHeader(isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Title
                _buildLabel('WHAT WAS THIS FOR?', isDark),
                const SizedBox(height: 8),
                _buildTextField(titleCtrl, 'Dinner, Trip, Groceries...', isDark),
                const SizedBox(height: 20),

                // Amount
                _buildLabel('TOTAL AMOUNT', isDark),
                const SizedBox(height: 8),
                _buildTextField(amountCtrl, '0', isDark,
                    prefixText: '₹ ',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 20),

                // Add participants
                _buildLabel('PEOPLE', isDark),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(nameCtrl, 'Person name', isDark),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        final name = nameCtrl.text.trim();
                        if (name.isNotEmpty && !participants.contains(name)) {
                          participants.add(name);
                          customShares.add(0);
                          if (paidBy.value.isEmpty) paidBy.value = name;
                          nameCtrl.clear();
                        }
                      },
                      child: Container(
                        width: 48, height: 48,
                        decoration: NeoBrutalismTheme.neoBox(
                          color: NeoBrutalismTheme.accentGreen,
                          offset: 3, borderColor: NeoBrutalismTheme.primaryBlack,
                        ),
                        child: const Icon(Icons.add, color: NeoBrutalismTheme.primaryBlack),
                      ),
                    ),
                  ],
                ),

                // Quick add from history — FIX: read participants.length to register reactive dep
                Obx(() {
                  // Force reactive registration by reading the list
                  final currentParticipants = participants.toList();
                  final knownNames = controller.allParticipants
                      .where((n) => !currentParticipants.contains(n))
                      .take(8)
                      .toList();

                  if (knownNames.isEmpty) return const SizedBox(height: 12);

                  return Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: Wrap(
                      spacing: 6, runSpacing: 6,
                      children: knownNames.map((name) => GestureDetector(
                        onTap: () {
                          participants.add(name);
                          customShares.add(0);
                          if (paidBy.value.isEmpty) paidBy.value = name;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1),
                          ),
                          child: Text('+ $name', style: TextStyle(fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.grey[400] : Colors.grey[700])),
                        ),
                      )).toList(),
                    ),
                  );
                }),

                // Participant list
                Obx(() {
                  final list = participants.toList();
                  final paid = paidBy.value;
                  final type = splitType.value;

                  return Column(
                    children: list.asMap().entries.map((entry) {
                      final i = entry.key;
                      final name = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: NeoBrutalismTheme.neoBox(
                            color: paid == name
                                ? NeoBrutalismTheme.getThemedColor(
                                NeoBrutalismTheme.accentPurple, isDark)
                                : (isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite),
                            offset: 2, borderColor: NeoBrutalismTheme.primaryBlack,
                          ),
                          child: Row(
                            children: [
                              // Paid by selector
                              GestureDetector(
                                onTap: () => paidBy.value = name,
                                child: Container(
                                  width: 22, height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: paid == name
                                        ? NeoBrutalismTheme.primaryBlack : Colors.transparent,
                                    border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
                                  ),
                                  child: paid == name
                                      ? const Icon(Icons.check, size: 14, color: NeoBrutalismTheme.primaryWhite)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                                        color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                                    if (paid == name)
                                      Text('Paid the bill', style: TextStyle(fontSize: 10,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600])),
                                  ],
                                ),
                              ),
                              // Custom share input
                              if (type == 'custom')
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                                        color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
                                    decoration: const InputDecoration(
                                      prefixText: '₹',
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (v) {
                                      if (i < customShares.length) {
                                        customShares[i] = double.tryParse(v) ?? 0;
                                      }
                                    },
                                  ),
                                ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  final removedName = participants[i];
                                  participants.removeAt(i);
                                  if (i < customShares.length) customShares.removeAt(i);
                                  if (paidBy.value == removedName && participants.isNotEmpty) {
                                    paidBy.value = participants.first;
                                  }
                                },
                                child: const Icon(Icons.close, size: 18, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
                const SizedBox(height: 20),

                // Split type
                _buildLabel('SPLIT TYPE', isDark),
                const SizedBox(height: 8),
                Obx(() {
                  final selected = splitType.value;
                  return Row(
                    children: ['equal', 'custom', 'percentage'].map((type) {
                      final label = type[0].toUpperCase() + type.substring(1);
                      final isSel = selected == type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => splitType.value = type,
                          child: Container(
                            margin: EdgeInsets.only(right: type != 'percentage' ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: isSel
                                ? NeoBrutalismTheme.neoBox(
                                color: NeoBrutalismTheme.accentPurple,
                                offset: 2, borderColor: NeoBrutalismTheme.primaryBlack)
                                : BoxDecoration(
                                color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
                                border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2)),
                            child: Center(child: Text(label.toUpperCase(),
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
                                    color: isSel ? NeoBrutalismTheme.primaryBlack
                                        : (isDark ? Colors.grey[500] : Colors.grey[600])))),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
                const SizedBox(height: 20),

                // Notes
                _buildLabel('NOTES (OPTIONAL)', isDark),
                const SizedBox(height: 8),
                _buildTextField(notesCtrl, 'Any notes...', isDark, maxLines: 3),
                const SizedBox(height: 32),

                // Preview
                Obx(() {
                  final list = participants.toList();
                  final type = splitType.value;
                  if (list.isEmpty) return const SizedBox.shrink();

                  final total = double.tryParse(amountCtrl.text) ?? 0;
                  final shares = type == 'equal'
                      ? SplitController.calculateEqualSplit(total, list.length)
                      : customShares.toList();

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: NeoBrutalismTheme.neoBox(
                      color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentBeige, isDark),
                      offset: 3, borderColor: NeoBrutalismTheme.primaryBlack,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PREVIEW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
                            color: NeoBrutalismTheme.primaryBlack, letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        ...list.asMap().entries.map((e) {
                          final share = e.key < shares.length ? shares[e.key] : 0.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.value, style: const TextStyle(fontSize: 13,
                                    fontWeight: FontWeight.w700, color: NeoBrutalismTheme.primaryBlack)),
                                Text('₹${share.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13,
                                    fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // Save button
                NeoButton(
                  text: 'CREATE SPLIT',
                  onPressed: () => _save(
                    titleCtrl.text, amountCtrl.text, paidBy.value,
                    participants, splitType.value, customShares, notesCtrl.text,
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

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 16,
        left: 20, right: 20, bottom: 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? NeoBrutalismTheme.darkSurface
            : NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentLilac, isDark),
        border: const Border(bottom: BorderSide(
            color: NeoBrutalismTheme.primaryBlack, width: NeoBrutalismTheme.borderWidth)),
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
          Text('NEW SPLIT', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
              letterSpacing: -1,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
        color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack));
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, bool isDark,
      {String? prefixText, TextInputType? keyboardType, int maxLines = 1}) {
    return Container(
      decoration: NeoBrutalismTheme.neoBox(
        color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
        offset: 3, borderColor: NeoBrutalismTheme.primaryBlack,
      ),
      child: TextField(
        controller: ctrl, keyboardType: keyboardType, maxLines: maxLines,
        style: TextStyle(fontWeight: FontWeight.w600,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
        decoration: InputDecoration(
          hintText: hint, prefixText: prefixText,
          border: InputBorder.none, contentPadding: const EdgeInsets.all(14),
          hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
        ),
      ),
    );
  }

  void _save(String title, String amountStr, String paidBy,
      RxList<String> participants, String splitType, RxList<double> customShares, String notes) {
    if (title.trim().isEmpty) {
      Get.snackbar('Error', 'Title is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final amount = double.tryParse(amountStr) ?? 0;
    if (amount <= 0) {
      Get.snackbar('Error', 'Enter a valid amount', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (participants.length < 2) {
      Get.snackbar('Error', 'Add at least 2 people', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (paidBy.isEmpty) {
      Get.snackbar('Error', 'Select who paid', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final shares = splitType == 'equal'
        ? SplitController.calculateEqualSplit(amount, participants.length)
        : customShares.toList();

    final split = SplitModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      totalAmount: amount,
      paidBy: paidBy,
      participants: List<String>.from(participants),
      shares: shares,
      settled: List.generate(participants.length,
              (i) => participants[i] == paidBy),
      splitType: splitType,
      createdAt: DateTime.now(),
      notes: notes.trim().isEmpty ? null : notes.trim(),
    );

    controller.addSplit(split);
    Navigator.of(Get.context!).pop();
  }
}