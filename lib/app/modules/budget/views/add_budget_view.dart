import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    final args = Get.arguments;
    if (args != null && args is BudgetModel) {
      _isEditMode = true;
      _editingBudget = args;
      _populateFormWithBudget(args);
    }
  }

  void _populateFormWithBudget(BudgetModel budget) {
    setState(() {
      _amountController.text = budget.amount.toString();
      _selectedCategoryId = budget.categoryId;
      _selectedPeriod = budget.period;
      _notesController.text = budget.notes ?? '';
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _showCalculator(bool isDark) async {
    final double? calculatedAmount = await showDialog<double>(
      context: context,
      builder: (context) => CalculatorDialog(
        isDark: isDark,
        initialAmount: _amountController.text.isEmpty
            ? 0
            : double.tryParse(_amountController.text) ?? 0,
      ),
    );

    if (calculatedAmount != null) {
      setState(() {
        _amountController.text = calculatedAmount.toStringAsFixed(2);
      });
    }
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      final budget = BudgetModel(
        id: _isEditMode
            ? _editingBudget!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: _selectedCategoryId,
        amount: double.parse(_amountController.text),
        period: _selectedPeriod,
        startDate: DateTime.now(),
        isActive: true,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (_isEditMode) {
        budgetController.updateBudget(budget);
        Get.back();
        Get.snackbar(
          'Success',
          'Budget updated successfully!',
          backgroundColor: NeoBrutalismTheme.accentBlue,
          colorText: NeoBrutalismTheme.primaryBlack,
        );
      } else {
        budgetController.addBudget(budget);
        Get.back();
        Get.snackbar(
          'Success',
          'Budget added successfully!',
          backgroundColor: NeoBrutalismTheme.accentGreen,
          colorText: NeoBrutalismTheme.primaryBlack,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.primaryWhite,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'EDIT BUDGET' : 'ADD BUDGET',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: NeoBrutalismTheme.primaryBlack,
          ),
        ),
        backgroundColor: _getThemedColor(NeoBrutalismTheme.accentBlue, isDark),
        foregroundColor: NeoBrutalismTheme.primaryBlack,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildAmountInput(isDark),
            const SizedBox(height: 16),
            _buildCategorySelector(isDark),
            const SizedBox(height: 16),
            _buildPeriodSelector(isDark),
            const SizedBox(height: 16),
            _buildNotesInput(isDark),
            const SizedBox(height: 32),
            _buildSaveButton(isDark),
          ],
        ),
      ),
    );
  }

  Color _getThemedColor(Color color, bool isDark) {
    if (!isDark) return color;

    final colorMap = {
      NeoBrutalismTheme.accentYellow: Color(0xFFE6B800),
      NeoBrutalismTheme.accentPink: Color(0xFFE667A0),
      NeoBrutalismTheme.accentBlue: Color(0xFF4D94FF),
      NeoBrutalismTheme.accentGreen: Color(0xFF00CC66),
      NeoBrutalismTheme.accentOrange: Color(0xFFFF8533),
      NeoBrutalismTheme.accentPurple: Color(0xFF9966FF),
    };

    return colorMap[color] ?? color;
  }

  Widget _buildAmountInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BUDGET AMOUNT',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: isDark
                ? NeoBrutalismTheme.darkText
                : NeoBrutalismTheme.primaryBlack,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _amountController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? NeoBrutalismTheme.darkSurface
                      : NeoBrutalismTheme.primaryWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: NeoBrutalismTheme.primaryBlack,
                      width: 3,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: NeoBrutalismTheme.primaryBlack,
                      width: 3,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: NeoBrutalismTheme.primaryBlack,
                      width: 4,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 3),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 4),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return 'Please enter a valid number';
                  }
                  if (amount <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _showCalculator(isDark),
              child: Container(
                height: 56,
                width: 56,
                decoration: NeoBrutalismTheme.neoBox(
                  color: _getThemedColor(NeoBrutalismTheme.accentBlue, isDark),
                  borderColor: NeoBrutalismTheme.primaryBlack,
                  offset: 4,
                ),
                child: Center(
                  child: Icon(
                    Icons.calculate_outlined,
                    size: 28,
                    color: NeoBrutalismTheme.primaryBlack,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATEGORY (OPTIONAL)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: isDark
                ? NeoBrutalismTheme.darkText
                : NeoBrutalismTheme.primaryBlack,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: NeoBrutalismTheme.neoBox(
            color: isDark
                ? NeoBrutalismTheme.darkSurface
                : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack,
          ),
          child: DropdownButton<String?>(
            value: _selectedCategoryId,
            isExpanded: true,
            underline: const SizedBox(),
            hint: Text(
              'Overall Budget (All Categories)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? NeoBrutalismTheme.darkText
                    : NeoBrutalismTheme.primaryBlack,
              ),
            ),
            dropdownColor: isDark
                ? NeoBrutalismTheme.darkSurface
                : NeoBrutalismTheme.primaryWhite,
            icon: Icon(
              Icons.arrow_drop_down,
              color: isDark
                  ? NeoBrutalismTheme.darkText
                  : NeoBrutalismTheme.primaryBlack,
            ),
            onChanged: (value) {
              setState(() {
                _selectedCategoryId = value;
              });
            },
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(
                  'Overall Budget (All Categories)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
                  ),
                ),
              ),
              ...categoryController.categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Row(
                    children: [
                      Text(category.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? NeoBrutalismTheme.darkText
                              : NeoBrutalismTheme.primaryBlack,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Leave empty for overall spending budget',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BUDGET PERIOD',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: isDark
                ? NeoBrutalismTheme.darkText
                : NeoBrutalismTheme.primaryBlack,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildPeriodOption('WEEKLY', 'weekly', isDark),
            const SizedBox(width: 8),
            _buildPeriodOption('MONTHLY', 'monthly', isDark),
            const SizedBox(width: 8),
            _buildPeriodOption('YEARLY', 'yearly', isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodOption(String label, String value, bool isDark) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: NeoBrutalismTheme.neoBox(
            color: isSelected
                ? _getThemedColor(NeoBrutalismTheme.accentGreen, isDark)
                : (isDark
                ? NeoBrutalismTheme.darkBackground
                : NeoBrutalismTheme.primaryWhite),
            offset: isSelected ? 2 : 5,
            borderColor: NeoBrutalismTheme.primaryBlack,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isSelected
                    ? NeoBrutalismTheme.primaryBlack
                    : (isDark
                    ? NeoBrutalismTheme.darkText.withOpacity(0.7)
                    : NeoBrutalismTheme.primaryBlack.withOpacity(0.7)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesInput(bool isDark) {
    return NeoInput(
      controller: _notesController,
      label: 'NOTES (OPTIONAL)',
      hint: 'Add any notes about this budget...',
      maxLines: 3,
      isDark: isDark,
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return NeoButton(
      text: _isEditMode ? 'UPDATE BUDGET' : 'SAVE BUDGET',
      onPressed: _saveBudget,
      color: _getThemedColor(
        _isEditMode
            ? NeoBrutalismTheme.accentBlue
            : NeoBrutalismTheme.accentGreen,
        isDark,
      ),
      height: 64,
      icon: _isEditMode ? Icons.update : Icons.save,
    );
  }
}