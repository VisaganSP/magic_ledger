import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/category_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/income_model.dart';
import '../../../data/services/period_service.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../../widgets/neo_date_range_picker.dart';
import '../../account/controllers/account_controller.dart';
import '../../category/controllers/category_controller.dart';
import '../../income/controllers/income_controller.dart';
import '../controllers/expense_controller.dart';

class ExpenseView extends GetView<ExpenseController> {
  final CategoryController categoryController = Get.find();
  final IncomeController incomeController = Get.find();

  ExpenseView({super.key});

  final RxString selectedFilter = 'All'.obs;
  final RxString selectedType = 'Expenses'.obs;
  final Rx<DateTime?> customStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> customEndDate = Rx<DateTime?>(null);
  final RxString searchQuery = ''.obs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      floatingActionButton: Obx(
            () => Container(
          decoration: NeoBrutalismTheme.neoBox(
            color: selectedType.value == 'Expenses'
                ? _themed(NeoBrutalismTheme.accentOrange, isDark)
                : _themed(NeoBrutalismTheme.accentGreen, isDark),
            offset: 4,
            borderColor: NeoBrutalismTheme.primaryBlack,
          ),
          child: FloatingActionButton(
            heroTag: 'expense_fab_${selectedType.value}',
            onPressed: () => selectedType.value == 'Expenses'
                ? Get.toNamed('/add-expense')
                : Get.toNamed('/add-income'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Icon(
              selectedType.value == 'Expenses'
                  ? Icons.remove
                  : Icons.add,
              size: 28,
              color: NeoBrutalismTheme.primaryBlack,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Header
          _buildHeader(isDark),
          // Type toggle
          _buildTypeToggle(isDark),
          // Filter chips
          _buildFilterRow(isDark),
          // Custom date display
          _buildCustomDateBanner(isDark),
          // Account filter
          _buildAccountFilter(isDark),
          // Summary bar
          _buildSummaryBar(isDark),
          // List
          Expanded(
            child: Obx(() {
              if (selectedType.value == 'Expenses') {
                final items = _getFilteredExpenses();
                if (items.isEmpty) return _buildEmptyState(true, isDark);
                return _buildExpenseList(items, isDark);
              } else {
                final items = _getFilteredIncomes();
                if (items.isEmpty) return _buildEmptyState(false, isDark);
                return _buildIncomeList(items, isDark);
              }
            }),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 12,
      ),
      color: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedType.value.toUpperCase(),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  color: isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
                ),
              ),
              Obx(() {
                final periodService = Get.find<PeriodService>();
                return Text(
                  periodService.periodLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                );
              }),
            ],
          )),
          // Search button
          GestureDetector(
            onTap: () => _showSearchDialog(isDark),
            child: Container(
              width: 42,
              height: 42,
              decoration: NeoBrutalismTheme.neoBox(
                color: isDark
                    ? NeoBrutalismTheme.darkSurface
                    : NeoBrutalismTheme.primaryWhite,
                offset: 3,
                borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: const Icon(Icons.search,
                  size: 22, color: NeoBrutalismTheme.primaryBlack),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ═══════════════════════════════════════════════════════════
  // TYPE TOGGLE
  // ═══════════════════════════════════════════════════════════

  Widget _buildTypeToggle(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Expanded(child: _buildToggleTab('Expenses', Icons.arrow_upward_rounded, isDark)),
          const SizedBox(width: 10),
          Expanded(child: _buildToggleTab('Income', Icons.arrow_downward_rounded, isDark)),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildToggleTab(String type, IconData icon, bool isDark) {
    return Obx(() {
      final isSelected = selectedType.value == type;
      final color = type == 'Expenses'
          ? NeoBrutalismTheme.accentOrange
          : NeoBrutalismTheme.accentGreen;

      return GestureDetector(
        onTap: () => selectedType.value = type,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: NeoBrutalismTheme.neoBox(
            color: isSelected
                ? _themed(color, isDark)
                : (isDark
                ? NeoBrutalismTheme.darkSurface
                : NeoBrutalismTheme.primaryWhite),
            offset: isSelected ? 2 : 4,
            borderColor: NeoBrutalismTheme.primaryBlack,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? NeoBrutalismTheme.primaryBlack
                    : (isDark ? Colors.grey[500] : Colors.grey[600]),
              ),
              const SizedBox(width: 6),
              Text(
                type.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isSelected
                      ? NeoBrutalismTheme.primaryBlack
                      : (isDark ? Colors.grey[500] : Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════
  // FILTER CHIPS — horizontal scroll, compact
  // ═══════════════════════════════════════════════════════════

  Widget _buildFilterRow(bool isDark) {
    final filters = [
      {'label': 'All', 'icon': Icons.all_inclusive},
      {'label': 'Today', 'icon': Icons.today},
      {'label': 'This Week', 'icon': Icons.view_week},
      {'label': 'This Month', 'icon': Icons.calendar_month},
      {'label': 'Custom', 'icon': Icons.date_range},
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          return Obx(() {
            final isSelected = selectedFilter.value == filter['label'];
            return GestureDetector(
              onTap: () {
                if (filter['label'] == 'Custom') {
                  showDialog(
                    context: context,
                    builder: (ctx) => NeoDateRangePicker(
                      initialStartDate: customStartDate.value,
                      initialEndDate: customEndDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      onDateRangeSelected: (start, end) {
                        if (start != null && end != null) {
                          customStartDate.value = start;
                          customEndDate.value = end;
                          selectedFilter.value = 'Custom';
                        }
                      },
                    ),
                  );
                } else {
                  selectedFilter.value = filter['label'] as String;
                  customStartDate.value = null;
                  customEndDate.value = null;
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: isSelected
                    ? NeoBrutalismTheme.neoBox(
                  color: _themed(NeoBrutalismTheme.accentPurple, isDark),
                  offset: 2,
                  borderColor: NeoBrutalismTheme.primaryBlack,
                )
                    : BoxDecoration(
                  color: isDark
                      ? NeoBrutalismTheme.darkSurface
                      : NeoBrutalismTheme.primaryWhite,
                  border: Border.all(
                    color: NeoBrutalismTheme.primaryBlack,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      size: 14,
                      color: isSelected
                          ? NeoBrutalismTheme.primaryBlack
                          : (isDark ? Colors.grey[500] : Colors.grey[600]),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      (filter['label'] as String).toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isSelected
                            ? NeoBrutalismTheme.primaryBlack
                            : (isDark ? Colors.grey[500] : Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  // ═══════════════════════════════════════════════════════════
  // CUSTOM DATE BANNER
  // ═══════════════════════════════════════════════════════════

  Widget _buildCustomDateBanner(bool isDark) {
    return Obx(() {
      if (selectedFilter.value != 'Custom' ||
          customStartDate.value == null ||
          customEndDate.value == null) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: NeoBrutalismTheme.neoBox(
            color: _themed(NeoBrutalismTheme.accentSkyBlue, isDark),
            offset: 2,
            borderColor: NeoBrutalismTheme.primaryBlack,
          ),
          child: Row(
            children: [
              const Icon(Icons.date_range,
                  size: 18, color: NeoBrutalismTheme.primaryBlack),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_fmtDate(customStartDate.value!)} — ${_fmtDate(customEndDate.value!)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: NeoBrutalismTheme.primaryBlack,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  customStartDate.value = null;
                  customEndDate.value = null;
                  selectedFilter.value = 'All';
                },
                child: const Icon(Icons.close,
                    size: 18, color: NeoBrutalismTheme.primaryBlack),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: -0.3, end: 0),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════
  // ACCOUNT FILTER — horizontal strip
  // ═══════════════════════════════════════════════════════════

  Widget _buildAccountFilter(bool isDark) {
    final accountController = Get.find<AccountController>();

    return Obx(() {
      final accounts = accountController.accounts;
      if (accounts.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: accounts.length + 1,
          itemBuilder: (ctx, index) {
            if (index == 0) {
              final isSelected = accountController.selectedAccountId.value == null;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
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

            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _buildAccountChip(
                label: account.name,
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
    }).animate().fadeIn(delay: 200.ms);
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: isSelected
            ? NeoBrutalismTheme.neoBox(
          color: _themed(color, isDark),
          offset: 2,
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
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected
                    ? NeoBrutalismTheme.primaryBlack
                    : (isDark ? Colors.grey[500] : Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SUMMARY BAR
  // ═══════════════════════════════════════════════════════════

  Widget _buildSummaryBar(bool isDark) {
    return Obx(() {
      final isExpenses = selectedType.value == 'Expenses';
      final items = isExpenses ? _getFilteredExpenses() : _getFilteredIncomes();
      final total = isExpenses
          ? (items as List<ExpenseModel>).fold(0.0, (sum, e) => sum + e.amount)
          : (items as List<IncomeModel>).fold(0.0, (sum, e) => sum + e.amount);
      final count = items.length;

      return Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: NeoBrutalismTheme.neoBox(
          color: isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
          offset: 3,
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isExpenses
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 18,
                  color: isExpenses
                      ? (isDark ? Colors.red[400] : Colors.red[700])
                      : (isDark ? Colors.green[400] : Colors.green[700]),
                ),
                const SizedBox(width: 6),
                Text(
                  '$count ${isExpenses ? 'expense' : 'income'}${count == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            Text(
              '${isExpenses ? '-' : '+'}₹${_formatAmount(total)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isExpenses
                    ? (isDark ? Colors.red[400] : Colors.red[700])
                    : (isDark ? Colors.green[400] : Colors.green[700]),
              ),
            ),
          ],
        ),
      );
    }).animate().fadeIn(delay: 250.ms);
  }

  // ═══════════════════════════════════════════════════════════
  // EXPENSE LIST
  // ═══════════════════════════════════════════════════════════

  Widget _buildExpenseList(List<ExpenseModel> expenses, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: expenses.length,
      itemBuilder: (ctx, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildExpenseCard(expenses[index], index, isDark),
        );
      },
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense, int index, bool isDark) {
    final category = categoryController.getCategoryForExpense(expense.categoryId);
    final accountController = Get.find<AccountController>();
    final account = accountController.getAccountForDisplay(expense.accountId);

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: NeoBrutalismTheme.neoBox(
          color: Colors.red,
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: const Icon(Icons.delete,
            color: NeoBrutalismTheme.primaryWhite, size: 28),
      ),
      confirmDismiss: (_) => _confirmDelete(expense.title, isDark),
      onDismissed: (_) {
        controller.deleteExpense(expense.id);
        Get.snackbar('Deleted', '${expense.title} removed',
            backgroundColor: _themed(NeoBrutalismTheme.accentPink, isDark),
            colorText: NeoBrutalismTheme.primaryBlack,
            borderWidth: 3,
            borderColor: NeoBrutalismTheme.primaryBlack,
            duration: const Duration(seconds: 2));
      },
      child: NeoCard(
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
              width: 44,
              height: 44,
              decoration: NeoBrutalismTheme.neoBox(
                color: _themed(category.colorValue, isDark),
                offset: 3,
                borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: Center(
                child: Text(category.icon,
                    style: const TextStyle(fontSize: 22)),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
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
                  // Tags
                  if (expense.tags != null && expense.tags!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: expense.tags!.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: _themed(
                                NeoBrutalismTheme.accentPurple, isDark),
                            border: Border.all(
                              color: NeoBrutalismTheme.primaryBlack,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: NeoBrutalismTheme.primaryBlack,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Amount + recurring badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-₹${expense.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.red[400] : Colors.red[700],
                  ),
                ),
                if (expense.isRecurring) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _themed(
                          NeoBrutalismTheme.accentLilac, isDark),
                      border: Border.all(
                        color: NeoBrutalismTheme.primaryBlack,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      expense.recurringType?.toUpperCase() ?? 'RECURRING',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: NeoBrutalismTheme.primaryBlack,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (80 * index).ms).slideX(begin: 0.05, end: 0);
  }

  // ═══════════════════════════════════════════════════════════
  // INCOME LIST
  // ═══════════════════════════════════════════════════════════

  Widget _buildIncomeList(List<IncomeModel> incomes, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: incomes.length,
      itemBuilder: (ctx, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildIncomeCard(incomes[index], index, isDark),
        );
      },
    );
  }

  Widget _buildIncomeCard(IncomeModel income, int index, bool isDark) {
    final accountController = Get.find<AccountController>();
    final account = accountController.getAccountForDisplay(income.accountId);

    return Dismissible(
      key: Key(income.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: NeoBrutalismTheme.neoBox(
          color: Colors.red,
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: const Icon(Icons.delete,
            color: NeoBrutalismTheme.primaryWhite, size: 28),
      ),
      confirmDismiss: (_) => _confirmDelete(income.title, isDark),
      onDismissed: (_) {
        incomeController.deleteIncome(income.id);
        Get.snackbar('Deleted', '${income.title} removed',
            backgroundColor: _themed(NeoBrutalismTheme.accentGreen, isDark),
            colorText: NeoBrutalismTheme.primaryBlack,
            borderWidth: 3,
            borderColor: NeoBrutalismTheme.primaryBlack,
            duration: const Duration(seconds: 2));
      },
      child: NeoCard(
        onTap: () => Get.toNamed('/income-detail', arguments: income),
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : NeoBrutalismTheme.primaryWhite,
        borderColor: NeoBrutalismTheme.primaryBlack,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: NeoBrutalismTheme.neoBox(
                color: _themed(NeoBrutalismTheme.accentGreen, isDark),
                offset: 3,
                borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: const Center(
                child: Icon(Icons.arrow_downward_rounded,
                    size: 22, color: NeoBrutalismTheme.primaryBlack),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+₹${income.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.green[400] : Colors.green[700],
                  ),
                ),
                if (income.isRecurring) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _themed(
                          NeoBrutalismTheme.accentLilac, isDark),
                      border: Border.all(
                        color: NeoBrutalismTheme.primaryBlack,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      income.recurringType?.toUpperCase() ?? 'RECURRING',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: NeoBrutalismTheme.primaryBlack,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (80 * index).ms).slideX(begin: 0.05, end: 0);
  }

  // ═══════════════════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════════════════

  Widget _buildEmptyState(bool isExpense, bool isDark) {
    final isFiltered = selectedFilter.value != 'All';
    final color = isExpense
        ? NeoBrutalismTheme.accentOrange
        : NeoBrutalismTheme.accentGreen;
    final icon = isExpense ? Icons.receipt_long : Icons.account_balance_wallet;
    final typeLabel = isExpense ? 'expenses' : 'income';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: NeoBrutalismTheme.neoBox(
                color: _themed(color, isDark),
                offset: 4,
                borderColor: NeoBrutalismTheme.primaryBlack,
              ),
              child: Icon(icon, size: 40, color: NeoBrutalismTheme.primaryBlack),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered
                  ? 'NO ${typeLabel.toUpperCase()} FOUND'
                  : 'NO ${typeLabel.toUpperCase()} YET',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark
                    ? NeoBrutalismTheme.darkText
                    : NeoBrutalismTheme.primaryBlack,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isFiltered
                  ? 'Try changing the filter'
                  : 'Start tracking your $typeLabel',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            NeoButton(
              text: 'ADD ${isExpense ? 'EXPENSE' : 'INCOME'}',
              onPressed: () => Get.toNamed(
                  isExpense ? '/add-expense' : '/add-income'),
              color: _themed(color, isDark),
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SEARCH DIALOG
  // ═══════════════════════════════════════════════════════════

  void _showSearchDialog(bool isDark) {
    final searchCtrl = TextEditingController();

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: NeoBrutalismTheme.neoBox(
                  color: isDark
                      ? NeoBrutalismTheme.darkBackground
                      : NeoBrutalismTheme.primaryWhite,
                  offset: 3,
                  borderColor: NeoBrutalismTheme.primaryBlack,
                ),
                child: TextField(
                  controller: searchCtrl,
                  autofocus: true,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                  onChanged: (v) => searchQuery.value = v,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: Obx(() {
                  final query = searchQuery.value;
                  if (query.isEmpty) {
                    return Center(
                      child: Text(
                        'Type to search',
                        style: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                        ),
                      ),
                    );
                  }

                  final expenses = controller.searchExpenses(query);
                  final incomes = incomeController.searchIncomes(query);

                  if (expenses.isEmpty && incomes.isEmpty) {
                    return Center(
                      child: Text(
                        'No results for "$query"',
                        style: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                        ),
                      ),
                    );
                  }

                  return ListView(
                    children: [
                      ...expenses.take(10).map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: GestureDetector(
                          onTap: () {
                            Get.back();
                            Get.toNamed('/expense-detail', arguments: e);
                          },
                          child: _buildSearchResult(
                            title: e.title,
                            subtitle:
                            '-₹${e.amount.toStringAsFixed(0)} • ${e.date.day}/${e.date.month}',
                            isExpense: true,
                            isDark: isDark,
                          ),
                        ),
                      )),
                      ...incomes.take(10).map((i) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: GestureDetector(
                          onTap: () {
                            Get.back();
                            Get.toNamed('/income-detail', arguments: i);
                          },
                          child: _buildSearchResult(
                            title: i.title,
                            subtitle:
                            '+₹${i.amount.toStringAsFixed(0)} • ${i.date.day}/${i.date.month}',
                            isExpense: false,
                            isDark: isDark,
                          ),
                        ),
                      )),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResult({
    required String title,
    required String subtitle,
    required bool isExpense,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? NeoBrutalismTheme.darkBackground
            : NeoBrutalismTheme.lightSecondaryBg,
        border: Border.all(
          color: NeoBrutalismTheme.primaryBlack,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isExpense
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: 16,
            color: isExpense ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FILTERS
  // ═══════════════════════════════════════════════════════════

  List<ExpenseModel> _getFilteredExpenses() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final accountId = Get.find<AccountController>().selectedAccountId.value;

    List<ExpenseModel> filtered;

    switch (selectedFilter.value) {
      case 'Today':
        filtered = controller.expenses.where((e) {
          final d = DateTime(e.date.year, e.date.month, e.date.day);
          return d.isAtSameMomentAs(today);
        }).toList();
        break;
      case 'This Week':
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        filtered = controller.expenses.where((e) {
          final d = DateTime(e.date.year, e.date.month, e.date.day);
          return d.isAfter(weekStart.subtract(const Duration(days: 1))) &&
              d.isBefore(weekEnd.add(const Duration(days: 1)));
        }).toList();
        break;
      case 'This Month':
        filtered = controller.expenses.where((e) {
          return e.date.year == now.year && e.date.month == now.month;
        }).toList();
        break;
      case 'Custom':
        if (customStartDate.value != null && customEndDate.value != null) {
          filtered = controller.getExpensesByDateRange(
            customStartDate.value!,
            customEndDate.value!,
          );
        } else {
          filtered = controller.expenses.toList();
        }
        break;
      default:
        filtered = controller.expenses.toList();
    }

    // Account filter
    if (accountId != null) {
      filtered = filtered.where((e) => e.accountId == accountId).toList();
    }

    return filtered;
  }

  List<IncomeModel> _getFilteredIncomes() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final accountId = Get.find<AccountController>().selectedAccountId.value;

    List<IncomeModel> filtered;

    switch (selectedFilter.value) {
      case 'Today':
        filtered = incomeController.incomes.where((i) {
          final d = DateTime(i.date.year, i.date.month, i.date.day);
          return d.isAtSameMomentAs(today);
        }).toList();
        break;
      case 'This Week':
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        filtered = incomeController.incomes.where((i) {
          final d = DateTime(i.date.year, i.date.month, i.date.day);
          return d.isAfter(weekStart.subtract(const Duration(days: 1))) &&
              d.isBefore(weekEnd.add(const Duration(days: 1)));
        }).toList();
        break;
      case 'This Month':
        filtered = incomeController.incomes.where((i) {
          return i.date.year == now.year && i.date.month == now.month;
        }).toList();
        break;
      case 'Custom':
        if (customStartDate.value != null && customEndDate.value != null) {
          filtered = incomeController.incomes.where((i) {
            return i.date.isAfter(
                customStartDate.value!.subtract(const Duration(days: 1))) &&
                i.date.isBefore(
                    customEndDate.value!.add(const Duration(days: 1)));
          }).toList();
        } else {
          filtered = incomeController.incomes.toList();
        }
        break;
      default:
        filtered = incomeController.incomes.toList();
    }

    if (accountId != null) {
      filtered = filtered.where((i) => i.accountId == accountId).toList();
    }

    return filtered;
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════

  Future<bool?> _confirmDelete(String title, bool isDark) {
    return Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
              color: NeoBrutalismTheme.primaryBlack, width: 3),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? NeoBrutalismTheme.darkSurface
                : NeoBrutalismTheme.primaryWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 40, color: Colors.orange),
              const SizedBox(height: 12),
              Text(
                'Delete "$title"?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      text: 'CANCEL',
                      onPressed: () => Get.back(result: false),
                      color: isDark
                          ? NeoBrutalismTheme.darkBackground
                          : NeoBrutalismTheme.primaryWhite,
                      textColor: isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      text: 'DELETE',
                      onPressed: () => Get.back(result: true),
                      color: Colors.red,
                      textColor: NeoBrutalismTheme.primaryWhite,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _themed(Color color, bool isDark) {
    return NeoBrutalismTheme.getThemedColor(color, isDark);
  }

  String _formatAmount(double amount) {
    final abs = amount.abs();
    if (abs >= 10000000) return '${(abs / 10000000).toStringAsFixed(1)}Cr';
    if (abs >= 100000) return '${(abs / 100000).toStringAsFixed(1)}L';
    if (abs >= 1000) return '${(abs / 1000).toStringAsFixed(1)}K';
    return abs.toStringAsFixed(2);
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}