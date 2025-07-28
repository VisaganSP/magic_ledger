import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/todo_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../controllers/todo_controller.dart';

class TodoDetailView extends StatelessWidget {
  final TodoModel todo = Get.arguments;
  final TodoController todoController = Get.find();

  TodoDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalismTheme.primaryWhite,
      appBar: AppBar(
        title: const Text('TODO DETAILS'),
        backgroundColor: _getPriorityColor(todo.priority),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteDialog(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMainInfo(),
          const SizedBox(height: 24),
          _buildDetailsSection(),
          if (todo.tags != null && todo.tags!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildTagsSection(),
          ],
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildMainInfo() {
    return NeoCard(
      color: _getPriorityColor(todo.priority).withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: todo.isCompleted,
                onChanged: (value) {
                  todoController.toggleTodo(todo);
                  Get.back();
                },
                activeColor: NeoBrutalismTheme.primaryBlack,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        decoration:
                            todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                    if (todo.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        todo.description!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          decoration:
                              todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                _getPriorityLabel(todo.priority),
                _getPriorityColor(todo.priority),
              ),
              const SizedBox(width: 8),
              if (todo.dueDate != null)
                _buildInfoChip(
                  'Due: ${todo.dueDate!.day}/${todo.dueDate!.month}',
                  _isOverdue() ? Colors.red : NeoBrutalismTheme.accentBlue,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: NeoBrutalismTheme.primaryWhite,
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DETAILS',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Created',
            '${todo.createdAt.day}/${todo.createdAt.month}/${todo.createdAt.year}',
          ),
          if (todo.hasReminder && todo.reminderTime != null)
            _buildDetailRow(
              'Reminder',
              '${todo.reminderTime!.day}/${todo.reminderTime!.month} at ${todo.reminderTime!.hour}:${todo.reminderTime!.minute.toString().padLeft(2, '0')}',
            ),
          _buildDetailRow('Status', todo.isCompleted ? 'Completed' : 'Pending'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TAGS',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                todo.tags!
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: NeoBrutalismTheme.neoBox(
                          color: NeoBrutalismTheme.accentYellow,
                        ),
                        child: Text(
                          tag.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: NeoButton(
            text: todo.isCompleted ? 'MARK PENDING' : 'MARK COMPLETE',
            onPressed: () {
              todoController.toggleTodo(todo);
              Get.back();
            },
            color:
                todo.isCompleted
                    ? NeoBrutalismTheme.accentOrange
                    : NeoBrutalismTheme.accentGreen,
            icon: todo.isCompleted ? Icons.replay : Icons.check,
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 3:
        return NeoBrutalismTheme.accentPink;
      case 2:
        return NeoBrutalismTheme.accentYellow;
      default:
        return NeoBrutalismTheme.accentGreen;
    }
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 3:
        return 'HIGH PRIORITY';
      case 2:
        return 'MEDIUM PRIORITY';
      default:
        return 'LOW PRIORITY';
    }
  }

  bool _isOverdue() {
    return todo.dueDate != null &&
        todo.dueDate!.isBefore(DateTime.now()) &&
        !todo.isCompleted;
  }

  void _showDeleteDialog(BuildContext context) {
    Get.dialog(
      Dialog(
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
                'DELETE TODO?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              const Text(
                'This action cannot be undone.',
                style: TextStyle(fontSize: 16),
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
                      text: 'DELETE',
                      onPressed: () {
                        todoController.deleteTodo(todo.id);
                        Get.back();
                        Get.back();
                      },
                      color: Colors.red,
                      textColor: NeoBrutalismTheme.primaryWhite,
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
