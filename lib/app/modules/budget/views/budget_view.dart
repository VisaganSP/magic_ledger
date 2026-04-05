import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/budget_model.dart';
import '../../../data/services/pdf_service.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../category/controllers/category_controller.dart';
import '../controllers/budget_controller.dart';

class BudgetView extends GetView<BudgetController> {
  const BudgetView({super.key});

  final _cur = const _Cur();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catCtrl = Get.find<CategoryController>();

    return Scaffold(
      backgroundColor: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomScrollView(
          slivers: [
            _buildAppBar(isDark),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(delegate: SliverChildListDelegate([
                _buildHealthDashboard(isDark),
                const SizedBox(height: 16),
                if (controller.activeBudgets.isNotEmpty) _buildDailyAllowanceStrip(isDark),
                if (controller.activeBudgets.isNotEmpty) const SizedBox(height: 16),
                _buildOverallSection(isDark),
                const SizedBox(height: 16),
                _buildCategorySection(catCtrl, isDark),
                const SizedBox(height: 16),
                if (controller.activeBudgets.isNotEmpty) _buildProjectionCard(isDark),
                if (controller.activeBudgets.isNotEmpty) const SizedBox(height: 16),
                _buildActionsRow(isDark),
                const SizedBox(height: 100),
              ])),
            ),
          ],
        );
      }),
      floatingActionButton: _buildFab(isDark),
    );
  }

  // ─── APP BAR ─────────────────────────────────────────────

  SliverAppBar _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      backgroundColor: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentBlue, isDark),
      foregroundColor: NeoBrutalismTheme.primaryBlack,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('BUDGETS', style: TextStyle(fontWeight: FontWeight.w900,
            fontSize: 20, color: NeoBrutalismTheme.primaryBlack)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
      ),
    );
  }

  // ─── HEALTH DASHBOARD ────────────────────────────────────

  Widget _buildHealthDashboard(bool isDark) {
    final summary = controller.getBudgetSummary();
    final pctUsed = (summary['percentageUsed'] as double);
    final exceeded = summary['exceededCount'] as int;
    final onTrack = summary['onTrackCount'] as int;
    final total = summary['totalBudgets'] as int;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: NeoBrutalismTheme.neoBox(
        color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentYellow, isDark),
        borderColor: NeoBrutalismTheme.primaryBlack, offset: 5,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: NeoBrutalismTheme.primaryBlack,
                borderRadius: BorderRadius.circular(4)),
            child: const Text('OVERVIEW', style: TextStyle(fontSize: 10,
                fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const Spacer(),
          Text('${total} budget${total != 1 ? 's' : ''} active',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: NeoBrutalismTheme.primaryBlack)),
        ]),
        const SizedBox(height: 14),
        // Summary row
        Row(children: [
          Expanded(child: _miniStat('BUDGETED', _cur.f(summary['totalBudget']),
              NeoBrutalismTheme.primaryBlack, isDark)),
          const SizedBox(width: 10),
          Expanded(child: _miniStat('SPENT', _cur.f(summary['totalSpent']),
              pctUsed > 100 ? Colors.red : NeoBrutalismTheme.primaryBlack, isDark)),
          const SizedBox(width: 10),
          Expanded(child: _miniStat('LEFT', _cur.f(summary['totalRemaining']),
              (summary['totalRemaining'] as double) < 0 ? Colors.red : const Color(0xFF00CC66), isDark)),
        ]),
        const SizedBox(height: 14),
        // Progress
        _progressBar(pctUsed, isDark),
        const SizedBox(height: 10),
        // Status pills
        Row(children: [
          _statusPill('$onTrack on track', const Color(0xFFB8E994)),
          const SizedBox(width: 8),
          if (exceeded > 0) _statusPill('$exceeded exceeded', const Color(0xFFE57373)),
        ]),
      ]),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _miniStat(String label, String value, Color valueColor, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
          color: NeoBrutalismTheme.primaryBlack, letterSpacing: 0.5)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: valueColor)),
    ]);
  }

  Widget _statusPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2)),
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
          color: NeoBrutalismTheme.primaryBlack)),
    );
  }

  // ─── DAILY ALLOWANCE STRIP ───────────────────────────────

  Widget _buildDailyAllowanceStrip(bool isDark) {
    // Show combined daily allowance across all budgets
    double totalAllowance = 0;
    for (final b in controller.activeBudgets) {
      totalAllowance += controller.getDailyAllowance(b);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: NeoBrutalismTheme.neoBox(
        color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
        borderColor: NeoBrutalismTheme.primaryBlack, offset: 4,
      ),
      child: Row(children: [
        const Icon(Icons.today, size: 22, color: NeoBrutalismTheme.primaryBlack),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("TODAY'S LIMIT", style: TextStyle(fontSize: 10,
              fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
          Text(_cur.f(totalAllowance), style: const TextStyle(fontSize: 20,
              fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
        ]),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Text('to stay on budget', style: TextStyle(fontSize: 11,
              fontWeight: FontWeight.w600, color: NeoBrutalismTheme.primaryBlack)),
          Text('across all budgets', style: TextStyle(fontSize: 10,
              color: Colors.black.withOpacity(0.5))),
        ]),
      ]),
    ).animate().fadeIn(delay: 100.ms);
  }

  // ─── OVERALL BUDGET ──────────────────────────────────────

  Widget _buildOverallSection(bool isDark) {
    final overall = controller.getOverallBudget();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('OVERALL BUDGET', isDark),
      const SizedBox(height: 10),
      overall != null
          ? _buildBudgetCard(overall, null, isDark, 0)
          : _emptyCard('No overall budget set', 'Set a total spending limit', isDark),
    ]);
  }

  // ─── CATEGORY BUDGETS ────────────────────────────────────

  Widget _buildCategorySection(CategoryController catCtrl, bool isDark) {
    final catBudgets = controller.getCategoryBudgets();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('CATEGORY BUDGETS', isDark),
      const SizedBox(height: 10),
      if (catBudgets.isEmpty)
        _emptyCard('No category budgets', 'Set limits per category', isDark)
      else
        ...catBudgets.asMap().entries.map((entry) {
          final cat = catCtrl.getCategoryById(entry.value.categoryId!);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildBudgetCard(entry.value, cat, isDark, entry.key + 1),
          );
        }),
    ]);
  }

  // ─── BUDGET CARD (the main piece) ────────────────────────

  Widget _buildBudgetCard(BudgetModel budget, dynamic cat, bool isDark, int i) {
    final spent = controller.getSpentAmount(budget);
    final pct = controller.getPercentageUsed(budget);
    final exceeded = controller.isBudgetExceeded(budget);
    final grade = controller.getGrade(budget);
    final gradeColor = controller.getGradeColor(grade);
    final allowance = controller.getDailyAllowance(budget);
    final projected = controller.getProjectedSpend(budget);
    final streak = controller.getStreak(budget);
    final daysLeft = controller.daysRemaining(budget);
    final velocity = controller.getVelocity(budget);
    final willExceed = controller.isOnTrackToExceed(budget);

    final cardColor = cat != null
        ? NeoBrutalismTheme.getThemedColor(cat.colorValue, isDark)
        : NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentPurple, isDark);

    return Container(
      decoration: NeoBrutalismTheme.neoBox(
        color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
        borderColor: NeoBrutalismTheme.primaryBlack, offset: 5,
      ),
      child: Column(children: [
        // Header strip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: cardColor,
            border: const Border(bottom: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3)),
          ),
          child: Row(children: [
            if (cat != null) Text(cat.icon, style: const TextStyle(fontSize: 24))
            else const Icon(Icons.account_balance_wallet, size: 24, color: NeoBrutalismTheme.primaryBlack),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cat?.name.toUpperCase() ?? 'OVERALL', style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
              Text('${budget.period.toUpperCase()} \u2022 $daysLeft days left',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.6))),
            ])),
            // Grade badge
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: gradeColor, shape: BoxShape.circle,
                border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2.5),
              ),
              child: Center(child: Text(grade, style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack))),
            ),
            const SizedBox(width: 6),
            _budgetMenu(budget, isDark),
          ]),
        ),

        Padding(padding: const EdgeInsets.all(14), child: Column(children: [
          // Budget vs Spent
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('BUDGET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                  color: NeoBrutalismTheme.primaryBlack)),
              Text(_cur.f(budget.amount), style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
            ])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('SPENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                  color: NeoBrutalismTheme.primaryBlack)),
              Text(_cur.f(spent), style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900,
                  color: exceeded ? Colors.red : NeoBrutalismTheme.primaryBlack)),
            ])),
          ]),
          const SizedBox(height: 12),

          // Progress bar
          _progressBar(pct, isDark),
          const SizedBox(height: 10),

          // Remaining + exceeded badge
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Remaining: ${_cur.f(controller.getRemainingAmount(budget))}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: exceeded ? Colors.red : (isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack))),
            if (exceeded) Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2)),
              child: const Text('EXCEEDED', style: TextStyle(fontSize: 9,
                  fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ]),
          const SizedBox(height: 12),

          // Insight tiles (2x2 grid)
          Row(children: [
            Expanded(child: _insightTile('\u{20B9}${allowance.toStringAsFixed(0)}/day',
                'Daily limit', Icons.today, const Color(0xFFB8E994), isDark)),
            const SizedBox(width: 8),
            Expanded(child: _insightTile('\u{20B9}${velocity.toStringAsFixed(0)}/day',
                'Current pace', Icons.speed, const Color(0xFFBFE3F0), isDark)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _insightTile('$streak day${streak != 1 ? 's' : ''}',
                'On-pace streak', Icons.local_fire_department, const Color(0xFFFDD663), isDark)),
            const SizedBox(width: 8),
            Expanded(child: _insightTile(willExceed ? 'Over budget' : 'Under budget',
                'Projection', willExceed ? Icons.trending_up : Icons.trending_down,
                willExceed ? const Color(0xFFE57373) : const Color(0xFFB8E994), isDark)),
          ]),
        ])),
      ]),
    ).animate().fadeIn(delay: (200 + i * 100).ms).slideX(begin: 0.15, end: 0);
  }

  Widget _insightTile(String value, String label, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5),
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: NeoBrutalismTheme.primaryBlack),
        const SizedBox(width: 6),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ])),
      ]),
    );
  }

  // ─── PROJECTION CARD ─────────────────────────────────────

  Widget _buildProjectionCard(bool isDark) {
    final overall = controller.getOverallBudget();
    if (overall == null && controller.getCategoryBudgets().isEmpty) return const SizedBox();

    // Aggregate projections
    double totalProjected = 0;
    double totalBudget = 0;
    for (final b in controller.activeBudgets) {
      totalProjected += controller.getProjectedSpend(b);
      totalBudget += b.amount;
    }
    final willExceed = totalProjected > totalBudget;
    final diff = (totalProjected - totalBudget).abs();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: NeoBrutalismTheme.neoBox(
        color: willExceed
            ? (isDark ? const Color(0xFF4A1B1B) : const Color(0xFFFFE0E0))
            : (isDark ? const Color(0xFF1B3A1B) : const Color(0xFFD4E4D1)),
        borderColor: NeoBrutalismTheme.primaryBlack, offset: 4,
      ),
      child: Row(children: [
        Icon(willExceed ? Icons.warning_amber : Icons.check_circle,
            size: 28, color: willExceed ? Colors.red : const Color(0xFF00CC66)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(willExceed ? 'PROJECTED TO EXCEED' : 'PROJECTED ON TRACK',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 2),
          Text(willExceed
              ? 'Estimated \u{20B9}${diff.toStringAsFixed(0)} over budget at current pace'
              : 'Estimated \u{20B9}${diff.toStringAsFixed(0)} under budget at current pace',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[700])),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(_cur.f(totalProjected), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
              color: willExceed ? Colors.red : const Color(0xFF00CC66))),
          Text('of ${_cur.f(totalBudget)}', style: TextStyle(fontSize: 10,
              color: isDark ? Colors.grey[500] : Colors.grey[600])),
        ]),
      ]),
    ).animate().fadeIn(delay: 400.ms);
  }

  // ─── ACTIONS ROW ─────────────────────────────────────────

  Widget _buildActionsRow(bool isDark) {
    return Row(children: [
      Expanded(child: NeoButton(
        text: 'EXPORT REPORT',
        onPressed: () => _exportReport(),
        color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentPurple, isDark),
        icon: Icons.picture_as_pdf,
      )),
      const SizedBox(width: 12),
      Expanded(child: NeoButton(
        text: 'TEST ALERTS',
        onPressed: () {
          controller.recheckAlerts();
          Get.snackbar('Alerts', 'Budget alerts rechecked',
              backgroundColor: NeoBrutalismTheme.accentBlue,
              colorText: NeoBrutalismTheme.primaryBlack,
              borderWidth: 3, borderColor: NeoBrutalismTheme.primaryBlack,
              duration: const Duration(seconds: 2));
        },
        color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentOrange, isDark),
        icon: Icons.notifications_active,
      )),
    ]).animate().fadeIn(delay: 500.ms);
  }

  void _exportReport() {
    final data = controller.getReportData();
    if (data.isEmpty) {
      Get.snackbar('No Data', 'Add budgets first to generate a report',
          backgroundColor: Colors.orange, colorText: NeoBrutalismTheme.primaryBlack);
      return;
    }
    // Use PdfService to generate budget report
    Get.snackbar('Coming Soon', 'Budget PDF report will be generated',
        backgroundColor: NeoBrutalismTheme.accentPurple,
        colorText: NeoBrutalismTheme.primaryBlack,
        borderWidth: 3, borderColor: NeoBrutalismTheme.primaryBlack);
  }

  // ─── SHARED COMPONENTS ───────────────────────────────────

  Widget _progressBar(double pct, bool isDark) {
    final clamped = pct.clamp(0.0, 100.0);
    Color barColor;
    if (pct > 100) barColor = Colors.red;
    else if (pct > 80) barColor = const Color(0xFFFF8533);
    else if (pct > 50) barColor = const Color(0xFFFDD663);
    else barColor = const Color(0xFF00CC66);

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('${pct.toStringAsFixed(0)}% used',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        if (pct > 100)
          Text('${(pct - 100).toStringAsFixed(0)}% over',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.red)),
      ]),
      const SizedBox(height: 6),
      Container(
        height: 16,
        decoration: BoxDecoration(
          border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: clamped / 100,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(barColor),
            minHeight: 16,
          ),
        ),
      ),
    ]);
  }

  Widget _sectionTitle(String text, bool isDark) {
    return Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
        color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack));
  }

  Widget _emptyCard(String title, String sub, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: NeoBrutalismTheme.neoBox(
        color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
        borderColor: NeoBrutalismTheme.primaryBlack, offset: 4,
      ),
      child: Column(children: [
        Icon(Icons.account_balance_wallet, size: 40, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
            color: isDark ? Colors.grey[400] : Colors.grey[600])),
        const SizedBox(height: 4),
        Text(sub, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[600] : Colors.grey[500]),
            textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _budgetMenu(BudgetModel budget, bool isDark) {
    return PopupMenuButton<String>(
      onSelected: (v) {
        if (v == 'edit') Get.toNamed('/edit-budget', arguments: budget);
        else if (v == 'delete') _showDeleteDialog(budget, isDark);
        else if (v == 'toggle') controller.toggleBudgetStatus(budget.id);
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'toggle', child: Text(budget.isActive ? 'Deactivate' : 'Activate')),
        const PopupMenuItem(value: 'delete',
            child: Text('Delete', style: TextStyle(color: Colors.red))),
      ],
      child: const Icon(Icons.more_vert, size: 20, color: NeoBrutalismTheme.primaryBlack),
    );
  }

  Widget _buildFab(bool isDark) {
    return FloatingActionButton.extended(
      onPressed: () => Get.toNamed('/add-budget'),
      backgroundColor: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
      label: const Text('ADD BUDGET', style: TextStyle(fontWeight: FontWeight.w900,
          color: NeoBrutalismTheme.primaryBlack)),
      icon: const Icon(Icons.add, color: NeoBrutalismTheme.primaryBlack),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3)),
    );
  }

  void _showDeleteDialog(BudgetModel budget, bool isDark) {
    Get.dialog(Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: NeoBrutalismTheme.neoBoxRounded(
            color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.warning, size: 44, color: Colors.red),
          const SizedBox(height: 14),
          const Text('DELETE BUDGET?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          const Text('This cannot be undone.', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: NeoButton(text: 'CANCEL', onPressed: () => Navigator.of(Get.context!).pop(),
                color: NeoBrutalismTheme.primaryWhite)),
            const SizedBox(width: 12),
            Expanded(child: NeoButton(text: 'DELETE', onPressed: () {
              controller.deleteBudget(budget.id);
              Navigator.of(Get.context!).pop();
              Get.snackbar('Deleted', 'Budget removed',
                  backgroundColor: NeoBrutalismTheme.accentGreen,
                  colorText: NeoBrutalismTheme.primaryBlack);
            }, color: Colors.red, textColor: Colors.white)),
          ]),
        ]),
      ),
    ));
  }
}

/// Currency formatter helper
class _Cur {
  const _Cur();
  String f(dynamic v) {
    final val = (v is double) ? v : (v as num).toDouble();
    return NumberFormat.currency(symbol: '\u{20B9}', decimalDigits: 0).format(val);
  }
}