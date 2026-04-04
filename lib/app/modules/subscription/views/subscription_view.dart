import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/subscription_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../controllers/subscription_controller.dart';

class SubscriptionView extends GetView<SubscriptionController> {
  const SubscriptionView({super.key});

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
              if (controller.subscriptions.isEmpty) return _buildEmpty(isDark);
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                children: [
                  _buildCostDashboard(isDark),
                  const SizedBox(height: 16),

                  // Renewing soon
                  if (controller.renewingSoon.isNotEmpty) ...[
                    _buildSection('RENEWING SOON', '${controller.renewingSoonCount.value}',
                        NeoBrutalismTheme.accentOrange, isDark),
                    const SizedBox(height: 10),
                    ...controller.renewingSoon.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildSubCard(e.value, isDark, highlight: true)
                          .animate().fadeIn(delay: (100 + e.key * 60).ms)
                          .slideX(begin: 0.04, end: 0),
                    )),
                    const SizedBox(height: 16),
                  ],

                  // Active
                  _buildSection('ACTIVE', '${controller.activeCount.value}',
                      NeoBrutalismTheme.accentGreen, isDark),
                  const SizedBox(height: 10),
                  ...controller.active.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildSubCard(e.value, isDark)
                        .animate().fadeIn(delay: (200 + e.key * 40).ms),
                  )),

                  // Inactive
                  if (controller.inactive.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSection('PAUSED', '${controller.inactive.length}',
                        Colors.grey, isDark),
                    const SizedBox(height: 10),
                    ...controller.inactive.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildSubCard(s, isDark, faded: true),
                    )),
                  ],
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
        top: MediaQuery.of(Get.context!).padding.top + 16,
        left: 20, right: 20, bottom: 14,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : _t(NeoBrutalismTheme.accentPink, isDark),
        border: const Border(bottom: BorderSide(
            color: NeoBrutalismTheme.primaryBlack, width: NeoBrutalismTheme.borderWidth)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
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
          Text('SUBSCRIPTIONS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const Spacer(),
          GestureDetector(
            onTap: () => Get.toNamed('/add-subscription'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: NeoBrutalismTheme.neoBox(
                color: NeoBrutalismTheme.accentGreen,
                offset: 3, borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: const Icon(Icons.add, color: NeoBrutalismTheme.primaryBlack),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildCostDashboard(bool isDark) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: NeoBrutalismTheme.neoBox(
        color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
        offset: 4, borderColor: NeoBrutalismTheme.primaryBlack,
      ),
      child: Column(
        children: [
          // Monthly & Yearly
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MONTHLY COST', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                        color: isDark ? Colors.grey[500] : Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text('₹${controller.monthlyTotal.value.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                  ],
                ),
              ),
              Container(width: 2, height: 40, color: NeoBrutalismTheme.primaryBlack),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('YEARLY COST', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                        color: isDark ? Colors.grey[500] : Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text('₹${controller.yearlyTotal.value.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Daily cost + active count
          Row(
            children: [
              _buildMiniStat('DAILY', '₹${controller.dailyCost.toStringAsFixed(0)}/day',
                  _t(NeoBrutalismTheme.accentYellow, isDark), isDark),
              const SizedBox(width: 8),
              _buildMiniStat('ACTIVE', '${controller.activeCount.value} subs',
                  _t(NeoBrutalismTheme.accentGreen, isDark), isDark),
              const SizedBox(width: 8),
              if (controller.mostExpensive != null)
                _buildMiniStat('TOP', controller.mostExpensive!.name,
                    _t(NeoBrutalismTheme.accentPink, isDark), isDark),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildMiniStat(String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.primaryBlack, letterSpacing: 0.3)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.primaryBlack),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String count, Color color, bool isDark) {
    return Row(
      children: [
        Container(width: 4, height: 20,
            decoration: BoxDecoration(color: _t(color, isDark), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(count, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
              color: isDark ? Colors.grey[400] : Colors.grey[700])),
        ),
      ],
    );
  }

  Widget _buildSubCard(SubscriptionModel sub, bool isDark,
      {bool highlight = false, bool faded = false}) {
    final iconEmoji = sub.icon ?? '📦';
    final daysLeft = sub.daysUntilRenewal;
    final renewText = daysLeft == 0 ? 'Today'
        : daysLeft == 1 ? 'Tomorrow'
        : daysLeft < 0 ? '${daysLeft.abs()}d overdue'
        : '${daysLeft}d';

    return GestureDetector(
      onTap: () => _showSubDetail(sub, isDark),
      child: Opacity(
        opacity: faded ? 0.5 : 1.0,
        child: NeoCard(
          color: highlight
              ? _t(NeoBrutalismTheme.accentYellow, isDark)
              : (isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite),
          borderColor: NeoBrutalismTheme.primaryBlack,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Icon
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: sub.color != null
                      ? Color(int.parse('FF${sub.color!}', radix: 16))
                      : _t(NeoBrutalismTheme.accentSkyBlue, isDark),
                  border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
                ),
                child: Center(child: Text(iconEmoji, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sub.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                        color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(sub.cycle.toUpperCase(), style: TextStyle(fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.grey[400] : Colors.grey[600])),
                        ),
                        const SizedBox(width: 6),
                        Text(sub.autoDeducted ? '🔄 Auto-pay' : '💳 Manual',
                            style: TextStyle(fontSize: 10,
                                color: isDark ? Colors.grey[500] : Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
              // Amount + renewal
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${sub.amount.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900,
                          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                  Text(renewText,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: daysLeft < 0
                              ? Colors.red
                              : (daysLeft <= 3
                              ? (isDark ? Colors.orange[300] : Colors.orange[700])
                              : (isDark ? Colors.grey[500] : Colors.grey[600])))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubDetail(SubscriptionModel sub, bool isDark) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(sub.icon ?? '📦', style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sub.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                      Text('₹${sub.amount.toStringAsFixed(2)} / ${sub.cycle}',
                          style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Cost breakdown
            Row(
              children: [
                Expanded(child: _detailBox('MONTHLY', '₹${sub.monthlyCost.toStringAsFixed(0)}', isDark)),
                const SizedBox(width: 8),
                Expanded(child: _detailBox('YEARLY', '₹${sub.yearlyCost.toStringAsFixed(0)}', isDark)),
                const SizedBox(width: 8),
                Expanded(child: _detailBox('NEXT', '${sub.nextRenewal.day}/${sub.nextRenewal.month}/${sub.nextRenewal.year}', isDark)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _detailBox('SINCE', '${sub.startDate.day}/${sub.startDate.month}/${sub.startDate.year}', isDark)),
                const SizedBox(width: 8),
                Expanded(child: _detailBox('PAYMENT', sub.autoDeducted ? 'Auto-pay' : 'Manual', isDark)),
                const SizedBox(width: 8),
                Expanded(child: _detailBox('STATUS', sub.isActive ? 'Active' : 'Paused', isDark)),
              ],
            ),

            if (sub.notes != null && sub.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(sub.notes!, style: TextStyle(fontSize: 13,
                  color: isDark ? Colors.grey[400] : Colors.grey[600])),
            ],

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: NeoButton(
                    text: sub.isActive ? 'PAUSE' : 'RESUME',
                    onPressed: () {
                      Get.back();
                      controller.toggleActive(sub.id);
                    },
                    color: sub.isActive
                        ? _t(NeoBrutalismTheme.accentYellow, isDark)
                        : _t(NeoBrutalismTheme.accentGreen, isDark),
                    icon: sub.isActive ? Icons.pause : Icons.play_arrow,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NeoButton(
                    text: 'EDIT',
                    onPressed: () {
                      Get.back();
                      Get.toNamed('/add-subscription', arguments: sub);
                    },
                    color: _t(NeoBrutalismTheme.accentSkyBlue, isDark),
                    icon: Icons.edit,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Get.back();
                    controller.deleteSubscription(sub.id);
                  },
                  child: Container(
                    width: 48, height: 48,
                    decoration: NeoBrutalismTheme.neoBox(
                      color: Colors.red.shade100, offset: 2,
                      borderColor: NeoBrutalismTheme.primaryBlack,
                    ),
                    child: const Icon(Icons.delete, color: Colors.red, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailBox(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? NeoBrutalismTheme.darkBackground : Colors.grey[100],
        border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900,
              color: isDark ? Colors.grey[500] : Colors.grey[600], letterSpacing: 0.3)),
          const SizedBox(height: 3),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
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
              color: _t(NeoBrutalismTheme.accentPink, isDark),
              offset: 4, borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: const Icon(Icons.autorenew, size: 40, color: NeoBrutalismTheme.primaryBlack),
          ),
          const SizedBox(height: 20),
          Text('NO SUBSCRIPTIONS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 8),
          Text('Track Netflix, Spotify, gym\nand other recurring payments',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[500] : Colors.grey[600])),
          const SizedBox(height: 24),
          SizedBox(width: 220, child: NeoButton(
            text: 'ADD SUBSCRIPTION', onPressed: () => Get.toNamed('/add-subscription'),
            color: NeoBrutalismTheme.accentGreen, icon: Icons.add,
          )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}