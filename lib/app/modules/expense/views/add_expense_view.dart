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

  // Helper method to get muted colors for dark theme
  Color _getThemedColor(Color color, bool isDark) {
    if (!isDark) return color;

    // Return slightly muted versions of colors for dark theme
    if (color == NeoBrutalismTheme.accentYellow) {
      return Color(0xFFE6B800); // Slightly darker yellow
    } else if (color == NeoBrutalismTheme.accentPink) {
      return Color(0xFFE667A0); // Slightly darker pink
    } else if (color == NeoBrutalismTheme.accentBlue) {
      return Color(0xFF4D94FF); // Slightly darker blue
    } else if (color == NeoBrutalismTheme.accentGreen) {
      return Color(0xFF00CC66); // Slightly darker green
    } else if (color == NeoBrutalismTheme.accentOrange) {
      return Color(0xFFFF8533); // Slightly darker orange
    } else if (color == NeoBrutalismTheme.accentPurple) {
      return Color(0xFF9966FF); // Slightly darker purple
    }
    return color;
  }

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

  Future<void> _pickReceipt(bool isDark) async {
    final ImagePicker picker = ImagePicker();

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            decoration: NeoBrutalismTheme.neoBoxRounded(
              color:
                  isDark
                      ? NeoBrutalismTheme.darkSurface
                      : NeoBrutalismTheme.primaryWhite,
              borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SELECT IMAGE SOURCE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color:
                        isDark
                            ? NeoBrutalismTheme.darkText
                            : NeoBrutalismTheme.primaryBlack,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      label: 'CAMERA',
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                      isDark: isDark,
                    ),
                    _buildImageSourceOption(
                      icon: Icons.photo_library,
                      label: 'GALLERY',
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                      isDark: isDark,
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
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: NeoBrutalismTheme.neoBox(
          color: _getThemedColor(NeoBrutalismTheme.accentPurple, isDark),
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: NeoBrutalismTheme.primaryBlack),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: NeoBrutalismTheme.primaryBlack,
              ),
            ),
          ],
        ),
      ),
    );
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
              surface:
                  isDark
                      ? NeoBrutalismTheme.darkSurface
                      : NeoBrutalismTheme.primaryWhite,
              onSurface:
                  isDark
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? NeoBrutalismTheme.darkBackground
              : NeoBrutalismTheme.primaryWhite,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'EDIT EXPENSE' : 'ADD EXPENSE',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: NeoBrutalismTheme.primaryBlack,
          ),
        ),
        backgroundColor: _getThemedColor(
          NeoBrutalismTheme.accentOrange,
          isDark,
        ),
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
                _buildTitleField(isDark),
                const SizedBox(height: 16),
                _buildAmountField(isDark),
                const SizedBox(height: 16),
                _buildCategorySelector(isDark),
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

  Widget _buildTitleField(bool isDark) {
    return NeoInput(
      controller: _titleController,
      label: 'EXPENSE TITLE',
      hint: 'e.g., Coffee at Starbucks',
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

  Widget _buildAmountField(bool isDark) {
    return NeoInput(
      controller: _amountController,
      label: 'AMOUNT',
      hint: '0.00',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      prefixText: '₹ ',
      isDark: isDark,
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

  Widget _buildCategorySelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATEGORY',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color:
                isDark
                    ? NeoBrutalismTheme.darkText
                    : NeoBrutalismTheme.primaryBlack,
          ),
        ),
        const SizedBox(height: 8),
        if (categoryController.categories.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: NeoBrutalismTheme.neoBox(
              color:
                  isDark
                      ? NeoBrutalismTheme.darkSurface
                      : NeoBrutalismTheme.primaryWhite,
              borderColor: NeoBrutalismTheme.primaryBlack,
            ),
            child: Center(
              child: Text(
                'No categories available. Please add categories first.',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey,
                ),
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
                                ? _getThemedColor(category.colorValue, isDark)
                                : (isDark
                                    ? NeoBrutalismTheme.darkSurface
                                    : NeoBrutalismTheme.primaryWhite),
                        offset: isSelected ? 2 : 5,
                        borderColor: NeoBrutalismTheme.primaryBlack,
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
                                      : (isDark
                                          ? NeoBrutalismTheme.darkText
                                              .withOpacity(0.7)
                                          : NeoBrutalismTheme.primaryBlack
                                              .withOpacity(0.7)),
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

  Widget _buildDateSelector(bool isDark) {
    return GestureDetector(
      onTap: () => _selectDate(isDark),
      child: NeoCard(
        color:
            isDark
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
                    color:
                        isDark
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
                    color:
                        isDark
                            ? NeoBrutalismTheme.darkText
                            : NeoBrutalismTheme.primaryBlack,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.calendar_today,
              color:
                  isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField(bool isDark) {
    return NeoInput(
      controller: _descriptionController,
      label: 'DESCRIPTION (OPTIONAL)',
      hint: 'Add any notes...',
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

  Widget _buildLocationField(bool isDark) {
    return NeoInput(
      controller: _locationController,
      label: 'LOCATION (OPTIONAL)',
      hint: 'Where did you spend?',
      suffixIcon: Icons.location_on,
      isDark: isDark,
    );
  }

  Widget _buildTagsField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TAGS (OPTIONAL)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color:
                isDark
                    ? NeoBrutalismTheme.darkText
                    : NeoBrutalismTheme.primaryBlack,
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
                backgroundColor: _getThemedColor(
                  NeoBrutalismTheme.accentYellow,
                  isDark,
                ),
                deleteIconColor: NeoBrutalismTheme.primaryBlack,
                side: const BorderSide(
                  color: NeoBrutalismTheme.primaryBlack,
                  width: 2,
                ),
              ),
            ),
            ActionChip(
              label: Text(
                'ADD TAG',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                ),
              ),
              onPressed: () async {
                final String? tag = await showDialog<String>(
                  context: context,
                  builder: (context) => const _TagDialog(),
                );
                if (tag != null && tag.isNotEmpty && !_tags.contains(tag)) {
                  setState(() {
                    _tags.add(tag);
                  });
                }
              },
              backgroundColor:
                  isDark
                      ? NeoBrutalismTheme.darkSurface
                      : NeoBrutalismTheme.primaryWhite,
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

  Widget _buildRecurringToggle(bool isDark) {
    return NeoCard(
      color:
          isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECURRING EXPENSE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color:
                      isDark
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
                  NeoBrutalismTheme.accentOrange,
                  isDark,
                ),
                activeTrackColor: _getThemedColor(
                  NeoBrutalismTheme.accentOrange,
                  isDark,
                ).withOpacity(0.5),
                inactiveThumbColor:
                    isDark
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
            color:
                isSelected
                    ? _getThemedColor(NeoBrutalismTheme.accentBlue, isDark)
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
                color:
                    isSelected
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

  Widget _buildReceiptSection(bool isDark) {
    return NeoCard(
      color:
          isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECEIPT (OPTIONAL)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color:
                  isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 16),
          if (_receiptImage != null) ...[
            Container(
              height: 200,
              decoration: NeoBrutalismTheme.neoBox(
                color:
                    isDark
                        ? NeoBrutalismTheme.darkBackground
                        : NeoBrutalismTheme.primaryWhite,
                borderColor: NeoBrutalismTheme.primaryBlack,
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
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: isDark ? Colors.grey[400] : Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Failed to load image',
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.grey[400] : Colors.grey,
                                ),
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
            onPressed: () => _pickReceipt(isDark),
            color: _getThemedColor(NeoBrutalismTheme.accentPurple, isDark),
            icon: Icons.camera_alt,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return NeoButton(
      text: _isEditMode ? 'UPDATE EXPENSE' : 'SAVE EXPENSE',
      onPressed: _saveExpense,
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

class _TagDialog extends StatefulWidget {
  const _TagDialog();

  @override
  State<_TagDialog> createState() => _TagDialogState();
}

class _TagDialogState extends State<_TagDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: NeoBrutalismTheme.neoBoxRounded(
          color:
              isDark
                  ? NeoBrutalismTheme.darkSurface
                  : NeoBrutalismTheme.primaryWhite,
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ADD TAG',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color:
                      isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 16),
              NeoInput(
                controller: _controller,
                label: 'TAG NAME',
                hint: 'e.g., Business, Personal',
                isDark: isDark,
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
                      color:
                          isDark
                              ? NeoBrutalismTheme.darkBackground
                              : NeoBrutalismTheme.primaryWhite,
                      textColor:
                          isDark
                              ? NeoBrutalismTheme.darkText
                              : NeoBrutalismTheme.primaryBlack,
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
