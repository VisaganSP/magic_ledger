import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/services/pdf_service.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../../widgets/neo_date_range_picker.dart';
import '../../account/controllers/account_controller.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

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
          _buildPeriodChips(isDark, context),
          _buildCustomDateBanner(isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                _buildOverviewCards(isDark),
                const SizedBox(height: 16),
                _buildComparisonBar(isDark),
                const SizedBox(height: 16),
                _buildTrendChart(isDark),
                const SizedBox(height: 16),
                _buildCategoryBreakdown(isDark),
                const SizedBox(height: 16),
                _buildInsightsGrid(isDark),
                const SizedBox(height: 16),
                _buildProjection(isDark),
                const SizedBox(height: 16),
                _buildTopExpenses(isDark),
                const SizedBox(height: 16),
                _buildExportSection(isDark),
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

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ANALYTICS',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  color: isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
                ),
              ),
              Obx(() => Text(
                controller.getDateRangeString(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              )),
            ],
          ),
          Obx(() {
            final accountController = Get.find<AccountController>();
            final accId = accountController.selectedAccountId.value;
            final label = accId == null
                ? 'ALL'
                : accountController.getAccountForDisplay(accId).name.toUpperCase();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: NeoBrutalismTheme.neoBox(
                color: _t(NeoBrutalismTheme.accentSkyBlue, isDark),
                offset: 2,
                borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.primaryBlack,
                ),
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ═══════════════════════════════════════════════════════════
  // PERIOD CHIPS
  // ═══════════════════════════════════════════════════════════

  Widget _buildPeriodChips(bool isDark, BuildContext context) {
    final periods = ['This Week', 'This Month', '3 Months', '6 Months', 'This Year', 'Custom'];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: periods.length,
        itemBuilder: (ctx, index) {
          final period = periods[index];
          return Obx(() {
            final isSelected = controller.selectedPeriod.value == period;
            return GestureDetector(
              onTap: () {
                if (period == 'Custom') {
                  showDialog(
                    context: context,
                    builder: (_) => NeoDateRangePicker(
                      initialStartDate: controller.customStartDate.value,
                      initialEndDate: controller.customEndDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      onDateRangeSelected: (s, e) {
                        if (s != null && e != null) controller.setCustomDateRange(s, e);
                      },
                    ),
                  );
                } else {
                  controller.changePeriod(period);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: isSelected
                    ? NeoBrutalismTheme.neoBox(
                  color: _t(NeoBrutalismTheme.accentPink, isDark),
                  offset: 2,
                  borderColor: NeoBrutalismTheme.primaryBlack,
                )
                    : BoxDecoration(
                  color: isDark
                      ? NeoBrutalismTheme.darkSurface
                      : NeoBrutalismTheme.primaryWhite,
                  border: Border.all(
                    color: NeoBrutalismTheme.primaryBlack,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (period == 'Custom') ...[
                      Icon(Icons.date_range, size: 13,
                          color: isSelected
                              ? NeoBrutalismTheme.primaryBlack
                              : (isDark ? Colors.grey[500] : Colors.grey[600])),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      period.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isSelected
                            ? NeoBrutalismTheme.primaryBlack
                            : (isDark ? Colors.grey[500] : Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildCustomDateBanner(bool isDark) {
    return Obx(() {
      if (controller.selectedPeriod.value != 'Custom' ||
          controller.customStartDate.value == null) {
        return const SizedBox.shrink();
      }
      final s = controller.customStartDate.value!;
      final e = controller.customEndDate.value!;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: NeoBrutalismTheme.neoBox(
            color: _t(NeoBrutalismTheme.accentSkyBlue, isDark),
            offset: 2,
            borderColor: NeoBrutalismTheme.primaryBlack,
          ),
          child: Row(
            children: [
              const Icon(Icons.date_range, size: 16, color: NeoBrutalismTheme.primaryBlack),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${s.day}/${s.month}/${s.year} — ${e.day}/${e.month}/${e.year}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                      color: NeoBrutalismTheme.primaryBlack),
                ),
              ),
              GestureDetector(
                onTap: () => controller.changePeriod('This Month'),
                child: const Icon(Icons.close, size: 16, color: NeoBrutalismTheme.primaryBlack),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════
  // OVERVIEW CARDS — 3 key numbers
  // ═══════════════════════════════════════════════════════════

  Widget _buildOverviewCards(bool isDark) {
    return Obx(() => Row(
      children: [
        Expanded(
          child: _buildMiniCard(
            label: 'SPENT',
            value: _fmt(controller.totalSpent.value),
            color: _t(NeoBrutalismTheme.accentOrange, isDark),
            icon: Icons.arrow_upward_rounded,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniCard(
            label: 'EARNED',
            value: _fmt(controller.totalEarned.value),
            color: _t(NeoBrutalismTheme.accentGreen, isDark),
            icon: Icons.arrow_downward_rounded,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniCard(
            label: 'NET',
            value: _fmt(controller.netFlow.value),
            color: controller.netFlow.value >= 0
                ? _t(NeoBrutalismTheme.accentSage, isDark)
                : _t(NeoBrutalismTheme.accentPink, isDark),
            icon: Icons.balance,
            isDark: isDark,
          ),
        ),
      ],
    )).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildMiniCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: NeoBrutalismTheme.neoBox(
        color: color,
        offset: 3,
        borderColor: NeoBrutalismTheme.primaryBlack,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 16, color: NeoBrutalismTheme.primaryBlack),
              Text(label,
                  style: const TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w900,
                      color: NeoBrutalismTheme.primaryBlack, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '₹$value',
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.primaryBlack),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // COMPARISON BAR
  // ═══════════════════════════════════════════════════════════

  Widget _buildComparisonBar(bool isDark) {
    return Obx(() {
      final sc = controller.spendingChange.value;
      final ic = controller.incomeChange.value;
      final sr = controller.savingsRate.value;

      return Row(
        children: [
          Expanded(child: _buildChangePill('Spending', sc, true, isDark)),
          const SizedBox(width: 8),
          Expanded(child: _buildChangePill('Income', ic, false, isDark)),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: NeoBrutalismTheme.neoBox(
                color: isDark
                    ? NeoBrutalismTheme.darkSurface
                    : NeoBrutalismTheme.primaryWhite,
                offset: 2,
                borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SAVINGS', style: TextStyle(fontSize: 8,
                      fontWeight: FontWeight.w900, letterSpacing: 0.5,
                      color: isDark ? Colors.grey[500] : Colors.grey[500])),
                  const SizedBox(height: 2),
                  Text(
                    '${sr.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w900,
                      color: sr >= 0
                          ? (isDark ? Colors.green[400] : Colors.green[700])
                          : (isDark ? Colors.red[400] : Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }).animate().fadeIn(delay: 250.ms);
  }

  Widget _buildChangePill(String label, double change, bool isExpense, bool isDark) {
    final isGood = isExpense ? change < 0 : change > 0;
    final color = change == 0
        ? (isDark ? Colors.grey[400]! : Colors.grey[600]!)
        : (isGood
        ? (isDark ? Colors.green[400]! : Colors.green[700]!)
        : (isDark ? Colors.red[400]! : Colors.red[600]!));

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: NeoBrutalismTheme.neoBox(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : NeoBrutalismTheme.primaryWhite,
        offset: 2,
        borderColor: NeoBrutalismTheme.primaryBlack,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 8,
              fontWeight: FontWeight.w900, letterSpacing: 0.5,
              color: isDark ? Colors.grey[500] : Colors.grey[500])),
          const SizedBox(height: 2),
          Row(
            children: [
              if (change != 0)
                Icon(change > 0 ? Icons.trending_up : Icons.trending_down,
                    size: 13, color: color),
              if (change != 0) const SizedBox(width: 2),
              Text(
                change == 0 ? '—' : '${change.abs().toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TREND CHART — expense + income lines
  // ═══════════════════════════════════════════════════════════

  Widget _buildTrendChart(bool isDark) {
    return NeoCard(
      color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CASH FLOW TREND', style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
              // Legend
              Row(
                children: [
                  Container(width: 10, height: 10, color: _t(NeoBrutalismTheme.accentPink, isDark)),
                  const SizedBox(width: 4),
                  Text('Spent', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  const SizedBox(width: 10),
                  Container(width: 10, height: 10, color: _t(NeoBrutalismTheme.accentGreen, isDark)),
                  const SizedBox(width: 4),
                  Text('Earned', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.grey[400] : Colors.grey[600])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.expenseTrendData.isEmpty) {
              return SizedBox(
                height: 180,
                child: Center(
                  child: Text('No data for this period',
                      style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500])),
                ),
              );
            }

            return SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i >= 0 && i < controller.trendLabels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(controller.trendLabels[i],
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.grey[500] : Colors.grey[600])),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (value, meta) => Text(
                          _fmtAxis(value),
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                              color: isDark ? Colors.grey[500] : Colors.grey[600]),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
                  ),
                  lineBarsData: [
                    // Expense line
                    LineChartBarData(
                      spots: controller.expenseTrendData.asMap().entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: _t(NeoBrutalismTheme.accentPink, isDark),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                          radius: 4,
                          color: _t(NeoBrutalismTheme.accentPink, isDark),
                          strokeWidth: 2,
                          strokeColor: NeoBrutalismTheme.primaryBlack,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _t(NeoBrutalismTheme.accentPink, isDark).withOpacity(0.1),
                      ),
                    ),
                    // Income line
                    LineChartBarData(
                      spots: controller.incomeTrendData.asMap().entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: _t(NeoBrutalismTheme.accentGreen, isDark),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                          radius: 4,
                          color: _t(NeoBrutalismTheme.accentGreen, isDark),
                          strokeWidth: 2,
                          strokeColor: NeoBrutalismTheme.primaryBlack,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _t(NeoBrutalismTheme.accentGreen, isDark).withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  // ═══════════════════════════════════════════════════════════
  // CATEGORY BREAKDOWN — pie + legend
  // ═══════════════════════════════════════════════════════════

  Widget _buildCategoryBreakdown(bool isDark) {
    return NeoCard(
      color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WHERE YOUR MONEY GOES', style: TextStyle(fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.categoryData.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(child: Text('No expenses yet',
                    style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500]))),
              );
            }

            return Column(
              children: [
                SizedBox(
                  height: 180,
                  child: PieChart(PieChartData(
                    sections: controller.categoryData.map((d) {
                      final amount = (d['amount'] as num).toDouble();
                      final pct = d['percentage'] as int;
                      final color = _t(d['color'] as Color, isDark);
                      return PieChartSectionData(
                        value: amount,
                        title: pct >= 5 ? '$pct%' : '',
                        color: color,
                        radius: 70,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
                            color: NeoBrutalismTheme.primaryBlack),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                  )),
                ),
                const SizedBox(height: 16),
                ...controller.categoryData.take(6).map((d) {
                  final name = d['name'] as String;
                  final icon = d['icon'] as String;
                  final amount = (d['amount'] as num).toDouble();
                  final pct = d['percentage'] as int;
                  final color = _t(d['color'] as Color, isDark);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5),
                          ),
                          child: Center(child: Text(icon, style: const TextStyle(fontSize: 14))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                              // Mini progress bar
                              const SizedBox(height: 3),
                              Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: FractionallySizedBox(
                                  widthFactor: (pct / 100).clamp(0.0, 1.0),
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('₹${_fmt(amount)}', style: TextStyle(fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                            Text('$pct%', style: TextStyle(fontSize: 10,
                                color: isDark ? Colors.grey[500] : Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  // ═══════════════════════════════════════════════════════════
  // INSIGHTS GRID — 4 key metrics
  // ═══════════════════════════════════════════════════════════

  Widget _buildInsightsGrid(bool isDark) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('INSIGHTS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildInsightTile(
                'Avg daily spend', '₹${_fmt(controller.avgDailySpent.value)}',
                Icons.speed, _t(NeoBrutalismTheme.accentOrange, isDark), isDark)),
            const SizedBox(width: 8),
            Expanded(child: _buildInsightTile(
                'Avg transaction', '₹${_fmt(controller.avgTransaction.value)}',
                Icons.receipt_long, _t(NeoBrutalismTheme.accentBlue, isDark), isDark)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildInsightTile(
                'Biggest expense', controller.highestExpenseTitle.value.isNotEmpty
                ? '₹${_fmt(controller.highestExpense.value)}'
                : '—',
                Icons.trending_up, _t(NeoBrutalismTheme.accentPink, isDark), isDark)),
            const SizedBox(width: 8),
            Expanded(child: _buildInsightTile(
                'Top category', controller.mostSpentCategory.value.isNotEmpty
                ? '${controller.mostSpentCategoryIcon.value} ${controller.mostSpentCategory.value}'
                : '—',
                Icons.category, _t(NeoBrutalismTheme.accentPurple, isDark), isDark)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildInsightTile(
                'Transactions', '${controller.expenseCount.value + controller.incomeCount.value}',
                Icons.swap_vert, _t(NeoBrutalismTheme.accentSkyBlue, isDark), isDark)),
            const SizedBox(width: 8),
            Expanded(child: _buildInsightTile(
                'Avg daily income', '₹${_fmt(controller.avgDailyEarned.value)}',
                Icons.arrow_downward_rounded, _t(NeoBrutalismTheme.accentGreen, isDark), isDark)),
          ],
        ),
      ],
    )).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildInsightTile(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: NeoBrutalismTheme.neoBox(
        color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
        offset: 3,
        borderColor: NeoBrutalismTheme.primaryBlack,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: color, border: Border.all(
                    color: NeoBrutalismTheme.primaryBlack, width: 1.5)),
                child: Icon(icon, size: 14, color: NeoBrutalismTheme.primaryBlack),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                    color: isDark ? Colors.grey[500] : Colors.grey[600]),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PROJECTION (current month only)
  // ═══════════════════════════════════════════════════════════

  Widget _buildProjection(bool isDark) {
    return Obx(() {
      if (controller.projectedMonthEnd.value <= 0) return const SizedBox.shrink();

      final projected = controller.projectedMonthEnd.value;
      final velocity = controller.spendingVelocity.value;
      final daysLeft = controller.daysRemaining.value;

      return NeoCard(
        color: _t(NeoBrutalismTheme.accentBeige, isDark),
        borderColor: NeoBrutalismTheme.primaryBlack,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_graph, size: 20, color: NeoBrutalismTheme.primaryBlack),
                const SizedBox(width: 8),
                const Text('MONTH-END PROJECTION', style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Projected total spend', style: TextStyle(fontSize: 11,
                        fontWeight: FontWeight.w600, color: Colors.black54)),
                    Text('₹${_fmt(projected)}', style: const TextStyle(fontSize: 22,
                        fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${_fmt(velocity)}/day', style: const TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w800, color: NeoBrutalismTheme.primaryBlack)),
                    Text('$daysLeft days left', style: const TextStyle(fontSize: 11,
                        fontWeight: FontWeight.w600, color: Colors.black54)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 550.ms);
    });
  }

  // ═══════════════════════════════════════════════════════════
  // TOP EXPENSES
  // ═══════════════════════════════════════════════════════════

  Widget _buildTopExpenses(bool isDark) {
    return NeoCard(
      color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TOP EXPENSES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.topExpenses.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(child: Text('No expenses',
                    style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500]))),
              );
            }

            final rankColors = [
              _t(NeoBrutalismTheme.accentPurple, isDark),
              _t(NeoBrutalismTheme.accentBlue, isDark),
              _t(NeoBrutalismTheme.accentGreen, isDark),
            ];

            return Column(
              children: controller.topExpenses.asMap().entries.map((entry) {
                final i = entry.key;
                final exp = entry.value;
                final color = i < 3 ? rankColors[i] : (isDark
                    ? NeoBrutalismTheme.darkBackground
                    : NeoBrutalismTheme.lightSecondaryBg);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: NeoBrutalismTheme.neoBox(
                          color: color,
                          offset: 2,
                          borderColor: NeoBrutalismTheme.primaryBlack,
                        ),
                        child: Center(child: Text('#${i + 1}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
                                color: NeoBrutalismTheme.primaryBlack))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(exp.title, style: TextStyle(fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isDark ? NeoBrutalismTheme.darkText
                                    : NeoBrutalismTheme.primaryBlack),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('${exp.date.day}/${exp.date.month}',
                                style: TextStyle(fontSize: 10,
                                    color: isDark ? Colors.grey[500] : Colors.grey[600])),
                          ],
                        ),
                      ),
                      Text('₹${exp.amount.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                              color: isDark ? Colors.red[400] : Colors.red[700])),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  // ═══════════════════════════════════════════════════════════
  // EXPORT
  // ═══════════════════════════════════════════════════════════

  Widget _buildExportSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: NeoBrutalismTheme.neoBox(
        color: _t(NeoBrutalismTheme.accentPurple, isDark),
        offset: 4,
        borderColor: NeoBrutalismTheme.primaryBlack,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.picture_as_pdf, size: 22, color: NeoBrutalismTheme.primaryBlack),
              SizedBox(width: 8),
              Text('EXPORT REPORT', style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Generate a PDF with all analytics', style: TextStyle(fontSize: 12,
              color: Colors.black54)),
          const SizedBox(height: 14),
          NeoButton(
            text: 'EXPORT AS PDF',
            onPressed: () async {
              Get.dialog(
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: NeoBrutalismTheme.neoBoxRounded(
                      color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
                      borderColor: NeoBrutalismTheme.primaryBlack,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
                        const SizedBox(height: 12),
                        Text('GENERATING...', style: TextStyle(fontWeight: FontWeight.w900,
                            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                      ],
                    ),
                  ),
                ),
                barrierDismissible: false,
              );

              await PdfService().generateAnalyticsReport(
                controller.expenseController.expenses,
                controller.categoryController.categories,
                controller.selectedPeriod.value,
              );

              Navigator.of(Get.context!).pop();
              Get.snackbar('Success', 'PDF report generated!',
                  backgroundColor: _t(NeoBrutalismTheme.accentGreen, isDark),
                  colorText: NeoBrutalismTheme.primaryBlack,
                  borderWidth: 3, borderColor: NeoBrutalismTheme.primaryBlack);
            },
            color: NeoBrutalismTheme.primaryWhite,
            icon: Icons.download,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════

  String _fmt(double v) {
    final abs = v.abs();
    final prefix = v < 0 ? '-' : '';
    if (abs >= 10000000) return '$prefix${(abs / 10000000).toStringAsFixed(1)}Cr';
    if (abs >= 100000) return '$prefix${(abs / 100000).toStringAsFixed(1)}L';
    if (abs >= 1000) return '$prefix${(abs / 1000).toStringAsFixed(1)}K';
    return '$prefix${abs.toStringAsFixed(0)}';
  }

  String _fmtAxis(double v) {
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(0)}L';
    if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(0)}K';
    return '₹${v.toStringAsFixed(0)}';
  }
}