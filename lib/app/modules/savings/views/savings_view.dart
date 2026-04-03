import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/savings_goal_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../controllers/savings_controller.dart';

class SavingsView extends GetView<SavingsController> {
  const SavingsView({super.key});

  String _cur(double v) => NumberFormat.currency(symbol: '\u{20B9}', decimalDigits: 0).format(v);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
      body: CustomScrollView(slivers: [
        SliverAppBar(expandedHeight: 90, pinned: true,
            backgroundColor: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
            foregroundColor: NeoBrutalismTheme.primaryBlack,
            flexibleSpace: const FlexibleSpaceBar(
                title: Text('SAVINGS GOALS', style: TextStyle(fontWeight: FontWeight.w900,
                    fontSize: 20, color: NeoBrutalismTheme.primaryBlack)),
                titlePadding: EdgeInsets.only(left: 56, bottom: 14))),
        SliverPadding(padding: const EdgeInsets.all(16),
            sliver: Obx(() => SliverList(delegate: SliverChildListDelegate([
              _buildOverview(isDark),
              const SizedBox(height: 16),
              if (controller.goals.isEmpty) _buildEmpty(isDark)
              else ...controller.goals.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildGoalCard(e.value, isDark, e.key))),
              const SizedBox(height: 100),
            ])))),
      ]),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.toNamed('/add-savings-goal'),
          backgroundColor: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
          label: const Text('NEW GOAL', style: TextStyle(fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.primaryBlack)),
          icon: const Icon(Icons.add, color: NeoBrutalismTheme.primaryBlack),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3))),
    );
  }

  Widget _buildOverview(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: NeoBrutalismTheme.neoBox(
          color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentYellow, isDark),
          borderColor: NeoBrutalismTheme.primaryBlack, offset: 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: NeoBrutalismTheme.primaryBlack, borderRadius: BorderRadius.circular(4)),
              child: const Text('OVERVIEW', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white))),
          const Spacer(),
          Text('${controller.activeCount} active \u2022 ${controller.completedCount} done',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: NeoBrutalismTheme.primaryBlack)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('SAVED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: NeoBrutalismTheme.primaryBlack)),
            Text(_cur(controller.totalSaved), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
          ])),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Text('TARGET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: NeoBrutalismTheme.primaryBlack)),
            Text(_cur(controller.totalTarget), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
          ])),
        ]),
        const SizedBox(height: 12),
        // Progress bar
        _progressBar(controller.overallProgress, isDark),
      ]),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildGoalCard(SavingsGoalModel goal, bool isDark, int index) {
    return Container(
      decoration: NeoBrutalismTheme.neoBox(
          color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
          borderColor: NeoBrutalismTheme.primaryBlack, offset: 4),
      child: Column(children: [
        // Header
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: goal.colorValue,
                border: const Border(bottom: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3))),
            child: Row(children: [
              Text(goal.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(goal.name.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                    color: NeoBrutalismTheme.primaryBlack)),
                if (goal.daysLeft != null)
                  Text('${goal.daysLeft} days left', style: TextStyle(fontSize: 10,
                      fontWeight: FontWeight.w700, color: Colors.black.withOpacity(0.5))),
              ])),
              if (goal.isCompleted)
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFB8E994), borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2)),
                    child: const Text('REACHED!', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900,
                        color: NeoBrutalismTheme.primaryBlack))),
              PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'delete') {
                      controller.deleteGoal(goal.id);
                      Get.snackbar('Deleted', '${goal.name} removed', backgroundColor: Colors.red, colorText: Colors.white);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                  child: const Icon(Icons.more_vert, size: 20, color: NeoBrutalismTheme.primaryBlack)),
            ])),

        // Body
        Padding(padding: const EdgeInsets.all(14), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('SAVED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
              Text(_cur(goal.savedAmount), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.primaryBlack)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('TARGET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
              Text(_cur(goal.targetAmount), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
            ]),
          ]),
          const SizedBox(height: 12),
          _progressBar(goal.progress, isDark),
          const SizedBox(height: 12),
          // Insight row
          Row(children: [
            Expanded(child: _insightTile('${goal.progress.toStringAsFixed(0)}%', 'Progress',
                const Color(0xFFB8E994), isDark)),
            const SizedBox(width: 8),
            Expanded(child: _insightTile(_cur(goal.remaining), 'Remaining',
                const Color(0xFFBFE3F0), isDark)),
            if (goal.dailyRequired != null) ...[
              const SizedBox(width: 8),
              Expanded(child: _insightTile('${_cur(goal.dailyRequired!)}/d', 'Needed',
                  const Color(0xFFFDD663), isDark)),
            ],
          ]),
          const SizedBox(height: 12),
          // Action buttons
          if (!goal.isCompleted) Row(children: [
            Expanded(child: NeoButton(text: 'ADD MONEY', onPressed: () => _showContributeDialog(goal, isDark),
                color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentGreen, isDark), icon: Icons.add)),
            const SizedBox(width: 8),
            Expanded(child: NeoButton(text: 'WITHDRAW', onPressed: () => _showWithdrawDialog(goal, isDark),
                color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentOrange, isDark), icon: Icons.remove)),
          ]),
        ])),
      ]),
    ).animate().fadeIn(delay: (150 * index).ms).slideX(begin: 0.1, end: 0);
  }

  Widget _insightTile(String value, String label, Color color, bool isDark) {
    return Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(isDark ? 0.2 : 0.4),
            borderRadius: BorderRadius.circular(8), border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          Text(label, style: TextStyle(fontSize: 9, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ]));
  }

  Widget _progressBar(double pct, bool isDark) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('${pct.toStringAsFixed(0)}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
      ]),
      const SizedBox(height: 4),
      Container(height: 14,
          decoration: BoxDecoration(border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
              borderRadius: BorderRadius.circular(7)),
          child: ClipRRect(borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(value: (pct / 100).clamp(0, 1),
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(pct >= 100 ? const Color(0xFF00CC66) : const Color(0xFF4D94FF)),
                  minHeight: 14))),
    ]);
  }

  Widget _buildEmpty(bool isDark) {
    return Container(padding: const EdgeInsets.all(40),
        decoration: NeoBrutalismTheme.neoBox(
            color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack, offset: 4),
        child: Column(children: [
          const Text('\u{1F3AF}', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('No savings goals yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 8),
          Text('Start saving toward something!', style: TextStyle(fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ]));
  }

  void _showContributeDialog(SavingsGoalModel goal, bool isDark) {
    final tc = TextEditingController();
    Get.dialog(Dialog(backgroundColor: Colors.transparent, child: Container(
        padding: const EdgeInsets.all(24),
        decoration: NeoBrutalismTheme.neoBoxRounded(
            color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('ADD TO ${goal.name.toUpperCase()}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 16),
          TextField(controller: tc, keyboardType: TextInputType.number, autofocus: true,
              decoration: InputDecoration(hintText: '0.00', prefixText: '\u{20B9} ',
                  border: OutlineInputBorder(borderSide: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3)))),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: NeoButton(text: 'CANCEL', onPressed: () => Get.back(), color: NeoBrutalismTheme.primaryWhite)),
            const SizedBox(width: 12),
            Expanded(child: NeoButton(text: 'ADD', onPressed: () {
              final amt = double.tryParse(tc.text) ?? 0;
              if (amt > 0) { controller.contribute(goal.id, amt); Get.back();
              Get.snackbar('\u{1F389} Saved!', '\u{20B9}${amt.toStringAsFixed(0)} added to ${goal.name}',
                  backgroundColor: const Color(0xFFB8E994), colorText: NeoBrutalismTheme.primaryBlack); }
            }, color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentGreen, isDark))),
          ]),
        ]))));
  }

  void _showWithdrawDialog(SavingsGoalModel goal, bool isDark) {
    final tc = TextEditingController();
    Get.dialog(Dialog(backgroundColor: Colors.transparent, child: Container(
        padding: const EdgeInsets.all(24),
        decoration: NeoBrutalismTheme.neoBoxRounded(
            color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('WITHDRAW FROM ${goal.name.toUpperCase()}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 8),
          Text('Available: ${_cur(goal.savedAmount)}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 16),
          TextField(controller: tc, keyboardType: TextInputType.number, autofocus: true,
              decoration: InputDecoration(hintText: '0.00', prefixText: '\u{20B9} ',
                  border: OutlineInputBorder(borderSide: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3)))),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: NeoButton(text: 'CANCEL', onPressed: () => Get.back(), color: NeoBrutalismTheme.primaryWhite)),
            const SizedBox(width: 12),
            Expanded(child: NeoButton(text: 'WITHDRAW', onPressed: () {
              final amt = double.tryParse(tc.text) ?? 0;
              if (amt > 0 && amt <= goal.savedAmount) { controller.withdraw(goal.id, amt); Get.back(); }
            }, color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentOrange, isDark))),
          ]),
        ]))));
  }
}