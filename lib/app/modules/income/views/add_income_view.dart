import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/income_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_account_picker.dart';
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

  bool _isEditMode = false;
  IncomeModel? _editingIncome;
  bool _isPrefilled = false; // SMS prefill tracking

  final Rxn<String> selectedAccountId = Rxn<String>(null);

  Color _getThemedColor(Color color, bool isDark) {
    return NeoBrutalismTheme.getThemedColor(color, isDark);
  }

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    final args = Get.arguments;
    if (args == null) return;

    // ─── MODE 1: Edit existing income ───────────────────
    if (args is Map<String, dynamic> && args['isEdit'] == true) {
      _isEditMode = true;
      final income = args['income'] as IncomeModel?;
      if (income != null) {
        _editingIncome = income;
        _populateFormWithIncome(income);
      }
      return;
    }

    // ─── MODE 2: SMS pre-fill ───────────────────────────
    if (args is Map<String, dynamic> && args['prefill'] == true) {
      _isPrefilled = true;
      _populateFromSms(args);
      return;
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
      selectedAccountId.value = income.accountId;
    });
  }

  /// Pre-fill from SMS transaction data
  void _populateFromSms(Map<String, dynamic> data) {
    setState(() {
      final amount = data['amount'];
      if (amount != null) _amountController.text = amount.toString();

      final title = data['title'];
      if (title != null && title.toString().isNotEmpty) {
        _titleController.text = title.toString();
      }

      final source = data['source'];
      if (source != null && source.toString().isNotEmpty) {
        _sourceController.text = source.toString();
      }

      final desc = data['description'];
      if (desc != null && desc.toString().isNotEmpty) {
        _descriptionController.text = desc.toString();
      }

      final accountId = data['accountId'];
      if (accountId != null) {
        selectedAccountId.value = accountId.toString();
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      Get.snackbar(
        '📱 Auto-detected from SMS',
        'Income fields pre-filled. Review and save!',
        backgroundColor: NeoBrutalismTheme.accentSkyBlue,
        colorText: NeoBrutalismTheme.primaryBlack,
        borderWidth: 3,
        borderColor: NeoBrutalismTheme.primaryBlack,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.sms, color: NeoBrutalismTheme.primaryBlack),
      );
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
              surface: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
              onSurface: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() { _selectedDate = picked; });
    }
  }

  Future<void> _showCalculator(bool isDark) async {
    final double? result = await showDialog<double>(
      context: context,
      builder: (context) => CalculatorDialog(
        isDark: isDark,
        initialAmount: _amountController.text.isEmpty
            ? 0 : double.tryParse(_amountController.text) ?? 0,
      ),
    );
    if (result != null) {
      setState(() { _amountController.text = result.toStringAsFixed(2); });
    }
  }

  Future<void> _saveIncome() async {
    if (_formKey.currentState!.validate()) {
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
            ? null : _descriptionController.text.trim(),
        isRecurring: _isRecurring,
        recurringType: _isRecurring ? _recurringType : null,
        accountId: selectedAccountId.value,
      );

      if (_isEditMode) {
        incomeController.updateIncome(income);
        Navigator.of(Get.context!).pop();
        Get.snackbar('Success', 'Income updated!',
            backgroundColor: NeoBrutalismTheme.accentBlue,
            colorText: NeoBrutalismTheme.primaryBlack,
            borderWidth: 3, borderColor: NeoBrutalismTheme.primaryBlack,
            duration: const Duration(seconds: 2));
      } else {
        incomeController.addIncome(income);
        Navigator.of(context).pop();
        Get.snackbar('Success',
            _isPrefilled ? 'SMS income saved!' : 'Income added!',
            backgroundColor: NeoBrutalismTheme.accentGreen,
            colorText: NeoBrutalismTheme.primaryBlack,
            borderWidth: 3, borderColor: NeoBrutalismTheme.primaryBlack,
            duration: const Duration(seconds: 2));
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
          _isEditMode ? 'EDIT INCOME' : (_isPrefilled ? 'SMS INCOME' : 'ADD INCOME'),
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
            // SMS banner
            if (_isPrefilled) _buildSmsBanner(isDark),
            if (_isPrefilled) const SizedBox(height: 12),

            _buildTitleInput(isDark),
            const SizedBox(height: 16),
            _buildAmountInput(isDark),
            const SizedBox(height: 16),
            _buildSourceInput(isDark),
            const SizedBox(height: 16),
            NeoAccountPicker(
              selectedAccountId: selectedAccountId,
              isDark: isDark,
              label: 'RECEIVE INTO ACCOUNT',
            ),
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

  Widget _buildSmsBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: NeoBrutalismTheme.neoBox(
        color: _getThemedColor(NeoBrutalismTheme.accentSkyBlue, isDark),
        offset: 3,
        borderColor: NeoBrutalismTheme.primaryBlack,
      ),
      child: Row(
        children: [
          const Icon(Icons.sms, size: 22, color: NeoBrutalismTheme.primaryBlack),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AUTO-DETECTED FROM SMS',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
                        color: NeoBrutalismTheme.primaryBlack)),
                const SizedBox(height: 2),
                Text('Income detected from bank message. Review and save.',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleInput(bool isDark) {
    return NeoAutocompleteInput(
      controller: _titleController,
      label: 'INCOME TITLE',
      hint: 'e.g., Monthly Salary',
      suggestions: autocompleteController.incomeTitles,
      onSuggestionSelected: (v) { _titleController.text = v; },
      isDark: isDark,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Please enter a title';
        if (v.trim().length < 3) return 'Title must be at least 3 characters';
        return null;
      },
    );
  }

  Widget _buildAmountInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AMOUNT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                    color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, fontWeight: FontWeight.w500),
                  prefixText: '₹ ',
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
                  if (v == null || v.isEmpty) return 'Please enter an amount';
                  final amt = double.tryParse(v);
                  if (amt == null) return 'Please enter a valid number';
                  if (amt <= 0) return 'Amount must be greater than 0';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _showCalculator(isDark),
              child: Container(
                height: 56, width: 56,
                decoration: NeoBrutalismTheme.neoBox(
                    color: _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
                    borderColor: NeoBrutalismTheme.primaryBlack, offset: 4),
                child: const Center(child: Icon(Icons.calculate_outlined, size: 28,
                    color: NeoBrutalismTheme.primaryBlack)),
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
      onSuggestionSelected: (v) { _sourceController.text = v; },
      isDark: isDark,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Please enter an income source';
        return null;
      },
    );
  }

  Widget _buildDateSelector(bool isDark) {
    return GestureDetector(
      onTap: () => _selectDate(isDark),
      child: NeoCard(
        color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
        borderColor: NeoBrutalismTheme.primaryBlack,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('DATE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
            const SizedBox(height: 4),
            Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                    color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          ]),
          Icon(Icons.calendar_today,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
        ]),
      ),
    );
  }

  Widget _buildDescriptionInput(bool isDark) {
    return NeoAutocompleteInput(
      controller: _descriptionController,
      label: 'DESCRIPTION (OPTIONAL)',
      hint: 'Add any notes...',
      suggestions: const [],
      onSuggestionSelected: (v) {},
      maxLines: 3,
      isDark: isDark,
      validator: (v) => v != null && v.trim().length > 500 ? 'Max 500 characters' : null,
    );
  }

  Widget _buildRecurringToggle(bool isDark) {
    return NeoCard(
      color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('RECURRING INCOME', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          Switch(value: _isRecurring, onChanged: (v) { setState(() { _isRecurring = v; }); },
              activeColor: _getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
              activeTrackColor: _getThemedColor(NeoBrutalismTheme.accentGreen, isDark).withOpacity(0.5),
              inactiveThumbColor: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack,
              inactiveTrackColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        ]),
        if (_isRecurring) ...[
          const SizedBox(height: 16),
          Align(alignment: Alignment.centerLeft, child: Text('FREQUENCY',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                  color: isDark ? Colors.grey[400] : Colors.grey))),
          const SizedBox(height: 8),
          Row(children: [
            _buildRecurringOption('DAILY', 'daily', isDark), const SizedBox(width: 8),
            _buildRecurringOption('WEEKLY', 'weekly', isDark), const SizedBox(width: 8),
            _buildRecurringOption('MONTHLY', 'monthly', isDark), const SizedBox(width: 8),
            _buildRecurringOption('YEARLY', 'yearly', isDark),
          ]),
        ],
      ]),
    );
  }

  Widget _buildRecurringOption(String label, String value, bool isDark) {
    final isSelected = _recurringType == value;
    return Expanded(child: GestureDetector(
      onTap: () { setState(() { _recurringType = value; }); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: NeoBrutalismTheme.neoBox(
            color: isSelected ? _getThemedColor(NeoBrutalismTheme.accentGreen, isDark)
                : (isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite),
            offset: isSelected ? 2 : 5, borderColor: NeoBrutalismTheme.primaryBlack),
        child: Center(child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
            color: isSelected ? NeoBrutalismTheme.primaryBlack
                : (isDark ? NeoBrutalismTheme.darkText.withOpacity(0.7)
                : NeoBrutalismTheme.primaryBlack.withOpacity(0.7))))),
      ),
    ));
  }

  Widget _buildSaveButton(bool isDark) {
    return NeoButton(
      text: _isEditMode ? 'UPDATE INCOME' : (_isPrefilled ? 'SAVE SMS INCOME' : 'SAVE INCOME'),
      onPressed: _saveIncome,
      color: _getThemedColor(
          _isEditMode ? NeoBrutalismTheme.accentBlue : NeoBrutalismTheme.accentGreen, isDark),
      height: 64,
      icon: _isEditMode ? Icons.update : (_isPrefilled ? Icons.sms : Icons.save),
    );
  }
}