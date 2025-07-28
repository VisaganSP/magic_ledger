import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/expense_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../../widgets/neo_input.dart';
import '../../category/controllers/category_controller.dart';
import '../controllers/expense_controller.dart';

class AddExpenseView extends StatefulWidget {
  const AddExpenseView({super.key});

  @override
  _AddExpenseViewState createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<AddExpenseView>
    with TickerProviderStateMixin {
  final ExpenseController expenseController = Get.find();
  final CategoryController categoryController = Get.find();

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

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _receiptImage = File(image.path);
      });
    }
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

  void _saveExpense() {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      final expense = ExpenseModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        categoryId: _selectedCategoryId!,
        date: _selectedDate,
        description:
            _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
        location:
            _locationController.text.isEmpty ? null : _locationController.text,
        receiptPath: _receiptImage?.path,
        tags: _tags.isEmpty ? null : _tags,
        isRecurring: _isRecurring,
        recurringType: _isRecurring ? _recurringType : null,
      );

      expenseController.addExpense(expense);
      Get.back();
      Get.snackbar(
        'Success',
        'Expense added successfully!',
        backgroundColor: NeoBrutalismTheme.accentGreen,
        colorText: NeoBrutalismTheme.primaryBlack,
        borderWidth: 3,
        borderColor: NeoBrutalismTheme.primaryBlack,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalismTheme.primaryWhite,
      appBar: AppBar(
        title: const Text('ADD EXPENSE'),
        backgroundColor: NeoBrutalismTheme.accentOrange,
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
                _buildTitleField(),
                const SizedBox(height: 16),
                _buildAmountField(),
                const SizedBox(height: 16),
                _buildCategorySelector(),
                const SizedBox(height: 16),
                _buildDateSelector(),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 16),
                _buildLocationField(),
                const SizedBox(height: 16),
                _buildTagsField(),
                const SizedBox(height: 16),
                _buildRecurringToggle(),
                const SizedBox(height: 16),
                _buildReceiptSection(),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return NeoInput(
      controller: _titleController,
      label: 'EXPENSE TITLE',
      hint: 'e.g., Coffee at Starbucks',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _buildAmountField() {
    return NeoInput(
      controller: _amountController,
      label: 'AMOUNT',
      hint: '0.00',
      keyboardType: TextInputType.number,
      prefixText: '\$ ',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CATEGORY',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categoryController.categories.length,
            itemBuilder: (context, index) {
              final category = categoryController.categories[index];
              final isSelected = _selectedCategoryId == category.id;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = category.id;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    decoration: NeoBrutalismTheme.neoBoxRounded(
                      color:
                          isSelected
                              ? category.colorValue
                              : NeoBrutalismTheme.primaryWhite,
                      offset: isSelected ? 2 : 5,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: NeoCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DATE',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return NeoInput(
      controller: _descriptionController,
      label: 'DESCRIPTION (OPTIONAL)',
      hint: 'Add any notes...',
      maxLines: 3,
    );
  }

  Widget _buildLocationField() {
    return NeoInput(
      controller: _locationController,
      label: 'LOCATION (OPTIONAL)',
      hint: 'Where did you spend?',
      suffixIcon: Icons.location_on,
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TAGS (OPTIONAL)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._tags.map(
              (tag) => Chip(
                label: Text(tag),
                onDeleted: () {
                  setState(() {
                    _tags.remove(tag);
                  });
                },
                backgroundColor: NeoBrutalismTheme.accentYellow,
                deleteIconColor: NeoBrutalismTheme.primaryBlack,
                side: const BorderSide(
                  color: NeoBrutalismTheme.primaryBlack,
                  width: 2,
                ),
              ),
            ),
            ActionChip(
              label: const Text('ADD TAG'),
              onPressed: () async {
                final String? tag = await showDialog<String>(
                  context: context,
                  builder: (context) => _TagDialog(),
                );
                if (tag != null && tag.isNotEmpty) {
                  setState(() {
                    _tags.add(tag);
                  });
                }
              },
              backgroundColor: NeoBrutalismTheme.primaryWhite,
              side: const BorderSide(
                color: NeoBrutalismTheme.primaryBlack,
                width: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecurringToggle() {
    return NeoCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RECURRING EXPENSE',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              ),
              Switch(
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value;
                  });
                },
                activeColor: NeoBrutalismTheme.primaryBlack,
              ),
            ],
          ),
          if (_isRecurring) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildRecurringOption('DAILY', 'daily')),
                const SizedBox(width: 8),
                Expanded(child: _buildRecurringOption('WEEKLY', 'weekly')),
                const SizedBox(width: 8),
                Expanded(child: _buildRecurringOption('MONTHLY', 'monthly')),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecurringOption(String label, String value) {
    final isSelected = _recurringType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _recurringType = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: NeoBrutalismTheme.neoBox(
          color:
              isSelected
                  ? NeoBrutalismTheme.accentBlue
                  : NeoBrutalismTheme.primaryWhite,
          offset: isSelected ? 2 : 5,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptSection() {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECEIPT (OPTIONAL)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          if (_receiptImage != null) ...[
            Container(
              height: 200,
              decoration: NeoBrutalismTheme.neoBox(),
              child: Image.file(_receiptImage!, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
          ],
          NeoButton(
            text: _receiptImage != null ? 'CHANGE RECEIPT' : 'ADD RECEIPT',
            onPressed: _pickReceipt,
            color: NeoBrutalismTheme.accentPurple,
            icon: Icons.camera_alt,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return NeoButton(
      text: 'SAVE EXPENSE',
      onPressed: _saveExpense,
      color: NeoBrutalismTheme.accentGreen,
      height: 64,
      icon: Icons.save,
    );
  }
}

class _TagDialog extends StatelessWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: NeoBrutalismTheme.neoBoxRounded(
          color: NeoBrutalismTheme.primaryWhite,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ADD TAG',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            NeoInput(
              controller: _controller,
              label: 'TAG NAME',
              hint: 'e.g., Business, Personal',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: NeoButton(
                    text: 'CANCEL',
                    onPressed: () => Get.back(),
                    color: NeoBrutalismTheme.primaryWhite,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeoButton(
                    text: 'ADD',
                    onPressed: () => Get.back(result: _controller.text),
                    color: NeoBrutalismTheme.accentGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
