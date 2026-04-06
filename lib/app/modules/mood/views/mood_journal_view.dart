import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_card.dart';
import '../../category/controllers/category_controller.dart';
import '../../expense/controllers/expense_controller.dart';

/// Moods: stores mood per expense ID in a separate Hive box.
/// No model changes needed.
class MoodService extends GetxService {
  late Box _moodBox;

  static const moods = {
    'happy': {'emoji': '😊', 'label': 'Happy', 'color': 0xFFB8E994},
    'stressed': {'emoji': '😰', 'label': 'Stressed', 'color': 0xFFFFB49A},
    'bored': {'emoji': '😴', 'label': 'Bored', 'color': 0xFFBFE3F0},
    'social': {'emoji': '🎉', 'label': 'Social', 'color': 0xFFE8CCFF},
    'impulse': {'emoji': '⚡', 'label': 'Impulse', 'color': 0xFFFDD663},
    'necessary': {'emoji': '📋', 'label': 'Necessary', 'color': 0xFFCCCCCC},
  };

  @override
  void onInit() {
    super.onInit();
    _initBox();
  }

  Future<void> _initBox() async {
    if (!Hive.isBoxOpen('expense_moods')) {
      _moodBox = await Hive.openBox('expense_moods');
    } else {
      _moodBox = Hive.box('expense_moods');
    }
  }

  /// Set mood for an expense
  Future<void> setMood(String expenseId, String mood) async {
    await _moodBox.put(expenseId, mood);
  }

  /// Get mood for an expense
  String? getMood(String expenseId) {
    return _moodBox.get(expenseId) as String?;
  }

  /// Remove mood
  Future<void> removeMood(String expenseId) async {
    await _moodBox.delete(expenseId);
  }

  /// Get all expense IDs with moods
  Map<String, String> getAllMoods() {
    final result = <String, String>{};
    for (final key in _moodBox.keys) {
      result[key.toString()] = _moodBox.get(key).toString();
    }
    return result;
  }
}

/// Mood Journal View — tag expenses + see mood insights
class MoodJournalView extends StatefulWidget {
  const MoodJournalView({super.key});

  @override
  State<MoodJournalView> createState() => _MoodJournalViewState();
}

class _MoodJournalViewState extends State<MoodJournalView> {
  late final MoodService _moodService;
  late final ExpenseController _expCtrl;
  late final CategoryController _catCtrl;

