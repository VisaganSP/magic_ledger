import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_card.dart';
import '../../expense/controllers/expense_controller.dart';
import '../../income/controllers/income_controller.dart';
import '../../account/controllers/account_controller.dart';

/// Achievement definitions
class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final Color color;
  final bool Function() check;

  Achievement({required this.id, required this.title, required this.description,
    required this.emoji, required this.color, required this.check});
}

/// Achievements & Streaks Controller
class AchievementsController extends GetxController {
  late Box _achievementsBox;
  final RxList<String> unlockedIds = <String>[].obs;
  final RxInt currentStreak = 0.obs;
  final RxInt bestStreak = 0.obs;

  late final List<Achievement> allAchievements;

  @override
  void onInit() {
    super.onInit();
    _initBox();
  }

  Future<void> _initBox() async {
    _achievementsBox = Hive.isBoxOpen('achievements')
        ? Hive.box('achievements')
        : await Hive.openBox('achievements');

    unlockedIds.value = List<String>.from(
        _achievementsBox.get('unlocked', defaultValue: <String>[]) ?? []);
    bestStreak.value = _achievementsBox.get('best_streak', defaultValue: 0);

    _defineAchievements();
    calculateStreak();
    checkAll();
  }

  void _defineAchievements() {
    final exp = Get.find<ExpenseController>();
    final inc = Get.find<IncomeController>();
    final acc = Get.find<AccountController>();

    allAchievements = [
      Achievement(id: 'first_expense', title: 'FIRST STEP',
          description: 'Record your first expense',
          emoji: '🎯', color: const Color(0xFFB8E994),
          check: () => exp.expenses.isNotEmpty),

      Achievement(id: 'ten_expenses', title: 'GETTING STARTED',
          description: 'Record 10 expenses',
          emoji: '📝', color: const Color(0xFFBFE3F0),
          check: () => exp.expenses.length >= 10),

      Achievement(id: 'fifty_expenses', title: 'EXPENSE TRACKER',
          description: 'Record 50 expenses',
          emoji: '📊', color: const Color(0xFFE8CCFF),
          check: () => exp.expenses.length >= 50),

      Achievement(id: 'hundred_expenses', title: 'DEDICATED TRACKER',
          description: 'Record 100 expenses',
          emoji: '🏅', color: const Color(0xFFFDD663),
          check: () => exp.expenses.length >= 100),

      Achievement(id: 'first_income', title: 'MONEY MAKER',
          description: 'Record your first income',
          emoji: '💰', color: const Color(0xFFB8E994),
          check: () => inc.incomes.isNotEmpty),

      Achievement(id: 'save_1k', title: 'FIRST THOUSAND',
          description: 'Have ₹1,000+ in accounts',
          emoji: '💵', color: const Color(0xFFBFE3F0),
          check: () => acc.getTotalBalance() >= 1000),

      Achievement(id: 'save_10k', title: 'FIVE FIGURES',
          description: 'Have ₹10,000+ in accounts',
          emoji: '💎', color: const Color(0xFFE8CCFF),
          check: () => acc.getTotalBalance() >= 10000),

      Achievement(id: 'save_50k', title: 'WEALTH BUILDER',
          description: 'Have ₹50,000+ in accounts',
          emoji: '🏆', color: const Color(0xFFFDD663),
          check: () => acc.getTotalBalance() >= 50000),

      Achievement(id: 'save_1l', title: 'LAKSHMI BLESSED',
          description: 'Have ₹1,00,000+ in accounts',
          emoji: '👑', color: const Color(0xFFFDB5D6),
          check: () => acc.getTotalBalance() >= 100000),

      Achievement(id: 'streak_3', title: 'MINDFUL SPENDER',
          description: '3-day no-spend streak',
          emoji: '🔥', color: const Color(0xFFFFB49A),
          check: () => currentStreak.value >= 3),

      Achievement(id: 'streak_7', title: 'WEEK WARRIOR',
          description: '7-day no-spend streak',
          emoji: '⚡', color: const Color(0xFFFDD663),
          check: () => currentStreak.value >= 7),

      Achievement(id: 'streak_14', title: 'FRUGAL FORTNIGHT',
          description: '14-day no-spend streak',
          emoji: '🌟', color: const Color(0xFFE8CCFF),
          check: () => currentStreak.value >= 14),

      Achievement(id: 'streak_30', title: 'LEGENDARY SAVER',
          description: '30-day no-spend streak',
          emoji: '🏆', color: const Color(0xFFFDB5D6),
          check: () => currentStreak.value >= 30),

      Achievement(id: 'multi_account', title: 'DIVERSIFIED',
          description: 'Set up 3+ accounts',
          emoji: '🏦', color: const Color(0xFFBFE3F0),
          check: () => acc.accounts.length >= 3),

      Achievement(id: 'savings_20', title: 'SMART SAVER',
          description: 'Save 20%+ of income in a month',
          emoji: '📈', color: const Color(0xFFB8E994),
          check: () {
            final now = DateTime.now();
            final start = DateTime(now.year, now.month, 1);
            final spent = exp.expenses.where((e) => !e.date.isBefore(start)).fold(0.0, (s, e) => s + e.amount);
            final earned = inc.incomes.where((i) => !i.date.isBefore(start)).fold(0.0, (s, i) => s + i.amount);
            return earned > 0 && ((earned - spent) / earned * 100) >= 20;
          }),
    ];
  }

