import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/services/pdf_service.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalismTheme.primaryWhite,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildDateRangeSelector(),
          const SizedBox(height: 24),
          _buildTotalStats(),
          const SizedBox(height: 24),
          _buildCategoryBreakdown(),
          const SizedBox(height: 24),
          _buildSpendingTrend(),
          const SizedBox(height: 24),
          _buildTopExpenses(),
          const SizedBox(height: 24),
          _buildExportSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'ANALYTICS',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: NeoBrutalismTheme.neoBox(
              color: NeoBrutalismTheme.accentBlue,
            ),
            child: Text(
              controller.selectedPeriod.value.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }

  Widget _buildDateRangeSelector() {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TIME PERIOD',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildPeriodChip('This Week'),
              _buildPeriodChip('This Month'),
              _buildPeriodChip('3 Months'),
              _buildPeriodChip('6 Months'),
              _buildPeriodChip('This Year'),
              _buildPeriodChip('Custom'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildPeriodChip(String period) {
    return Obx(() {
      final isSelected = controller.selectedPeriod.value == period;
      return GestureDetector(
        onTap: () => controller.changePeriod(period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: NeoBrutalismTheme.neoBox(
            color:
                isSelected
                    ? NeoBrutalismTheme.accentPink
                    : NeoBrutalismTheme.primaryWhite,
            offset: isSelected ? 2 : 5,
          ),
          child: Text(
            period.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      );
    });
  }

  Widget _buildTotalStats() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'TOTAL SPENT',
              '\$${controller.totalSpent.value.toStringAsFixed(2)}',
              NeoBrutalismTheme.accentOrange,
              Icons.payments,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'AVG DAILY',
              '\$${controller.avgDailySpent.value.toStringAsFixed(2)}',
              NeoBrutalismTheme.accentGreen,
              Icons.today,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return NeoCard(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 24),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CATEGORY BREAKDOWN',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          Obx(
            () => SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections:
                      controller.categoryData.map((data) {
                        final amount =
                            (data['amount'] as num)
                                .toDouble(); // Convert num to double
                        final percentage = data['percentage'] as int;
                        final color = data['color'] as Color;

                        return PieChartSectionData(
                          value: amount,
                          title: '$percentage%',
                          color: color,
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: NeoBrutalismTheme.primaryWhite,
                          ),
                        );
                      }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildCategoryLegend(),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildCategoryLegend() {
    return Obx(
      () => Column(
        children:
            controller.categoryData.map((data) {
              final amount =
                  (data['amount'] as num).toDouble(); // Convert num to double
              final name = data['name'] as String;
              final color = data['color'] as Color;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: NeoBrutalismTheme.primaryBlack,
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '\$${amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSpendingTrend() {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SPENDING TREND',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          Obx(
            () => SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 &&
                              index < controller.trendLabels.length) {
                            return Text(
                              controller.trendLabels[index],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: NeoBrutalismTheme.primaryBlack,
                      width: 3,
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots:
                          controller.trendData.asMap().entries.map((entry) {
                            return FlSpot(entry.key.toDouble(), entry.value);
                          }).toList(),
                      isCurved: true,
                      color: NeoBrutalismTheme.accentPink,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: NeoBrutalismTheme.accentPink,
                            strokeWidth: 2,
                            strokeColor: NeoBrutalismTheme.primaryBlack,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: NeoBrutalismTheme.accentPink.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildTopExpenses() {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOP EXPENSES',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Column(
              children:
                  controller.topExpenses.asMap().entries.map((entry) {
                    final index = entry.key;
                    final expense = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: NeoBrutalismTheme.neoBox(
                              color: _getRankColor(index),
                            ),
                            child: Center(
                              child: Text(
                                '#${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  expense.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${expense.date.day}/${expense.date.month}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${expense.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1000.ms);
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return NeoBrutalismTheme.accentYellow;
      case 1:
        return NeoBrutalismTheme.accentBlue;
      case 2:
        return NeoBrutalismTheme.accentGreen;
      default:
        return NeoBrutalismTheme.primaryWhite;
    }
  }

  Widget _buildExportSection() {
    return NeoCard(
      color: NeoBrutalismTheme.accentPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EXPORT REPORT',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Generate a beautiful PDF report with all your analytics',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),
          NeoButton(
            text: 'EXPORT AS PDF',
            onPressed: () async {
              Get.dialog(
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: NeoBrutalismTheme.neoBoxRounded(
                      color: NeoBrutalismTheme.primaryWhite,
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: NeoBrutalismTheme.primaryBlack,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'GENERATING PDF...',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
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

              Get.back();
              Get.snackbar(
                'Success',
                'PDF report generated successfully!',
                backgroundColor: NeoBrutalismTheme.accentGreen,
                colorText: NeoBrutalismTheme.primaryBlack,
                borderWidth: 3,
                borderColor: NeoBrutalismTheme.primaryBlack,
              );
            },
            color: NeoBrutalismTheme.primaryWhite,
            icon: Icons.picture_as_pdf,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1200.ms);
  }
}
