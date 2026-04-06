import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/todo_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../controllers/todo_controller.dart';

class TodoDetailView extends StatefulWidget {
  const TodoDetailView({super.key});

  @override
  State<TodoDetailView> createState() => _TodoDetailViewState();
}

class _TodoDetailViewState extends State<TodoDetailView> {
  final TodoModel initialTodo = Get.arguments;
  final TodoController ctrl = Get.find();

  // Focus timer state
  bool _timerRunning = false;
  int _timerSeconds = 25 * 60; // 25 min default
  int _selectedMinutes = 25;
  Timer? _timer;
  int _totalFocusSeconds = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() { _timerRunning = true; _timerSeconds = _selectedMinutes * 60; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timerSeconds <= 0) {
        t.cancel();
        setState(() { _timerRunning = false; _totalFocusSeconds += _selectedMinutes * 60; });
        Get.snackbar('\u{1F389} Focus complete!', '${_selectedMinutes}min session done for "${initialTodo.title}"',
            backgroundColor: const Color(0xFFB8E994), colorText: NeoBrutalismTheme.primaryBlack,
            borderWidth: 3, borderColor: NeoBrutalismTheme.primaryBlack);
      } else {
        setState(() { _timerSeconds--; });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    final elapsed = (_selectedMinutes * 60) - _timerSeconds;
    setState(() { _timerRunning = false; _totalFocusSeconds += elapsed; });
  }

