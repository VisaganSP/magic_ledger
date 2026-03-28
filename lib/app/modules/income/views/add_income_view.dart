import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/income_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../../widgets/neo_autocomplete_input.dart';
import '../controllers/income_controller.dart';
import '../../expense/controllers/autocomplete_controller.dart';
import '../../expense/widgets/calculator_dialog.dart';

class AddIncomeView extends StatefulWidget {
  const AddIncomeView({super.key});

  @override
  State<AddIncomeView> createState() => _AddIncomeViewState();
}

class _AddIncomeViewState extends State<AddIncomeView> {
  final IncomeController incomeController = Get.find();
  final AutocompleteController autocompleteController = Get.find();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  String _recurringType = 'monthly';

  // Track if we're editing
  bool _isEditMode = false;
  IncomeModel? _editingIncome;

  // Helper method to get muted colors for dark theme
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

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _isEditMode = args['isEdit'] ?? false;
      final income = args['income'] as IncomeModel?;

      if (_isEditMode && income != null) {
        _editingIncome = income;
        _populateFormWithIncome(income);
      }
    }
  }

  void _populateFormWithIncome(IncomeModel income) {
    setState(() {
      _titleController.text = income.title;
      _amountController.text = income.amount.toString();
      _sourceController.text = income.source;
      _selectedDate = income.date;
      _descriptionController.text = income.description ?? '';
      _isRecurring = income.isRecurring;
      _recurringType = income.recurringType ?? 'monthly';
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _sourceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isDark) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: NeoBrutalismTheme.primaryBlack,
              onPrimary: NeoBrutalismTheme.primaryWhite,
              surface: isDark
                  ? NeoBrutalismTheme.darkSurface
                  : NeoBrutalismTheme.primaryWhite,
              onSurface: isDark
                  ? NeoBrutalismTheme.darkText
                  : NeoBrutalismTheme.primaryBlack,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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

  Future<void> _saveIncome() async {
    if (_formKey.currentState!.validate()) {
      // Save autocomplete data
      await autocompleteController.addIncomeTitle(_titleController.text.trim());
      await autocompleteController.addIncomeSource(_sourceController.text.trim());

      final income = IncomeModel(
        id: _isEditMode
            ? _editingIncome!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        source: _sourceController.text.trim(),
        date: _selectedDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        isRecurring: _isRecurring,
        recurringType: _isRecurring ? _recurringType : null,
      );

      if (_isEditMode) {
        incomeController.updateIncome(income);
        Get.back();
        Get.snackbar(
          'Success',
          'Income updated successfully!',
          backgroundColor: NeoBrutalismTheme.accentBlue,
          colorText: NeoBrutalismTheme.primaryBlack,
          borderWidth: 3,
          borderColor: NeoBrutalismTheme.primaryBlack,
          duration: const Duration(seconds: 2),
        );
      } else {
        incomeController.addIncome(income);
        Get.back();
        Get.snackbar(
          'Success',
          'Income added successfully!',
          backgroundColor: NeoBrutalismTheme.accentGreen,
          colorText: NeoBrutalismTheme.primaryBlack,
          borderWidth: 3,
          borderColor: NeoBrutalismTheme.primaryBlack,
          duration: const Duration(seconds: 2),
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
          _isEditMode ? 'EDIT INCOME' : 'ADD INCOME',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: NeoBrutalismTheme.primaryBlack,
          ),
        ),
        backgroundColor: _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
        foregroundColor: NeoBrutalismTheme.primaryBlack,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTitleInput(isDark),
            const SizedBox(height: 16),
            _buildAmountInput(isDark),
            const SizedBox(height: 16),
            _buildSourceInput(isDark),
            const SizedBox(height: 16),
            _buildDateSelector(isDark),
            const SizedBox(height: 16),
            _buildDescriptionInput(isDark),
            const SizedBox(height: 16),
            _buildRecurringToggle(isDark),
            const SizedBox(height: 32),
            _buildSaveButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleInput(bool isDark) {
    return NeoAutocompleteInput(
      controller: _titleController,
      label: 'INCOME TITLE',
      hint: 'e.g., Monthly Salary',
      suggestions: autocompleteController.incomeTitles,
      onSuggestionSelected: (value) {
        _titleController.text = value;
      },
      isDark: isDark,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a title';
        }
        if (value.trim().length < 3) {
          return 'Title must be at least 3 characters';
        }
        return null;
      },
    );
  }

  Widget _buildAmountInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AMOUNT',
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
                  color: _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
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

  Widget _buildSourceInput(bool isDark) {
    return NeoAutocompleteInput(
      controller: _sourceController,
      label: 'INCOME SOURCE',
      hint: 'e.g., Salary, Freelance',
      suggestions: autocompleteController.incomeSources,
      onSuggestionSelected: (value) {
        _sourceController.text = value;
      },
      isDark: isDark,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter an income source';
        }
        return null;
      },
    );
  }

  Widget _buildDateSelector(bool isDark) {
    return GestureDetector(
      onTap: () => _selectDate(isDark),
      child: NeoCard(
        color: isDark
            ? NeoBrutalismTheme.darkSurface
            : NeoBrutalismTheme.primaryWhite,
        borderColor: NeoBrutalismTheme.primaryBlack,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DATE',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? NeoBrutalismTheme.darkText
                        : NeoBrutalismTheme.primaryBlack,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.calendar_today,
              color: isDark
                  ? NeoBrutalismTheme.darkText
                  : NeoBrutalismTheme.primaryBlack,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionInput(bool isDark) {
    return NeoAutocompleteInput(
      controller: _descriptionController,
      label: 'DESCRIPTION (OPTIONAL)',
      hint: 'Add any notes...',
      suggestions: [],
      onSuggestionSelected: (value) {},
      maxLines: 3,
      isDark: isDark,
      validator: (value) {
        if (value != null && value.trim().length > 500) {
          return 'Description must be less than 500 characters';
        }
        return null;
      },
    );
  }

  Widget _buildRecurringToggle(bool isDark) {
    return NeoCard(
      color: isDark
          ? NeoBrutalismTheme.darkSurface
          : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECURRING INCOME',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
                ),
              ),
              Switch(
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value;
                  });
                },
                activeColor: _getThemedColor(
                  NeoBrutalismTheme.accentGreen,
                  isDark,
                ),
                activeTrackColor: _getThemedColor(
                  NeoBrutalismTheme.accentGreen,
                  isDark,
                ).withOpacity(0.5),
                inactiveThumbColor: isDark
                    ? NeoBrutalismTheme.darkText
                    : NeoBrutalismTheme.primaryBlack,
                inactiveTrackColor:
                isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ],
          ),
          if (_isRecurring) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'FREQUENCY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.grey[400] : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRecurringOption('DAILY', 'daily', isDark),
                const SizedBox(width: 8),
                _buildRecurringOption('WEEKLY', 'weekly', isDark),
                const SizedBox(width: 8),
                _buildRecurringOption('MONTHLY', 'monthly', isDark),
                const SizedBox(width: 8),
                _buildRecurringOption('YEARLY', 'yearly', isDark),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecurringOption(String label, String value, bool isDark) {
    final isSelected = _recurringType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _recurringType = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
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
                fontSize: 11,
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

  Widget _buildSaveButton(bool isDark) {
    return NeoButton(
      text: _isEditMode ? 'UPDATE INCOME' : 'SAVE INCOME',
      onPressed: _saveIncome,
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