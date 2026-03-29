import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/expense_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_account_picker.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../../widgets/neo_autocomplete_input.dart';
import '../../../widgets/neo_input.dart';
import '../../category/controllers/category_controller.dart';
import '../controllers/expense_controller.dart';
import '../controllers/autocomplete_controller.dart';
import '../widgets/calculator_dialog.dart';
import '../widgets/category_bottom_sheet.dart';
import '../widgets/tag_dialog.dart';

class AddExpenseView extends StatefulWidget {
  const AddExpenseView({super.key});

  @override
  State<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<AddExpenseView>
    with TickerProviderStateMixin {
  final ExpenseController expenseController = Get.find();
  final CategoryController categoryController = Get.find();
  final AutocompleteController autocompleteController = Get.find();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  File? _receiptImage;
  bool _isRecurring = false;
  String _recurringType = 'monthly';
  final List<String> _tags = [];

  bool _isEditMode = false;
  ExpenseModel? _editingExpense;
  bool _isPrefilled = false; // SMS prefill tracking

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Rxn<String> selectedAccountId = Rxn<String>(null);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFormData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  void _initializeFormData() {
    final args = Get.arguments;

    if (args == null) {
      _setDefaultCategory();
      return;
    }

    // ─── MODE 1: Edit existing expense ──────────────────
    if (args is Map<String, dynamic> && args['isEdit'] == true) {
      _isEditMode = true;
      final expense = args['expense'] as ExpenseModel?;
      if (expense != null) {
        _editingExpense = expense;
        _populateFormWithExpense(expense);
      }
      return;
    }

    // ─── MODE 2: SMS pre-fill ───────────────────────────
    if (args is Map<String, dynamic> && args['prefill'] == true) {
      _isPrefilled = true;
      _populateFromSms(args);
      return;
    }

    _setDefaultCategory();
  }

  void _setDefaultCategory() {
    if (_selectedCategoryId == null && categoryController.categories.isNotEmpty) {
      setState(() {
        _selectedCategoryId = categoryController.categories.first.id;
      });
    }
  }

  void _populateFormWithExpense(ExpenseModel expense) {
    setState(() {
      _titleController.text = expense.title;
      _amountController.text = expense.amount.toString();
      _selectedCategoryId = expense.categoryId;
      _selectedDate = expense.date;
      _descriptionController.text = expense.description ?? '';
      _locationController.text = expense.location ?? '';
      _tags.clear();
      if (expense.tags != null) _tags.addAll(expense.tags!);
      _isRecurring = expense.isRecurring;
      _recurringType = expense.recurringType ?? 'monthly';
      if (expense.receiptPath != null) _receiptImage = File(expense.receiptPath!);
      selectedAccountId.value = expense.accountId;
    });
  }

  /// Pre-fill from SMS transaction data
  void _populateFromSms(Map<String, dynamic> data) {
    setState(() {
      // Amount
      final amount = data['amount'];
      if (amount != null) {
        _amountController.text = amount.toString();
      }

      // Title
      final title = data['title'];
      if (title != null && title.toString().isNotEmpty) {
        _titleController.text = title.toString();
      }

      // Description
      final desc = data['description'];
      if (desc != null && desc.toString().isNotEmpty) {
        _descriptionController.text = desc.toString();
      }

      // Account
      final accountId = data['accountId'];
      if (accountId != null) {
        selectedAccountId.value = accountId.toString();
      }

      // Category — match by name
      final categoryName = data['category'];
      if (categoryName != null) {
        try {
          final match = categoryController.categories.firstWhere(
                (c) => c.name.toLowerCase() == categoryName.toString().toLowerCase(),
          );
          _selectedCategoryId = match.id;
        } catch (_) {
          _setDefaultCategory();
        }
      } else {
        _setDefaultCategory();
      }
    });

    // Show a banner that this was auto-detected
    Future.delayed(const Duration(milliseconds: 500), () {
      Get.snackbar(
        '📱 Auto-detected from SMS',
        'Fields pre-filled. Review and save!',
        backgroundColor: NeoBrutalismTheme.accentSkyBlue,
        colorText: NeoBrutalismTheme.primaryBlack,
        borderWidth: 3,
        borderColor: NeoBrutalismTheme.primaryBlack,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.sms, color: NeoBrutalismTheme.primaryBlack),
      );
    });
  }

