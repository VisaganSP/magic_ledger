import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../data/models/expense_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../account/controllers/account_controller.dart';
import '../../category/controllers/category_controller.dart';
import '../../expense/controllers/expense_controller.dart';

/// Template model stored as a Map in Hive (no adapter needed)
/// Fields: id, title, amount, categoryId, accountId, icon
class ExpenseTemplateController extends GetxController {
  late Box _templateBox;
  final RxList<Map<String, dynamic>> templates = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initBox();
  }

  Future<void> _initBox() async {
    _templateBox = Hive.isBoxOpen('expense_templates')
        ? Hive.box('expense_templates')
        : await Hive.openBox('expense_templates');
    _loadTemplates();
  }

  void _loadTemplates() {
    templates.value = _templateBox.keys.map((key) {
      final raw = _templateBox.get(key);
      if (raw is Map) return Map<String, dynamic>.from(raw);
      return <String, dynamic>{};
    }).where((m) => m.isNotEmpty).toList();
  }

  Future<void> addTemplate({
    required String title,
    required double amount,
    String? categoryId,
    String? accountId,
    String icon = '⚡',
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final template = {
      'id': id,
      'title': title,
      'amount': amount,
      'categoryId': categoryId,
      'accountId': accountId,
      'icon': icon,
      'usageCount': 0,
    };
    await _templateBox.put(id, template);
    _loadTemplates();
  }

  Future<void> deleteTemplate(String id) async {
    await _templateBox.delete(id);
    _loadTemplates();
  }

  /// Use a template — creates an expense instantly
  void useTemplate(Map<String, dynamic> template) {
    final expCtrl = Get.find<ExpenseController>();
    final accCtrl = Get.find<AccountController>();

    final expense = ExpenseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: template['title'] ?? 'Expense',
      amount: (template['amount'] as num?)?.toDouble() ?? 0,
      date: DateTime.now(),
      categoryId: template['categoryId'] ?? 'uncategorized',
      accountId: template['accountId'],
    );
    expCtrl.addExpense(expense);

    // Adjust account balance
    if (template['accountId'] != null) {
      accCtrl.adjustBalance(template['accountId'], -(template['amount'] as num).toDouble());
    }

    // Increment usage count
    final updated = Map<String, dynamic>.from(template);
    updated['usageCount'] = (updated['usageCount'] ?? 0) + 1;
    _templateBox.put(template['id'], updated);
    _loadTemplates();

    Get.snackbar(
      '✅ Added',
      '-₹${(template['amount'] as num).toStringAsFixed(0)} • ${template['title']}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.orange[100],
      colorText: Colors.orange[900],
      borderWidth: 2,
      borderColor: Colors.orange[700]!,
      margin: const EdgeInsets.all(12),
    );
  }
}

/// Expense Templates View
class ExpenseTemplatesView extends StatelessWidget {
  const ExpenseTemplatesView({super.key});

