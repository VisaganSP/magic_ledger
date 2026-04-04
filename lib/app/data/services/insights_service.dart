import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../modules/category/controllers/category_controller.dart';
import '../../modules/expense/controllers/expense_controller.dart';
import '../../modules/income/controllers/income_controller.dart';

class InsightItem {
  final String type; // 'warning', 'tip', 'achievement', 'trend', 'anomaly', 'stat'
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final double? value;
  final String? actionRoute; // optional route to navigate to

  InsightItem({
    required this.type,
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    this.value,
    this.actionRoute,
  });
}

class InsightsService {
  final ExpenseController _expCtrl = Get.find<ExpenseController>();
  final IncomeController _incCtrl = Get.find<IncomeController>();
  final CategoryController _catCtrl = Get.find<CategoryController>();

  List<InsightItem> generateInsights({
    DateTime? start,
    DateTime? end,
    String? accountId,
  }) {
    final now = DateTime.now();
    final rangeStart = start ?? DateTime(now.year, now.month, 1);
    final rangeEnd = end ?? now;

    var expenses = _expCtrl.expenses.where((e) =>
    !e.date.isBefore(rangeStart) && !e.date.isAfter(rangeEnd)).toList();
    var incomes = _incCtrl.incomes.where((i) =>
    !i.date.isBefore(rangeStart) && !i.date.isAfter(rangeEnd)).toList();

    if (accountId != null) {
      expenses = expenses.where((e) => e.accountId == accountId).toList();
      incomes = incomes.where((i) => i.accountId == accountId).toList();
    }

    final duration = rangeEnd.difference(rangeStart);
    final prevStart = rangeStart.subtract(duration);
    final prevEnd = rangeStart.subtract(const Duration(days: 1));

    var prevExpenses = _expCtrl.expenses.where((e) =>
    !e.date.isBefore(prevStart) && !e.date.isAfter(prevEnd)).toList();
    var prevIncomes = _incCtrl.incomes.where((i) =>
    !i.date.isBefore(prevStart) && !i.date.isAfter(prevEnd)).toList();

    if (accountId != null) {
      prevExpenses = prevExpenses.where((e) => e.accountId == accountId).toList();
      prevIncomes = prevIncomes.where((i) => i.accountId == accountId).toList();
    }

    final insights = <InsightItem>[];

    if (expenses.isEmpty && incomes.isEmpty) {
      insights.add(InsightItem(
        type: 'tip', title: 'No data yet',
        body: 'Start adding transactions to see smart insights about your spending patterns.',
        icon: Icons.lightbulb_outline, color: const Color(0xFF9DB4FF),
      ));
      return insights;
    }

    final totalSpent = expenses.fold(0.0, (s, e) => s + e.amount);
    final totalEarned = incomes.fold(0.0, (s, i) => s + i.amount);
    final prevTotalSpent = prevExpenses.fold(0.0, (s, e) => s + e.amount);
    final prevTotalEarned = prevIncomes.fold(0.0, (s, i) => s + i.amount);
    final days = rangeEnd.difference(rangeStart).inDays + 1;

    // ── 1. Quick summary stat card ──
    insights.add(InsightItem(
      type: 'stat',
      title: '${expenses.length} expenses, ${incomes.length} incomes',
      body: 'Total spent: ₹${totalSpent.toStringAsFixed(0)} • '
          'Total earned: ₹${totalEarned.toStringAsFixed(0)} • '
          'Net: ${(totalEarned - totalSpent) >= 0 ? '+' : ''}₹${(totalEarned - totalSpent).toStringAsFixed(0)} '
          'over $days days.',
      icon: Icons.dashboard,
      color: const Color(0xFFBFE3F0),
      value: 999, // Always show first
    ));

    // ── 2. Savings rate ──
    if (totalEarned > 0) {
      final savingsRate = ((totalEarned - totalSpent) / totalEarned * 100);
      if (savingsRate >= 30) {
        insights.add(InsightItem(
          type: 'achievement', title: '${savingsRate.toStringAsFixed(0)}% savings rate',
          body: 'You kept ₹${(totalEarned - totalSpent).toStringAsFixed(0)} out of ₹${totalEarned.toStringAsFixed(0)} earned. '
              '${savingsRate >= 50 ? 'Outstanding financial discipline!' : 'Above the recommended 20% benchmark.'}',
          icon: Icons.emoji_events, color: const Color(0xFFB8E994), value: savingsRate,
        ));
      } else if (savingsRate < 0) {
        insights.add(InsightItem(
          type: 'warning', title: 'Spending exceeds income',
          body: 'You\'ve spent ₹${(totalSpent - totalEarned).toStringAsFixed(0)} more than earned. '
              'That\'s a ${savingsRate.abs().toStringAsFixed(0)}% deficit. Review non-essential spending.',
          icon: Icons.warning_amber, color: const Color(0xFFFFB49A), value: savingsRate.abs(),
          actionRoute: '/expenses',
        ));
      } else if (savingsRate < 10) {
        insights.add(InsightItem(
          type: 'tip', title: 'Only ${savingsRate.toStringAsFixed(0)}% saved',
          body: 'Financial experts recommend saving at least 20% of income. '
              'You\'re saving ₹${(totalEarned - totalSpent).toStringAsFixed(0)} — try to boost this by cutting one category.',
          icon: Icons.lightbulb, color: const Color(0xFFFDD663), value: savingsRate,
        ));
      }
    }

    // ── 3. Spending trend vs previous period ──
    if (prevTotalSpent > 0) {
      final change = ((totalSpent - prevTotalSpent) / prevTotalSpent * 100);
      if (change > 20) {
        insights.add(InsightItem(
          type: 'warning', title: 'Spending up ${change.toStringAsFixed(0)}%',
          body: '₹${totalSpent.toStringAsFixed(0)} vs ₹${prevTotalSpent.toStringAsFixed(0)} last period. '
              'That\'s ₹${(totalSpent - prevTotalSpent).toStringAsFixed(0)} extra. Check which categories grew.',
          icon: Icons.trending_up, color: const Color(0xFFFDB5D6), value: change,
        ));
      } else if (change < -10) {
        insights.add(InsightItem(
          type: 'achievement', title: 'Spending down ${change.abs().toStringAsFixed(0)}%',
          body: 'Cut ₹${(prevTotalSpent - totalSpent).toStringAsFixed(0)} compared to last period. '
              '${change < -25 ? 'Major improvement!' : 'Keep this momentum going.'}',
          icon: Icons.trending_down, color: const Color(0xFFB8E994), value: change.abs(),
        ));
      }
    }

    // ── 4. Top category analysis ──
    if (expenses.isNotEmpty) {
      final catTotals = <String, double>{};
      for (final e in expenses) {
        catTotals[e.categoryId] = (catTotals[e.categoryId] ?? 0) + e.amount;
      }

      if (catTotals.isNotEmpty) {
        final sorted = catTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // Top 3 categories
        final top3 = sorted.take(3).map((e) {
          final cat = _catCtrl.getCategoryForExpense(e.key);
          final pct = totalSpent > 0 ? (e.value / totalSpent * 100) : 0.0;
          return '${cat.icon} ${cat.name} ₹${e.value.toStringAsFixed(0)} (${pct.toStringAsFixed(0)}%)';
        }).join('\n');

        insights.add(InsightItem(
          type: 'trend', title: 'Top spending categories',
          body: top3,
          icon: Icons.pie_chart, color: const Color(0xFFE8CCFF), value: 50,
        ));

        // Dominant category warning
        final topPct = totalSpent > 0 ? (sorted.first.value / totalSpent * 100) : 0.0;
        if (topPct > 50) {
          final topCat = _catCtrl.getCategoryForExpense(sorted.first.key);
          insights.add(InsightItem(
            type: 'warning', title: '${topCat.icon} ${topCat.name}: ${topPct.toStringAsFixed(0)}% of all spending',
            body: 'More than half your money goes to ${topCat.name}. '
                'Consider if all ₹${sorted.first.value.toStringAsFixed(0)} was necessary.',
            icon: Icons.priority_high, color: const Color(0xFFFFB49A), value: topPct,
          ));
        }

        // Category vs previous period — find biggest change
        if (prevExpenses.isNotEmpty) {
          final prevCatTotals = <String, double>{};
          for (final e in prevExpenses) {
            prevCatTotals[e.categoryId] = (prevCatTotals[e.categoryId] ?? 0) + e.amount;
          }

          double biggestIncrease = 0;
          String? biggestIncreaseCatId;
          double biggestDecrease = 0;
          String? biggestDecreaseCatId;

          for (final entry in sorted) {
            final prev = prevCatTotals[entry.key] ?? 0;
            if (prev > 0) {
              final change = ((entry.value - prev) / prev * 100);
              if (change > biggestIncrease) {
                biggestIncrease = change;
                biggestIncreaseCatId = entry.key;
              }
              if (change < biggestDecrease) {
                biggestDecrease = change;
                biggestDecreaseCatId = entry.key;
              }
            }
          }

          if (biggestIncrease > 40 && biggestIncreaseCatId != null) {
            final cat = _catCtrl.getCategoryForExpense(biggestIncreaseCatId);
            final curr = catTotals[biggestIncreaseCatId] ?? 0;
            final prev = prevCatTotals[biggestIncreaseCatId] ?? 0;
            insights.add(InsightItem(
              type: 'anomaly',
              title: '${cat.icon} ${cat.name} spiked +${biggestIncrease.toStringAsFixed(0)}%',
              body: 'Was ₹${prev.toStringAsFixed(0)}, now ₹${curr.toStringAsFixed(0)}. '
                  'That\'s ₹${(curr - prev).toStringAsFixed(0)} more than usual.',
              icon: Icons.auto_graph, color: const Color(0xFFFFB49A), value: biggestIncrease,
            ));
          }

          if (biggestDecrease < -30 && biggestDecreaseCatId != null) {
            final cat = _catCtrl.getCategoryForExpense(biggestDecreaseCatId);
            final curr = catTotals[biggestDecreaseCatId] ?? 0;
            final prev = prevCatTotals[biggestDecreaseCatId] ?? 0;
            insights.add(InsightItem(
              type: 'achievement',
              title: '${cat.icon} ${cat.name} cut by ${biggestDecrease.abs().toStringAsFixed(0)}%',
              body: 'Down from ₹${prev.toStringAsFixed(0)} to ₹${curr.toStringAsFixed(0)}. '
                  'Saved ₹${(prev - curr).toStringAsFixed(0)} in this category.',
              icon: Icons.thumb_up, color: const Color(0xFFB8E994), value: biggestDecrease.abs(),
            ));
          }
        }

        // Category diversity score
        final diversity = catTotals.length;
        if (diversity <= 2 && expenses.length > 5) {
          insights.add(InsightItem(
            type: 'tip', title: 'Only $diversity categories used',
            body: 'Most spending is concentrated in very few categories. '
                'Use categories to track where your money goes — it helps find savings.',
            icon: Icons.category, color: const Color(0xFFBFE3F0),
          ));
        }
      }
    }

    // ── 5. Biggest single expense ──
    if (expenses.length > 3) {
      final biggest = expenses.reduce((a, b) => a.amount > b.amount ? a : b);
      final avgExpense = totalSpent / expenses.length;
      if (biggest.amount > avgExpense * 3) {
        insights.add(InsightItem(
          type: 'anomaly', title: 'Big expense: ${biggest.title}',
          body: '₹${biggest.amount.toStringAsFixed(0)} is ${(biggest.amount / avgExpense).toStringAsFixed(1)}x '
              'your average of ₹${avgExpense.toStringAsFixed(0)}. '
              'On ${biggest.date.day}/${biggest.date.month}.',
          icon: Icons.attach_money, color: const Color(0xFFFDD663), value: biggest.amount,
        ));
      }
    }

    // ── 6. Weekend vs weekday spending ──
    if (days >= 7 && expenses.length >= 5) {
      double weekdayTotal = 0, weekendTotal = 0;
      int weekdayCount = 0, weekendCount = 0;

      for (final e in expenses) {
        if (e.date.weekday >= 6) {
          weekendTotal += e.amount;
          weekendCount++;
        } else {
          weekdayTotal += e.amount;
          weekdayCount++;
        }
      }

      if (weekendCount > 0 && weekdayCount > 0) {
        final weekendAvg = weekendTotal / weekendCount;
        final weekdayAvg = weekdayTotal / weekdayCount;

        if (weekendAvg > weekdayAvg * 1.5) {
          insights.add(InsightItem(
            type: 'trend', title: 'Weekend splurge pattern',
            body: 'Average weekend transaction: ₹${weekendAvg.toStringAsFixed(0)} vs '
                'weekday: ₹${weekdayAvg.toStringAsFixed(0)}. '
                'Weekend spending is ${((weekendAvg / weekdayAvg - 1) * 100).toStringAsFixed(0)}% higher.',
            icon: Icons.weekend, color: const Color(0xFFFDB5D6),
          ));
        } else if (weekdayAvg > weekendAvg * 1.5) {
          insights.add(InsightItem(
            type: 'achievement', title: 'Weekends under control',
            body: 'You spend less on weekends (₹${weekendAvg.toStringAsFixed(0)}/tx) '
                'than weekdays (₹${weekdayAvg.toStringAsFixed(0)}/tx). Nice restraint!',
            icon: Icons.weekend, color: const Color(0xFFB8E994),
          ));
        }
      }
    }

    // ── 7. Daily spending pattern ──
    if (days > 7 && expenses.length >= 5) {
      final dailySpend = <int, double>{};
      for (final e in expenses) {
        dailySpend[e.date.weekday] = (dailySpend[e.date.weekday] ?? 0) + e.amount;
      }

      if (dailySpend.isNotEmpty) {
        final maxDay = dailySpend.entries.reduce((a, b) => a.value > b.value ? a : b);
        final minDay = dailySpend.entries.reduce((a, b) => a.value < b.value ? a : b);
        final dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

        insights.add(InsightItem(
          type: 'trend', title: '${dayNames[maxDay.key]} = highest, ${dayNames[minDay.key]} = lowest',
          body: 'Peak spending on ${dayNames[maxDay.key]}s: ₹${maxDay.value.toStringAsFixed(0)}. '
              'Least on ${dayNames[minDay.key]}s: ₹${minDay.value.toStringAsFixed(0)}. '
              'Plan big purchases on low-spend days.',
          icon: Icons.bar_chart, color: const Color(0xFFBFE3F0),
        ));
      }
    }

    // ── 8. Small expenses adding up ──
    if (expenses.length >= 5) {
      final small = expenses.where((e) => e.amount < 100).toList();
      if (small.length >= 5) {
        final smallTotal = small.fold(0.0, (s, e) => s + e.amount);
        final pct = totalSpent > 0 ? (smallTotal / totalSpent * 100) : 0.0;
        insights.add(InsightItem(
          type: 'tip',
          title: '${small.length} micro-transactions = ₹${smallTotal.toStringAsFixed(0)}',
          body: 'Transactions under ₹100 make up ${pct.toStringAsFixed(0)}% of total spending. '
              '${pct > 20 ? 'These small leaks can drain your budget — try batching purchases.' : 'Not too bad, but stay aware.'}',
          icon: Icons.scatter_plot, color: const Color(0xFFE8CCFF), value: smallTotal,
        ));
      }
    }

    // ── 9. Projection ──
    if (days > 3 && rangeStart.month == now.month && rangeStart.year == now.year) {
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final projected = (totalSpent / now.day) * daysInMonth;
      final projectedLabel = projected >= 100000
          ? '₹${(projected / 1000).toStringAsFixed(0)}K'
          : '₹${projected.toStringAsFixed(0)}';

      insights.add(InsightItem(
        type: totalEarned > 0 && projected > totalEarned ? 'warning' : 'trend',
        title: 'Projected month-end: $projectedLabel',
        body: 'At ₹${(totalSpent / now.day).toStringAsFixed(0)}/day pace, '
            'you\'ll spend ~₹${projected.toStringAsFixed(0)} by month-end. '
            '${totalEarned > 0 && projected > totalEarned ? 'That\'s ₹${(projected - totalEarned).toStringAsFixed(0)} over income!' : '${daysInMonth - now.day} days left to adjust.'}',
        icon: Icons.speed, color: const Color(0xFFFDB5D6), value: projected,
      ));
    }