  Color _getThemedColor(Color color, bool isDark) {
    return NeoBrutalismTheme.getThemedColor(color, isDark);
  }

  // ─── ACTION HANDLERS ─────────────────────────────────────

  Future<void> _pickReceipt(bool isDark) async {
    final ImagePicker picker = ImagePicker();
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildImageSourceSelector(isDark),
    );
    if (source != null) {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() { _receiptImage = File(image.path); });
      }
    }
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

  void _showCategoryBottomSheet(bool isDark) {
    showCategoryBottomSheet(
      context: context,
      isDark: isDark,
      selectedCategoryId: _selectedCategoryId,
      onCategorySelected: (categoryId) {
        setState(() { _selectedCategoryId = categoryId; });
      },
      getThemedColor: _getThemedColor,
    );
  }

  Future<void> _addTag(bool isDark) async {
    final String? tag = await showDialog<String>(
      context: context,
      builder: (context) => TagDialog(isDark: isDark),
    );
    if (tag != null && tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() { _tags.add(tag); });
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        Get.snackbar('Error', 'Please select a category',
            backgroundColor: Colors.red, colorText: NeoBrutalismTheme.primaryWhite,
            borderWidth: 3, borderColor: NeoBrutalismTheme.primaryBlack);
        return;
      }

      await _saveAutocompleteData();
      final expense = _buildExpenseModel();

      if (_isEditMode) {
        expenseController.updateExpense(expense);
        Get.back();
        Get.snackbar('Success', 'Expense updated!',
            backgroundColor: NeoBrutalismTheme.accentBlue,
            colorText: NeoBrutalismTheme.primaryBlack,
            borderWidth: 3, borderColor: NeoBrutalismTheme.primaryBlack,
            duration: const Duration(seconds: 2));
      } else {
        expenseController.addExpense(expense);
        Get.back();
        Get.snackbar('Success',
            _isPrefilled ? 'SMS expense saved!' : 'Expense added!',
            backgroundColor: NeoBrutalismTheme.accentGreen,
            colorText: NeoBrutalismTheme.primaryBlack,
            borderWidth: 3, borderColor: NeoBrutalismTheme.primaryBlack,
            duration: const Duration(seconds: 2));
      }
    }
  }

  Future<void> _saveAutocompleteData() async {
    await autocompleteController.addTitle(_titleController.text.trim());
    if (_locationController.text.trim().isNotEmpty) {
      await autocompleteController.addLocation(_locationController.text.trim());
    }
    for (final tag in _tags) {
      await autocompleteController.addTag(tag);
    }
  }

  ExpenseModel _buildExpenseModel() {
    return ExpenseModel(
      id: _isEditMode
          ? _editingExpense!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      categoryId: _selectedCategoryId!,
      date: _selectedDate,
      description: _descriptionController.text.trim().isEmpty
          ? null : _descriptionController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null : _locationController.text.trim(),
      receiptPath: _receiptImage?.path,
      tags: _tags.isEmpty ? null : _tags,
      isRecurring: _isRecurring,
      recurringType: _isRecurring ? _recurringType : null,
      accountId: selectedAccountId.value,
    );
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

  // ─── BUILD ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? NeoBrutalismTheme.darkBackground
          : NeoBrutalismTheme.primaryWhite,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'EDIT EXPENSE' : (_isPrefilled ? 'SMS EXPENSE' : 'ADD EXPENSE'),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: NeoBrutalismTheme.primaryBlack,
          ),
        ),
        backgroundColor: _getThemedColor(NeoBrutalismTheme.accentOrange, isDark),
        foregroundColor: NeoBrutalismTheme.primaryBlack,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // SMS detection banner
                if (_isPrefilled) _buildSmsBanner(isDark),
                if (_isPrefilled) const SizedBox(height: 12),

                _buildTitleField(isDark),
                const SizedBox(height: 16),
                _buildAmountField(isDark),
                const SizedBox(height: 16),
                _buildCategorySelector(isDark),
                const SizedBox(height: 16),
                NeoAccountPicker(
                  selectedAccountId: selectedAccountId,
                  isDark: isDark,
                  label: 'PAY FROM ACCOUNT',
                ),
                const SizedBox(height: 16),
                _buildDateSelector(isDark),
                const SizedBox(height: 16),
                _buildDescriptionField(isDark),
                const SizedBox(height: 16),
                _buildLocationField(isDark),
                const SizedBox(height: 16),
                _buildTagsField(isDark),
                const SizedBox(height: 16),
                _buildRecurringToggle(isDark),
                const SizedBox(height: 16),
                _buildReceiptSection(isDark),
                const SizedBox(height: 32),
                _buildSaveButton(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Banner shown when form is pre-filled from SMS
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
                const Text(
                  'AUTO-DETECTED FROM SMS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: NeoBrutalismTheme.primaryBlack,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fields pre-filled from your bank message. Review and save.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── FORM FIELDS (unchanged from original) ────────────────

  Widget _buildTitleField(bool isDark) {
    return NeoAutocompleteInput(
      controller: _titleController,
      label: 'EXPENSE TITLE',
      hint: 'e.g., Coffee at Starbucks',
      suggestions: autocompleteController.titles,
      onSuggestionSelected: (value) { _titleController.text = value; },
      isDark: isDark,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Please enter a title';
        if (value.trim().length < 3) return 'Title must be at least 3 characters';
        return null;
      },
    );
  }

  Widget _buildAmountField(bool isDark) {
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
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter an amount';
                  final amount = double.tryParse(value);
                  if (amount == null) return 'Please enter a valid number';
                  if (amount <= 0) return 'Amount must be greater than 0';
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
                    color: _getThemedColor(NeoBrutalismTheme.accentBlue, isDark),
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

  Widget _buildCategorySelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CATEGORY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showCategoryBottomSheet(isDark),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: NeoBrutalismTheme.neoBox(
                color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
                borderColor: NeoBrutalismTheme.primaryBlack),
            child: Row(
              children: [
                if (_selectedCategoryId != null) ...[
                  Text(categoryController.getCategoryById(_selectedCategoryId!)?.icon ?? '📁',
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(
                      categoryController.getCategoryById(_selectedCategoryId!)?.name.toUpperCase() ?? 'SELECT',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
                      overflow: TextOverflow.ellipsis)),
                ] else ...[
                  Expanded(child: Text('Select Category',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[400] : Colors.grey))),
                ],
                Icon(Icons.arrow_drop_down,
                    color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack, size: 24),
              ],
            ),
          ),
        ),
      ],
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

  Widget _buildDescriptionField(bool isDark) {
    return NeoInput(controller: _descriptionController, label: 'DESCRIPTION (OPTIONAL)',
        hint: 'Add any notes...', maxLines: 3, isDark: isDark,
        validator: (v) => v != null && v.trim().length > 500 ? 'Max 500 characters' : null);
  }

  Widget _buildLocationField(bool isDark) {
    return NeoAutocompleteInput(controller: _locationController,
        label: 'LOCATION (OPTIONAL)', hint: 'Where did you spend?',
        suggestions: autocompleteController.locations,
        onSuggestionSelected: (v) { _locationController.text = v; },
        suffixIcon: Icons.location_on, isDark: isDark);
  }

  Widget _buildTagsField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TAGS (OPTIONAL)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          ..._tags.map((tag) => Chip(
            label: Text(tag, style: const TextStyle(fontWeight: FontWeight.bold,
                color: NeoBrutalismTheme.primaryBlack)),
            onDeleted: () { setState(() { _tags.remove(tag); }); },
            backgroundColor: _getThemedColor(NeoBrutalismTheme.accentYellow, isDark),
            deleteIconColor: NeoBrutalismTheme.primaryBlack,
            side: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 2),
          )),
          ActionChip(
            label: Text('ADD TAG', style: TextStyle(fontWeight: FontWeight.bold,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
            onPressed: () => _addTag(isDark),
            backgroundColor: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            side: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 2),
          ),
        ]),
      ],
    );
  }

  Widget _buildRecurringToggle(bool isDark) {
    return NeoCard(
      color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('RECURRING EXPENSE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
          Switch(value: _isRecurring, onChanged: (v) { setState(() { _isRecurring = v; }); },
              activeColor: _getThemedColor(NeoBrutalismTheme.accentOrange, isDark),
              activeTrackColor: _getThemedColor(NeoBrutalismTheme.accentOrange, isDark).withOpacity(0.5),
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
            color: isSelected ? _getThemedColor(NeoBrutalismTheme.accentBlue, isDark)
                : (isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite),
            offset: isSelected ? 2 : 5, borderColor: NeoBrutalismTheme.primaryBlack),
        child: Center(child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
            color: isSelected ? NeoBrutalismTheme.primaryBlack
                : (isDark ? NeoBrutalismTheme.darkText.withOpacity(0.7)
                : NeoBrutalismTheme.primaryBlack.withOpacity(0.7))))),
      ),
    ));
  }

  Widget _buildReceiptSection(bool isDark) {
    return NeoCard(
      color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('RECEIPT (OPTIONAL)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 16),
        if (_receiptImage != null) ...[_buildReceiptPreview(isDark), const SizedBox(height: 12)],
        NeoButton(text: _receiptImage != null ? 'CHANGE RECEIPT' : 'ADD RECEIPT',
            onPressed: () => _pickReceipt(isDark),
            color: _getThemedColor(NeoBrutalismTheme.accentPurple, isDark), icon: Icons.camera_alt),
      ]),
    );
  }

  Widget _buildReceiptPreview(bool isDark) {
    return Container(
      height: 200,
      decoration: NeoBrutalismTheme.neoBox(
          color: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
          borderColor: NeoBrutalismTheme.primaryBlack),
      child: ClipRRect(borderRadius: BorderRadius.circular(4),
          child: Stack(fit: StackFit.expand, children: [
            Image.file(_receiptImage!, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.error_outline, size: 48, color: isDark ? Colors.grey[400] : Colors.grey),
                    const SizedBox(height: 8),
                    Text('Failed to load', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey)),
                  ]),
                )),
            Positioned(top: 8, right: 8, child: GestureDetector(
              onTap: () { setState(() { _receiptImage = null; }); },
              child: Container(padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle,
                      border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2)),
                  child: const Icon(Icons.close, color: NeoBrutalismTheme.primaryWhite, size: 16)),
            )),
          ])),
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return NeoButton(
      text: _isEditMode ? 'UPDATE EXPENSE' : (_isPrefilled ? 'SAVE SMS EXPENSE' : 'SAVE EXPENSE'),
      onPressed: _saveExpense,
      color: _getThemedColor(
          _isEditMode ? NeoBrutalismTheme.accentBlue : NeoBrutalismTheme.accentGreen, isDark),
      height: 64,
      icon: _isEditMode ? Icons.update : (_isPrefilled ? Icons.sms : Icons.save),
    );
  }

  Widget _buildImageSourceSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NeoBrutalismTheme.neoBoxRounded(
          color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
          borderColor: NeoBrutalismTheme.primaryBlack),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('SELECT IMAGE SOURCE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _buildImageSourceOption(icon: Icons.camera_alt, label: 'CAMERA',
              onTap: () => Navigator.pop(context, ImageSource.camera), isDark: isDark),
          _buildImageSourceOption(icon: Icons.photo_library, label: 'GALLERY',
              onTap: () => Navigator.pop(context, ImageSource.gallery), isDark: isDark),
        ]),
        const SizedBox(height: 10),
      ]),
    );
  }

  Widget _buildImageSourceOption({required IconData icon, required String label,
    required VoidCallback onTap, required bool isDark}) {
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.all(20),
      decoration: NeoBrutalismTheme.neoBox(
          color: _getThemedColor(NeoBrutalismTheme.accentPurple, isDark),
          borderColor: NeoBrutalismTheme.primaryBlack),
      child: Column(children: [
        Icon(icon, size: 40, color: NeoBrutalismTheme.primaryBlack),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12,
            color: NeoBrutalismTheme.primaryBlack)),
      ]),
    ));
  }
}