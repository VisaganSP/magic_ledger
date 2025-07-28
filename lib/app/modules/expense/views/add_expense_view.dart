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
  State<AddExpenseView> createState() => _AddExpenseViewState();
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

  // Track if we're editing
  bool _isEditMode = false;
  ExpenseModel? _editingExpense;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Initialize form data after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFormData();
    });
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
    if (args != null && args is Map<String, dynamic>) {
      _isEditMode = args['isEdit'] ?? false;
      final expense = args['expense'] as ExpenseModel?;

      if (_isEditMode && expense != null) {
        _editingExpense = expense;
        _populateFormWithExpense(expense);
      }
    }

    // Set default category if none selected
    if (_selectedCategoryId == null &&
        categoryController.categories.isNotEmpty) {
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
      if (expense.tags != null) {
        _tags.addAll(expense.tags!);
      }
      _isRecurring = expense.isRecurring;
      _recurringType = expense.recurringType ?? 'monthly';
      if (expense.receiptPath != null) {
        _receiptImage = File(expense.receiptPath!);
      }
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

  Future<void> _pickReceipt() async {
    final ImagePicker picker = ImagePicker();

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            decoration: NeoBrutalismTheme.neoBoxRounded(
              color: NeoBrutalismTheme.primaryWhite,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'SELECT IMAGE SOURCE',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      label: 'CAMERA',
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                    ),
                    _buildImageSourceOption(
                      icon: Icons.photo_library,
                      label: 'GALLERY',
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
    );

    if (source != null) {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _receiptImage = File(image.path);
        });
      }
    }
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: NeoBrutalismTheme.neoBox(
          color: NeoBrutalismTheme.accentPurple,
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: NeoBrutalismTheme.primaryBlack),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
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
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        Get.snackbar(
          'Error',
          'Please select a category',
          backgroundColor: Colors.red,
          colorText: NeoBrutalismTheme.primaryWhite,
          borderWidth: 3,
          borderColor: NeoBrutalismTheme.primaryBlack,
        );
        return;
      }

      final expense = ExpenseModel(
        id:
            _isEditMode
                ? _editingExpense!.id
                : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        categoryId: _selectedCategoryId!,
        date: _selectedDate,
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        location:
            _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
        receiptPath: _receiptImage?.path,
        tags: _tags.isEmpty ? null : _tags,
        isRecurring: _isRecurring,
        recurringType: _isRecurring ? _recurringType : null,
      );

      if (_isEditMode) {
        expenseController.updateExpense(expense);
        Get.back();
        Get.snackbar(
          'Success',
          'Expense updated successfully!',
          backgroundColor: NeoBrutalismTheme.accentBlue,
          colorText: NeoBrutalismTheme.primaryBlack,
          borderWidth: 3,
          borderColor: NeoBrutalismTheme.primaryBlack,
          duration: const Duration(seconds: 2),
        );
      } else {
        expenseController.addExpense(expense);
        Get.back();
        Get.snackbar(
          'Success',
          'Expense added successfully!',
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
          _isEditMode ? 'EDIT EXPENSE' : 'ADD EXPENSE',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: NeoBrutalismTheme.accentOrange,
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

  Widget _buildAmountField() {
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

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CATEGORY',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: NeoBrutalismTheme.primaryBlack,
          ),
        ),
        const SizedBox(height: 8),
        if (categoryController.categories.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: NeoBrutalismTheme.neoBox(
              color: NeoBrutalismTheme.primaryWhite,
            ),
            child: const Center(
              child: Text(
                'No categories available. Please add categories first.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
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
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected
                                      ? NeoBrutalismTheme.primaryBlack
                                      : NeoBrutalismTheme.primaryBlack
                                          .withOpacity(0.7),
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

  Widget _buildDescriptionField() {
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: NeoBrutalismTheme.primaryBlack,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._tags.map(
              (tag) => Chip(
                label: Text(
                  tag,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: NeoBrutalismTheme.primaryBlack,
                  ),
                ),
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
              label: const Text(
                'ADD TAG',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: NeoBrutalismTheme.primaryBlack,
                ),
              ),
              onPressed: () async {
                final String? tag = await showDialog<String>(
                  context: context,
                  builder: (context) => _TagDialog(),
                );
                if (tag != null && tag.isNotEmpty && !_tags.contains(tag)) {
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
      color: NeoBrutalismTheme.primaryWhite,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RECURRING EXPENSE',
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
                activeColor: NeoBrutalismTheme.accentOrange,
                activeTrackColor: NeoBrutalismTheme.accentOrange.withOpacity(
                  0.5,
                ),
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
            color:
                isSelected
                    ? NeoBrutalismTheme.accentBlue
                    : NeoBrutalismTheme.primaryWhite,
            offset: isSelected ? 2 : 5,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color:
                    isSelected
                        ? NeoBrutalismTheme.primaryBlack
                        : NeoBrutalismTheme.primaryBlack.withOpacity(0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptSection() {
    return NeoCard(
      color: NeoBrutalismTheme.primaryWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECEIPT (OPTIONAL)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 16),
          if (_receiptImage != null) ...[
            Container(
              height: 200,
              decoration: NeoBrutalismTheme.neoBox(
                color: NeoBrutalismTheme.primaryWhite,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      _receiptImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _receiptImage = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: NeoBrutalismTheme.primaryBlack,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: NeoBrutalismTheme.primaryWhite,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
      text: _isEditMode ? 'UPDATE EXPENSE' : 'SAVE EXPENSE',
      onPressed: _saveExpense,
      color:
          _isEditMode
              ? NeoBrutalismTheme.accentBlue
              : NeoBrutalismTheme.accentGreen,
      height: 64,
      icon: _isEditMode ? Icons.update : Icons.save,
    );
  }
}

class _TagDialog extends StatelessWidget {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  _TagDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: NeoBrutalismTheme.neoBoxRounded(
          color: NeoBrutalismTheme.primaryWhite,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ADD TAG',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: NeoBrutalismTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 16),
              NeoInput(
                controller: _controller,
                label: 'TAG NAME',
                hint: 'e.g., Business, Personal',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a tag name';
                  }
                  if (value.trim().length > 20) {
                    return 'Tag must be less than 20 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      text: 'CANCEL',
                      onPressed: () => Get.back(),
                      color: NeoBrutalismTheme.primaryWhite,
                      textColor: NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      text: 'ADD',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Get.back(result: _controller.text.trim());
                        }
                      },
                      color: NeoBrutalismTheme.accentGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