  String _formatTime(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final todo = ctrl.todos.firstWhere((t) => t.id == initialTodo.id, orElse: () => initialTodo);
      final isOverdue = todo.dueDate != null && todo.dueDate!.isBefore(DateTime.now()) && !todo.isCompleted;

      return Scaffold(
        backgroundColor: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
        appBar: AppBar(
          title: const Text('TASK DETAILS', style: TextStyle(fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.primaryBlack)),
          backgroundColor: NeoBrutalismTheme.getThemedColor(_priorityColor(todo.priority), isDark),
          foregroundColor: NeoBrutalismTheme.primaryBlack, elevation: 0,
          actions: [
            IconButton(icon: const Icon(Icons.edit), onPressed: () => Get.toNamed('/add-todo', arguments: {'todo': todo, 'isEdit': true})),
            IconButton(icon: const Icon(Icons.delete), onPressed: () => _confirmDelete(todo, isDark)),
          ],
        ),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          // Main card
          _buildMainCard(todo, isOverdue, isDark),
          const SizedBox(height: 16),

          // Focus timer
          if (!todo.isCompleted) _buildFocusTimer(todo, isDark),
          if (!todo.isCompleted) const SizedBox(height: 16),

          // Details
          _buildDetailsCard(todo, isDark),
          if (todo.tags != null && todo.tags!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildTagsCard(todo, isDark),
          ],
          const SizedBox(height: 16),

          // Snooze options (only for pending)
          if (!todo.isCompleted && todo.dueDate != null) _buildSnoozeCard(todo, isDark),
          if (!todo.isCompleted && todo.dueDate != null) const SizedBox(height: 16),

          // Action buttons
          _buildActions(todo, isDark),
          const SizedBox(height: 24),
        ]),
      );
    });
  }

  Widget _buildMainCard(TodoModel todo, bool isOverdue, bool isDark) {
    return Container(
      decoration: NeoBrutalismTheme.neoBox(
          color: NeoBrutalismTheme.getThemedColor(_priorityColor(todo.priority), isDark),
          borderColor: NeoBrutalismTheme.primaryBlack, offset: 5),
      child: Padding(padding: const EdgeInsets.all(18), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(
            onTap: () => ctrl.toggleTodo(todo),
            child: Container(width: 30, height: 30,
                decoration: BoxDecoration(
                    color: todo.isCompleted ? const Color(0xFFB8E994) : Colors.white,
                    border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 3),
                    borderRadius: BorderRadius.circular(6)),
                child: todo.isCompleted
                    ? const Icon(Icons.check, size: 20, color: NeoBrutalismTheme.primaryBlack) : null),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(todo.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.primaryBlack,
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null))),
        ]),
        if (todo.description != null && todo.description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(todo.description!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.7))),
        ],
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _chip(_priorityLabel(todo.priority), _priorityColor(todo.priority)),
          if (todo.dueDate != null)
            _chip('Due: ${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}',
                isOverdue ? const Color(0xFFE57373) : const Color(0xFFBFE3F0)),
          if (todo.hasReminder) _chip('\u{1F514} Reminder set', const Color(0xFFDCC9E8)),
          if (todo.isCompleted) _chip('\u{2705} DONE', const Color(0xFFB8E994)),
        ]),
      ],
      )),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2)),
      child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900,
          color: NeoBrutalismTheme.primaryBlack)),
    );
  }

  // ─── FOCUS TIMER ─────────────────────────────────────────

  Widget _buildFocusTimer(TodoModel todo, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: NeoBrutalismTheme.neoBox(
          color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
          borderColor: NeoBrutalismTheme.primaryBlack, offset: 4),
      child: Column(children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: NeoBrutalismTheme.primaryBlack,
                borderRadius: BorderRadius.circular(4)),
            child: const Text('FOCUS TIMER', style: TextStyle(fontSize: 9,
                fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const Spacer(),
          if (_totalFocusSeconds > 0)
            Text('Total: ${_formatTime(_totalFocusSeconds)}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ]),
        const SizedBox(height: 16),

        // Timer display
        Text(_formatTime(_timerRunning ? _timerSeconds : _selectedMinutes * 60),
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, fontFamily: 'monospace',
                color: _timerRunning ? const Color(0xFFE57373)
                    : (isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack))),
        const SizedBox(height: 12),

        // Duration selector (only when not running)
        if (!_timerRunning) Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (final m in [15, 25, 45, 60]) ...[
            GestureDetector(
              onTap: () => setState(() { _selectedMinutes = m; }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: _selectedMinutes == m ? const Color(0xFFBFE3F0) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5)),
                child: Text('${m}m', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                    color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
              ),
            ),
            if (m != 60) const SizedBox(width: 8),
          ],
        ]),
        const SizedBox(height: 16),

        // Start/Stop button
        NeoButton(
          text: _timerRunning ? 'STOP FOCUS' : 'START FOCUS',
          onPressed: _timerRunning ? _stopTimer : _startTimer,
          color: _timerRunning ? const Color(0xFFE57373)
              : NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
          icon: _timerRunning ? Icons.stop : Icons.play_arrow,
        ),
      ]),
    );
  }

  // ─── DETAILS CARD ────────────────────────────────────────

  Widget _buildDetailsCard(TodoModel todo, bool isDark) {
    return NeoCard(
      color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('DETAILS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 14),
        _detailRow('Created', '${todo.createdAt.day}/${todo.createdAt.month}/${todo.createdAt.year}', isDark),
        _detailRow('Status', todo.isCompleted ? 'Completed' : 'Pending', isDark),
        if (todo.hasReminder && todo.reminderTime != null)
          _detailRow('Reminder', '${todo.reminderTime!.day}/${todo.reminderTime!.month} at '
              '${todo.reminderTime!.hour.toString().padLeft(2, '0')}:${todo.reminderTime!.minute.toString().padLeft(2, '0')}', isDark),
        if (_totalFocusSeconds > 0)
          _detailRow('Focus time', _formatTime(_totalFocusSeconds), isDark),
      ]),
    );
  }

  Widget _detailRow(String label, String value, bool isDark) {
    return Padding(padding: const EdgeInsets.only(bottom: 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey[400] : Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
              color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        ]));
  }

  Widget _buildTagsCard(TodoModel todo, bool isDark) {
    return NeoCard(
      color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('TAGS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: todo.tags!.map((tag) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: NeoBrutalismTheme.neoBox(
              color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentYellow, isDark),
              borderColor: NeoBrutalismTheme.primaryBlack),
          child: Text(tag.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11,
              color: NeoBrutalismTheme.primaryBlack)),
        )).toList()),
      ]),
    );
  }

  // ─── SNOOZE CARD ─────────────────────────────────────────

  Widget _buildSnoozeCard(TodoModel todo, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: NeoBrutalismTheme.neoBox(
          color: isDark ? NeoBrutalismTheme.darkSurface : const Color(0xFFF5E6D3),
          borderColor: NeoBrutalismTheme.primaryBlack, offset: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('SNOOZE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
        const SizedBox(height: 10),
        Row(children: [
          _snoozeBtn('1h', const Duration(hours: 1), todo, isDark),
          const SizedBox(width: 8),
          _snoozeBtn('3h', const Duration(hours: 3), todo, isDark),
          const SizedBox(width: 8),
          _snoozeBtn('Tomorrow', const Duration(days: 1), todo, isDark),
          const SizedBox(width: 8),
          _snoozeBtn('Next week', const Duration(days: 7), todo, isDark),
        ]),
      ]),
    );
  }

  Widget _snoozeBtn(String label, Duration dur, TodoModel todo, bool isDark) {
    return Expanded(child: GestureDetector(
      onTap: () {
        ctrl.snoozeTodo(todo, dur);
        Get.snackbar('Snoozed', '$label', backgroundColor: const Color(0xFFBFE3F0),
            colorText: NeoBrutalismTheme.primaryBlack, duration: const Duration(seconds: 2));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 1.5)),
        child: Center(child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
            color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack))),
      ),
    ));
  }

  // ─── ACTIONS ─────────────────────────────────────────────

  Widget _buildActions(TodoModel todo, bool isDark) {
    return Row(children: [
      Expanded(child: NeoButton(text: 'EDIT', onPressed: () => Get.toNamed('/add-todo',
          arguments: {'todo': todo, 'isEdit': true}),
          color: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentBlue, isDark), icon: Icons.edit)),
      const SizedBox(width: 12),
      Expanded(child: NeoButton(
          text: todo.isCompleted ? 'REOPEN' : 'COMPLETE',
          onPressed: () => ctrl.toggleTodo(todo),
          color: NeoBrutalismTheme.getThemedColor(
              todo.isCompleted ? NeoBrutalismTheme.accentOrange : NeoBrutalismTheme.accentGreen, isDark),
          icon: todo.isCompleted ? Icons.replay : Icons.check)),
    ]);
  }

  void _confirmDelete(TodoModel todo, bool isDark) {
    Get.dialog(Dialog(backgroundColor: Colors.transparent, child: Container(
      padding: const EdgeInsets.all(24),
      decoration: NeoBrutalismTheme.neoBoxRounded(
          color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
          borderColor: NeoBrutalismTheme.primaryBlack),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.warning, size: 44, color: Colors.red),
        const SizedBox(height: 12),
        Text('DELETE "${todo.title.toUpperCase()}"?',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: NeoButton(text: 'CANCEL', onPressed: () => Navigator.of(Get.context!).pop(),
              color: NeoBrutalismTheme.primaryWhite)),
          const SizedBox(width: 12),
          Expanded(child: NeoButton(text: 'DELETE', onPressed: () {
            ctrl.deleteTodo(todo.id); Navigator.of(Get.context!).pop(); Navigator.of(Get.context!).pop();
          }, color: Colors.red, textColor: Colors.white)),
        ]),
      ]),
    )));
  }

  Color _priorityColor(int p) {
    switch (p) { case 3: return const Color(0xFFE57373); case 2: return const Color(0xFFFDD663); default: return const Color(0xFFB8E994); }
  }

  String _priorityLabel(int p) {
    switch (p) { case 3: return 'HIGH'; case 2: return 'MEDIUM'; default: return 'LOW'; }
  }
}