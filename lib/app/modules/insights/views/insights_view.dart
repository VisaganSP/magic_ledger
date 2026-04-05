import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/services/insights_service.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_card.dart';
import '../../account/controllers/account_controller.dart';

class InsightsView extends StatefulWidget {
  const InsightsView({super.key});

  @override
  State<InsightsView> createState() => _InsightsViewState();
}

class _InsightsViewState extends State<InsightsView> {
  final InsightsService _service = InsightsService();
  List<InsightItem> _insights = [];
  String _selectedPeriod = 'This Month';

  @override
  void initState() {
    super.initState();
    _generateInsights();
  }

  void _generateInsights() {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (_selectedPeriod) {
      case 'This Week':
        start = now.subtract(Duration(days: now.weekday - 1));
        break;
      case '3 Months':
        start = DateTime(now.year, now.month - 2, 1);
        break;
      case '6 Months':
        start = DateTime(now.year, now.month - 5, 1);
        break;
      case 'This Year':
        start = DateTime(now.year, 1, 1);
        break;
      default:
        start = DateTime(now.year, now.month, 1);
    }

    final accId = Get.find<AccountController>().selectedAccountId.value;

    setState(() {
      _insights = _service.generateInsights(start: start, end: end, accountId: accId);
    });
  }

  Color _t(Color c, bool d) => NeoBrutalismTheme.getThemedColor(c, d);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Count by type
    int warnings = _insights.where((i) => i.type == 'warning').length;
    int achievements = _insights.where((i) => i.type == 'achievement').length;
    int tips = _insights.where((i) => i.type == 'tip' || i.type == 'trend' || i.type == 'anomaly').length;

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      body: Column(
        children: [
          _buildHeader(isDark, warnings, achievements, tips),
          _buildPeriodChips(isDark),
          Expanded(
            child: _insights.isEmpty
                ? _buildEmpty(isDark)
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: _insights.length,
              itemBuilder: (ctx, i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildInsightCard(_insights[i], isDark)
                      .animate()
                      .fadeIn(delay: (80 + i * 60).ms)
                      .slideY(begin: 0.04, end: 0),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, int warnings, int achievements, int tips) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20, right: 20, bottom: 14,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : _t(NeoBrutalismTheme.accentPurple, isDark),
        border: const Border(bottom: BorderSide(
            color: NeoBrutalismTheme.primaryBlack, width: NeoBrutalismTheme.borderWidth)),
      ),
      child: Column(
        children: [
          Row(
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
                    Text('SPENDING INSIGHTS',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5,
                            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                    Text('${_insights.length} insights for $_selectedPeriod',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : Colors.grey[700])),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _generateInsights,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: NeoBrutalismTheme.neoBox(
                    color: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
                    offset: 3, borderColor: NeoBrutalismTheme.primaryBlack,
                  ),
                  child: Icon(Icons.refresh,
                      color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
                ),
              ),
            ],
          ),
          // Type summary badges
          if (_insights.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (warnings > 0) _buildBadge('⚠️ $warnings', Colors.red, isDark),
                if (warnings > 0) const SizedBox(width: 8),
                if (achievements > 0) _buildBadge('🏆 $achievements', const Color(0xFFB8E994), isDark),
                if (achievements > 0) const SizedBox(width: 8),
                if (tips > 0) _buildBadge('💡 $tips', const Color(0xFFFDD663), isDark),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _t(color, isDark),
        border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
          color: NeoBrutalismTheme.primaryBlack)),
    );
  }

  Widget _buildPeriodChips(bool isDark) {
    final periods = ['This Week', 'This Month', '3 Months', '6 Months', 'This Year'];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: periods.length,
        itemBuilder: (ctx, i) {
          final p = periods[i];
          final sel = _selectedPeriod == p;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedPeriod = p);
              _generateInsights();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: sel
                  ? NeoBrutalismTheme.neoBox(
                  color: _t(NeoBrutalismTheme.accentPink, isDark),
                  offset: 2, borderColor: NeoBrutalismTheme.primaryBlack)
                  : BoxDecoration(
                  color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
                  border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2)),
              child: Center(child: Text(p.toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
                      color: sel ? NeoBrutalismTheme.primaryBlack
                          : (isDark ? Colors.grey[500] : Colors.grey[600])))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInsightCard(InsightItem insight, bool isDark) {
    final typeConfig = <String, Map<String, dynamic>>{
      'stat': {'bg': const Color(0xFFBFE3F0), 'badge': '📊 SUMMARY'},
      'warning': {'bg': const Color(0xFFFFB49A), 'badge': '⚠️ WARNING'},
      'anomaly': {'bg': const Color(0xFFFDB5D6), 'badge': '🔍 ANOMALY'},
      'trend': {'bg': const Color(0xFFE8CCFF), 'badge': '📈 TREND'},
      'tip': {'bg': const Color(0xFFFDD663), 'badge': '💡 TIP'},
      'achievement': {'bg': const Color(0xFFB8E994), 'badge': '🏆 WIN'},
    };
    final config = typeConfig[insight.type] ?? typeConfig['tip']!;
    final bgColor = _t(config['bg'] as Color, isDark);
    final badge = config['badge'] as String;

    return GestureDetector(
      onTap: insight.actionRoute != null
          ? () => Get.toNamed(insight.actionRoute!)
          : null,
      child: NeoCard(
        color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
        borderColor: NeoBrutalismTheme.primaryBlack,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Color strip
            Container(height: 5, color: bgColor),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + Title + Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: bgColor,
                          border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
                        ),
                        child: Icon(insight.icon, size: 22, color: NeoBrutalismTheme.primaryBlack),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: bgColor,
                                border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5),
                              ),
                              child: Text(badge, style: const TextStyle(fontSize: 9,
                                  fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
                            ),
                            // Title
                            Text(insight.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                                height: 1.2,
                                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                          ],
                        ),
                      ),
                      if (insight.actionRoute != null)
                        Icon(Icons.chevron_right, size: 20,
                            color: isDark ? Colors.grey[600] : Colors.grey[400]),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Body text
                  Text(insight.body, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                      height: 1.5,
                      color: isDark ? Colors.grey[400] : Colors.grey[700])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: NeoBrutalismTheme.neoBox(
              color: _t(NeoBrutalismTheme.accentPurple, isDark),
              offset: 4, borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: const Icon(Icons.insights, size: 40, color: NeoBrutalismTheme.primaryBlack),
          ),
          const SizedBox(height: 20),
          Text('NO INSIGHTS YET', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 8),
          Text('Add some transactions to see\nsmart spending insights',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[500] : Colors.grey[600])),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}