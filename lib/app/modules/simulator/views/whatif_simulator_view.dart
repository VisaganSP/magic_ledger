import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_card.dart';
import '../../category/controllers/category_controller.dart';
import '../../expense/controllers/expense_controller.dart';
import '../../income/controllers/income_controller.dart';

class WhatIfSimulatorView extends StatefulWidget {
  const WhatIfSimulatorView({super.key});

  @override
  State<WhatIfSimulatorView> createState() => _WhatIfSimulatorViewState();
}

class _WhatIfSimulatorViewState extends State<WhatIfSimulatorView> {
  final ExpenseController _expCtrl = Get.find<ExpenseController>();
  final IncomeController _incCtrl = Get.find<IncomeController>();
  final CategoryController _catCtrl = Get.find<CategoryController>();

  // Sliders
  double _incomeChange = 0; // -50 to +100 (%)
  final Map<String, double> _categoryCuts = {};
  double _extraSavings = 0; // fixed amount per month

  // Data
  late double _currentMonthlySpent;
  late double _currentMonthlyEarned;
  late Map<String, double> _categoryTotals;

  @override
  void initState() {
    super.initState();
    _calculateBaseData();
  }

  void _calculateBaseData() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);

    _currentMonthlySpent = _expCtrl.expenses
        .where((e) => !e.date.isBefore(start))
        .fold(0.0, (s, e) => s + e.amount);
    _currentMonthlyEarned = _incCtrl.incomes
        .where((i) => !i.date.isBefore(start))
        .fold(0.0, (s, i) => s + i.amount);

    // Annualize if we're mid-month
    if (now.day < 25) {
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      _currentMonthlySpent = (_currentMonthlySpent / now.day) * daysInMonth;
      _currentMonthlyEarned = (_currentMonthlyEarned / now.day) * daysInMonth;
    }

    _categoryTotals = {};
    for (final e in _expCtrl.expenses.where((e) => !e.date.isBefore(start))) {
      _categoryTotals[e.categoryId] =
          (_categoryTotals[e.categoryId] ?? 0) + e.amount;
    }

    // Initialize all category cuts to 0
    for (final catId in _categoryTotals.keys) {
      _categoryCuts[catId] = 0;
    }
  }

  // Calculate simulated values
  double get _simIncome => _currentMonthlyEarned * (1 + _incomeChange / 100);

  double get _simSpent {
    double total = 0;
    for (final entry in _categoryTotals.entries) {
      final cut = _categoryCuts[entry.key] ?? 0;
      total += entry.value * (1 - cut / 100);
    }
    return total;
  }

  double get _simMonthlySaved => _simIncome - _simSpent + _extraSavings;
  double get _currentMonthlySaved => _currentMonthlyEarned - _currentMonthlySpent;
  double get _improvement => _simMonthlySaved - _currentMonthlySaved;

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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                _buildProjectionCard(isDark),
                const SizedBox(height: 16),
                _buildIncomeSlider(isDark),
                const SizedBox(height: 12),
                _buildExtraSavingsSlider(isDark),
                const SizedBox(height: 20),
                _buildCategorySliders(isDark),
                const SizedBox(height: 20),
                _buildLongTermProjection(isDark),
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
        top: MediaQuery.of(context).padding.top + 16,
        left: 20, right: 20, bottom: 14,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : _t(const Color(0xFFBFE3F0), isDark),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WHAT-IF SIMULATOR', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
              Text('Drag sliders to see the impact', style: TextStyle(fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[700])),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                _incomeChange = 0;
                _extraSavings = 0;
                for (final key in _categoryCuts.keys) { _categoryCuts[key] = 0; }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: NeoBrutalismTheme.neoBox(
                color: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
                offset: 2, borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: Icon(Icons.refresh, size: 18,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildProjectionCard(bool isDark) {
    final hasImprovement = _improvement > 0;

    return NeoCard(
      color: hasImprovement
          ? _t(NeoBrutalismTheme.accentGreen, isDark)
          : _t(NeoBrutalismTheme.accentOrange, isDark),
      borderColor: NeoBrutalismTheme.primaryBlack,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CURRENT', style: TextStyle(fontSize: 9,
                        fontWeight: FontWeight.w900, letterSpacing: 0.5,
                        color: NeoBrutalismTheme.primaryBlack)),
                    Text('₹${_currentMonthlySaved.toStringAsFixed(0)}/mo',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                            color: NeoBrutalismTheme.primaryBlack)),
                  ],
                ),
              ),
              const Text('→', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.primaryBlack)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('SIMULATED', style: TextStyle(fontSize: 9,
                        fontWeight: FontWeight.w900, letterSpacing: 0.5,
                        color: NeoBrutalismTheme.primaryBlack)),
                    Text('₹${_simMonthlySaved.toStringAsFixed(0)}/mo',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                            color: NeoBrutalismTheme.primaryBlack)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: NeoBrutalismTheme.primaryBlack,
              border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
            ),
            child: Center(
              child: Text(
                hasImprovement
                    ? '🚀 +₹${_improvement.toStringAsFixed(0)}/month more savings!'
                    : '₹${_improvement.abs().toStringAsFixed(0)}/month less savings',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeSlider(bool isDark) {
    return _buildSliderCard(
      label: '💰 INCOME CHANGE',
      value: '${_incomeChange >= 0 ? '+' : ''}${_incomeChange.toStringAsFixed(0)}%',
      detail: '₹${_simIncome.toStringAsFixed(0)}/mo (was ₹${_currentMonthlyEarned.toStringAsFixed(0)})',
      color: _t(NeoBrutalismTheme.accentGreen, isDark),
      slider: Slider(
        value: _incomeChange,
        min: -50, max: 100,
        divisions: 30,
        activeColor: NeoBrutalismTheme.primaryBlack,
        inactiveColor: Colors.black26,
        onChanged: (v) => setState(() => _incomeChange = v),
      ),
      isDark: isDark,
    );
  }

  Widget _buildExtraSavingsSlider(bool isDark) {
    return _buildSliderCard(
      label: '🏦 EXTRA MONTHLY SAVINGS',
      value: '+₹${_extraSavings.toStringAsFixed(0)}',
      detail: 'Fixed amount set aside each month',
      color: _t(NeoBrutalismTheme.accentSkyBlue, isDark),
      slider: Slider(
        value: _extraSavings,
        min: 0, max: 20000,
        divisions: 40,
        activeColor: NeoBrutalismTheme.primaryBlack,
        inactiveColor: Colors.black26,
        onChanged: (v) => setState(() => _extraSavings = v),
      ),
      isDark: isDark,
    );
  }

  Widget _buildCategorySliders(bool isDark) {
    final sorted = _categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('✂️ CUT BY CATEGORY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 10),
        ...sorted.take(6).map((entry) {
          final cat = _catCtrl.getCategoryForExpense(entry.key);
          final cut = _categoryCuts[entry.key] ?? 0;
          final newAmount = entry.value * (1 - cut / 100);
          final saved = entry.value - newAmount;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NeoCard(
              color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
              borderColor: NeoBrutalismTheme.primaryBlack,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('${cat.icon} ${cat.name}', style: TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                      const Spacer(),
                      if (cut > 0)
                        Text('-₹${saved.toStringAsFixed(0)}', style: TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w900, color: Colors.green[700])),
                      const SizedBox(width: 8),
                      Text('${cut.toStringAsFixed(0)}%', style: TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: cut > 0 ? Colors.green[700] : (isDark ? Colors.grey[500] : Colors.grey[600]))),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      activeTrackColor: NeoBrutalismTheme.primaryBlack,
                      inactiveTrackColor: isDark ? Colors.grey[700] : Colors.grey[300],
                      thumbColor: NeoBrutalismTheme.primaryBlack,
                      overlayColor: Colors.black12,
                    ),
                    child: Slider(
                      value: cut,
                      min: 0, max: 100,
                      divisions: 20,
                      onChanged: (v) => setState(() => _categoryCuts[entry.key] = v),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${entry.value.toStringAsFixed(0)} → ₹${newAmount.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 10,
                              color: isDark ? Colors.grey[500] : Colors.grey[600])),
                      // Quick buttons
                      Row(
                        children: [10, 25, 50].map((pct) => GestureDetector(
                          onTap: () => setState(() => _categoryCuts[entry.key] = pct.toDouble()),
                          child: Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: cut == pct
                                  ? NeoBrutalismTheme.primaryBlack
                                  : (isDark ? Colors.grey[800] : Colors.grey[200]),
                              border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1),
                            ),
                            child: Text('$pct%', style: TextStyle(fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: cut == pct ? Colors.white : NeoBrutalismTheme.primaryBlack)),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLongTermProjection(bool isDark) {
    final monthlySavings = _simMonthlySaved;
    final periods = [3, 6, 12, 24, 60]; // months
    final labels = ['3 MO', '6 MO', '1 YR', '2 YR', '5 YR'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('📈 LONG-TERM IMPACT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 10),
        NeoCard(
          color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
          borderColor: NeoBrutalismTheme.primaryBlack,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Bar chart
              SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: periods.asMap().entries.map((entry) {
                    final i = entry.key;
                    final months = entry.value;
                    final total = monthlySavings * months;
                    final maxTotal = monthlySavings * 60;
                    final barHeight = maxTotal > 0 ? (total / maxTotal * 110).clamp(8.0, 110.0) : 8.0;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              total >= 100000
                                  ? '₹${(total / 100000).toStringAsFixed(1)}L'
                                  : '₹${(total / 1000).toStringAsFixed(0)}K',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
                                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: barHeight,
                              decoration: NeoBrutalismTheme.neoBox(
                                color: _t([
                                  NeoBrutalismTheme.accentSkyBlue,
                                  NeoBrutalismTheme.accentGreen,
                                  NeoBrutalismTheme.accentYellow,
                                  NeoBrutalismTheme.accentPurple,
                                  NeoBrutalismTheme.accentPink,
                                ][i], isDark),
                                offset: 2,
                                borderColor: NeoBrutalismTheme.primaryBlack,
                              ),
                            ).animate().slideY(begin: 1, end: 0,
                                delay: (200 + i * 100).ms, duration: 400.ms,
                                curve: Curves.easeOut),
                            const SizedBox(height: 6),
                            Text(labels[i], style: TextStyle(fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.grey[500] : Colors.grey[600])),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: monthlySavings > 0
                      ? _t(NeoBrutalismTheme.accentGreen, isDark)
                      : _t(NeoBrutalismTheme.accentOrange, isDark),
                  border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
                ),
                child: Text(
                  monthlySavings > 0
                      ? '✨ At this rate, you\'d save ₹${(monthlySavings * 12).toStringAsFixed(0)} in a year!'
                      : '⚠️ You\'d be ₹${(monthlySavings.abs() * 12).toStringAsFixed(0)} in the hole after a year.',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                      color: NeoBrutalismTheme.primaryBlack),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderCard({
    required String label,
    required String value,
    required String detail,
    required Color color,
    required Widget slider,
    required bool isDark,
  }) {
    return NeoCard(
      color: color,
      borderColor: NeoBrutalismTheme.primaryBlack,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
                  letterSpacing: 0.5, color: NeoBrutalismTheme.primaryBlack)),
              const Spacer(),
              Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.primaryBlack)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              activeTrackColor: NeoBrutalismTheme.primaryBlack,
              inactiveTrackColor: Colors.black26,
              thumbColor: NeoBrutalismTheme.primaryBlack,
              overlayColor: Colors.black12,
            ),
            child: slider,
          ),
          Text(detail, style: const TextStyle(fontSize: 10, color: Colors.black54)),
        ],
      ),
    );
  }
}