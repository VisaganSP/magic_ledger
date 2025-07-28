import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/income_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../../widgets/neo_input.dart';
import '../controllers/income_controller.dart';

class AddIncomeView extends StatefulWidget {
  const AddIncomeView({super.key});

  @override
  State<AddIncomeView> createState() => _AddIncomeViewState();
}

class _AddIncomeViewState extends State<AddIncomeView> {
  final IncomeController incomeController = Get.find();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedSource = 'Salary';
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  String _recurringType = 'monthly';

  // Track if we're editing
  bool _isEditMode = false;
  IncomeModel? _editingIncome;

  final List<String> _incomeSources = [
    'Salary',
    'Freelance',
    'Investment',
    'Business',
    'Gift',
    'Other',
  ];

  final List<String> _recurringTypes = [
    'daily',
    'weekly',
    'monthly',
    'yearly',
  ];

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
    _titleController.text = income.title;
    _amountController.text = income.amount.toString();
    _selectedSource = income.source;
    _selectedDate = income.date;
    _descriptionController.text = income.description ?? '';
    _isRecurring = income.isRecurring;
    _recurringType = income.recurringType ?? 'monthly';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: NeoBrutalismTheme.primaryBlack,
              onPrimary: NeoBrutalismTheme.primaryWhite,
              surface: NeoBrutalismTheme.primaryWhite,
              onSurface: NeoBrutalismTheme.primaryBlack,
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

  void _saveIncome() {
    if (_formKey.currentState!.validate()) {
      final income = IncomeModel(
        id: _isEditMode ? _editingIncome!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        source: _selectedSource,
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
    return Scaffold(
      backgroundColor: NeoBrutalismTheme.primaryWhite,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'EDIT INCOME' : 'ADD INCOME',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: NeoBrutalismTheme.accentGreen,
        foregroundColor: NeoBrutalismTheme.primaryBlack,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTitleInput(),
            const SizedBox(height: 16),
            _buildAmountInput(),
            const SizedBox(height: 16),
            _buildSourceSelector(),
            const SizedBox(height: 16),
            _buildDateSelector(),
            const SizedBox(height: 16),
            _buildDescriptionInput(),
            const SizedBox(height: 16),
            _buildRecurringToggle(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleInput() {
    return NeoInput(
      controller: _titleController,
      label: 'INCOME TITLE',
      hint: 'e.g., Monthly Salary',
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

  Widget _buildAmountInput() {
    return NeoInput(
      controller: _amountController,
      label: 'AMOUNT',
      hint: '0.00',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      prefixText: '₹ ',
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
    );
  }

  Widget _buildSourceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INCOME SOURCE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: NeoBrutalismTheme.primaryBlack,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: NeoBrutalismTheme.neoBox(
            color: NeoBrutalismTheme.primaryWhite,
          ),
          child: DropdownButton<String>(
            value: _selectedSource,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(
              Icons.arrow_drop_down,
              color: NeoBrutalismTheme.primaryBlack,
            ),
            onChanged: (value) {
              setState(() {
                _selectedSource = value!;
              });
            },
            items: _incomeSources.map((source) {
              return DropdownMenuItem(
                value: source,
                child: Text(
                  source,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: NeoBrutalismTheme.primaryBlack,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: NeoCard(
        color: NeoBrutalismTheme.primaryWhite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DATE',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: NeoBrutalismTheme.primaryBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: NeoBrutalismTheme.primaryBlack,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.calendar_today,
              color: NeoBrutalismTheme.primaryBlack,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return NeoInput(
      controller: _descriptionController,
      label: 'DESCRIPTION (OPTIONAL)',
      hint: 'Add any notes...',
      maxLines: 3,
      validator: (value) {
        if (value != null && value.trim().length > 500) {
          return 'Description must be less than 500 characters';
        }
        return null;
      },
    );
  }

  Widget _buildRecurringToggle() {
    return NeoCard(
      color: NeoBrutalismTheme.primaryWhite,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RECURRING INCOME',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.primaryBlack,
                ),
              ),
              Switch(
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value;
                  });
                },
                activeColor: NeoBrutalismTheme.accentGreen,
                activeTrackColor: NeoBrutalismTheme.accentGreen.withOpacity(0.5),
                inactiveThumbColor: NeoBrutalismTheme.primaryBlack,
                inactiveTrackColor: Colors.grey.shade300,
              ),
            ],
          ),
          if (_isRecurring) ...[
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'FREQUENCY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRecurringOption('DAILY', 'daily'),
                const SizedBox(width: 8),
                _buildRecurringOption('WEEKLY', 'weekly'),
                const SizedBox(width: 8),
                _buildRecurringOption('MONTHLY', 'monthly'),
                const SizedBox(width: 8),
                _buildRecurringOption('YEARLY', 'yearly'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecurringOption(String label, String value) {
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
                ? NeoBrutalismTheme.accentGreen
                : NeoBrutalismTheme.primaryWhite,
            offset: isSelected ? 2 : 5,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isSelected
                    ? NeoBrutalismTheme.primaryBlack
                    : NeoBrutalismTheme.primaryBlack.withOpacity(0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return NeoButton(
      text: _isEditMode ? 'UPDATE INCOME' : 'SAVE INCOME',
      onPressed: _saveIncome,
      color: _isEditMode ? NeoBrutalismTheme.accentBlue : NeoBrutalismTheme.accentGreen,
      height: 64,
      icon: _isEditMode ? Icons.update : Icons.save,
    );
  }
}