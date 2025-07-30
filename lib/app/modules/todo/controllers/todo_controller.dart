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

  // Add date filter property
  final dateFilter = {'start': null as DateTime?, 'end': null as DateTime?}.obs;

  final NotificationService _notificationService = NotificationService();

  @override
  void onInit() {
    super.onInit();
    loadTodos();
    ever(todos, (_) => updateCounts());
  }

  void loadTodos() {
    todos.value =
        _todoBox.values.toList()..sort((a, b) {
          // Sort by completion status first, then by priority
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          return b.priority.compareTo(a.priority);
        });
    updateCounts();
  }

  void updateCounts() {
    final now = DateTime.now();
    pendingCount.value = todos.where((t) => !t.isCompleted).length;
    completedCount.value = todos.where((t) => t.isCompleted).length;
    overdueCount.value =
        todos
            .where(
              (t) =>
                  !t.isCompleted &&
                  t.dueDate != null &&
                  t.dueDate!.isBefore(now),
            )
            .length;
  }

  Future<void> addTodo(TodoModel todo) async {
    await _todoBox.put(todo.id, todo);

    // Schedule reminder if needed
    if (todo.hasReminder && todo.reminderTime != null) {
      await _notificationService.scheduleNotification(
        id: todo.id.hashCode,
        title: 'Todo Reminder',
        body: todo.title,
        scheduledDate: todo.reminderTime!,
      );
    }

    loadTodos();
  }

  Future<void> updateTodo(TodoModel todo) async {
    await todo.save();
    loadTodos();
  }

  Future<void> toggleTodo(TodoModel todo) async {
    todo.isCompleted = !todo.isCompleted;
    await todo.save();

    // Cancel reminder if completed
    if (todo.isCompleted && todo.hasReminder) {
      await _notificationService.cancelNotification(todo.id.hashCode);
    }

    loadTodos();
  }

  Future<void> deleteTodo(String id) async {
    final todo = _todoBox.get(id);
    if (todo != null && todo.hasReminder) {
      await _notificationService.cancelNotification(id.hashCode);
    }

    await _todoBox.delete(id);
    loadTodos();
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  // Add date filter methods
  void setDateFilter(DateTime? start, DateTime? end) {
    dateFilter.value = {'start': start, 'end': end};
  }

  void clearDateFilter() {
    dateFilter.value = {'start': null, 'end': null};
  }

  Future<void> updateTodoDueDate(TodoModel todo, DateTime newDate) async {
    // Cancel old reminder if exists
    if (todo.hasReminder && todo.reminderTime != null) {
      await _notificationService.cancelNotification(todo.id.hashCode);
    }

    // Update due date
    todo.dueDate = newDate;

    // Update reminder time if todo has reminder
    if (todo.hasReminder && todo.reminderTime != null) {
      // Keep the same time but update the date
      final oldTime = todo.reminderTime!;
      todo.reminderTime = DateTime(
        newDate.year,
        newDate.month,
        newDate.day,
        oldTime.hour,
        oldTime.minute,
      );

      // Schedule new reminder
      await _notificationService.scheduleNotification(
        id: todo.id.hashCode,
        title: 'Todo Reminder',
        body: todo.title,
        scheduledDate: todo.reminderTime!,
      );
    }

    await todo.save();
    loadTodos();
  }

  List<TodoModel> getFilteredTodos() {
    var filtered =
        todos.where((todo) {
          // Apply status filter
          switch (selectedFilter.value) {
            case 'pending':
              if (todo.isCompleted) return false;
              break;
            case 'completed':
              if (!todo.isCompleted) return false;
              break;
          }

          // Apply date filter
          final start = dateFilter.value['start'];
          final end = dateFilter.value['end'];

          if (start != null || end != null) {
            if (todo.dueDate == null) return false;

            if (start != null && todo.dueDate!.isBefore(start)) return false;
            if (end != null &&
                todo.dueDate!.isAfter(end.add(Duration(days: 1))))
              return false;
          }

          return true;
        }).toList();

    return filtered;
  }

  List<TodoModel> getTodosByPriority(int priority) {
    return todos
        .where((t) => t.priority == priority && !t.isCompleted)
        .toList();
  }

  List<TodoModel> getOverdueTodos() {
    final now = DateTime.now();
    return todos
        .where(
          (t) =>
              !t.isCompleted && t.dueDate != null && t.dueDate!.isBefore(now),
        )
        .toList();
  }

  List<TodoModel> getTodayTodos() {
    final now = DateTime.now();
    return todos
        .where(
          (t) =>
              !t.isCompleted &&
              t.dueDate != null &&
              t.dueDate!.year == now.year &&
              t.dueDate!.month == now.month &&
              t.dueDate!.day == now.day,
        )
        .toList();
  }
}
