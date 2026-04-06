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
  State<AddTodoView> createState() => _AddTodoViewState();
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
  bool _isEditMode = false;
  TodoModel? _editingTodo;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map<String, dynamic> && (args['isEdit'] ?? false)) {
      _isEditMode = true;
      final todo = args['todo'] as TodoModel;
      _editingTodo = todo;
      _titleController.text = todo.title;
      _descriptionController.text = todo.description ?? '';
      _dueDate = todo.dueDate;
      _priority = todo.priority;
      _hasReminder = todo.hasReminder;
      if (todo.reminderTime != null) _reminderTime = TimeOfDay.fromDateTime(todo.reminderTime!);
      if (todo.tags != null) _tags = List<String>.from(todo.tags!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isDark) async {
    final picked = await showDatePicker(context: context,
        initialDate: _dueDate ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030),
        builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.light(
            primary: NeoBrutalismTheme.primaryBlack, onPrimary: NeoBrutalismTheme.primaryWhite,
            surface: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            onSurface: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)), child: child!));
    if (picked != null) setState(() { _dueDate = picked; });
  }

  Future<void> _selectTime(bool isDark) async {
    final picked = await showTimePicker(context: context, initialTime: _reminderTime,
        builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.light(
            primary: NeoBrutalismTheme.primaryBlack, onPrimary: NeoBrutalismTheme.primaryWhite,
            surface: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            onSurface: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)), child: child!));
    if (picked != null) setState(() { _reminderTime = picked; });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    DateTime? reminderDt;
    if (_hasReminder && _dueDate != null) {
      reminderDt = DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day, _reminderTime.hour, _reminderTime.minute);
    }
    final todo = TodoModel(
      id: _isEditMode ? _editingTodo!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      dueDate: _dueDate, priority: _priority, tags: _tags.isEmpty ? null : _tags,
      createdAt: _isEditMode ? _editingTodo!.createdAt : DateTime.now(),
      hasReminder: _hasReminder, reminderTime: reminderDt,
      isCompleted: _isEditMode ? _editingTodo!.isCompleted : false,
    );
    if (_isEditMode) {
      todoController.updateTodo(todo); Navigator.of(Get.context!).pop();
      Get.snackbar('Updated', 'Todo updated!', backgroundColor: NeoBrutalismTheme.accentBlue,
          colorText: NeoBrutalismTheme.primaryBlack, borderWidth: 3, borderColor: NeoBrutalismTheme.primaryBlack);
    } else {
      todoController.addTodo(todo); Navigator.of(Get.context!).pop();
      Get.snackbar('Created', 'Todo added!', backgroundColor: NeoBrutalismTheme.accentGreen,
          colorText: NeoBrutalismTheme.primaryBlack, borderWidth: 3, borderColor: NeoBrutalismTheme.primaryBlack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
      appBar: AppBar(
          title: Text(_isEditMode ? 'EDIT TODO' : 'ADD TODO',
              style: const TextStyle(fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
          backgroundColor: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentPurple, isDark),
          foregroundColor: NeoBrutalismTheme.primaryBlack, elevation: 0),
      body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
        _buildTitle(isDark).animate().fadeIn().slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
        _buildDescription(isDark).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
        _buildPriority(isDark).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
        _buildDueDate(isDark).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
        _buildReminder(isDark).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
        // Quick date shortcuts
        if (_dueDate == null) _buildQuickDates(isDark).animate().fadeIn(delay: 450.ms),
        if (_dueDate == null) const SizedBox(height: 16),
        _buildTags(isDark).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 32),
        _buildSaveBtn(isDark).animate().fadeIn(delay: 600.ms).scale(),
      ])),
    );
  }

  Widget _buildTitle(bool isDark) {
    return NeoInput(controller: _titleController, label: 'TODO TITLE',
        hint: 'What needs to be done?', isDark: isDark,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null);
  }

  Widget _buildDescription(bool isDark) {
    return NeoInput(controller: _descriptionController, label: 'DESCRIPTION (OPTIONAL)',
        hint: 'Add details...', maxLines: 3, isDark: isDark);
  }

  Widget _buildPriority(bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('PRIORITY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
      const SizedBox(height: 8),
      Row(children: [
        _priorityChip(1, 'LOW', const Color(0xFFB8E994), isDark),
        const SizedBox(width: 8),
        _priorityChip(2, 'MEDIUM', const Color(0xFFFDD663), isDark),
        const SizedBox(width: 8),
        _priorityChip(3, 'HIGH', const Color(0xFFE57373), isDark),
      ]),
    ]);
  }

  Widget _priorityChip(int val, String label, Color color, bool isDark) {
    final sel = _priority == val;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() { _priority = val; }),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: NeoBrutalismTheme.neoBox(
            color: sel ? color : (isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite),
            offset: sel ? 2 : 5, borderColor: NeoBrutalismTheme.primaryBlack),
        child: Center(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
            color: sel ? NeoBrutalismTheme.primaryBlack
                : (isDark ? NeoBrutalismTheme.darkText.withOpacity(0.7)
                : NeoBrutalismTheme.primaryBlack.withOpacity(0.7))))),
      ),
    ));
  }

  Widget _buildDueDate(bool isDark) {
    return GestureDetector(
      onTap: () => _selectDate(isDark),
      child: NeoCard(
        color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
        borderColor: NeoBrutalismTheme.primaryBlack,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('DUE DATE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
            const SizedBox(height: 4),
            Text(_dueDate != null ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}' : 'No due date',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                    color: _dueDate != null
                        ? (isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)
                        : (isDark ? Colors.grey[500] : Colors.grey[600]))),
          ]),
          Row(children: [
            if (_dueDate != null) GestureDetector(
              onTap: () => setState(() { _dueDate = null; _hasReminder = false; }),
              child: const Padding(padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.clear, size: 20, color: Colors.grey)),
            ),
            Icon(Icons.calendar_today,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack),
          ]),
        ]),
      ),
    );
  }

  /// Quick date shortcuts
  Widget _buildQuickDates(bool isDark) {
    return Row(children: [
      _quickDate('Today', DateTime.now(), isDark),
      const SizedBox(width: 8),
      _quickDate('Tomorrow', DateTime.now().add(const Duration(days: 1)), isDark),
      const SizedBox(width: 8),
      _quickDate('Next week', DateTime.now().add(const Duration(days: 7)), isDark),
    ]);
  }

  Widget _quickDate(String label, DateTime date, bool isDark) {
    return Expanded(child: GestureDetector(
      onTap: () => setState(() { _dueDate = DateTime(date.year, date.month, date.day); }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: isDark ? NeoBrutalismTheme.darkSurface : const Color(0xFFF0EEEB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5)),
        child: Center(child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack))),
      ),
    ));
  }

  Widget _buildReminder(bool isDark) {
    return NeoCard(
      color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('REMINDER', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
            if (_dueDate == null) Text('Set a due date first', style: TextStyle(fontSize: 11,
                color: isDark ? Colors.grey[500] : Colors.grey[600])),
          ]),
          Switch(value: _hasReminder,
              onChanged: _dueDate != null ? (v) => setState(() { _hasReminder = v; }) : null,
              activeColor: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentPurple, isDark)),
        ]),
        if (_hasReminder && _dueDate != null) ...[
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _selectTime(isDark),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: NeoBrutalismTheme.neoBox(
                  color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentBlue, isDark),
                  borderColor: NeoBrutalismTheme.primaryBlack),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.access_time, color: NeoBrutalismTheme.primaryBlack),
                const SizedBox(width: 8),
                Text(_reminderTime.format(context), style: const TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w800, color: NeoBrutalismTheme.primaryBlack)),
              ]),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _buildTags(bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('TAGS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        ..._tags.map((t) => Chip(
            label: Text(t, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12,
                color: NeoBrutalismTheme.primaryBlack)),
            onDeleted: () => setState(() { _tags.remove(t); }),
            backgroundColor: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentYellow, isDark),
            deleteIconColor: NeoBrutalismTheme.primaryBlack,
            side: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 2))),
        ActionChip(
            label: Text('+ TAG', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12,
                color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
            onPressed: () async {
              final tag = await Get.dialog<String>(_tagDialog(isDark));
              if (tag != null && tag.isNotEmpty && !_tags.contains(tag)) setState(() { _tags.add(tag); });
            },
            backgroundColor: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            side: const BorderSide(color: NeoBrutalismTheme.primaryBlack, width: 2)),
      ]),
    ]);
  }

  Widget _buildSaveBtn(bool isDark) {
    return NeoButton(text: _isEditMode ? 'UPDATE TODO' : 'SAVE TODO', onPressed: _save,
        color: NeoBrutalismTheme.getThemedColor(
            _isEditMode ? NeoBrutalismTheme.accentBlue : NeoBrutalismTheme.accentGreen, isDark),
        height: 64, icon: _isEditMode ? Icons.update : Icons.save);
  }

  Widget _tagDialog(bool isDark) {
    final c = TextEditingController();
    return Dialog(backgroundColor: Colors.transparent, child: Container(
      padding: const EdgeInsets.all(24),
      decoration: NeoBrutalismTheme.neoBoxRounded(
          color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
          borderColor: NeoBrutalismTheme.primaryBlack),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('ADD TAG', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 16),
        NeoInput(controller: c, label: 'TAG NAME', hint: 'e.g., Work', isDark: isDark),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: NeoButton(text: 'CANCEL', onPressed: () => Navigator.of(Get.context!).pop(),
              color: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite)),
          const SizedBox(width: 12),
          Expanded(child: NeoButton(text: 'ADD', onPressed: () => Get.back(result: c.text.trim()),
              color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentGreen, isDark))),
        ]),
      ]),
    ));
  }
}