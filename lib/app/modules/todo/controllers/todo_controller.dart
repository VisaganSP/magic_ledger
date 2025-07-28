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

  List<TodoModel> getFilteredTodos() {
    switch (selectedFilter.value) {
      case 'pending':
        return todos.where((t) => !t.isCompleted).toList();
      case 'completed':
        return todos.where((t) => t.isCompleted).toList();
      default:
        return todos;
    }
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
