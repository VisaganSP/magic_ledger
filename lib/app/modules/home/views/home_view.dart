import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/expense_model.dart';
import '../../../data/models/income_model.dart';
import '../../../data/models/todo_model.dart';
import '../../../data/services/export_service.dart';
import '../../../data/services/period_service.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../account/controllers/account_controller.dart';
import '../../analytics/views/analytics_view.dart';
import '../../category/controllers/category_controller.dart';
import '../../expense/views/expense_view.dart';
import '../../notifications/controllers/notification_inbox_controller.dart';
import '../../todo/views/todo_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.selectedIndex.value == 0) {
        controller.refreshStats();
      }
    });

    final categoryController = Get.find<CategoryController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Obx(
                      () => IndexedStack(
                    index: controller.selectedIndex.value,
                    children: [
                      _buildDashboardPage(categoryController, isDark),
                      ExpenseView(),
                      TodoView(),
                      AnalyticsView(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.11),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNav(isDark),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DASHBOARD PAGE — the main scrollable home content
  // ═══════════════════════════════════════════════════════════

  Widget _buildDashboardPage(
      CategoryController categoryController, bool isDark) {
    return CustomScrollView(
      slivers: [
        // 1. Header
        SliverToBoxAdapter(child: _buildHeader(isDark)),
        // 2. Period Navigator
        SliverToBoxAdapter(child: _buildPeriodNavigator(isDark)),
        // 3. Financial Snapshot Hero
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _buildFinancialHero(isDark),
          ),
        ),
        // 4. Account Strip
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: _buildAccountStrip(isDark),
          ),
        ),
        // 5. Comparison Row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _buildComparisonRow(isDark),
          ),
        ),
        // 6. Quick Actions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: _buildQuickActions(isDark),
          ),
        ),
        // 7. Recent Transactions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: _buildRecentTransactions(categoryController, isDark),
          ),
        ),
        // 8. Upcoming Todos
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: _buildUpcomingTodos(isDark),
          ),
        ),
        // 9. Manage Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: _buildManageSection(isDark),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 1. HEADER — minimal, clean
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 14,
      ),
      color: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MAGIC LEDGER',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  color: isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 2),
              Obx(() => Text(
                controller.periodService.isCurrentPeriod
                    ? 'Track. Save. Achieve.'
                    : 'Viewing history',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              )),
            ],
          ),
          Row(
            children: [
              _buildHeaderButton(
                icon: Icons.add,
                color: NeoBrutalismTheme.accentGreen,
                onTap: () => _showAddMenu(isDark),
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              // ═══ NOTIFICATION BELL WITH BADGE ═══
              Obx(() {
                final inboxController = Get.find<NotificationInboxController>();
                final count = inboxController.unreadCount.value;
                return GestureDetector(
                  onTap: () => Get.toNamed('/notifications'),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: NeoBrutalismTheme.neoBox(
                          color: count > 0
                              ? _themedColor(NeoBrutalismTheme.accentYellow, isDark)
                              : (isDark
                              ? NeoBrutalismTheme.darkSurface
                              : NeoBrutalismTheme.primaryWhite),
                          offset: 3,
                          borderColor: NeoBrutalismTheme.primaryBlack,
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            size: 22, color: NeoBrutalismTheme.primaryBlack),
                      ),
                      if (count > 0)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: NeoBrutalismTheme.primaryBlack,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                count > 9 ? '9+' : '$count',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(width: 10),
              _buildHeaderButton(
                icon: Icons.settings_outlined,
                color: isDark
                    ? NeoBrutalismTheme.darkSurface
                    : NeoBrutalismTheme.primaryWhite,
                onTap: () => Get.toNamed('/settings'),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: NeoBrutalismTheme.neoBox(
          color: color,
          offset: 3,
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: Icon(icon, size: 22, color: NeoBrutalismTheme.primaryBlack),
      ),
    );
  }

  void _showAddMenu(bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            NeoButton(
              text: 'ADD EXPENSE',
              onPressed: () {
                Get.back();
                Get.toNamed('/add-expense');
              },
              color: _themedColor(NeoBrutalismTheme.accentOrange, isDark),
              icon: Icons.remove_circle_outline,
            ),
            const SizedBox(height: 12),
            NeoButton(
              text: 'ADD INCOME',
              onPressed: () {
                Get.back();
                Get.toNamed('/add-income');
              },
              color: _themedColor(NeoBrutalismTheme.accentGreen, isDark),
              icon: Icons.add_circle_outline,
            ),
            const SizedBox(height: 12),
            NeoButton(
              text: 'ADD TODO',
              onPressed: () {
                Get.back();
                Get.toNamed('/add-todo');
              },
              color: _themedColor(NeoBrutalismTheme.accentPurple, isDark),
              icon: Icons.task_alt,
            ),
            const SizedBox(height: 12),
            NeoButton(
              text: 'ADD SAVINGS GOAL',
              onPressed: () {
                Get.back();
                Get.toNamed('/add-savings-goal');
              },
              color: _themedColor(NeoBrutalismTheme.accentSkyBlue, isDark),
              icon: Icons.savings,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showExportSheet(bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
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
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            NeoButton(
              text: 'EXPORT ALL (CSV)',
              onPressed: () {
                Get.back();
                ExportService().exportAll(
                  expenses: controller.expenseController.expenses,
                  incomes: controller.incomeController.incomes,
                  categories: Get.find<CategoryController>().categories,
                  accounts: controller.accountController.accounts,
                );
              },
              color: _themedColor(NeoBrutalismTheme.accentGreen, isDark),
              icon: Icons.table_chart,
            ),
            const SizedBox(height: 12),
            NeoButton(
              text: 'EXPORT EXPENSES ONLY',
              onPressed: () {
                Get.back();
                ExportService().exportExpenses(
                  expenses: controller.expenseController.expenses,
                  categories: Get.find<CategoryController>().categories,
                  accounts: controller.accountController.accounts,
                );
              },
              color: _themedColor(NeoBrutalismTheme.accentOrange, isDark),
              icon: Icons.receipt_long,
            ),
            const SizedBox(height: 12),
            NeoButton(
              text: 'EXPORT INCOMES ONLY',
              onPressed: () {
                Get.back();
                ExportService().exportIncomes(
                  incomes: controller.incomeController.incomes,
                  accounts: controller.accountController.accounts,
                );
              },
              color: _themedColor(NeoBrutalismTheme.accentSkyBlue, isDark),
              icon: Icons.arrow_downward_rounded,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 2. PERIOD NAVIGATOR
  // ═══════════════════════════════════════════════════════════

  Widget _buildPeriodNavigator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : NeoBrutalismTheme.primaryWhite,
        border: Border(
          bottom: BorderSide(
            color: NeoBrutalismTheme.primaryBlack.withOpacity(isDark ? 0.3 : 0.15),
            width: 1,
          ),
        ),
      ),
      child: Obx(() {
        final periodService = controller.periodService;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous month
            GestureDetector(
              onTap: () => periodService.previousMonth(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: NeoBrutalismTheme.neoBox(
                  color: isDark
                      ? NeoBrutalismTheme.darkBackground
                      : Colors.grey[50]!,
                  offset: 2,
                  borderColor: NeoBrutalismTheme.primaryBlack,
                ),
                child: const Icon(Icons.chevron_left,
                    size: 20, color: NeoBrutalismTheme.primaryBlack),
              ),
            ),
            const SizedBox(width: 20),

            // Current period display
            GestureDetector(
              onTap: () => _showMonthPicker(isDark),
              child: Column(
                children: [
                  Text(
                    periodService.monthName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                  Text(
                    '${periodService.selectedYear.value}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),

            // Next month (disabled if current)
            GestureDetector(
              onTap: periodService.canGoForward
                  ? () => periodService.nextMonth()
                  : null,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: NeoBrutalismTheme.neoBox(
                  color: periodService.canGoForward
                      ? (isDark
                      ? NeoBrutalismTheme.darkBackground
                      : Colors.grey[50]!)
                      : (isDark ? NeoBrutalismTheme.darkSurface : Colors.grey[200]!),
                  offset: periodService.canGoForward ? 2 : 0,
                  borderColor: NeoBrutalismTheme.primaryBlack,
                ),
                child: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: periodService.canGoForward
                      ? NeoBrutalismTheme.primaryBlack
                      : Colors.grey,
                ),
              ),
            ),

            // "Today" button if not current month
            if (!periodService.isCurrentPeriod) ...[
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => periodService.goToCurrentMonth(),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: NeoBrutalismTheme.neoBox(
                    color: NeoBrutalismTheme.accentPurple,
                    offset: 2,
                    borderColor: NeoBrutalismTheme.primaryBlack,
                  ),
                  child: const Text(
                    'TODAY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    ).animate().fadeIn(delay: 100.ms);
  }

  void _showMonthPicker(bool isDark) {
    final periodService = controller.periodService;
    final tempYear = periodService.selectedYear.value.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
              color: NeoBrutalismTheme.primaryBlack, width: 3),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? NeoBrutalismTheme.darkSurface
                : NeoBrutalismTheme.primaryWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Obx(() {
            // Force reactive read at root scope so GetX tracks it
            final currentTempYear = tempYear.value;
            final selYear = periodService.selectedYear.value;
            final selMonth = periodService.selectedMonth.value;
            final now = DateTime.now();

            final shortNames = [
              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
            ];

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Year selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => tempYear.value--,
                      icon: Icon(
                        Icons.chevron_left,
                        color: isDark
                            ? NeoBrutalismTheme.darkText
                            : NeoBrutalismTheme.primaryBlack,
                      ),
                    ),
                    Text(
                      '$currentTempYear',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? NeoBrutalismTheme.darkText
                            : NeoBrutalismTheme.primaryBlack,
                      ),
                    ),
                    IconButton(
                      onPressed: currentTempYear < now.year
                          ? () => tempYear.value++
                          : null,
                      icon: Icon(
                        Icons.chevron_right,
                        color: currentTempYear < now.year
                            ? (isDark
                            ? NeoBrutalismTheme.darkText
                            : NeoBrutalismTheme.primaryBlack)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Month grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  childAspectRatio: 2.0,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: List.generate(12, (index) {
                    final month = index + 1;
                    final isCurrentSelection =
                        currentTempYear == selYear && month == selMonth;
                    final isFuture = currentTempYear > now.year ||
                        (currentTempYear == now.year && month > now.month);

                    return GestureDetector(
                      onTap: isFuture
                          ? null
                          : () {
                        Get.back();
                        Future.microtask(() {
                          periodService.goTo(currentTempYear, month);
                        });
                      },
                      child: Container(
                        decoration: isCurrentSelection
                            ? NeoBrutalismTheme.neoBox(
                          color: NeoBrutalismTheme.accentPurple,
                          offset: 2,
                          borderColor: NeoBrutalismTheme.primaryBlack,
                        )
                            : BoxDecoration(
                          color: isFuture
                              ? (isDark
                              ? NeoBrutalismTheme.darkSurface
                              : Colors.grey[200])
                              : (isDark
                              ? NeoBrutalismTheme.darkBackground
                              : NeoBrutalismTheme.primaryWhite),
                          border: Border.all(
                            color: NeoBrutalismTheme.primaryBlack,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            shortNames[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isCurrentSelection
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                              color: isFuture
                                  ? Colors.grey
                                  : (isCurrentSelection
                                  ? NeoBrutalismTheme.primaryBlack
                                  : (isDark
                                  ? NeoBrutalismTheme.darkText
                                  : NeoBrutalismTheme.primaryBlack)),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 3. FINANCIAL HERO — the centerpiece
  // ═══════════════════════════════════════════════════════════

  Widget _buildFinancialHero(bool isDark) {
    return Obx(() {
      final bal = controller.balance.value;
      final inc = controller.totalIncome.value;
      final exp = controller.totalExpenses.value;
      final maxBar = inc > exp ? inc : (exp > 0 ? exp : 1);

      return NeoCard(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : NeoBrutalismTheme.primaryWhite,
        borderColor: NeoBrutalismTheme.primaryBlack,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Balance label
            Text(
              'BALANCE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 6),

            // Big balance number
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _formatCurrencyFull(bal),
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: bal >= 0
                      ? (isDark ? Colors.green[400] : Colors.green[700])
                      : (isDark ? Colors.red[400] : Colors.red[700]),
                  letterSpacing: -1,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Savings badge
            if (inc > 0)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getHealthColor(
                      controller.savingsPercentage.value, isDark),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: NeoBrutalismTheme.primaryBlack,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '${controller.spendingHealth} • ${controller.savingsPercentage.value.toStringAsFixed(0)}% saved',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: NeoBrutalismTheme.primaryBlack,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Income / Expense bars
            Row(
              children: [
                // Income side
                Expanded(
                  child: _buildBarSection(
                    label: 'INCOME',
                    amount: inc,
                    barColor: _themedColor(NeoBrutalismTheme.accentGreen, isDark),
                    barWidth: maxBar > 0 ? (inc / maxBar) : 0,
                    icon: Icons.arrow_downward_rounded,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                // Expense side
                Expanded(
                  child: _buildBarSection(
                    label: 'SPENT',
                    amount: exp,
                    barColor: _themedColor(NeoBrutalismTheme.accentPink, isDark),
                    barWidth: maxBar > 0 ? (exp / maxBar) : 0,
                    icon: Icons.arrow_upward_rounded,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildBarSection({
    required String label,
    required double amount,
    required Color barColor,
    required double barWidth,
    required IconData icon,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _formatCurrency(amount),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark
                ? NeoBrutalismTheme.darkText
                : NeoBrutalismTheme.primaryBlack,
          ),
        ),
        const SizedBox(height: 6),
        // Progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: NeoBrutalismTheme.primaryBlack,
              width: 1,
            ),
          ),
          child: FractionallySizedBox(
            widthFactor: barWidth.clamp(0.0, 1.0),
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 4. ACCOUNT STRIP
  // ═══════════════════════════════════════════════════════════

  Widget _buildAccountStrip(bool isDark) {
    final accountController = controller.accountController;

    return Obx(() {
      final accounts = accountController.accounts;
      if (accounts.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: accounts.length + 1, // +1 for "All"
          itemBuilder: (ctx, index) {
            if (index == 0) {
              // "All accounts" chip
              final isSelected =
                  accountController.selectedAccountId.value == null;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildAccountChip(
                  label: 'All',
                  icon: '📊',
                  isSelected: isSelected,
                  color: NeoBrutalismTheme.accentPurple,
                  onTap: () => accountController.selectAccount(null),
                  isDark: isDark,
                ),
              );
            }

            final account = accounts[index - 1];
            final isSelected =
                accountController.selectedAccountId.value == account.id;
            final balance = accountController.getAccountBalance(account.id);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildAccountChip(
                label: '${account.name} ${_formatCurrency(balance)}',
                icon: account.icon,
                isSelected: isSelected,
                color: account.colorValue,
                onTap: () => accountController.selectAccount(account.id),
                isDark: isDark,
              ),
            );
          },
        ),
      );
    }).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildAccountChip({
    required String label,
    required String icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? NeoBrutalismTheme.neoBox(
          color: color,
          offset: 3,
          borderColor: NeoBrutalismTheme.primaryBlack,
        )
            : BoxDecoration(
          color: isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
          border: Border.all(
            color: NeoBrutalismTheme.primaryBlack,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected
                    ? NeoBrutalismTheme.primaryBlack
                    : (isDark ? Colors.grey[400] : Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 5. COMPARISON ROW
  // ═══════════════════════════════════════════════════════════

  Widget _buildComparisonRow(bool isDark) {
    return Obx(() {
      final expChange = controller.expenseChangePercent.value;
      final incChange = controller.incomeChangePercent.value;
      final prevLabel = controller.periodService.previousPeriodLabel;

      return Row(
        children: [
          Expanded(
            child: _buildComparisonChip(
              label: 'Spending',
              change: expChange,
              vsLabel: 'vs $prevLabel',
              isExpense: true,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildComparisonChip(
              label: 'Income',
              change: incChange,
              vsLabel: 'vs $prevLabel',
              isExpense: false,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          // Daily average
          Expanded(
            child: NeoCard(
              color: isDark
                  ? NeoBrutalismTheme.darkSurface
                  : NeoBrutalismTheme.lightSecondaryBg,
              borderColor: NeoBrutalismTheme.primaryBlack,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAILY AVG',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _formatCurrency(controller.dailyAvgExpense.value),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? NeoBrutalismTheme.darkText
                            : NeoBrutalismTheme.primaryBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }).animate().fadeIn(delay: 350.ms);
  }

  Widget _buildComparisonChip({
    required String label,
    required double change,
    required String vsLabel,
    required bool isExpense,
    required bool isDark,
  }) {
    // For expenses: increase is bad (red arrow up), decrease is good (green arrow down)
    // For income: increase is good (green arrow up), decrease is bad (red arrow down)
    final isPositiveChange = change > 0;
    final isGood = isExpense ? !isPositiveChange : isPositiveChange;
    final arrowIcon =
    isPositiveChange ? Icons.trending_up : Icons.trending_down;
    final changeColor = change == 0
        ? (isDark ? Colors.grey[400]! : Colors.grey[600]!)
        : (isGood
        ? (isDark ? Colors.green[400]! : Colors.green[700]!)
        : (isDark ? Colors.red[400]! : Colors.red[600]!));

    return NeoCard(
      color: isDark
          ? NeoBrutalismTheme.darkSurface
          : NeoBrutalismTheme.lightSecondaryBg,
      borderColor: NeoBrutalismTheme.primaryBlack,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (change != 0) ...[
                Icon(arrowIcon, size: 14, color: changeColor),
                const SizedBox(width: 2),
              ],
              Flexible(
                child: Text(
                  change == 0
                      ? '—'
                      : '${change.abs().toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: changeColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 6. QUICK ACTIONS — compact row
  // ═══════════════════════════════════════════════════════════

  Widget _buildQuickActions(bool isDark) {
    return Column(
      children: [
        // Existing row
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                label: 'EXPENSE',
                icon: Icons.remove_circle_outline,
                color: _themedColor(NeoBrutalismTheme.accentOrange, isDark),
                onTap: () => Get.toNamed('/add-expense'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildQuickActionButton(
                label: 'INCOME',
                icon: Icons.add_circle_outline,
                color: _themedColor(NeoBrutalismTheme.accentGreen, isDark),
                onTap: () => Get.toNamed('/add-income'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildQuickActionButton(
                label: 'TODO',
                icon: Icons.task_alt,
                color: _themedColor(NeoBrutalismTheme.accentBlue, isDark),
                onTap: () => Get.toNamed('/add-todo'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildQuickActionButton(
                label: 'TRANSFER',
                icon: Icons.swap_horiz,
                color: _themedColor(NeoBrutalismTheme.accentLilac, isDark),
                onTap: () => Get.toNamed('/accounts'),
                isDark: isDark,
              ),
            ),
          ],
        ),
        // ═══ NEW: Second row for new features ═══
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                label: 'SAVINGS',
                icon: Icons.savings,
                color: _themedColor(NeoBrutalismTheme.accentSkyBlue, isDark),
                onTap: () => Get.toNamed('/savings'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildQuickActionButton(
                label: 'DEBTS',
                icon: Icons.account_balance,
                color: _themedColor(NeoBrutalismTheme.accentPink, isDark),
                onTap: () => Get.toNamed('/debt'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildQuickActionButton(
                label: 'CALENDAR',
                icon: Icons.calendar_month,
                color: _themedColor(NeoBrutalismTheme.accentYellow, isDark),
                onTap: () => Get.toNamed('/financial-calendar'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildQuickActionButton(
                label: 'EXPORT',
                icon: Icons.download,
                color: _themedColor(NeoBrutalismTheme.accentSage, isDark),
                onTap: () => _showExportSheet(isDark),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: NeoBrutalismTheme.neoBox(
          color: color,
          offset: 3,
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: NeoBrutalismTheme.primaryBlack),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.primaryBlack,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 7. RECENT TRANSACTIONS
  // ═══════════════════════════════════════════════════════════

  Widget _buildRecentTransactions(
      CategoryController categoryController, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('RECENT TRANSACTIONS', isDark),
            Obx(() => Text(
              '${controller.totalTransactions.value} total',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            )),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          final transactions = controller.getRecentTransactions(limit: 5);

          if (transactions.isEmpty) {
            return _buildEmptyState(
              icon: Icons.receipt_long,
              title: 'No transactions yet',
              subtitle: 'Add your first expense or income',
              isDark: isDark,
            );
          }

          return Column(
            children: [
              ...transactions.asMap().entries.map((entry) {
                final t = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: t['type'] == 'expense'
                      ? _buildExpenseItem(
                      t['data'], categoryController, isDark)
                      : _buildIncomeItem(t['data'], isDark),
                ).animate().fadeIn(delay: (450 + entry.key * 50).ms);
              }),
              if (controller.totalTransactions.value > 5) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () =>
                      _showAllTransactionsDialog(categoryController, isDark),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: NeoBrutalismTheme.primaryBlack,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'VIEW ALL TRANSACTIONS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildExpenseItem(
      ExpenseModel expense,
      CategoryController categoryController,
      bool isDark) {
    final category = categoryController.getCategoryForExpense(expense.categoryId);
    final accountController = controller.accountController;
    final account = accountController.getAccountForDisplay(expense.accountId);

    return NeoCard(
      onTap: () => Get.toNamed('/expense-detail', arguments: expense),
      color: isDark
          ? NeoBrutalismTheme.darkSurface
          : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _themedColor(category.colorValue, isDark),
              border: Border.all(
                color: NeoBrutalismTheme.primaryBlack,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(category.icon, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                    if (expense.accountId != null) ...[
                      Text(
                        ' • ${account.icon} ${account.name}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[600] : Colors.grey[500],
                        ),
                      ),
                    ],
                    Text(
                      ' • ${expense.date.day}/${expense.date.month}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[600] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '-₹${expense.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.red[400] : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeItem(IncomeModel income, bool isDark) {
    final accountController = controller.accountController;
    final account = accountController.getAccountForDisplay(income.accountId);

    return NeoCard(
      onTap: () => Get.toNamed('/income-detail', arguments: income),
      color: isDark
          ? NeoBrutalismTheme.darkSurface
          : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _themedColor(NeoBrutalismTheme.accentGreen, isDark),
              border: Border.all(
                color: NeoBrutalismTheme.primaryBlack,
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(Icons.arrow_downward_rounded,
                  size: 20, color: NeoBrutalismTheme.primaryBlack),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  income.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      income.source,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                    if (income.accountId != null) ...[
                      Text(
                        ' • ${account.icon} ${account.name}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[600] : Colors.grey[500],
                        ),
                      ),
                    ],
                    Text(
                      ' • ${income.date.day}/${income.date.month}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[600] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '+₹${income.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.green[400] : Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  void _showAllTransactionsDialog(
      CategoryController categoryController, bool isDark) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
              color: NeoBrutalismTheme.primaryBlack, width: 3),
        ),
        child: Container(
          height: Get.height * 0.7,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? NeoBrutalismTheme.darkSurface
                : NeoBrutalismTheme.primaryWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                    'ALL — ${controller.periodService.periodLabelShort.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                    ),
                  )),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: NeoBrutalismTheme.neoBox(
                        color: NeoBrutalismTheme.primaryWhite,
                        offset: 2,
                        borderColor: NeoBrutalismTheme.primaryBlack,
                      ),
                      child: const Icon(Icons.close, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  final allTransactions = controller.getAllTransactions();

                  if (allTransactions.isEmpty) {
                    return Center(
                      child: Text(
                        'No transactions found',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: allTransactions.length,
                    itemBuilder: (context, index) {
                      final t = allTransactions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: t['type'] == 'expense'
                            ? _buildExpenseItem(
                            t['data'], categoryController, isDark)
                            : _buildIncomeItem(t['data'], isDark),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 8. UPCOMING TODOS
  // ═══════════════════════════════════════════════════════════

  Widget _buildUpcomingTodos(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('UPCOMING TODOS', isDark),
            GestureDetector(
              onTap: () => controller.changeTab(2),
              child: Text(
                'SEE ALL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          final upcomingTodos = controller.todoController.todos
              .where((todo) => !todo.isCompleted)
              .take(3)
              .toList();

          if (upcomingTodos.isEmpty) {
            return _buildEmptyState(
              icon: Icons.task_alt,
              title: 'All caught up',
              subtitle: 'No pending todos',
              isDark: isDark,
            );
          }

          return Column(
            children: upcomingTodos
                .asMap()
                .entries
                .map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildTodoItem(entry.value, isDark),
            ).animate().fadeIn(delay: (600 + entry.key * 50).ms))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildTodoItem(TodoModel todo, bool isDark) {
    final priorityColor = _getPriorityColor(todo.priority, isDark);

    return NeoCard(
      onTap: () => Get.toNamed('/todo-detail', arguments: todo),
      color: isDark
          ? NeoBrutalismTheme.darkSurface
          : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Priority indicator bar
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // Checkbox
          GestureDetector(
            onTap: () async {
              await controller.todoController.toggleTodo(todo);
              controller.calculateStats();
            },
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: todo.isCompleted
                    ? NeoBrutalismTheme.primaryBlack
                    : Colors.transparent,
                border: Border.all(
                  color: NeoBrutalismTheme.primaryBlack,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: todo.isCompleted
                  ? const Icon(Icons.check,
                  size: 14, color: NeoBrutalismTheme.primaryWhite)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
                    decoration:
                    todo.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (todo.dueDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Due ${todo.dueDate!.day}/${todo.dueDate!.month}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Priority badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: NeoBrutalismTheme.primaryBlack,
                width: 1,
              ),
            ),
            child: Text(
              _getPriorityLabel(todo.priority),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.primaryBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 9. MANAGE SECTION
  // ═══════════════════════════════════════════════════════════

  Widget _buildManageSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('MANAGE', isDark),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildManageCard(
                title: 'Categories',
                icon: Icons.category,
                color: _themedColor(NeoBrutalismTheme.accentYellow, isDark),
                onTap: () => Get.toNamed('/categories'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildManageCard(
                title: 'Budgets',
                icon: Icons.pie_chart_outline,
                color: _themedColor(NeoBrutalismTheme.accentBlue, isDark),
                onTap: () => Get.toNamed('/budgets'),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildManageCard(
                title: 'Accounts',
                icon: Icons.account_balance,
                color: _themedColor(NeoBrutalismTheme.accentSkyBlue, isDark),
                onTap: () => Get.toNamed('/accounts'),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 700.ms);
  }

  Widget _buildManageCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: NeoBrutalismTheme.neoBox(
          color: color,
          offset: 3,
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: NeoBrutalismTheme.primaryBlack),
            const SizedBox(height: 6),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.primaryBlack,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BOTTOM NAV
  // ═══════════════════════════════════════════════════════════

  Widget _buildBottomNav(bool isDark) {
    final screenHeight = MediaQuery.of(Get.context!).size.height;
    final navbarHeight = screenHeight * 0.09;

    return Container(
      margin: EdgeInsets.all(screenHeight * 0.02),
      height: navbarHeight.clamp(65.0, 85.0),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: NeoBrutalismTheme.primaryBlack,
            offset: Offset(4, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
          border: Border.all(
            color: NeoBrutalismTheme.primaryBlack,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenHeight * 0.01,
              vertical: screenHeight * 0.008,
            ),
            child: Obx(
                  () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: _buildNavItem(
                      Icons.home_rounded,
                      'HOME',
                      0,
                      _themedColor(NeoBrutalismTheme.accentPurple, isDark),
                      isDark,
                    ),
                  ),
                  Flexible(
                    child: _buildNavItem(
                      Icons.receipt_long_rounded,
                      'EXPENSES',
                      1,
                      _themedColor(NeoBrutalismTheme.accentPink, isDark),
                      isDark,
                    ),
                  ),
                  Flexible(
                    child: _buildNavItem(
                      Icons.check_box_rounded,
                      'TODOS',
                      2,
                      _themedColor(NeoBrutalismTheme.accentBlue, isDark),
                      isDark,
                    ),
                  ),
                  Flexible(
                    child: _buildNavItem(
                      Icons.bar_chart_rounded,
                      'STATS',
                      3,
                      _themedColor(NeoBrutalismTheme.accentYellow, isDark),
                      isDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 1, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildNavItem(
      IconData icon,
      String label,
      int index,
      Color activeColor,
      bool isDark,
      ) {
    final isSelected = controller.selectedIndex.value == index;
    final screenHeight = MediaQuery.of(Get.context!).size.height;
    final iconSize = screenHeight * 0.024;
    final selectedIconSize = screenHeight * 0.028;

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isSelected
                    ? selectedIconSize.clamp(32.0, 42.0)
                    : iconSize.clamp(26.0, 36.0),
                height: isSelected
                    ? selectedIconSize.clamp(32.0, 42.0)
                    : iconSize.clamp(26.0, 36.0),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? NeoBrutalismTheme.primaryBlack
                        : Colors.transparent,
                    width: isSelected ? 2 : 0,
                  ),
                  boxShadow: isSelected
                      ? [
                    const BoxShadow(
                      color: NeoBrutalismTheme.primaryBlack,
                      offset: Offset(2, 2),
                    ),
                  ]
                      : [],
                ),
                child: Icon(
                  icon,
                  size: isSelected
                      ? (selectedIconSize * 0.6).clamp(16.0, 22.0)
                      : (iconSize * 0.6).clamp(14.0, 20.0),
                  color: isSelected
                      ? NeoBrutalismTheme.primaryBlack
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
              SizedBox(height: screenHeight * 0.004),
              Text(
                label,
                style: TextStyle(
                  fontSize: (screenHeight * 0.011).clamp(8.0, 11.0),
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: isSelected
                      ? (isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack)
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SHARED HELPERS
  // ═══════════════════════════════════════════════════════════

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
        color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack,
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : NeoBrutalismTheme.lightSecondaryBg,
        border: Border.all(
          color: NeoBrutalismTheme.primaryBlack.withOpacity(isDark ? 0.3 : 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: isDark ? Colors.grey[600] : Colors.grey[400]),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[600] : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _themedColor(Color color, bool isDark) {
    return NeoBrutalismTheme.getThemedColor(color, isDark);
  }

  Color _getPriorityColor(int priority, bool isDark) {
    switch (priority) {
      case 3:
        return _themedColor(NeoBrutalismTheme.accentPink, isDark);
      case 2:
        return _themedColor(NeoBrutalismTheme.accentYellow, isDark);
      default:
        return isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.lightSecondaryBg;
    }
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 3:
        return 'HIGH';
      case 2:
        return 'MED';
      default:
        return 'LOW';
    }
  }

  Color _getHealthColor(double savingsPercent, bool isDark) {
    if (savingsPercent >= 30) {
      return _themedColor(NeoBrutalismTheme.accentGreen, isDark);
    }
    if (savingsPercent >= 15) {
      return _themedColor(NeoBrutalismTheme.accentSkyBlue, isDark);
    }
    if (savingsPercent >= 0) {
      return _themedColor(NeoBrutalismTheme.accentYellow, isDark);
    }
    return _themedColor(NeoBrutalismTheme.accentPink, isDark);
  }

  String _formatCurrency(double amount) {
    final abs = amount.abs();
    final prefix = amount < 0 ? '-' : '';
    if (abs >= 10000000) {
      return '$prefix₹${(abs / 10000000).toStringAsFixed(1)}Cr';
    } else if (abs >= 100000) {
      return '$prefix₹${(abs / 100000).toStringAsFixed(1)}L';
    } else if (abs >= 1000) {
      return '$prefix₹${(abs / 1000).toStringAsFixed(1)}K';
    }
    return '$prefix₹${abs.toStringAsFixed(0)}';
  }

  String _formatCurrencyFull(double amount) {
    final prefix = amount < 0 ? '-' : '';
    final abs = amount.abs();
    if (abs >= 10000000) {
      return '$prefix₹${(abs / 10000000).toStringAsFixed(2)} Cr';
    } else if (abs >= 100000) {
      return '$prefix₹${(abs / 100000).toStringAsFixed(2)} L';
    }
    return '$prefix₹${abs.toStringAsFixed(2)}';
  }
}