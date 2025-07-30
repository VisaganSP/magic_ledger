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

  // Helper method to get muted colors for dark theme
  Color _getThemedColor(Color color, bool isDark) {
    if (!isDark) return color;

    // Return slightly muted versions of colors for dark theme
    if (color == NeoBrutalismTheme.accentYellow) {
      return Color(0xFFE6B800); // Slightly darker yellow
    } else if (color == NeoBrutalismTheme.accentPink) {
      return Color(0xFFE667A0); // Slightly darker pink
    } else if (color == NeoBrutalismTheme.accentBlue) {
      return Color(0xFF4D94FF); // Slightly darker blue
    } else if (color == NeoBrutalismTheme.accentGreen) {
      return Color(0xFF00CC66); // Slightly darker green
    } else if (color == NeoBrutalismTheme.accentOrange) {
      return Color(0xFFFF8533); // Slightly darker orange
    } else if (color == NeoBrutalismTheme.accentPurple) {
      return Color(0xFF9966FF); // Slightly darker purple
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? NeoBrutalismTheme.darkBackground
              : NeoBrutalismTheme.primaryWhite,
      appBar: AppBar(
        title: const Text(
          'TODO DETAILS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: NeoBrutalismTheme.primaryBlack,
          ),
        ),
        backgroundColor: _getThemedColor(
          _getPriorityColor(todo.priority),
          isDark,
        ),
        foregroundColor: NeoBrutalismTheme.primaryBlack,
        elevation: 0,
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
              _showDeleteDialog(context, isDark);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMainInfo(isDark),
          const SizedBox(height: 24),
          _buildDetailsSection(isDark),
          if (todo.tags != null && todo.tags!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildTagsSection(isDark),
          ],
          const SizedBox(height: 32),
          _buildActionButtons(isDark),
        ],
      ),
    );
  }

  Widget _buildMainInfo(bool isDark) {
    return NeoCard(
      color: _getThemedColor(_getPriorityColor(todo.priority), isDark),
      borderColor: NeoBrutalismTheme.primaryBlack,
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
                checkColor: NeoBrutalismTheme.primaryWhite,
                side: BorderSide(
                  color: NeoBrutalismTheme.primaryBlack,
                  width: 2,
                ),
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
                        color: NeoBrutalismTheme.primaryBlack,
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
                          color: NeoBrutalismTheme.primaryBlack.withOpacity(
                            0.8,
                          ),
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
                _getThemedColor(_getPriorityColor(todo.priority), isDark),
                isDark,
              ),
              const SizedBox(width: 8),
              if (todo.dueDate != null)
                _buildInfoChip(
                  'Due: ${todo.dueDate!.day}/${todo.dueDate!.month}',
                  _getThemedColor(
                    _isOverdue() ? Colors.red : NeoBrutalismTheme.accentBlue,
                    isDark,
                  ),
                  isDark,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color, bool isDark) {
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

  Widget _buildDetailsSection(bool isDark) {
    return NeoCard(
      color:
          isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DETAILS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color:
                  isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Created',
            '${todo.createdAt.day}/${todo.createdAt.month}/${todo.createdAt.year}',
            isDark,
          ),
          if (todo.hasReminder && todo.reminderTime != null)
            _buildDetailRow(
              'Reminder',
              '${todo.reminderTime!.day}/${todo.reminderTime!.month} at ${todo.reminderTime!.hour}:${todo.reminderTime!.minute.toString().padLeft(2, '0')}',
              isDark,
            ),
          _buildDetailRow(
            'Status',
            todo.isCompleted ? 'Completed' : 'Pending',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color:
                  isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(bool isDark) {
    return NeoCard(
      color:
          isDark
              ? NeoBrutalismTheme.darkSurface
              : NeoBrutalismTheme.primaryWhite,
      borderColor: NeoBrutalismTheme.primaryBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TAGS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color:
                  isDark
                      ? NeoBrutalismTheme.darkText
                      : NeoBrutalismTheme.primaryBlack,
            ),
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
                          color: _getThemedColor(
                            NeoBrutalismTheme.accentYellow,
                            isDark,
                          ),
                          borderColor: NeoBrutalismTheme.primaryBlack,
                        ),
                        child: Text(
                          tag.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: NeoBrutalismTheme.primaryBlack,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: NeoButton(
            text: todo.isCompleted ? 'MARK PENDING' : 'MARK COMPLETE',
            onPressed: () {
              todoController.toggleTodo(todo);
              Get.back();
            },
            color: _getThemedColor(
              todo.isCompleted
                  ? NeoBrutalismTheme.accentOrange
                  : NeoBrutalismTheme.accentGreen,
              isDark,
            ),
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

  void _showDeleteDialog(BuildContext context, bool isDark) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: NeoBrutalismTheme.neoBoxRounded(
            color:
                isDark
                    ? NeoBrutalismTheme.darkSurface
                    : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                'DELETE TODO?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color:
                      isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "${todo.title}"?',
                style: TextStyle(
                  fontSize: 16,
                  color:
                      isDark
                          ? NeoBrutalismTheme.darkText
                          : NeoBrutalismTheme.primaryBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
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
                              : NeoBrutalismTheme.primaryWhite,
                      textColor:
                          isDark
                              ? NeoBrutalismTheme.darkText
                              : NeoBrutalismTheme.primaryBlack,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      text: 'DELETE',
                      onPressed: () {
                        todoController.deleteTodo(todo.id);
                        Get.back(); // Close dialog
                        Get.back(); // Go back to previous screen
                        Get.snackbar(
                          'Todo Deleted',
                          '${todo.title} has been removed',
                          backgroundColor: Colors.red,
                          colorText: NeoBrutalismTheme.primaryWhite,
                          borderWidth: 3,
                          borderColor: NeoBrutalismTheme.primaryBlack,
                          duration: const Duration(seconds: 2),
                          icon: const Icon(
                            Icons.delete_forever,
                            color: NeoBrutalismTheme.primaryWhite,
                          ),
                        );
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
