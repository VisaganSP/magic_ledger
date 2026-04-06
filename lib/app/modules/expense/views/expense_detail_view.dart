import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/expense_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../account/controllers/account_controller.dart';
import '../../category/controllers/category_controller.dart';
import '../controllers/expense_controller.dart';

class ExpenseDetailView extends StatelessWidget {
  final ExpenseModel expense = Get.arguments;
  final CategoryController categoryController = Get.find();
  final ExpenseController expenseController = Get.find();
  final AccountController accountController = Get.find();

  ExpenseDetailView({super.key});

  Color _t(Color c, bool d) => NeoBrutalismTheme.getThemedColor(c, d);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = _getCategory();
    final categoryIcon = category?.icon ?? '💰';
    final categoryName = category?.name ?? 'Unknown';
    final categoryColor = _t(category?.colorValue ?? Colors.grey, isDark);
    final account = accountController.getAccountForDisplay(expense.accountId);

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      body: CustomScrollView(
        slivers: [
          // ═══ CUSTOM APP BAR ═══
          SliverToBoxAdapter(child: _buildHeader(categoryColor, isDark)),

          // ═══ HERO CARD ═══
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildHeroCard(categoryColor, categoryIcon, categoryName, account, isDark)
                  .animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
            ),
          ),

          // ═══ QUICK STATS ═══
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildQuickStats(isDark)
                  .animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
            ),
          ),

          // ═══ DETAILS ═══
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildDetailsCard(categoryName, account, isDark)
                  .animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
            ),
          ),

          // ═══ TAGS ═══
          if (expense.tags != null && expense.tags!.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildTagsCard(isDark)
                    .animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
              ),
            ),

          // ═══ RECEIPT ═══
          if (expense.receiptPath != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildReceiptCard(isDark)
                    .animate().fadeIn(delay: 450.ms).slideY(begin: 0.1, end: 0),
              ),
            ),

          // ═══ ACTIONS ═══
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
              child: _buildActions(categoryColor, isDark)
                  .animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeader(Color accentColor, bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 12,
        left: 20, right: 20, bottom: 14,
      ),
      decoration: BoxDecoration(
        color: isDark ? NeoBrutalismTheme.darkSurface : accentColor,
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
                  offset: 3, borderColor: NeoBrutalismTheme.primaryBlack),
              child: Icon(Icons.arrow_back, size: 20,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text('EXPENSE DETAILS', style: TextStyle(fontSize: 20,
                fontWeight: FontWeight.w900, letterSpacing: -0.5,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          ),
          GestureDetector(
            onTap: _navigateToEdit,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: NeoBrutalismTheme.neoBox(
                  color: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
                  offset: 3, borderColor: NeoBrutalismTheme.primaryBlack),
              child: Icon(Icons.edit, size: 20,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _showDeleteDialog(isDark),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: NeoBrutalismTheme.neoBox(
                  color: Colors.red, offset: 3,
                  borderColor: NeoBrutalismTheme.primaryBlack),
              child: const Icon(Icons.delete, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  // ═══════════════════════════════════════════════════════════
  // HERO CARD — big amount + title
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeroCard(Color accentColor, String icon, String catName,
      dynamic account, bool isDark) {
    return NeoCard(
      color: accentColor,
      borderColor: NeoBrutalismTheme.primaryBlack,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Amount
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '-₹${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.primaryBlack, letterSpacing: -1),
            ),
          ).animate().scale(delay: 150.ms, duration: 400.ms,
              begin: const Offset(0.8, 0.8), end: const Offset(1, 1),
              curve: Curves.elasticOut),
          const SizedBox(height: 12),

          // Title
          Text(expense.title, style: const TextStyle(fontSize: 20,
              fontWeight: FontWeight.w800, color: NeoBrutalismTheme.primaryBlack),
              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),

          // Category + Account chips
          Wrap(
            spacing: 8, runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildChip('$icon $catName', isDark),
              if (expense.accountId != null)
                _buildChip('${account.icon} ${account.name}', isDark),
              _buildChip('📅 ${_fmtDate(expense.date)}', isDark),
              if (expense.isRecurring)
                _buildChip('🔄 ${expense.recurringType?.toUpperCase() ?? 'RECURRING'}', isDark,
                    color: _t(NeoBrutalismTheme.accentPurple, isDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text, bool isDark, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: color ?? (isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite),
          border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5),
          borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // QUICK STATS ROW
  // ═══════════════════════════════════════════════════════════

  Widget _buildQuickStats(bool isDark) {
    final dayOfWeek = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][expense.date.weekday - 1];
    final timeStr = '${expense.date.hour.toString().padLeft(2, '0')}:${expense.date.minute.toString().padLeft(2, '0')}';

    return Row(
      children: [
        Expanded(child: _buildStatCard('DAY', dayOfWeek.toUpperCase(), Icons.calendar_today, isDark)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard('TIME', timeStr, Icons.access_time, isDark)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard('TYPE', expense.isRecurring ? 'RECURRING' : 'ONE-TIME',
            expense.isRecurring ? Icons.autorenew : Icons.receipt, isDark)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, bool isDark) {
    return NeoCard(
      color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, size: 18, color: isDark ? Colors.grey[500] : Colors.grey[600]),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
              letterSpacing: 0.5, color: isDark ? Colors.grey[600] : Colors.grey[500])),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DETAILS CARD
  // ═══════════════════════════════════════════════════════════

  Widget _buildDetailsCard(String catName, dynamic account, bool isDark) {
    return NeoCard(
      color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DETAILS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 14),
          if (expense.description != null && expense.description!.isNotEmpty)
            _buildDetailRow('Description', expense.description!, isDark),
          _buildDetailRow('Category', catName, isDark),
          if (expense.accountId != null)
            _buildDetailRow('Account', '${account.icon} ${account.name}', isDark),
          _buildDetailRow('Amount', '₹${expense.amount.toStringAsFixed(2)}', isDark),
          _buildDetailRow('Date', _fmtDateFull(expense.date), isDark),
          if (expense.location != null && expense.location!.isNotEmpty)
            _buildDetailRow('Location', expense.location!, isDark),
          if (expense.isRecurring)
            _buildDetailRow('Frequency', _getFormattedFrequency(), isDark),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                color: isDark ? Colors.grey[500] : Colors.grey[500])),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TAGS CARD
  // ═══════════════════════════════════════════════════════════

  Widget _buildTagsCard(bool isDark) {
    return NeoCard(
      color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TAGS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: expense.tags!.asMap().entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: NeoBrutalismTheme.neoBox(
                    color: _t(NeoBrutalismTheme.accentYellow, isDark),
                    offset: 2, borderColor: NeoBrutalismTheme.primaryBlack),
                child: Text(entry.value.toUpperCase(), style: const TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
              ).animate().fadeIn(delay: (500 + entry.key * 80).ms)
                  .scale(begin: const Offset(0.8, 0.8));
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // RECEIPT CARD
  // ═══════════════════════════════════════════════════════════

  Widget _buildReceiptCard(bool isDark) {
    return NeoCard(
      color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RECEIPT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
              GestureDetector(
                onTap: _showFullScreenReceipt,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: NeoBrutalismTheme.neoBox(
                      color: _t(NeoBrutalismTheme.accentSkyBlue, isDark),
                      offset: 2, borderColor: NeoBrutalismTheme.primaryBlack),
                  child: const Icon(Icons.fullscreen, size: 18, color: NeoBrutalismTheme.primaryBlack),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showFullScreenReceipt,
            child: Container(
              height: 200, width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
                  borderRadius: BorderRadius.circular(4)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Image.file(File(expense.receiptPath!), fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.broken_image, size: 48,
                            color: isDark ? Colors.grey[600] : Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text('Image not found', style: TextStyle(
                            color: isDark ? Colors.grey[600] : Colors.grey[400])),
                      ]),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenReceipt() {
    Get.to(() => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(child: InteractiveViewer(
          child: Image.file(File(expense.receiptPath!),
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white, size: 64)))),
    ), transition: Transition.fadeIn);
  }

  // ═══════════════════════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════════════════════

  Widget _buildActions(Color accentColor, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton('DUPLICATE', Icons.copy,
                  _t(NeoBrutalismTheme.accentSkyBlue, isDark), _duplicateExpense, isDark),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton('SHARE', Icons.share,
                  _t(NeoBrutalismTheme.accentGreen, isDark), () => _shareExpense(), isDark),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _buildActionButton('EDIT EXPENSE', Icons.edit, accentColor, _navigateToEdit, isDark),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: NeoBrutalismTheme.neoBox(
            color: color, offset: 4, borderColor: NeoBrutalismTheme.primaryBlack),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: NeoBrutalismTheme.primaryBlack),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900,
                color: NeoBrutalismTheme.primaryBlack, letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // LOGIC
  // ═══════════════════════════════════════════════════════════

  dynamic _getCategory() {
    try {
      return categoryController.categories.firstWhere((c) => c.id == expense.categoryId);
    } catch (_) {
      return categoryController.categories.isNotEmpty ? categoryController.categories.first : null;
    }
  }

  void _navigateToEdit() {
    Get.toNamed('/add-expense', arguments: {'expense': expense, 'isEdit': true});
  }

  void _duplicateExpense() {
    final dup = ExpenseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${expense.title} (Copy)',
      amount: expense.amount,
      categoryId: expense.categoryId,
      date: DateTime.now(),
      description: expense.description,
      location: expense.location,
      tags: expense.tags,
      receiptPath: expense.receiptPath,
      isRecurring: expense.isRecurring,
      recurringType: expense.recurringType,
      accountId: expense.accountId,
    );
    expenseController.addExpense(dup);
    Get.snackbar('✅ Duplicated', '"${expense.title}" copied',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100], colorText: Colors.green[900],
        borderWidth: 2, borderColor: Colors.green[700]!,
        margin: const EdgeInsets.all(12));
  }

  void _shareExpense() {
    final cat = _getCategory();
    final text = [
      'Expense: ${expense.title}',
      'Amount: ₹${expense.amount.toStringAsFixed(2)}',
      'Category: ${cat?.name ?? 'Unknown'}',
      'Date: ${_fmtDateFull(expense.date)}',
      if (expense.description != null) 'Note: ${expense.description}',
      if (expense.location != null) 'Location: ${expense.location}',
      '', '— Magic Ledger',
    ].join('\n');
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar('📋 Copied', 'Expense details copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue[100], colorText: Colors.blue[900],
        margin: const EdgeInsets.all(12));
  }

  void _showDeleteDialog(bool isDark) {
    Get.dialog(Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: NeoBrutalismTheme.neoBoxRounded(
            color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56, height: 56,
            decoration: NeoBrutalismTheme.neoBox(
                color: Colors.red, offset: 3, borderColor: NeoBrutalismTheme.primaryBlack),
            child: const Icon(Icons.delete_forever, size: 28, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text('DELETE EXPENSE?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 8),
          Text('"${expense.title}" will be permanently removed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: NeoButton(text: 'CANCEL',
                onPressed: () => Navigator.of(Get.context!).pop(),
                color: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
                textColor: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
            const SizedBox(width: 12),
            Expanded(child: NeoButton(text: 'DELETE', onPressed: () {
              expenseController.deleteExpense(expense.id);
              Navigator.of(Get.context!).pop(); // dialog
              Navigator.of(Get.context!).pop(); // detail page
              Get.snackbar('🗑️ Deleted', '${expense.title} removed',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red[100], colorText: Colors.red[900],
                  margin: const EdgeInsets.all(12));
            }, color: Colors.red, textColor: Colors.white)),
          ]),
        ]),
      ),
    ));
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
  String _fmtDateFull(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day}/${d.month}/${d.year} at $h:$m';
  }

  String _getFormattedFrequency() {
    switch (expense.recurringType?.toLowerCase()) {
      case 'daily': return 'Every Day';
      case 'weekly': return 'Every Week';
      case 'monthly': return 'Every Month';
      case 'yearly': return 'Every Year';
      default: return expense.recurringType?.toUpperCase() ?? 'N/A';
    }
  }
}