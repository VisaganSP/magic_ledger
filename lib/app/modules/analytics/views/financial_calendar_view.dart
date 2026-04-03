import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/services/period_service.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../expense/controllers/expense_controller.dart';
import '../../income/controllers/income_controller.dart';

/// A heatmap calendar showing daily spending intensity.
/// Deep red = high spend, light green = low spend, grey = no data.
/// Tap a day to see its transactions.
class FinancialCalendarView extends StatefulWidget {
  const FinancialCalendarView({super.key});
  @override
  State<FinancialCalendarView> createState() => _FinancialCalendarViewState();
}

class _FinancialCalendarViewState extends State<FinancialCalendarView> {
  late int _year;
  late int _month;
  int? _selectedDay;

  final _expCtrl = Get.find<ExpenseController>();
  final _incCtrl = Get.find<IncomeController>();
  final _cur = NumberFormat.currency(symbol: '\u{20B9}', decimalDigits: 0);
  final _dateFmt = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
  }

  Map<int, double> _getDailySpending() {
    final data = <int, double>{};
    final start = DateTime(_year, _month, 1);
    final end = DateTime(_year, _month + 1, 0);
    for (final e in _expCtrl.expenses) {
      if (e.date.year == _year && e.date.month == _month) {
        data[e.date.day] = (data[e.date.day] ?? 0) + e.amount;
      }
    }
    return data;
  }

  Map<int, double> _getDailyIncome() {
    final data = <int, double>{};
    for (final i in _incCtrl.incomes) {
      if (i.date.year == _year && i.date.month == _month) {
        data[i.date.day] = (data[i.date.day] ?? 0) + i.amount;
      }
    }
    return data;
  }

  Color _heatColor(double amount, double maxSpend, bool isDark) {
    if (amount <= 0) return isDark ? const Color(0xFF2C2C2A) : const Color(0xFFF0EEEB);
    final intensity = (amount / maxSpend).clamp(0.0, 1.0);
    if (intensity < 0.25) return isDark ? const Color(0xFF1B3A1B) : const Color(0xFFD4E4D1);
    if (intensity < 0.50) return isDark ? const Color(0xFF3A3A1B) : const Color(0xFFFDD663);
    if (intensity < 0.75) return isDark ? const Color(0xFF4A2A1B) : const Color(0xFFFFB49A);
    return isDark ? const Color(0xFF4A1B1B) : const Color(0xFFE57373);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dailySpend = _getDailySpending();
    final dailyIncome = _getDailyIncome();
    final maxSpend = dailySpend.values.isEmpty ? 1.0 : dailySpend.values.reduce((a, b) => a > b ? a : b);
    final daysInMonth = DateTime(_year, _month + 1, 0).day;
    final firstWeekday = DateTime(_year, _month, 1).weekday; // 1=Mon
    final totalSpent = dailySpend.values.fold(0.0, (s, v) => s + v);
    final totalEarned = dailyIncome.values.fold(0.0, (s, v) => s + v);
    final avgDaily = dailySpend.isNotEmpty ? totalSpent / dailySpend.length : 0.0;

    return Scaffold(
      backgroundColor: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
      appBar: AppBar(
          title: const Text('FINANCIAL CALENDAR', style: TextStyle(fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.primaryBlack)),
          backgroundColor: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentBlue, isDark),
          foregroundColor: NeoBrutalismTheme.primaryBlack, elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Month navigator
        _buildMonthNav(isDark),
        const SizedBox(height: 16),

        // Summary strip
        _buildSummary(totalSpent, totalEarned, avgDaily, isDark),
        const SizedBox(height: 16),

        // Calendar grid
        _buildCalendar(dailySpend, maxSpend, daysInMonth, firstWeekday, isDark),
        const SizedBox(height: 12),

        // Legend
        _buildLegend(isDark),
        const SizedBox(height: 16),

        // Day detail
        if (_selectedDay != null) _buildDayDetail(_selectedDay!, dailySpend, dailyIncome, isDark),
      ]),
    );
  }

  Widget _buildMonthNav(bool isDark) {
    return Container(
        padding: const EdgeInsets.all(12),
        decoration: NeoBrutalismTheme.neoBox(
            color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentYellow, isDark),
            borderColor: NeoBrutalismTheme.primaryBlack, offset: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(
              onTap: () => setState(() {
                _month--; if (_month < 1) { _month = 12; _year--; }
                _selectedDay = null;
              }),
              child: Container(padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.chevron_left, color: NeoBrutalismTheme.primaryBlack))),
          Text('${DateFormat.MMMM().format(DateTime(_year, _month))} $_year',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
          GestureDetector(
              onTap: () => setState(() {
                _month++; if (_month > 12) { _month = 1; _year++; }
                _selectedDay = null;
              }),
              child: Container(padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.chevron_right, color: NeoBrutalismTheme.primaryBlack))),
        ]));
  }

  Widget _buildSummary(double spent, double earned, double avg, bool isDark) {
    return Row(children: [
      _miniStat('SPENT', _cur.format(spent), const Color(0xFFE57373), isDark),
      const SizedBox(width: 8),
      _miniStat('EARNED', _cur.format(earned), const Color(0xFFB8E994), isDark),
      const SizedBox(width: 8),
      _miniStat('AVG/DAY', _cur.format(avg), const Color(0xFFBFE3F0), isDark),
    ]);
  }

  Widget _miniStat(String label, String value, Color color, bool isDark) {
    return Expanded(child: Container(padding: const EdgeInsets.all(10),
        decoration: NeoBrutalismTheme.neoBox(color: color, borderColor: NeoBrutalismTheme.primaryBlack, offset: 3),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: NeoBrutalismTheme.primaryBlack)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
        ])));
  }

  Widget _buildCalendar(Map<int, double> daily, double maxSpend, int daysInMonth, int firstWd, bool isDark) {
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();
    final isCurrentMonth = _year == now.year && _month == now.month;

    return Container(
        padding: const EdgeInsets.all(12),
        decoration: NeoBrutalismTheme.neoBox(
            color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack, offset: 4),
        child: Column(children: [
          // Day of week headers
          Row(children: dayLabels.map((d) => Expanded(child: Center(
              child: Text(d, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                  color: isDark ? Colors.grey[400] : Colors.grey[600]))))).toList()),
          const SizedBox(height: 8),
          // Calendar grid
          ...List.generate(6, (week) {
            return Padding(padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: List.generate(7, (wd) {
                  final dayNum = week * 7 + wd - (firstWd - 2);
                  if (dayNum < 1 || dayNum > daysInMonth) {
                    return Expanded(child: Container(height: 42));
                  }
                  final spend = daily[dayNum] ?? 0;
                  final isToday = isCurrentMonth && dayNum == now.day;
                  final isSelected = _selectedDay == dayNum;

                  return Expanded(child: GestureDetector(
                      onTap: () => setState(() { _selectedDay = dayNum; }),
                      child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: 42, margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                              color: _heatColor(spend, maxSpend, isDark),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: isSelected ? NeoBrutalismTheme.primaryBlack
                                      : isToday ? const Color(0xFF4D94FF) : Colors.transparent,
                                  width: isSelected ? 3 : isToday ? 2 : 0)),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text('$dayNum', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                            if (spend > 0) Text(_compact(spend), style: TextStyle(fontSize: 7,
                                fontWeight: FontWeight.w700, color: isDark ? Colors.grey[300] : Colors.grey[700])),
                          ]))));
                })));
          }),
        ]));
  }

  String _compact(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  Widget _buildLegend(bool isDark) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('Low ', style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600])),
      ...[ const Color(0xFFD4E4D1), const Color(0xFFFDD663), const Color(0xFFFFB49A), const Color(0xFFE57373)]
          .map((c) => Container(width: 20, height: 12, margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3),
              border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1)))),
      Text(' High', style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600])),
    ]);
  }

  Widget _buildDayDetail(int day, Map<int, double> dailySpend, Map<int, double> dailyIncome, bool isDark) {
    final date = DateTime(_year, _month, day);
    final spent = dailySpend[day] ?? 0;
    final earned = dailyIncome[day] ?? 0;

    // Get transactions for this day
    final dayExps = _expCtrl.expenses.where((e) =>
    e.date.year == _year && e.date.month == _month && e.date.day == day).toList();
    final dayIncs = _incCtrl.incomes.where((i) =>
    i.date.year == _year && i.date.month == _month && i.date.day == day).toList();

    return Container(
        padding: const EdgeInsets.all(14),
        decoration: NeoBrutalismTheme.neoBox(
            color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack, offset: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: NeoBrutalismTheme.primaryBlack, borderRadius: BorderRadius.circular(4)),
                child: Text(_dateFmt.format(date), style: const TextStyle(fontSize: 10,
                    fontWeight: FontWeight.w900, color: Colors.white))),
            const Spacer(),
            if (spent > 0) Text('Out: ${_cur.format(spent)}', style: const TextStyle(fontSize: 12,
                fontWeight: FontWeight.w800, color: Color(0xFFE57373))),
            if (spent > 0 && earned > 0) const Text('  \u2022  '),
            if (earned > 0) Text('In: ${_cur.format(earned)}', style: const TextStyle(fontSize: 12,
                fontWeight: FontWeight.w800, color: Color(0xFF00CC66))),
          ]),
          if (dayExps.isEmpty && dayIncs.isEmpty) ...[
            const SizedBox(height: 16),
            Center(child: Text('No transactions', style: TextStyle(fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600]))),
          ] else ...[
            const SizedBox(height: 12),
            ...dayExps.map((e) => Padding(padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(
                      color: Color(0xFFE57373), shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack))),
                  Text('-${_cur.format(e.amount)}', style: const TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w800, color: Color(0xFFE57373))),
                ]))),
            ...dayIncs.map((i) => Padding(padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(
                      color: Color(0xFF00CC66), shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(i.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack))),
                  Text('+${_cur.format(i.amount)}', style: const TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w800, color: Color(0xFF00CC66))),
                ]))),
          ],
        ]));
  }
}