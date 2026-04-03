import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../data/models/todo_model.dart';
import '../../../data/services/notification_service.dart';

class TodoController extends GetxController {
  final Box<TodoModel> _todoBox = Hive.box('todos');
  final RxList<TodoModel> todos = <TodoModel>[].obs;
  final RxString selectedFilter = 'all'.obs;
  final RxInt pendingCount = 0.obs;
  final RxInt completedCount = 0.obs;
  final RxInt overdueCount = 0.obs;
  final dateFilter = {'start': null as DateTime?, 'end': null as DateTime?}.obs;
  final NotificationService _notif = NotificationService();

  // Productivity tracking
  final RxInt todayCompleted = 0.obs;
  final RxInt todayTotal = 0.obs;
  final RxInt streak = 0.obs;
  final RxInt dailyGoal = 5.obs;

  @override
  void onInit() {
    super.onInit();
    loadTodos();
    ever(todos, (_) => _refreshStats());
    _loadDailyGoal();
  }

  void loadTodos() {
    todos.value = _todoBox.values.toList()..sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      return b.priority.compareTo(a.priority);
    });
    _refreshStats();
  }

  void _refreshStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    pendingCount.value = todos.where((t) => !t.isCompleted).length;
    completedCount.value = todos.where((t) => t.isCompleted).length;
    overdueCount.value = todos.where((t) =>
    !t.isCompleted && t.dueDate != null && t.dueDate!.isBefore(now)).length;

    // Today's stats
    todayTotal.value = todos.where((t) =>
    t.dueDate != null && t.dueDate!.isAfter(today.subtract(const Duration(hours: 1))) &&
        t.dueDate!.isBefore(tomorrow)).length;
    todayCompleted.value = todos.where((t) =>
    t.isCompleted && t.dueDate != null &&
        t.dueDate!.isAfter(today.subtract(const Duration(hours: 1))) &&
        t.dueDate!.isBefore(tomorrow)).length;

    _calcStreak();
  }

  void _calcStreak() {
    int s = 0;
    final now = DateTime.now();
    for (int d = 0; d < 365; d++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: d));
      final dayEnd = day.add(const Duration(days: 1));
      final dayTodos = todos.where((t) => t.dueDate != null &&
          t.dueDate!.isAfter(day.subtract(const Duration(hours: 1))) &&
          t.dueDate!.isBefore(dayEnd)).toList();
      if (dayTodos.isEmpty) { if (d == 0) continue; break; }
      if (dayTodos.every((t) => t.isCompleted)) { s++; } else { if (d > 0) break; }
    }
    streak.value = s;
  }

  void _loadDailyGoal() {
    try {
      final box = Hive.box('settings');
      dailyGoal.value = box.get('todo_daily_goal', defaultValue: 5);
    } catch (_) {}
  }

  Future<void> setDailyGoal(int goal) async {
    dailyGoal.value = goal;
    try {
      final box = Hive.box('settings');
      await box.put('todo_daily_goal', goal);
    } catch (_) {}
  }

  // ═══════════════════════════════════════════════════════════
  // CRUD
  // ═══════════════════════════════════════════════════════════

  Future<void> addTodo(TodoModel todo) async {
    await _todoBox.put(todo.id, todo);
    if (todo.hasReminder && todo.reminderTime != null) {
      _scheduleReminder(todo);
    }
    loadTodos();
  }

  Future<void> updateTodo(TodoModel updated) async {
    try {
      final existing = _todoBox.get(updated.id);
      if (existing == null) return;
      existing.title = updated.title;
      existing.description = updated.description;
      existing.priority = updated.priority;
      existing.dueDate = updated.dueDate;
      existing.tags = updated.tags;
      existing.hasReminder = updated.hasReminder;
      existing.reminderTime = updated.reminderTime;
      existing.isCompleted = updated.isCompleted;
      await existing.save();

      if (existing.hasReminder && existing.reminderTime != null) {
        _scheduleReminder(existing);
      } else {
        await _notif.cancelNotification(existing.id.hashCode);
      }
      loadTodos();
    } catch (e) {
      debugPrint('Error updating todo: $e');
    }
  }

  Future<void> toggleTodo(TodoModel todo) async {
    try {
      final existing = _todoBox.get(todo.id);
      if (existing == null) return;
      existing.isCompleted = !existing.isCompleted;
      await existing.save();
      if (existing.isCompleted && existing.hasReminder) {
        await _notif.cancelNotification(existing.id.hashCode);
      }
      loadTodos();
    } catch (e) {
      debugPrint('Error toggling todo: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    final todo = _todoBox.get(id);
    if (todo != null && todo.hasReminder) {
      await _notif.cancelNotification(id.hashCode);
    }
    await _todoBox.delete(id);
    loadTodos();
  }

  // ═══════════════════════════════════════════════════════════
  // SNOOZE
  // ═══════════════════════════════════════════════════════════

  Future<void> snoozeTodo(TodoModel todo, Duration duration) async {
    try {
      final existing = _todoBox.get(todo.id);
      if (existing == null) return;
      final newDate = DateTime.now().add(duration);
      existing.dueDate = newDate;
      if (existing.hasReminder && existing.reminderTime != null) {
        await _notif.cancelNotification(existing.id.hashCode);
        existing.reminderTime = newDate.subtract(const Duration(minutes: 30));
        _scheduleReminder(existing);
      }
      await existing.save();
      loadTodos();
    } catch (e) {
      debugPrint('Error snoozing: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════

  Future<void> _scheduleReminder(TodoModel todo) async {
    try {
      if (todo.reminderTime == null) return;
      if (todo.reminderTime!.isBefore(DateTime.now())) {
        debugPrint('[Todo] Reminder time is in the past, skipping');
        return;
      }
      await _notif.scheduleNotification(
        id: todo.id.hashCode,
        title: _priorityEmoji(todo.priority) + ' Todo: ${todo.title}',
        body: todo.description ?? 'Time to get this done!',
        scheduledDate: todo.reminderTime!,
        payload: 'todo:${todo.id}',
      );
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
    }
  }

  String _priorityEmoji(int p) {
    switch (p) { case 3: return '\u{1F525}'; case 2: return '\u{26A1}'; default: return '\u{2705}'; }
  }

  Future<void> updateTodoDueDate(TodoModel todo, DateTime newDate) async {
    try {
      final existing = _todoBox.get(todo.id);
      if (existing == null) return;
      if (existing.hasReminder) await _notif.cancelNotification(existing.id.hashCode);
      existing.dueDate = newDate;
      if (existing.hasReminder && existing.reminderTime != null) {
        final old = existing.reminderTime!;
        existing.reminderTime = DateTime(newDate.year, newDate.month, newDate.day, old.hour, old.minute);
        _scheduleReminder(existing);
      }
      await existing.save();
      loadTodos();
    } catch (e) {
      debugPrint('Error updating due date: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // FILTERING & GROUPING
  // ═══════════════════════════════════════════════════════════

  void changeFilter(String f) => selectedFilter.value = f;
  void setDateFilter(DateTime? s, DateTime? e) => dateFilter.value = {'start': s, 'end': e};
  void clearDateFilter() => dateFilter.value = {'start': null, 'end': null};

  List<TodoModel> getFilteredTodos() {
    return todos.where((t) {
      switch (selectedFilter.value) {
        case 'pending': if (t.isCompleted) return false; break;
        case 'completed': if (!t.isCompleted) return false; break;
        case 'overdue':
          if (t.isCompleted || t.dueDate == null || !t.dueDate!.isBefore(DateTime.now())) return false;
          break;
      }
      final s = dateFilter.value['start'];
      final e = dateFilter.value['end'];
      if (s != null || e != null) {
        if (t.dueDate == null) return false;
        if (s != null && t.dueDate!.isBefore(s)) return false;
        if (e != null && t.dueDate!.isAfter(e.add(const Duration(days: 1)))) return false;
      }
      return true;
    }).toList();
  }

  /// Group todos into smart sections
  Map<String, List<TodoModel>> getGroupedTodos() {
    final filtered = getFilteredTodos();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final weekEnd = today.add(const Duration(days: 7));

    final groups = <String, List<TodoModel>>{
      'Overdue': [],
      'Today': [],
      'Tomorrow': [],
      'This week': [],
      'Later': [],
      'No date': [],
      'Completed': [],
    };

    for (final t in filtered) {
      if (t.isCompleted) { groups['Completed']!.add(t); continue; }
      if (t.dueDate == null) { groups['No date']!.add(t); continue; }
      if (t.dueDate!.isBefore(today)) { groups['Overdue']!.add(t); continue; }
      if (t.dueDate!.isBefore(tomorrow)) { groups['Today']!.add(t); continue; }
      if (t.dueDate!.isBefore(tomorrow.add(const Duration(days: 1)))) { groups['Tomorrow']!.add(t); continue; }
      if (t.dueDate!.isBefore(weekEnd)) { groups['This week']!.add(t); continue; }
      groups['Later']!.add(t);
    }

    // Remove empty groups
    groups.removeWhere((_, v) => v.isEmpty);
    return groups;
  }

  // ═══════════════════════════════════════════════════════════
  // PRODUCTIVITY
  // ═══════════════════════════════════════════════════════════

  double get completionRate {
    if (todos.isEmpty) return 0;
    return completedCount.value / todos.length * 100;
  }

  double get todayProgress {
    if (dailyGoal.value <= 0) return 0;
    return (todayCompleted.value / dailyGoal.value * 100).clamp(0, 100);
  }

  String get productivityGrade {
    final rate = todayProgress;
    if (rate >= 100) return 'S';
    if (rate >= 80) return 'A';
    if (rate >= 60) return 'B';
    if (rate >= 40) return 'C';
    if (rate >= 20) return 'D';
    return 'F';
  }

  List<TodoModel> getTodosByPriority(int p) => todos.where((t) => t.priority == p && !t.isCompleted).toList();
  List<TodoModel> getOverdueTodos() => todos.where((t) => !t.isCompleted && t.dueDate != null && t.dueDate!.isBefore(DateTime.now())).toList();
  List<TodoModel> getTodayTodos() {
    final n = DateTime.now();
    return todos.where((t) => !t.isCompleted && t.dueDate != null &&
        t.dueDate!.year == n.year && t.dueDate!.month == n.month && t.dueDate!.day == n.day).toList();
  }

  /// Batch complete
  Future<void> completeAll(List<TodoModel> items) async {
    for (final t in items) {
      final e = _todoBox.get(t.id);
      if (e != null && !e.isCompleted) { e.isCompleted = true; await e.save(); }
    }
    loadTodos();
  }

  /// Batch delete
  Future<void> deleteAll(List<String> ids) async {
    for (final id in ids) { await _todoBox.delete(id); }
    loadTodos();
  }
}