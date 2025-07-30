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
  const AddTodoView({super.key});

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

  // Track if we're editing
  bool _isEditMode = false;
  TodoModel? _editingTodo;

  // Helper method to get muted colors for dark theme
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
    if (args != null && args is Map<String, dynamic>) {
      _isEditMode = args['isEdit'] ?? false;
      final todo = args['todo'] as TodoModel?;

      if (_isEditMode && todo != null) {
        _editingTodo = todo;
        _populateFormWithTodo(todo);
      }
    }
  }

  void _populateFormWithTodo(TodoModel todo) {
    _titleController.text = todo.title;
    _descriptionController.text = todo.description ?? '';
    _dueDate = todo.dueDate;
    _priority = todo.priority;
    _hasReminder = todo.hasReminder;
    if (todo.reminderTime != null) {
      _reminderTime = TimeOfDay.fromDateTime(todo.reminderTime!);
    }
    if (todo.tags != null) {
      _tags = List<String>.from(todo.tags!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(bool isDark) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
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
                      : NeoBrutalismTheme.lightSurface,
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

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectReminderTime(bool isDark) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: NeoBrutalismTheme.primaryBlack,
              onPrimary: NeoBrutalismTheme.primaryWhite,
              surface:
                  isDark
                      ? NeoBrutalismTheme.darkSurface
                      : NeoBrutalismTheme.lightSurface,
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
        id:
            _isEditMode
                ? _editingTodo!.id
                : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description:
            _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
        dueDate: _dueDate,
        priority: _priority,
        tags: _tags.isEmpty ? null : _tags,
        createdAt: _isEditMode ? _editingTodo!.createdAt : DateTime.now(),
        hasReminder: _hasReminder,
        reminderTime: reminderDateTime,
        isCompleted: _isEditMode ? _editingTodo!.isCompleted : false,
      );

      if (_isEditMode) {
        todoController.updateTodo(todo);
        Get.back();
        Get.snackbar(
          'Success',
          'Todo updated successfully!',
          backgroundColor: NeoBrutalismTheme.accentBlue,
          colorText: NeoBrutalismTheme.primaryBlack,
          borderWidth: 3,
          borderColor: NeoBrutalismTheme.primaryBlack,
          duration: const Duration(seconds: 2),
        );
      } else {
        todoController.addTodo(todo);
        Get.back();
        Get.snackbar(
          'Success',
          'Todo added successfully!',
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
              : NeoBrutalismTheme.lightBackground,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'EDIT TODO' : 'ADD TODO',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: NeoBrutalismTheme.primaryBlack,
          ),
        ),
        backgroundColor: _getThemedColor(
          NeoBrutalismTheme.accentPurple,
          isDark,
        ),
        foregroundColor: NeoBrutalismTheme.primaryBlack,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTitleField(
              isDark,
            ).animate().fadeIn().slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            _buildDescriptionField(
              isDark,
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            _buildPrioritySelector(
              isDark,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            _buildDueDateSelector(
              isDark,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            _buildReminderSection(
              isDark,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 16),
            _buildTagsSection(
              isDark,
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 32),
            _buildSaveButton(isDark).animate().fadeIn(delay: 600.ms).scale(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField(bool isDark) {
    return NeoInput(
      controller: _titleController,
      label: 'TODO TITLE',
      hint: 'What needs to be done?',
      isDark: isDark,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField(bool isDark) {
    return NeoInput(
      controller: _descriptionController,
      label: 'DESCRIPTION (OPTIONAL)',
      hint: 'Add more details...',
      maxLines: 3,
      isDark: isDark,
    );
  }

  Widget _buildPrioritySelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRIORITY',
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
        Row(
          children: [
            Expanded(
              child: _buildPriorityOption(
                1,
                'LOW',
                NeoBrutalismTheme.accentGreen,
                isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityOption(
                2,
                'MEDIUM',
                NeoBrutalismTheme.accentYellow,
                isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityOption(
                3,
                'HIGH',
                NeoBrutalismTheme.accentPink,
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityOption(
    int value,
    String label,
    Color color,
    bool isDark,
  ) {
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
          color:
              isSelected
                  ? _getThemedColor(color, isDark)
                  : (isDark
                      ? NeoBrutalismTheme.darkSurface
                      : NeoBrutalismTheme.lightSurface),
          offset: isSelected ? 2 : 5,
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color:
                  isSelected
                      ? NeoBrutalismTheme.primaryBlack
                      : (isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDueDateSelector(bool isDark) {
    return GestureDetector(
      onTap: () => _selectDueDate(isDark),
      child: NeoCard(
        color:
            isDark
                ? NeoBrutalismTheme.darkSurface
                : NeoBrutalismTheme.lightSurface,
        borderColor: NeoBrutalismTheme.primaryBlack,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DUE DATE (OPTIONAL)',
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
                  _dueDate != null
                      ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                      : 'No due date',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color:
                        _dueDate != null
                            ? (isDark
                                ? NeoBrutalismTheme.darkText
                                : NeoBrutalismTheme.primaryBlack)
                            : (isDark ? Colors.grey[500] : Colors.grey[600]),
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

  Widget _buildReminderSection(bool isDark) {
    return NeoCard(
      color:
          isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.lightSurface,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SET REMINDER',
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
                value: _hasReminder,
                onChanged:
                    _dueDate != null
                        ? (value) {
                          setState(() {
                            _hasReminder = value;
                          });
                        }
                        : null,
                activeColor: _getThemedColor(
                  NeoBrutalismTheme.accentPurple,
                  isDark,
                ),
                activeTrackColor: _getThemedColor(
                  NeoBrutalismTheme.accentPurple,
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
          if (_hasReminder && _dueDate != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectReminderTime(isDark),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: NeoBrutalismTheme.neoBox(
                  color: _getThemedColor(NeoBrutalismTheme.accentBlue, isDark),
                  borderColor: NeoBrutalismTheme.primaryBlack,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: NeoBrutalismTheme.primaryBlack,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _reminderTime.format(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: NeoBrutalismTheme.primaryBlack,
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

  Widget _buildTagsSection(bool isDark) {
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
                final String? tag = await Get.dialog<String>(
                  _buildTagDialog(isDark),
                );
                if (tag != null && tag.isNotEmpty) {
                  setState(() {
                    _tags.add(tag);
                  });
                }
              },
              backgroundColor:
                  isDark
                      ? NeoBrutalismTheme.darkSurface
                      : NeoBrutalismTheme.lightSurface,
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

  Widget _buildSaveButton(bool isDark) {
    return NeoButton(
      text: _isEditMode ? 'UPDATE TODO' : 'SAVE TODO',
      onPressed: _saveTodo,
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

  Widget _buildTagDialog(bool isDark) {
    final controller = TextEditingController();
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: NeoBrutalismTheme.neoBoxRounded(
          color:
              isDark
                  ? NeoBrutalismTheme.darkSurface
                  : NeoBrutalismTheme.lightSurface,
          borderColor: NeoBrutalismTheme.primaryBlack,
        ),
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
              controller: controller,
              label: 'TAG NAME',
              hint: 'e.g., Work, Personal',
              isDark: isDark,
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
                            : NeoBrutalismTheme.lightBackground,
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
                    onPressed: () => Get.back(result: controller.text),
                    color: _getThemedColor(
                      NeoBrutalismTheme.accentGreen,
                      isDark,
                    ),
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