  Color _t(Color c, bool d) => NeoBrutalismTheme.getThemedColor(c, d);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = Get.find<ExpenseTemplateController>();

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.lightBackground,
      body: Column(
        children: [
          _buildHeader(isDark),
          Expanded(
            child: Obx(() {
              if (ctrl.templates.isEmpty) {
                return _buildEmptyState(isDark);
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                children: [
                  // Quick-use section
                  Text('TAP TO ADD INSTANTLY', style: TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w900, letterSpacing: 0.5,
                      color: isDark ? Colors.grey[500] : Colors.grey[600])),
                  const SizedBox(height: 10),

                  // Template grid
                  Wrap(
                    spacing: 10, runSpacing: 10,
                    children: ctrl.templates.asMap().entries.map((entry) {
                      return _buildTemplateChip(entry.value, isDark, ctrl)
                          .animate().fadeIn(delay: (80 + entry.key * 50).ms)
                          .scale(begin: const Offset(0.9, 0.9));
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // All templates list (with delete)
                  Text('MANAGE TEMPLATES', style: TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w900, letterSpacing: 0.5,
                      color: isDark ? Colors.grey[500] : Colors.grey[600])),
                  const SizedBox(height: 10),
                  ...ctrl.templates.map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildTemplateRow(t, isDark, ctrl),
                  )),
                ],
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: NeoBrutalismTheme.neoBox(
          color: _t(NeoBrutalismTheme.accentGreen, isDark),
          offset: 4, borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddTemplateSheet(isDark, ctrl),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: NeoBrutalismTheme.primaryBlack, size: 28),
        ),
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
            : _t(NeoBrutalismTheme.accentBeige, isDark),
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
              Text('QUICK TEMPLATES', style: TextStyle(fontSize: 22,
                  fontWeight: FontWeight.w900, letterSpacing: -0.5,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
              Text('One-tap expense shortcuts', style: TextStyle(fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[700])),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  /// Tappable quick-add chip
  Widget _buildTemplateChip(Map<String, dynamic> t, bool isDark,
      ExpenseTemplateController ctrl) {
    final icon = t['icon'] ?? '⚡';
    final title = t['title'] ?? 'Expense';
    final amount = (t['amount'] as num?)?.toDouble() ?? 0;

    return GestureDetector(
      onTap: () => ctrl.useTemplate(t),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: NeoBrutalismTheme.neoBox(
          color: _t(NeoBrutalismTheme.accentYellow, isDark),
          offset: 3, borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
                Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w700, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// List row with delete
  Widget _buildTemplateRow(Map<String, dynamic> t, bool isDark,
      ExpenseTemplateController ctrl) {
    final catCtrl = Get.find<CategoryController>();
    final icon = t['icon'] ?? '⚡';
    final usage = t['usageCount'] ?? 0;
    String? catName;
    try {
      if (t['categoryId'] != null) {
        catName = catCtrl.getCategoryForExpense(t['categoryId']).name;
      }
    } catch (_) {}

    return Dismissible(
      key: Key(t['id'] ?? ''),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => ctrl.deleteTemplate(t['id']),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: NeoCard(
        color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
        borderColor: NeoBrutalismTheme.primaryBlack,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t['title'] ?? '', style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                  Text([
                    if (catName != null) catName,
                    'Used $usage times',
                  ].join(' • '),
                      style: TextStyle(fontSize: 11,
                          color: isDark ? Colors.grey[500] : Colors.grey[600])),
                ],
              ),
            ),
            Text('-₹${((t['amount'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                    color: isDark ? Colors.red[400] : Colors.red[700])),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => ctrl.useTemplate(t),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: NeoBrutalismTheme.neoBox(
                  color: _t(NeoBrutalismTheme.accentGreen, isDark),
                  offset: 2, borderColor: NeoBrutalismTheme.primaryBlack,
                ),
                child: const Icon(Icons.add, size: 18, color: NeoBrutalismTheme.primaryBlack),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: NeoBrutalismTheme.neoBox(
              color: _t(NeoBrutalismTheme.accentYellow, isDark),
              offset: 4, borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: const Center(child: Text('⚡', style: TextStyle(fontSize: 40))),
          ),
          const SizedBox(height: 20),
          Text('NO TEMPLATES YET', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 8),
          Text('Save frequent expenses as templates\nfor one-tap adding',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.4,
                  color: isDark ? Colors.grey[500] : Colors.grey[600])),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: NeoButton(
              text: 'CREATE TEMPLATE',
              onPressed: () => _showAddTemplateSheet(isDark, Get.find<ExpenseTemplateController>()),
              color: _t(NeoBrutalismTheme.accentGreen, isDark),
              icon: Icons.add,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  void _showAddTemplateSheet(bool isDark, ExpenseTemplateController ctrl) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final selectedIcon = '⚡'.obs;
    final selectedCategoryId = Rxn<String>();
    final selectedAccountId = Rxn<String>();

    final catCtrl = Get.find<CategoryController>();
    final accCtrl = Get.find<AccountController>();

    final icons = ['⚡', '☕', '🚌', '🍕', '🛒', '⛽', '💊', '🎬', '🍔', '🧾', '📱', '🏋️', '🎵', '🚕', '✂️', '🧹'];

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('NEW TEMPLATE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
              const SizedBox(height: 16),

              // Icon picker
              Text('ICON', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
                  letterSpacing: 0.5, color: isDark ? Colors.grey[500] : Colors.grey[600])),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8, runSpacing: 8,
                children: icons.map((ic) {
                  final isSelected = selectedIcon.value == ic;
                  return GestureDetector(
                    onTap: () => selectedIcon.value = ic,
                    child: Container(
                      width: 40, height: 40,
                      decoration: isSelected
                          ? NeoBrutalismTheme.neoBox(
                          color: NeoBrutalismTheme.accentYellow,
                          offset: 2, borderColor: NeoBrutalismTheme.primaryBlack)
                          : BoxDecoration(
                          color: isDark ? NeoBrutalismTheme.darkBackground : Colors.grey[100],
                          border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5)),
                      child: Center(child: Text(ic, style: const TextStyle(fontSize: 20))),
                    ),
                  );
                }).toList(),
              )),
              const SizedBox(height: 16),

              // Title
              _buildInputField(titleCtrl, 'Title (e.g. "Morning Coffee")', isDark),
              const SizedBox(height: 12),

              // Amount
              _buildInputField(amountCtrl, 'Amount (e.g. 30)', isDark,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),

              // Category dropdown
              Text('CATEGORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
                  letterSpacing: 0.5, color: isDark ? Colors.grey[500] : Colors.grey[600])),
              const SizedBox(height: 6),
              Obx(() => Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: NeoBrutalismTheme.neoBox(
                  color: isDark ? NeoBrutalismTheme.darkBackground : Colors.grey[50]!,
                  offset: 2, borderColor: NeoBrutalismTheme.primaryBlack,
                ),
                child: DropdownButton<String>(
                  value: selectedCategoryId.value,
                  hint: Text('Select category',
                      style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400])),
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
                  items: catCtrl.categories.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text('${c.icon} ${c.name}', style: TextStyle(
                        color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                  )).toList(),
                  onChanged: (v) => selectedCategoryId.value = v,
                ),
              )),
              const SizedBox(height: 12),

              // Account dropdown
              Text('ACCOUNT (optional)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
                  letterSpacing: 0.5, color: isDark ? Colors.grey[500] : Colors.grey[600])),
              const SizedBox(height: 6),
              Obx(() => Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: NeoBrutalismTheme.neoBox(
                  color: isDark ? NeoBrutalismTheme.darkBackground : Colors.grey[50]!,
                  offset: 2, borderColor: NeoBrutalismTheme.primaryBlack,
                ),
                child: DropdownButton<String>(
                  value: selectedAccountId.value,
                  hint: Text('Select account',
                      style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400])),
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
                  items: [
                    DropdownMenuItem<String>(value: null,
                        child: Text('None', style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[600]))),
                    ...accCtrl.accounts.map((a) => DropdownMenuItem(
                      value: a.id,
                      child: Text('${a.icon} ${a.name}', style: TextStyle(
                          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
                    )),
                  ],
                  onChanged: (v) => selectedAccountId.value = v,
                ),
              )),
              const SizedBox(height: 20),

              // Save button
              NeoButton(
                text: 'SAVE TEMPLATE',
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                  if (title.isEmpty || amount <= 0) {
                    Get.snackbar('Missing Info', 'Enter title and amount',
                        snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  ctrl.addTemplate(
                    title: title,
                    amount: amount,
                    categoryId: selectedCategoryId.value,
                    accountId: selectedAccountId.value,
                    icon: selectedIcon.value,
                  );
                  Navigator.of(Get.context!).pop();
                  Get.snackbar('✅ Template Saved', '$title — ₹${amount.toStringAsFixed(0)}',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green[100], colorText: Colors.green[900]);
                },
                color: _t(NeoBrutalismTheme.accentGreen, isDark),
                icon: Icons.save,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildInputField(TextEditingController ctrl, String hint, bool isDark,
      {TextInputType? keyboardType}) {
    return Container(
      decoration: NeoBrutalismTheme.neoBox(
        color: isDark ? NeoBrutalismTheme.darkBackground : Colors.grey[50]!,
        offset: 2, borderColor: NeoBrutalismTheme.primaryBlack,
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
          hintStyle: TextStyle(fontSize: 13,
              color: isDark ? Colors.grey[600] : Colors.grey[400]),
        ),
      ),
    );
  }
}