  @override
  void initState() {
    super.initState();
    _moodService = Get.find<MoodService>();
    _expCtrl = Get.find<ExpenseController>();
    _catCtrl = Get.find<CategoryController>();
  }

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
            child: Obx(() {
              // Force reactivity
              final _ = _expCtrl.expenses.length;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                children: [
                  _buildMoodInsights(isDark),
                  const SizedBox(height: 20),
                  _buildRecentExpenses(isDark),
                ],
              );
            }),
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
            : _t(const Color(0xFFFDB5D6), isDark),
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
              Text('MOOD JOURNAL', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
              Text('How does spending make you feel?', style: TextStyle(fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[700])),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildMoodInsights(bool isDark) {
    final allMoods = _moodService.getAllMoods();
    if (allMoods.isEmpty) {
      return NeoCard(
        color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
        borderColor: NeoBrutalismTheme.primaryBlack,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('🎭', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text('START TAGGING MOODS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
            const SizedBox(height: 6),
            Text('Tap any expense below to tag how you felt.\nPatterns will appear here after a few tags.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[600])),
          ],
        ),
      );
    }

    // Calculate mood stats
    final moodTotals = <String, double>{};
    final moodCounts = <String, int>{};

    for (final entry in allMoods.entries) {
      final expense = _expCtrl.expenses.firstWhereOrNull((e) => e.id == entry.key);
      if (expense != null) {
        moodTotals[entry.value] = (moodTotals[entry.value] ?? 0) + expense.amount;
        moodCounts[entry.value] = (moodCounts[entry.value] ?? 0) + 1;
      }
    }

    final totalTagged = moodTotals.values.fold(0.0, (s, v) => s + v);
    final sorted = moodTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MOOD INSIGHTS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 10),

        // Mood breakdown cards
        ...sorted.map((entry) {
          final moodData = MoodService.moods[entry.key];
          if (moodData == null) return const SizedBox.shrink();
          final pct = totalTagged > 0 ? (entry.value / totalTagged * 100) : 0.0;
          final count = moodCounts[entry.key] ?? 0;
          final avg = count > 0 ? entry.value / count : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NeoCard(
              color: Color(moodData['color'] as int),
              borderColor: NeoBrutalismTheme.primaryBlack,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Text(moodData['emoji'] as String, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((moodData['label'] as String).toUpperCase(),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900,
                                color: NeoBrutalismTheme.primaryBlack)),
                        Text('$count transactions • Avg ₹${avg.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${entry.value.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900,
                              color: NeoBrutalismTheme.primaryBlack)),
                      Text('${pct.toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                              color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.04, end: 0);
        }),

        // Insight text
        if (sorted.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: NeoBrutalismTheme.neoBox(
              color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
              offset: 3, borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡 PATTERN DETECTED', style: TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w900, letterSpacing: 0.5,
                    color: NeoBrutalismTheme.primaryBlack)),
                const SizedBox(height: 6),
                Text(_generateInsight(sorted, moodCounts, totalTagged),
                    style: TextStyle(fontSize: 13, height: 1.5,
                        color: isDark ? Colors.grey[400] : Colors.grey[700])),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _generateInsight(List<MapEntry<String, double>> sorted, Map<String, int> counts, double total) {
    if (sorted.isEmpty) return '';
    final top = sorted.first;
    final topData = MoodService.moods[top.key];
    final pct = total > 0 ? (top.value / total * 100) : 0.0;

    String insight = '${topData?['emoji']} ${topData?['label']} spending makes up ${pct.toStringAsFixed(0)}% of tagged expenses (₹${top.value.toStringAsFixed(0)}).';

    if (top.key == 'impulse') {
      insight += ' Impulse buys are your biggest mood trigger — try a 24-hour rule before purchases over ₹500.';
    } else if (top.key == 'stressed') {
      insight += ' Stress spending is real. Try free alternatives: walks, cooking, journaling.';
    } else if (top.key == 'bored') {
      insight += ' Boredom costs you money. Find free hobbies to fill the gap.';
    } else if (top.key == 'social') {
      insight += ' Social spending is natural but can add up. Set a monthly social budget.';
    } else if (top.key == 'happy') {
      insight += ' Most spending makes you happy — that\'s a good sign you\'re spending on things that matter.';
    }

    return insight;
  }

  Widget _buildRecentExpenses(bool isDark) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final recent = _expCtrl.expenses
        .where((e) => !e.date.isBefore(monthStart))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TAG YOUR EXPENSES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 10),
        ...recent.take(20).toList().asMap().entries.map((entry) {
          final e = entry.value;
          final currentMood = _moodService.getMood(e.id);
          final cat = _catCtrl.getCategoryForExpense(e.categoryId);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => _showMoodPicker(e.id, currentMood, isDark),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: NeoBrutalismTheme.neoBox(
                  color: currentMood != null
                      ? Color(MoodService.moods[currentMood]?['color'] as int? ?? 0xFFFFFFFF)
                      : (isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite),
                  offset: 2, borderColor: NeoBrutalismTheme.primaryBlack,
                ),
                child: Row(
                  children: [
                    if (currentMood != null)
                      Text(MoodService.moods[currentMood]?['emoji'] as String? ?? '',
                          style: const TextStyle(fontSize: 22))
                    else
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.add, size: 16, color: NeoBrutalismTheme.primaryBlack),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                              color: isDark && currentMood == null
                                  ? NeoBrutalismTheme.darkText
                                  : NeoBrutalismTheme.primaryBlack),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('${cat.icon} ${cat.name} • ${e.date.day}/${e.date.month}',
                              style: const TextStyle(fontSize: 10, color: Colors.black54)),
                        ],
                      ),
                    ),
                    Text('₹${e.amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                            color: NeoBrutalismTheme.primaryBlack)),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (100 + entry.key * 30).ms),
          );
        }),
      ],
    );
  }

  void _showMoodPicker(String expenseId, String? currentMood, bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: const Border(
            top: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
            left: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
            right: BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('HOW DID THIS FEEL?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12, runSpacing: 12,
              alignment: WrapAlignment.center,
              children: MoodService.moods.entries.map((entry) {
                final isSel = currentMood == entry.key;
                return GestureDetector(
                  onTap: () async {
                    await _moodService.setMood(expenseId, entry.key);
                    Navigator.of(Get.context!).pop();
                    setState(() {});
                  },
                  child: Container(
                    width: 90, height: 80,
                    decoration: isSel
                        ? NeoBrutalismTheme.neoBox(
                        color: Color(entry.value['color'] as int),
                        offset: 4, borderColor: NeoBrutalismTheme.primaryBlack)
                        : NeoBrutalismTheme.neoBox(
                        color: Color(entry.value['color'] as int).withOpacity(0.5),
                        offset: 2, borderColor: NeoBrutalismTheme.primaryBlack),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(entry.value['emoji'] as String, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text((entry.value['label'] as String).toUpperCase(),
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900,
                                color: NeoBrutalismTheme.primaryBlack)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (currentMood != null) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  await _moodService.removeMood(expenseId);
                  Navigator.of(Get.context!).pop();
                  setState(() {});
                },
                child: Text('REMOVE MOOD', style: TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w900, color: Colors.red[400])),
              ),
            ],
            SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
          ],
        ),
      ),
    );
  }
}