  /// Calculate current no-spend streak
  void calculateStreak() {
    final exp = Get.find<ExpenseController>();
    final now = DateTime.now();
    int streak = 0;

    for (int d = 0; d < 365; d++) {
      final date = now.subtract(Duration(days: d));
      // Skip today (might still spend)
      if (d == 0) continue;

      final hasExpense = exp.expenses.any((e) =>
      e.date.year == date.year && e.date.month == date.month && e.date.day == date.day);

      if (!hasExpense) {
        streak++;
      } else {
        break;
      }
    }

    currentStreak.value = streak;

    // Update best streak
    if (streak > bestStreak.value) {
      bestStreak.value = streak;
      _achievementsBox.put('best_streak', streak);
    }
  }

  /// Check all achievements and unlock new ones
  void checkAll() {
    bool newUnlock = false;
    for (final a in allAchievements) {
      if (!unlockedIds.contains(a.id) && a.check()) {
        unlockedIds.add(a.id);
        newUnlock = true;

        // Show celebration snackbar
        Get.snackbar(
          '${a.emoji} Achievement Unlocked!',
          '${a.title} — ${a.description}',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          backgroundColor: a.color,
          colorText: NeoBrutalismTheme.primaryBlack,
          borderWidth: 2,
          borderColor: NeoBrutalismTheme.primaryBlack,
          margin: const EdgeInsets.all(12),
        );
      }
    }

    if (newUnlock) {
      _achievementsBox.put('unlocked', unlockedIds.toList());
    }
  }

  int get totalAchievements => allAchievements.length;
  int get unlockedCount => unlockedIds.length;
  double get progressPercent => totalAchievements > 0 ? unlockedCount / totalAchievements * 100 : 0;
}

/// Achievements View
class AchievementsView extends StatelessWidget {
  const AchievementsView({super.key});

  Color _t(Color c, bool d) => NeoBrutalismTheme.getThemedColor(c, d);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = Get.find<AchievementsController>();

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      body: Column(
        children: [
          _buildHeader(isDark, ctrl),
          Expanded(
            child: Obx(() {
              ctrl.checkAll();
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                children: [
                  // Streak card
                  _buildStreakCard(isDark, ctrl),
                  const SizedBox(height: 16),

                  // Progress
                  _buildProgressCard(isDark, ctrl),
                  const SizedBox(height: 20),

                  // Achievements grid
                  Text('ALL ACHIEVEMENTS', style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w900, letterSpacing: 0.5,
                      color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                  const SizedBox(height: 10),
                  ...ctrl.allAchievements.asMap().entries.map((entry) {
                    final a = entry.value;
                    final unlocked = ctrl.unlockedIds.contains(a.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildAchievementCard(a, unlocked, isDark)
                          .animate().fadeIn(delay: (100 + entry.key * 40).ms),
                    );
                  }),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, AchievementsController ctrl) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 16,
        left: 20, right: 20, bottom: 14,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : _t(NeoBrutalismTheme.accentYellow, isDark),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ACHIEVEMENTS', style: TextStyle(fontSize: 22,
                    fontWeight: FontWeight.w900, letterSpacing: -0.5,
                    color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                Obx(() => Text('${ctrl.unlockedCount}/${ctrl.totalAchievements} unlocked',
                    style: TextStyle(fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[700]))),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildStreakCard(bool isDark, AchievementsController ctrl) {
    return Obx(() => NeoCard(
      color: _t(NeoBrutalismTheme.accentOrange, isDark),
      borderColor: NeoBrutalismTheme.primaryBlack,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 44)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NO-SPEND STREAK', style: TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w900, letterSpacing: 0.5,
                    color: NeoBrutalismTheme.primaryBlack)),
                const SizedBox(height: 4),
                Text('${ctrl.currentStreak.value} days',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900,
                        color: NeoBrutalismTheme.primaryBlack)),
                Text('Best: ${ctrl.bestStreak.value} days',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildProgressCard(bool isDark, AchievementsController ctrl) {
    return Obx(() {
      final pct = ctrl.progressPercent;
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
                const Text('PROGRESS', style: TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w900, letterSpacing: 0.5,
                    color: NeoBrutalismTheme.primaryBlack)),
                Text('${pct.toStringAsFixed(0)}%', style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5),
              ),
              child: FractionallySizedBox(
                widthFactor: (pct / 100).clamp(0.0, 1.0),
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: _t(NeoBrutalismTheme.accentGreen, isDark),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAchievementCard(Achievement a, bool unlocked, bool isDark) {
    return NeoCard(
      color: unlocked
          ? _t(a.color, isDark)
          : (isDark ? NeoBrutalismTheme.darkSurface : Colors.grey[200]!),
      borderColor: NeoBrutalismTheme.primaryBlack,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Text(unlocked ? a.emoji : '🔒', style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                    color: unlocked
                        ? NeoBrutalismTheme.primaryBlack
                        : (isDark ? Colors.grey[600] : Colors.grey[500]))),
                const SizedBox(height: 2),
                Text(a.description, style: TextStyle(fontSize: 12,
                    color: unlocked ? Colors.black54 : (isDark ? Colors.grey[700] : Colors.grey[400]))),
              ],
            ),
          ),
          if (unlocked)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: NeoBrutalismTheme.primaryBlack,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.check, size: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }
}