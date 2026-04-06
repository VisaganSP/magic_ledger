import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/income_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../account/controllers/account_controller.dart';
import '../controllers/income_controller.dart';

class IncomeDetailView extends StatelessWidget {
  final IncomeModel income = Get.arguments;
  final IncomeController incomeController = Get.find();
  final AccountController accountController = Get.find();

  IncomeDetailView({super.key});

  Color _t(Color c, bool d) => NeoBrutalismTheme.getThemedColor(c, d);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final account = accountController.getAccountForDisplay(income.accountId);

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      body: CustomScrollView(
        slivers: [
          // ═══ HEADER ═══
          SliverToBoxAdapter(child: _buildHeader(isDark)),

          // ═══ HERO CARD ═══
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildHeroCard(account, isDark)
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
              child: _buildDetailsCard(account, isDark)
                  .animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
            ),
          ),

          // ═══ ACTIONS ═══
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
              child: _buildActions(isDark)
                  .animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
            ),
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
        top: MediaQuery.of(Get.context!).padding.top + 12,
        left: 20, right: 20, bottom: 14,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : _t(NeoBrutalismTheme.accentGreen, isDark),
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
            child: Text('INCOME DETAILS', style: TextStyle(fontSize: 20,
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
  // HERO CARD
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeroCard(dynamic account, bool isDark) {
    return NeoCard(
      color: _t(NeoBrutalismTheme.accentGreen, isDark),
      borderColor: NeoBrutalismTheme.primaryBlack,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Amount
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '+₹${income.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.primaryBlack, letterSpacing: -1),
            ),
          ).animate().scale(delay: 150.ms, duration: 400.ms,
              begin: const Offset(0.8, 0.8), end: const Offset(1, 1),
              curve: Curves.elasticOut),
          const SizedBox(height: 12),

          // Title
          Text(income.title, style: const TextStyle(fontSize: 20,
              fontWeight: FontWeight.w800, color: NeoBrutalismTheme.primaryBlack),
              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),

          // Info chips
          Wrap(
            spacing: 8, runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildChip('💼 ${income.source}', isDark),
              if (income.accountId != null)
                _buildChip('${account.icon} ${account.name}', isDark),
              _buildChip('📅 ${_fmtDate(income.date)}', isDark),
              if (income.isRecurring)
                _buildChip('🔄 ${income.recurringType?.toUpperCase() ?? 'RECURRING'}', isDark,
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
  // QUICK STATS
  // ═══════════════════════════════════════════════════════════

  Widget _buildQuickStats(bool isDark) {
    final dayOfWeek = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][income.date.weekday - 1];
    final timeStr = '${income.date.hour.toString().padLeft(2, '0')}:${income.date.minute.toString().padLeft(2, '0')}';

    return Row(
      children: [
        Expanded(child: _buildStatCard('DAY', dayOfWeek.toUpperCase(), Icons.calendar_today, isDark)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard('TIME', timeStr, Icons.access_time, isDark)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard('SOURCE', income.source.length > 8
            ? '${income.source.substring(0, 8)}...' : income.source.toUpperCase(),
            Icons.account_balance_wallet, isDark)),
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
              textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
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

  Widget _buildDetailsCard(dynamic account, bool isDark) {
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
          if (income.description != null && income.description!.isNotEmpty)
            _buildDetailRow('Description', income.description!, isDark),
          _buildDetailRow('Source', income.source, isDark),
          if (income.accountId != null)
            _buildDetailRow('Account', '${account.icon} ${account.name}', isDark),
          _buildDetailRow('Amount', '₹${income.amount.toStringAsFixed(2)}', isDark),
          _buildDetailRow('Date', _fmtDateFull(income.date), isDark),
          _buildDetailRow('Type', income.isRecurring ? 'Recurring' : 'One-time', isDark),
          if (income.isRecurring)
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
  // ACTIONS
  // ═══════════════════════════════════════════════════════════

  Widget _buildActions(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton('DUPLICATE', Icons.copy,
                  _t(NeoBrutalismTheme.accentSkyBlue, isDark), _duplicateIncome, isDark),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton('SHARE', Icons.share,
                  _t(NeoBrutalismTheme.accentPurple, isDark), _shareIncome, isDark),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _buildActionButton('EDIT INCOME', Icons.edit,
              _t(NeoBrutalismTheme.accentGreen, isDark), _navigateToEdit, isDark),
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

  void _navigateToEdit() {
    Get.toNamed('/add-income', arguments: {'income': income, 'isEdit': true});
  }

  void _duplicateIncome() {
    final dup = IncomeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${income.title} (Copy)',
      amount: income.amount,
      source: income.source,
      date: DateTime.now(),
      description: income.description,
      isRecurring: income.isRecurring,
      recurringType: income.recurringType,
      accountId: income.accountId,
    );
    incomeController.addIncome(dup);
    Get.snackbar('✅ Duplicated', '"${income.title}" copied',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100], colorText: Colors.green[900],
        borderWidth: 2, borderColor: Colors.green[700]!,
        margin: const EdgeInsets.all(12));
  }

  void _shareIncome() {
    final text = [
      'Income: ${income.title}',
      'Amount: ₹${income.amount.toStringAsFixed(2)}',
      'Source: ${income.source}',
      'Date: ${_fmtDateFull(income.date)}',
      if (income.description != null) 'Note: ${income.description}',
      '', '— Magic Ledger',
    ].join('\n');
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar('📋 Copied', 'Income details copied to clipboard',
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
          Text('DELETE INCOME?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 8),
          Text('"${income.title}" will be permanently removed.',
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
              incomeController.deleteIncome(income.id);
              Navigator.of(Get.context!).pop();
              Navigator.of(Get.context!).pop();
              Get.snackbar('🗑️ Deleted', '${income.title} removed',
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
    switch (income.recurringType?.toLowerCase()) {
      case 'daily': return 'Every Day';
      case 'weekly': return 'Every Week';
      case 'monthly': return 'Every Month';
      case 'yearly': return 'Every Year';
      default: return income.recurringType?.toUpperCase() ?? 'N/A';
    }
  }
}