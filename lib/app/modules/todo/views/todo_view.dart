import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../data/models/todo_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../controllers/todo_controller.dart';

class TodoView extends GetView<TodoController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalismTheme.primaryWhite,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-todo'),
        backgroundColor: NeoBrutalismTheme.accentPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: NeoBrutalismTheme.primaryBlack,
            width: 3,
          ),
        ),
        child: const Icon(Icons.add, size: 32),
      ).animate().scale(delay: 500.ms),
      body: Column(
        children: [
          _buildHeader(),
          _buildStats(),
          _buildFilterTabs(),
          Expanded(child: Obx(() => _buildTodoList())),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Text(
        'TODOS',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
      ),
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'PENDING',
              controller.pendingCount.value.toString(),
              NeoBrutalismTheme.accentOrange,
              Icons.pending_actions,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'COMPLETED',
              controller.completedCount.value.toString(),
              NeoBrutalismTheme.accentGreen,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'OVERDUE',
              controller.overdueCount.value.toString(),
              NeoBrutalismTheme.accentPink,
              Icons.warning,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return NeoCard(
      color: color,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildFilterTab(
                'ALL',
                'all',
                controller.selectedFilter.value == 'all',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFilterTab(
                'PENDING',
                'pending',
                controller.selectedFilter.value == 'pending',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFilterTab(
                'COMPLETED',
                'completed',
                controller.selectedFilter.value == 'completed',
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildFilterTab(String label, String value, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.changeFilter(value),
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }

  Widget _buildTodoList() {
    final todos = controller.getFilteredTodos();

    if (todos.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildTodoCard(todo, index),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: NeoBrutalismTheme.neoBox(
                color: NeoBrutalismTheme.accentPurple,
              ),
              child: const Icon(Icons.task_alt, size: 60),
            ).animate().scale(duration: 500.ms),
            const SizedBox(height: 24),
            const Text(
              'NO TODOS',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first todo',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            NeoButton(
              text: 'ADD TODO',
              onPressed: () => Get.toNamed('/add-todo'),
              color: NeoBrutalismTheme.accentPurple,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoCard(TodoModel todo, int index) {
    final isOverdue =
        todo.dueDate != null &&
        todo.dueDate!.isBefore(DateTime.now()) &&
        !todo.isCompleted;

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: NeoBrutalismTheme.neoBox(color: Colors.red),
        child: const Icon(
          Icons.delete,
          color: NeoBrutalismTheme.primaryWhite,
          size: 32,
        ),
      ),
      onDismissed: (direction) {
        controller.deleteTodo(todo.id);
      },
      child: NeoCard(
        color: _getPriorityColor(todo.priority),
        onTap: () => Get.toNamed('/todo-detail', arguments: todo),
        child: Row(
          children: [
            Checkbox(
              value: todo.isCompleted,
              onChanged: (value) => controller.toggleTodo(todo),
              activeColor: NeoBrutalismTheme.primaryBlack,
              side: const BorderSide(
                color: NeoBrutalismTheme.primaryBlack,
                width: 2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration:
                          todo.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (todo.description != null && todo.description!.isNotEmpty)
                    Text(
                      todo.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        decoration:
                            todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (todo.dueDate != null) ...[
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: isOverdue ? Colors.red : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${todo.dueDate!.day}/${todo.dueDate!.month}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverdue ? Colors.red : Colors.grey[600],
                            fontWeight: isOverdue ? FontWeight.bold : null,
                          ),
                        ),
                      ],
                      if (todo.hasReminder) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.notifications_active,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            _buildPriorityIndicator(todo.priority),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2, end: 0);
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 3:
        return NeoBrutalismTheme.accentPink.withOpacity(0.3);
      case 2:
        return NeoBrutalismTheme.accentYellow.withOpacity(0.3);
      default:
        return NeoBrutalismTheme.primaryWhite;
    }
  }

  Widget _buildPriorityIndicator(int priority) {
    String label;
    Color color;

    switch (priority) {
      case 3:
        label = 'HIGH';
        color = Colors.red;
        break;
      case 2:
        label = 'MED';
        color = Colors.orange;
        break;
      default:
        label = 'LOW';
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: NeoBrutalismTheme.primaryWhite,
        ),
      ),
    );
  }
}
