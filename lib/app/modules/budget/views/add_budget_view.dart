import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/budget_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../../widgets/neo_input.dart';
import '../../category/controllers/category_controller.dart';
import '../../expense/widgets/calculator_dialog.dart';
import '../controllers/budget_controller.dart';

class AddBudgetView extends StatefulWidget {
  const AddBudgetView({super.key});

  @override
  State<AddBudgetView> createState() => _AddBudgetViewState();
}

class _AddBudgetViewState extends State<AddBudgetView> {
  final BudgetController budgetController = Get.find();
  final CategoryController categoryController = Get.find();

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCategoryId;
  String _selectedPeriod = 'monthly';
  bool _isEditMode = false;
  BudgetModel? _editingBudget;
  bool _enableAlert = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final args = Get.arguments;
    if (args != null && args is BudgetModel) {
      _isEditMode = true;
      _editingBudget = args;
      setState(() {
        _amountController.text = args.amount.toString();
        _selectedCategoryId = args.categoryId;
        _selectedPeriod = args.period;
        _notesController.text = args.notes ?? '';
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Color _themed(Color c, bool d) => NeoBrutalismTheme.getThemedColor(c, d);

  Future<void> _showCalculator(bool isDark) async {
    final result = await showDialog<double>(
      context: context,
      builder: (_) => CalculatorDialog(isDark: isDark,
          initialAmount: double.tryParse(_amountController.text) ?? 0),
    );
    if (result != null) setState(() { _amountController.text = result.toStringAsFixed(2); });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final budget = BudgetModel(
      id: _isEditMode ? _editingBudget!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      categoryId: _selectedCategoryId,
      amount: double.parse(_amountController.text),
      period: _selectedPeriod,
      startDate: DateTime.now(),
      isActive: true,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (_isEditMode) {
      budgetController.updateBudget(budget);
      Get.back();
      Get.snackbar('Updated', 'Budget updated successfully',
          backgroundColor: NeoBrutalismTheme.accentBlue,
          colorText: NeoBrutalismTheme.primaryBlack,
          borderWidth: 3, borderColor: NeoBrutalismTheme.primaryBlack);
    } else {
      budgetController.addBudget(budget);
      Get.back();
      Get.snackbar('Created', 'Budget added successfully',
          backgroundColor: NeoBrutalismTheme.accentGreen,
          colorText: NeoBrutalismTheme.primaryBlack,
          borderWidth: 3, borderColor: NeoBrutalismTheme.primaryBlack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
      appBar: AppBar(
        title: Text(_isEditMode ? 'EDIT BUDGET' : 'ADD BUDGET',
            style: const TextStyle(fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
        backgroundColor: _themed(NeoBrutalismTheme.accentBlue, isDark),
        foregroundColor: NeoBrutalismTheme.primaryBlack,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          _buildAmountInput(isDark),
          const SizedBox(height: 16),
          _buildCategorySelector(isDark),
          const SizedBox(height: 16),
          _buildPeriodSelector(isDark),
          const SizedBox(height: 16),
          _buildPreview(isDark),
          const SizedBox(height: 16),
          _buildAlertToggle(isDark),
          const SizedBox(height: 16),
          _buildNotesInput(isDark),
          const SizedBox(height: 32),
          _buildSaveButton(isDark),
        ]),
      ),
    );
  }

  Widget _buildAmountInput(bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('BUDGET AMOUNT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
      const SizedBox(height: 8),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: TextFormField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, fontWeight: FontWeight.w500),
            prefixText: '\u{20B9} ',
            prefixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
            filled: true,
            fillColor: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 3)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 4)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 3)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Enter an amount';
            final a = double.tryParse(v);
            if (a == null) return 'Enter a valid number';
            if (a <= 0) return 'Must be greater than 0';
            return null;
          },
        )),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _showCalculator(isDark),
          child: Container(height: 56, width: 56,
              decoration: NeoBrutalismTheme.neoBox(
                  color: _themed(NeoBrutalismTheme.accentBlue, isDark),
                  borderColor: NeoBrutalismTheme.primaryBlack, offset: 4),
              child: const Center(child: Icon(Icons.calculate_outlined, size: 28,
                  color: NeoBrutalismTheme.primaryBlack))),
        ),
      ]),
    ]);
  }

  Widget _buildCategorySelector(bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('CATEGORY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: NeoBrutalismTheme.neoBox(
            color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack),
        child: DropdownButton<String?>(
          value: _selectedCategoryId,
          isExpanded: true,
          underline: const SizedBox(),
          hint: Text('Overall (all categories)', style: TextStyle(fontWeight: FontWeight.w600,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          dropdownColor: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
          icon: Icon(Icons.arrow_drop_down,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
          onChanged: (v) => setState(() { _selectedCategoryId = v; }),
          items: [
            DropdownMenuItem<String?>(value: null,
                child: Text('Overall (all categories)', style: TextStyle(fontWeight: FontWeight.w600,
                    color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack))),
            ...categoryController.categories.map((c) => DropdownMenuItem(
                value: c.id, child: Row(children: [
              Text(c.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(c.name, style: TextStyle(fontWeight: FontWeight.w600,
                  color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
            ]))),
          ],
        ),
      ),
      const SizedBox(height: 6),
      Text('Leave empty for an overall spending limit',
          style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
    ]);
  }

  Widget _buildPeriodSelector(bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('PERIOD', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
      const SizedBox(height: 8),
      Row(children: [
        _periodChip('WEEKLY', 'weekly', isDark),
        const SizedBox(width: 8),
        _periodChip('MONTHLY', 'monthly', isDark),
        const SizedBox(width: 8),
        _periodChip('YEARLY', 'yearly', isDark),
      ]),
    ]);
  }

  Widget _periodChip(String label, String value, bool isDark) {
    final sel = _selectedPeriod == value;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() { _selectedPeriod = value; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: NeoBrutalismTheme.neoBox(
            color: sel ? _themed(NeoBrutalismTheme.accentGreen, isDark)
                : (isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite),
            offset: sel ? 2 : 5, borderColor: NeoBrutalismTheme.primaryBlack),
        child: Center(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
            color: sel ? NeoBrutalismTheme.primaryBlack
                : (isDark ? NeoBrutalismTheme.darkText.withOpacity(0.7)
                : NeoBrutalismTheme.primaryBlack.withOpacity(0.7))))),
      ),
    ));
  }

  /// Live preview of daily allowance before saving
  Widget _buildPreview(bool isDark) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return const SizedBox();

    int days;
    switch (_selectedPeriod) {
      case 'weekly': days = 7; break;
      case 'yearly': days = 365; break;
      default: days = 30;
    }
    final daily = amount / days;
    final weekly = daily * 7;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: NeoBrutalismTheme.neoBox(
          color: _themed(NeoBrutalismTheme.accentYellow, isDark).withOpacity(0.5),
          borderColor: NeoBrutalismTheme.primaryBlack, offset: 3),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: NeoBrutalismTheme.primaryBlack,
                borderRadius: BorderRadius.circular(4)),
            child: const Text('PREVIEW', style: TextStyle(fontSize: 9,
                fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Daily limit', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
            Text('\u{20B9}${daily.toStringAsFixed(0)}/day', style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
          ])),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Weekly limit', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
            Text('\u{20B9}${weekly.toStringAsFixed(0)}/week', style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
          ])),
        ]),
        const SizedBox(height: 8),
        Text('$_selectedPeriod budget of \u{20B9}${amount.toStringAsFixed(0)} = $days days',
            style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
      ]),
    );
  }

  Widget _buildAlertToggle(bool isDark) {
    return NeoCard(
      color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SMART ALERTS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          const SizedBox(height: 2),
          Text('Notify at 75%, 90%, and 100%',
              style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ]),
        Switch(value: _enableAlert,
            onChanged: (v) => setState(() { _enableAlert = v; }),
            activeColor: _themed(NeoBrutalismTheme.accentGreen, isDark)),
      ]),
    );
  }

  Widget _buildNotesInput(bool isDark) {
    return NeoInput(controller: _notesController, label: 'NOTES (OPTIONAL)',
        hint: 'Budget notes...', maxLines: 3, isDark: isDark);
  }

  Widget _buildSaveButton(bool isDark) {
    return NeoButton(
      text: _isEditMode ? 'UPDATE BUDGET' : 'SAVE BUDGET',
      onPressed: _save,
      color: _themed(_isEditMode ? NeoBrutalismTheme.accentBlue : NeoBrutalismTheme.accentGreen, isDark),
      height: 64,
      icon: _isEditMode ? Icons.update : Icons.save,
    );
  }
}