import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/neo_brutalism_theme.dart';

class NeoPieChart extends StatelessWidget {
  final List<PieChartSectionData> sections;
  final double centerSpaceRadius;

  const NeoPieChart({
    Key? key,
    required this.sections,
    this.centerSpaceRadius = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: NeoBrutalismTheme.neoBox(),
      padding: const EdgeInsets.all(16),
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: centerSpaceRadius,
          sectionsSpace: 2,
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 3),
          ),
        ),
      ),
    );
  }
}

class NeoLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final Color lineColor;
  final String? leftTitle;
  final String? bottomTitle;

  const NeoLineChart({
    Key? key,
    required this.spots,
    this.lineColor = NeoBrutalismTheme.accentPink,
    this.leftTitle,
    this.bottomTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: NeoBrutalismTheme.neoBox(),
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
            },
            getDrawingVerticalLine: (value) {
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
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  );
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
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 3),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: lineColor,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: lineColor,
                    strokeWidth: 2,
                    strokeColor: NeoBrutalismTheme.primaryBlack,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NeoBarChart extends StatelessWidget {
  final List<BarChartGroupData> barGroups;
  final double maxY;

  const NeoBarChart({Key? key, required this.barGroups, required this.maxY})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: NeoBrutalismTheme.neoBox(),
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: barGroups,
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
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  );
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
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 3),
          ),
        ),
      ),
    );
  }
}