    // ── 10. No-spend days ──
    if (days > 7) {
      int noSpendDays = 0;
      for (int d = 0; d < days; d++) {
        final date = rangeStart.add(Duration(days: d));
        if (date.isAfter(now)) break;
        final hasExpense = expenses.any((e) =>
        e.date.year == date.year && e.date.month == date.month && e.date.day == date.day);
        if (!hasExpense) noSpendDays++;
      }
      if (noSpendDays >= 2) {
        insights.add(InsightItem(
          type: noSpendDays >= 7 ? 'achievement' : 'tip',
          title: '$noSpendDays no-spend days',
          body: '${noSpendDays >= 7 ? 'Impressive!' : ''} $noSpendDays days with zero expenses out of $days. '
              '${noSpendDays >= 10 ? 'You\'re a no-spend champion!' : 'Try to hit ${noSpendDays + 3} next time.'}',
          icon: Icons.shield, color: const Color(0xFFB8E994), value: noSpendDays.toDouble(),
        ));
      }
    }

    // ── 11. Income trend ──
    if (prevTotalEarned > 0 && totalEarned > 0) {
      final incChange = ((totalEarned - prevTotalEarned) / prevTotalEarned * 100);
      if (incChange > 15) {
        insights.add(InsightItem(
          type: 'achievement', title: 'Income up ${incChange.toStringAsFixed(0)}%',
          body: '₹${totalEarned.toStringAsFixed(0)} vs ₹${prevTotalEarned.toStringAsFixed(0)} last period.',
          icon: Icons.rocket_launch, color: const Color(0xFFB8E994), value: incChange,
        ));
      } else if (incChange < -15) {
        insights.add(InsightItem(
          type: 'warning', title: 'Income dropped ${incChange.abs().toStringAsFixed(0)}%',
          body: '₹${totalEarned.toStringAsFixed(0)} vs ₹${prevTotalEarned.toStringAsFixed(0)} last period. Tighten the budget.',
          icon: Icons.arrow_downward, color: const Color(0xFFFFB49A), value: incChange.abs(),
        ));
      }
    }

    // ── 12. Transaction frequency ──
    if (expenses.isNotEmpty && days > 0) {
      final txPerDay = expenses.length / days;
      insights.add(InsightItem(
        type: txPerDay > 5 ? 'tip' : 'stat',
        title: '${txPerDay.toStringAsFixed(1)} transactions/day',
        body: '${expenses.length} expenses over $days days. '
            '${txPerDay > 5 ? 'That\'s a lot — consider batch buying or fewer impulse purchases.' : 'Reasonable frequency.'}',
        icon: Icons.receipt_long, color: const Color(0xFFFDD663), value: txPerDay,
      ));
    }

    // ── 13. Average transaction size ──
    if (expenses.isNotEmpty) {
      final avg = totalSpent / expenses.length;
      final median = _getMedian(expenses.map((e) => e.amount).toList());
      if (avg > median * 2) {
        insights.add(InsightItem(
          type: 'trend',
          title: 'Big outliers skewing average',
          body: 'Average transaction: ₹${avg.toStringAsFixed(0)} but median is only ₹${median.toStringAsFixed(0)}. '
              'A few large expenses are pulling the average up.',
          icon: Icons.analytics, color: const Color(0xFFBFE3F0),
        ));
      }
    }

    // ── 14. Recurring pattern detection ──
    if (expenses.length > 5) {
      final titleCounts = <String, int>{};
      for (final e in expenses) {
        final key = e.title.toLowerCase().trim();
        titleCounts[key] = (titleCounts[key] ?? 0) + 1;
      }
      final recurring = titleCounts.entries.where((e) => e.value >= 3).toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      if (recurring.isNotEmpty) {
        final top = recurring.first;
        final recurringExpenses = expenses.where(
                (e) => e.title.toLowerCase().trim() == top.key);
        final recurringTotal = recurringExpenses.fold(0.0, (s, e) => s + e.amount);

        insights.add(InsightItem(
          type: 'trend',
          title: '"${top.key}" appears ${top.value} times',
          body: 'Totaling ₹${recurringTotal.toStringAsFixed(0)}. '
              '${top.value >= 5 ? 'This might be a subscription — track it in the Subscriptions section.' : 'Frequent purchase — is it a habit?'}',
          icon: Icons.repeat, color: const Color(0xFFE8CCFF),
          actionRoute: '/subscriptions',
        ));
      }
    }

    // ── 15. Time-of-day pattern ──
    if (expenses.length >= 10) {
      int morning = 0, afternoon = 0, evening = 0, night = 0;
      for (final e in expenses) {
        final h = e.date.hour;
        if (h >= 6 && h < 12) morning++;
        else if (h >= 12 && h < 17) afternoon++;
        else if (h >= 17 && h < 22) evening++;
        else night++;
      }

      final maxPeriod = [morning, afternoon, evening, night];
      final maxIdx = maxPeriod.indexOf(maxPeriod.reduce((a, b) => a > b ? a : b));
      final periods = ['morning (6AM-12PM)', 'afternoon (12-5PM)', 'evening (5-10PM)', 'late night'];
      final emojis = ['☀️', '🌤️', '🌙', '🌑'];

      insights.add(InsightItem(
        type: 'trend',
        title: '${emojis[maxIdx]} Most spending in ${periods[maxIdx]}',
        body: 'Morning: $morning • Afternoon: $afternoon • Evening: $evening • Night: $night transactions. '
            '${maxIdx == 3 ? 'Late-night purchases are often impulse buys — sleep on it!' : ''}',
        icon: Icons.access_time, color: const Color(0xFFFDD663),
      ));
    }

    // Sort: stat first, then warnings, anomalies, trends, tips, achievements
    final typeOrder = {'stat': 0, 'warning': 1, 'anomaly': 2, 'trend': 3, 'tip': 4, 'achievement': 5};
    insights.sort((a, b) {
      final ta = typeOrder[a.type] ?? 6;
      final tb = typeOrder[b.type] ?? 6;
      if (ta != tb) return ta.compareTo(tb);
      return (b.value ?? 0).compareTo(a.value ?? 0);
    });

    return insights;
  }

  double _getMedian(List<double> values) {
    if (values.isEmpty) return 0;
    values.sort();
    final mid = values.length ~/ 2;
    if (values.length.isOdd) return values[mid];
    return (values[mid - 1] + values[mid]) / 2;
  }
}