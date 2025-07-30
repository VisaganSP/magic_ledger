import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/services/pdf_service.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../../widgets/neo_date_range_picker.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? NeoBrutalismTheme.darkBackground
              : NeoBrutalismTheme.primaryWhite,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(isDark),
          const SizedBox(height: 24),
          _buildDateRangeSelector(isDark, context),
          const SizedBox(height: 24),
          _buildTotalStats(isDark),
          const SizedBox(height: 24),
          _buildCategoryBreakdown(isDark),
          const SizedBox(height: 24),
          _buildSpendingTrend(isDark),
          const SizedBox(height: 24),
          _buildTopExpenses(isDark),
          const SizedBox(height: 24),
          _buildExportSection(isDark),
        ],
      ),
    );
  }

  // Helper method to get muted colors for dark theme
  Color _getThemedColor(Color color, bool isDark) {
    if (!isDark) return color;

    // Return slightly muted versions of colors for dark theme
    if (color == NeoBrutalismTheme.accentYellow) {
      return Color(0xFFE6B800); // Slightly darker yellow
    } else if (color == NeoBrutalismTheme.accentPink) {
      return Color(0xFFE667A0); // Slightly darker pink
    } else if (color == NeoBrutalismTheme.accentBlue) {
      return Color(0xFF4D94FF); // Slightly darker blue
    } else if (color == NeoBrutalismTheme.accentGreen) {
      return Color(0xFF00CC66); // Slightly darker green
    } else if (color == NeoBrutalismTheme.accentOrange) {
      return Color(0xFFFF8533); // Slightly darker orange
    } else if (color == NeoBrutalismTheme.accentPurple) {
      return Color(0xFF9966FF); // Slightly darker purple
    }
    return color;
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ANALYTICS',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color:
                    isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
              ),
            ),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: NeoBrutalismTheme.neoBox(
                  color: _getThemedColor(NeoBrutalismTheme.accentBlue, isDark),
                  borderColor: NeoBrutalismTheme.primaryBlack,
                ),
                child: Text(
                  controller.selectedPeriod.value.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: NeoBrutalismTheme.primaryBlack,
                  ),
                ),
              ),
            ),
          ],
        ),
        // Add custom date range display if selected
        Obx(() {
          if (controller.selectedPeriod.value == 'Custom' &&
              controller.customStartDate.value != null &&
              controller.customEndDate.value != null) {
            return Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: NeoBrutalismTheme.neoBox(
                color: _getThemedColor(NeoBrutalismTheme.accentBlue, isDark),
                borderColor: NeoBrutalismTheme.primaryBlack,
                offset: 2,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.date_range,
                    size: 20,
                    color: NeoBrutalismTheme.primaryBlack,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${controller.customStartDate.value!.day}/${controller.customStartDate.value!.month}/${controller.customStartDate.value!.year} - ${controller.customEndDate.value!.day}/${controller.customEndDate.value!.month}/${controller.customEndDate.value!.year}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: NeoBrutalismTheme.primaryBlack,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: NeoBrutalismTheme.primaryBlack,
                    ),
                    onPressed: () {
                      controller.customStartDate.value = null;
                      controller.customEndDate.value = null;
                      controller.changePeriod('This Month');
                    },
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.5, end: 0);
          }
          return const SizedBox.shrink();
        }),
      ],
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }

  Widget _buildDateRangeSelector(bool isDark, BuildContext context) {
    return NeoCard(
      color:
          isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TIME PERIOD',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color:
                  isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildPeriodChip('This Week', isDark, context),
              _buildPeriodChip('This Month', isDark, context),
              _buildPeriodChip('3 Months', isDark, context),
              _buildPeriodChip('6 Months', isDark, context),
              _buildPeriodChip('This Year', isDark, context),
              _buildPeriodChip('Custom', isDark, context),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildPeriodChip(String period, bool isDark, BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedPeriod.value == period;
      return GestureDetector(
        onTap: () {
          if (period == 'Custom') {
            // Show date range picker
            showDialog(
              context: context,
              builder:
                  (context) => NeoDateRangePicker(
                    initialStartDate: controller.customStartDate.value,
                    initialEndDate: controller.customEndDate.value,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                    onDateRangeSelected: (start, end) {
                      if (start != null && end != null) {
                        controller.setCustomDateRange(start, end);
                      }
                    },
                  ),
            );
          } else {
            controller.changePeriod(period);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: NeoBrutalismTheme.neoBox(
            color:
                isSelected
                    ? _getThemedColor(NeoBrutalismTheme.accentPink, isDark)
                    : (isDark
                        ? NeoBrutalismTheme.darkBackground
                        : NeoBrutalismTheme.primaryWhite),
            offset: isSelected ? 2 : 5,
            borderColor: NeoBrutalismTheme.primaryBlack,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (period == 'Custom')
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.date_range,
                    size: 16,
                    color:
                        isSelected
                            ? NeoBrutalismTheme.primaryBlack
                            : (isDark
                                ? NeoBrutalismTheme.darkText
                                : NeoBrutalismTheme.primaryBlack),
                  ),
                ),
              Text(
                period.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color:
                      isSelected
                          ? NeoBrutalismTheme.primaryBlack
                          : (isDark
                              ? NeoBrutalismTheme.darkText
                              : NeoBrutalismTheme.primaryBlack),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTotalStats(bool isDark) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'TOTAL SPENT',
              '₹${controller.totalSpent.value.toStringAsFixed(2)}',
              _getThemedColor(NeoBrutalismTheme.accentOrange, isDark),
              Icons.payments,
              isDark,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'AVG DAILY',
              '₹${controller.avgDailySpent.value.toStringAsFixed(2)}',
              _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
              Icons.today,
              isDark,
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
    bool isDark,
  ) {
    return NeoCard(
      color: color,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 24, color: NeoBrutalismTheme.primaryBlack),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.primaryBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.primaryBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(bool isDark) {
    return NeoCard(
      color:
          isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CATEGORY BREAKDOWN',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color:
                  isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
            ),
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
                        final color = _getThemedColor(
                          data['color'] as Color,
                          isDark,
                        );

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
          _buildCategoryLegend(isDark),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildCategoryLegend(bool isDark) {
    return Obx(
      () => Column(
        children:
            controller.categoryData.map((data) {
              final amount =
                  (data['amount'] as num).toDouble(); // Convert num to double
              final name = data['name'] as String;
              final color = _getThemedColor(data['color'] as Color, isDark);

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
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color:
                              isDark
                                  ? NeoBrutalismTheme.darkText
                                  : NeoBrutalismTheme.primaryBlack,
                        ),
                      ),
                    ),
                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color:
                            isDark
                                ? NeoBrutalismTheme.darkText
                                : NeoBrutalismTheme.primaryBlack,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSpendingTrend(bool isDark) {
    return NeoCard(
      color:
          isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SPENDING TREND',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color:
                  isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
            ),
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
                      return FlLine(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                        strokeWidth: 1,
                      );
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
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDark
                                        ? NeoBrutalismTheme.darkText
                                        : NeoBrutalismTheme.primaryBlack,
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
                            '₹${value.toInt()}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark
                                      ? NeoBrutalismTheme.darkText
                                      : NeoBrutalismTheme.primaryBlack,
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
                      color: _getThemedColor(
                        NeoBrutalismTheme.accentPink,
                        isDark,
                      ),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: _getThemedColor(
                              NeoBrutalismTheme.accentPink,
                              isDark,
                            ),
                            strokeWidth: 2,
                            strokeColor: NeoBrutalismTheme.primaryBlack,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _getThemedColor(
                          NeoBrutalismTheme.accentPink,
                          isDark,
                        ).withOpacity(0.2),
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

  Widget _buildTopExpenses(bool isDark) {
    return NeoCard(
      color:
          isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOP EXPENSES',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color:
                  isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
            ),
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
                              color: _getRankColor(index, isDark),
                              borderColor: NeoBrutalismTheme.primaryBlack,
                            ),
                            child: Center(
                              child: Text(
                                '#${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: _getRankTextColor(index, isDark),
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark
                                            ? NeoBrutalismTheme.darkText
                                            : NeoBrutalismTheme.primaryBlack,
                                  ),
                                ),
                                Text(
                                  '${expense.date.day}/${expense.date.month}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${expense.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color:
                                  isDark
                                      ? NeoBrutalismTheme.darkText
                                      : NeoBrutalismTheme.primaryBlack,
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

  Color _getRankColor(int index, bool isDark) {
    switch (index) {
      case 0:
        return _getThemedColor(NeoBrutalismTheme.accentYellow, isDark);
      case 1:
        return _getThemedColor(NeoBrutalismTheme.accentBlue, isDark);
      case 2:
        return _getThemedColor(NeoBrutalismTheme.accentGreen, isDark);
      default:
        return isDark
            ? NeoBrutalismTheme.darkBackground
            : NeoBrutalismTheme.primaryWhite;
    }
  }

  Color _getRankTextColor(int index, bool isDark) {
    if (index < 3) {
      return NeoBrutalismTheme.primaryBlack;
    }
    return isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack;
  }

  Widget _buildExportSection(bool isDark) {
    return NeoCard(
      color: _getThemedColor(NeoBrutalismTheme.accentPurple, isDark),
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EXPORT REPORT',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Generate a beautiful PDF report with all your analytics',
            style: TextStyle(
              fontSize: 14,
              color: NeoBrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 20),
          NeoButton(
            text: 'EXPORT AS PDF',
            onPressed: () async {
              Get.dialog(
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: NeoBrutalismTheme.neoBoxRounded(
                      color:
                          isDark
                              ? NeoBrutalismTheme.darkSurface
                              : NeoBrutalismTheme.primaryWhite,
                      borderColor: NeoBrutalismTheme.primaryBlack,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color:
                              isDark
                                  ? NeoBrutalismTheme.darkText
                                  : NeoBrutalismTheme.primaryBlack,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'GENERATING PDF...',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color:
                                isDark
                                    ? NeoBrutalismTheme.darkText
                                    : NeoBrutalismTheme.primaryBlack,
                          ),
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
                backgroundColor: _getThemedColor(
                  NeoBrutalismTheme.accentGreen,
                  isDark,
                ),
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
