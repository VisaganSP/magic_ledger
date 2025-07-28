import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/todo_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../../widgets/neo_input.dart';
import '../controllers/todo_controller.dart';

class AddTodoView extends StatefulWidget {
  @override
  _AddTodoViewState createState() => _AddTodoViewState();
}

class _AddTodoViewState extends State<AddTodoView> {
  final TodoController todoController = Get.find();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _dueDate;
  int _priority = 1;
  bool _hasReminder = false;
  TimeOfDay _reminderTime = TimeOfDay.now();
  List<String> _tags = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
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

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
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

    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
      DateTime? reminderDateTime;
      if (_hasReminder && _dueDate != null) {
        reminderDateTime = DateTime(
          _dueDate!.year,
          _dueDate!.month,
          _dueDate!.day,
          _reminderTime.hour,
          _reminderTime.minute,
        );
      }

      final todo = TodoModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description:
            _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
        dueDate: _dueDate,
        priority: _priority,
        tags: _tags.isEmpty ? null : _tags,
        createdAt: DateTime.now(),
        hasReminder: _hasReminder,
        reminderTime: reminderDateTime,
      );

      todoController.addTodo(todo);
      Get.back();
      Get.snackbar(
        'Success',
        'Todo added successfully!',
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
        title: const Text('ADD TODO'),
        backgroundColor: NeoBrutalismTheme.accentPurple,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTitleField().animate().fadeIn().slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            _buildDescriptionField()
                .animate()
                .fadeIn(delay: 100.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            _buildPrioritySelector()
                .animate()
                .fadeIn(delay: 200.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            _buildDueDateSelector()
                .animate()
                .fadeIn(delay: 300.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            _buildReminderSection()
                .animate()
                .fadeIn(delay: 400.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            _buildTagsSection()
                .animate()
                .fadeIn(delay: 500.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 32),
            _buildSaveButton().animate().fadeIn(delay: 600.ms).scale(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return NeoInput(
      controller: _titleController,
      label: 'TODO TITLE',
      hint: 'What needs to be done?',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return NeoInput(
      controller: _descriptionController,
      label: 'DESCRIPTION (OPTIONAL)',
      hint: 'Add more details...',
      maxLines: 3,
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PRIORITY',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPriorityOption(
                1,
                'LOW',
                NeoBrutalismTheme.accentGreen,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityOption(
                2,
                'MEDIUM',
                NeoBrutalismTheme.accentYellow,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityOption(
                3,
                'HIGH',
                NeoBrutalismTheme.accentPink,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityOption(int value, String label, Color color) {
    final isSelected = _priority == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _priority = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: NeoBrutalismTheme.neoBox(
          color: isSelected ? color : NeoBrutalismTheme.primaryWhite,
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

  Widget _buildDueDateSelector() {
    return GestureDetector(
      onTap: _selectDueDate,
      child: NeoCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DUE DATE (OPTIONAL)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  _dueDate != null
                      ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                      : 'No due date',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _dueDate != null ? null : Colors.grey[600],
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

  Widget _buildReminderSection() {
    return NeoCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SET REMINDER',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              ),
              Switch(
                value: _hasReminder,
                onChanged:
                    _dueDate != null
                        ? (value) {
                          setState(() {
                            _hasReminder = value;
                          });
                        }
                        : null,
                activeColor: NeoBrutalismTheme.primaryBlack,
              ),
            ],
          ),
          if (_hasReminder && _dueDate != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _selectReminderTime,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: NeoBrutalismTheme.neoBox(
                  color: NeoBrutalismTheme.accentBlue,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 8),
                    Text(
                      _reminderTime.format(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
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
                final String? tag = await Get.dialog<String>(_buildTagDialog());
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

  Widget _buildSaveButton() {
    return NeoButton(
      text: 'SAVE TODO',
      onPressed: _saveTodo,
      color: NeoBrutalismTheme.accentGreen,
      height: 64,
      icon: Icons.save,
    );
  }

  Widget _buildTagDialog() {
    final controller = TextEditingController();
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
              controller: controller,
              label: 'TAG NAME',
              hint: 'e.g., Work, Personal',
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
                    onPressed: () => Get.back(result: controller.text),
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
