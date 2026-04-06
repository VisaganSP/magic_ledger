import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../theme/neo_brutalism_theme.dart';
import '../../category/controllers/category_controller.dart';
import '../../expense/controllers/expense_controller.dart';
import '../../income/controllers/income_controller.dart';

/// Spotify Wrapped–style monthly financial story
class MoneyStoryView extends StatefulWidget {
  const MoneyStoryView({super.key});

  @override
  State<MoneyStoryView> createState() => _MoneyStoryViewState();
}

class _MoneyStoryViewState extends State<MoneyStoryView> {
  late final PageController _pageCtrl;
  late final List<_StoryCard> _cards;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _cards = _generateCards();
  }

  List<_StoryCard> _generateCards() {
    final exp = Get.find<ExpenseController>();
    final inc = Get.find<IncomeController>();
    final cat = Get.find<CategoryController>();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    final expenses = exp.expenses.where((e) => !e.date.isBefore(monthStart)).toList();
    final incomes = inc.incomes.where((i) => !i.date.isBefore(monthStart)).toList();
    final totalSpent = expenses.fold(0.0, (s, e) => s + e.amount);
    final totalEarned = incomes.fold(0.0, (s, i) => s + i.amount);
    final saved = totalEarned - totalSpent;
    final rate = totalEarned > 0 ? (saved / totalEarned * 100) : 0.0;
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    final monthName = months[now.month - 1];

    final cards = <_StoryCard>[];

    // Card 1: Intro
    cards.add(_StoryCard(
      bg: NeoBrutalismTheme.primaryBlack,
      textColor: Colors.white,
      emoji: '✦',
      title: '$monthName ${now.year}',
      subtitle: 'YOUR MONEY STORY',
      body: 'Let\'s see how your finances played out this month.',
      accent: NeoBrutalismTheme.accentYellow,
    ));

    // Card 2: Total flow
    cards.add(_StoryCard(
      bg: const Color(0xFFB8E994),
      emoji: '💰',
      title: '₹${totalEarned.toStringAsFixed(0)}',
      subtitle: 'EARNED THIS MONTH',
      body: '${incomes.length} income entries kept the cash flowing.',
      accent: NeoBrutalismTheme.accentGreen,
    ));

    // Card 3: Total spent
    cards.add(_StoryCard(
      bg: const Color(0xFFFFB49A),
      emoji: '💸',
      title: '₹${totalSpent.toStringAsFixed(0)}',
      subtitle: 'SPENT ACROSS ${expenses.length} TRANSACTIONS',
      body: 'That\'s ₹${expenses.isNotEmpty ? (totalSpent / expenses.length).toStringAsFixed(0) : '0'} per transaction on average.',
      accent: NeoBrutalismTheme.accentOrange,
    ));

    // Card 4: Top category
    if (expenses.isNotEmpty) {
      final catTotals = <String, double>{};
      for (final e in expenses) {
        catTotals[e.categoryId] = (catTotals[e.categoryId] ?? 0) + e.amount;
      }
      final sorted = catTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final topCat = cat.getCategoryForExpense(sorted.first.key);
      final topPct = totalSpent > 0 ? (sorted.first.value / totalSpent * 100) : 0.0;

      cards.add(_StoryCard(
        bg: const Color(0xFFE8CCFF),
        emoji: topCat.icon,
        title: topCat.name.toUpperCase(),
        subtitle: '#1 SPENDING CATEGORY',
        body: '₹${sorted.first.value.toStringAsFixed(0)} — that\'s ${topPct.toStringAsFixed(0)}% of all spending.',
        accent: NeoBrutalismTheme.accentPurple,
      ));
    }

    // Card 5: Biggest expense
    if (expenses.isNotEmpty) {
      final biggest = expenses.reduce((a, b) => a.amount > b.amount ? a : b);
      cards.add(_StoryCard(
        bg: const Color(0xFFFDD663),
        emoji: '💎',
        title: '₹${biggest.amount.toStringAsFixed(0)}',
        subtitle: 'BIGGEST SINGLE EXPENSE',
        body: '"${biggest.title}" on ${biggest.date.day}/${biggest.date.month}. That one hit different.',
        accent: NeoBrutalismTheme.accentYellow,
      ));
    }

    // Card 6: Best day / Worst day
    if (expenses.isNotEmpty) {
      final dayTotals = <int, double>{};
      for (final e in expenses) {
        dayTotals[e.date.day] = (dayTotals[e.date.day] ?? 0) + e.amount;
      }
      final worst = dayTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
      final noSpendDays = now.day - dayTotals.length;

      cards.add(_StoryCard(
        bg: const Color(0xFFFDB5D6),
        emoji: '📅',
        title: '${monthName.substring(0, 3)} ${worst.key}',
        subtitle: 'YOUR MOST EXPENSIVE DAY',
        body: '₹${worst.value.toStringAsFixed(0)} spent that day alone.\n'
            '${noSpendDays > 0 ? 'But you also had $noSpendDays no-spend days! 🎉' : ''}',
        accent: NeoBrutalismTheme.accentPink,
      ));
    }

    // Card 7: Savings verdict
    String grade;
    String gradeEmoji;
    Color gradeBg;
    if (rate >= 40) { grade = 'LEGENDARY SAVER'; gradeEmoji = '🏆'; gradeBg = const Color(0xFFB8E994); }
    else if (rate >= 25) { grade = 'GREAT SAVER'; gradeEmoji = '⭐'; gradeBg = const Color(0xFFBFE3F0); }
    else if (rate >= 15) { grade = 'DECENT SAVER'; gradeEmoji = '👍'; gradeBg = const Color(0xFFFDD663); }
    else if (rate >= 0) { grade = 'ROOM TO GROW'; gradeEmoji = '💪'; gradeBg = const Color(0xFFFFB49A); }
    else { grade = 'OVERSPENDER'; gradeEmoji = '🚨'; gradeBg = const Color(0xFFFDB5D6); }

    cards.add(_StoryCard(
      bg: gradeBg,
      emoji: gradeEmoji,
      title: '${rate.toStringAsFixed(0)}% SAVED',
      subtitle: grade,
      body: saved >= 0
          ? 'You kept ₹${saved.toStringAsFixed(0)} this month. ${rate >= 20 ? 'Above the 20% benchmark!' : 'Try to hit 20% next month.'}'
          : 'You overspent by ₹${saved.abs().toStringAsFixed(0)}. Time to review and reset.',
      accent: gradeBg,
    ));

    // Card 8: Fun fact
    if (expenses.isNotEmpty) {
      final avgPerDay = totalSpent / max(now.day, 1);
      final coffees = (totalSpent / 150).floor();
      cards.add(_StoryCard(
        bg: const Color(0xFFBFE3F0),
        emoji: '☕',
        title: '$coffees COFFEES',
        subtitle: 'YOUR SPENDING IN COFFEE UNITS',
        body: 'At ₹150/coffee, your spending this month equals $coffees coffees.\n'
            'That\'s ~₹${avgPerDay.toStringAsFixed(0)} per day.',
        accent: NeoBrutalismTheme.accentSkyBlue,
      ));
    }

    // Card 9: Wrap up
    cards.add(_StoryCard(
      bg: NeoBrutalismTheme.primaryBlack,
      textColor: Colors.white,
      emoji: '✦',
      title: 'THAT\'S A WRAP',
      subtitle: '$monthName ${now.year}',
      body: 'Keep tracking, keep improving.\nSee you next month! 🚀',
      accent: NeoBrutalismTheme.accentGreen,
    ));

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: NeoBrutalismTheme.primaryBlack,
      body: Stack(
        children: [
          // Pages
          PageView.builder(
            controller: _pageCtrl,
            itemCount: _cards.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (ctx, i) => _buildPage(_cards[i], i, isDark),
          ),

          // Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20, right: 20,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(Get.context!).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
                const Spacer(),
                // Progress dots
                ...List.generate(_cards.length, (i) => Container(
                  width: i == _currentPage ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                )),
                const Spacer(),
                const SizedBox(width: 32), // Balance close button
              ],
            ),
          ),

          // Bottom hint
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 0, right: 0,
            child: Center(
              child: Text(
                _currentPage < _cards.length - 1
                    ? 'SWIPE →'
                    : 'TAP ✕ TO CLOSE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_StoryCard card, int index, bool isDark) {
    final textColor = card.textColor ?? NeoBrutalismTheme.primaryBlack;

    return Container(
      color: card.bg,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 60,
        left: 32, right: 32,
        bottom: MediaQuery.of(context).padding.bottom + 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Big emoji
          Text(card.emoji, style: const TextStyle(fontSize: 56))
              .animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
          const SizedBox(height: 20),

          // Subtitle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.15),
              border: Border.all(color: textColor.withOpacity(0.3), width: 2),
            ),
            child: Text(card.subtitle,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
                    letterSpacing: 1, color: textColor.withOpacity(0.7))),
          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0),
          const SizedBox(height: 16),

          // Title
          Text(card.title,
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900,
                  height: 1.1, letterSpacing: -1.5, color: textColor))
              .animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),

          // Body
          Text(card.body,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,
                  height: 1.6, color: textColor.withOpacity(0.8)))
              .animate().fadeIn(delay: 700.ms),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }
}

class _StoryCard {
  final Color bg;
  final Color? textColor;
  final String emoji;
  final String title;
  final String subtitle;
  final String body;
  final Color accent;

  _StoryCard({
    required this.bg,
    this.textColor,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.accent,
  });
}