import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/category_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_input.dart';
import '../controllers/category_controller.dart';

class AddCategoryView extends StatefulWidget {
  const AddCategoryView({super.key});

  @override
  _AddCategoryViewState createState() => _AddCategoryViewState();
}

class _AddCategoryViewState extends State<AddCategoryView> {
  final CategoryController categoryController = Get.find();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedIcon = '📁';
  Color _selectedColor = NeoBrutalismTheme.accentPink;

  final List<String> _availableIcons = [
    '📁',
    '🏠',
    '🚗',
    '✈️',
    '🍔',
    '🛍️',
    '💡',
    '💊',
    '📚',
    '🎬',
    '🎮',
    '🏋️',
    '💰',
    '🎁',
    '📱',
    '💻',
    '👕',
    '🏥',
    '🎨',
    '🎵',
    '📷',
    '⚽',
    '🍕',
    '☕',
  ];

  final List<Color> _availableColors = [
    NeoBrutalismTheme.accentPink,
    NeoBrutalismTheme.accentBlue,
    NeoBrutalismTheme.accentGreen,
    NeoBrutalismTheme.accentYellow,
    NeoBrutalismTheme.accentOrange,
    NeoBrutalismTheme.accentPurple,
    Colors.red,
    Colors.indigo,
    Colors.teal,
    Colors.brown,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final category = CategoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        icon: _selectedIcon,
        color: _selectedColor.value,
        budget:
            _budgetController.text.isNotEmpty
                ? double.parse(_budgetController.text)
                : null,
        description:
            _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
        isDefault: false,
      );

      categoryController.addCategory(category);
      Get.back();
      Get.snackbar(
        'Success',
        'Category added successfully!',
        backgroundColor: NeoBrutalismTheme.accentGreen,
        colorText: NeoBrutalismTheme.primaryBlack,
        borderWidth: 3,
        borderColor: NeoBrutalismTheme.primaryBlack,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalismTheme.primaryWhite,
      appBar: AppBar(
        title: const Text('ADD CATEGORY'),
        backgroundColor: NeoBrutalismTheme.accentGreen,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildNameField(),
            const SizedBox(height: 16),
            _buildIconSelector(),
            const SizedBox(height: 16),
            _buildColorSelector(),
            const SizedBox(height: 16),
            _buildBudgetField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return NeoInput(
      controller: _nameController,
      label: 'CATEGORY NAME',
      hint: 'e.g., Groceries',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a name';
        }
        return null;
      },
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SELECT ICON',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: NeoBrutalismTheme.neoBox(),
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _availableIcons.length,
            itemBuilder: (context, index) {
              final icon = _availableIcons[index];
              final isSelected = _selectedIcon == icon;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: NeoBrutalismTheme.neoBox(
                    color:
                        isSelected
                            ? NeoBrutalismTheme.accentYellow
                            : NeoBrutalismTheme.primaryWhite,
                    offset: isSelected ? 2 : 5,
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SELECT COLOR',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _availableColors.length,
            itemBuilder: (context, index) {
              final color = _availableColors[index];
              final isSelected = _selectedColor == color;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    decoration: NeoBrutalismTheme.neoBox(
                      color: color,
                      offset: isSelected ? 2 : 5,
                    ),
                    child:
                        isSelected
                            ? const Icon(
                              Icons.check,
                              color: NeoBrutalismTheme.primaryBlack,
                            )
                            : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetField() {
    return NeoInput(
      controller: _budgetController,
      label: 'MONTHLY BUDGET (OPTIONAL)',
      hint: '0.00',
      keyboardType: TextInputType.number,
      prefixText: '\$ ',
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return NeoInput(
      controller: _descriptionController,
      label: 'DESCRIPTION (OPTIONAL)',
      hint: 'What is this category for?',
      maxLines: 3,
    );
  }

  Widget _buildSaveButton() {
    return NeoButton(
      text: 'SAVE CATEGORY',
      onPressed: _saveCategory,
      color: NeoBrutalismTheme.accentGreen,
      height: 64,
      icon: Icons.save,
    );
  }
}
